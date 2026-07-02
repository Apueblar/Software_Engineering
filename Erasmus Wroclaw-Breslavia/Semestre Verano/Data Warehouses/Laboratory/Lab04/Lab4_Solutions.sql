-- LOCAL SERVER:    LAPTOP-MKLCFCJ  (SQL Server 17 Enterprise Dev)
-- EXTERNAL SERVER: 156.17.130.187,22443 (must be on Eduroam or University VPN)
--                  Auth: SQL Login | user: dwuser | pass: dwpass
-- LAB 4
-- TASK 1 - SIMPLE QUERYING - Study sales rep performance
-- TASK 1.1: - Quarterly pivot WITHOUT PIVOT (using CASE)
SELECT
    per.FirstName + ' ' + per.LastName AS SalesPerson,
    SUM(CASE WHEN DATEPART(QUARTER, soh.OrderDate) = 1 THEN soh.SubTotal ELSE 0 END) AS Quarter1, -- If the quarter is not correct -> 0
    SUM(CASE WHEN DATEPART(QUARTER, soh.OrderDate) = 2 THEN soh.SubTotal ELSE 0 END) AS Quarter2,
    SUM(CASE WHEN DATEPART(QUARTER, soh.OrderDate) = 3 THEN soh.SubTotal ELSE 0 END) AS Quarter3,
    SUM(CASE WHEN DATEPART(QUARTER, soh.OrderDate) = 4 THEN soh.SubTotal ELSE 0 END) AS Quarter4
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp  ON soh.SalesPersonID   = sp.BusinessEntityID
JOIN Person.Person per ON sp.BusinessEntityID  = per.BusinessEntityID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY per.FirstName + ' ' + per.LastName
ORDER BY SalesPerson;

-- TASK 1.2: – Quarterly pivot WITH PIVOT operator (no CASE)
SELECT
    SalesPerson,
    ISNULL([1], 0) AS Quarter1,
    ISNULL([2], 0) AS Quarter2,
    ISNULL([3], 0) AS Quarter3,
    ISNULL([4], 0) AS Quarter4
FROM (
    SELECT
        per.FirstName + ' ' + per.LastName AS SalesPerson,
        DATEPART(QUARTER, soh.OrderDate) AS Quarter,
        soh.SubTotal
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL
) AS SourceData
PIVOT (
    SUM(SubTotal)
    FOR Quarter IN ([1], [2], [3], [4])
) AS PivotTable
ORDER BY SalesPerson;

-- TASK 1.3: – Quarterly pivot using CTEs (one CTE per quarter) (No OVER clause, no CASE clause)
WITH Q1 AS (
    SELECT
        per.FirstName + ' ' + per.LastName AS SalesPerson,
        SUM(soh.SubTotal) AS Quarter1
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL
      AND DATEPART(QUARTER, soh.OrderDate) = 1
    GROUP BY per.FirstName + ' ' + per.LastName
),
Q2 AS (
    SELECT
        per.FirstName + ' ' + per.LastName AS SalesPerson,
        SUM(soh.SubTotal) AS Quarter2
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL
      AND DATEPART(QUARTER, soh.OrderDate) = 2
    GROUP BY per.FirstName + ' ' + per.LastName
),
Q3 AS (
    SELECT
        per.FirstName + ' ' + per.LastName AS SalesPerson,
        SUM(soh.SubTotal) AS Quarter3
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL
      AND DATEPART(QUARTER, soh.OrderDate) = 3
    GROUP BY per.FirstName + ' ' + per.LastName
),
Q4 AS (
    SELECT
        per.FirstName + ' ' + per.LastName AS SalesPerson,
        SUM(soh.SubTotal) AS Quarter4
    FROM Sales.SalesOrderHeader soh
    JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
    JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
    WHERE soh.SalesPersonID IS NOT NULL
      AND DATEPART(QUARTER, soh.OrderDate) = 4
    GROUP BY per.FirstName + ' ' + per.LastName
)
SELECT
    COALESCE(Q1.SalesPerson, Q2.SalesPerson, Q3.SalesPerson, Q4.SalesPerson) AS SalesPerson,
    ISNULL(Q1.Quarter1, 0) AS Quarter1,
    ISNULL(Q2.Quarter2, 0) AS Quarter2,
    ISNULL(Q3.Quarter3, 0) AS Quarter3,
    ISNULL(Q4.Quarter4, 0) AS Quarter4
FROM Q1
FULL OUTER JOIN Q2 ON Q1.SalesPerson = Q2.SalesPerson
FULL OUTER JOIN Q3 ON COALESCE(Q1.SalesPerson, Q2.SalesPerson) = Q3.SalesPerson
FULL OUTER JOIN Q4 ON COALESCE(Q1.SalesPerson, Q2.SalesPerson, Q3.SalesPerson) = Q4.SalesPerson
ORDER BY SalesPerson;

-- TASK 1.4: – Yearly sales report WITHOUT windowed functions (Uses GROUP BY only)
SELECT
    per.FirstName + ' ' + per.LastName AS SalesPerson,
    sp.BusinessEntityID AS EmployeeID,
    YEAR(soh.OrderDate) AS Year,
    SUM(soh.SubTotal) AS SubTotal,
    COUNT(soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
WHERE soh.SalesPersonID IS NOT NULL
GROUP BY
    per.FirstName + ' ' + per.LastName,
    sp.BusinessEntityID,
    YEAR(soh.OrderDate)
ORDER BY SalesPerson, Year;

-- TASK 1.5 – Yearly sales report WITH windowed functions (OVER) - (Uses PARTITION BY)
SELECT DISTINCT
    per.FirstName + ' ' + per.LastName AS SalesPerson,
    sp.BusinessEntityID AS EmployeeID,
    YEAR(soh.OrderDate) AS Year,
    SUM(soh.SubTotal) OVER (PARTITION BY sp.BusinessEntityID, YEAR(soh.OrderDate)) AS SubTotal,
    COUNT(soh.SalesOrderID) OVER (PARTITION BY sp.BusinessEntityID, YEAR(soh.OrderDate)) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesPerson sp  ON soh.SalesPersonID  = sp.BusinessEntityID
JOIN Person.Person     per ON sp.BusinessEntityID = per.BusinessEntityID
WHERE soh.SalesPersonID IS NOT NULL
ORDER BY SalesPerson, Year;

-- TASK 1.6: – Yearly sales report using CTE (No OVER clause)
WITH YearlySales AS (
    SELECT
        soh.SalesPersonID,
        YEAR(soh.OrderDate)     AS Year,
        SUM(soh.SubTotal)       AS SubTotal,
        COUNT(soh.SalesOrderID) AS NumberOfOrders
    FROM Sales.SalesOrderHeader soh
    WHERE soh.SalesPersonID IS NOT NULL
    GROUP BY soh.SalesPersonID, YEAR(soh.OrderDate)
)
SELECT
    per.FirstName + ' ' + per.LastName AS SalesPerson,
    ys.SalesPersonID                   AS EmployeeID,
    ys.Year,
    ys.SubTotal,
    ys.NumberOfOrders
FROM YearlySales ys
JOIN Person.Person per ON ys.SalesPersonID = per.BusinessEntityID
ORDER BY SalesPerson, Year;


-- TASK 2 - SCHEMAS, INGESTING DATA, MOVING DATA
-- TASK 2.1: - Create the three schemas in YOUR local database
USE DW_Lab4;
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'SRC')
    EXEC('CREATE SCHEMA SRC');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'STAGE')
    EXEC('CREATE SCHEMA STAGE');
GO
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'DW')
    EXEC('CREATE SCHEMA DW');
GO

-- TASK 2.2: - Set up Linked Server to the external AdventureWorks
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = 'AW_EXTERNAL') -- Drop existing linked server if it exists
BEGIN
    EXEC sp_dropserver 'AW_EXTERNAL', 'droplogins';
END
GO

EXEC sp_addlinkedserver
    @server     = N'AW_EXTERNAL',
    @srvproduct = N'',
    @provider   = N'MSOLEDBSQL',          -- newer driver, preferred over SQLNCLI
    @datasrc    = N'156.17.130.187,22443',
    @provstr    = N'TrustServerCertificate=yes;';

EXEC sp_addlinkedsrvlogin
    @rmtsrvname  = N'AW_EXTERNAL',
    @useself     = N'False',
    @locallogin  = NULL,
    @rmtuser     = N'dwuser',
    @rmtpassword = N'dwpass';
GO

-- Test
SELECT TOP 5 * FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[Product];

-- SELECT * FROM OPENQUERY(AW_EXTERNAL, 'SELECT name FROM sys.databases ORDER BY name');

-- TASK 2.3: Extract source tables from external server (product tables + SalesOrderDetail) into [SRC]
-- Using SELECT INTO — creates the table and fills it in one shot
SELECT * INTO SRC.Product
FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[Product];

SELECT * INTO SRC.ProductSubcategory
FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[ProductSubcategory];

SELECT * INTO SRC.ProductCategory
FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[ProductCategory];

SELECT * INTO SRC.SalesOrderDetail
FROM [AW_EXTERNAL].[AdventureWorks2014].[Sales].[SalesOrderDetail];

-- Also need SalesOrderHeader for date joins in FactSales later
SELECT * INTO SRC.SalesOrderHeader
FROM [AW_EXTERNAL].[AdventureWorks2014].[Sales].[SalesOrderHeader];

-- Verify extraction completeness
-- Compare local SRC counts vs external source counts
-- Local counts (run on LAPTOP-MKLCFCJ):
SELECT 'SRC.Product' AS TableName, COUNT(*) AS LocalRows FROM SRC.Product UNION ALL
SELECT 'SRC.ProductSubcategory', COUNT(*) FROM SRC.ProductSubcategory UNION ALL
SELECT 'SRC.ProductCategory', COUNT(*) FROM SRC.ProductCategory UNION ALL
SELECT 'SRC.SalesOrderDetail', COUNT(*) FROM SRC.SalesOrderDetail UNION ALL
SELECT 'SRC.SalesOrderHeader', COUNT(*) FROM SRC.SalesOrderHeader;

-- External counts (match exactly):
SELECT 'Product' AS TableName, COUNT(*) AS ExternalRows FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[Product]           UNION ALL
SELECT 'ProductSubcategory', COUNT(*) FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[ProductSubcategory] UNION ALL
SELECT 'ProductCategory', COUNT(*) FROM [AW_EXTERNAL].[AdventureWorks2014].[Production].[ProductCategory]    UNION ALL
SELECT 'SalesOrderDetail', COUNT(*) FROM [AW_EXTERNAL].[AdventureWorks2014].[Sales].[SalesOrderDetail]        UNION ALL
SELECT 'SalesOrderHeader', COUNT(*) FROM [AW_EXTERNAL].[AdventureWorks2014].[Sales].[SalesOrderHeader];

-- TASK 2.4: Move SRC → STAGE and clean/transform the data (Flatten Product + SubCategory + Category into one wide table)
SELECT
    p.ProductID,
    p.Name                                            AS ProductName,
    p.ProductNumber,
    ISNULL(ps.Name, 'No Subcategory')                 AS SubCategory,
    ISNULL(pc.Name, 'No Category')                    AS Category,
    p.ListPrice,
    ISNULL(p.Color, 'Not Specified')                  AS Color,
    CASE p.ProductLine
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Standard'
        ELSE      'Not Applicable'
    END                                               AS ProductLine,
    CASE p.Class
        WHEN 'H' THEN 'High'
        WHEN 'M' THEN 'Medium'
        WHEN 'L' THEN 'Low'
        ELSE      'Not Applicable'
    END                                               AS Class,
    CASE p.Style
        WHEN 'W' THEN 'Womens'
        WHEN 'M' THEN 'Mens'
        WHEN 'U' THEN 'Universal'
        ELSE      'Not Applicable'
    END                                               AS Style,
    p.Weight,
    ISNULL(p.WeightUnitMeasureCode, 'N/A')            AS WeightUnit,
    p.Size,
    ISNULL(p.SizeUnitMeasureCode, 'N/A')              AS SizeUnit,
    p.StandardCost,
    p.SellStartDate,
    p.SellEndDate,
    CASE p.MakeFlag
        WHEN 1 THEN 'Yes'
        ELSE   'No'
    END                                               AS IsManufactured,
    CASE WHEN sold.ProductID IS NOT NULL THEN 'Yes'
         ELSE 'No'
    END                                               AS IsPurchasedAtleastOnce
INTO STAGE.Product
FROM SRC.Product p
LEFT JOIN SRC.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN SRC.ProductCategory    pc ON ps.ProductCategoryID   = pc.ProductCategoryID
LEFT JOIN (
    SELECT DISTINCT ProductID FROM SRC.SalesOrderDetail
) sold ON p.ProductID = sold.ProductID;

-- Quick data quality checks on STAGE.Product:
SELECT COUNT(*) AS TotalRows FROM STAGE.Product;
SELECT COUNT(*) AS NullNames FROM STAGE.Product WHERE ProductName IS NULL;
SELECT COUNT(*) AS NullCategory FROM STAGE.Product WHERE Category = 'No Category';
SELECT COUNT(*) AS NullColor FROM STAGE.Product WHERE Color = 'Not Specified';
SELECT DISTINCT ProductLine FROM STAGE.Product;
SELECT DISTINCT Class FROM STAGE.Product;
SELECT DISTINCT IsManufactured FROM STAGE.Product;
SELECT DISTINCT IsPurchasedAtleastOnce FROM STAGE.Product;

-- TASK 2.5: Create DW.DIMProduct with surrogate key (Cannot use SELECT INTO here because we need IDENTITY column)
CREATE TABLE DW.DIMProduct (
    ProductSK               INT IDENTITY(1,1) NOT NULL,
    ProductID               INT NOT NULL,
    ProductName             NVARCHAR(255) NOT NULL,
    ProductNumber           NVARCHAR(50) NOT NULL,
    SubCategory             NVARCHAR(100),
    Category                NVARCHAR(100),
    ListPrice               MONEY,
    Color                   NVARCHAR(50),
    ProductLine             NVARCHAR(50),
    Class                   NVARCHAR(50),
    Style                   NVARCHAR(50),
    Weight                  DECIMAL(8,2),
    WeightUnit              NVARCHAR(10),
    Size                    NVARCHAR(20),
    SizeUnit                NVARCHAR(10),
    StandardCost            MONEY,
    SellStartDate           DATETIME,
    SellEndDate             DATETIME,
    IsManufactured          NVARCHAR(3),
    IsPurchasedAtleastOnce  NVARCHAR(3),
    CONSTRAINT PK_DIMProduct PRIMARY KEY (ProductSK)
);
GO

INSERT INTO DW.DIMProduct (
    ProductID, ProductName, ProductNumber, SubCategory, Category,
    ListPrice, Color, ProductLine, Class, Style,
    Weight, WeightUnit, Size, SizeUnit,
    StandardCost, SellStartDate, SellEndDate,
    IsManufactured, IsPurchasedAtleastOnce
)
SELECT
    ProductID, ProductName, ProductNumber, SubCategory, Category,
    ListPrice, Color, ProductLine, Class, Style,
    Weight, WeightUnit, Size, SizeUnit,
    StandardCost, SellStartDate, SellEndDate,
    IsManufactured, IsPurchasedAtleastOnce
FROM STAGE.Product;

-- Verify: counts must match
SELECT COUNT(*) AS DIMProductRows FROM DW.DIMProduct;
SELECT COUNT(*) AS StageRows      FROM STAGE.Product;

-- Check no duplicate ProductIDs
SELECT ProductID, COUNT(*) AS Cnt
FROM DW.DIMProduct
GROUP BY ProductID
HAVING COUNT(*) > 1;
-- Expected: 0 rows returned

-- TASK 2.6: Create DW.DimDate (date dimension)
-- Range: 01.01.2010 – 31.12.2020
IF OBJECT_ID('DW.DimDate', 'U') IS NOT NULL DROP TABLE DW.DimDate;
GO

DECLARE @StartDate DATE = '2010-01-01';
DECLARE @EndDate   DATE = '2020-12-31';

;WITH DateSequence AS (
    SELECT @StartDate AS DateValue
    UNION ALL
    SELECT DATEADD(DAY, 1, DateValue)
    FROM DateSequence
    WHERE DateValue < @EndDate
)
SELECT
    CONVERT(INT, CONVERT(CHAR(8), DateValue, 112))              AS DateID,           -- YYYYMMDD – PK
    DateValue                                                   AS [Date],
    CONVERT(CHAR(10), DateValue, 105)                           AS [Date (EUStyle)],  -- DD-MM-YYYY
    YEAR(DateValue)                                             AS [Year],
    DATEPART(QUARTER, DateValue)                                AS [Quarter],
    MONTH(DateValue)                                            AS [Month Number],
    DATENAME(MONTH, DateValue)                                  AS [Month Name],
    DAY(DateValue)                                              AS [Day Number of Month],
    DATEPART(WEEKDAY, DateValue)                                AS [Day of Week Number],
    DATENAME(WEEKDAY, DateValue)                                AS [Day Name],
    CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1, 7)
         THEN 'Weekend' ELSE 'Weekday'
    END                                                         AS [Day Type],
    DATEPART(ISO_WEEK, DateValue)                               AS [Week Number],
    CAST(DATEADD(DAY, 1 - DAY(DateValue), DateValue) AS DATE)  AS [First Day of Month],
    CAST(EOMONTH(DateValue) AS DATE)                            AS [Last Day of Month],
    CASE WHEN DATEPART(WEEKDAY, DateValue) IN (1, 7) THEN 1 ELSE 0 END  AS [IsWeekend],
    CASE WHEN DAY(DateValue) = 1 THEN 1 ELSE 0 END              AS [IsFirstDayOfMonth],
    CASE WHEN DateValue = EOMONTH(DateValue) THEN 1 ELSE 0 END  AS [IsLastDayOfMonth]
INTO DW.DimDate
FROM DateSequence
OPTION (MAXRECURSION 5000);
GO

ALTER TABLE DW.DimDate
ALTER COLUMN DateID INT NOT NULL;
GO

ALTER TABLE DW.DimDate
ADD CONSTRAINT PK_DimDate PRIMARY KEY (DateID);
GO

-- TASK 2.7: Verify DimDate
-- g. Total rows = 4018
SELECT COUNT(*) AS TotalDays FROM DW.DimDate;

-- h. Unique years = 11
SELECT COUNT(DISTINCT [Year]) AS UniqueYears FROM DW.DimDate;

-- i. Unique year-month combos = 132
SELECT COUNT(DISTINCT CAST([Year] AS NVARCHAR(4)) + '-' + CAST([Month Number] AS NVARCHAR(2)))
    AS YearMonthCombinations
FROM DW.DimDate;

-- j. 5 random rows – manually verify values make sense
SELECT TOP 5 * FROM DW.DimDate ORDER BY NEWID();

-- Spot-check known dates:
SELECT * FROM DW.DimDate WHERE [Date] = '2020-01-04'; -- Saturday → Weekend
SELECT * FROM DW.DimDate WHERE [Date] = '2020-01-06'; -- Monday  → Weekday
SELECT * FROM DW.DimDate WHERE [Date] = '2015-03-15'; -- Sunday  → Weekend, Q1

-- TASK 2.8: Create DW.FactSales
CREATE TABLE DW.FactSales (
    SalesOrderID        INT      NOT NULL,
    SalesOrderDetailID  INT      NOT NULL,
    ProductSK           INT      NOT NULL,
    OrderDateID         INT      NOT NULL,
    DueDateID           INT      NOT NULL,
    ShipDateID          INT      NULL,
    UnitPrice           MONEY    NOT NULL,
    OrderQty            SMALLINT NOT NULL,
    UnitPriceDiscount   MONEY    NOT NULL,
    TotalValue          MONEY    NOT NULL,
    TotalDiscountValue  MONEY    NOT NULL,
    CONSTRAINT PK_FactSales PRIMARY KEY (SalesOrderID, SalesOrderDetailID),
    CONSTRAINT CHK_FactSales_Qty        CHECK (OrderQty > 0),
    CONSTRAINT CHK_FactSales_Price      CHECK (UnitPrice >= 0),
    CONSTRAINT CHK_FactSales_Total      CHECK (TotalValue >= 0)
);
GO

INSERT INTO DW.FactSales (
    SalesOrderID, SalesOrderDetailID, ProductSK,
    OrderDateID, DueDateID, ShipDateID,
    UnitPrice, OrderQty, UnitPriceDiscount,
    TotalValue, TotalDiscountValue
)
SELECT
    sod.SalesOrderID,
    sod.SalesOrderDetailID,
    dp.ProductSK,
    CONVERT(INT, CONVERT(CHAR(8), soh.OrderDate, 112)) AS OrderDateID,
    CONVERT(INT, CONVERT(CHAR(8), soh.DueDate,  112)) AS DueDateID,
    CONVERT(INT, CONVERT(CHAR(8), soh.ShipDate, 112)) AS ShipDateID,
    sod.UnitPrice,
    sod.OrderQty,
    sod.UnitPriceDiscount,
    sod.OrderQty * sod.UnitPrice * (1 - sod.UnitPriceDiscount) AS TotalValue,
    sod.OrderQty * sod.UnitPrice * sod.UnitPriceDiscount       AS TotalDiscountValue
FROM SRC.SalesOrderDetail sod
JOIN SRC.SalesOrderHeader soh ON sod.SalesOrderID  = soh.SalesOrderID
JOIN DW.DIMProduct        dp  ON sod.ProductID     = dp.ProductID;
GO

-- Add Foreign Keys
ALTER TABLE DW.FactSales ADD
    CONSTRAINT FK_FactSales_DIMProduct     FOREIGN KEY (ProductSK)   REFERENCES DW.DIMProduct(ProductSK),
    CONSTRAINT FK_FactSales_DimDate_Order  FOREIGN KEY (OrderDateID) REFERENCES DW.DimDate(DateID),
    CONSTRAINT FK_FactSales_DimDate_Due    FOREIGN KEY (DueDateID)   REFERENCES DW.DimDate(DateID);
GO

-- Verify FactSales
SELECT COUNT(*) AS FactSalesRows FROM DW.FactSales;
SELECT COUNT(*) AS SourceRows    FROM SRC.SalesOrderDetail;
-- Must be equal

SELECT SUM(TotalValue) AS FactTotal   FROM DW.FactSales;
SELECT SUM(LineTotal)  AS SourceTotal FROM SRC.SalesOrderDetail;
-- Must be equal (or within rounding margin)


-- TASK 3 - DESIGN ONLY (no SQL needed)
-- Approach: Add rating columns directly to DIMProduct.
--
-- Reasoning: Rating is a property of the product, not a separate
-- business event. Since analysts want to study sales filtered/grouped
-- by product rating, the rating belongs in the product dimension.
-- A separate DIMRating table would add unnecessary complexity for
-- this use case (sales analysis, not review analysis).
--
-- Columns added to DIMProduct:
--   AverageRating     DECIMAL(3,2)  -- avg score 0.00–5.00
--   NumberOfReviews   INT           -- how many reviews
--   ReviewLocation    NVARCHAR(100) -- where reviews came from
--
-- Updated model:
--   DimDate ──┐
--             ├──  FactSales  ──── DIMProduct (+ Rating columns)


-- TASK 4 - ENRICH PRODUCT: CSV INGESTION + INTEGRATION
-- TASK 4.1: Create EXT schema and landing table for CSV
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'EXT')
    EXEC('CREATE SCHEMA EXT');
GO

DROP TABLE IF EXISTS EXT.ProductReview;
GO

CREATE TABLE EXT.ProductReview (
    ReviewID       NVARCHAR(20)  NULL,   -- reviewid
    ProductID      NVARCHAR(20)  NULL,   -- productid
    ReviewDate     NVARCHAR(20)  NULL,   -- date        (mixed: serial number OR 'MM/DD/YYYY')
    RatingWebsite  NVARCHAR(20)  NULL,   -- ratingWebsite  (0–10 scale)
    RatingShipping NVARCHAR(20)  NULL,   -- ratingShipping (0–10 scale)
    RatingProduct  NVARCHAR(20)  NULL,   -- ratingProduct  (0–10 scale)
    RatingOverall  NVARCHAR(20)  NULL,   -- ratingOverall  (avg of above; 0–10)
    Gender         NVARCHAR(50)  NULL,   -- gender
    Email          NVARCHAR(100) NULL,   -- email      (max observed: 37 chars)
    Job            NVARCHAR(100) NULL,   -- job        (max observed: 36 chars)
    PostCode       NVARCHAR(20)  NULL,   -- postCode   (all current values = 0)
    Source         NVARCHAR(50)  NULL,   -- source     (Twitter/Google/TikTok/etc.)
    DidPurchase    NVARCHAR(10)  NULL,   -- didPurchase ('TRUE' or '0')
    DidRecommend   NVARCHAR(10)  NULL,   -- didRecommend (0 or 1)
    IsUsefull      NVARCHAR(10)  NULL,   -- isUsefull  (vote count 0–33+, NOT a flag)
    UserAgent      NVARCHAR(500) NULL,   -- userAgent  (max observed: 244 chars)
    IP             NVARCHAR(50)  NULL    -- ip
);
GO

--SELECT servicename, service_account 
--FROM sys.dm_server_services;
 
-- Load the CSV file (adjust path to where you saved DW2526-LAB-Rating.csv)
BULK INSERT EXT.ProductReview
FROM 'C:\Temp\DWI-LAB-Rating.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
);

SELECT COUNT(*) AS LoadedRows_ProductReview FROM EXT.ProductReview;   -- expected: 1249
SELECT * FROM EXT.ProductReview;
GO

-- Create EXT.IPLocation
DROP TABLE IF EXISTS EXT.IPLocation;
GO

CREATE TABLE EXT.IPLocation (
    City        NVARCHAR(100) NULL, -- city
    Country     NVARCHAR(100) NULL, -- country
    CountryCode NVARCHAR(10)  NULL, -- countrycode
    Continent   NVARCHAR(100) NULL, -- continent
    IP          NVARCHAR(50)  NULL  -- ip
);
GO

BULK INSERT EXT.IPLocation
FROM 'C:\Temp\DWI-LAB-IPlocation.csv'
WITH (
    FORMAT = 'CSV',
    FIRSTROW = 2
);
GO

SELECT COUNT(*) AS LoadedRows_IPLocation FROM EXT.IPLocation; -- expected: 500
GO

-- TASK 4.2: Move EXT.ProductReview → STAGE.ProductRating
-- Step 1: build per-review enriched staging (review + location)
-- Most-common country per product used as ReviewLocation
WITH ReviewWithLocation AS (
    SELECT
        TRY_CAST(pr.productid AS INT) AS ProductID,
        TRY_CAST(pr.RatingOverall AS DECIMAL(10,7)) AS RatingOverall,
        ISNULL(il.Country, 'Unknown') AS Country
    FROM EXT.ProductReview pr
    LEFT JOIN EXT.IPLocation il ON pr.IP = il.IP
    WHERE TRY_CAST(pr.productid AS INT) IS NOT NULL
),
-- Step 2: dominant country per product (most reviews from)
DominantCountry AS (
    SELECT
        ProductID,
        Country AS ReviewLocation,
        ROW_NUMBER() OVER (
            PARTITION BY ProductID
            ORDER BY COUNT(*) DESC
        ) AS rn
    FROM ReviewWithLocation
    GROUP BY ProductID, Country
),
-- Step 3: aggregated rating per product
Aggregated AS (
    SELECT
        ProductID,
        -- normalize 0-10 → 0-5 to fit DECIMAL(3,2) and check constraint
        CAST(AVG(RatingOverall) / 2.0 AS DECIMAL(3,2)) AS Rating,
        COUNT(*) AS NumberOfReviews
    FROM ReviewWithLocation
    GROUP BY ProductID
)
SELECT
    a.ProductID,
    LTRIM(RTRIM(sp.Name)) AS ProductName,
    a.Rating,
    a.NumberOfReviews,
    ISNULL(dc.ReviewLocation, 'Unknown') AS ReviewLocation
INTO STAGE.ProductRating
FROM Aggregated a
JOIN SRC.Product sp    ON a.ProductID = sp.ProductID    -- get ProductName
LEFT JOIN DominantCountry dc ON a.ProductID = dc.ProductID AND dc.rn = 1;

-- Quality checks (now Rating is 0-5, so check passes correctly)
SELECT ProductID, COUNT(*) AS Cnt
FROM STAGE.ProductRating
GROUP BY ProductID HAVING COUNT(*) > 1; -- expect 0

SELECT COUNT(*) AS BadRatings
FROM STAGE.ProductRating
WHERE Rating < 0 OR Rating > 5; -- expect 0

-- TASK 4.3: Add rating columns to STAGE.Product and update
ALTER TABLE STAGE.Product
ADD Rating          DECIMAL(3,2)  NULL,
    NumberOfReviews INT           NULL,
    ReviewLocation  NVARCHAR(100) NULL;
GO

UPDATE sp
SET
    sp.Rating          = sr.Rating,
    sp.NumberOfReviews = sr.NumberOfReviews,
    sp.ReviewLocation  = sr.ReviewLocation
FROM STAGE.Product sp
JOIN STAGE.ProductRating sr ON sp.ProductID = sr.ProductID;

-- TASK 4.4: Add rating columns to DW.DIMProduct and update
-- Using INSERT INTO logic: table already exists — cannot SELECT INTO
-- Primary key (ProductSK) is preserved since table was created with IDENTITY
ALTER TABLE DW.DIMProduct
ADD Rating          DECIMAL(3,2)  NULL,
    NumberOfReviews INT           NULL,
    ReviewLocation  NVARCHAR(100) NULL;
GO

-- Update existing DIMProduct rows with rating data
UPDATE dp
SET
    dp.Rating          = sp.Rating,
    dp.NumberOfReviews = sp.NumberOfReviews,
    dp.ReviewLocation  = sp.ReviewLocation
FROM DW.DIMProduct dp
JOIN STAGE.Product sp ON dp.ProductID = sp.ProductID;
GO

-- Verify
SELECT COUNT(*) AS TotalProducts    FROM DW.DIMProduct;
SELECT COUNT(*) AS RatedProducts    FROM DW.DIMProduct WHERE Rating IS NOT NULL;
SELECT COUNT(*) AS UnratedProducts  FROM DW.DIMProduct WHERE Rating IS NULL;

-- Spot-check 5 enriched products
SELECT TOP 5 ProductID, ProductName, Rating, NumberOfReviews, ReviewLocation
FROM DW.DIMProduct
WHERE Rating IS NOT NULL
ORDER BY NEWID();


-- TASK 5 - INCREMENTAL UPDATE WITH DW2526-LAB-RatingNEW.csv
-- TASK 5.1: Load new CSV into EXT
CREATE TABLE EXT.ProductRatingNEW (
    ProductID       INT,
    ProductName     NVARCHAR(255),
    Rating          DECIMAL(3,2),
    NumberOfReviews INT,
    ReviewLocation  NVARCHAR(100)
);
GO

BULK INSERT EXT.ProductRatingNEW
FROM 'C:\Data\DW2526-LAB-RatingNEW.csv'
WITH (
    FORMAT          = 'CSV',
    FIRSTROW        = 2,
    FIELDTERMINATOR = ',',
    ROWTERMINATOR   = '\n',
    TABLOCK
);
GO

SELECT COUNT(*) AS NewFileRows FROM EXT.ProductRatingNEW;

-- TASK 5.2: Clean new data into STAGE
SELECT
    ProductID,
    LTRIM(RTRIM(ProductName))                       AS ProductName,
    ISNULL(Rating, 0)                               AS Rating,
    ISNULL(NumberOfReviews, 0)                      AS NumberOfReviews,
    ISNULL(LTRIM(RTRIM(ReviewLocation)), 'Unknown') AS ReviewLocation
INTO STAGE.ProductRatingNEW
FROM EXT.ProductRatingNEW
WHERE ProductID IS NOT NULL;
GO

-- TASK 5.3: MERGE new ratings into STAGE.ProductRating
-- Updates existing rows; inserts brand new ones
DECLARE @MergeLog TABLE (Action NVARCHAR(10));

MERGE INTO STAGE.ProductRating AS Target
USING STAGE.ProductRatingNEW   AS Source
ON (Target.ProductID = Source.ProductID)

WHEN MATCHED THEN
    UPDATE SET
        Target.Rating          = Source.Rating,
        Target.NumberOfReviews = Source.NumberOfReviews,
        Target.ReviewLocation  = Source.ReviewLocation
 
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, ProductName, Rating, NumberOfReviews, ReviewLocation)
    VALUES (Source.ProductID, Source.ProductName, Source.Rating,
            Source.NumberOfReviews, Source.ReviewLocation)

OUTPUT $action INTO @MergeLog;

-- See what changed
SELECT Action, COUNT(*) AS Count
FROM @MergeLog
GROUP BY Action;
-- Shows: INSERT = X new rows, UPDATE = Y changed rows

-- TASK 5.4: Propagate merged ratings up to DW.DIMProduct
-- Update products that already exist in DIMProduct
UPDATE dp
SET
    dp.Rating          = sr.Rating,
    dp.NumberOfReviews = sr.NumberOfReviews,
    dp.ReviewLocation  = sr.ReviewLocation
FROM DW.DIMProduct dp
JOIN STAGE.ProductRating sr ON dp.ProductID = sr.ProductID;
GO

-- Insert any completely new products from the new file
-- (only if they also exist in the base product catalog)
INSERT INTO DW.DIMProduct (
    ProductID, ProductName, ProductNumber, SubCategory, Category,
    ListPrice, Color, ProductLine, Class, Style,
    Weight, WeightUnit, Size, SizeUnit, StandardCost,
    SellStartDate, SellEndDate, IsManufactured, IsPurchasedAtleastOnce,
    Rating, NumberOfReviews, ReviewLocation
)
SELECT
    sp.ProductID, sp.ProductName, sp.ProductNumber,
    sp.SubCategory, sp.Category, sp.ListPrice,
    sp.Color, sp.ProductLine, sp.Class, sp.Style,
    sp.Weight, sp.WeightUnit, sp.Size, sp.SizeUnit,
    sp.StandardCost, sp.SellStartDate, sp.SellEndDate,
    sp.IsManufactured, sp.IsPurchasedAtleastOnce,
    sr.Rating, sr.NumberOfReviews, sr.ReviewLocation
FROM STAGE.ProductRating sr
JOIN STAGE.Product sp ON sr.ProductID = sp.ProductID
WHERE NOT EXISTS (
    SELECT 1 FROM DW.DIMProduct dp WHERE dp.ProductID = sr.ProductID
);
GO

-- TASK 5.5: Final verification
SELECT COUNT(*) AS FinalDIMProductCount   FROM DW.DIMProduct;
SELECT COUNT(*) AS RatedProductsFinal     FROM DW.DIMProduct WHERE Rating IS NOT NULL;

-- No orphaned FK references in FactSales after new products added
SELECT COUNT(*) AS OrphanedFKRows
FROM DW.FactSales f
WHERE NOT EXISTS (
    SELECT 1 FROM DW.DIMProduct dp WHERE dp.ProductSK = f.ProductSK
);
-- Expected: 0