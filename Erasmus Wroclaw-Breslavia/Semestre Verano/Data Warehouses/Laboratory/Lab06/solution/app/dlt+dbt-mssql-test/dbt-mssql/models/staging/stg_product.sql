{{ config(materialized='view') }}

-- TASK 3 - Staging: Product
-- Joins Product + ProductSubcategory + ProductCategory + ProductRating.
-- Applies:
--   Cleansing   : NULL color → 'N/A'; NULL weight → 0 / 'Unknown'
--   Standardisation : weight converted to KG; weight class derived
--   Enrichment  : rating aggregates joined from ProductRating

WITH raw AS (
    SELECT * FROM {{ source('raw_aw', 'product') }}
),
subcategory AS (
    SELECT
        product_subcategory_id,
        name AS subcategory_name,
        product_category_id
    FROM {{ source('raw_aw', 'product_subcategory') }}
),
category AS (
    SELECT
        product_category_id,
        name AS category_name
    FROM {{ source('raw_aw', 'product_category') }}
),
ratings AS (
    -- Aggregate per product_id (multiple reviews per product)
    SELECT
        product_id,
        ROUND(AVG(CAST(rating AS FLOAT)), 1) AS rating_avg,
        MIN(CAST(rating AS FLOAT))            AS rating_min,
        MAX(CAST(rating AS FLOAT))            AS rating_max
    FROM {{ source('raw_aw', 'product_rating') }}
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.name                                              AS product_name,
    p.product_number,
    ISNULL(sc.subcategory_name, 'N/A')                 AS subcategory_name,
    ISNULL(c.category_name,     'N/A')                 AS category_name,

    -- Cleansing: replace NULL color with 'N/A'
    ISNULL(p.color, 'N/A')                             AS color,

    -- Standardisation: weight class derived from grams stored in AW
    CASE
        WHEN p.weight IS NULL          THEN 'Unknown'
        WHEN p.weight < 500            THEN 'Light'
        WHEN p.weight BETWEEN 500 AND 5000 THEN 'Medium'
        ELSE                                'Heavy'
    END                                                AS weight_class,

    -- Standardisation: convert grams → kg (NULL treated as 0)
    ROUND(ISNULL(p.weight, 0) / 1000.0, 2)            AS weight_kg,

    p.list_price,
    p.standard_cost,

    -- Enrichment: product ratings from external CSV
    r.rating_avg,
    r.rating_min,
    r.rating_max

FROM raw p
LEFT JOIN subcategory sc ON p.product_subcategory_id = sc.product_subcategory_id
LEFT JOIN category     c  ON sc.product_category_id  = c.product_category_id
LEFT JOIN ratings      r  ON p.product_id            = r.product_id
