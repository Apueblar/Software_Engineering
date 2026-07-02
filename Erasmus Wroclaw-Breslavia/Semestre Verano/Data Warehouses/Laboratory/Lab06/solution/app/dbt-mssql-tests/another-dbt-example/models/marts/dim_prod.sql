{{ config(materialized='table') }}

WITH stg_prod AS (
    SELECT * FROM {{ ref('stg_Product') }}
)
SELECT product_id, color, 1 as new_col
FROM stg_prod
