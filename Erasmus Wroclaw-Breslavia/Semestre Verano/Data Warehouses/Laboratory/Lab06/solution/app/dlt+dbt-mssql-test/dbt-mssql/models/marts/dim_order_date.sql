{{ config(materialized='table') }}

-- TASK 4 - Mart: dim_order_date
-- Generates one row per unique order date found in SalesOrderHeader.
-- Enriches with: day of month, month number/name, quarter, half-year, year.
-- The DateKey is an integer in YYYYMMDD format (e.g. 20110531).

WITH raw_dates AS (
    SELECT 
        CAST(MIN(order_date) AS DATE) AS min_date,
        CAST(MAX(order_date) AS DATE) AS max_date
    FROM {{ source('raw_aw', 'sales_order_header') }}
),
numbers AS (
    SELECT ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) - 1 AS n
    FROM {{ source('raw_aw', 'sales_order_header') }}
),
date_spine AS (
    SELECT DATEADD(day, n.n, r.min_date) AS full_date
    FROM numbers n
    CROSS JOIN raw_dates r
    WHERE DATEADD(day, n.n, r.min_date) <= r.max_date
)

SELECT
    CAST(FORMAT(full_date, 'yyyyMMdd') AS INT)  AS date_key,  -- e.g. 20110531
    full_date,
    DAY(full_date)                              AS day_of_month,
    MONTH(full_date)                            AS month_number,
    DATENAME(MONTH, full_date)                  AS month_name,
    DATEPART(QUARTER, full_date)                AS quarter,
    CASE WHEN MONTH(full_date) <= 6 THEN 1
         ELSE 2
    END                                         AS half_year,
    YEAR(full_date)                             AS year
FROM date_spine
