{{ config(materialized='view') }}

-- TASK 5 - Staging: Salesperson
-- Joins SalesPerson (quota/bonus) with Person (names).
-- Handles optional middle name for full_name.

WITH sp AS (
    SELECT * FROM {{ source('raw_aw', 'sales_person') }}
),
p AS (
    SELECT
        business_entity_id,
        first_name,
        middle_name,
        last_name
    FROM {{ source('raw_aw', 'person') }}
)

SELECT
    sp.business_entity_id,
    p.first_name,
    p.middle_name,
    p.last_name,

    -- Enrichment: computed full name (middle name optional)
    p.first_name
        + ISNULL(' ' + p.middle_name, '')
        + ' ' + p.last_name                    AS full_name,

    -- Cleansing: replace NULL financials with 0
    ISNULL(sp.sales_quota, 0)                  AS sales_quota,
    ISNULL(sp.bonus,       0)                  AS bonus,
    ISNULL(sp.commission_pct, 0)               AS commission_pct,
    sp.territory_id

FROM sp
JOIN p ON sp.business_entity_id = p.business_entity_id
