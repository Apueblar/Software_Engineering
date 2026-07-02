{{ config(materialized='table') }}

-- TASK 3 - Mart: dim_product
-- Materialises the cleaned staging view as a permanent table.
-- Adds a surrogate ProductKey using ROW_NUMBER().

WITH stg AS (
    SELECT * FROM {{ ref('stg_product') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY product_id)             AS product_key,  -- surrogate PK
    product_id,
    product_name,
    product_number,
    subcategory_name,
    category_name,
    color,
    weight_class,
    weight_kg,
    list_price,
    standard_cost,
    -- Profit computed here as well (mirrors the SQL Server computed column)
    ISNULL(list_price, 0) - ISNULL(standard_cost, 0)   AS product_profit,
    -- Ratings: default 0 if no review exists
    ROUND(ISNULL(rating_avg, 0), 1)                     AS rating_avg,
    rating_min,
    rating_max
FROM stg
