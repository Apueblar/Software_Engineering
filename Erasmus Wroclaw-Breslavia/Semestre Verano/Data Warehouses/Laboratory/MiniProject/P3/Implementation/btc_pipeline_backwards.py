"""
btc_backfill.py — Bitcoin Blockchain Historical Backfill Pipeline
=================================================================
Walks BACKWARD from the lowest block currently in STG_BLOCKS toward
block 0, fetching blocks, transactions, market data, and loading the DW
in complete, self-contained batches.

Resumable: the frontier is derived from MIN(height) in STG_BLOCKS on
every startup — no separate state file needed. Stop and restart at any
time; the pipeline picks up exactly where it left off.

Graceful shutdown: pressing Ctrl+C sets a stop flag. The pipeline
completes the current batch in full (blocks + transactions + market +
DW load are all committed to both staging and DW) before exiting. This
guarantees the database is always in a consistent state, even mid-run.

Usage
-----
  # Start/resume backfill using blocks_per_run from config.yaml
  python btc_backfill.py

  # Override the batch size (number of blocks per batch)
  python btc_backfill.py --batch-size 50

  # Dry run — show frontier and exit without fetching anything
  python btc_backfill.py --status

Prerequisites
-------------
  - btc_pipeline.py must be in the same directory (shared imports).
  - Run btc_pipeline.py --run-now at least once first so STG_BLOCKS
    has at least one row to establish the starting frontier.
  - Same requirements as btc_pipeline.py (see HOW_TO_RUN.txt).
"""

import argparse
import logging
import signal
import sys
import time
from datetime import datetime, UTC
from pathlib import Path

import pyodbc

# ---------------------------------------------------------------------------
# Shared imports from the forward pipeline
# Re-use ALL helpers — DB connections, logging, HTTP, staging loaders,
# DW loaders. The backfill only adds its own block-backward fetcher.
# ---------------------------------------------------------------------------
from btc_pipeline import (
    load_config,
    setup_logging,
    get_connection,
    log_run_start,
    log_run_finish,
    http_get,
    fetch_and_load_transactions,
    fetch_and_load_market,
    fetch_and_load_fear_greed,
    fetch_and_load_dominance,
    run_dw_load,
)

log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Graceful shutdown — Ctrl+C
# ---------------------------------------------------------------------------

_stop_requested: bool = False


def _handle_sigint(signum, frame):
    """
    First Ctrl+C  → set flag; current batch finishes cleanly then exits.
    Second Ctrl+C → hard exit immediately (data already committed up to
                    last completed batch).
    """
    global _stop_requested
    if not _stop_requested:
        _stop_requested = True
        log.warning(
            "Ctrl+C received — finishing current batch before stopping. "
            "All data will be committed. Press Ctrl+C again to force-quit."
        )
    else:
        log.warning("Second Ctrl+C — force-quitting immediately.")
        sys.exit(1)


signal.signal(signal.SIGINT, _handle_sigint)


# ---------------------------------------------------------------------------
# Backfill frontier helpers
# ---------------------------------------------------------------------------

def get_backfill_frontier(cur: pyodbc.Cursor) -> int | None:
    """
    Return the lowest block height currently in STG_BLOCKS.

    This is the backfill frontier — the next batch will start at
    (frontier - 1) and walk further down toward block 0.

    Returns None if STG_BLOCKS is empty (cannot start yet).
    Resuming is automatic: after a stopped run, MIN(height) is still the
    last block loaded, so the next run starts exactly one below it.
    """
    cur.execute(
        "SELECT MIN(height) FROM dbo.STG_BLOCKS WHERE is_active = 1"
    )
    row = cur.fetchone()
    return row[0] if row and row[0] is not None else None


def get_forward_watermark(cur: pyodbc.Cursor) -> int | None:
    """Return the highest block height in STG_BLOCKS (forward pipeline mark)."""
    cur.execute(
        "SELECT MAX(height) FROM dbo.STG_BLOCKS WHERE is_active = 1"
    )
    row = cur.fetchone()
    return row[0] if row and row[0] is not None else None


def get_staging_block_count(cur: pyodbc.Cursor) -> int:
    """Return total active blocks currently staged."""
    cur.execute("SELECT COUNT(*) FROM dbo.STG_BLOCKS WHERE is_active = 1")
    return cur.fetchone()[0]


# ---------------------------------------------------------------------------
# Backward block fetcher
# ---------------------------------------------------------------------------

def fetch_blocks_backward(
    conn: pyodbc.Connection,
    cfg: dict,
    start_height: int,
    batch_size: int,
) -> tuple[int, int, int | None]:
    """
    Fetch blocks starting at `start_height` and walking DOWN toward
    block 0.  Stops after `batch_size` blocks have been seen (fetched),
    regardless of how many were actually new (inserted).

    Counting `fetched` (not `inserted`) toward the limit matches the
    forward pipeline's behaviour and guarantees the frontier always
    advances by exactly `batch_size` height units per batch — even if
    some blocks in the range are already staged (e.g. from an earlier
    partial run or a forward-pipeline overlap).

    Parameters
    ----------
    conn         : open staging connection
    cfg          : full config dict
    start_height : block height to begin fetching from (inclusive)
    batch_size   : number of blocks to process before returning

    Returns
    -------
    (fetched, inserted, lowest_height_loaded)
      fetched              — total blocks seen from the API
      inserted             — blocks actually new and inserted into staging
      lowest_height_loaded — smallest height inserted this batch (None if 0)
    """
    fetch_cfg = cfg["fetch"]
    retries   = fetch_cfg["max_retries"]
    backoff   = fetch_cfg["retry_backoff_sec"]

    cur    = conn.cursor()
    log_id = log_run_start(cur, "backfill_blocks")
    conn.commit()

    fetched: int       = 0
    inserted: int      = 0
    lowest_loaded: int | None = None
    current_start: int = start_height

    log.info(
        "Fetching up to %d blocks backward from height %d ...",
        batch_size, start_height,
    )

    try:
        while fetched < batch_size:
            if _stop_requested:
                log.info("Stop flag set — aborting block fetch mid-page.")
                break

            if current_start < 0:
                log.info("Passed height 0 — backfill complete.")
                break

            # mempool.space returns a page of ~10 blocks in descending order
            page = http_get(
                f"https://mempool.space/api/v1/blocks/{current_start}",
                max_retries=retries,
                backoff=backoff,
            )

            if not page:
                log.info(
                    "Empty page returned at height %d — no more blocks.",
                    current_start,
                )
                break

            for block in page:
                if fetched >= batch_size or _stop_requested:
                    break

                height = block["height"]
                extras = block.get("extras") or {}
                pool   = extras.get("pool") or {}

                # IF NOT EXISTS guard — safe to run even if block already staged
                cur.execute(
                    """
                    IF NOT EXISTS (SELECT 1 FROM dbo.STG_BLOCKS WHERE block_hash = ?)
                    INSERT INTO dbo.STG_BLOCKS (
                        block_hash, height, block_version,
                        block_timestamp, median_time,
                        tx_count, size_bytes, weight_units,
                        difficulty, nonce, bits,
                        merkle_root, previous_block_hash,
                        total_fees_sat, avg_fee_rate, median_fee_rate,
                        pool_name, pool_slug, miner_reward_sat
                    ) VALUES (?,?,CAST(? AS INT),CAST(? AS BIGINT),CAST(? AS BIGINT),
                              CAST(? AS INT),CAST(? AS INT),CAST(? AS INT),?,CAST(? AS BIGINT),CAST(? AS BIGINT),
                              ?,?,CAST(? AS BIGINT),
                              CAST(? AS INT),CAST(? AS INT),?,?,CAST(? AS BIGINT))
                    """,
                    block["id"],          # EXISTS check value
                    # INSERT values
                    block["id"],          # block_hash
                    height,               # height
                    block.get("version"),
                    block["timestamp"],
                    block.get("mediantime", block["timestamp"]),
                    block["tx_count"],
                    block["size"],
                    block["weight"],
                    block["difficulty"],
                    block["nonce"],
                    block.get("bits"),
                    block.get("merkle_root"),
                    block.get("previousblockhash"),
                    extras.get("totalFees"),
                    extras.get("avgFeeRate"),
                    extras.get("medianFee"),
                    pool.get("name"),
                    pool.get("slug"),
                    extras.get("reward"),
                )

                fetched += 1

                if cur.rowcount > 0:
                    inserted += 1
                    if lowest_loaded is None or height < lowest_loaded:
                        lowest_loaded = height

            # Advance the start point to one below the lowest height in this page.
            # mempool.space pages descend, so page[-1]["height"] is the lowest.
            next_start = page[-1]["height"] - 1
            if next_start < 0:
                log.info("Reached below block 0 — chain fully covered.")
                break
            current_start = next_start

        conn.commit()
        log.info(
            "Block fetch complete — fetched=%d, inserted=%d (new), "
            "lowest_inserted=%s",
            fetched, inserted, lowest_loaded,
        )
        log_run_finish(
            cur, log_id,
            fetched=fetched,
            inserted=inserted,
            last_height=lowest_loaded,
        )
        conn.commit()

    except Exception as exc:
        conn.rollback()
        log.error("Backward block fetch failed: %s", exc)
        log_run_finish(cur, log_id, fetched, inserted, error=str(exc))
        conn.commit()
        raise

    return fetched, inserted, lowest_loaded


# ---------------------------------------------------------------------------
# Single batch runner
# ---------------------------------------------------------------------------

def run_batch(
    conn: pyodbc.Connection,
    cfg: dict,
    batch_num: int,
    frontier: int,
    batch_size: int,
) -> tuple[bool, int | None]:
    """
    Execute one complete backfill batch:
      1. Fetch `batch_size` blocks backward from (frontier - 1)
      2. Fetch transactions for all pending blocks
      3. Refresh market OHLCV (idempotent — no-op if already loaded)
      4. Refresh Fear & Greed (idempotent)
      5. Refresh BTC dominance (idempotent)
      6. Full DW load (picks up everything new in staging)

    Steps 3-5 are fast no-ops once the forward pipeline has populated
    the full market history. They are kept here so the backfill can
    operate standalone if needed (i.e. market data was never loaded).

    Returns
    -------
    (reached_genesis, lowest_height)
      reached_genesis — True if block 0 was loaded in this batch
      lowest_height   — smallest height loaded (None if nothing inserted)
    """
    start_height = frontier - 1
    log.info(
        "=== Batch #%d | frontier=%d | fetching from height %d downward ===",
        batch_num, frontier, start_height,
    )

    # ------------------------------------------------------------------ #
    # Step 1 — Blocks (backward)
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 1: Blocks (backward from %d) ---",
             batch_num, start_height)

    _fetched, inserted, lowest = fetch_blocks_backward(
        conn, cfg, start_height, batch_size
    )

    if inserted == 0:
        # All blocks in this range are already staged.
        # This can happen when the forward pipeline has fetched historical
        # blocks that overlap the backfill range (very rare).
        # Log and return so the outer loop can re-evaluate the frontier.
        log.info(
            "No new blocks inserted for range starting at %d "
            "(already staged). Frontier has not changed.",
            start_height,
        )
        # Return False + None so the outer loop knows to stop / re-check
        return False, None

    # ------------------------------------------------------------------ #
    # Step 2 — Transactions
    # Processes ALL blocks in STG_BLOCKS that have no transactions yet,
    # which includes everything loaded in this batch.
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 2: Transactions ---", batch_num)
    fetch_and_load_transactions(conn, cfg)

    # ------------------------------------------------------------------ #
    # Step 3 — Market OHLCV
    # No-op if already fully loaded; Yahoo Finance history starts ~2014.
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 3: Market OHLCV ---", batch_num)
    fetch_and_load_market(conn, cfg)

    # ------------------------------------------------------------------ #
    # Step 4 — Fear & Greed (Alternative.me, starts 2019-02-01)
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 4: Fear & Greed ---", batch_num)
    fetch_and_load_fear_greed(conn, cfg)

    # ------------------------------------------------------------------ #
    # Step 5 — BTC dominance (CoinLore live + static interpolation)
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 5: BTC Dominance ---", batch_num)
    fetch_and_load_dominance(conn, cfg)

    # ------------------------------------------------------------------ #
    # Step 6 — DW load  (Staging → BTC_DW star schema, all sub-steps)
    # ------------------------------------------------------------------ #
    log.info("--- Batch %d / Step 6: DW Load ---", batch_num)
    run_dw_load(conn, cfg)

    log.info(
        "=== Batch #%d complete | lowest block loaded: %s ===",
        batch_num, lowest,
    )

    reached_genesis = lowest is not None and lowest <= 0
    return reached_genesis, lowest


# ---------------------------------------------------------------------------
# Status reporter (--status flag)
# ---------------------------------------------------------------------------

def print_status(cfg: dict):
    """
    Connect to staging, read the current frontier and forward watermark,
    and print a human-readable status summary. Does not fetch any data.
    """
    try:
        conn = get_connection(cfg)
    except pyodbc.Error as exc:
        print(f"ERROR: Cannot connect to SQL Server: {exc}")
        sys.exit(1)

    try:
        cur = conn.cursor()
        frontier = get_backfill_frontier(cur)
        forward  = get_forward_watermark(cur)
        total    = get_staging_block_count(cur)

        print()
        print("=" * 55)
        print("  BTC Backfill — Current Status")
        print("=" * 55)

        if frontier is None:
            print("  STG_BLOCKS is empty.")
            print("  Run btc_pipeline.py --run-now first.")
        else:
            print(f"  Forward watermark (highest block) : {forward:>9,}")
            print(f"  Backfill frontier (lowest block)  : {frontier:>9,}")
            print(f"  Blocks not yet staged (0 to {frontier - 1:,})  : {frontier:>9,}")
            print(f"  Total blocks currently staged     : {total:>9,}")

            if frontier <= 0:
                print()
                print("  ✓ Backfill is COMPLETE — block 0 already staged.")
            else:
                print()
                print(f"  Next batch will start at height   : {frontier - 1:>9,}")

        print("=" * 55)
        print()

    finally:
        conn.close()


# ---------------------------------------------------------------------------
# Main backfill loop
# ---------------------------------------------------------------------------

def run_backfill(cfg: dict, batch_size: int):
    """
    Outer loop: keep running batches until block 0 is reached, Ctrl+C is
    pressed, or an unrecoverable error occurs.

    Each batch opens its own staging connection, commits all data to both
    BTC_Staging and BTC_DW, then closes cleanly before the next batch
    begins. This means every completed batch is fully durable — if the
    process is killed between batches, no data is lost.
    """
    batch_num  = 0
    zero_insert_streak = 0   # safety counter against infinite loops

    while not _stop_requested:
        batch_num += 1

        # Open a fresh connection for each batch so a failed batch's partial
        # state does not bleed into the next one.
        try:
            conn = get_connection(cfg)
        except pyodbc.Error as exc:
            log.critical("Cannot connect to SQL Server: %s", exc)
            return

        try:
            cur      = conn.cursor()
            frontier = get_backfill_frontier(cur)

            if frontier is None:
                log.critical(
                    "STG_BLOCKS is empty. Run btc_pipeline.py --run-now "
                    "first to establish at least one block as the starting "
                    "frontier."
                )
                return

            if frontier <= 0:
                log.info(
                    "Frontier is block 0 — backfill is fully complete. "
                    "Nothing left to fetch."
                )
                return

            try:
                reached_genesis, lowest = run_batch(
                    conn, cfg, batch_num, frontier, batch_size
                )
            except Exception as exc:
                log.error(
                    "Batch #%d failed with an unhandled error: %s. "
                    "Stopping backfill — re-run to resume from frontier %d.",
                    batch_num, exc, frontier,
                )
                return

        finally:
            conn.close()

        # ------------------------------------------------------------------
        # Post-batch checks
        # ------------------------------------------------------------------

        if lowest is None:
            # Nothing was inserted — all blocks in range already existed.
            zero_insert_streak += 1
            log.warning(
                "Batch #%d inserted 0 new blocks (streak=%d). "
                "This usually means the range is already covered.",
                batch_num, zero_insert_streak,
            )
            if zero_insert_streak >= 3:
                log.error(
                    "Three consecutive batches with 0 new blocks. "
                    "Stopping to avoid infinite loop. "
                    "Check STG_BLOCKS for gaps or run btc_pipeline.py to "
                    "verify the forward watermark."
                )
                return
        else:
            zero_insert_streak = 0  # reset streak on successful insert

        if reached_genesis:
            log.info(
                "Block 0 reached in batch #%d — historical backfill is "
                "complete! The full Bitcoin chain is now in staging.",
                batch_num,
            )
            return

        if _stop_requested:
            break

        # Polite pause between batches — avoids hammering the mempool.space
        # API and gives SQL Server a moment to breathe between large loads.
        log.info("Pausing 3 s before next batch ...")
        time.sleep(3)

    # ------------------------------------------------------------------
    # Exit message
    # ------------------------------------------------------------------
    if _stop_requested:
        log.info(
            "Backfill stopped by user after %d completed batch(es). "
            "Re-run btc_backfill.py to continue — it will resume "
            "automatically from the current frontier.",
            batch_num,
        )
    else:
        log.info("Backfill loop exited after %d batch(es).", batch_num)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description=(
            "BTC Historical Backfill Pipeline — fetches backwards from the "
            "lowest staged block to block 0. Safe to stop and resume at any time."
        ),
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python btc_backfill.py                   # use blocks_per_run from config.yaml
  python btc_backfill.py --batch-size 50   # 50 blocks per batch (slower, safer)
  python btc_backfill.py --batch-size 500  # 500 blocks per batch (faster overnight)
  python btc_backfill.py --status          # show frontier without fetching
        """,
    )
    parser.add_argument(
        "--batch-size",
        type=int,
        default=None,
        metavar="N",
        help=(
            "Number of blocks to fetch per batch. "
            "Defaults to fetch.blocks_per_run in config.yaml "
            f"(currently read at startup)."
        ),
    )
    parser.add_argument(
        "--status",
        action="store_true",
        help="Print the current backfill frontier and exit. Does not fetch data.",
    )
    args = parser.parse_args()

    cfg = load_config()
    setup_logging(cfg)

    # --status: show info and exit
    if args.status:
        print_status(cfg)
        return

    batch_size = (
        args.batch_size
        if args.batch_size is not None
        else cfg["fetch"]["blocks_per_run"]
    )

    log.info("=" * 60)
    log.info("BTC Backfill Pipeline started — %s", datetime.now(UTC))
    log.info("Batch size : %d blocks per batch", batch_size)
    log.info("Stop with  : Ctrl+C  (current batch completes before exit)")
    log.info("Resume with: python btc_backfill.py  (auto-detects frontier)")
    log.info("=" * 60)

    run_backfill(cfg, batch_size)

    log.info("BTC Backfill Pipeline finished — %s", datetime.now(UTC))


if __name__ == "__main__":
    main()
