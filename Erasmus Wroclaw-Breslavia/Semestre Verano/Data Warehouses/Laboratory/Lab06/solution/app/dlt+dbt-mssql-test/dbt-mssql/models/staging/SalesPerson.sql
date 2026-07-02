{{ config(materialized='view') }}

-- Redirected to the full staging model.
-- Original template replaced during Lab 6 implementation.
-- See: models/staging/stg_salesperson.sql for the complete logic.

SELECT * FROM {{ ref('stg_salesperson') }}