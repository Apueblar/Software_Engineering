-- LAB 2 - SQL
-- TASK 1 - OVER CLAUSE 
-- TASK 1.1: 
/* Assign a sequential number to each sales order based on the month (order date). Numbers each row
in the Sales.SalesOrderHeader table, ordered by the month from OrderDate. We want to get a
consecutive number for each order in each month. */
SELECT
    SalesOrderID,
    OrderDate,
    MONTH(OrderDate) AS [Month],
    YEAR(OrderDate) AS [Year],
    ROW_NUMBER() OVER (
        PARTITION BY YEAR(OrderDate), MONTH(OrderDate)
        ORDER BY OrderDate
    ) AS [Order Number in Month]
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;

-- TASK 1.2:
/* Rank products by their list price, with the most expensive product having the highest rank. Assign a
rank to each product in the Production.Product table based on its ListPrice in each category in a
descending order. Products with the same price receive the same rank. */
SELECT
    pc.Name AS [Category],
    p.Name AS [Product],
    p.ListPrice,
    RANK() OVER (
        PARTITION BY pc.ProductCategoryID
        ORDER BY p.ListPrice DESC
    ) AS [Price Rank]
FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
ORDER BY pc.Name, [Price Rank];

-- TASK 1.3:
/* Calculate the running total of the total amount due for sales orders over time in the year 2023.
Compute a cumulative sum of the TotalDue column in the Sales.SalesOrderHeader table for orders
placed in 2023, ordered by OrderDate. */
SELECT
    SalesOrderID,
    OrderDate,
    TotalDue,
    SUM(TotalDue) OVER (
        ORDER BY OrderDate
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS [Running Total]
FROM Sales.SalesOrderHeader
WHERE YEAR(OrderDate) = 2023
ORDER BY OrderDate;

-- TASK 1.4:
/* Compare the price of each product to the average price of all products within its subcategory. For each
product, calculate the average ListPrice of all products in the same subcategory and then determine
the difference between the product's price and this average. */
SELECT
    ps.Name AS [Subcategory],
    p.Name AS [Product],
    p.ListPrice,
    AVG(p.ListPrice) OVER (
        PARTITION BY p.ProductSubcategoryID
    ) AS [Subcategory Avg Price],
    p.ListPrice - AVG(p.ListPrice) OVER (
        PARTITION BY p.ProductSubcategoryID
    ) AS [Diff from Avg]
FROM Production.Product p
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.ListPrice > 0
ORDER BY ps.Name, p.ListPrice DESC;

-- TASK 1.5:
/* Calculate the moving average of the total amount due for sales orders, considering the current order
and the two preceding orders. Calculate the average of the TotalDue for the current row and the two
rows immediately preceding it in the Sales.SalesOrderHeader table, ordered by OrderDate. */
SELECT
    SalesOrderID,
    OrderDate,
    TotalDue,
    AVG(TotalDue) OVER (
        ORDER BY OrderDate
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS [3-Row Moving Avg]
FROM Sales.SalesOrderHeader
ORDER BY OrderDate;

-- TASK 1.6:
/* Determine the percentage of the total annual sales contributed by each salesperson. Calculate the
total sales for each salesperson in each year and then computes what percentage of the total sales for
that year each salesperson's sales represent. (Suggest using CTE, to group the data) */
WITH SalesPerPersonYear AS (
    SELECT
        SalesPersonID,
        YEAR(OrderDate) AS [Year],
        SUM(SubTotal) AS PersonYearSales
    FROM Sales.SalesOrderHeader
    WHERE SalesPersonID IS NOT NULL
      AND Status = 5
    GROUP BY SalesPersonID, YEAR(OrderDate)
)
SELECT
    sp.[Year],
    per.LastName + ', ' + per.FirstName AS [Salesperson],
    sp.PersonYearSales AS [Individual Sales],
    SUM(sp.PersonYearSales) OVER (
        PARTITION BY sp.[Year]
    ) AS [Total Annual Sales],
    sp.PersonYearSales * 100.0 / SUM(sp.PersonYearSales) OVER (PARTITION BY sp.[Year]) AS [% of Annual Sales]
FROM SalesPerPersonYear sp
    JOIN Sales.SalesPerson sls ON sp.SalesPersonID = sls.BusinessEntityID
    JOIN Person.Person per ON sls.BusinessEntityID = per.BusinessEntityID
ORDER BY sp.[Year], [% of Annual Sales] DESC;

-- TASK 1.7:
/* Calculate the total monthly sales per territory and compute a YTD (year to date, a sum of total sales
starting from the beginning of the year, up to the current month) running total (resetting each year)
and a 3-month moving average to show trend lines.
o A classic OLAP requirement is smoothing out volatile sales data to spot trends while tracking
cumulative progress toward annual goals. */
WITH MonthlyTerritoryS AS (
    SELECT
        soh.TerritoryID,
        st.Name AS TerritoryName,
        YEAR(soh.OrderDate) AS [Year],
        MONTH(soh.OrderDate) AS [Month],
        SUM(soh.SubTotal) AS MonthlySales
    FROM Sales.SalesOrderHeader  soh
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    WHERE soh.Status = 5
    GROUP BY soh.TerritoryID, st.Name, YEAR(soh.OrderDate), MONTH(soh.OrderDate)
)
SELECT
    TerritoryID,
    TerritoryName,
    [Year],
    [Month],
    MonthlySales,
    -- YTD: cumulative sum from January, resets each new year
    SUM(MonthlySales) OVER (
        PARTITION BY TerritoryID, [Year]
        ORDER BY [Month]
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    ) AS [YTD Sales],
    -- 3-month moving average: smooths short-term volatility
    AVG(MonthlySales) OVER (
        PARTITION BY TerritoryID, [Year]
        ORDER BY [Month]
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS [3-Month Moving Avg]
FROM MonthlyTerritoryS
ORDER BY TerritoryID, [Year], [Month];

-- TASK 1.8:
/* Calculate the total sales for each product category per year along with the previous year's sales, and
calculates the YoY percentage growth. Remember that there is a starting year, handle it gracefully.
o Comparing current performance to historical performance is a cornerstone of data
warehousing. */
WITH CategoryYearlySales AS (
    SELECT
        pc.ProductCategoryID,
        pc.Name AS CategoryName,
        YEAR(soh.OrderDate) AS [Year],
        SUM(sod.LineTotal) AS YearlySales
    FROM Sales.SalesOrderHeader soh
        JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
        JOIN Production.Product p ON sod.ProductID = p.ProductID
        JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        JOIN Production.ProductCategory  pc ON ps.ProductCategoryID = pc.ProductCategoryID
    WHERE soh.Status = 5
    GROUP BY pc.ProductCategoryID, pc.Name, YEAR(soh.OrderDate)
)
SELECT
    CategoryName,
    [Year],
    YearlySales AS [Current Year Sales],
    -- LAG fetches the previous row's YearlySales within the same category
    LAG(YearlySales) OVER (
        PARTITION BY ProductCategoryID
        ORDER BY [Year]
    ) AS [Previous Year Sales],
    -- YoY % growth; NULL for the first year (no prior data to compare)
    CASE
        WHEN LAG(YearlySales) OVER (
                PARTITION BY ProductCategoryID ORDER BY [Year]
             ) IS NULL
        THEN NULL
        ELSE ROUND(
            (YearlySales - LAG(YearlySales) OVER (
                PARTITION BY ProductCategoryID ORDER BY [Year]
            ))
            / LAG(YearlySales) OVER (
                PARTITION BY ProductCategoryID ORDER BY [Year]
            ) * 100,
        2)
    END AS [YoY Growth %]
FROM CategoryYearlySales
ORDER BY CategoryName, [Year];

-- TASK 1.9:
/* Find which specific products contribute to the top 80% of total company revenue. Hint – calculate the
cumulative sum of sales over the ordered products and divides it by the grand total to find the
cumulative percentage.
o Pareto analysis identifies the top-performing entities that drive the most value.  */
WITH ProductSales AS (
    SELECT
        p.ProductID,
        p.Name AS ProductName,
        SUM(sod.LineTotal) AS TotalRevenue
    FROM Sales.SalesOrderDetail sod
        JOIN Production.Product p ON sod.ProductID = p.ProductID
    GROUP BY p.ProductID, p.Name
),
CumulativeSales AS (
    SELECT
        ProductID,
        ProductName,
        TotalRevenue,
        -- Running total of revenue, ordered from highest to lowest
        SUM(TotalRevenue) OVER (
            ORDER BY TotalRevenue DESC
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) AS RunningTotal,
        -- Grand total (no ORDER BY = whole-partition aggregate)
        SUM(TotalRevenue) OVER () AS GrandTotal,
        -- Cumulative % at each product
        ROUND(
            SUM(TotalRevenue) OVER (
                ORDER BY TotalRevenue DESC
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            ) * 100.0
            / SUM(TotalRevenue) OVER (),
        2) AS [Cumulative %]
    FROM ProductSales
)
SELECT
    ProductID,
    ProductName,
    TotalRevenue,
    RunningTotal,
    [Cumulative %]
FROM CumulativeSales
WHERE [Cumulative %] - (TotalRevenue * 100.0 / GrandTotal) < 80
   -- keeps all products whose cumulative % was still below 80
   -- before the current product was added, plus the one that tips over
   OR [Cumulative %] <= 80
ORDER BY TotalRevenue DESC;