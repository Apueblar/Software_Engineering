
  
    USE [AWStaging];
    USE [AWStaging];
    
    

    

    
    USE [AWStaging];
    EXEC('
        create view "raw_raw"."stg_sales__dbt_tmp__dbt_tmp_vw" as 

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
WHERE order_date >= ''2020-01-01'';
    ')

EXEC('
            SELECT * INTO "AWStaging"."raw_raw"."stg_sales__dbt_tmp" FROM "AWStaging"."raw_raw"."stg_sales__dbt_tmp__dbt_tmp_vw" 
    OPTION (LABEL = ''dbt-sqlserver'');

        ')

    
    EXEC('DROP VIEW IF EXISTS raw_raw.stg_sales__dbt_tmp__dbt_tmp_vw')



    
    use [AWStaging];
    if EXISTS (
        SELECT *
        FROM sys.indexes with (nolock)
        WHERE name = 'raw_raw_stg_sales__dbt_tmp_cci'
        AND object_id=object_id('raw_raw_stg_sales__dbt_tmp')
    )
    DROP index "raw_raw"."stg_sales__dbt_tmp".raw_raw_stg_sales__dbt_tmp_cci
    CREATE CLUSTERED COLUMNSTORE INDEX raw_raw_stg_sales__dbt_tmp_cci
    ON "raw_raw"."stg_sales__dbt_tmp"

   


  