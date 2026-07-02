"""
btc_pipeline.py — Bitcoin Blockchain Analytics Staging Pipeline
================================================================
Fetches on-chain data (mempool.space) and market data (Yahoo Finance via
yfinance + Alternative.me) and loads them incrementally into the BTC_Staging
SQL Server database created by 01_staging_schema.sql.

Usage
-----
  # Run once immediately
  python btc_pipeline.py --run-now

  # Run on schedule defined in config.yaml (interval_days)
  python btc_pipeline.py --schedule

  # Override schedule interval from command line (every 2 days)
  python btc_pipeline.py --schedule --days 2

Requirements
------------
  pip install -r requirements.txt
  SQL Server ODBC Driver 17 must be installed.
  Run 01_staging_schema.sql on your SQL Server instance first.
"""

import argparse
import bisect
import logging
import math
import time
from datetime import datetime, timedelta, timezone, date, UTC
from pathlib import Path

import pyodbc
import requests
import schedule
import yaml
import yfinance as yf

# ---------------------------------------------------------------------------
# Config
# ---------------------------------------------------------------------------

CONFIG_FILE = Path(__file__).parent / "config.yaml"


def load_config() -> dict:
    with open(CONFIG_FILE, "r") as f:
        return yaml.safe_load(f)


# ---------------------------------------------------------------------------
# Logging
# ---------------------------------------------------------------------------

def setup_logging(cfg: dict):
    log_file = Path(__file__).parent / cfg["logging"]["log_file"]
    level = getattr(logging, cfg["logging"]["level"].upper(), logging.INFO)
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        handlers=[
            logging.FileHandler(log_file, encoding="utf-8"),
            logging.StreamHandler(),
        ],
    )


log = logging.getLogger(__name__)

# ---------------------------------------------------------------------------
# Database helpers
# ---------------------------------------------------------------------------

def get_connection(cfg: dict) -> pyodbc.Connection:
    db = cfg["database"]
    if db.get("trusted_connection", "no").lower() == "yes":
        conn_str = (
            f"DRIVER={{{db['driver']}}};"
            f"SERVER={db['server']};"
            f"DATABASE={db['database']};"
            "Trusted_Connection=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={{{db['driver']}}};"
            f"SERVER={db['server']};"
            f"DATABASE={db['database']};"
            f"UID={db['username']};"
            f"PWD={db['password']};"
        )
    return pyodbc.connect(conn_str, autocommit=False)


def get_dw_connection(cfg: dict) -> pyodbc.Connection:
    """Open a connection to the BTC_DW target data warehouse.

    Uses cfg['dw_database'] so the DW can live on the same server (same
    Windows auth, same driver) without touching the staging connection.
    Cross-database three-part-name references (BTC_Staging.dbo.*) work
    because both databases are on the same SQL Server instance.
    """
    db = cfg["dw_database"]
    if db.get("trusted_connection", "no").lower() == "yes":
        conn_str = (
            f"DRIVER={{{db['driver']}}};"
            f"SERVER={db['server']};"
            f"DATABASE={db['database']};"
            "Trusted_Connection=yes;"
        )
    else:
        conn_str = (
            f"DRIVER={{{db['driver']}}};"
            f"SERVER={db['server']};"
            f"DATABASE={db['database']};"
            f"UID={db['username']};"
            f"PWD={db['password']};"
        )
    return pyodbc.connect(conn_str, autocommit=False)


def log_run_start(cur: pyodbc.Cursor, source: str) -> int:
    """Insert a pipeline log row and return its log_id."""
    cur.execute(
        "INSERT INTO dbo.STG_PIPELINE_LOG (source_name, status) "
        "OUTPUT INSERTED.log_id VALUES (?, 'running')",
        source,
    )
    return cur.fetchone()[0]


def log_run_finish(
    cur: pyodbc.Cursor,
    log_id: int,
    fetched: int,
    inserted: int,
    last_height: int = None,
    last_date: date = None,
    error: str = None,
):
    status = "error" if error else "ok"
    cur.execute(
        """UPDATE dbo.STG_PIPELINE_LOG
           SET status=?, records_fetched=?, records_inserted=?,
               last_block_height=?, last_date=?, error_msg=?
           WHERE log_id=?""",
        status, fetched, inserted, last_height, last_date, error, log_id,
    )


def _reject_dq(
    cur: pyodbc.Cursor,
    source_table: str,
    business_key: str,
    business_key_value: str | None,
    dq_rule: str,
    dq_pillar: str,
    reject_reason: str,
    raw_payload: str | None = None,
):
    """Write a single DQ failure row to ERR_QUALITY_REJECTS in BTC_DW.

    The cursor must belong to a connection opened against BTC_DW so that
    'dbo.ERR_QUALITY_REJECTS' resolves to the correct database.
    """
    cur.execute(
        """
        INSERT INTO dbo.ERR_QUALITY_REJECTS
            (source_table, business_key, business_key_value,
             dq_rule, dq_pillar, reject_reason, raw_payload)
        VALUES (?,?,?,?,?,?,?)
        """,
        source_table,
        business_key,
        str(business_key_value) if business_key_value is not None else None,
        dq_rule,
        dq_pillar,
        reject_reason,
        raw_payload,
    )


# ---------------------------------------------------------------------------
# HTTP helpers
# ---------------------------------------------------------------------------

def http_get(url: str, params: dict = None, max_retries: int = 3,
             backoff: int = 5, sleep_after: float = 0, ignore_404: bool = False) -> dict | list:
    """GET with retry + optional polite sleep after (for rate-limited APIs)."""
    import requests
    for attempt in range(1, max_retries + 1):
        try:
            r = requests.get(url, params=params, timeout=15)
            if ignore_404 and r.status_code == 404:
                return []
            r.raise_for_status()
            if sleep_after:
                time.sleep(sleep_after)
            return r.json()
        except requests.RequestException as exc:
            log.warning("HTTP error %s (attempt %d/%d): %s", url, attempt, max_retries, exc)
            if attempt < max_retries:
                time.sleep(backoff * attempt)
            else:
                raise


# ---------------------------------------------------------------------------
# Watermark helpers
# ---------------------------------------------------------------------------

def get_last_block_height(cur: pyodbc.Cursor) -> int | None:
    """Return the highest block height already in staging, or None."""
    cur.execute("SELECT MAX(height) FROM dbo.STG_BLOCKS WHERE is_active = 1")
    row = cur.fetchone()
    return row[0] if row and row[0] is not None else None


def get_last_market_date(cur: pyodbc.Cursor) -> date | None:
    """Return the latest price_date already in STG_MARKET_DAILY, or None."""
    cur.execute("SELECT MAX(price_date) FROM dbo.STG_MARKET_DAILY")
    row = cur.fetchone()
    return row[0] if row and row[0] is not None else None


def get_last_fear_greed_date(cur: pyodbc.Cursor) -> date | None:
    cur.execute("SELECT MAX(fg_date) FROM dbo.STG_FEAR_GREED_RAW")
    row = cur.fetchone()
    return row[0] if row and row[0] is not None else None


# ---------------------------------------------------------------------------
# Market cap helpers — circulating supply (zero-dependency computation)
# ---------------------------------------------------------------------------

_GENESIS_DATE = date(2009, 1, 3)
_BLOCKS_PER_HALVING = 210_000
_INITIAL_SUBSIDY_BTC = 50.0


def btc_circulating_supply(height: int) -> float:
    """
    Return total BTC issued up to and including block `height`.

    Uses the deterministic halving schedule:
      - Era 0 (blocks 0-209 999): 50 BTC/block
      - Era 1 (blocks 210 000-419 999): 25 BTC/block
      - Era N: 50 / 2**N BTC/block (floor in satoshis — ignored here for float
        precision; error is negligible for market-cap estimation).

    No network calls required.
    """
    total = 0.0
    subsidy = _INITIAL_SUBSIDY_BTC
    remaining = height + 1  # blocks 0 … height inclusive
    while remaining > 0 and subsidy >= 1e-10:
        blocks_this_era = min(remaining, _BLOCKS_PER_HALVING)
        total += blocks_this_era * subsidy
        remaining -= blocks_this_era
        subsidy /= 2.0
    return total


def _block_height_for_date(cur: pyodbc.Cursor, d: date) -> int:
    """
    Best-effort block height at end of date d.

    1. Query STG_BLOCKS for the max height whose block_timestamp falls on d.
    2. Fall back to 144 blocks/day heuristic from genesis if no staged data.
    """
    try:
        cur.execute(
            """
            SELECT MAX(height)
            FROM dbo.STG_BLOCKS
            WHERE CAST(DATEADD(SECOND, block_timestamp, '19700101') AS DATE) = ?
              AND is_active = 1
            """,
            d,
        )
        row = cur.fetchone()
        if row and row[0] is not None:
            return int(row[0])
    except Exception:
        pass  # swallow — fall through to approximation

    days_since_genesis = max(0, (d - _GENESIS_DATE).days)
    return int(days_since_genesis * 144)


def compute_market_cap(cur: pyodbc.Cursor, d: date, price_close: float) -> float | None:
    """Return market_cap_usd = circulating_supply_btc × price_close."""
    if price_close is None or price_close <= 0:
        return None
    height = _block_height_for_date(cur, d)
    supply = btc_circulating_supply(height)
    return round(supply * price_close, 2)


# ---------------------------------------------------------------------------
# BTC dominance helpers — CoinLore (today) + static monthly table (history)
# ---------------------------------------------------------------------------
#
# Strategy overview:
#   CoinLore GET /api/global/ returns today's live btc_d (free, no key).
#   All historical dates are resolved from the static monthly table below
#   using linear interpolation between anchor points.

# Static monthly BTC dominance table — full history 2009-2026.
# Sources: CMC/Messari archives (pre-2019); public dominance charts (2019-2025);
#          approximate estimates for 2025-09 onward (marked with ~).
# Monthly resolution; days in between are linearly interpolated.
#
# Format: list of (date, dominance_pct) sorted ascending.
_DOMINANCE_STATIC: list[tuple[date, float]] = [
    # Pre-altcoin era — Bitcoin was the only significant coin.
    (date(2009,  1,  3), 100.0),
    (date(2011,  6,  1), 100.0),
    # Early altcoin era — Namecoin, Litecoin appear but are tiny.
    (date(2012,  1,  1),  99.0),
    (date(2012,  6,  1),  98.0),
    (date(2013,  1,  1),  96.0),
    (date(2013,  4, 28),  94.3),  # ~earliest CMC tracking date
    (date(2013,  7,  1),  93.1),
    (date(2013, 10,  1),  92.4),
    (date(2013, 12,  1),  90.2),
    # 2014: Ripple/Litecoin grow, dominance falls
    (date(2014,  3,  1),  84.5),
    (date(2014,  6,  1),  78.5),
    (date(2014,  9,  1),  77.1),
    (date(2014, 12,  1),  77.4),
    # 2015: Ethereum announced; altcoin market quiet
    (date(2015,  3,  1),  76.3),
    (date(2015,  6,  1),  75.8),
    (date(2015,  9,  1),  77.2),
    (date(2015, 12,  1),  77.7),
    # 2016: Ethereum launches, ETC split — dominance stays high
    (date(2016,  3,  1),  79.4),
    (date(2016,  6,  1),  81.2),
    (date(2016,  9,  1),  83.1),
    (date(2016, 12,  1),  85.7),
    # 2017: ICO boom — dominance collapses mid-year
    (date(2017,  3,  1),  82.5),
    (date(2017,  5,  1),  65.3),
    (date(2017,  6,  1),  42.1),
    (date(2017,  7,  1),  45.8),
    (date(2017,  9,  1),  47.9),
    (date(2017, 10,  1),  55.3),
    (date(2017, 11,  1),  54.1),
    (date(2017, 12,  1),  37.6),
    # 2018: ICO collapse, BTC recovers relative dominance
    (date(2018,  2,  1),  36.7),
    (date(2018,  3,  1),  44.5),
    (date(2018,  5,  1),  36.8),
    (date(2018,  6,  1),  40.4),
    (date(2018,  8,  1),  50.2),
    (date(2018,  9,  1),  55.3),
    (date(2018, 11,  1),  54.1),
    (date(2018, 12,  1),  55.5),
    # 2019: BTC recovery, dominance climbs
    (date(2019,  1,  1),  53.5),
    (date(2019,  3,  1),  51.2),
    (date(2019,  6,  1),  61.5),  # BTC surges toward $14 k
    (date(2019,  9,  1),  68.3),
    (date(2019, 12,  1),  66.7),
    # 2020: DeFi summer pulls alts; COVID crash briefly lifts BTC share
    (date(2020,  3,  1),  63.4),
    (date(2020,  6,  1),  65.0),
    (date(2020,  9,  1),  57.6),  # DeFi / ETH rally
    (date(2020, 12,  1),  69.3),  # BTC bull run
    # 2021: Altcoin season, dual ATHs
    (date(2021,  1,  1),  71.8),
    (date(2021,  3,  1),  60.2),
    (date(2021,  5,  1),  40.2),  # BTC crash; alt season
    (date(2021,  7,  1),  46.8),
    (date(2021,  9,  1),  43.2),
    (date(2021, 11,  1),  42.6),  # altcoin ATH period
    (date(2021, 12,  1),  40.5),
    # 2022: Bear market; LUNA/FTX collapses
    (date(2022,  1,  1),  42.1),
    (date(2022,  3,  1),  43.5),
    (date(2022,  6,  1),  46.9),  # LUNA collapse — BTC relatively stronger
    (date(2022,  9,  1),  40.4),
    (date(2022, 12,  1),  38.7),  # FTX collapse
    # 2023: Gradual recovery
    (date(2023,  1,  1),  40.0),
    (date(2023,  3,  1),  46.3),
    (date(2023,  6,  1),  48.6),
    (date(2023,  9,  1),  49.4),
    (date(2023, 12,  1),  52.3),
    # 2024: ETF approvals; 4th halving
    (date(2024,  1,  1),  52.7),  # spot ETF approved
    (date(2024,  3,  1),  54.1),  # pre-halving rally
    (date(2024,  5,  1),  51.8),  # post-halving normalisation
    (date(2024,  7,  1),  54.3),
    (date(2024,  9,  1),  56.2),
    (date(2024, 11,  1),  60.6),  # post-US election surge
    (date(2024, 12,  1),  57.9),
    # 2025: Continued BTC dominance; spot ETH ETF activity
    (date(2025,  1,  1),  57.3),
    (date(2025,  3,  1),  59.6),
    (date(2025,  6,  1),  64.0),  # ~ estimated
    (date(2025,  9,  1),  63.0),  # ~ estimated
    (date(2025, 12,  1),  61.5),  # ~ estimated
    # 2026: ~ estimated; today's value is overridden by CoinLore live fetch
    (date(2026,  1,  1),  62.0),  # ~ estimated
    (date(2026,  4, 27),  62.0),  # ~ estimated (today — pipeline will use live API)
]

# Pre-build sorted key list for bisect lookups
_DOMINANCE_DATES = [row[0] for row in _DOMINANCE_STATIC]
_DOMINANCE_PCTS  = [row[1] for row in _DOMINANCE_STATIC]


def _static_dominance(d: date) -> float:
    """
    Return linearly-interpolated BTC dominance % for date d from the static
    table. Clamps to boundary values outside the covered range.
    """
    if d <= _DOMINANCE_DATES[0]:
        return _DOMINANCE_PCTS[0]
    if d >= _DOMINANCE_DATES[-1]:
        return _DOMINANCE_PCTS[-1]

    idx = bisect.bisect_right(_DOMINANCE_DATES, d)
    d0, p0 = _DOMINANCE_DATES[idx - 1], _DOMINANCE_PCTS[idx - 1]
    d1, p1 = _DOMINANCE_DATES[idx],     _DOMINANCE_PCTS[idx]

    span = (d1 - d0).days
    if span == 0:
        return p0
    frac = (d - d0).days / span
    return round(p0 + frac * (p1 - p0), 2)


# CoinLore /api/global/ supplies today's live btc_d.
# All historical dates are served by the static interpolation table.
_COINLORE_GLOBAL_URL   = "https://api.coinlore.net/api/global/"
_LIVE_DOMINANCE_CUTOFF = date(2019, 1, 1)   # oldest date eligible for live-cache lookup


def fetch_coinlore_dominance(retries: int = 3, backoff: int = 5) -> dict[date, float]:
    """
    Fetch today's BTC dominance from CoinLore GET /api/global/.

    CoinLore is free, requires no API key, and has no rate limit (1 req/s
    recommended).  It does not provide historical data, so only today's date
    is inserted into the returned cache; every other date falls through to
    the static interpolation table in get_dominance_pct().

    Returns {date.today(): btc_dominance_pct}, or {} on failure.
    """
    result: dict[date, float] = {}
    try:
        data = http_get(_COINLORE_GLOBAL_URL, max_retries=retries, backoff=backoff)
        record = data[0] if isinstance(data, list) and data else {}
        btc_d = record.get("btc_d")
        if btc_d is not None:
            pct = round(float(btc_d), 2)
            result[date.today()] = pct
            log.info("CoinLore global: btc_dominance=%.2f%%", pct)
        else:
            log.debug("CoinLore global: btc_d field missing — using static fallback.")
    except Exception as exc:
        log.debug("CoinLore global fetch failed (%s) — using static fallback.", exc)
    return result


def get_dominance_pct(
    d: date,
    live_cache: dict[date, float],
) -> float | None:
    """
    Resolve BTC dominance % for date d:
      1. Live cache (today's value from CoinLore, dates >= _LIVE_DOMINANCE_CUTOFF)
      2. Static monthly table with linear interpolation (all other dates / cache miss)
    """
    if d >= _LIVE_DOMINANCE_CUTOFF:
        val = live_cache.get(d)
        if val is not None:
            return val
    return _static_dominance(d)


# ---------------------------------------------------------------------------
# Source 1 — On-Chain: Blocks
# ---------------------------------------------------------------------------

def fetch_and_load_blocks(conn: pyodbc.Connection, cfg: dict):
    """
    Fetches new blocks from mempool.space /api/v1/blocks (15 per page,
    newest-first) and upserts them into STG_BLOCKS.
    Only fetches up to cfg['fetch']['blocks_per_run'] new blocks.
    """
    fetch_cfg = cfg["fetch"]
    retries = fetch_cfg["max_retries"]
    backoff = fetch_cfg["retry_backoff_sec"]
    max_blocks = fetch_cfg["blocks_per_run"]

    cur = conn.cursor()
    log_id = log_run_start(cur, "blocks")
    conn.commit()

    last_height = get_last_block_height(cur)
    log.info("Block watermark: %s", last_height if last_height else "none (first run)")

    # Get current chain tip
    tip = int(http_get("https://mempool.space/api/blocks/tip/height",
                       max_retries=retries, backoff=backoff))
    log.info("Chain tip: %d", tip)

    start_from = tip  # mempool paginates newest-first; we walk backwards
    fetched = 0
    inserted = 0
    last_loaded_height = None

    try:
        while fetched < max_blocks:
            page = http_get(
                f"https://mempool.space/api/v1/blocks/{start_from}",
                max_retries=retries, backoff=backoff,
            )
            if not page:
                break

            for block in page:
                height = block["height"]

                # Stop if we've caught up to what's already staged
                if last_height is not None and height <= last_height:
                    log.info("Reached watermark height %d — stopping block fetch.", last_height)
                    fetched = max_blocks  # triggers outer while exit
                    break

                if fetched >= max_blocks:
                    break

                extras = block.get("extras") or {}
                pool = extras.get("pool") or {}

                cur.execute(
                    """
                    IF NOT EXISTS (SELECT 1 FROM dbo.STG_BLOCKS WHERE block_hash = ?)
                    INSERT INTO dbo.STG_BLOCKS (
                        block_hash, height, block_version, block_timestamp, median_time,
                        tx_count, size_bytes, weight_units, difficulty, nonce, bits,
                        merkle_root, previous_block_hash, total_fees_sat,
                        avg_fee_rate, median_fee_rate, pool_name, pool_slug, miner_reward_sat
                    ) VALUES (?,?,CAST(? AS INT),CAST(? AS BIGINT),CAST(? AS BIGINT),
                              CAST(? AS INT),CAST(? AS INT),CAST(? AS INT),?,CAST(? AS BIGINT),CAST(? AS BIGINT),
                              ?,?,CAST(? AS BIGINT),
                              CAST(? AS INT),CAST(? AS INT),?,?,CAST(? AS BIGINT))
                    """,
                    block["id"],  # EXISTS check
                    block["id"],
                    height,
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
                if cur.rowcount > 0:
                    inserted += 1
                fetched += 1
                last_loaded_height = height

            # Next page starts from the lowest height in this page minus 1
            start_from = page[-1]["height"] - 1
            if start_from <= 0:
                break

        conn.commit()
        log.info("Blocks: fetched=%d, inserted=%d. New high-water: %s",
                 fetched, inserted, last_loaded_height)
        log_run_finish(cur, log_id, fetched, inserted, last_height=last_loaded_height)
        conn.commit()

    except Exception as exc:
        conn.rollback()
        log.error("Block load failed: %s", exc)
        log_run_finish(cur, log_id, fetched, inserted, error=str(exc))
        conn.commit()
        raise


# ---------------------------------------------------------------------------
# Source 1 — On-Chain: Transactions, Inputs, Outputs
# ---------------------------------------------------------------------------

def _derive_flags(tx: dict) -> tuple[bool, bool, bool]:
    """Return (is_coinbase, has_witness, is_rbf) derived from TX JSON."""
    vin = tx.get("vin", [])
    is_coinbase = bool(vin and vin[0].get("is_coinbase", False))
    has_witness = any(inp.get("witness") for inp in vin)
    is_rbf = any(
        inp.get("sequence", 0xFFFFFFFF) <= 0xFFFFFFFD
        for inp in vin
        if not inp.get("is_coinbase", False)
    )
    return is_coinbase, has_witness, is_rbf


def fetch_and_load_transactions(conn: pyodbc.Connection, cfg: dict):
    """
    For each block in STG_BLOCKS that has no transactions yet in
    STG_TRANSACTIONS, fetch TXs from mempool.space and load them
    along with their inputs and outputs.

    Respects cfg['fetch']['max_tx_per_block']. Set to 0 to skip.
    """
    fetch_cfg = cfg["fetch"]
    max_tx = fetch_cfg["max_tx_per_block"]
    if max_tx == 0:
        log.info("max_tx_per_block=0 — skipping transaction fetch.")
        return

    retries = fetch_cfg["max_retries"]
    backoff = fetch_cfg["retry_backoff_sec"]

    cur = conn.cursor()
    log_id = log_run_start(cur, "transactions")
    conn.commit()

    # Find blocks staged but not yet loaded into STG_TRANSACTIONS
    cur.execute(
        """
        SELECT b.block_hash, b.height
        FROM dbo.STG_BLOCKS b
        WHERE b.is_active = 1
          AND NOT EXISTS (
              SELECT 1 FROM dbo.STG_TRANSACTIONS t WHERE t.block_hash = b.block_hash
          )
        ORDER BY b.height DESC
        """
    )
    pending_blocks = cur.fetchall()
    log.info("Blocks pending TX load: %d", len(pending_blocks))

    total_fetched = 0
    total_inserted = 0
    last_height = None

    try:
        for block_hash, height in pending_blocks:
            log.info("Loading TXs for block %d (...%s)", height, block_hash[12:])
            loaded_tx = 0
            page = 0

            while loaded_tx < max_tx:
                txs = http_get(
                    f"https://mempool.space/api/block/{block_hash}/txs/{page * 25}",
                    max_retries=retries, backoff=backoff, ignore_404=True
                )
                if not txs:
                    break

                for tx in txs:
                    if loaded_tx >= max_tx:
                        break

                    is_coinbase, has_witness, is_rbf = _derive_flags(tx)

                    # --- STG_TRANSACTIONS ---
                    cur.execute(
                        """
                        IF NOT EXISTS (SELECT 1 FROM dbo.STG_TRANSACTIONS WHERE txid = ?)
                        INSERT INTO dbo.STG_TRANSACTIONS (
                            txid, block_hash, block_height, tx_version, locktime,
                            size_bytes, weight_units, fee_satoshis,
                            input_count, output_count, is_coinbase, has_witness, is_rbf
                        ) VALUES (?,?,CAST(? AS INT),CAST(? AS INT),CAST(? AS BIGINT),
                                  CAST(? AS INT),CAST(? AS INT),CAST(? AS BIGINT),
                                  CAST(? AS INT),CAST(? AS INT),?,?,?)
                        """,
                        tx["txid"],  # EXISTS check
                        tx["txid"], block_hash, height,
                        tx.get("version", 1),
                        tx.get("locktime", 0),
                        tx.get("size", 0),
                        tx.get("weight", 0),
                        0 if is_coinbase else (tx.get("fee") or 0),
                        len(tx.get("vin", [])),
                        len(tx.get("vout", [])),
                        1 if is_coinbase else 0,
                        1 if has_witness else 0,
                        1 if is_rbf else 0,
                    )

                    if cur.rowcount > 0:
                        total_inserted += 1

                        # --- STG_TX_INPUTS ---
                        for idx, inp in enumerate(tx.get("vin", [])):
                            prevout = inp.get("prevout") or {}
                            # Coinbase inputs use vout=0xFFFFFFFF (4294967295) as a
                            # sentinel — this overflows SQL Server INT. NULL it out;
                            # prev_vout is already NULL for coinbase by design.
                            raw_vout = inp.get("vout")
                            safe_vout = (
                                None
                                if (raw_vout is None
                                    or raw_vout >= 0xFFFFFFFF
                                    or inp.get("is_coinbase"))
                                else raw_vout
                            )
                            # sequence is BIGINT in the schema but pyodbc may infer INT
                            # for values that fit in 32 bits. Force to Python int so the
                            # driver sends it as the correct size.
                            seq = int(inp.get("sequence") or 0xFFFFFFFF)
                            cur.execute(
                                """
                                INSERT INTO dbo.STG_TX_INPUTS (
                                    txid, input_index, prev_txid, prev_vout, value_sat,
                                    script_type, address, has_witness, sequence_num
                                ) VALUES (?,CAST(? AS INT),?,CAST(? AS INT),CAST(? AS BIGINT),?,?,?,CAST(? AS BIGINT))
                                """,
                                tx["txid"], idx,
                                inp.get("txid"),
                                safe_vout,
                                prevout.get("value"),
                                prevout.get("scriptpubkey_type"),
                                prevout.get("scriptpubkey_address"),
                                1 if inp.get("witness") else 0,
                                seq,
                            )

                        # --- STG_TX_OUTPUTS ---
                        for idx, out in enumerate(tx.get("vout", [])):
                            cur.execute(
                                """
                                INSERT INTO dbo.STG_TX_OUTPUTS (
                                    txid, output_index, value_sat, script_type, address
                                ) VALUES (?,CAST(? AS INT),CAST(? AS BIGINT),?,?)
                                """,
                                tx["txid"], idx,
                                out.get("value", 0),
                                out.get("scriptpubkey_type"),
                                out.get("scriptpubkey_address"),
                            )

                    loaded_tx += 1
                    total_fetched += 1

                page += 1
                if len(txs) < 25:
                    break  # last page

            last_height = height
            conn.commit()
            log.info("  Block %d: %d TXs loaded.", height, loaded_tx)

        # Post-load: fill primary_script_type via V_TX_PRIMARY_SCRIPT
        log.info("Updating primary_script_type via majority vote...")
        cur.execute(
            """
            UPDATE t
            SET t.primary_script_type = v.primary_script_type
            FROM dbo.STG_TRANSACTIONS t
            JOIN dbo.V_TX_PRIMARY_SCRIPT v ON v.txid = t.txid
            WHERE t.primary_script_type IS NULL
            """
        )
        conn.commit()

        log.info("Transactions: fetched=%d, inserted=%d", total_fetched, total_inserted)
        log_run_finish(cur, log_id, total_fetched, total_inserted, last_height=last_height)
        conn.commit()

    except Exception as exc:
        conn.rollback()
        log.error("Transaction load failed: %s", exc)
        log_run_finish(cur, log_id, total_fetched, total_inserted, error=str(exc))
        conn.commit()
        raise


# ---------------------------------------------------------------------------
# Source 2 — Market: Yahoo Finance OHLCV (via yfinance)
#            + computed market_cap_usd
# ---------------------------------------------------------------------------

def fetch_and_load_market(conn: pyodbc.Connection, cfg: dict):
    """
    Fetches daily BTC-USD OHLCV from Yahoo Finance using yfinance.
    No API key required. Covers the full available history via period="max".

    Fields populated:
      price_open, price_high, price_low, price_close, volume_24h_usd
      market_cap_usd  ← computed: btc_circulating_supply(height) × price_close
                         (height resolved from STG_BLOCKS, or 144 blk/day approx)

    Fields NOT populated here (handled by fetch_and_load_dominance):
      btc_dominance_pct

    Only processes dates strictly after the current watermark.
    """
    cur = conn.cursor()
    log_id = log_run_start(cur, "market")
    conn.commit()

    last_date = get_last_market_date(cur)
    log.info(
        "Market watermark: %s",
        last_date if last_date else "none (first run — fetching full history)",
    )

    fetched = 0
    inserted = 0

    try:
        ticker = yf.Ticker("BTC-USD")

        if last_date is None:
            log.info("Fetching full BTC-USD history from Yahoo Finance...")
            hist = ticker.history(period="max", interval="1d", auto_adjust=True)
        else:
            start_str = (last_date + timedelta(days=1)).strftime("%Y-%m-%d")
            log.info("Fetching BTC-USD from Yahoo Finance starting %s...", start_str)
            hist = ticker.history(start=start_str, interval="1d", auto_adjust=True)

        if hist.empty:
            log.info("No new market data returned from Yahoo Finance.")
            log_run_finish(cur, log_id, 0, 0, last_date=last_date)
            conn.commit()
            return

        # Normalise DatetimeIndex to UTC so .date() is comparable to SQL DATE
        if hist.index.tzinfo is None:
            hist.index = hist.index.tz_localize("UTC")
        else:
            hist.index = hist.index.tz_convert("UTC")

        today = date.today()

        def _safe(val) -> float | None:
            """Return float or None; treat 0 / NaN as None."""
            try:
                f = float(val)
                return f if f > 0 else None
            except (TypeError, ValueError):
                return None

        for ts, row in hist.iterrows():
            d = ts.date()

            # Skip watermark-overlap rows
            if last_date and d <= last_date:
                continue

            # Skip today's potentially-incomplete candle on this run only;
            # let it through once it's actually "today" no longer (i.e. d <= today)
            if d > today:
                continue

            price_open  = _safe(row.get("Open"))
            price_high  = _safe(row.get("High"))
            price_low   = _safe(row.get("Low"))
            price_close = _safe(row.get("Close"))
            vol         = _safe(row.get("Volume"))

            # Compute market cap from circulating supply × price_close.
            # Uses STG_BLOCKS for the height on this date when available,
            # otherwise falls back to 144-blocks/day approximation.
            mkt_cap = compute_market_cap(cur, d, price_close)

            cur.execute(
                """
                IF NOT EXISTS (SELECT 1 FROM dbo.STG_MARKET_DAILY WHERE price_date = ?)
                    INSERT INTO dbo.STG_MARKET_DAILY (
                        price_date, price_open, price_high, price_low, price_close,
                        volume_24h_usd, market_cap_usd
                    ) VALUES (?,?,?,?,?,?,?)
                ELSE
                    UPDATE dbo.STG_MARKET_DAILY
                    SET price_open      = ?,
                        price_high      = ?,
                        price_low       = ?,
                        price_close     = ?,
                        volume_24h_usd  = ?,
                        market_cap_usd  = ?,
                        load_ts         = SYSUTCDATETIME()
                    WHERE price_date = ?
                """,
                # EXISTS check
                d,
                # INSERT positional args
                d, price_open, price_high, price_low, price_close, vol, mkt_cap,
                # UPDATE positional args
                price_open, price_high, price_low, price_close, vol, mkt_cap, d,
            )
            if cur.rowcount > 0:
                inserted += 1
            fetched += 1

        # --- Compute rolling stats (7-day MA) ---
        log.info("Computing 7d MA in-database...")
        cur.execute(
            """
            WITH ordered AS (
                SELECT price_date, price_close,
                       AVG(price_close) OVER (
                           ORDER BY price_date
                           ROWS BETWEEN 6 PRECEDING AND CURRENT ROW
                       ) AS ma7
                FROM dbo.STG_MARKET_DAILY
                WHERE price_close IS NOT NULL
            )
            UPDATE dbo.STG_MARKET_DAILY
            SET price_ma_7d = o.ma7
            FROM dbo.STG_MARKET_DAILY m
            JOIN ordered o ON o.price_date = m.price_date
            WHERE m.price_ma_7d IS NULL
               OR m.price_date >= DATEADD(day, -8, GETDATE())
            """
        )
        conn.commit()

        # --- Compute 14-day realised volatility (Design §4.1 DIM_MARKET) ---
        # Formula : stddev(daily log-returns over 14-day window) × √365
        # SQL Server STDEV() does not support ROWS BETWEEN window frames so
        # this is computed in Python and pushed back row-by-row.
        log.info("Computing 14-day realised volatility in Python...")
        cur.execute(
            """
            SELECT price_date, price_close
            FROM   dbo.STG_MARKET_DAILY
            WHERE  price_close IS NOT NULL
            ORDER  BY price_date
            """
        )
        price_rows = cur.fetchall()
        if price_rows:
            dates_v  = [r[0] for r in price_rows]
            closes_v = [float(r[1]) for r in price_rows]

            # Build log-return series (index 0 has no prior close → None)
            log_rets: list = [None]
            for i in range(1, len(closes_v)):
                c0, c1 = closes_v[i - 1], closes_v[i]
                log_rets.append(math.log(c1 / c0) if c0 > 0 and c1 > 0 else None)

            _SQRT365 = math.sqrt(365.0)
            updated_vol = 0
            for i, d in enumerate(dates_v):
                window = [
                    lr for lr in log_rets[max(0, i - 13): i + 1]
                    if lr is not None
                ]
                if len(window) < 2:
                    continue
                mean_lr  = sum(window) / len(window)
                variance = sum((x - mean_lr) ** 2 for x in window) / (len(window) - 1)
                vol      = math.sqrt(variance) * _SQRT365
                cur.execute(
                    """
                    UPDATE dbo.STG_MARKET_DAILY
                    SET    volatility_14d = ?
                    WHERE  price_date = ?
                      AND  (volatility_14d IS NULL
                           OR price_date >= DATEADD(day, -15, GETDATE()))
                    """,
                    round(vol, 6), d,
                )
                if cur.rowcount > 0:
                    updated_vol += 1
            conn.commit()
            log.info("volatility_14d: %d rows updated.", updated_vol)

        log.info("Market: fetched=%d, inserted/updated=%d", fetched, inserted)
        log_run_finish(cur, log_id, fetched, inserted, last_date=today)
        conn.commit()

    except Exception as exc:
        conn.rollback()
        log.error("Market load failed: %s", exc)
        log_run_finish(cur, log_id, fetched, inserted, error=str(exc))
        conn.commit()
        raise


# ---------------------------------------------------------------------------
# Source 2 — Market: BTC dominance
#            CoinLore (today) + static monthly table (all historical dates)
# ---------------------------------------------------------------------------

def fetch_and_load_dominance(conn: pyodbc.Connection, cfg: dict):
    """
    Populates btc_dominance_pct in STG_MARKET_DAILY for every row that
    currently has a NULL in that column.

    Strategy:
      today          → CoinLore /api/global/ (free, no key, real-time btc_d)
      all other dates → embedded static monthly table with linear interpolation
    """
    fetch_cfg = cfg["fetch"]
    retries   = fetch_cfg["max_retries"]
    backoff   = fetch_cfg["retry_backoff_sec"]

    cur = conn.cursor()
    log_id = log_run_start(cur, "dominance")
    conn.commit()

    # Find all rows that still need dominance filled
    cur.execute(
        """
        SELECT price_date
        FROM dbo.STG_MARKET_DAILY
        WHERE btc_dominance_pct IS NULL
        ORDER BY price_date
        """
    )
    null_rows = [r[0] for r in cur.fetchall()]

    if not null_rows:
        log.info("btc_dominance_pct: no NULL rows — nothing to do.")
        log_run_finish(cur, log_id, 0, 0)
        conn.commit()
        return

    log.info("btc_dominance_pct: %d rows need filling (oldest=%s, newest=%s).",
             len(null_rows), null_rows[0], null_rows[-1])

    # Fetch today's live dominance from CoinLore (single request)
    log.info("Fetching live BTC dominance from CoinLore...")
    live_cache = fetch_coinlore_dominance(retries=retries, backoff=backoff)
    log.info("CoinLore returned %d record(s).", len(live_cache))

    # --- Fill each NULL row ---
    updated = 0
    for d in null_rows:
        pct = get_dominance_pct(d, live_cache)
        if pct is None:
            continue
        cur.execute(
            """
            UPDATE dbo.STG_MARKET_DAILY
            SET btc_dominance_pct = ?, load_ts = SYSUTCDATETIME()
            WHERE price_date = ? AND btc_dominance_pct IS NULL
            """,
            pct, d,
        )
        if cur.rowcount > 0:
            updated += 1

    conn.commit()
    log.info("btc_dominance_pct: updated %d / %d rows.", updated, len(null_rows))
    log_run_finish(cur, log_id, len(null_rows), updated)
    conn.commit()


# ---------------------------------------------------------------------------
# Source 2 — Market: Alternative.me Fear & Greed
# ---------------------------------------------------------------------------

def fetch_and_load_fear_greed(conn: pyodbc.Connection, cfg: dict):
    """
    Fetches the full Fear & Greed history from Alternative.me (free, no auth).
    Only inserts dates newer than the current watermark.
    After loading into STG_FEAR_GREED_RAW, merges into STG_MARKET_DAILY.
    """
    fetch_cfg = cfg["fetch"]
    retries = fetch_cfg["max_retries"]
    backoff = fetch_cfg["retry_backoff_sec"]

    cur = conn.cursor()
    log_id = log_run_start(cur, "fear_greed")
    conn.commit()

    last_date = get_last_fear_greed_date(cur)
    log.info("Fear & Greed watermark: %s", last_date if last_date else "none")

    fetched = 0
    inserted = 0

    try:
        data = http_get(
            "https://api.alternative.me/fng/",
            params={"limit": 0},  # 0 = full history
            max_retries=retries, backoff=backoff,
        )
        records = data.get("data", [])
        log.info("Alternative.me returned %d records.", len(records))

        for rec in records:
            ts = int(rec["timestamp"])
            d = datetime.fromtimestamp(ts, tz=timezone.utc).date()

            if last_date and d <= last_date:
                continue

            fetched += 1
            cur.execute(
                """
                IF NOT EXISTS (SELECT 1 FROM dbo.STG_FEAR_GREED_RAW WHERE fg_date = ?)
                INSERT INTO dbo.STG_FEAR_GREED_RAW (fg_date, fg_score, fg_label, fg_timestamp)
                VALUES (?,?,?,?)
                """,
                d,
                d,
                int(rec["value"]),
                rec["value_classification"],
                ts,
            )
            if cur.rowcount > 0:
                inserted += 1

        conn.commit()

        # Merge into STG_MARKET_DAILY
        log.info("Merging Fear & Greed into STG_MARKET_DAILY...")
        cur.execute(
            """
            UPDATE m
            SET m.fear_greed_score = fg.fg_score,
                m.fear_greed_label = fg.fg_label,
                m.load_ts          = SYSUTCDATETIME()
            FROM dbo.STG_MARKET_DAILY m
            JOIN dbo.STG_FEAR_GREED_RAW fg ON fg.fg_date = m.price_date
            WHERE m.fear_greed_score IS NULL
            """
        )
        conn.commit()

        log.info("Fear & Greed: fetched=%d, inserted=%d", fetched, inserted)
        log_run_finish(cur, log_id, fetched, inserted,
                       last_date=date.today())
        conn.commit()

    except Exception as exc:
        conn.rollback()
        log.error("Fear & Greed load failed: %s", exc)
        log_run_finish(cur, log_id, fetched, inserted, error=str(exc))
        conn.commit()
        raise


# ---------------------------------------------------------------------------
# Step 6 — DW Load  (Staging → BTC_DW star schema)
# ---------------------------------------------------------------------------
# Implements the ETL flow defined in BTC_DW_Dimensional_Design_P2.md §7.
# Sub-steps run in dependency order:
#   6a  extend_dim_date      — add new calendar days to DIM_DATE (SCD Type 0)
#   6b  load_dim_block       — new blocks from STG_BLOCKS        (SCD Type 0)
#   6c  load_dim_tx_type     — distinct combos from STG_TX       (SCD Type 1)
#   6d  load_dim_market      — daily snapshots from STG_MARKET   (SCD Type 1)
#   6e  load_fact_transaction — full fact load with DQ gates,
#                                surrogate-key lookups, and pre-computed cols
# ---------------------------------------------------------------------------

_CONFORMED_SCRIPT_TYPES = frozenset(
    {"P2PKH", "P2SH", "P2WPKH", "P2WSH", "P2TR", "OTHER"}
)


def extend_dim_date(dw_conn: pyodbc.Connection):
    """Idempotently insert DIM_DATE rows for every date that staged blocks
    need, plus today.

    Strategy — data-driven, not range-based:
      1. Collect the distinct calendar dates derived from STG_BLOCKS.median_time
         (the same conversion used by FACT_TRANSACTION's DIM_DATE JOIN) plus
         today's date, both of which must exist in DIM_DATE for the fact load
         to succeed.
      2. Filter to dates not already in DIM_DATE.
      3. Insert only those missing rows.

    This means DIM_DATE starts empty and grows exactly as fast as real block
    data arrives — no pre-seeding, no blind calendar loops from genesis.

    Halving era boundaries used (confirmed block-header dates):
      Era 1 : ≤ 2012-11-28 | Era 2 : ≤ 2016-07-09 | Era 3 : ≤ 2020-05-11
      Era 4 : ≤ 2024-04-19 | Era 5 : 2024-04-20 onwards
    """
    cur = dw_conn.cursor()
    cur.execute(
        """
        -- Collect all distinct dates needed by staged blocks (median_time → date)
        -- plus today, then insert only those missing from DIM_DATE.
        INSERT INTO dbo.DIM_DATE (
            date_key, [date], [day], [month], quarter, [year],
            day_of_week, is_weekend, halving_era,
            dw_load_timestamp, dw_source_system
        )
        SELECT
            YEAR(d) * 10000 + MONTH(d) * 100 + DAY(d) AS date_key,
            d,
            DAY(d),
            MONTH(d),
            DATEPART(QUARTER, d),
            YEAR(d),
            DATEPART(WEEKDAY, d),
            CASE WHEN DATEPART(WEEKDAY, d) IN (1, 7) THEN 1 ELSE 0 END,
            CASE
                WHEN d <= '2012-11-28' THEN 'Era 1'
                WHEN d <= '2016-07-09' THEN 'Era 2'
                WHEN d <= '2020-05-11' THEN 'Era 3'
                WHEN d <= '2024-04-19' THEN 'Era 4'
                ELSE                        'Era 5'
            END,
            GETDATE(),
            'System_Calendar'
        FROM (
            -- Dates required by staged blocks
            SELECT DISTINCT
                CAST(
                    DATEADD(SECOND,
                        b.median_time % 86400,
                        DATEADD(DAY, b.median_time / 86400, '1970-01-01'))
                AS DATE) AS d
            FROM BTC_Staging.dbo.STG_BLOCKS b
            WHERE b.is_active = 1

            UNION

            -- Always ensure today is present (required by DQ freshness checks
            -- and the NVT / market steps that reference the current run date)
            SELECT CAST(GETDATE() AS DATE)
        ) AS needed_dates
        WHERE NOT EXISTS (
            SELECT 1
            FROM   dbo.DIM_DATE dd
            WHERE  dd.date_key =
                       YEAR(needed_dates.d) * 10000
                     + MONTH(needed_dates.d) * 100
                     + DAY(needed_dates.d)
        )
        """
    )
    inserted = cur.rowcount
    dw_conn.commit()
    cur.execute("SELECT COUNT(*), MIN([date]), MAX([date]) FROM dbo.DIM_DATE")
    total, earliest, latest = cur.fetchone()
    log.info(
        "DIM_DATE: %d rows total (earliest=%s, watermark=%s), %d new rows inserted.",
        total, earliest, latest, inserted,
    )
    if total == 0:
        log.warning(
            "DIM_DATE is empty after extend — no staged blocks found. "
            "FACT_TRANSACTION load will produce 0 rows."
        )


def load_dim_block(dw_conn: pyodbc.Connection) -> int:
    """SCD Type 0: insert new blocks from BTC_Staging into DIM_BLOCK.

    Never updates existing rows — Proof-of-Work cryptographically seals
    every block attribute; a detected delta signals data corruption.

    Difficulty tier thresholds (historical Bitcoin difficulty scale):
      Low     : difficulty <  1 T  (10^12)   pre-2013
      Medium  : difficulty < 10 T  (10^13)   2013–2017
      High    : difficulty < 100 T (10^14)   2017–2021
      Extreme : difficulty >= 100 T           2021 – present
    """
    cur = dw_conn.cursor()
    cur.execute(
        """
        INSERT INTO dbo.DIM_BLOCK (
            block_height, block_hash, block_timestamp,
            block_size_bytes, block_weight_units, block_difficulty,
            difficulty_tier, pool_name, pool_slug, dw_load_timestamp, dw_source_system
        )
        SELECT
            b.height,
            b.block_hash,
            -- Unix epoch BIGINT → DATETIME via day+second split (avoids INT overflow)
            DATEADD(SECOND,
                    b.block_timestamp % 86400,
                    DATEADD(DAY, b.block_timestamp / 86400, '1970-01-01 00:00:00')),
            b.size_bytes,
            b.weight_units,
            b.difficulty,
            CASE
                WHEN b.difficulty <  1e12 THEN 'Low'
                WHEN b.difficulty <  1e13 THEN 'Medium'
                WHEN b.difficulty <  1e14 THEN 'High'
                ELSE                           'Extreme'
            END,
            b.pool_name,
            b.pool_slug,
            GETDATE(),
            'RPC_Bitcoind_Node'
        FROM BTC_Staging.dbo.STG_BLOCKS b
        WHERE b.is_active = 1
          AND NOT EXISTS (
                SELECT 1 FROM dbo.DIM_BLOCK d WHERE d.block_height = b.height
          )
        """
    )
    inserted = cur.rowcount
    dw_conn.commit()
    log.info("DIM_BLOCK: %d new blocks inserted (SCD Type 0).", inserted)
    return inserted


def load_dim_tx_type(dw_conn: pyodbc.Connection) -> int:
    """SCD Type 1: upsert distinct (script_type, 4-flag) combinations.

    Reads all distinct combinations from BTC_Staging.dbo.STG_TRANSACTIONS
    and inserts any that are missing from DIM_TX_TYPE.  A changed
    script_type_desc would produce a new unique-key combination, so no
    explicit UPDATE pass is needed for the type label itself.

    DQ Consistency gate (Design §6):
      Non-conformed script types (e.g. 'UNKNOWN', 'op_return') are mapped
      to 'OTHER' and logged in ERR_QUALITY_REJECTS; the row is still loaded.
    """
    cur = dw_conn.cursor()

    cur.execute(
        """
        SELECT
            UPPER(LTRIM(RTRIM(ISNULL(primary_script_type, 'OTHER')))) AS script_type_desc,
            CAST(has_witness AS TINYINT)                               AS segwit_flag,
            CAST(is_coinbase  AS TINYINT)                              AS coinbase_flag,
            CAST(is_rbf       AS TINYINT)                              AS rbf_flag,
            CAST(CASE WHEN locktime > 0 THEN 1 ELSE 0 END AS TINYINT)  AS locktime_flag
        FROM BTC_Staging.dbo.STG_TRANSACTIONS
        GROUP BY
            UPPER(LTRIM(RTRIM(ISNULL(primary_script_type, 'OTHER')))),
            CAST(has_witness AS TINYINT),
            CAST(is_coinbase  AS TINYINT),
            CAST(is_rbf       AS TINYINT),
            CAST(CASE WHEN locktime > 0 THEN 1 ELSE 0 END AS TINYINT)
        """
    )
    combos = cur.fetchall()

    inserted = 0
    for raw_script, segwit_f, coinbase_f, rbf_f, locktime_f in combos:
        # DQ Consistency: map non-conformed types to 'OTHER'
        if raw_script not in _CONFORMED_SCRIPT_TYPES:
            log.debug(
                "DQ Consistency: script_type '%s' not in conformed list — mapping to 'OTHER'.",
                raw_script,
            )
            _reject_dq(
                cur,
                source_table="STG_TRANSACTIONS",
                business_key="primary_script_type",
                business_key_value=raw_script,
                dq_rule=(
                    "script_type_desc must match conformed list: "
                    "P2PKH|P2SH|P2WPKH|P2WSH|P2TR|OTHER"
                ),
                dq_pillar="Consistency",
                reject_reason=f"'{raw_script}' mapped to 'OTHER'; row still loaded.",
            )
            script_desc = "OTHER"
        else:
            script_desc = raw_script

        # SCD Type 1 upsert — INSERT only if combination is genuinely new
        cur.execute(
            """
            IF NOT EXISTS (
                SELECT 1 FROM dbo.DIM_TX_TYPE
                WHERE  script_type_desc = ? AND segwit_flag   = ?
                  AND  coinbase_flag    = ? AND rbf_flag      = ?
                  AND  locktime_flag    = ?
            )
                INSERT INTO dbo.DIM_TX_TYPE (
                    script_type_desc, segwit_flag, coinbase_flag,
                    rbf_flag, locktime_flag,
                    dw_load_timestamp, dw_source_system
                )
                VALUES (?,?,?,?,?, GETDATE(), 'STG_TRANSACTIONS')
            """,
            script_desc, segwit_f, coinbase_f, rbf_f, locktime_f,
            script_desc, segwit_f, coinbase_f, rbf_f, locktime_f,
        )
        if cur.rowcount > 0:
            inserted += 1

    dw_conn.commit()
    log.info("DIM_TX_TYPE: %d new type combinations inserted (SCD Type 1).", inserted)
    return inserted


def load_dim_market(dw_conn: pyodbc.Connection) -> tuple[int, int]:
    """SCD Type 1: upsert daily market snapshots from STG_MARKET_DAILY.

    DQ Freshness gate (Design §6):
      If the most recent staging date is older than yesterday, log an
      operations alert and write to ERR_QUALITY_REJECTS, but continue
      loading (stale data is better than no data).

    SCD Type 1 logic:
      INSERT rows for dates not yet in DIM_MARKET.
      UPDATE existing rows when staging is fresher (load_ts comparison)
      — the final end-of-day value overwrites any earlier partial load.
    """
    cur = dw_conn.cursor()

    # --- DQ Freshness gate ---
    cur.execute("SELECT MAX(price_date) FROM BTC_Staging.dbo.STG_MARKET_DAILY")
    latest_mkt = cur.fetchone()[0]
    if latest_mkt is not None:
        yesterday = date.today() - timedelta(days=1)
        if latest_mkt < yesterday:
            msg = (
                f"Staging market latest date {latest_mkt} is older than "
                f"yesterday ({yesterday}). Market data may be stale."
            )
            log.warning("DQ Freshness: %s", msg)
            _reject_dq(
                cur,
                source_table="STG_MARKET_DAILY",
                business_key="price_date",
                business_key_value=str(latest_mkt),
                dq_rule=(
                    "Market snapshot date must represent a snapshot within "
                    "the last 24 hours relative to load"
                ),
                dq_pillar="Freshness",
                reject_reason=msg,
            )
            dw_conn.commit()

    # --- INSERT new dates not yet in DIM_MARKET ---
    # Only insert rows for dates that already exist in DIM_DATE (i.e. dates
    # that have staged blocks).  This keeps DIM_MARKET strictly data-driven:
    # no market row is created unless there are actual on-chain transactions
    # for that day.  date_key is computed inline so it is never NULL.
    cur.execute(
        """
        INSERT INTO dbo.DIM_MARKET (
            snapshot_date, date_key,
            fear_greed_score, fear_greed_label,
            btc_dominance_percent, market_cap_usd, volatility_index,
            dw_load_timestamp, dw_source_system
        )
        SELECT
            m.price_date,
            YEAR(m.price_date) * 10000
                + MONTH(m.price_date) * 100
                + DAY(m.price_date),
            m.fear_greed_score,
            m.fear_greed_label,
            m.btc_dominance_pct,
            m.market_cap_usd,
            m.volatility_14d,
            GETDATE(),
            'API_Yahoo_FearGreed'
        FROM BTC_Staging.dbo.STG_MARKET_DAILY m
        -- Only create a market row when there are staged blocks on that date,
        -- meaning DIM_DATE already has the matching date_key.
        WHERE EXISTS (
            SELECT 1 FROM dbo.DIM_DATE dd
            WHERE dd.date_key =
                YEAR(m.price_date) * 10000
                + MONTH(m.price_date) * 100
                + DAY(m.price_date)
        )
        AND NOT EXISTS (
            SELECT 1 FROM dbo.DIM_MARKET d WHERE d.snapshot_date = m.price_date
        )
        """
    )
    inserted = cur.rowcount

    # --- UPDATE existing rows where staging is fresher (SCD Type 1 overwrite) ---
    cur.execute(
        """
        UPDATE d
        SET    d.fear_greed_score      = m.fear_greed_score,
               d.fear_greed_label      = m.fear_greed_label,
               d.btc_dominance_percent = m.btc_dominance_pct,
               d.market_cap_usd        = m.market_cap_usd,
               d.volatility_index      = m.volatility_14d,
               d.date_key              = YEAR(m.price_date) * 10000
                                           + MONTH(m.price_date) * 100
                                           + DAY(m.price_date),
               d.dw_load_timestamp     = GETDATE()
        FROM   dbo.DIM_MARKET d
        JOIN   BTC_Staging.dbo.STG_MARKET_DAILY m ON m.price_date = d.snapshot_date
        WHERE  m.load_ts > d.dw_load_timestamp
        """
    )
    updated = cur.rowcount

    dw_conn.commit()
    log.info(
        "DIM_MARKET: %d inserted, %d updated (SCD Type 1).", inserted, updated
    )
    return inserted, updated


def load_fact_transaction(dw_conn: pyodbc.Connection) -> int:
    """Load new transactions into FACT_TRANSACTION with all DQ gates applied.

    DQ Gates (Design §6, in execution order):
      1. Uniqueness   — txid must be 64-char hex and not already in FACT.
      2. Completeness — output_value_sat must be >= 0 and not NULL.
      3. Completeness — block_hash must resolve to a loaded block_key in DIM_BLOCK;
                         failure rejects every transaction in that block batch.
      (4. Consistency — handled upstream in load_dim_tx_type.)
      (5. Freshness   — handled upstream in load_dim_market.)

    Rejected rows are written to ERR_QUALITY_REJECTS before the main INSERT
    so the error log is populated even if the INSERT itself is rolled back.

    Surrogate key lookups (all performed via SQL JOIN):
      date_key    ← DIM_DATE.date_key  via block median_time → YYYYMMDD
      block_key   ← DIM_BLOCK.block_key via block_height
      tx_type_key ← DIM_TX_TYPE.tx_type_key via 5-flag combination
      market_key  ← DIM_MARKET.market_key via snapshot_date  (LEFT JOIN)

    Pre-computed columns stored in FACT (Design §4.2):
      tx_vsize_bytes  = weight_units / 4.0
      fee_burden_pct  = fee_sat * 100 / NULLIF(output_sat, 0)
      input_value_btc = input_sat / 1e8
      output_value_btc= output_sat / 1e8
      fee_btc         = fee_sat / 1e8
      io_value_ratio  = input_sat / NULLIF(output_sat, 0)
    """
    cur = dw_conn.cursor()

    # ------------------------------------------------------------------
    # DQ Gate 1 — Uniqueness: 64-char hex txid + not already in FACT
    # ------------------------------------------------------------------
    cur.execute(
        """
        INSERT INTO dbo.ERR_QUALITY_REJECTS
            (source_table, business_key, business_key_value,
             dq_rule, dq_pillar, reject_reason)
        SELECT
            'STG_TRANSACTIONS',
            'txid',
            t.txid,
            'txid must be unique and follow 64-char hex format',
            'Uniqueness',
            CASE
                WHEN LEN(t.txid) <> 64
                    THEN 'Invalid length: ' + CAST(LEN(t.txid) AS VARCHAR)
                WHEN t.txid LIKE '%[^0-9a-fA-F]%'
                    THEN 'Non-hex characters detected in txid'
                ELSE 'txid already present in FACT_TRANSACTION (duplicate load attempt)'
            END
        FROM BTC_Staging.dbo.STG_TRANSACTIONS t
        WHERE  LEN(t.txid) <> 64
            OR t.txid LIKE '%[^0-9a-fA-F]%'
            OR EXISTS (SELECT 1 FROM dbo.FACT_TRANSACTION f WHERE f.txid = t.txid)
        """
    )
    dq1 = cur.rowcount

    # ------------------------------------------------------------------
    # DQ Gate 2 — Completeness: output_value_sat >= 0, not NULL
    # ------------------------------------------------------------------
    cur.execute(
        """
        INSERT INTO dbo.ERR_QUALITY_REJECTS
            (source_table, business_key, business_key_value,
             dq_rule, dq_pillar, reject_reason)
        SELECT
            'STG_TRANSACTIONS',
            'output_value_sat',
            t.txid,
            'output_value_sat cannot be NULL or negative (must be >= 0)',
            'Completeness',
            CASE
                WHEN ov.output_value_sat IS NULL
                    THEN 'output_value_sat is NULL — no output records found in STG_TX_OUTPUTS'
                ELSE 'output_value_sat is negative: ' + CAST(ov.output_value_sat AS VARCHAR)
            END
        FROM BTC_Staging.dbo.STG_TRANSACTIONS t
        LEFT JOIN BTC_Staging.dbo.V_TX_OUTPUT_TOTALS ov ON ov.txid = t.txid
        WHERE (ov.output_value_sat IS NULL OR ov.output_value_sat < 0)
          AND LEN(t.txid) = 64
          AND t.txid NOT LIKE '%[^0-9a-fA-F]%'
          AND NOT EXISTS (SELECT 1 FROM dbo.FACT_TRANSACTION f WHERE f.txid = t.txid)
        """
    )
    dq2 = cur.rowcount

    # ------------------------------------------------------------------
    # DQ Gate 3 — Completeness: block_hash must resolve to DIM_BLOCK
    # (entire block batch rejected if block is missing from the dimension)
    # ------------------------------------------------------------------
    cur.execute(
        """
        INSERT INTO dbo.ERR_QUALITY_REJECTS
            (source_table, business_key, business_key_value,
             dq_rule, dq_pillar, reject_reason)
        SELECT DISTINCT
            'STG_TRANSACTIONS',
            'block_height',
            CAST(t.block_height AS VARCHAR),
            'block_height must resolve to a loaded block in DIM_BLOCK',
            'Completeness',
            'block_height ' + CAST(t.block_height AS VARCHAR)
                + ' not found in DIM_BLOCK — entire block batch rejected'
        FROM BTC_Staging.dbo.STG_TRANSACTIONS t
        WHERE LEN(t.txid) = 64
          AND t.txid NOT LIKE '%[^0-9a-fA-F]%'
          AND NOT EXISTS (SELECT 1 FROM dbo.FACT_TRANSACTION f WHERE f.txid = t.txid)
          AND NOT EXISTS (SELECT 1 FROM dbo.DIM_BLOCK        b WHERE b.block_height = t.block_height)
        """
    )
    dq3 = cur.rowcount

    dw_conn.commit()
    log.info(
        "DQ rejects written — Uniqueness: %d | Completeness(output): %d "
        "| Completeness(block): %d",
        dq1, dq2, dq3,
    )

    # ------------------------------------------------------------------
    # Main INSERT: only rows that pass all DQ gates
    # All 6 pre-computed columns calculated in-SQL (Design §4.2)
    # ------------------------------------------------------------------
    cur.execute(
        """
        INSERT INTO dbo.FACT_TRANSACTION (
            date_key, block_key, tx_type_key, market_key,
            txid,
            fee_satoshis, fee_rate_sat_vbyte,
            input_value_sat, output_value_sat,
            tx_size_bytes, tx_weight_units,
            btc_price_usd_avg,
            input_value_usd, output_value_usd, fee_usd,
            market_cap_usd, fear_greed_score,
            tx_vsize_bytes,  fee_burden_pct,
            input_value_btc, output_value_btc, fee_btc, io_value_ratio,
            dw_load_timestamp, dw_source_system
        )
        SELECT
            dd.date_key,
            db.block_key,
            dt.tx_type_key,
            dm.market_key,                         -- NULL for pre-exchange-data blocks

            t.txid,
            t.fee_satoshis,
            t.fee_rate_sat_vbyte,
            iv.input_value_sat,                    -- NULL for coinbase (no UTXO spent)
            ov.output_value_sat,
            t.size_bytes,
            t.weight_units,
            mkt.price_usd_avg,                     -- NULL for pre-2013 blocks

            -- Fiat conversions (NULL when no daily price available)
            CASE WHEN mkt.price_usd_avg IS NOT NULL AND iv.input_value_sat IS NOT NULL
                 THEN ROUND(CAST(iv.input_value_sat  AS FLOAT)
                            / 100000000.0 * mkt.price_usd_avg, 4)
                 ELSE NULL END,                    -- input_value_usd
            CASE WHEN mkt.price_usd_avg IS NOT NULL
                 THEN ROUND(CAST(ov.output_value_sat AS FLOAT)
                            / 100000000.0 * mkt.price_usd_avg, 4)
                 ELSE NULL END,                    -- output_value_usd
            CASE WHEN mkt.price_usd_avg IS NOT NULL
                 THEN ROUND(CAST(t.fee_satoshis      AS FLOAT)
                            / 100000000.0 * mkt.price_usd_avg, 4)
                 ELSE NULL END,                    -- fee_usd

            -- Denormalised macro columns copied from DIM_MARKET (Q4, Q8 queries)
            dm.market_cap_usd,
            dm.fear_greed_score,

            -- [pre-computed] tx_vsize_bytes = weight_units / 4.0  (Q2, Q3)
            ROUND(t.weight_units / 4.0, 2),

            -- [pre-computed] fee_burden_pct = fee_sat*100 / NULLIF(output_sat,0)  (Q3)
            CASE WHEN ov.output_value_sat > 0
                 THEN ROUND(t.fee_satoshis * 100.0 / ov.output_value_sat, 4)
                 ELSE NULL END,

            -- [pre-computed] input_value_btc = input_sat / 1e8
            CASE WHEN iv.input_value_sat IS NOT NULL
                 THEN ROUND(CAST(iv.input_value_sat  AS FLOAT) / 100000000.0, 8)
                 ELSE NULL END,

            -- [pre-computed] output_value_btc = output_sat / 1e8
            ROUND(CAST(ov.output_value_sat AS FLOAT) / 100000000.0, 8),

            -- [pre-computed] fee_btc = fee_sat / 1e8
            ROUND(CAST(t.fee_satoshis      AS FLOAT) / 100000000.0, 8),

            -- [pre-computed] io_value_ratio = input_sat / NULLIF(output_sat, 0)  (Q5)
            CASE WHEN ov.output_value_sat > 0 AND iv.input_value_sat IS NOT NULL
                 THEN ROUND(
                        CAST(iv.input_value_sat AS FLOAT)
                        / CAST(ov.output_value_sat AS FLOAT), 4)
                 ELSE NULL END,

            GETDATE(),
            'RPC_Node_YahooFinance'

        FROM BTC_Staging.dbo.STG_TRANSACTIONS t

        -- Block row needed for timestamp → calendar-date conversion
        JOIN BTC_Staging.dbo.STG_BLOCKS b
             ON  b.block_hash = t.block_hash

        -- Output totals per txid (SUM of all vout values)
        JOIN BTC_Staging.dbo.V_TX_OUTPUT_TOTALS ov
             ON  ov.txid = t.txid

        -- Input totals per txid (NULL for coinbase — LEFT JOIN)
        LEFT JOIN BTC_Staging.dbo.V_TX_INPUT_TOTALS iv
             ON  iv.txid = t.txid

        -- DIM_BLOCK surrogate key lookup via block_height
        JOIN dbo.DIM_BLOCK db
             ON  db.block_height = t.block_height

        -- DIM_DATE surrogate key lookup
        -- median_time (Unix epoch BIGINT) → UTC date → YYYYMMDD INT key
        JOIN dbo.DIM_DATE dd
             ON  dd.date_key =
                    YEAR (CAST(DATEADD(SECOND, b.median_time % 86400, DATEADD(DAY, b.median_time / 86400, '1970-01-01')) AS DATE)) * 10000
                  + MONTH(CAST(DATEADD(SECOND, b.median_time % 86400, DATEADD(DAY, b.median_time / 86400, '1970-01-01')) AS DATE)) * 100
                  + DAY  (CAST(DATEADD(SECOND, b.median_time % 86400, DATEADD(DAY, b.median_time / 86400, '1970-01-01')) AS DATE))

        -- Market daily row (LEFT JOIN — pre-exchange blocks have no market data)
        LEFT JOIN BTC_Staging.dbo.STG_MARKET_DAILY mkt
             ON  mkt.price_date =
                    CAST(DATEADD(SECOND, b.median_time % 86400, DATEADD(DAY, b.median_time / 86400, '1970-01-01')) AS DATE)

        -- DIM_MARKET surrogate key lookup (LEFT JOIN — NULL when no market row)
        LEFT JOIN dbo.DIM_MARKET dm
             ON  dm.snapshot_date =
                    CAST(DATEADD(SECOND, b.median_time % 86400, DATEADD(DAY, b.median_time / 86400, '1970-01-01')) AS DATE)

        -- DIM_TX_TYPE surrogate key lookup
        -- Non-conformed script types already mapped to 'OTHER' in load_dim_tx_type
        JOIN dbo.DIM_TX_TYPE dt
             ON  dt.script_type_desc =
                    CASE
                        WHEN UPPER(ISNULL(t.primary_script_type, 'OTHER'))
                             IN ('P2PKH','P2SH','P2WPKH','P2WSH','P2TR','OTHER')
                        THEN UPPER(ISNULL(t.primary_script_type, 'OTHER'))
                        ELSE 'OTHER'
                    END
             AND dt.segwit_flag   = CAST(t.has_witness AS TINYINT)
             AND dt.coinbase_flag = CAST(t.is_coinbase  AS TINYINT)
             AND dt.rbf_flag      = CAST(t.is_rbf       AS TINYINT)
             AND dt.locktime_flag =
                    CAST(CASE WHEN t.locktime > 0 THEN 1 ELSE 0 END AS TINYINT)

        -- DQ filter: exclude every row that failed a gate above
        WHERE LEN(t.txid) = 64
          AND t.txid NOT LIKE '%[^0-9a-fA-F]%'
          AND ov.output_value_sat >= 0
          AND EXISTS     (SELECT 1 FROM dbo.DIM_BLOCK db2 WHERE db2.block_height = t.block_height)
          AND NOT EXISTS (SELECT 1 FROM dbo.FACT_TRANSACTION f WHERE f.txid = t.txid)
        """
    )
    inserted = cur.rowcount
    dw_conn.commit()
    log.info("FACT_TRANSACTION: %d rows inserted.", inserted)
    return inserted


def compute_nvt_ratio(dw_conn: pyodbc.Connection, stg_conn: pyodbc.Connection):
    """
    Post-fact-load step: compute NVT Ratio for every date that has
    FACT_TRANSACTION rows but a NULL nvt_ratio in STG_MARKET_DAILY.

    NVT = market_cap_usd / SUM(output_value_usd) per date.
    Requires FACT_TRANSACTION to be loaded first.
    """
    cur_dw  = dw_conn.cursor()
    cur_stg = stg_conn.cursor()

    # Step A: aggregate daily output_value_usd from FACT_TRANSACTION
    cur_dw.execute("""
        SELECT d.[date], SUM(f.output_value_usd) AS daily_volume_usd
        FROM   dbo.FACT_TRANSACTION f
        JOIN   dbo.DIM_DATE d ON d.date_key = f.date_key
        WHERE  f.output_value_usd IS NOT NULL
        GROUP  BY d.[date]
    """)
    daily_volumes = {row[0]: row[1] for row in cur_dw.fetchall()}

    # Step B: update STG_MARKET_DAILY.nvt_ratio and DIM_MARKET.nvt_ratio
    updated = 0
    for price_date, volume_usd in daily_volumes.items():
        if volume_usd and volume_usd > 0:
            # 1. Update Staging (bump load_ts so it's fresh)
            cur_stg.execute("""
                UPDATE dbo.STG_MARKET_DAILY
                SET    nvt_ratio = ROUND(market_cap_usd / ?, 4),
                       load_ts   = SYSUTCDATETIME()
                WHERE  price_date = ?
                  AND  market_cap_usd IS NOT NULL
                  AND  nvt_ratio IS NULL
            """, volume_usd, price_date)
            if cur_stg.rowcount > 0:
                updated += 1

    stg_conn.commit()

    # Step C: propagate to DIM_MARKET (SCD-1 update)
    cur_dw.execute("""
        UPDATE dm
        SET    dm.nvt_ratio = m.nvt_ratio,
               dm.dw_load_timestamp = GETDATE()
        FROM   dbo.DIM_MARKET dm
        JOIN   BTC_Staging.dbo.STG_MARKET_DAILY m
               ON m.price_date = dm.snapshot_date
        WHERE  m.nvt_ratio IS NOT NULL
          AND  dm.nvt_ratio IS NULL
    """)
    dw_conn.commit()
    log.info("NVT Ratio: %d rows updated in STG_MARKET_DAILY.", updated)


def run_dw_load(stg_conn: pyodbc.Connection, cfg: dict):
    """Orchestrate the full DW load (Step 6) in dimension-dependency order.

    Opens a dedicated connection to BTC_DW; the staging connection is retained
    for writing pipeline-run audit rows into BTC_Staging.dbo.STG_PIPELINE_LOG.
    The two connections are independent and commit separately.
    """
    stg_cur = stg_conn.cursor()
    log_id  = log_run_start(stg_cur, "dw_load")
    stg_conn.commit()

    total_inserted = 0

    try:
        dw_conn = get_dw_connection(cfg)
    except pyodbc.Error as exc:
        log.critical("Cannot connect to BTC_DW: %s", exc)
        log_run_finish(stg_cur, log_id, 0, 0, error=str(exc))
        stg_conn.commit()
        return

    try:
        log.info("DW 6a — extend DIM_DATE to today...")
        extend_dim_date(dw_conn)

        log.info("DW 6b — DIM_BLOCK (SCD Type 0)...")
        total_inserted += load_dim_block(dw_conn)

        log.info("DW 6c — DIM_TX_TYPE (SCD Type 1 + DQ Consistency)...")
        total_inserted += load_dim_tx_type(dw_conn)

        log.info("DW 6d — DIM_MARKET (SCD Type 1 + DQ Freshness)...")
        ins, _upd = load_dim_market(dw_conn)
        total_inserted += ins

        log.info("DW 6e — FACT_TRANSACTION (DQ gates + surrogate lookups + pre-computed cols)...")
        total_inserted += load_fact_transaction(dw_conn)

        log.info("DW 6f — Compute NVT Ratio...")
        compute_nvt_ratio(dw_conn, stg_conn)

        log_run_finish(stg_cur, log_id, 0, total_inserted)
        stg_conn.commit()
        log.info(
            "DW load complete — %d dimension + fact rows inserted across all DW tables.",
            total_inserted,
        )

    except Exception as exc:
        log.error("DW load failed at an intermediate step: %s", exc)
        log_run_finish(stg_cur, log_id, 0, total_inserted, error=str(exc))
        stg_conn.commit()
        raise

    finally:
        dw_conn.close()


# ---------------------------------------------------------------------------
# Full pipeline run
# ---------------------------------------------------------------------------

def run_pipeline(cfg: dict):
    log.info("=" * 60)
    log.info("Pipeline run started — %s", datetime.now(UTC))
    log.info("=" * 60)

    try:
        conn = get_connection(cfg)
    except pyodbc.Error as exc:
        log.critical("Cannot connect to SQL Server: %s", exc)
        return

    try:
        # Step 1 — Blocks (always run first; TXs depend on it)
        log.info("--- Step 1/6: Blocks ---")
        fetch_and_load_blocks(conn, cfg)

        # Step 2 — Transactions (depends on blocks being loaded)
        log.info("--- Step 2/6: Transactions ---")
        fetch_and_load_transactions(conn, cfg)

        # Step 3 — Market OHLCV + market_cap_usd + 7d MA + 14d volatility
        log.info("--- Step 3/6: Market OHLCV ---")
        fetch_and_load_market(conn, cfg)

        # Step 4 — Fear & Greed (merges into STG_MARKET_DAILY)
        log.info("--- Step 4/6: Fear & Greed ---")
        fetch_and_load_fear_greed(conn, cfg)

        # Step 5 — BTC dominance (CoinLore live + static monthly table)
        log.info("--- Step 5/6: BTC dominance ---")
        fetch_and_load_dominance(conn, cfg)

        # Step 6 — DW Load (Staging → BTC_DW star schema)
        log.info("--- Step 6/6: DW Load (Staging → BTC_DW) ---")
        run_dw_load(conn, cfg)

    finally:
        conn.close()

    log.info("Pipeline run complete — %s", datetime.now(UTC))
    log.info("=" * 60)


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(description="BTC Staging Pipeline")
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument(
        "--run-now", action="store_true",
        help="Run the pipeline once immediately and exit.",
    )
    group.add_argument(
        "--schedule", action="store_true",
        help="Run on a repeating schedule (interval from config.yaml).",
    )
    parser.add_argument(
        "--days", type=int, default=None,
        help="Override the schedule interval from config.yaml (days).",
    )
    args = parser.parse_args()

    cfg = load_config()
    setup_logging(cfg)

    if args.run_now:
        run_pipeline(cfg)
        return

    # Scheduled mode
    interval = args.days if args.days is not None else cfg["schedule"]["interval_days"]
    log.info("Scheduler started — running every %d day(s). Press Ctrl+C to stop.", interval)

    # Run immediately on start, then every N days
    run_pipeline(cfg)
    schedule.every(interval).days.do(run_pipeline, cfg=cfg)

    while True:
        schedule.run_pending()
        time.sleep(60)  # check every minute


if __name__ == "__main__":
    main()