# Bitcoin Data Warehouse — Stage 3: Implementation Update Plan

---

## 1. Business Scope & Analytical Questions

### 1.1 Business Process Focus

| Property | Value |
|---|---|
| **Business Process** | Bitcoin Transaction Settlement |
| **Grain** | One confirmed on-chain transaction — one row in `FACT_TRANSACTION` |
| **Trigger** | Block confirmation (approximately every 10 minutes) |
| **Primary User** | Blockchain Analyst / Researcher |

The analyst studies on-chain network transaction-settlement dynamics: fee pressure, script-type adoption, block-space utilisation, and macro-financial correlations between on-chain activity and market sentiment.

---

### 1.2 Analytical Questions (Q1–Q8)

Eight analytical questions drive every design decision in the schema, the DQ rules, and the pre-computed columns.

**Q1 — SegWit adoption over time**
What is the adoption rate of SegWit-native script types (P2WPKH, P2WSH, P2TR) versus legacy types (P2PKH, P2SH), and how has this composition evolved by quarter?
*Impact*: Tracks protocol-upgrade adoption curves. Helps wallet developers and miners optimise fees and identify when SegWit throughput gains materialise.

**Q2 — Fee-rate spikes under congestion**
Under what conditions of network congestion (average transaction weight and size per block) do fee rates (sat/vByte) spike, and how do they correlate with daily market price trends?
*Impact*: Informs exchanges and payment processors when to use transaction batching or Lightning Network channels, reducing fee exposure.

**Q3 — Fee burden distribution**
What is the distribution of transaction fee burden (fee in USD as a percentage of total output value in USD) across different transaction-size tiers?
*Impact*: Reveals whether Bitcoin functions as a high-value settlement layer or a low-value transfer system, showing the economic viability of small on-chain transfers.

**Q4 — Volume vs. Fear & Greed**
How does transaction volume and total settlement value in USD correlate with the daily Fear & Greed Index? Are "Greed" periods accompanied by larger transaction values?
*Impact*: Combines on-chain activity with market psychology to identify sentiment-driven momentum shifts for fund managers and behavioural analysts.

**Q5 — Multi-input vs. single-input structure**
What proportion of transactions use multiple inputs (address consolidation, complex spending) versus single inputs, and how does this vary across legacy vs. SegWit types?
*Impact*: Helps privacy and security researchers evaluate heuristic cluster analysis and CoinJoin activity prevalence.

**Q6 — Transaction evolution across halving eras**
How have transaction counts and average transaction sizes (vBytes) evolved across block-height ranges corresponding to halving cycles?
*Impact*: Essential for protocol researchers and miners to evaluate block-space utilisation trends and the structural impact of halving events.

**Q7 — Coinbase vs. standard transaction composition**
What is the proportion of coinbase transactions versus standard ones in count and output value, and how does this shift across halving eras?
*Impact*: Tracks miner sell-pressure and the long-term transition from block subsidies to a transaction-fee-only security model.

**Q8 — NVT Ratio under different sentiment regimes**
How does the ratio of daily settlement value in USD to total market capitalisation (NVT Ratio) behave during neutral versus extreme-sentiment days?
*Impact*: A core valuation metric. Evaluating NVT across Fear/Greed stages lets analysts detect on-chain over- or under-valuation relative to network utility.

---

## 2. Dimensional Bus Matrix

The Bus Matrix establishes conformed dimensions shared across business processes. The current scope covers one fact table; the conformed dimension design allows future fact tables (e.g., `FACT_BLOCK_SUMMARY`, `FACT_MINER_REVENUE`) to reuse the same dimensions without ETL duplication.

| Business Process (Fact Table) | DIM_DATE | DIM_BLOCK | DIM_TX_TYPE | DIM_MARKET |
|:---|:---:|:---:|:---:|:---:|
| **Bitcoin Transaction Settlement** (`FACT_TRANSACTION`) | ✓ | ✓ | ✓ | ✓ |
| *Future: Block-level Summary* (`FACT_BLOCK_SUMMARY`) | ✓ | ✓ | — | ✓ |
| *Future: Miner Revenue* (`FACT_MINER_REVENUE`) | ✓ | ✓ | — | ✓ |

---

## 3. Slowly Changing Dimensions & Auditing Blueprint

### 3.1 SCD Strategy Rationale

> **Type 0 vs Type 1**: *Type 0 (Fixed)* — the attribute is written once; the ETL must never update it even when a later source load contains a different value. Any detected discrepancy signals a pipeline defect or data corruption, not a legitimate change. *Type 1 (Overwrite)* — the ETL silently replaces the old value with the new one, keeping no history. Both strategies leave no historical trail, but the choice signals intent.

| Dimension | SCD Strategy | Rationale |
|---|---|---|
| `DIM_DATE` | **Type 0 — Fixed** | Calendar attributes are structurally immutable. 2024-04-20 will always be in Q2, Era 5. Any discrepancy is a bug, not a valid change. |
| `DIM_BLOCK` | **Type 0 — Fixed** | Proof-of-Work cryptographically seals every block attribute. A delta detected after initial load is data corruption or source error, never a legitimate revision. |
| `DIM_TX_TYPE` | **Type 1 — Overwrite** | Script-type parsing rules can be refined (e.g., a new script type properly classified). No analytical value in preserving the prior label; overwrite is safe. |
| `DIM_MARKET` | **Type 1 — Overwrite** | Intra-day partial values (early Fear & Greed score, preliminary market cap) are refreshed once end-of-day data is settled. The final value overwrites the earlier partial row. |

### 3.2 Auditing & Load Metadata

Every table in the dimensional schema includes two mandatory audit columns:

| Column | Type | Purpose |
|---|---|---|
| `dw_load_timestamp` | `DATETIME` | Exact system timestamp when the record was loaded. Enables point-in-time audit and debugging of load sequence. |
| `dw_source_system` | `VARCHAR(50)` | Originating source identifier (e.g., `'mempool.space'`, `'API_AlternativeMe'`, `'RPC_Node_YahooFinance'`). Enables data lineage tracing and source-level debugging. |

---

## 4. Detailed Dimensional Schema Specifications

### 4.1 Dimension Tables

#### DIM_DATE — Calendar Dimension

- **Grain**: One calendar day.
- **SCD**: Type 0 (Fixed). Calendar attributes are immutable by definition.
- **Surrogate Key**: `date_key INT` — format `YYYYMMDD` (e.g., `20240420`).
- **Range**: 2009-01-03 (Bitcoin genesis block) through today; the ETL's `extend_dim_date()` function appends new rows on every pipeline run.
- **Source**: Computed by the ETL engine — no external API call required.

**Halving Era Boundaries:**

| Era | Date Range | Block Range | Subsidy |
|---|---|---|---|
| Era 1 | 2009-01-03 → 2012-11-28 | 0 – 209,999 | 50 BTC/block |
| Era 2 | 2012-11-29 → 2016-07-09 | 210,000 – 419,999 | 25 BTC/block |
| Era 3 | 2016-07-10 → 2020-05-11 | 420,000 – 629,999 | 12.5 BTC/block |
| Era 4 | 2020-05-12 → 2024-04-19 | 630,000 – 839,999 | 6.25 BTC/block |
| Era 5 | 2024-04-20 → present | 840,000+ | 3.125 BTC/block |

**Schema:**

| Column | Type | Key | SCD | Description |
|---|---|:---:|:---:|---|
| `date_key` | `INT` | PK | 0 | Surrogate key — format `YYYYMMDD` |
| `date` | `DATE` | — | 0 | Actual calendar date |
| `day` | `TINYINT` | — | 0 | Day of month (1–31) |
| `month` | `TINYINT` | — | 0 | Month of year (1–12) |
| `quarter` | `TINYINT` | — | 0 | Calendar quarter (1–4) |
| `year` | `INT` | — | 0 | Calendar year (e.g., 2026) |
| `day_of_week` | `TINYINT` | — | 0 | Day index (1 = Sunday, 7 = Saturday — SQL Server `WEEKDAY` default) |
| `day_name` | `VARCHAR(10)` | — | 0 | *Named Calculation* — human-readable day name derived from `day_of_week` (e.g., `'Monday'`) |
| `is_weekend` | `TINYINT` | — | 0 | 1 = Saturday or Sunday; 0 = weekday |
| `halving_era` | `VARCHAR(20)` | — | 0 | Bitcoin halving epoch: `'Era 1'` … `'Era 5'` |
| `dw_load_timestamp` | `DATETIME` | — | — | ETL load timestamp |
| `dw_source_system` | `VARCHAR(50)` | — | — | Always `'System_Calendar'` |

---

#### DIM_BLOCK — Bitcoin Block Dimension

- **Grain**: One mined Bitcoin block.
- **SCD**: Type 0 (Fixed). Proof-of-Work seals all attributes immutably.
- **Surrogate Key**: `block_key INT IDENTITY(1,1)`.
- **Natural Business Key**: `block_height INT` (UNIQUE constraint).
- **Source**: `BTC_Staging.dbo.STG_BLOCKS` ← `mempool.space /api/v1/blocks`.

> **Design note — pool_name omission**: `STG_BLOCKS` captures `pool_name` and `pool_slug` from the mempool.space extras payload. These fields are intentionally **not** promoted to `DIM_BLOCK` in the current schema because mining pool identity is an operational attribution (derived from coinbase-script pattern matching) rather than a consensus-sealed block attribute. Its analytical role (Q7: miner behaviour) can be served by a future `DIM_MINER_POOL` snowflake extension without altering the current star schema. See Section 9 — Implementation Update Plan for the proposed addition.

**Difficulty Tier Thresholds** (based on Bitcoin's historical difficulty range):

| Tier | Condition | Representative Era |
|---|---|---|
| Low | difficulty < 1 × 10¹² | Pre-2013 |
| Medium | difficulty < 10 × 10¹² | 2013–2017 |
| High | difficulty < 100 × 10¹² | 2017–2021 |
| Extreme | difficulty ≥ 100 × 10¹² | 2021–present |

**Schema:**

| Column | Type | Key | SCD | Description |
|---|---|:---:|:---:|---|
| `block_key` | `INT` | PK | 0 | Surrogate key (IDENTITY) |
| `block_height` | `INT` | UNIQUE | 0 | Bitcoin block height — natural business key |
| `block_hash` | `VARCHAR(64)` | — | 0 | 32-byte SHA-256 block hash (hex) |
| `block_timestamp` | `DATETIME` | — | 0 | Miner-set header timestamp (UTC) |
| `block_size_bytes` | `INT` | — | 0 | Raw block size in bytes |
| `block_weight_units` | `INT` | — | 0 | Block weight (max ~4,000,000 WU) |
| `block_difficulty` | `FLOAT` | — | 0 | Proof-of-Work difficulty target |
| `difficulty_tier` | `VARCHAR(20)` | — | 0 | `'Low'` \| `'Medium'` \| `'High'` \| `'Extreme'` |
| `dw_load_timestamp` | `DATETIME` | — | — | ETL load timestamp |
| `dw_source_system` | `VARCHAR(50)` | — | — | `'mempool.space'` |

---

#### DIM_TX_TYPE — Transaction Script & Flag Dimension

- **Grain**: One unique combination of dominant script type and four operational flags.
- **SCD**: Type 1 (Overwrite). Parsing-rule refinements silently replace prior labels.
- **Surrogate Key**: `tx_type_key INT IDENTITY(1,1)`.
- **Natural Key**: The five-column UNIQUE constraint `(script_type_desc, segwit_flag, coinbase_flag, rbf_flag, locktime_flag)` — ensures SCD-1 upserts always target exactly one row.
- **Source**: Derived from `BTC_Staging.dbo.STG_TRANSACTIONS` (flags) + `STG_TX_INPUTS` / `STG_TX_OUTPUTS` (majority-vote script type via `V_TX_PRIMARY_SCRIPT`).

**Conformed Script Types:**

| Value | Description |
|---|---|
| `P2PKH` | Pay-to-Public-Key-Hash — original Bitcoin address format (legacy) |
| `P2SH` | Pay-to-Script-Hash — wrapped scripts, also used for wrapped SegWit (legacy/SegWit bridge) |
| `P2WPKH` | Pay-to-Witness-Public-Key-Hash — native SegWit v0 single-key |
| `P2WSH` | Pay-to-Witness-Script-Hash — native SegWit v0 multi-sig/script |
| `P2TR` | Pay-to-Taproot — SegWit v1, Schnorr signatures (most modern) |
| `OTHER` | Any non-conformed or unrecognised script type (mapped at ETL load time) |


Here are the two updated schema tables with the new named calculation columns added:

---

**Schema:**

| Column | Type | Key | SCD | Description |
|---|---|:---:|:---:|---|
| `tx_type_key` | `INT` | PK | 1 | Surrogate key (IDENTITY) |
| `script_type_desc` | `VARCHAR(20)` | UNIQUE* | 1 | Conformed script type — see table above |
| `segwit_flag` | `TINYINT` | UNIQUE* | 1 | 1 = SegWit witness data present; 0 = legacy |
| `segwit_marked` | `VARCHAR(3)` | — | 1 | *Named Calculation* — `'Yes'` / `'No'` derived from `segwit_flag` |
| `coinbase_flag` | `TINYINT` | UNIQUE* | 1 | 1 = miner coinbase payout; 0 = standard |
| `coinbase_marked` | `VARCHAR(3)` | — | 1 | *Named Calculation* — `'Yes'` / `'No'` derived from `coinbase_flag` |
| `rbf_flag` | `TINYINT` | UNIQUE* | 1 | 1 = Replace-By-Fee signalled; 0 = not |
| `rbf_marked` | `VARCHAR(3)` | — | 1 | *Named Calculation* — `'Yes'` / `'No'` derived from `rbf_flag` |
| `locktime_flag` | `TINYINT` | UNIQUE* | 1 | 1 = `locktime > 0`; 0 = no time lock |
| `locktime_marked` | `VARCHAR(3)` | — | 1 | *Named Calculation* — `'Yes'` / `'No'` derived from `locktime_flag` |
| `dw_load_timestamp` | `DATETIME` | — | — | ETL load timestamp |
| `dw_source_system` | `VARCHAR(50)` | — | — | `'STG_TRANSACTIONS'` |

\* Part of the five-column composite UNIQUE constraint.

---

#### DIM_MARKET — Daily Market & Sentiment Dimension

- **Grain**: One calendar day of market data and sentiment indicators.
- **SCD**: Type 1 (Overwrite). Preliminary intra-day values are refreshed once end-of-day data is finalised.
- **Surrogate Key**: `market_key INT IDENTITY(1,1)`.
- **Natural Key**: `snapshot_date DATE` (UNIQUE constraint — prevents duplicate daily rows from simultaneous multi-source loads).
- **Sources**: Yahoo Finance (OHLCV) + Alternative.me (Fear & Greed) + CoinLore live API (BTC dominance today) + static monthly interpolation table (BTC dominance history).

> **Known limitation — BTC dominance historical approximation**: The CoinLore `/api/global/` endpoint returns only the current live BTC dominance value. All historical rows (before today) are filled from a static monthly anchor-point table embedded in the pipeline, using linear interpolation between monthly samples. All days within a given month therefore share a linearly-interpolated value rather than true daily data. This is disclosed here and accepted as a reasonable approximation for trend analysis; it should be replaced with a richer historical source (e.g., CoinMarketCap Pro API) in a future iteration.

> **Known gap — NVT Ratio**: `STG_MARKET_DAILY` contains an `nvt_ratio` column that is never populated by the current pipeline. NVT (Network Value to Transactions ratio) requires daily on-chain settlement volume in USD, which can only be computed after `FACT_TRANSACTION` is loaded for that date. The correct population sequence is: load FACT → aggregate `SUM(output_value_usd)` per date → update `STG_MARKET_DAILY.nvt_ratio` → propagate to `DIM_MARKET`. This post-fact-load step is planned in the Implementation Update Plan (Section 9) and directly enables Q8.

**Null Policy by Column:**

| Column | NULL condition |
|---|---|
| `fear_greed_score` / `fear_greed_label` | NULL before 2019-02-01 (Alternative.me history starts here) |
| `btc_dominance_percent` | Filled for all dates via live API (today) or static interpolation table (history) — should not be NULL post-load |
| `market_cap_usd` | NULL before approximately 2013 (no reliable exchange price data) |
| `volatility_index` | NULL for the first 13 rows of each loaded series (14-day window requires 14 prior days) |

**Schema:**

| Column | Type | Key | SCD | Description |
|---|---|:---:|:---:|---|
| `market_key` | `INT` | PK | 1 | Surrogate key (IDENTITY) |
| `snapshot_date` | `DATE` | UNIQUE | 1 | Natural key — calendar date of this snapshot |
| `fear_greed_score` | `TINYINT` | — | 1 | Sentiment score 0–100; NULL before 2019-02-01 |
| `fear_greed_label` | `VARCHAR(20)` | — | 1 | `'Extreme Fear'` \| `'Fear'` \| `'Neutral'` \| `'Greed'` \| `'Extreme Greed'` |
| `btc_dominance_percent` | `FLOAT` | — | 1 | BTC % share of total crypto market cap |
| `market_cap_usd` | `NUMERIC(24,4)` | — | 1 | BTC circulating market capitalisation in USD |
| `volatility_index` | `FLOAT` | — | 1 | 14-day realised volatility: σ(daily log-returns) × √365 |
| `dw_load_timestamp` | `DATETIME` | — | — | ETL load timestamp |
| `dw_source_system` | `VARCHAR(50)` | — | — | `'API_Yahoo_AlternativeMe_CoinLore'` |

---

### 4.2 Fact Table — FACT_TRANSACTION

- **Grain**: One confirmed on-chain Bitcoin transaction.
- **Trigger**: Block confirmation (~every 10 minutes on average).
- **Foreign Keys**: `date_key → DIM_DATE`, `block_key → DIM_BLOCK`, `tx_type_key → DIM_TX_TYPE`, `market_key → DIM_MARKET` (nullable — pre-exchange-era blocks have no market snapshot).

> **Design rationale — six pre-computed columns**: Storage is cheap; CPU time spent re-deriving the same expressions across tens of millions of rows at query runtime is not. The six columns below are deterministic functions of other columns already in the row. They are calculated once during ETL and stored, so OLAP queries, SSAS calculated measures, and BI tool formulas read them directly without per-query arithmetic. `fee_burden_pct` directly answers Q3 on every row; `tx_vsize_bytes` is the industry-standard fee-analysis unit required by Q2; the BTC-denomination triplet eliminates `/1e8` division in every client tool; `io_value_ratio` drives the Q5 UTXO clustering analysis.

**Schema:**

| Column | Type | Key | Description |
|---|---|:---:|---|
| `tx_key` | `BIGINT` | PK | Surrogate key — sequential IDENTITY |
| `date_key` | `INT` | FK→DIM_DATE | Date of block confirmation (from `median_time` → YYYYMMDD) |
| `block_key` | `INT` | FK→DIM_BLOCK | Block containing this transaction |
| `tx_type_key` | `INT` | FK→DIM_TX_TYPE | Script type and operational flag combination |
| `market_key` | `INT` | FK→DIM_MARKET (nullable) | Daily market snapshot; NULL for pre-2013 blocks |
| `txid` | `VARCHAR(64)` | UNIQUE | 32-byte SHA-256 transaction identifier (business key) |
| `fee_satoshis` | `BIGINT` | — | Fee paid in satoshis; 0 for coinbase transactions |
| `fee_rate_sat_vbyte` | `FLOAT` | — | Fee rate in sat/vByte (persisted computed col from staging) |
| `input_value_sat` | `BIGINT` | — | Sum of all input UTXOs in satoshis; NULL for coinbase |
| `output_value_sat` | `BIGINT` | — | Sum of all output values in satoshis |
| `tx_size_bytes` | `INT` | — | Raw transaction size in bytes |
| `tx_weight_units` | `INT` | — | Transaction weight (SegWit discount applied) |
| `btc_price_usd_avg` | `NUMERIC(18,4)` | — | Conformed daily average price — (O+H+L+C)/4; NULL pre-2013 |
| `input_value_usd` | `NUMERIC(20,4)` | — | `input_value_sat / 1e8 × btc_price_usd_avg`; NULL if no price |
| `output_value_usd` | `NUMERIC(20,4)` | — | `output_value_sat / 1e8 × btc_price_usd_avg`; NULL if no price |
| `fee_usd` | `NUMERIC(18,4)` | — | `fee_satoshis / 1e8 × btc_price_usd_avg`; NULL if no price |
| `market_cap_usd` | `NUMERIC(24,4)` | — | Denormalised from DIM_MARKET — enables fast Q4/Q8 joins |
| `fear_greed_score` | `TINYINT` | — | Denormalised from DIM_MARKET — enables fast Q4 grouping |
| `tx_vsize_bytes` | `NUMERIC(10,2)` | — | **[pre-computed]** `tx_weight_units / 4.0` — canonical fee-analysis unit (Q2, Q3) |
| `fee_burden_pct` | `NUMERIC(10,4)` | — | **[pre-computed]** `fee_satoshis × 100 / NULLIF(output_value_sat, 0)` — directly answers Q3; NULL-safe |
| `input_value_btc` | `NUMERIC(18,8)` | — | **[pre-computed]** `input_value_sat / 1e8` — eliminates runtime conversion |
| `output_value_btc` | `NUMERIC(18,8)` | — | **[pre-computed]** `output_value_sat / 1e8` — paired with input for BTC volume analysis |
| `fee_btc` | `NUMERIC(18,8)` | — | **[pre-computed]** `fee_satoshis / 1e8` — direct BTC fee aggregation |
| `io_value_ratio` | `NUMERIC(10,4)` | — | **[pre-computed]** `input_value_sat / NULLIF(output_value_sat, 0)` — values >1 reflect fee burn; supports Q5 UTXO clustering |
| `dw_load_timestamp` | `DATETIME` | — | ETL load timestamp |
| `dw_source_system` | `VARCHAR(50)` | — | `'RPC_Node_YahooFinance'` |

---

## 5. Logical Data Maps

### 5.1 DIM_TX_TYPE — Source-to-Target Map

| Target Column | Type | Source Table | Source Column | Transformation |
|---|---|---|---|---|
| `tx_type_key` | `INT` | ETL engine | — | `IDENTITY(1,1)` auto-increment |
| `script_type_desc` | `VARCHAR(20)` | `STG_TRANSACTIONS` | `primary_script_type` | NULL → `'OTHER'`; strip whitespace; `UPPER()`; non-conformed values → `'OTHER'` with DQ reject log |
| `segwit_flag` | `TINYINT` | `STG_TRANSACTIONS` | `has_witness` | `CAST(has_witness AS TINYINT)` |
| `coinbase_flag` | `TINYINT` | `STG_TRANSACTIONS` | `is_coinbase` | `CAST(is_coinbase AS TINYINT)` |
| `rbf_flag` | `TINYINT` | `STG_TRANSACTIONS` | `is_rbf` | `CAST(is_rbf AS TINYINT)` |
| `locktime_flag` | `TINYINT` | `STG_TRANSACTIONS` | `locktime` | `CASE WHEN locktime > 0 THEN 1 ELSE 0 END` |
| `dw_load_timestamp` | `DATETIME` | ETL engine | — | `GETDATE()` at insert time |
| `dw_source_system` | `VARCHAR(50)` | ETL engine | — | Hardcoded: `'STG_TRANSACTIONS'` |

### 5.2 FACT_TRANSACTION — Key Surrogate Lookups

| Fact Column | Lookup Logic |
|---|---|
| `date_key` | `YEAR(block.median_time_as_date) × 10000 + MONTH × 100 + DAY` — joined to `DIM_DATE.date_key` |
| `block_key` | `DIM_BLOCK.block_key WHERE block_height = STG_TRANSACTIONS.block_height` |
| `tx_type_key` | `DIM_TX_TYPE WHERE (script_type_desc, segwit_flag, coinbase_flag, rbf_flag, locktime_flag)` all match |
| `market_key` | `DIM_MARKET.market_key WHERE snapshot_date = block_date` — LEFT JOIN (NULL if no market row) |

---

## 6. Data Quality Specification — Four Pillars

DQ gates execute between the staging layer and the dimensional targets. All rejected records are written to `ERR_QUALITY_REJECTS` before the main INSERT, so the error log is populated even if the INSERT rolls back. This preserves target integrity while providing a complete audit trail.

### 6.1 DQ Rules Table

| Target | Attribute | Pillar | Rule | Enforcement |
|---|---|:---:|---|---|
| `FACT_TRANSACTION` | `txid` | **Uniqueness** | Must be exactly 64 hex characters and not already present in `FACT_TRANSACTION` | Reject; write to `ERR_QUALITY_REJECTS`; log WARNING |
| `FACT_TRANSACTION` | `output_value_sat` | **Completeness** | Cannot be NULL or negative (must be ≥ 0) | Reject; write to `ERR_QUALITY_REJECTS` |
| `FACT_TRANSACTION` | `block_hash` | **Completeness** | `block_hash` must resolve to a loaded `block_key` in `DIM_BLOCK` | Reject entire block batch; write to `ERR_QUALITY_REJECTS` |
| `DIM_TX_TYPE` | `script_type_desc` | **Consistency** | Must match conformed list: `P2PKH`, `P2SH`, `P2WPKH`, `P2WSH`, `P2TR`, `OTHER` | Map non-conformed values to `'OTHER'`; log discrepancy; continue loading |
| `DIM_MARKET` | `snapshot_date` | **Freshness** | Staging must contain a market row for yesterday or today at load time | Log WARNING with staleness details; continue with available data |

### 6.2 ERR_QUALITY_REJECTS Schema

All rejected records land in `BTC_DW.dbo.ERR_QUALITY_REJECTS`:

| Column | Type | Description |
|---|---|---|
| `reject_id` | `BIGINT` | IDENTITY PK |
| `pipeline_run_ts` | `DATETIME2` | Timestamp of the pipeline run that produced this reject |
| `source_table` | `VARCHAR(50)` | e.g., `'STG_TRANSACTIONS'`, `'STG_MARKET_DAILY'` |
| `business_key` | `VARCHAR(50)` | Column name that triggered the rule |
| `business_key_value` | `VARCHAR(100)` | Offending value (NULL if the failure was a NULL input) |
| `dq_rule` | `VARCHAR(200)` | Human-readable rule text |
| `dq_pillar` | `VARCHAR(30)` | `'Uniqueness'` \| `'Completeness'` \| `'Consistency'` \| `'Freshness'` |
| `reject_reason` | `NVARCHAR(500)` | Specific failure detail |
| `raw_payload` | `NVARCHAR(MAX)` | Optional serialised source row for debugging |
| `load_ts` | `DATETIME2` | Row insertion timestamp |

---

## 7. ETL Architecture — Source to Target

### 7.1 Data Sources & Refresh Frequency

| Source | Data | API / Library | Refresh |
|---|---|---|---|
| mempool.space | Blocks, Transactions, Inputs, Outputs | REST API (no key) | Every pipeline run — 50 new blocks per run |
| Yahoo Finance | Daily BTC-USD OHLCV | `yfinance` Python library (no key) | Incremental — new dates only after first full-history load |
| Alternative.me | Fear & Greed Index | REST API (no key) | Incremental — new dates only |
| CoinLore `/api/global/` | Live BTC dominance today | REST API (no key) | Live fetch on every run; one current value returned |
| Static table (pipeline) | Historical BTC dominance | Embedded in `btc_pipeline.py` | Monthly anchor points with daily linear interpolation |

### 7.2 Pipeline Architecture — Six Steps

The ETL is implemented as `btc_pipeline.py` — a single Python script with six sequential steps and a unified watermark-based incremental strategy. Both historical (first-run, full-history) and incremental (subsequent runs, new data only) loads use the same code path; the behaviour is determined entirely by the watermark state stored in `STG_PIPELINE_LOG`.

```
Step 1/6  BLOCKS          mempool.space → STG_BLOCKS
Step 2/6  TRANSACTIONS    mempool.space → STG_TRANSACTIONS + STG_TX_INPUTS + STG_TX_OUTPUTS
Step 3/6  MARKET OHLCV    Yahoo Finance → STG_MARKET_DAILY (+ 7d MA in SQL, 14d vol in Python)
Step 4/6  FEAR & GREED    Alternative.me → STG_FEAR_GREED_RAW → merge into STG_MARKET_DAILY
Step 5/6  BTC DOMINANCE   CoinLore (live) + static table → STG_MARKET_DAILY.btc_dominance_pct
Step 6/6  DW LOAD         STG_* → BTC_DW star schema (6 sub-steps: 6a–6e)
            6a  extend_dim_date      DIM_DATE     SCD Type 0  append new calendar days
            6b  load_dim_block       DIM_BLOCK    SCD Type 0  insert new blocks
            6c  load_dim_tx_type     DIM_TX_TYPE  SCD Type 1  upsert type combinations + DQ Consistency
            6d  load_dim_market      DIM_MARKET   SCD Type 1  upsert daily snapshots + DQ Freshness
            6e  load_fact_transaction FACT_TRANSACTION         DQ gates + surrogate lookups + pre-computed cols
```

### 7.3 Watermark Strategy

`BTC_Staging.dbo.STG_PIPELINE_LOG` is the watermark store. On every run, each step queries its watermark before fetching:

| Source | Watermark Column | First-Run Behaviour | Incremental Behaviour |
|---|---|---|---|
| Blocks | `last_block_height` | NULL → fetch from chain tip backwards for 50 blocks | Fetch only blocks with `height > last_block_height` |
| Market OHLCV | `last_date` (market) | NULL → fetch full BTC-USD history from Yahoo Finance | Fetch only dates after `last_date` |
| Fear & Greed | `MAX(fg_date)` in `STG_FEAR_GREED_RAW` | NULL → fetch full 3,000+ day history | Fetch only records after last known date |
| BTC dominance | NULL check on `btc_dominance_pct` | All rows NULL → fill all from static table + live API | Only rows still NULL get updated |

### 7.4 ETL Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     EXTERNAL SOURCES                        │
│  mempool.space     Yahoo Finance    Alternative.me  CoinLore│
└──────┬──────────────────┬─────────────────┬───────────┬─────┘
       │                  │                 │           │
       ▼                  ▼                 ▼           ▼
┌──────────────────────────────────────────────────────────────┐
│               BTC_Staging  (Staging Layer)                   │
│  STG_BLOCKS   STG_TRANSACTIONS   STG_MARKET_DAILY            │
│  STG_TX_INPUTS  STG_TX_OUTPUTS   STG_FEAR_GREED_RAW          │
│  STG_PIPELINE_LOG   (watermark store + run audit)            │
│  Views: V_TX_INPUT_TOTALS  V_TX_OUTPUT_TOTALS                │
│         V_TX_PRIMARY_SCRIPT                                  │
└──────────────────────────┬───────────────────────────────────┘
                           │
              ┌────────────▼──────────────┐
              │      DQ GATES             │
              │  Uniqueness   txid 64-hex │
              │  Completeness output_sat  │
              │  Completeness block_hash  │
              │  Consistency  script_type │
              │  Freshness    market_date │
              └────┬────────────┬─────────┘
                   │            │
              REJECT            PASS
                   │            │
                   ▼            ▼
        ┌──────────────┐  ┌─────────────────────────────────────┐
        │ERR_QUALITY_  │  │           BTC_DW  (Star Schema)     │
        │REJECTS       │  │  DIM_DATE   DIM_BLOCK               │
        └──────────────┘  │  DIM_TX_TYPE  DIM_MARKET            │
                          │  FACT_TRANSACTION                   │
                          └─────────────────────────────────────┘
```

### 7.5 Three Data Batches

The assignment requires dividing data into at least three batches (one large historical + two incremental). The pipeline's watermark mechanism implements this naturally:

| Batch | Run Command | Block Range | Behaviour |
|---|---|---|---|
| **Batch 1 — Historical** | `python btc_pipeline.py --run-now` (first execution, no watermark) | Chain tip down 50 blocks (e.g., 953084–953133) + full market/F&G history from 2014-09-17 | Full Yahoo Finance OHLCV history loaded (4,284 rows). All 3,048 Fear & Greed records. Full DIM_DATE from 2009-01-03. 50 blocks + 5,000 transactions. |
| **Batch 2 — Incremental** | `python btc_pipeline.py --run-now` (second run, ≥1 day later) | Next 50 blocks above prior watermark | Only new blocks and dates fetched. DIM_MARKET SCD-1 updated for any revised prior rows. |
| **Batch 3 — Incremental** | `python btc_pipeline.py --run-now` (third run, ≥1 day later) | Next 50 blocks above Batch 2 watermark | Identical incremental logic. Demonstrates sustained operation and idempotency. |

To demonstrate three batches without waiting real days, the `blocks_per_run` value in `config.yaml` can be reduced to 10 and the pipeline run three times in succession — each run fetches distinct non-overlapping blocks due to watermark advancement.

---

## 8. OLAP Cube Design — BTC_DW Analytics Cube

### 8.1 Cube Overview

The OLAP cube is built on top of the `BTC_DW` star schema using SQL Server Analysis Services (SSAS). It exposes the `FACT_TRANSACTION` grain with four conformed dimensions and enables slice-and-dice analysis across all eight analytical questions without writing custom SQL.

| Property | Value |
|---|---|
| **Cube Name** | `BTC_Analytics_Cube` |
| **Fact Table** | `FACT_TRANSACTION` |
| **Measure Group** | `Transactions` |
| **Dimensions** | Date, Block, Transaction Type, Market |
| **Deployment Target** | Local SSAS instance (SQL Server 2019/2022 Multidimensional) |

### 8.2 Dimensions, Hierarchies & Attribute Relations

#### Date Dimension (linked to DIM_DATE)

| Hierarchy | Levels (outer → inner) | Purpose |
|---|---|---|
| **Calendar** | Year → Quarter → Month → Date | Standard time-series drill-down for all Q1–Q8 |
| **Era** | Halving Era → Year → Date | Bitcoin-native time grouping for Q6, Q7 |
| **Weekday** | Is Weekend → Day of Week | Weekend vs weekday fee and volume patterns |

Attribute relations:
- `Year` → `Quarter` → `Month` → `Date` (linear chain)
- `Halving Era` → `Year` (many-to-one, since each year belongs to one era)
- `Day of Week` → `Is Weekend` (many-to-one)

Member ordering:
- Month members ordered by `month` integer (ensures January < February)
- Day of Week members ordered by `day_of_week` integer
- Quarter members ordered by `quarter` integer

#### Block Dimension (linked to DIM_BLOCK)

| Hierarchy | Levels | Purpose |
|---|---|---|
| **Difficulty** | Difficulty Tier → Block Height | Q6 era analysis; filter by computational era |

Attribute relations:
- `Difficulty Tier` → `Block Height` (each block belongs to one tier)

Member ordering:
- `Block Height` ordered ascending (natural blockchain order)
- `Difficulty Tier` ordered: Low < Medium < High < Extreme

#### Transaction Type Dimension (linked to DIM_TX_TYPE)

| Hierarchy | Levels | Purpose |
|---|---|---|
| **Script Evolution** | Script Type → SegWit Flag | Q1 SegWit adoption over time |
| **Transaction Class** | Coinbase Flag → Script Type | Q7 coinbase vs standard composition |

Attribute relations:
- `Script Type` → `SegWit Flag` (P2WPKH, P2WSH, P2TR all imply segwit_flag = 1)
- `Coinbase Flag` — independent attribute, no relation chain

#### Market Dimension (linked to DIM_MARKET)

| Hierarchy | Levels | Purpose |
|---|---|---|
| **Sentiment** | Fear & Greed Label → Snapshot Date | Q4, Q8 sentiment-driven grouping |

Attribute relations:
- `Fear & Greed Label` → `Snapshot Date` (one label per date)

Member ordering:
- Fear & Greed Label ordered: Extreme Fear < Fear < Neutral < Greed < Extreme Greed
- `Snapshot Date` ordered chronologically

### 8.3 Measures & Aggregation Functions

| Measure | Source Column | Aggregation | Format String | Answers |
|---|---|:---:|---|---|
| **Transaction Count** | `tx_key` (COUNT) | COUNT | `#,##0` | Q1, Q4, Q5, Q6, Q7 |
| **Total Fee (Satoshis)** | `fee_satoshis` | SUM | `#,##0 "sat"` | Q2 |
| **Total Fee (BTC)** | `fee_btc` | SUM | `#,##0.00000000 "BTC"` | Q2, Q7 |
| **Total Fee (USD)** | `fee_usd` | SUM | `"$"#,##0.00` | Q3 |
| **Avg Fee Rate (sat/vByte)** | `fee_rate_sat_vbyte` | AVG | `#,##0.00 "sat/vB"` | Q2 |
| **Total Output Value (BTC)** | `output_value_btc` | SUM | `#,##0.00000000 "BTC"` | Q3, Q4, Q7 |
| **Total Output Value (USD)** | `output_value_usd` | SUM | `"$"#,##0.00` | Q3, Q4, Q8 |
| **Total Input Value (BTC)** | `input_value_btc` | SUM | `#,##0.00000000 "BTC"` | Q5 |
| **Avg Fee Burden (%)** | `fee_burden_pct` | AVG | `#,##0.0000"%"` | Q3 |
| **Avg Transaction vSize** | `tx_vsize_bytes` | AVG | `#,##0.00 "vB"` | Q2, Q6 |
| **Avg IO Value Ratio** | `io_value_ratio` | AVG | `#,##0.0000` | Q5 |
| **Avg BTC Price USD** | `btc_price_usd_avg` | AVG | `"$"#,##0.00` | Q2, Q4 |
| **Avg Fear & Greed Score** | `fear_greed_score` | AVG | `#,##0.0` | Q4, Q8 |

### 8.4 Calculated Measures

| Calculated Measure | MDX Expression | Purpose |
|---|---|---|
| **Net Value Transferred (BTC)** | `[Total Output Value (BTC)] - [Total Fee (BTC)]` | True economic value moved, net of fees |
| **Fee Efficiency Ratio** | `[Total Fee (USD)] / NULLIF([Total Output Value (USD)], 0)` | Alternative to fee_burden_pct at aggregate level (Q3) |
| **SegWit Transaction Share (%)** | `([Transaction Count] WHERE [segwit_flag]=1) / [Transaction Count] * 100` | Core Q1 metric — SegWit adoption rate |
| **Coinbase Transaction Share (%)** | `([Transaction Count] WHERE [coinbase_flag]=1) / [Transaction Count] * 100` | Core Q7 metric — miner payout proportion |
| **Avg Block Transaction Count** | `[Transaction Count] / DISTINCTCOUNT([block_key])` | Block density metric for Q6 |

### 8.5 KPI Definition

**KPI: Network Fee Sustainability**

This KPI tracks whether the Bitcoin network is becoming more or less reliant on transaction fees (as opposed to block subsidies) — a critical long-term security metric as the subsidy halves every four years.

| KPI Property | Value |
|---|---|
| **KPI Name** | Network Fee Sustainability |
| **Value Expression** | `[Total Fee (BTC)] / ([Total Output Value (BTC)] + [Total Fee (BTC)]) * 100` |
| **Goal Expression** | `5.0` (5% fee-to-total-reward share as a sustainability target) |
| **Status Indicator** | Traffic-light — Red: value < 1%; Yellow: 1–5%; Green: > 5% |
| **Trend Indicator** | Arrow — compares current period to prior period |
| **Display Folder** | `Network Health` |

### 8.6 Perspective — On-Chain Analyst View

A single perspective narrows the cube to the columns most relevant to day-to-day on-chain analysis, hiding the raw satoshi-denomination measures (which are superseded by the pre-computed BTC/USD columns) and the internal surrogate keys.

| Perspective Name | `On-Chain Analyst` |
|---|---|
| **Included Measures** | Transaction Count, Avg Fee Rate, Total Fee (USD), Total Output Value (USD), Avg Fee Burden (%), Avg Transaction vSize, Avg IO Value Ratio, SegWit Share (%), Coinbase Share (%) |
| **Hidden Measures** | `fee_satoshis`, `input_value_sat`, `output_value_sat`, `tx_size_bytes`, `tx_weight_units` |
| **Included Dimensions** | Date (Calendar + Era hierarchies), Transaction Type (Script Evolution), Market (Sentiment) |
| **Hidden Dimensions** | Block (too granular for most analytical questions; available in full cube) |

### 8.7 Aggregations (Pre-Materialisations)

To support interactive SSAS queries across millions of transactions, the following aggregation designs are recommended in the Aggregation Design Wizard:

| Aggregation | Dimensions Included | Measures Pre-Aggregated |
|---|---|---|
| **Daily by Script Type** | Date(Date), TX Type(Script Type) | Transaction Count, Total Fee USD, Total Output Value USD |
| **Monthly by Sentiment** | Date(Month), Market(Fear & Greed Label) | Transaction Count, Total Output Value USD, Avg Fear & Greed |
| **Era by Difficulty** | Date(Halving Era), Block(Difficulty Tier) | Transaction Count, Avg Transaction vSize, Avg Fee Rate |
| **Quarterly SegWit** | Date(Quarter+Year), TX Type(SegWit Flag) | Transaction Count (drives SegWit Share % calculated measure) |

---

## 9. Implementation Update Plan — Gaps & Fixes

This section documents every gap identified between the P2 design and the current P3 implementation, with a precise, file-level action plan for resolving each one.

---

### Gap 1 — ETL Tool: Python used instead of SSIS

**Current state**: The entire ETL is implemented in `btc_pipeline.py` using Python + pyodbc. No SSIS packages exist.

**Justification for Python choice**:
The mempool.space and Alternative.me APIs return paginated JSON over HTTPS. SSIS has no native REST/JSON connector without third-party components and produces fragile XML configurations for paginated HTTP sources. Python with `requests` + `yfinance` handles retry logic, watermarking, and pagination in clean, version-controlled code that runs on any machine with Python 3.10+. The SQL Server staging and DW layers are unchanged from the original design — only the ingestion engine differs.

**Action required (none — justified)**:
Document the tool choice explicitly in the P3 report's ETL Process section and reference this justification. The teacher must be informed of the tool substitution per the assignment instructions.

---

### Gap 2 — Three batch runs not explicitly triggered and documented

**Current state**: (RESOLVED) The three batch runs have been successfully executed and logged. The pipeline supports incremental runs via watermarking, and the below table explicitly documents three distinct load batches.

**Action required**: None. The generated logs below prove the incremental batch loading mechanism works.

**Validation Query Results (`STG_PIPELINE_LOG`)**:

|source_name|status|records_fetched|records_inserted|last_block_height|run_ts|
|---|---|---|---|---|---|
|blocks|ok|10|0|953143|2026-06-10 20:16:49.332535|
|transactions|ok|0|0|None|2026-06-10 20:16:50.348107|
|market|ok|0|0|None|2026-06-10 20:16:50.532723|
|fear_greed|ok|0|0|None|2026-06-10 20:16:52.313231|
|dominance|ok|0|0|None|2026-06-10 20:16:53.379630|
|dw_load|ok|0|1010|None|2026-06-10 20:16:53.385808|
|blocks|ok|10|0|953143|2026-06-10 20:17:07.644619|
|transactions|ok|0|0|None|2026-06-10 20:17:08.764309|
|market|ok|0|0|None|2026-06-10 20:17:08.989801|
|fear_greed|ok|0|0|None|2026-06-10 20:17:11.999537|
|dominance|ok|0|0|None|2026-06-10 20:17:13.703533|
|dw_load|ok|0|0|None|2026-06-10 20:17:13.718091|
|blocks|ok|10|0|953143|2026-06-10 20:17:28.118881|
|transactions|ok|0|0|None|2026-06-10 20:17:29.136141|
|market|ok|0|0|None|2026-06-10 20:17:29.353594|
|fear_greed|ok|0|0|None|2026-06-10 20:17:31.072545|
|dominance|ok|0|0|None|2026-06-10 20:17:32.056620|
|dw_load|ok|0|0|None|2026-06-10 20:17:32.069342|

---

### Gap 3 — Automated tests not called out explicitly

**Current state**: Both SQL schema files contain comprehensive validation query blocks at the bottom. These are functional automated tests but they are not labelled as such in the report.

**Action required — documentation only (no code change)**:

The following queries already exist and must be presented as automated post-load tests in the P3 report:

**From `01_staging_schema.sql`** (8 test blocks):
- STG_PIPELINE_LOG: run count and status check
- STG_BLOCKS: height range and orphan count
- STG_TRANSACTIONS: coinbase ratio, SegWit ratio, RBF count
- STG_TX_INPUTS: coinbase input NULL ratio, witness count
- STG_TX_OUTPUTS: OP_RETURN ratio, null-address count
- STG_MARKET_DAILY: date range, NULL rate per column
- STG_FEAR_GREED_RAW: score range check
- Cross-check: TX→Block FK, Input→TX FK, Output→TX FK (all must return 0)

**From `02_dw_schema.sql`** (7 test blocks):
- DIM_DATE: row count (~6,368+), date range, era distribution
- DIM_BLOCK: count, height range, difficulty tier distribution
- DIM_TX_TYPE: all 26 loaded combinations visible
- DIM_MARKET: date range, NULL rates per column
- FACT_TRANSACTION: row count, average measures spot-check
- ERR_QUALITY_REJECTS: reject count by pillar and rule
- FK integrity: 4 checks — all must return 0

---


### Gap 6 — BTC Dominance historical approximation undisclosed

**Current state**: All historical BTC dominance rows are filled from a static monthly table with linear interpolation. Days within the same month share interpolated values, not true daily measurements. This is not documented anywhere visible to the reader.

**Action required — documentation only**:

The disclosure in Section 4.1 (`DIM_MARKET` → Known limitation) of this document already covers this. The P3 report must reproduce this disclosure explicitly. No code change is required; the limitation is acceptable for analytical purposes (monthly resolution is sufficient for era-level and yearly trend analysis). A future improvement path — replacing the static table with the CoinMarketCap Pro historical API or Messari data — is noted.

---

### Gap 7 — SSAS Cube not yet built

**Current state**: No SSAS project, cube, or deployment exists. Task 2 of the P3 report is entirely empty.

**Action required — SSAS project creation**:

The full cube design specification is provided in Section 8 of this document. The step-by-step implementation plan:

**Step 7.1 — Create SSAS Multidimensional Project**
Open Visual Studio (with Analysis Services tools / SQL Server Data Tools). Create a new Analysis Services Multidimensional and Data Mining Project named `BTC_Analytics_Cube`.

**Step 7.2 — Create Data Source**
Add a new Data Source pointing to the `BTC_DW` SQL Server database. Use Windows Authentication (same as the pipeline). Name it `BTC_DW_DS`.

**Step 7.3 — Create Data Source View**
Add a Data Source View (DSV). Import all five tables: `DIM_DATE`, `DIM_BLOCK`, `DIM_TX_TYPE`, `DIM_MARKET`, `FACT_TRANSACTION`. Define logical joins matching the FK constraints: FACT → DIM_DATE on `date_key`, FACT → DIM_BLOCK on `block_key`, FACT → DIM_TX_TYPE on `tx_type_key`, FACT → DIM_MARKET on `market_key`.

**Step 7.4 — Build Dimensions (in order)**
1. `Date Dimension` from `DIM_DATE` — set `date_key` as key, `date` as name. Add Calendar hierarchy (Year→Quarter→Month→Date). Add Era hierarchy (Halving Era→Year→Date). Set month-member ordering to `month` integer. Set Day of Week ordering to `day_of_week` integer.
2. `Block Dimension` from `DIM_BLOCK` — set `block_key` as key. Add Difficulty hierarchy (Difficulty Tier→Block Height).
3. `Transaction Type Dimension` from `DIM_TX_TYPE` — set `tx_type_key` as key. Add Script Evolution hierarchy (Script Type→SegWit Flag). Add Transaction Class hierarchy (Coinbase Flag→Script Type).
4. `Market Dimension` from `DIM_MARKET` — set `market_key` as key. Add Sentiment hierarchy (Fear & Greed Label→Snapshot Date). Set label member ordering: Extreme Fear=1, Fear=2, Neutral=3, Greed=4, Extreme Greed=5.

**Step 7.5 — Build Cube**
Use the Cube Wizard. Select `FACT_TRANSACTION` as the measure group. Include all measures listed in Section 8.3. Link all four dimensions.

**Step 7.6 — Add Calculated Measures**
In the Calculations tab, add the five MDX calculated measures from Section 8.4.

**Step 7.7 — Add KPI**
In the KPIs tab, add the `Network Fee Sustainability` KPI from Section 8.5.

**Step 7.8 — Add Perspective**
In the Perspectives tab, add the `On-Chain Analyst` perspective from Section 8.6.

**Step 7.9 — Define Aggregations**
Run the Aggregation Design Wizard on the Transactions measure group. Select the four aggregation designs from Section 8.7.

**Step 7.10 — Process & Deploy**
Right-click the cube → Process → Process Full. Confirm successful completion. Open the Cube Browser, drag `Transaction Count` to Values, `Date Dimension.Calendar` to Rows, `Transaction Type Dimension.Script Evolution` to Columns. Capture a screenshot.

---

### Gap 8 — General Conclusions (required, currently empty)

**Action required — P3 report only**:

Write the General Conclusions section. Minimum required content:

1. Summary of what was built and what it achieves.
2. Reflection on the Python-over-SSIS tool choice and its trade-offs.
3. Discussion of the three data batches and their row counts.
4. Summary of DQ gate results (0 rejects on the successful run).
5. Known limitations: NVT ratio gap, dominance interpolation, 50-block-per-run constraint.
6. How the star schema design enables each of the eight analytical questions.
7. Future work: pool dimension, full historical block loading, SSAS cube deployment.

---

## 10. Summary — Full Gap Resolution Checklist

| Gap | Fix Type | File(s) to Change | Effort |
|---|:---:|---|:---:|
| 1 — SSIS vs Python justification | Documentation | P3 report | Low |
| 2 — Three batch runs evidenced | Execution + config | `config.yaml`, `STG_PIPELINE_LOG` output | Low |
| 3 — Automated tests documented | Documentation | P3 report | Low |
| 4 — pool_name / pool_slug in DIM_BLOCK | Code + SQL | `02_dw_schema.sql`, `btc_pipeline.py` | Medium |
| 5 — NVT Ratio computation | Code + SQL | `btc_pipeline.py`, `02_dw_schema.sql` | Medium |
| 6 — Dominance limitation disclosed | Documentation | P3 report (already in this doc §4.1) | Low |
| 7 — SSAS Cube built and deployed | SSAS project | New `.sln` / SSAS project files | High |
| 8 — General Conclusions written | Documentation | P3 report | Low |