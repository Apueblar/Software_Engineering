-- LAB 1 - SQL
-- TASK 1 - SQL QUERIES 
-- TASK 1.1: 
/* Provide information about the global sales amount (money), number of orders and volume (items
sold) of the AdventureWorks business. */
SELECT 
    SUM(soh.SubTotal) AS [Sales Amount], -- Adding the subtotal of all the salesHeader
    SUM(sod.Volume) AS Volume, -- Calculating per salesHeader the addition of all the quantities of each associated sod
    COUNT(*) AS [Number Orders] -- Total number of orders
FROM Sales.SalesOrderHeader soh
CROSS APPLY (
    SELECT SUM(OrderQty) AS Volume
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = soh.SalesOrderID
) sod
WHERE soh.Status = 5;

-- TASK 1.2:
/* Provide information about the sales amount, volume, and number of orders in individual years of
operation of the business */
SELECT
    YEAR(soh.OrderDate) AS Year,
    SUM(soh.SubTotal) AS [Sales Amount], -- Adding the subtotal of all the salesHeader
    SUM(sod.Volume) AS Volume, -- Calculating per salesHeader the addition of all the quantities of each associated sod
    COUNT(*) AS [Number Orders] -- Total number of orders
FROM Sales.SalesOrderHeader soh
CROSS APPLY (
    SELECT SUM(OrderQty) AS Volume
    FROM Sales.SalesOrderDetail
    WHERE SalesOrderID = soh.SalesOrderID
) sod
WHERE soh.Status = 5
GROUP BY YEAR(soh.OrderDate)
ORDER BY YEAR(soh.OrderDate);

-- TASK 1.3:
/* Prepare a SQL query that provides top 5 customers with the highest number of orders, try using the
customer name */
SELECT TOP 5
    c.CustomerID,
    ISNULL(p.LastName + ', ' + p.FirstName, s.Name) AS [Last name, name],
    COUNT(soh.SalesOrderID) AS [Number of orders]
FROM Sales.SalesOrderHeader soh
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
GROUP BY
    c.CustomerID,
    ISNULL(p.LastName + ', ' + p.FirstName, s.Name)
ORDER BY [Number of orders] DESC;

-- TASK 1.4:
/* Prepare a SQL query that provides the names of all individual customers with the total sum of
purchases (use SalesOrderHeader.SubTotal) greater than 1500USD – sorted (descending) by the total
sales amount */
SELECT
    c.CustomerID,
    p.LastName + ', ' + p.FirstName AS [Last name, name],
    SUM(soh.SubTotal) AS SalesAmount
FROM Sales.SalesOrderHeader soh
    JOIN Sales.Customer c ON soh.CustomerID = c.CustomerID
    JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
WHERE c.StoreID IS NULL
GROUP BY
    c.CustomerID,
    p.LastName,
    p.FirstName
HAVING SUM(soh.SubTotal) > 1500
ORDER BY SalesAmount DESC;

-- TASK 1.5:
/* Prepare a query that provides information about average price, total sales amount, and total volume
in individual product categories of the AdventureWorks business */
SELECT
    pc.ProductCategoryID AS CategoryID,
    pc.Name AS [Category name],
    AVG(p.ListPrice) AS [Average price],
    SUM(sod.LineTotal) AS [Total Sales Amount],
    SUM(sod.OrderQty) AS [Total Volume]
FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY
    pc.ProductCategoryID,
    pc.Name;

-- TASK 1.6:
/* Display all subcategories which average price is higher than the average price of all categories. */
SELECT
    ps.ProductSubcategoryID AS SubcategoryID,
    ps.Name AS [Subcategory Name],
    AVG(p.ListPrice) AS [Average price],
    (SELECT AVG(ListPrice)
     FROM Production.Product
     WHERE ListPrice > 0) AS [Average price (over all categories)]
FROM Production.Product p
    JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE p.ListPrice > 0
GROUP BY
    ps.ProductSubcategoryID,
    ps.Name
HAVING AVG(p.ListPrice) >
    (SELECT AVG(ListPrice)
     FROM Production.Product
     WHERE ListPrice > 0)
ORDER BY [Average price] DESC;

-- TASK 1.7:
/* Select sales territory (name) with sales in May 2023 higher than the average monthly sales per sales
territory */
WITH MonthlySalesPerTerritory AS (
    -- All months across all years for computing the average
    SELECT
        TerritoryID,
        YEAR(OrderDate) AS [Year],
        MONTH(OrderDate) AS [Month],
        SUM(SubTotal) AS MonthlySales
    FROM Sales.SalesOrderHeader
    GROUP BY TerritoryID, YEAR(OrderDate), MONTH(OrderDate)
), AvgMonthly AS (
    SELECT
        TerritoryID,
        AVG(MonthlySales) AS AvgMonthlySales
    FROM MonthlySalesPerTerritory
    GROUP BY TerritoryID
), May2023 AS (
    SELECT
        TerritoryID,
        SUM(SubTotal) AS May2023Sales
    FROM Sales.SalesOrderHeader
    WHERE YEAR(OrderDate) = 2023
      AND MONTH(OrderDate) = 5
    GROUP BY TerritoryID
)
SELECT
    st.TerritoryID AS SalesTerritoryID,
    st.Name AS [Sales Territory Name],
    m.May2023Sales AS [Sales (May 2023)],
    a.AvgMonthlySales AS [Average monthly sales (per territory)]
FROM May2023 m
    JOIN AvgMonthly a ON m.TerritoryID = a.TerritoryID
    JOIN Sales.SalesTerritory st ON m.TerritoryID = st.TerritoryID
WHERE m.May2023Sales > a.AvgMonthlySales
ORDER BY m.May2023Sales DESC;

-- TASK 1.8:
/* Create a list of sales territories (ids are enough) with an average number of orders (both real value and
the largest integer less than the value) made by customers who have more than 10 orders in general
(use CTE) */
WITH CustomersOver10 AS (
    -- Customers with more than 10 orders in total (globally)
    SELECT
        CustomerID,
        COUNT(SalesOrderID) AS TotalOrders
    FROM Sales.SalesOrderHeader
    GROUP BY CustomerID
    HAVING COUNT(SalesOrderID) > 10
),
OrdersPerCustomerPerTerritory AS (
    -- For those customers, count their orders within each territory
    SELECT
        soh.TerritoryID,
        soh.CustomerID,
        COUNT(soh.SalesOrderID) AS OrdersInTerritory
    FROM Sales.SalesOrderHeader soh
        JOIN CustomersOver10 co ON soh.CustomerID = co.CustomerID
    GROUP BY soh.TerritoryID, soh.CustomerID
)
SELECT
    TerritoryID,
    AVG(CAST(OrdersInTerritory AS FLOAT)) AS [Average number of orders],
    FLOOR(AVG(CAST(OrdersInTerritory AS FLOAT))) AS [Average number of orders (INT)]
FROM OrdersPerCustomerPerTerritory
GROUP BY TerritoryID
ORDER BY TerritoryID;

-- TASK 1.9:
/* Show monthly sales amount by each sales territory in year 2023 and calculate the difference with
the previous month (use 0 for 12/2022) to identify trends */
WITH MonthlySales2023 AS (
    SELECT
        soh.TerritoryID,
        st.Name AS TerritoryName,
        MONTH(soh.OrderDate) AS Mnt,
        SUM(soh.SubTotal) AS SalesAmt
    FROM Sales.SalesOrderHeader soh
        JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
    WHERE YEAR(soh.OrderDate) = 2023
    GROUP BY soh.TerritoryID, st.Name, MONTH(soh.OrderDate)
)
SELECT
    TerritoryID,
    TerritoryName AS [Sales Territory Name],
    Mnt,
    SalesAmt AS [Sales Amt],
    -- LAG returns NULL for the first month (Jan 2023), ISNULL replaces it with 0
    SalesAmt - ISNULL(
        LAG(SalesAmt) OVER (PARTITION BY TerritoryID ORDER BY Mnt),
        0
    ) AS [Diff to prev]
FROM MonthlySales2023
ORDER BY TerritoryID, Mnt;

-- TASK 3.1:
/* Provides different product’s price categories:
a. ListPrice < 20.00 – Inexpensive
b. 20.00 < ListPrice < 75.00 – Regular
c. 75 < ListPrice < 750.00 – High
d. 750.00 < ListPrice – Expensive */
SELECT
    p.ProductID,
    p.Name AS [Product Name],
    p.ListPrice,
    CASE
        WHEN p.ListPrice = 0 THEN 'N/A (not for sale)'
        WHEN p.ListPrice < 20.00 THEN 'Inexpensive'
        WHEN p.ListPrice < 75.00 THEN 'Regular'
        WHEN p.ListPrice < 750.00 THEN 'High'
        ELSE 'Expensive'
    END AS [Price Category]
FROM Production.Product p
ORDER BY p.ListPrice;

-- TASK 3.2:
/* Provides information about total volume of product for different price categories and different
product categories – use price categories in columns, product categories in rows, and total volume as
values (0 - never sold a product from a given category); please use CASE to put years on columns */
SELECT
    ISNULL(pc.Name, 'No Category') AS [Product Category], -- USE PS for Subcategories
    -- Inexpensive: ListPrice > 0 AND < 20
    SUM(CASE
            WHEN p.ListPrice > 0  AND p.ListPrice < 20.00 THEN CAST(sod.OrderQty AS INT)
            ELSE 0
        END) AS Inexpensive,
    -- Regular: 20 <= ListPrice < 75
    SUM(CASE
            WHEN p.ListPrice >= 20.00 AND p.ListPrice < 75.00 THEN CAST(sod.OrderQty AS INT)
            ELSE 0
        END) AS Regular,
    -- High: 75 <= ListPrice < 750
    SUM(CASE
            WHEN p.ListPrice >= 75.00 AND p.ListPrice < 750.00 THEN CAST(sod.OrderQty AS INT)
            ELSE 0
        END) AS High,
    -- Expensive: ListPrice >= 750
    SUM(CASE
            WHEN p.ListPrice >= 750.00 THEN CAST(sod.OrderQty AS INT)
            ELSE 0
        END) AS Expensive
FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
    JOIN Production.Product p ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
WHERE soh.Status = 5
GROUP BY pc.Name -- USE PS for Subcategories
ORDER BY pc.Name; -- USE PS for Subcategories

-- TASK 4.1:
/* provides information about product’s subcategory, product’s colour and total sales value; please do
not use pivoting here – this will be our base query for the pivot. */
SELECT
    ISNULL(ps.Name, 'No Subcategory') AS [Subcategory Name],
    ISNULL(p.Color, 'N/A') AS Colour,
    SUM(sod.LineTotal) AS [Total Sales Value]
FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p  ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
GROUP BY
    ps.Name,
    p.Color
ORDER BY [Subcategory Name], Colour;

-- TASK 4.2:
/* provides information about total sales value for different colours of different product subcategories;
please put colours on columns, products’ subcategory names on rows, and total sales value as values;
use the query from the previous point. */
SELECT *
FROM (
    SELECT
        ISNULL(ps.Name, 'No Subcategory') AS SubcategoryName, -- ROWS (DO not pivot)
        ISNULL(p.Color, 'N/A') AS Colour,
        sod.LineTotal AS SalesValue
    FROM Sales.SalesOrderDetail sod
        JOIN Production.Product p ON sod.ProductID = p.ProductID
        LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
) AS source
PIVOT ( -- This are the column values
    SUM(SalesValue)
    FOR Colour IN (
        [Black], [Blue], [Grey], [Multi], [N/A],
        [Red], [Silver], [Silver/Black], [White], [Yellow]
    )
) AS pivoting
ORDER BY SubcategoryName;

/* a. please prepare a version of this query, where only subcategories from category Bike are
presented. */
SELECT *
FROM (
    SELECT
        ISNULL(ps.Name, 'No Subcategory') AS SubcategoryName, -- ROWS (DO not pivot)
        ISNULL(p.Color, 'N/A') AS Colour,
        sod.LineTotal AS SalesValue
    FROM Sales.SalesOrderDetail sod
        JOIN Production.Product p ON sod.ProductID = p.ProductID
        LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
        LEFT JOIN Production.ProductCategory pc ON pc.ProductCategoryID = ps.ProductCategoryID
    WHERE pc.Name = 'Bikes' -- ADDING This Where
) AS source
PIVOT ( -- This are the column values
    SUM(SalesValue)
    FOR Colour IN (
        [Black], [Blue], [Grey], [Multi], [N/A], [Red], [Silver], [Silver/Black], [White], [Yellow]
    )
) AS pivoting
ORDER BY SubcategoryName;

-- TASK 4.3:
/* provides information about average sales subtotal amounts in years and months; please put
months on columns, years on rows, and subtotal as values – do this without manually specifying all
individual years. */
SELECT *
FROM (
    SELECT
        YEAR(OrderDate) AS [Year],
        MONTH(OrderDate) AS [Month],
        SubTotal
    FROM Sales.SalesOrderHeader
    WHERE Status = 5
) AS source
PIVOT (
    SUM(Subtotal)
    FOR [Month] IN (
        [1],[2],[3],[4],[5],[6],[7],[8],[9],[10],[11],[12]
    )
) AS pivoting
ORDER BY [Year];

-- TASK 5.1:
/* provides total sales amount for different product categories along with a total value of sales for all
categories – use only one SELECT statement (do not use UNION) */
SELECT
    CASE
        WHEN GROUPING(pc.Name) = 1 THEN 'GRAND TOTAL' -- Can't use a simple WHERE pc.Name IS NULL
        ELSE ISNULL(pc.Name, 'No Category')
    END AS [Category Name],
    SUM(sod.LineTotal) AS [Total Sales Amount]
FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p  ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID   = pc.ProductCategoryID
GROUP BY ROLLUP(pc.Name) -- = GROUP BY pc.Name with a grand total -> pc.Name = NULL
ORDER BY GROUPING(pc.Name), pc.Name;

-- TASK 5.2:
/* provides total sales amount for different products (use product’s name) in different product
categories and subcategories – please provide sales summaries for: each category and subcategory,
each category, each subcategory and a total sales amount value (aggregated for all categories and
subcategories) – use only one SELECT statement (do not use UNION) */
SELECT
    CASE
        WHEN GROUPING(pc.Name) = 1 THEN NULL
        ELSE pc.Name
    END AS [Category Name],
    CASE
        WHEN GROUPING(ps.Name) = 1 THEN NULL
        ELSE ps.Name
    END AS [Subcategory Name],
    CASE
        WHEN GROUPING(p.Name) = 1 THEN NULL -- Addition of all p.Name => 1
        ELSE p.Name
    END AS [Product Name],
    SUM(sod.LineTotal) AS [Total Sales Amount]
FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p  ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory    pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY GROUPING SETS ( -- Detailed first, general later
    (pc.Name, ps.Name, p.Name), -- per product within its category & subcategory
    (pc.Name, ps.Name), -- per subcategory subtotal
    (pc.Name), -- per category subtotal
    () -- grand total
)
ORDER BY
    GROUPING(pc.Name), pc.Name,
    GROUPING(ps.Name), ps.Name,
    GROUPING(p.Name), p.Name;

-- TASK 5.3:
/* Provides total sales amount for each product category and colour (include products without specified
colour), total for each colour, total for each category and total sales amount:
a. Please use grouping function to identify the total sales amount from the sales amount for
products without specified colour */
SELECT
    -- Category label (NULL from CUBE becomes 'ALL CATEGORIES')
    CASE
        WHEN GROUPING(pc.Name)  = 1 THEN 'ALL CATEGORIES' -- Checking if Categories sum up => 1
        ELSE ISNULL(pc.Name, 'No Category')
    END AS [Category Name],
 
    -- Colour label (rollup NULL vs genuine NULL differentiated below)
    CASE
        WHEN GROUPING(p.Color) = 1 THEN 'ALL COLOURS' -- Checking if Color sum up => 1
        ELSE ISNULL(p.Color, 'No Colour')
    END AS [Color],
 
    SUM(sod.LineTotal) AS [Total Sales Amount],
 
    -- 5.3a: isolate sales from products that truly have no colour specified
    -- GROUPING() = 0 means this is a real data NULL, not a rollup row;
    -- combined with p.Color IS NULL it pinpoints "no colour" products only.
    CASE
        WHEN GROUPING(p.Color) = 0 AND p.Color IS NULL THEN SUM(sod.LineTotal)
        ELSE NULL
    END AS [Sales - No Colour Assigned],
 
    -- Helper columns to allow identifying row type in downstream tools
    GROUPING(pc.Name) AS [Is Category Rollup],
    GROUPING(p.Color) AS [Is Colour Rollup]
 
FROM Sales.SalesOrderDetail sod
    JOIN Production.Product p  ON sod.ProductID = p.ProductID
    LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
GROUP BY CUBE(pc.Name, p.Color) -- every combination in all directions
ORDER BY
    GROUPING(pc.Name), pc.Name,
    GROUPING(p.Color), p.Color;