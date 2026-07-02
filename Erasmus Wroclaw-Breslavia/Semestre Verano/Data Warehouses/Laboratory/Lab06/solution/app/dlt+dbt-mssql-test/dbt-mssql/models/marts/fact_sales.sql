{{ config(materialized='table') }}

-- TASK 6 / TASK 7 - Mart: fact_sales
-- Joins SalesOrderHeader + SalesOrderDetail with all four dimension tables.
-- Converts LineTotal from USD to PLN using the daily NBP exchange rate.
-- Task 7 enrichment: prev_day_rate and rate_trend columns.

WITH orders AS (
    SELECT * FROM {{ source('raw_aw', 'sales_order_header') }}
),
details AS (
    SELECT * FROM {{ source('raw_aw', 'sales_order_detail') }}
),
dim_prod AS (
    SELECT product_key, product_id
    FROM {{ ref('dim_product') }}
),
dim_sp AS (
    SELECT salesperson_key, business_entity_id
    FROM {{ ref('dim_salesperson') }}
),
dim_terr AS (
    SELECT territory_key, territory_id
    FROM {{ ref('dim_sales_territory') }}
),
dim_date AS (
    SELECT date_key, full_date
    FROM {{ ref('dim_order_date') }}
),
rates AS (
    SELECT
        rate_date,
        usd_to_pln,
        -- Task 7: rate from the previous calendar day
        LAG(usd_to_pln) OVER (ORDER BY rate_date)    AS prev_day_rate
    FROM {{ source('raw_aw', 'currency_rate_data') }}
)

SELECT
    ROW_NUMBER() OVER (ORDER BY o.sales_order_id, d.sales_order_detail_id) AS sales_fact_key,
    o.sales_order_id,
    d.sales_order_detail_id,

    -- Dimension foreign keys
    dp.product_key,
    dsp.salesperson_key,
    dt.territory_key,
    dd.date_key,

    -- Measures (USD)
    d.order_qty,
    d.unit_price,
    d.line_total,

    -- Task 6: PLN conversion
    r.usd_to_pln,
    ROUND(d.line_total * r.usd_to_pln, 2)           AS line_total_pln,

    -- Task 7: exchange rate trend indicator
    r.prev_day_rate,
    CASE
        WHEN r.usd_to_pln > r.prev_day_rate THEN 'Rising'
        WHEN r.usd_to_pln < r.prev_day_rate THEN 'Falling'
        ELSE 'Stable'
    END                                              AS rate_trend

FROM orders o
JOIN details  d   ON o.sales_order_id       = d.sales_order_id
JOIN dim_prod dp  ON d.product_id           = dp.product_id
JOIN dim_sp   dsp ON o.sales_person_id      = dsp.business_entity_id
JOIN dim_terr dt  ON o.territory_id         = dt.territory_id
JOIN dim_date dd  ON CAST(o.order_date AS DATE) = dd.full_date
LEFT JOIN rates r ON CAST(o.order_date AS DATE) = r.rate_date
