-- =============================================================================
-- BTC_DW — DATA WAREHOUSE TARGET SCHEMA
-- File    : 02_dw_schema.sql
-- Design  : BTC_DW_Dimensional_Design_P2.md  §4 (Schema) + §6 (DQ)
-- =============================================================================
-- Run order : AFTER 01_staging_schema.sql and at least one btc_pipeline.py run
--             so that BTC_Staging is populated and cross-DB references resolve.
-- Idempotent: every object creation is guarded by IF OBJECT_ID … IS NULL,
--             so the script can be re-run safely without dropping existing data.
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Create the Data Warehouse database
-- -----------------------------------------------------------------------------
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BTC_DW')
BEGIN
    CREATE DATABASE BTC_DW COLLATE Latin1_General_CI_AS;
    PRINT 'Database BTC_DW created.';
END
ELSE
    PRINT 'Database BTC_DW already exists — skipping creation.';
GO

USE BTC_DW;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- =============================================================================
-- 1. DIM_DATE  —  Calendar dimension
-- =============================================================================
-- Grain    : One calendar day
-- SCD Type : 0 (Fixed) — calendar attributes are structurally immutable.
--            ETL must never update existing rows; a detected discrepancy
--            signals a pipeline defect, not a legitimate change.
-- Key      : date_key INT  format YYYYMMDD  (e.g. 20240419)
-- Range    : 2009-01-03 (Bitcoin genesis) through today; the pipeline's
--            extend_dim_date() function adds new dates on every run.
-- Halving era boundaries (approximate confirmed block-header dates):
--   Era 1 : genesis       to 2012-11-28  (blocks       0 – 209 999)
--   Era 2 : 2012-11-29    to 2016-07-09  (blocks 210 000 – 419 999)
--   Era 3 : 2016-07-10    to 2020-05-11  (blocks 420 000 – 629 999)
--   Era 4 : 2020-05-12    to 2024-04-19  (blocks 630 000 – 839 999)
--   Era 5 : 2024-04-20    to present     (blocks 840 000 +)
-- =============================================================================
IF OBJECT_ID('dbo.DIM_DATE', 'U') IS NULL
CREATE TABLE dbo.DIM_DATE (
    date_key          INT          NOT NULL,   -- YYYYMMDD surrogate key
    [date]            DATE         NOT NULL,
    [day]             TINYINT      NOT NULL,   -- 1–31
    [month]           TINYINT      NOT NULL,   -- 1–12
    quarter           TINYINT      NOT NULL,   -- 1–4
    [year]            INT          NOT NULL,
    day_of_week       TINYINT      NOT NULL,   -- 1=Sunday … 7=Saturday (SQL Server WEEKDAY default)
    is_weekend        TINYINT      NOT NULL,   -- 1 = Saturday or Sunday, 0 = weekday
    halving_era       VARCHAR(20)  NOT NULL,   -- 'Era 1' | 'Era 2' | … | 'Era 5'
    dw_load_timestamp DATETIME     NOT NULL,
    dw_source_system  VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_DIM_DATE PRIMARY KEY (date_key)
);
GO
PRINT 'DIM_DATE table ready.';
GO

-- -----------------------------------------------------------------------------
-- Initial population  —  2009-01-03 through today
-- extend_dim_date() in btc_pipeline.py keeps this up to date on every run.
-- -----------------------------------------------------------------------------
DECLARE @d   DATE        = '2009-01-03';
DECLARE @end DATE        = CAST(GETDATE() AS DATE);
DECLARE @key INT;
DECLARE @era VARCHAR(20);

WHILE @d <= @end
BEGIN
    SET @key = YEAR(@d) * 10000 + MONTH(@d) * 100 + DAY(@d);
    SET @era = CASE
        WHEN @d <= '2012-11-28' THEN 'Era 1'
        WHEN @d <= '2016-07-09' THEN 'Era 2'
        WHEN @d <= '2020-05-11' THEN 'Era 3'
        WHEN @d <= '2024-04-19' THEN 'Era 4'
        ELSE                         'Era 5'
    END;

    IF NOT EXISTS (SELECT 1 FROM dbo.DIM_DATE WHERE date_key = @key)
        INSERT INTO dbo.DIM_DATE (
            date_key, [date], [day], [month], quarter, [year],
            day_of_week, is_weekend, halving_era,
            dw_load_timestamp, dw_source_system
        )
        VALUES (
            @key, @d,
            DAY(@d), MONTH(@d), DATEPART(QUARTER, @d), YEAR(@d),
            DATEPART(WEEKDAY, @d),
            CASE WHEN DATEPART(WEEKDAY, @d) IN (1, 7) THEN 1 ELSE 0 END,
            @era,
            GETDATE(), 'System_Calendar'
        );

    SET @d = DATEADD(DAY, 1, @d);
END
GO
PRINT 'DIM_DATE initial population complete.';
GO

-- =============================================================================
-- 2. DIM_BLOCK  —  Bitcoin block dimension
-- =============================================================================
-- Grain    : One mined Bitcoin block
-- SCD Type : 0 (Fixed) — Proof-of-Work cryptographically seals every
--            block attribute; any detected delta is data corruption, not change.
-- Key      : block_key  INT IDENTITY(1,1)
-- NK       : block_height  (UNIQUE constraint enforced)
-- Difficulty tier thresholds (based on Bitcoin's historical difficulty range):
--   Low     : difficulty <  1 T  (10^12)   — pre-2013 era
--   Medium  : difficulty < 10 T  (10^13)   — 2013–2017 era
--   High    : difficulty < 100 T (10^14)   — 2017–2021 era
--   Extreme : difficulty >= 100 T           — 2021 – present
-- =============================================================================
IF OBJECT_ID('dbo.DIM_BLOCK', 'U') IS NULL
CREATE TABLE dbo.DIM_BLOCK (
    block_key          INT          NOT NULL IDENTITY(1,1),
    block_height       INT          NOT NULL,   -- natural business key
    block_hash         VARCHAR(64)  NOT NULL,   -- 32-byte SHA-256 hex
    block_timestamp    DATETIME     NOT NULL,   -- miner-set header timestamp (UTC)
    block_size_bytes   INT          NOT NULL,
    block_weight_units INT          NOT NULL,   -- max ~4 000 000 WU per block
    block_difficulty   FLOAT        NOT NULL,
    difficulty_tier    VARCHAR(20)  NOT NULL,   -- Low | Medium | High | Extreme
    pool_name          VARCHAR(100) NULL,       -- Mining pool name (e.g., 'Foundry USA', 'AntPool')
    pool_slug          VARCHAR(100) NULL,       -- URL-safe pool identifier (e.g., 'foundryusa')
    dw_load_timestamp  DATETIME     NOT NULL,
    dw_source_system   VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_DIM_BLOCK        PRIMARY KEY (block_key),
    CONSTRAINT UQ_DIM_BLOCK_height UNIQUE      (block_height)
);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_DIM_BLOCK_hash' AND object_id = OBJECT_ID('dbo.DIM_BLOCK')
)
    CREATE INDEX IX_DIM_BLOCK_hash ON dbo.DIM_BLOCK (block_hash);
GO
PRINT 'DIM_BLOCK ready.';
GO

-- =============================================================================
-- 3. DIM_TX_TYPE  —  Transaction script & flag dimension
-- =============================================================================
-- Grain    : Unique combination of dominant script type + 4 operational flags
-- SCD Type : 1 (Overwrite) — parsing-rule refinements silently replace prior
--            labels; no analytical need to preserve the old classification.
-- Key      : tx_type_key  INT IDENTITY(1,1)
-- NK       : the five-column UNIQUE constraint (script_type_desc + 4 flags)
--            ensures SCD-1 upserts always target exactly one existing row.
-- Conformed script types: P2PKH | P2SH | P2WPKH | P2WSH | P2TR | OTHER
--   Any non-conformed value from staging (e.g. 'UNKNOWN', 'op_return') is
--   mapped to 'OTHER' by the ETL and logged in ERR_QUALITY_REJECTS.
-- =============================================================================
IF OBJECT_ID('dbo.DIM_TX_TYPE', 'U') IS NULL
CREATE TABLE dbo.DIM_TX_TYPE (
    tx_type_key       INT          NOT NULL IDENTITY(1,1),
    script_type_desc  VARCHAR(20)  NOT NULL,   -- P2PKH|P2SH|P2WPKH|P2WSH|P2TR|OTHER
    segwit_flag       TINYINT      NOT NULL,   -- 1 = SegWit witness present, 0 = Legacy
    coinbase_flag     TINYINT      NOT NULL,   -- 1 = miner coinbase payout, 0 = standard
    rbf_flag          TINYINT      NOT NULL,   -- 1 = Replace-By-Fee signalled
    locktime_flag     TINYINT      NOT NULL,   -- 1 = locktime > 0
    dw_load_timestamp DATETIME     NOT NULL,
    dw_source_system  VARCHAR(50)  NOT NULL,

    CONSTRAINT PK_DIM_TX_TYPE       PRIMARY KEY (tx_type_key),
    CONSTRAINT UQ_DIM_TX_TYPE_combo UNIQUE (
        script_type_desc, segwit_flag, coinbase_flag, rbf_flag, locktime_flag
    )
);
GO
PRINT 'DIM_TX_TYPE ready.';
GO

-- =============================================================================
-- 4. DIM_MARKET  —  Daily macro market & sentiment snapshot
-- =============================================================================
-- Grain    : One calendar day of market + sentiment data
-- SCD Type : 1 (Overwrite) — preliminary intra-day values (early Fear & Greed
--            score, partial market cap) are refreshed when end-of-day data
--            becomes available; the final value overwrites the earlier partial.
-- Key      : market_key  INT IDENTITY(1,1)
-- NK       : snapshot_date  (UNIQUE constraint prevents duplicate daily rows;
--            at most one market snapshot can exist per calendar date because all
--            signals are defined as single daily values — a second row would be
--            logically inconsistent and would distort any fact-table aggregation).
-- =============================================================================
IF OBJECT_ID('dbo.DIM_MARKET', 'U') IS NULL
CREATE TABLE dbo.DIM_MARKET (
    market_key             INT             NOT NULL IDENTITY(1,1),
    snapshot_date          DATE            NOT NULL,   -- natural business key
    date_key               INT             NULL,       -- FK to DIM_DATE; enables calendar-hierarchy slicing in SSAS/Power BI
    fear_greed_score       TINYINT         NULL,       -- 0–100; NULL before 2019-02-01
    fear_greed_label       VARCHAR(20)     NULL,       -- Extreme Fear|Fear|Neutral|Greed|Extreme Greed
    btc_dominance_percent  FLOAT           NULL,       -- BTC % share of total crypto market cap
    market_cap_usd         NUMERIC(24,4)   NULL,       -- BTC circulating market cap in USD
    volatility_index       FLOAT           NULL,       -- 14-day realised volatility (stddev×√365)
    nvt_ratio              NUMERIC(10,4)   NULL,
    dw_load_timestamp      DATETIME        NOT NULL,
    dw_source_system       VARCHAR(50)     NOT NULL,

    CONSTRAINT PK_DIM_MARKET      PRIMARY KEY (market_key),
    CONSTRAINT UQ_DIM_MARKET_date UNIQUE      (snapshot_date),
    CONSTRAINT FK_DIM_MARKET_DATE FOREIGN KEY (date_key) REFERENCES dbo.DIM_DATE (date_key)
);
GO
PRINT 'DIM_MARKET ready.';
GO

-- Idempotent patch for already-deployed instances created before date_key existed:
-- adds the column + FK if missing, then backfills it from snapshot_date.
IF COL_LENGTH('dbo.DIM_MARKET', 'date_key') IS NULL
BEGIN
    ALTER TABLE dbo.DIM_MARKET ADD date_key INT NULL;

    UPDATE dbo.DIM_MARKET
    SET date_key = YEAR(snapshot_date) * 10000
                  + MONTH(snapshot_date) * 100
                  + DAY(snapshot_date);

    ALTER TABLE dbo.DIM_MARKET
        ADD CONSTRAINT FK_DIM_MARKET_DATE FOREIGN KEY (date_key) REFERENCES dbo.DIM_DATE (date_key);

    PRINT 'DIM_MARKET: date_key column + FK added and backfilled.';
END
GO

-- =============================================================================
-- 5. FACT_TRANSACTION  —  Central fact table
-- =============================================================================
-- Grain    : One confirmed on-chain Bitcoin transaction
-- Trigger  : Block confirmation (~every 10 minutes)
-- FKs      : date_key → DIM_DATE, block_key → DIM_BLOCK,
--            tx_type_key → DIM_TX_TYPE, market_key → DIM_MARKET (nullable:
--            early pre-market blocks have no matching market snapshot)
--
-- Pre-computed columns (Design §4.2 rationale):
--   Storage is cheap; recomputing these across 50M+ rows at query runtime is not.
--   Each is a deterministic function of other columns in the same row; they are
--   computed once during ETL and stored so OLAP queries, SSAS calculated
--   members, and Tableau/Power BI formulas read them directly.
--
--   tx_vsize_bytes   = tx_weight_units / 4.0
--                      Canonical fee-analysis unit; avoids repeated division (Q2, Q3).
--   fee_burden_pct   = fee_satoshis * 100.0 / NULLIF(output_value_sat, 0)
--                      Directly answers Q3; NULL-safe via NULLIF for zero-output TXs.
--   input_value_btc  = input_value_sat / 1e8
--   output_value_btc = output_value_sat / 1e8
--   fee_btc          = fee_satoshis / 1e8
--                      Eliminates per-query /1e8 in Tableau / SSAS calculated members.
--   io_value_ratio   = input_value_sat / NULLIF(output_value_sat, 0)
--                      Values > 1 reflect fee burn; supports Q5 UTXO cluster analysis.
-- =============================================================================
IF OBJECT_ID('dbo.FACT_TRANSACTION', 'U') IS NULL
CREATE TABLE dbo.FACT_TRANSACTION (
    -- Surrogate primary key (loaded sequentially)
    tx_key               BIGINT          NOT NULL IDENTITY(1,1),

    -- Foreign keys to conformed dimensions
    date_key             INT             NOT NULL,
    block_key            INT             NOT NULL,
    tx_type_key          INT             NOT NULL,
    market_key           INT             NULL,          -- NULL for pre-exchange-data blocks

    -- Business key
    txid                 VARCHAR(64)     NOT NULL,      -- 32-byte SHA-256 TX identifier

    -- Raw on-chain measures
    fee_satoshis         BIGINT          NOT NULL,      -- 0 for coinbase transactions
    fee_rate_sat_vbyte   FLOAT           NULL,          -- persisted computed col from staging
    input_value_sat      BIGINT          NULL,          -- NULL for coinbase (no UTXO spent)
    output_value_sat     BIGINT          NOT NULL,
    tx_size_bytes        INT             NOT NULL,
    tx_weight_units      INT             NOT NULL,

    -- Conformed daily average Bitcoin price (USD)
    btc_price_usd_avg    NUMERIC(18,4)   NULL,          -- NULL for pre-2013 blocks

    -- Fiat-converted measures  (ETL: sat / 1e8 × btc_price_usd_avg)
    input_value_usd      NUMERIC(20,4)   NULL,
    output_value_usd     NUMERIC(20,4)   NULL,
    fee_usd              NUMERIC(18,4)   NULL,

    -- Denormalised macro correlation columns (from DIM_MARKET, for fast Q4/Q8 queries)
    market_cap_usd       NUMERIC(24,4)   NULL,
    fear_greed_score     TINYINT         NULL,

    -- [pre-computed]  tx_vsize_bytes  =  tx_weight_units / 4.0
    tx_vsize_bytes       NUMERIC(10,2)   NULL,
    -- [pre-computed]  fee_burden_pct  =  fee_sat * 100 / NULLIF(output_sat, 0)
    fee_burden_pct       NUMERIC(10,4)   NULL,
    -- [pre-computed]  input_value_btc =  input_value_sat / 1e8
    input_value_btc      NUMERIC(18,8)   NULL,
    -- [pre-computed]  output_value_btc = output_value_sat / 1e8
    output_value_btc     NUMERIC(18,8)   NULL,
    -- [pre-computed]  fee_btc          = fee_satoshis / 1e8
    fee_btc              NUMERIC(18,8)   NULL,
    -- [pre-computed]  io_value_ratio   = input_sat / NULLIF(output_sat, 0)
    io_value_ratio       NUMERIC(10,4)   NULL,

    -- Audit columns (SCD note: fact rows are INSERT-only; no updates after load)
    dw_load_timestamp    DATETIME        NOT NULL,
    dw_source_system     VARCHAR(50)     NOT NULL,

    CONSTRAINT PK_FACT_TRANSACTION  PRIMARY KEY (tx_key),
    CONSTRAINT UQ_FACT_TX_txid      UNIQUE      (txid),
    CONSTRAINT FK_FACT_DATE         FOREIGN KEY (date_key)     REFERENCES dbo.DIM_DATE    (date_key),
    CONSTRAINT FK_FACT_BLOCK        FOREIGN KEY (block_key)    REFERENCES dbo.DIM_BLOCK   (block_key),
    CONSTRAINT FK_FACT_TX_TYPE      FOREIGN KEY (tx_type_key)  REFERENCES dbo.DIM_TX_TYPE (tx_type_key),
    CONSTRAINT FK_FACT_MARKET       FOREIGN KEY (market_key)   REFERENCES dbo.DIM_MARKET  (market_key)
);
GO

-- Composite and covering indexes on FK columns for star-join performance
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACT_TX_date_key'    AND object_id = OBJECT_ID('dbo.FACT_TRANSACTION'))
    CREATE INDEX IX_FACT_TX_date_key    ON dbo.FACT_TRANSACTION (date_key);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACT_TX_block_key'   AND object_id = OBJECT_ID('dbo.FACT_TRANSACTION'))
    CREATE INDEX IX_FACT_TX_block_key   ON dbo.FACT_TRANSACTION (block_key);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACT_TX_tx_type_key' AND object_id = OBJECT_ID('dbo.FACT_TRANSACTION'))
    CREATE INDEX IX_FACT_TX_tx_type_key ON dbo.FACT_TRANSACTION (tx_type_key);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_FACT_TX_market_key'  AND object_id = OBJECT_ID('dbo.FACT_TRANSACTION'))
    CREATE INDEX IX_FACT_TX_market_key  ON dbo.FACT_TRANSACTION (market_key);
GO
PRINT 'FACT_TRANSACTION ready.';
GO

-- =============================================================================
-- 6. ERR_QUALITY_REJECTS  —  DQ error sink  (Design §6)
-- =============================================================================
-- Records that fail any of the 5 DQ gates are written here before being
-- excluded from the star-schema target load.  This preserves target integrity
-- while providing a full audit trail for manual investigation.
--
-- DQ Pillars covered (Design §6):
--   Uniqueness   — txid must be 64-char hex and not already in FACT_TRANSACTION
--   Completeness — output_value_sat >= 0; block_hash must resolve to DIM_BLOCK
--   Consistency  — script_type_desc must match the conformed list; map → OTHER
--   Freshness    — market snapshot must represent the last 24 h; alert if stale
-- =============================================================================
IF OBJECT_ID('dbo.ERR_QUALITY_REJECTS', 'U') IS NULL
CREATE TABLE dbo.ERR_QUALITY_REJECTS (
    reject_id          BIGINT         NOT NULL IDENTITY(1,1),
    pipeline_run_ts    DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),
    source_table       VARCHAR(50)    NOT NULL,   -- STG_TRANSACTIONS | STG_MARKET_DAILY | …
    business_key       VARCHAR(50)    NOT NULL,   -- column name that triggered the rule
    business_key_value VARCHAR(100)   NULL,        -- value that failed (may be NULL for NULL inputs)
    dq_rule            VARCHAR(200)   NOT NULL,   -- human-readable rule text
    dq_pillar          VARCHAR(30)    NOT NULL,   -- Uniqueness|Completeness|Consistency|Freshness
    reject_reason      NVARCHAR(500)  NOT NULL,   -- specific failure detail
    raw_payload        NVARCHAR(MAX)  NULL,        -- optional serialised source row for debugging
    load_ts            DATETIME2      NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_ERR_QUALITY_REJECTS PRIMARY KEY (reject_id)
);
GO

IF NOT EXISTS (
    SELECT 1 FROM sys.indexes
    WHERE name = 'IX_ERR_pillar' AND object_id = OBJECT_ID('dbo.ERR_QUALITY_REJECTS')
)
    CREATE INDEX IX_ERR_pillar ON dbo.ERR_QUALITY_REJECTS (dq_pillar, source_table);
GO
PRINT 'ERR_QUALITY_REJECTS ready.';
GO

PRINT '=== BTC_DW schema creation complete ===';
GO

-- =============================================================================
-- Validation queries  —  run manually after the pipeline to verify the DW
-- =============================================================================

-- --------------------------------------------------------
-- 1. DIM_DATE — row count, range, era distribution
-- --------------------------------------------------------
SELECT COUNT(*)           AS total_dates,
       MIN([date])        AS first_date,
       MAX([date])        AS last_date,
       halving_era,
       COUNT(*)           AS era_days
FROM BTC_DW.dbo.DIM_DATE
GROUP BY halving_era
ORDER BY MIN([date]);

-- --------------------------------------------------------
-- 2. DIM_BLOCK — count, height range, difficulty tiers
-- --------------------------------------------------------
SELECT difficulty_tier,
       COUNT(*)           AS block_count,
       MIN(block_height)  AS min_height,
       MAX(block_height)  AS max_height,
       MIN(block_timestamp) AS earliest,
       MAX(block_timestamp) AS latest
FROM BTC_DW.dbo.DIM_BLOCK
GROUP BY difficulty_tier
ORDER BY MIN(block_height);

-- --------------------------------------------------------
-- 3. DIM_TX_TYPE — all loaded type combinations
-- --------------------------------------------------------
SELECT tx_type_key, script_type_desc,
       segwit_flag, coinbase_flag, rbf_flag, locktime_flag,
       dw_load_timestamp
FROM BTC_DW.dbo.DIM_TX_TYPE
ORDER BY tx_type_key;

-- --------------------------------------------------------
-- 4. DIM_MARKET — date range and NULL rates
-- --------------------------------------------------------
SELECT COUNT(*)  AS total_days,
       MIN(snapshot_date) AS first_date,
       MAX(snapshot_date) AS last_date,
       SUM(CASE WHEN fear_greed_score      IS NULL THEN 1 ELSE 0 END) AS null_fg_score,
       SUM(CASE WHEN btc_dominance_percent IS NULL THEN 1 ELSE 0 END) AS null_dominance,
       SUM(CASE WHEN volatility_index      IS NULL THEN 1 ELSE 0 END) AS null_volatility
FROM BTC_DW.dbo.DIM_MARKET;

-- --------------------------------------------------------
-- 5. FACT_TRANSACTION — row count and key measure averages
-- --------------------------------------------------------
SELECT COUNT(*)                  AS total_tx,
       SUM(CASE WHEN market_key IS NULL THEN 1 ELSE 0 END) AS no_market_key,
       AVG(fee_rate_sat_vbyte)   AS avg_fee_rate_sat_vbyte,
       AVG(tx_vsize_bytes)       AS avg_tx_vsize_bytes,
       AVG(fee_burden_pct)       AS avg_fee_burden_pct,
       AVG(io_value_ratio)       AS avg_io_value_ratio
FROM BTC_DW.dbo.FACT_TRANSACTION;

-- Spot-check 5 most recent transactions (all pre-computed columns visible)
SELECT TOP 5
    f.txid,
    f.fee_satoshis,
    f.tx_vsize_bytes,
    f.fee_burden_pct,
    f.input_value_btc,
    f.output_value_btc,
    f.fee_btc,
    f.io_value_ratio,
    d.[date]           AS block_date,
    b.block_height,
    b.difficulty_tier,
    t.script_type_desc,
    m.fear_greed_label
FROM BTC_DW.dbo.FACT_TRANSACTION  f
JOIN BTC_DW.dbo.DIM_DATE          d ON d.date_key    = f.date_key
JOIN BTC_DW.dbo.DIM_BLOCK         b ON b.block_key   = f.block_key
JOIN BTC_DW.dbo.DIM_TX_TYPE       t ON t.tx_type_key = f.tx_type_key
LEFT JOIN BTC_DW.dbo.DIM_MARKET   m ON m.market_key  = f.market_key
ORDER BY f.tx_key DESC;

-- --------------------------------------------------------
-- 6. ERR_QUALITY_REJECTS — reject counts by pillar & rule
-- --------------------------------------------------------
SELECT dq_pillar,
       source_table,
       dq_rule,
       COUNT(*) AS reject_count
FROM BTC_DW.dbo.ERR_QUALITY_REJECTS
GROUP BY dq_pillar, source_table, dq_rule
ORDER BY reject_count DESC;

-- --------------------------------------------------------
-- 7. FK integrity cross-check (all results should be 0)
-- --------------------------------------------------------
SELECT 'Missing date_key'    AS issue, COUNT(*) AS orphaned_rows
FROM BTC_DW.dbo.FACT_TRANSACTION f
WHERE NOT EXISTS (SELECT 1 FROM BTC_DW.dbo.DIM_DATE d   WHERE d.date_key   = f.date_key)
UNION ALL
SELECT 'Missing block_key',  COUNT(*)
FROM BTC_DW.dbo.FACT_TRANSACTION f
WHERE NOT EXISTS (SELECT 1 FROM BTC_DW.dbo.DIM_BLOCK b  WHERE b.block_key  = f.block_key)
UNION ALL
SELECT 'Missing tx_type_key', COUNT(*)
FROM BTC_DW.dbo.FACT_TRANSACTION f
WHERE NOT EXISTS (SELECT 1 FROM BTC_DW.dbo.DIM_TX_TYPE t WHERE t.tx_type_key = f.tx_type_key)
UNION ALL
SELECT 'Missing market_key (non-null only)', COUNT(*)
FROM BTC_DW.dbo.FACT_TRANSACTION f
WHERE f.market_key IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM BTC_DW.dbo.DIM_MARKET m WHERE m.market_key = f.market_key);
