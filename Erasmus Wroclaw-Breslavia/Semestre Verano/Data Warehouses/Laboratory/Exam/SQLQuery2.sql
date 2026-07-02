-- Query 2:
/*The finance department is conducting a multi-level fiscal audit to track tax obligations across different time scales. They need a hierarchical report that drills down into the TaxAmt across three nested time periods:

Total tax by Calendar Year.
Total tax by Quarter (within each year).
Total tax by Month (within each quarter).
Instead of manual summation or multiple localized filters, write a single query that generates an organized hierarchy, providing sub-totals at each chronological level and a final grand total to capture the full tax liability for the database period. Make sure to identify aggregate rows by using an 'ALL' prefix, e.g., 'ALLQUARTERS' or 'ALLMONTHS'.
*/

SELECT
    -- Year label: 'ALLYEARS' for the grand total row
    CASE
        WHEN GROUPING(YEAR(soh.OrderDate)) = 1 THEN 'ALLYEARS'
        ELSE CAST(YEAR(soh.OrderDate) AS VARCHAR(4))
    END AS CalendarYear,

    -- Quarter label: NULL when rolled up to year/grand-total level
    CASE
        WHEN GROUPING(YEAR(soh.OrderDate)) = 1 THEN NULL
        WHEN GROUPING(DATEPART(QUARTER, soh.OrderDate)) = 1 THEN 'ALLQUARTERS'
        ELSE 'Q' + CAST(DATEPART(QUARTER, soh.OrderDate) AS VARCHAR(1))
    END AS Quarter,

    -- Month label: NULL when rolled up to quarter/year/grand-total level
    CASE
        WHEN GROUPING(DATEPART(QUARTER, soh.OrderDate)) = 1 THEN NULL
        WHEN GROUPING(MONTH(soh.OrderDate)) = 1 THEN 'ALLMONTHS'
        ELSE CAST(MONTH(soh.OrderDate) AS VARCHAR(2))
    END AS [Month],

    SUM(soh.TaxAmt) AS TotalTaxAmt

FROM Sales.SalesOrderHeader soh

GROUP BY GROUPING SETS (
    (), -- Grand total
    (YEAR(soh.OrderDate)), -- Sub-total per year
    (YEAR(soh.OrderDate), DATEPART(QUARTER, soh.OrderDate)), -- Sub-total per quarter
    (YEAR(soh.OrderDate), DATEPART(QUARTER, soh.OrderDate), MONTH(soh.OrderDate)) -- Detail per month
)

ORDER BY
    GROUPING(YEAR(soh.OrderDate)) DESC, -- Grand total last
    YEAR(soh.OrderDate),
    GROUPING(DATEPART(QUARTER, soh.OrderDate)) DESC, -- Year subtotal before quarters
    DATEPART(QUARTER, soh.OrderDate),
    GROUPING(MONTH(soh.OrderDate)) DESC, -- Quarter subtotal before months
    MONTH(soh.OrderDate);