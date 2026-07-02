# Bitcoin Blockchain Analytics Platform
## Data Profiling Report — Stage 1 (Analysis)
**Course:** Data Warehouses — Master's 2025/26  
**Author:** Álvaro Puebla Ruisánchez  
**Scope:** Source 1 (Bitcoin On-Chain) · Source 2 (Bitcoin Market Data)

---

## How to Fetch Samples Locally

Before the profiling detail, here are the exact commands to reproduce all samples used in this report. Run these to populate your staging DB.

```bash
# ---------- SOURCE 1 — mempool.space ----------
# Current block tip height
curl "https://mempool.space/api/blocks/tip/height"

# Last 15 block headers (paginated endpoint)
curl "https://mempool.space/api/v1/blocks"

# Single block detail by height
curl "https://mempool.space/api/block-height/840000"    # returns block hash
HASH=$(curl -s "https://mempool.space/api/block-height/840000")
curl "https://mempool.space/api/block/$HASH"            # returns block JSON

# Transactions in a block (first page, 25 TXs)
curl "https://mempool.space/api/block/$HASH/txs/0"

# Single transaction detail
curl "https://mempool.space/api/tx/4d5b2a..."           # replace with real txid

# ---------- SOURCE 2 — yfinance (Yahoo Finance) ----------
# Install: pip install yfinance
# No API key required.

# ---------- SOURCE 2 — Alternative.me Fear & Greed ----------
# Latest value
curl "https://api.alternative.me/fng/"

# Full history (all available dates since 2019)
curl "https://api.alternative.me/fng/?limit=0&format=csv"    # CSV
curl "https://api.alternative.me/fng/?limit=0"               # JSON
```

```python
# Python equivalent — recommended for staging automation
import requests, pandas as pd, json, time

# --- mempool.space blocks ---
def fetch_block_page(start_height=None):
    url = "https://mempool.space/api/v1/blocks"
    if start_height:
        url += f"/{start_height}"
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    return r.json()   # list of 15 block dicts

# --- mempool.space transactions ---
def fetch_block_txs(block_hash, page=0):
    url = f"https://mempool.space/api/block/{block_hash}/txs/{page}"
    r = requests.get(url, timeout=10)
    r.raise_for_status()
    return r.json()   # list of up to 25 tx dicts

# --- yfinance BTC-USD OHLCV ---
def fetch_ohlcv():
    import yfinance as yf
    ticker = yf.Ticker("BTC-USD")
    hist = ticker.history(period="max", interval="1d", auto_adjust=True)
    # Normalise index to UTC date
    hist.index = hist.index.tz_convert("UTC")
    hist.index = hist.index.date
    hist.index.name = "price_date"
    return hist[["Open", "High", "Low", "Close", "Volume"]].rename(columns={
        "Open":   "price_open",
        "High":   "price_high",
        "Low":    "price_low",
        "Close":  "price_close",
        "Volume": "volume_24h_usd",
    })
# NOTE: market_cap_usd and btc_dominance_pct are NOT available from yfinance.

# --- Alternative.me Fear & Greed ---
def fetch_fear_greed():
    r = requests.get("https://api.alternative.me/fng/?limit=0", timeout=10)
    return r.json()["data"]   # list of dicts

# NOTE: yfinance handles rate limiting internally; no manual sleep needed.
```

---

## Source 1 — Bitcoin On-Chain Data

**APIs:** mempool.space REST  
**Formats:** REST/JSON (live) → CSV flat file (historical archival)  
**Update cadence:** ~10 minutes (one block)

---

### 1.1 Block Metadata Endpoint

**URL:** `GET https://mempool.space/api/v1/blocks[/{start_height}]`  
Returns 15 blocks per page, newest first.

#### Representative Sample Record (one block JSON object)

```json
{
  "id":           "00000000000000000002e8e2a8...abcd",
  "height":       840000,
  "version":      536870912,
  "timestamp":    1713571767,
  "tx_count":     3050,
  "size":         1542318,
  "weight":       3993672,
  "merkle_root":  "f1234...abc",
  "previousblockhash": "000000000000000000033f...",
  "mediantime":   1713570144,
  "nonce":        3204668123,
  "bits":         386089497,
  "difficulty":   86871722279470.31,
  "extras": {
    "coinbaseRaw":  "03401e0d...",
    "medianFee":    15,
    "feeRange":     [1, 5, 10, 15, 25, 50, 200],
    "reward":       312694674,
    "totalFees":    62694674,
    "avgFee":       20547,
    "avgFeeRate":   20,
    "pool": {
      "id":     81,
      "name":   "Foundry USA",
      "slug":   "foundryusa"
    },
    "matchRate":    98.36,
    "expectedFees": 62521069
  }
}
```

#### Column Inventory — Block Endpoint

| JSON Field | SQL Type | Example Value | Notes |
|---|---|---|---|
| `id` | CHAR(64) | `"00000000...abcd"` | Block hash — degenerate dim candidate |
| `height` | INT | `840000` | Sequential, no gaps |
| `version` | INT | `536870912` | Version signalling bits |
| `timestamp` | BIGINT | `1713571767` | Unix epoch (UTC) |
| `tx_count` | INT | `3050` | TXs including coinbase |
| `size` | INT | `1542318` | Raw bytes |
| `weight` | INT | `3993672` | SegWit weight units (max ~4M) |
| `merkle_root` | CHAR(64) | `"f1234...abc"` | Staging only |
| `previousblockhash` | CHAR(64) | `"000000...33f"` | Staging only |
| `mediantime` | BIGINT | `1713570144` | MTP — staging only |
| `nonce` | BIGINT | `3204668123` | Staging only |
| `bits` | BIGINT | `386089497` | Compact difficulty target |
| `difficulty` | FLOAT | `86871722279470.31` | Absolute difficulty |
| `extras.medianFee` | INT | `15` | Median fee rate sat/vByte |
| `extras.feeRange` | ARRAY[INT] | `[1,5,10,15,25,50,200]` | 7 percentile buckets |
| `extras.reward` | BIGINT | `312694674` | Subsidy + fees (satoshis) |
| `extras.totalFees` | BIGINT | `62694674` | Block total fees (satoshis) |
| `extras.avgFeeRate` | INT | `20` | Average fee rate sat/vByte |
| `extras.pool.name` | VARCHAR(100) | `"Foundry USA"` | Mining pool name |

#### Null / Missing Field Rates — Block Endpoint

| Field | Null Rate | Condition |
|---|---|---|
| `extras` | ~0% | Always present for recent blocks |
| `extras.pool` | ~2–5% | Unknown pools → `{"id":null,"name":"Unknown"}` |
| `extras.feeRange` | ~0.1% | Very old or empty blocks |
| `extras.matchRate` | ~0% | Always present |
| `previousblockhash` | 100% for block 0 | Genesis block only |

---

### 1.2 Transaction Endpoint

**URL:** `GET https://mempool.space/api/block/{hash}/txs/{start_index}`  
Returns 25 TXs per page; coinbase TX is always index 0.

#### Representative Sample Record (one transaction JSON)

```json
{
  "txid": "4d5b2a3e...f7",
  "version": 2,
  "locktime": 0,
  "size": 225,
  "weight": 574,
  "fee": 3375,
  "vin": [
    {
      "txid":     "abcd...1234",
      "vout":     1,
      "prevout": {
        "scriptpubkey":      "0014a3f...bc2",
        "scriptpubkey_type": "v0_p2wpkh",
        "value":             500000
      },
      "scriptsig": "",
      "witness":  ["304402...", "02abc..."],
      "sequence": 4294967293,
      "is_coinbase": false
    }
  ],
  "vout": [
    {
      "scriptpubkey":      "0014b2c...de1",
      "scriptpubkey_type": "v0_p2wpkh",
      "scriptpubkey_address": "bc1q...xyz",
      "value": 120000
    },
    {
      "scriptpubkey":      "0014c3d...ef2",
      "scriptpubkey_type": "v0_p2wpkh",
      "scriptpubkey_address": "bc1q...abc",
      "value": 376625
    }
  ],
  "status": {
    "confirmed":   true,
    "block_height": 840001,
    "block_hash":   "000000...aa",
    "block_time":   1713572100
  }
}
```

#### Column Inventory — Transaction Endpoint

| JSON Path | SQL Type | Example Value | DW Target |
|---|---|---|---|
| `txid` | CHAR(64) | `"4d5b2a...f7"` | FACT_TRANSACTION.txid (degenerate) |
| `version` | TINYINT | `2` | Staging only |
| `locktime` | INT | `0` | Staging only |
| `size` | INT | `225` | FACT_TRANSACTION.tx_size_bytes |
| `weight` | INT | `574` | FACT_TRANSACTION.tx_weight_units |
| `fee` | BIGINT | `3375` | FACT_TRANSACTION.fee_satoshis |
| `vin[].is_coinbase` | BIT | `false` | DIM_TX_TYPE.is_coinbase |
| `vin[].witness` | ARRAY | `["304402..."]` | Non-empty → segwit_flag=TRUE |
| `vin[].prevout.scriptpubkey_type` | VARCHAR(20) | `"v0_p2wpkh"` | DIM_TX_TYPE.primary_script_type |
| `vin[].prevout.value` | BIGINT | `500000` | Aggregated → FACT.input_value_sat |
| `vout[].value` | BIGINT | `376625` | Aggregated → FACT.output_value_sat |
| `vout[].scriptpubkey_type` | VARCHAR(20) | `"v0_p2wpkh"` | DIM_TX_TYPE.primary_script_type |
| `vout[].scriptpubkey_address` | VARCHAR(100) | `"bc1q...xyz"` | Staging only (UTXO tracking) |
| `status.block_height` | INT | `840001` | FACT_TRANSACTION.block_height |

#### Null / Missing Field Rates — Transaction Endpoint

| Field | Null Rate | Condition |
|---|---|---|
| `fee` | ~100% for coinbase | Coinbase TXs have no fee — use 0 |
| `vin[].prevout` | ~100% for coinbase inputs | Coinbase vin has no previous output |
| `vin[].witness` | ~25–35% | Pre-SegWit or legacy-input TXs |
| `vout[].scriptpubkey_address` | ~5–10% | Bare scripts, OP_RETURN outputs |
| `locktime` | 0% | Always present, usually `0` |

---

### 1.3 Source 1 — Data Quality Issues

| Issue | Description | Severity |
|---|---|---|
| **Rate limiting** | mempool.space public API: no hard rate limit documented, but aggressive polling (>10 req/s) triggers 429. Backfilling 200K blocks = ~13K API pages. | Medium |
| **Pagination depth** | Block TX endpoint returns 25 TXs per page. A block with 3,000 TXs requires 120 sequential requests. Multiply by 200K blocks = ~24M requests for full history. **Sample approach essential.** | High |
| **fee_rate derivation** | `fee_rate_sat_vbyte` is NOT returned directly. Must be computed: `ROUND(fee / (weight / 4.0), 2)`. Virtual bytes = weight / 4. | Medium |
| **input_value_sat missing for coinbase** | Coinbase `vin` has no `prevout` → no input value. Store NULL or -1 in staging; exclude from SUM aggregates. | Medium |
| **primary_script_type derivation** | Must be decided from majority vote across all inputs and outputs. No single "type" field at TX level. | Medium |
| **is_rbf_signalling** | Not returned by mempool.space TX endpoint. Derivable from `vin[].sequence <= 0xFFFFFFFD`, but requires parsing each input. | Low |
| **Historical CSV gaps** | blockchain.com historical export has known gaps in 2010–2011 (sparse early blocks). Fee data absent before block ~170,000. | Medium |
| **Orphaned / stale data** | Rare reorganisation events (<0.01%) can cause a previously confirmed TX to be rolled back. Staging must support soft-delete or versioning. | Low |
| **Timestamp precision** | `timestamp` is miner-set and can be up to 2 hours in the past. Use `mediantime` for analytical date joining. | Medium |

---

### 1.4 Source 1 — Volume Estimates

| Dataset | Rows (scope) | Est. Raw Size |
|---|---|---|
| Block metadata (last 200K blocks) | 200,000 | ~80 MB JSON |
| Transactions (~50M sample) | 50,000,000 | ~20 GB JSON |
| TX inputs/outputs (sampled) | ~150M (3 UTXO avg) | ~60 GB JSON |

**Date range:** Block 686,000 (approx. June 2021) → Block 886,000 (approx. April 2025)

---

## Source 2 — Bitcoin Market Data

**APIs:** Yahoo Finance via `yfinance` (key-less) · Alternative.me Fear & Greed Index · CoinLore `/api/global/` (live BTC dominance)  
**Formats:** Python library (yfinance) + REST/JSON  
**Update cadence:** Daily

---

### 2.1 Yahoo Finance (yfinance) — Daily OHLCV

**Library:** `yfinance` (pip install yfinance) — no API key required.  
**Ticker:** `BTC-USD`  
**Full history:** Available via `period="max"`, daily interval.

#### Representative DataFrame Output

```
Date (UTC)    Open        High        Low         Close       Volume
2024-04-18    63100.0000  64200.0000  62800.0000  63845.1200  28741234567
2024-04-19    63845.1200  65100.0000  63700.0000  64512.3300  31054112334
```

> **Note:** `auto_adjust=True` is passed so the Close column reflects adjusted prices. Volume is in USD equivalent as reported by Yahoo Finance.

#### Column Inventory — yfinance `BTC-USD` Ticker

| DataFrame Column | SQL Type | Example Value | DW Target |
|---|---|---|---|
| Index (date, UTC) | DATE | `2024-04-18` | STG_MARKET_DAILY.price_date |
| `Open` | DECIMAL(18,4) | `63100.0000` | STG_MARKET_DAILY.price_open |
| `High` | DECIMAL(18,4) | `64200.0000` | STG_MARKET_DAILY.price_high |
| `Low` | DECIMAL(18,4) | `62800.0000` | STG_MARKET_DAILY.price_low |
| `Close` | DECIMAL(18,4) | `63845.1200` | STG_MARKET_DAILY.price_close |
| `Volume` | DECIMAL(22,2) | `28741234567` | STG_MARKET_DAILY.volume_24h_usd |
| — (Computed) | DECIMAL(18,4) | `63486.2875` | STG_MARKET_DAILY.price_usd_avg / FACT.btc_price_usd_avg |

> **Not available from yfinance:** `market_cap_usd` and `btc_dominance_pct` — these columns remain NULL in STG_MARKET_DAILY. NVT ratio computation will require an external source for market cap, or can be approximated if circulating supply data is imported separately.

---

### 2.2 Alternative.me — Fear & Greed Index

**URL:** `GET https://api.alternative.me/fng/?limit=0`

#### Representative Sample Records

```json
{
  "name": "Fear and Greed Index",
  "data": [
    {
      "value":               "72",
      "value_classification": "Greed",
      "timestamp":           "1713484800",
      "time_until_update":   "64800"
    },
    {
      "value":               "45",
      "value_classification": "Fear",
      "timestamp":           "1713398400",
      "time_until_update":   null
    }
  ],
  "metadata": {
    "error": null
  }
}
```

#### CSV Format (via `?limit=0&format=csv`)

```
date,fng_value,fng_classification,timestamp
19-04-2024,72,Greed,1713484800
18-04-2024,45,Fear,1713398400
17-04-2024,38,Fear,1713312000
```

#### Column Inventory — Fear & Greed

| Field | SQL Type | Example Value | DW Target |
|---|---|---|---|
| `value` | TINYINT | `72` | FACT.fear_greed_score |
| `value_classification` | VARCHAR(20) | `"Greed"` | DIM_MARKET.fear_greed_label |
| `timestamp` | BIGINT | `1713484800` | Join key → DATE |
| `time_until_update` | INT | `64800` | Staging only (discard) |

#### Null / Missing Field Rates — Fear & Greed

| Field | Null Rate | Condition |
|---|---|---|
| `value` | ~0% | Always populated |
| `value_classification` | ~0% | Always populated |
| `time_until_update` | ~50% | Null for historical records |

---

### 2.3 Source 2 — Data Quality Issues

| Issue | Description | Severity |
|---|---|---|
| **market_cap_usd not from API** | yfinance does not provide historical market cap. `market_cap_usd` is **computed in the pipeline**: `btc_circulating_supply(block_height) × btc_price_usd_avg` using a deterministic halving schedule. Result is a close approximation; error is negligible for market-cap estimation. NVT ratio computation is deferred until on-chain transaction volume is available for joining. | Low |
| **btc_dominance_pct — live only from CoinLore** | CoinLore `/api/global/` provides only today's live BTC dominance. All historical dates are resolved from an embedded static monthly table (2009–2026) with linear interpolation between anchor points. Values from 2025-09 onward are estimated. | Low |
| **Price = 0 / NaN before 2010** | yfinance BTC-USD history effectively starts around mid-2010 (first reliable Yahoo Finance data). Rows before that date will simply be absent rather than zero-filled. | Medium |
| **Volume accuracy** | Yahoo Finance volume for BTC-USD aggregates exchange volume from a subset of venues. It is directionally correct but may differ from CoinGecko or CoinMarketCap aggregated volume. Flag as approximate. | Low |
| **Today's candle is incomplete** | yfinance returns an intra-day row for the current date. The pipeline skips any row where `date >= today` to avoid loading a partial candle. | Low |
| **Fear & Greed history starts 2019-02-01** | No data exists before this date. FACT_TRANSACTION rows pre-2019 must LEFT JOIN to NULL on fear_greed_score and use a default DIM_MARKET key (e.g., `market_key = -1` = "Unknown Regime"). | High |
| **Timestamp timezone** | yfinance DatetimeIndex is tz-aware (UTC when `tz_convert("UTC")` is applied). Fear & Greed timestamps are also UTC. Bitcoin block timestamps are miner-set UTC. All normalised to UTC date before joining. | Low |
| **NVT ratio deferred** | NVT (Network Value to Transactions) requires both market cap (now computed) and daily on-chain TX volume joined from FACT_TRANSACTION. NVT is computed as a post-load step once both are available; it is not populated during the initial staging load. | Medium |

---

## Source 1 vs. Dimensional Model — Mismatch Analysis

| DW Target | Source Field | Status | ETL Action Required |
|---|---|---|---|
| `FACT.fee_rate_sat_vbyte` | Not in API | ⚠️ Derived | Compute: `ROUND(fee / (weight/4.0), 2)` |
| `FACT.input_value_sat` | `SUM(vin[].prevout.value)` | ⚠️ Aggregation | Sum across all vin entries per TX |
| `FACT.output_value_sat` | `SUM(vout[].value)` | ⚠️ Aggregation | Sum across all vout entries per TX |
| `DIM_TX_TYPE.is_coinbase` | `vin[0].is_coinbase` | ✅ Direct | Check first input element |
| `DIM_TX_TYPE.segwit_flag` | `vin[].witness` | ⚠️ Derived | TRUE if any input has non-empty witness array |
| `DIM_TX_TYPE.is_rbf_signalling` | `vin[].sequence` | ⚠️ Derived | TRUE if any `sequence <= 0xFFFFFFFD` |
| `DIM_TX_TYPE.primary_script_type` | `vin[].prevout.scriptpubkey_type` | ⚠️ Derived | Majority vote across all I/O; P2TR, P2WPKH, P2WSH, P2SH, P2PKH |
| `DIM_TX_TYPE.input_count_bucket` | `len(vin)` | ✅ Derived | Count vin array; bucket in ETL |
| `DIM_TX_TYPE.output_count_bucket` | `len(vout)` | ✅ Derived | Count vout array; bucket in ETL |
| `DIM_BLOCK.difficulty_tier` | `block.difficulty` | ✅ Derived | Bucket by quartile of full history |
| `DIM_BLOCK.tx_count_tier` | `block.tx_count` | ✅ Direct | Bucket: <500 / 500–2000 / >2000 |
| `DIM_BLOCK.size_tier` | `block.weight` | ✅ Derived | Compare to 4M limit |
| `DIM_BLOCK.halving_era` | `block.height` | ✅ Derived | Height ranges: 0/210K/420K/630K/840K |
| `DIM_BLOCK.is_epoch_boundary` | `block.height` | ✅ Derived | TRUE if within 1008 blocks of halving height |

---

## Source 2 vs. Dimensional Model — Mismatch Analysis

| DW Target | Source Field | Status | ETL Action Required |
|---|---|---|---|
| `FACT.btc_price_usd_avg` | `price_usd_avg` | ✅ Computed | Staged average price of the day (OHLC average) |
| `FACT.input_value_usd` | `value_sat` × `price_usd_avg` | ⚠️ Derived | Sum inputs in sats × 10^-8 × average price |
| `FACT.output_value_usd` | `value_sat` × `price_usd_avg` | ⚠️ Derived | Sum outputs in sats × 10^-8 × average price |
| `FACT.fee_usd` | `fee_satoshis` × `price_usd_avg` | ⚠️ Derived | fee_satoshis × 10^-8 × average price |
| `FACT.market_cap_usd` | — | ⚠️ Derived | Computed in pipeline: `btc_circulating_supply(block_height) × price_close` |
| `FACT.fear_greed_score` | `fng.value` | ✅ Direct | Alternative.me API |
| `DIM_MARKET.fear_greed_label` | `fng.value_classification` | ✅ Direct | Already matches model labels |
| `DIM_MARKET.fear_greed_bucket` | `fng.value` | ✅ Derived | Bucket 0–20 / 21–40 / 41–60 / 61–80 / 81–100 |
| `DIM_MARKET.price_trend` | Not in API | ⚠️ Derived | Compute 7-day MA; classify direction + magnitude |
| `DIM_MARKET.volatility_regime` | Not in API | ⚠️ Derived | Compute 14-day realised vol; percentile bucket |
| `DIM_MARKET.market_cap_tier` | — | ⚠️ Derived | Bucket computed `market_cap_usd` into tiers during DW load |
| `DIM_MARKET.btc_dominance_tier` | — | ⚠️ Derived | CoinLore live API (today) + static monthly table with linear interpolation (historical) |
| `DIM_MARKET.nvt_signal` | Not available | ⚠️ Derived (deferred) | Requires `market_cap_usd` (now computed) + on-chain TX volume from FACT; computed as post-load step |
| `DIM_MARKET.cycle_phase` | Not in any API | ⚠️ Rule-based | Derive from price_trend + days_since_halving + volatility_regime |
| `DIM_MARKET.post_halving_months` | Not in API | ✅ Derivable | From DIM_DATE.days_since_halving / 30 |
| `DIM_DATE.halving_era` | Not in API | ✅ Derivable | From block.height or calendar date |
| `DIM_DATE.days_since_halving` | Not in API | ✅ Derivable | Calendar arithmetic from known halving dates |

---

## ETL Staging Layer — Quality Handling Summary

| Issue | Staging Table Strategy |
|---|---|
| `fee` is NULL for coinbase TXs | Stage as `fee_satoshis = 0`; set flag `is_coinbase = 1` |
| `fee_rate_sat_vbyte` must be computed | Add computed column in staging: `fee / (weight / 4.0)` |
| `input_value_sat` requires UTXO sum | Explode vin array into `STG_TX_INPUTS`; SUM per txid during DW load |
| `output_value_sat` requires UTXO sum | Explode vout array into `STG_TX_OUTPUTS`; SUM per txid during DW load |
| `primary_script_type` majority vote | Add post-load SQL step: `MODE(scriptpubkey_type)` grouped by txid |
| `segwit_flag` derivation | `CASE WHEN EXISTS (SELECT 1 FROM STG_TX_INPUTS WHERE txid=t.txid AND witness IS NOT NULL) THEN 1 ELSE 0` |
| Fear & Greed absent pre-2019 | `LEFT JOIN` on date; NULL score rows → map to `market_key = -1` ("No Data") |
| BTC price absent before ~mid-2010 | yfinance has no BTC-USD data before ~2010-07; early rows simply absent in staging |
| Volume = 0 | Store 0 in staging; NULL out in DW transform |
| NVT deferred | `market_cap_usd` is now computed; NVT requires both market cap and on-chain TX volume from FACT — computed as a post-load step once both are available |
| `btc_dominance_pct` sourcing | CoinLore `/api/global/` live API for today; all historical dates resolved from embedded static monthly table (2009–2026) with linear interpolation |
| `market_cap_usd` computed internally | `btc_circulating_supply(block_height) × price_close` — deterministic halving schedule; no external API needed |
| yfinance today's incomplete candle | Pipeline skips rows where `date >= today` to avoid partial data |
| Miner timestamp drift | Join FACT to DIM_DATE using `CAST(FROM_UNIXTIME(mediantime) AS DATE)` not raw `timestamp` |
| Block reorgs | Add `is_active BIT DEFAULT 1` to all staging block/TX tables; soft-delete on reorg detection |

---

## Staging Database Schema Sketch

```sql
-- SQL Server Staging DB (BTC_Staging)

CREATE TABLE STG_BLOCKS (
    block_hash        CHAR(64)     NOT NULL,
    height            INT          NOT NULL,
    block_timestamp   BIGINT       NOT NULL,
    median_time       BIGINT       NOT NULL,
    tx_count          INT          NOT NULL,
    size_bytes        INT          NOT NULL,
    weight_units      INT          NOT NULL,
    difficulty        FLOAT        NOT NULL,
    nonce             BIGINT       NOT NULL,
    total_fees_sat    BIGINT       NULL,
    avg_fee_rate      INT          NULL,
    pool_name         VARCHAR(100) NULL,
    load_ts           DATETIME2    NOT NULL DEFAULT GETDATE(),
    is_active         BIT          NOT NULL DEFAULT 1
);

CREATE TABLE STG_TRANSACTIONS (
    txid              CHAR(64)     NOT NULL,
    block_hash        CHAR(64)     NOT NULL,
    block_height      INT          NOT NULL,
    tx_version        TINYINT      NOT NULL,
    locktime          INT          NOT NULL,
    size_bytes        INT          NOT NULL,
    weight_units      INT          NOT NULL,
    fee_satoshis      BIGINT       NOT NULL DEFAULT 0,
    fee_rate_sat_vbyte AS (CASE WHEN weight_units > 0 THEN ROUND(CAST(fee_satoshis AS FLOAT) / (weight_units / 4.0), 2) ELSE NULL END) PERSISTED,
    input_count       INT          NOT NULL,
    output_count      INT          NOT NULL,
    is_coinbase       BIT          NOT NULL DEFAULT 0,
    has_witness       BIT          NOT NULL DEFAULT 0,
    is_rbf            BIT          NOT NULL DEFAULT 0,
    primary_script_type VARCHAR(20) NULL,
    load_ts           DATETIME2    NOT NULL DEFAULT GETDATE()
);

CREATE TABLE STG_TX_INPUTS (
    id                BIGINT IDENTITY PRIMARY KEY,
    txid              CHAR(64)     NOT NULL,
    input_index       INT          NOT NULL,
    prev_txid         CHAR(64)     NULL,
    prev_vout         INT          NULL,
    value_sat         BIGINT       NULL,
    script_type       VARCHAR(20)  NULL,
    address           VARCHAR(100) NULL,
    has_witness       BIT          NOT NULL DEFAULT 0,
    sequence_num      BIGINT       NOT NULL
);

CREATE TABLE STG_TX_OUTPUTS (
    id                BIGINT IDENTITY PRIMARY KEY,
    txid              CHAR(64)     NOT NULL,
    output_index      INT          NOT NULL,
    value_sat         BIGINT       NOT NULL,
    script_type       VARCHAR(20)  NULL,
    address           VARCHAR(100) NULL
);

CREATE TABLE STG_MARKET_DAILY (
    price_date        DATE         NOT NULL,
    price_open        DECIMAL(18,4) NULL,
    price_high        DECIMAL(18,4) NULL,
    price_low         DECIMAL(18,4) NULL,
    price_close       DECIMAL(18,4) NULL,
    -- Computed: average daily price (OHLC average)
    price_usd_avg     AS (
        CASE WHEN price_open IS NOT NULL AND price_high IS NOT NULL AND price_low IS NOT NULL AND price_close IS NOT NULL
             THEN ROUND((price_open + price_high + price_low + price_close) / 4.0, 4)
             ELSE price_close
        END
    ) PERSISTED,
    volume_24h_usd    DECIMAL(22,2) NULL,
    market_cap_usd    DECIMAL(22,2) NULL,
    btc_dominance_pct DECIMAL(5,2)  NULL,
    fear_greed_score  TINYINT       NULL,
    fear_greed_label  VARCHAR(20)   NULL,
    load_ts           DATETIME2     NOT NULL DEFAULT GETDATE()
);
```