# Bitcoin Blockchain Analytics Platform — Data Warehouse Mini-Project
## AI Context Summary — Parts 2–4 Reference Document

> **Course:** Data Warehouses — Master's — 2025/26  
> **Part completed:** Part 1 (Analysis)  
> **Status:** Analysis complete — ready for Part 2 (Design)

---

## 1. Project Overview

We are building a **data mart** for Bitcoin blockchain transaction analytics following standard data warehouse architecture. The goal is an end-to-end analytical platform from raw source data to interactive OLAP reports.

**Stack:** SQL Server (Staging DB) → SSIS (ETL) → Star Schema DW → SSAS (multidimensional cube) → Tableau / Power BI

---

## 2. Data Sources (2 Sources — Required Minimum Met)

### Source 1 — Bitcoin On-Chain Data
| Property | Value |
|----------|-------|
| APIs | mempool.space REST API, blockchain.com/api, Bitcoin Core RPC |
| Format | JSON (live) → CSV flat files (historical) |
| Update rate | ~10 minutes (per block) |
| Access | Free public APIs; no auth required for basic endpoints |

**Fields extracted:**
- Block: height, hash, timestamp, size_bytes, weight_units, difficulty, nonce, tx_count, total_fees_sat
- Transaction: txid, block_height, input_count, output_count, fee_satoshis, fee_rate_sat_vbyte, is_coinbase, segwit_flag, tx_size_bytes, tx_weight_units, script_type
- Inputs/Outputs: value_sat, script_type, address (for UTXO tracking)
- Mempool: pending_tx_count, avg_fee_rate (snapshot)

### Source 2 — Bitcoin Market Data
| Property | Value |
|----------|-------|
| APIs | Yahoo Finance via `yfinance` (OHLCV) · Alternative.me (Fear & Greed) · CoinLore `/api/global/` (live BTC dominance) |
| Format | Python library (yfinance) + REST JSON |
| Update rate | Daily |
| History | Since ~mid-2010 (price, yfinance), since 2019-02-01 (Fear & Greed) |

**Fields extracted:**
- Date, average price (USD) — computed from Yahoo Finance daily price data (average of open, high, low, close)
- Market capitalisation (USD) — computed: `btc_circulating_supply(block_height) × btc_price_usd_avg` (no external API; deterministic halving schedule)
- Fear & Greed Index score (0–100) and label (Extreme Fear / Fear / Neutral / Greed / Extreme Greed) — via Alternative.me
- Bitcoin dominance % — today's value from CoinLore live API; all historical dates from an embedded static monthly table (linear interpolation)

---

## 3. Business Process

**Business Process:** Bitcoin Transaction Settlement  
**Measurable event:** Each on-chain confirmed transaction included in a mined block  
**Grain:** One confirmed Bitcoin transaction (one row in FACT_TRANSACTION)  
**Trigger:** Block confirmation (~every 10 minutes)

---

## 4. Dimensions (4 Dimensions — Minimum Met)

### DIM_DATE
Attributes (8):
1. `date_key` — surrogate PK (integer YYYYMMDD)
2. `full_date` — DATE
3. `year`, `quarter`, `month_num`, `month_name`
4. `day_of_week`, `week_num`
5. `is_weekend` — BOOL
6. `is_holiday` — BOOL
7. `halving_era` — INT (1=2009–2012, 2=2012–2016, 3=2016–2020, 4=2020–2024, 5=2024+)
8. `days_since_halving` — INT
9. `unix_timestamp_day` — BIGINT

### DIM_BLOCK
> **Design note:** DIM_BLOCK is redesigned as a **categorical grouped dimension** — rows represent distinct combinations of block regime attributes, not individual blocks. Block height and hash (unique per block) are removed; block_height lives as a degenerate dimension in FACT_TRANSACTION. Miner coinbase address is also removed — the coinbase transaction is already captured as a row in FACT_TRANSACTION (including it here would double-count). Raw numeric fields (size_bytes, weight_units, nonce, difficulty value) are replaced by bucketed tiers, so many blocks share the same DIM_BLOCK row. The surrogate key is a simple counter assigned to each unique attribute combination.

Attributes (6):
1. `block_key` — surrogate PK (counter — one row per unique attribute combo)
2. `difficulty_tier` — VARCHAR (`Low` / `Medium` / `High` / `Extreme`) — difficulty bucketed by network-history percentile quartiles
3. `tx_count_tier` — VARCHAR (`Low <500` / `Medium 500–2000` / `High >2000`) — block fullness proxy; correlates with block size/weight
4. `size_tier` — VARCHAR (`Small` / `Medium` / `Large` / `Full`) — derived from block weight vs. 4 MB weight limit
5. `halving_era` — INT (1–5) — which halving epoch the block belongs to
6. `is_epoch_boundary` — BOOL — TRUE only for the ~2016 blocks straddling each halving event

### DIM_TX_TYPE
Attributes (8):
1. `tx_type_key` — surrogate PK
2. `is_coinbase` — BOOL
3. `segwit_flag` — BOOL
4. `input_count_bucket` — VARCHAR (`1`, `2-5`, `6-20`, `20+`)
5. `output_count_bucket` — VARCHAR (`1`, `2`, `3-5`, `6+`)
6. `primary_script_type` — VARCHAR (P2PKH, P2SH, P2WPKH, P2WSH, P2TR)
7. `is_rbf_signalling` — BOOL (Replace-by-Fee)
8. `size_tier` — VARCHAR (`Small <250b`, `Medium 250-1000b`, `Large 1000-4000b`, `XL 4000+b`)

### DIM_MARKET
> **Design note:** Raw numeric market values (price, volume, market cap, fear/greed score) are measures in FACT_TRANSACTION. DIM_MARKET is a pure categorical market regime dimension. `price_trend` labels are renamed to plain directional tiers (Mega Bull / Bull / Lateral / Bear / Mega Bear) for clarity and consistency with the bucketing approach used across all dimensions.

Attributes (10):
1. `market_key` — surrogate PK
2. `fear_greed_label` — VARCHAR (`Extreme Fear` / `Fear` / `Neutral` / `Greed` / `Extreme Greed`)
3. `fear_greed_bucket` — VARCHAR (`0–20`, `21–40`, `41–60`, `61–80`, `81–100`)
4. `price_trend` — VARCHAR (`Mega Bull` / `Bull` / `Lateral` / `Bear` / `Mega Bear`) — derived from 7-day MA direction and magnitude
5. `volatility_regime` — VARCHAR (`Low` / `Medium` / `High` / `Extreme`) — from 14-day realised volatility percentile
6. `market_cap_tier` — VARCHAR (`Micro <100B` / `Small 100–500B` / `Mid 500B–1T` / `Large >1T`)
7. `btc_dominance_tier` — VARCHAR (`Low <40%` / `Medium 40–55%` / `High >55%`) — bucketed from `btc_dominance_pct` (CoinLore live for today; static monthly table + linear interpolation for all historical dates)
8. `nvt_signal` — VARCHAR (`Undervalued` / `Fair Value` / `Overvalued`) — NVT < 40 / 40–100 / > 100
9. `cycle_phase` — VARCHAR (`Accumulation` / `Early Bull` / `Late Bull` / `Distribution` / `Bear`)
10. `post_halving_months` — INT — full months since most recent halving (0–48)

---

## 5. Fact Table

**FACT_TRANSACTION**

> **Note on DIM_BLOCK:** `block_height` is stored here as a degenerate dimension (lookup without its own dimension table entry), preserving the ability to trace any transaction back to its exact block without bloating DIM_BLOCK with one row per block.

| Column | Type | Notes |
|--------|------|-------|
| `fact_tx_key` | INT PK | Surrogate key |
| `date_key` | INT FK | → DIM_DATE |
| `block_key` | INT FK | → DIM_BLOCK (block regime group) |
| `tx_type_key` | INT FK | → DIM_TX_TYPE |
| `market_key` | INT FK | → DIM_MARKET |
| `txid` | CHAR(64) | Degenerate dimension |
| `block_height` | INT | Degenerate dimension — exact block reference |
| **`fee_satoshis`** | BIGINT | **MEASURE** — SUM, AVG |
| **`fee_rate_sat_vbyte`** | DECIMAL | **MEASURE** — AVG, PERCENTILE |
| **`input_value_sat`** | BIGINT | **MEASURE** — SUM |
| **`output_value_sat`** | BIGINT | **MEASURE** — SUM |
| **`tx_size_bytes`** | INT | **MEASURE** — AVG, MAX |
| **`tx_weight_units`** | INT | **MEASURE** — AVG, SUM |
| **`btc_price_usd_avg`** | DECIMAL | **MEASURE** — average daily BTC price (OHLC average) |
| **`input_value_usd`** | DECIMAL | **MEASURE** — transaction input value in USD |
| **`output_value_usd`** | DECIMAL | **MEASURE** — transaction output value in USD |
| **`fee_usd`** | DECIMAL | **MEASURE** — transaction fee in USD |
| **`market_cap_usd`** | BIGINT | **MEASURE** — computed: `btc_circulating_supply(block_height) × btc_price_usd_avg` |
| **`fear_greed_score`** | INT | **MEASURE** — raw Fear & Greed score (0–100) |

**12 measures** — substantially exceeds the minimum requirement of 4 (3 minimum for basic score)

---

## 6. User Profile

### User Profile — Blockchain Analyst / Researcher (PRIMARY)
Needs to understand long-term trends, on-chain behaviour, SegWit adoption, miner economics, UTXO patterns. Time-series and aggregated views are key.

---

## 7. OLAP User Needs (8 Retained questions)

| ID | Question | Dimensions Used | Expected Visualisation |
|----|----------|----------------|----------------------|
| N1 | How does avg fee rate (sat/vB) evolve MoM across halving epochs? | DIM_DATE × DIM_BLOCK × DIM_TX_TYPE | Line chart with epoch markers |
| N2 | What % of confirmed transactions use SegWit-native inputs vs legacy per quarter? | DIM_DATE × DIM_TX_TYPE | Stacked bar — SegWit adoption |
| N3 | How does average transaction size/weight vary by script type over time? | DIM_DATE × DIM_TX_TYPE | Clustered column chart |
| N4 | How does transaction volume (USD) scale across different market cap tiers? | DIM_DATE × DIM_MARKET | Heatmap or Bubble chart |
| N5 | How does the Network Value to Transactions (NVT) signal correlate with market valuation? | DIM_DATE × DIM_MARKET | Dual-axis line (NVT vs Price) |
| N6 | What are the trends in Replace-by-Fee (RBF) adoption over time? | DIM_DATE × DIM_TX_TYPE | Area chart |
| N7 | How has transaction complexity (inputs/outputs count) evolved over time? | DIM_DATE × DIM_TX_TYPE | Multi-line trend chart |
| N8 | How does daily on-chain transaction volume respond to changes in Bitcoin dominance? | DIM_DATE × DIM_MARKET | Scatter plot with trend lines |

---

## 8. Dataset Scope (Practical)

| Dataset | Volume | Scope Decision |
|---------|--------|---------------|
| Block metadata | ~200K rows | Last 200K blocks (~4 years) |
| Transactions | ~50M rows | Sampled subset of above blocks |
| TX Inputs/Outputs | Filtered | Only for sampled TXs |
| Market OHLCV | ~5,500 rows | Full history since 2009 |
| Fear & Greed | ~2,000 rows | Full history since 2019 |

> **DIM_BLOCK row count:** With 4 difficulty tiers × 3 tx_count tiers × 4 size tiers × 5 halving eras × 2 epoch_boundary values = max 480 distinct combinations (actual populated rows far fewer, ~50–100 realistic combos).

---

## 9. Architecture Summary

```
[Source 1: mempool.space API / blockchain.com]
           ↓  JSON / REST
[Source 2: CoinGecko API / Alternative.me]
           ↓  JSON / CSV

     ┌─────────────────────┐
     │   STAGING DATABASE  │  ← SQL Server (raw relational tables)
     │   (SQL Server)      │    Loaded via SSIS Extract & Load
     └─────────┬───────────┘
               │ SSIS Transform & Load
     ┌─────────▼───────────┐
     │   DATA MART (DW)    │  ← Star Schema
     │   FACT_TRANSACTION  │    DIM_DATE, DIM_BLOCK,
     │   + 4 DIMENSIONS    │    DIM_TX_TYPE, DIM_MARKET
     └─────────┬───────────┘
               │ SSAS Processing
     ┌─────────▼───────────┐
     │   SSAS OLAP CUBE    │  ← Multidimensional cube
     │   (Multidim. Model) │    Measures + hierarchies
     └─────────┬───────────┘
               │
     ┌─────────▼───────────┐
     │ Tableau / Power BI  │  ← Reports, dashboards, OLAP analysis
     └─────────────────────┘
```

---

## 10. Requirements Checklist

| Requirement | Status | Detail |
|-------------|--------|--------|
| ≥ 2 data sources | ✅ | mempool.space (on-chain) + yfinance / Alternative.me / CoinLore (market) |
| Heterogeneous formats | ✅ | REST JSON (live) + CSV flat files (historical) |
| Operational data (not pre-aggregated) | ✅ | Raw TX & block data |
| ≥ 4 dimensions | ✅ | 4 dimensions |
| ≥ 5–10 attributes per dimension | ✅ | 6–10 per dimension |
| ≥ 4 measures | ✅ | 12 measures |
| Single data mart (single line of business) | ✅ | Bitcoin TX settlement |
| SSAS cube planned | ✅ | Multidimensional cube in Part 3 |
| ETL via SSIS | ✅ | Planned for Part 3 |
| Staging DB | ✅ | SQL Server intermediate store |
| Not AdventureWorks | ✅ | Custom Bitcoin blockchain dataset |

---

## 11. Notes for Part 2 (Design)

- **Star schema** is the target (not snowflake) — simpler for SSAS and OLAP queries
- **DIM_DATE** should be built as a calendar table with pre-computed attributes (faster querying)
- **DIM_BLOCK** is now a small grouped dimension (~50–100 rows). ETL classifies each raw block into tiers during staging load; FACT_TRANSACTION keeps `block_height` as degenerate dimension for exact traceability. `block_hash`, `nonce`, `miner_coinbase_address`, and raw numeric fields are staging-only — not loaded into the DW dimension.
- **DIM_MARKET** is a categorical market regime dimension. `price_trend` uses five directional tiers (Mega Bull / Bull / Lateral / Bear / Mega Bear). Raw numeric values live in FACT_TRANSACTION. `market_cap_usd` is computed in the pipeline from `btc_circulating_supply(block_height) × price_close` — no external market-cap API needed. `btc_dominance_pct` is resolved from CoinLore for today's live value and from an embedded static monthly table (linearly interpolated) for all historical dates.
- **FACT_TRANSACTION** will be large — consider partitioning by date in staging
- **DIM_TX_TYPE** is a small, slowly-changing dimension — candidate for static lookup
- **ETL flow:** Extract (API/CSV) → Stage (SQL Server raw) → Clean → Conform → Load DW
- **Logical Data Map** should trace each source field → staging column → DW attribute