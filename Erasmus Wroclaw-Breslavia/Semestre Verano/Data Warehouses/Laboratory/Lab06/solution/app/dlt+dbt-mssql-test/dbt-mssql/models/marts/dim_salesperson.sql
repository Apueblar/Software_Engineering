{{ config(materialized='table') }}

-- TASK 5 - Mart: dim_salesperson
-- Materialises the salesperson staging view with a surrogate SalespersonKey.

WITH stg AS (
    SELECT * FROM {{ ref('stg_salesperson') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY business_entity_id)  AS salesperson_key,  -- surrogate PK
    business_entity_id,
    first_name,
    middle_name,
    last_name,
    full_name,
    sales_quota,
    bonus,
    commission_pct,
    territory_id
FROM stg
