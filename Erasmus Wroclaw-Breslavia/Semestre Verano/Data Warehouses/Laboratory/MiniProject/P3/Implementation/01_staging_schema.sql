-- =============================================================================
-- BTC_DW — STAGING DATABASE SCHEMA
-- File: 01_staging_schema.sql
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 0. Create the staging database
-- -----------------------------------------------------------------------------
--IF EXISTS (SELECT name FROM sys.databases WHERE name = N'BTC_Staging')
--BEGIN
--    ALTER DATABASE BTC_Staging SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
--    DROP DATABASE BTC_Staging;
--    PRINT 'Database BTC_Staging dropped.';
--END
--GO

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'BTC_Staging')
BEGIN
    CREATE DATABASE BTC_Staging COLLATE Latin1_General_CI_AS;
    PRINT 'Database BTC_Staging created.';
END
ELSE
    PRINT 'Database BTC_Staging already exists — skipping creation.';
GO

USE BTC_Staging;
GO

SET QUOTED_IDENTIFIER ON;
GO

-- -----------------------------------------------------------------------------
-- 1. STG_PIPELINE_LOG
--    Tracks every pipeline run. Used by Python for incremental watermarking
--    (i.e. "what was the last block height / date we successfully loaded?").
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_PIPELINE_LOG', 'U') IS NULL
CREATE TABLE dbo.STG_PIPELINE_LOG (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    run_ts DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    source_name VARCHAR(50) NOT NULL, -- 'blocks' | 'transactions' | 'market' | 'fear_greed'
    records_fetched INT NOT NULL DEFAULT 0,
    records_inserted INT NOT NULL DEFAULT 0,
    last_block_height INT NULL, -- watermark for on-chain sources
    last_date DATE NULL, -- watermark for market sources
    status VARCHAR(20) NOT NULL DEFAULT 'running', -- running | ok | error
    error_msg NVARCHAR(MAX) NULL
);
GO
PRINT 'STG_PIPELINE_LOG ready.';
GO

-- -----------------------------------------------------------------------------
-- 2. STG_BLOCKS
--    One row per Bitcoin block. Populated from mempool.space /api/v1/blocks.
--    Raw numerics kept as-is; bucketing happens in the DW load (Part 3).
--    is_active supports soft-delete on block reorg detection.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_BLOCKS', 'U') IS NULL
CREATE TABLE dbo.STG_BLOCKS (
    block_hash CHAR(64) NOT NULL,
    height INT NOT NULL,
    block_version INT NULL,
    block_timestamp BIGINT NOT NULL, -- miner-set Unix epoch (UTC)
    median_time BIGINT NOT NULL, -- MTP — more reliable for date joins
    tx_count INT NOT NULL,
    size_bytes INT NOT NULL,
    weight_units INT NOT NULL, -- max ~4,000,000 for a full block
    difficulty FLOAT NOT NULL,
    nonce BIGINT NOT NULL,
    bits BIGINT NULL,
    merkle_root CHAR(64) NULL,
    previous_block_hash CHAR(64) NULL,
    total_fees_sat BIGINT NULL, -- NULL on very old blocks (extras absent)
    avg_fee_rate INT NULL, -- sat/vByte; NULL pre-SegWit
    median_fee_rate INT NULL,
    pool_name VARCHAR(100) NULL,
    pool_slug VARCHAR(100) NULL,
    miner_reward_sat BIGINT NULL, -- subsidy + fees
    load_ts DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),
    is_active BIT NOT NULL DEFAULT 1, -- 0 = orphaned/reorged

    CONSTRAINT PK_STG_BLOCKS PRIMARY KEY (block_hash)
);
GO

-- Index on height for incremental watermark queries
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STG_BLOCKS_height')
    CREATE INDEX IX_STG_BLOCKS_height ON dbo.STG_BLOCKS (height DESC);
GO
PRINT 'STG_BLOCKS ready.';
GO

IF COL_LENGTH('dbo.STG_BLOCKS', 'pool_name') IS NULL
BEGIN
    ALTER TABLE dbo.STG_BLOCKS ADD pool_name VARCHAR(100) NULL, pool_slug VARCHAR(100) NULL;
    PRINT 'STG_BLOCKS: pool_name and pool_slug columns added (schema upgrade).';
END
GO

-- -----------------------------------------------------------------------------
-- 3. STG_TRANSACTIONS
--    One row per confirmed transaction. fee_rate_sat_vbyte is a persisted
--    computed column so SSIS can read it directly without recalculating.
--    primary_script_type is populated by a post-load SQL step (majority vote
--    across STG_TX_INPUTS / STG_TX_OUTPUTS for that txid).
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_TRANSACTIONS', 'U') IS NULL
CREATE TABLE dbo.STG_TRANSACTIONS (
    txid CHAR(64) NOT NULL,
    block_hash CHAR(64) NOT NULL,
    block_height INT NOT NULL,
    tx_version INT NOT NULL DEFAULT 1,
    locktime INT NOT NULL DEFAULT 0,
    size_bytes INT NOT NULL,
    weight_units INT NOT NULL,
    -- Fee fields
    fee_satoshis BIGINT NOT NULL DEFAULT 0, -- 0 for coinbase
    -- Computed: fee / (weight / 4) = fee per virtual byte. PERSISTED so it's queryable.
    fee_rate_sat_vbyte AS (
        CASE WHEN weight_units > 0
                THEN ROUND(CAST(fee_satoshis AS FLOAT) / (weight_units / 4.0), 4)
                ELSE NULL
        END
    ) PERSISTED,
    -- Input / output summary counts
    input_count INT NOT NULL,
    output_count INT NOT NULL,
    -- Derived flags (set during Python fetch)
    is_coinbase BIT NOT NULL DEFAULT 0,
    has_witness BIT NOT NULL DEFAULT 0, -- TRUE if any input has witness data
    is_rbf BIT NOT NULL DEFAULT 0, -- TRUE if any sequence <= 0xFFFFFFFD
    -- Filled by post-load SQL (majority script type across all I/O for this TX)
    primary_script_type VARCHAR(20) NULL, -- P2PKH | P2SH | P2WPKH | P2WSH | P2TR | UNKNOWN
    load_ts DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_STG_TRANSACTIONS PRIMARY KEY (txid),
    CONSTRAINT FK_STG_TX_BLOCK FOREIGN KEY (block_hash) REFERENCES dbo.STG_BLOCKS (block_hash)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STG_TX_block_height')
    CREATE INDEX IX_STG_TX_block_height ON dbo.STG_TRANSACTIONS (block_height DESC);
GO
PRINT 'STG_TRANSACTIONS ready.';
GO

-- -----------------------------------------------------------------------------
-- 4. STG_TX_INPUTS
--    One row per transaction input (vin entry). Needed to compute:
--      - input_value_sat (SUM per txid -> FACT measure)
--      - has_witness flag
--      - is_rbf flag
--      - primary_script_type (majority vote with outputs)
--    Coinbase TXs: prev_txid, prev_vout, value_sat are all NULL.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_TX_INPUTS', 'U') IS NULL
CREATE TABLE dbo.STG_TX_INPUTS (
    input_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    txid CHAR(64) NOT NULL,
    input_index INT NOT NULL,
    prev_txid CHAR(64) NULL, -- NULL for coinbase
    prev_vout INT NULL, -- NULL for coinbase
    value_sat BIGINT NULL, -- NULL for coinbase (no UTXO to spend)
    script_type VARCHAR(20) NULL, -- from prevout.scriptpubkey_type
    address VARCHAR(100) NULL,
    has_witness BIT NOT NULL DEFAULT 0,
    sequence_num BIGINT NOT NULL DEFAULT 4294967295, -- 0xFFFFFFFF = final

    CONSTRAINT FK_STG_INPUT_TX FOREIGN KEY (txid) REFERENCES dbo.STG_TRANSACTIONS (txid)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STG_INPUTS_txid')
    CREATE INDEX IX_STG_INPUTS_txid ON dbo.STG_TX_INPUTS (txid);
GO
PRINT 'STG_TX_INPUTS ready.';
GO

-- -----------------------------------------------------------------------------
-- 5. STG_TX_OUTPUTS
--    One row per transaction output (vout entry). Needed to compute:
--      - output_value_sat (SUM per txid -> FACT measure)
--      - primary_script_type (majority vote with inputs)
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_TX_OUTPUTS', 'U') IS NULL
CREATE TABLE dbo.STG_TX_OUTPUTS (
    output_id BIGINT IDENTITY(1,1) PRIMARY KEY,
    txid CHAR(64) NOT NULL,
    output_index INT NOT NULL,
    value_sat BIGINT NOT NULL,
    script_type VARCHAR(20) NULL, -- P2PKH | P2SH | P2WPKH | P2WSH | P2TR | OP_RETURN
    address VARCHAR(100) NULL, -- NULL for OP_RETURN outputs

    CONSTRAINT FK_STG_OUTPUT_TX FOREIGN KEY (txid) REFERENCES dbo.STG_TRANSACTIONS (txid)
);
GO

IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_STG_OUTPUTS_txid')
    CREATE INDEX IX_STG_OUTPUTS_txid ON dbo.STG_TX_OUTPUTS (txid);
GO
PRINT 'STG_TX_OUTPUTS ready.';
GO

-- -----------------------------------------------------------------------------
-- 6. STG_MARKET_DAILY
--    One row per calendar date. Merges CoinGecko OHLCV + Alternative.me
--    Fear & Greed into one denormalised market table. SSIS joins to
--    FACT_TRANSACTION on price_date = CAST(block_date AS DATE).
--
--    Null policy (documented here for ETL reference in Part 3):
--      price_open/high/low -- NULL before 2013 (no reliable exchange data)
--      price_close -- NULL before 2013; flag rows where CoinGecko returns 0
--      volume_24h_usd -- NULL before 2014
--      market_cap_usd -- NULL before 2013
--      fear_greed_score -- NULL before 2019-02-01 (API history starts here)
--      btc_dominance_pct -- NULL unless /global snapshot available for that date
--      nvt_ratio -- computed post-load once on-chain volume is available
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_MARKET_DAILY', 'U') IS NULL
CREATE TABLE dbo.STG_MARKET_DAILY (
    price_date DATE NOT NULL,
    -- CoinGecko OHLCV (from /market_chart + /ohlc endpoints)
    price_open DECIMAL(18,4) NULL,
    price_high DECIMAL(18,4) NULL,
    price_low DECIMAL(18,4) NULL,
    price_close DECIMAL(18,4) NULL,
    -- Computed: average daily price (OHLC average)
    price_usd_avg AS (
        CASE WHEN price_open IS NOT NULL AND price_high IS NOT NULL AND price_low IS NOT NULL AND price_close IS NOT NULL
             THEN ROUND((price_open + price_high + price_low + price_close) / 4.0, 4)
             ELSE price_close
        END
    ) PERSISTED,
    volume_24h_usd DECIMAL(22,2) NULL,
    market_cap_usd DECIMAL(22,2) NULL,
    -- BTC dominance from /global snapshot (best-effort daily scrape)
    btc_dominance_pct DECIMAL(5,2) NULL,
    -- Alternative.me Fear & Greed (available from 2019-02-01)
    fear_greed_score TINYINT NULL, -- 0-100; NULL pre-2019
    fear_greed_label VARCHAR(25) NULL, -- 'Extreme Fear' | 'Fear' | 'Neutral' | 'Greed' | 'Extreme Greed'
    -- Computed post-load: market_cap / daily_on_chain_tx_volume_usd
    nvt_ratio DECIMAL(10,4) NULL,
    -- 7-day MA of price_close (for price_trend classification during DW load)
    price_ma_7d DECIMAL(18,4) NULL,
    -- 14-day realised volatility: stddev of daily log returns * sqrt(365)
    volatility_14d DECIMAL(8,6) NULL,
    load_ts DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_STG_MARKET_DAILY PRIMARY KEY (price_date)
);
GO
PRINT 'STG_MARKET_DAILY ready.';
GO

-- -----------------------------------------------------------------------------
-- 7. STG_FEAR_GREED_RAW
--    Raw Alternative.me response before merging into STG_MARKET_DAILY.
--    Keeping this separate lets you re-run the merge without re-hitting the API.
-- -----------------------------------------------------------------------------
IF OBJECT_ID('dbo.STG_FEAR_GREED_RAW', 'U') IS NULL
CREATE TABLE dbo.STG_FEAR_GREED_RAW (
    fg_date DATE NOT NULL,
    fg_score TINYINT NOT NULL,
    fg_label VARCHAR(25) NOT NULL,
    fg_timestamp BIGINT NOT NULL, -- Unix epoch from API response
    load_ts DATETIME2 NOT NULL DEFAULT SYSUTCDATETIME(),

    CONSTRAINT PK_STG_FEAR_GREED PRIMARY KEY (fg_date)
);
GO
PRINT 'STG_FEAR_GREED_RAW ready.';
GO

-- =============================================================================
-- Helper views
-- Used by the SSIS DW load package (Part 3) to resolve measures that cannot
-- come from a single staging row.
-- =============================================================================

-- FACT.input_value_sat — sum of all inputs per transaction
CREATE OR ALTER VIEW dbo.V_TX_INPUT_TOTALS AS
SELECT
    txid,
    SUM(value_sat) AS input_value_sat,
    COUNT(*) AS input_count_check
FROM dbo.STG_TX_INPUTS
WHERE value_sat IS NOT NULL -- exclude coinbase inputs (NULL prevout)
GROUP BY txid;
GO
PRINT 'V_TX_INPUT_TOTALS ready.';
GO

-- FACT.output_value_sat — sum of all outputs per transaction
CREATE OR ALTER VIEW dbo.V_TX_OUTPUT_TOTALS AS
SELECT
    txid,
    SUM(value_sat) AS output_value_sat,
    COUNT(*) AS output_count_check
FROM dbo.STG_TX_OUTPUTS
GROUP BY txid;
GO
PRINT 'V_TX_OUTPUT_TOTALS ready.';
GO

-- DIM_TX_TYPE.primary_script_type — modal script type across all I/O for each TX
-- SQL Server has no MODE() aggregate, so this uses ROW_NUMBER() + COUNT().
CREATE OR ALTER VIEW dbo.V_TX_PRIMARY_SCRIPT AS
WITH script_counts AS (
    SELECT txid, script_type, COUNT(*) AS cnt
    FROM (
        SELECT txid, script_type FROM dbo.STG_TX_INPUTS WHERE script_type IS NOT NULL
        UNION ALL
        SELECT txid, script_type FROM dbo.STG_TX_OUTPUTS WHERE script_type IS NOT NULL
    ) combined
    GROUP BY txid, script_type
),
ranked AS (
    SELECT txid, script_type,
           ROW_NUMBER() OVER (PARTITION BY txid ORDER BY cnt DESC) AS rn
    FROM script_counts
)
SELECT txid, script_type AS primary_script_type
FROM ranked
WHERE rn = 1;
GO
PRINT 'V_TX_PRIMARY_SCRIPT ready.';
GO

PRINT '=== BTC_Staging schema creation complete ===';
GO

-- Check values:
-- ============================================================
-- 1. PIPELINE LOG — did any runs complete successfully?
-- ============================================================
SELECT TOP 20 *
FROM BTC_Staging.dbo.STG_PIPELINE_LOG
ORDER BY run_ts DESC;

-- Summary by source and status
SELECT source_name, status, COUNT(*) AS runs,
       SUM(records_inserted) AS total_inserted,
       MAX(run_ts) AS last_run
FROM BTC_Staging.dbo.STG_PIPELINE_LOG
GROUP BY source_name, status
ORDER BY source_name;


-- ============================================================
-- 2. BLOCKS — how many loaded, what height range?
-- ============================================================
SELECT COUNT(*)            AS total_blocks,
       MIN(height)         AS min_height,
       MAX(height)         AS max_height,
       SUM(CASE WHEN is_active = 0 THEN 1 ELSE 0 END) AS orphaned,
       MIN(load_ts)        AS first_load,
       MAX(load_ts)        AS last_load
FROM BTC_Staging.dbo.STG_BLOCKS;

-- Spot check a few rows
SELECT TOP 5 block_hash, height, tx_count, total_fees_sat, pool_name, load_ts
FROM BTC_Staging.dbo.STG_BLOCKS
ORDER BY height DESC;


-- ============================================================
-- 3. TRANSACTIONS — count, coinbase ratio, SegWit ratio
-- ============================================================
SELECT COUNT(*)  AS total_tx,
       SUM(CAST(is_coinbase AS INT))   AS coinbase_count,
       SUM(CAST(has_witness AS INT))   AS segwit_count,
       SUM(CAST(is_rbf AS INT))        AS rbf_count,
       AVG(fee_rate_sat_vbyte)         AS avg_fee_rate,
       MIN(block_height)               AS min_block,
       MAX(block_height)               AS max_block
FROM BTC_Staging.dbo.STG_TRANSACTIONS;

-- Spot check
SELECT TOP 5 txid, block_height, fee_satoshis, fee_rate_sat_vbyte,
             is_coinbase, has_witness, primary_script_type
FROM BTC_Staging.dbo.STG_TRANSACTIONS
ORDER BY block_height DESC;


-- ============================================================
-- 4. TX INPUTS — count, coinbase (NULL value) ratio
-- ============================================================
SELECT COUNT(*)  AS total_inputs,
       SUM(CASE WHEN value_sat IS NULL THEN 1 ELSE 0 END) AS coinbase_inputs,
       SUM(CASE WHEN has_witness = 1   THEN 1 ELSE 0 END) AS witness_inputs,
       COUNT(DISTINCT txid) AS distinct_txids
FROM BTC_Staging.dbo.STG_TX_INPUTS;


-- ============================================================
-- 5. TX OUTPUTS — count, OP_RETURN ratio
-- ============================================================
SELECT COUNT(*)  AS total_outputs,
       SUM(CASE WHEN script_type = 'op_return' THEN 1 ELSE 0 END) AS op_return_count,
       SUM(CASE WHEN address IS NULL THEN 1 ELSE 0 END) AS null_address_count,
       COUNT(DISTINCT txid) AS distinct_txids
FROM BTC_Staging.dbo.STG_TX_OUTPUTS;


-- ============================================================
-- 6. MARKET DAILY — date range, null rates
-- ============================================================
SELECT COUNT(*)           AS total_days,
       MIN(price_date)    AS earliest_date,
       MAX(price_date)    AS latest_date,
       SUM(CASE WHEN price_close     IS NULL THEN 1 ELSE 0 END) AS null_close,
       SUM(CASE WHEN fear_greed_score IS NULL THEN 1 ELSE 0 END) AS null_fg_score,
       SUM(CASE WHEN btc_dominance_pct IS NULL THEN 1 ELSE 0 END) AS null_dominance
FROM BTC_Staging.dbo.STG_MARKET_DAILY;

-- Spot check recent rows
SELECT TOP 5 *
FROM BTC_Staging.dbo.STG_MARKET_DAILY
ORDER BY price_date DESC;


-- ============================================================
-- 7. FEAR & GREED RAW — count and date range
-- ============================================================
SELECT COUNT(*)        AS total_days,
       MIN(fg_date)    AS earliest_date,
       MAX(fg_date)    AS latest_date,
       MIN(fg_score)   AS min_score,
       MAX(fg_score)   AS max_score
FROM BTC_Staging.dbo.STG_FEAR_GREED_RAW;


-- ============================================================
-- 8. CROSS-CHECK — blocks vs transactions consistency
-- ============================================================
-- Every TX should have a matching block
SELECT COUNT(*) AS tx_missing_block
FROM BTC_Staging.dbo.STG_TRANSACTIONS t
WHERE NOT EXISTS (
    SELECT 1 FROM BTC_Staging.dbo.STG_BLOCKS b
    WHERE b.block_hash = t.block_hash
);

-- Every input/output should have a matching TX
SELECT COUNT(*) AS inputs_missing_tx
FROM BTC_Staging.dbo.STG_TX_INPUTS i
WHERE NOT EXISTS (
    SELECT 1 FROM BTC_Staging.dbo.STG_TRANSACTIONS t
    WHERE t.txid = i.txid
);

SELECT COUNT(*) AS outputs_missing_tx
FROM BTC_Staging.dbo.STG_TX_OUTPUTS o
WHERE NOT EXISTS (
    SELECT 1 FROM BTC_Staging.dbo.STG_TRANSACTIONS t
    WHERE t.txid = o.txid
);