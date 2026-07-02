-- Query 1:
/*
Write a single T-SQL query using the AdventureWorks database.
Establish the average sales ranking (calculated as average of monthly rankings) of our sales representatives (sales made by the sales representative) evolve year-over-year.
Pivot years, so that each Year is a column header.

Result structure: Sales Representative, 2022, 2023, 2024, 2025, as values for 202X column represent average ranking, calculated as average of monthly rankings, which are calculated based on sales values in a given quarter - e.g., sales representative with the highest sales in a given month gets rank of 1, sales representative with the second highest sales in a given month gets rank of 2, and so on; having four quarters in a year you need to average these rankings.

The Query: "How did the average sales ranking (calculated as average of monthly rankings) of our sales representatives evolve year-over-year?"
*/

-- Step 1: Aggregate s per rep, per year-month
WITH MonthlySales AS (
    SELECT
        per.FirstName + ' ' + per.LastName  AS SalesRep,
        YEAR(soh.OrderDate) AS OrderYear,
        MONTH(soh.OrderDate) AS OrderMonth,
        SUM(soh.SubTotal) AS TotalSales
    FROM Sales.SalesOrderHeader soh
    INNER JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    INNER JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL -- exclude online / no-rep orders
    GROUP BY
        per.FirstName, per.LastName,
        YEAR(soh.OrderDate),
        MONTH(soh.OrderDate)
),

-- Step 2: Rank every rep within each (year, month) window - highest s -> rank 1
MonthlyRanked AS (
    SELECT
        SalesRep,
        OrderYear,
        OrderMonth,
        RANK() OVER (
            PARTITION BY OrderYear, OrderMonth
            ORDER BY TotalSales DESC
        ) AS MonthRank
    FROM MonthlySales
),

-- Step 3: Average the month ranks per rep per year
AvgYearlyRank AS (
    SELECT
        SalesRep,
        OrderYear,
        AVG(CAST(MonthRank AS DECIMAL(10, 2))) AS AvgRank
    FROM MonthlyRanked
    GROUP BY SalesRep, OrderYear
)

-- Step 4: Pivot years as columns
SELECT
    SalesRep AS [Sales Representative],
    ROUND(MAX(CASE WHEN OrderYear = 2022 THEN AvgRank END), 2) AS [2022],
    ROUND(MAX(CASE WHEN OrderYear = 2023 THEN AvgRank END), 2) AS [2023],
    ROUND(MAX(CASE WHEN OrderYear = 2024 THEN AvgRank END), 2) AS [2024],
    ROUND(MAX(CASE WHEN OrderYear = 2025 THEN AvgRank END), 2) AS [2025]
FROM AvgYearlyRank
GROUP BY SalesRep
ORDER BY SalesRep;