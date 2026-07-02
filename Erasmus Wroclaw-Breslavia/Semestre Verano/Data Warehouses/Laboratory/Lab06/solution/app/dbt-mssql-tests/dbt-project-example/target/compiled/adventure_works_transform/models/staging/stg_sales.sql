

WITH raw_sales AS (
    -- dlt creates tables based on source names
    SELECT 
        sales_order_ID,
        order_date,
        customer_ID,
        sub_total,
        tax_amt,
        freight,
        total_due
    FROM "AWStaging"."raw"."sales_order_header"
)

SELECT
    *,
    -- Simple transformation: Calculate tax as a ratio
    CASE 
        WHEN sub_total > 0 THEN (tax_amt / sub_total) * 100 
        ELSE 0 
    END AS tax_percentage,
    -- Simple cleanup: Flag high value orders
    CASE 
        WHEN total_due > 5000 THEN 1 
        ELSE 0 
    END AS is_high_value
FROM raw_sales
WHERE order_date >= '2020-01-01'