
{{ config(materialized='view') }}

WITH raw_prod AS (
    SELECT * FROM {{ source('raw', 'Product') }}
)

select product_id, color from raw_prod
