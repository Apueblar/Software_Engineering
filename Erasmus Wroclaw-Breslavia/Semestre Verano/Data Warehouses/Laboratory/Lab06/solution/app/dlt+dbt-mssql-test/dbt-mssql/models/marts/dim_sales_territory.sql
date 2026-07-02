{{ config(materialized='table') }}

-- TASK 5 - Mart: dim_sales_territory
-- Materialises the sales territory staging view with a surrogate TerritoryKey.

WITH stg AS (
    SELECT * FROM {{ ref('stg_territory') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY territory_id)  AS territory_key,  -- surrogate PK
    territory_id,
    territory_name,
    territory_country,
    territory_continent
FROM stg
