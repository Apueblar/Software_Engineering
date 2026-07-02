{{ config(materialized='table') }}

-- Redirected to the full product dimension model.
-- Original template replaced during Lab 6 implementation.
-- See: models/marts/dim_product.sql for the complete logic.

SELECT * FROM {{ ref('dim_product') }}
