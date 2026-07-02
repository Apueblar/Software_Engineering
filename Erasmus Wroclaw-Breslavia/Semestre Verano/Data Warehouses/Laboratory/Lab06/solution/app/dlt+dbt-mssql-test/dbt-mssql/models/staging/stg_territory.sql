{{ config(materialized='view') }}

-- TASK 5 - Staging: Sales Territory
-- Joins SalesTerritory with CountryRegion for human-readable country names.

WITH t AS (
    SELECT * FROM {{ source('raw_aw', 'sales_territory') }}
),
cr AS (
    SELECT
        country_region_code,
        name AS country_name
    FROM {{ source('raw_aw', 'country_region') }}
)

SELECT
    t.territory_id,
    t.name                  AS territory_name,
    t.country_region_code,
    cr.country_name         AS territory_country,

    -- 'group' maps to continent in AW (e.g. 'North America', 'Europe')
    t.[group]               AS territory_continent

FROM t
LEFT JOIN cr ON t.country_region_code = cr.country_region_code
