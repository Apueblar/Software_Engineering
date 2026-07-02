-- ------------------------------------------------------------
-- TASK 1 - Create Star Schema Tables in SQL Server
-- Run against: StarSchema database (or AWStaging.Staging)
-- ------------------------------------------------------------

-- 0. Create / switch to the target database
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'StarSchema')
    CREATE DATABASE StarSchema;
GO
USE StarSchema;
GO

-- ------------------------------------------------------------
-- 1. Dimension: Product
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.dim_Product', 'U') IS NOT NULL
    DROP TABLE dbo.dim_Product;
GO

CREATE TABLE dbo.dim_Product (
    ProductKey          INT             PRIMARY KEY,
    ProductID           INT             NOT NULL,
    ProductName         NVARCHAR(50)    NOT NULL,
    ProductNumber       NVARCHAR(25)    NOT NULL,
    ProductSubcategory  NVARCHAR(50)    NULL,
    ProductCategory     NVARCHAR(50)    NULL,
    Color               NVARCHAR(15)    NULL,
    WeightClass         NVARCHAR(15)    NULL,   -- 'Light' / 'Medium' / 'Heavy' / 'Unknown'
    WeightKg            DECIMAL(8,2)    NULL,
    ListPrice           MONEY           NULL,
    StandardCost        MONEY           NULL,
    ProductProfit       AS (ISNULL(ListPrice, 0) - ISNULL(StandardCost, 0)),  -- computed
    -- Enrichment: ratings from rating.csv
    RatingAvg           DECIMAL(3,1)    NULL,
    RatingMin           DECIMAL(3,1)    NULL,
    RatingMax           DECIMAL(3,1)    NULL
);
GO

-- ------------------------------------------------------------
-- 2. Dimension: Salesperson
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.dim_Salesperson', 'U') IS NOT NULL
    DROP TABLE dbo.dim_Salesperson;
GO

CREATE TABLE dbo.dim_Salesperson (
    SalespersonKey      INT             PRIMARY KEY,
    BusinessEntityID    INT             NOT NULL,
    FirstName           NVARCHAR(50)    NOT NULL,
    MiddleName          NVARCHAR(50)    NULL,
    LastName            NVARCHAR(50)    NOT NULL,
    FullName            AS (FirstName + ISNULL(' ' + MiddleName, '') + ' ' + LastName),  -- computed
    SalesQuota          MONEY           NULL,
    Bonus               MONEY           NULL,
    CommissionPct       SMALLMONEY      NULL,
    TerritoryID         INT             NULL
);
GO

-- ------------------------------------------------------------
-- 3. Dimension: Sales Territory
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.dim_SalesTerritory', 'U') IS NOT NULL
    DROP TABLE dbo.dim_SalesTerritory;
GO

CREATE TABLE dbo.dim_SalesTerritory (
    TerritoryKey        INT             PRIMARY KEY,
    TerritoryID         INT             NOT NULL,
    TerritoryName       NVARCHAR(50)    NOT NULL,
    TerritoryCountry    NVARCHAR(50)    NOT NULL,
    TerritoryContinent  NVARCHAR(50)    NOT NULL
);
GO

-- ------------------------------------------------------------
-- 4. Dimension: Order Date
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.dim_OrderDate', 'U') IS NOT NULL
    DROP TABLE dbo.dim_OrderDate;
GO

CREATE TABLE dbo.dim_OrderDate (
    DateKey             INT             PRIMARY KEY,   -- e.g. 20110531
    FullDate            DATE            NOT NULL,
    DayOfMonth          TINYINT         NOT NULL,
    MonthNumber         TINYINT         NOT NULL,
    MonthName           NVARCHAR(10)    NOT NULL,
    Quarter             TINYINT         NOT NULL,      -- 1-4
    HalfYear            TINYINT         NOT NULL,      -- 1 or 2
    Year                SMALLINT        NOT NULL
);
GO

-- ------------------------------------------------------------
-- 5. Fact: Sales
-- ------------------------------------------------------------
IF OBJECT_ID('dbo.fact_Sales', 'U') IS NOT NULL
    DROP TABLE dbo.fact_Sales;
GO

CREATE TABLE dbo.fact_Sales (
    SalesFactKey        INT             IDENTITY(1,1) PRIMARY KEY,
    SalesOrderID        INT             NOT NULL,
    SalesOrderDetailID  INT             NOT NULL,
    -- Foreign keys to dimension tables
    ProductKey          INT             NOT NULL REFERENCES dbo.dim_Product(ProductKey),
    SalespersonKey      INT             NOT NULL REFERENCES dbo.dim_Salesperson(SalespersonKey),
    TerritoryKey        INT             NOT NULL REFERENCES dbo.dim_SalesTerritory(TerritoryKey),
    DateKey             INT             NOT NULL REFERENCES dbo.dim_OrderDate(DateKey),
    -- Measures
    OrderQty            SMALLINT        NOT NULL,
    UnitPrice           MONEY           NOT NULL,
    LineTotal           MONEY           NOT NULL,    -- original USD
    LineTotalPLN        MONEY           NULL,        -- converted at order-date rate
    UsdToPln            DECIMAL(10,4)   NULL,        -- rate used for conversion
    -- Optional enrichment (Task 7)
    PrevDayRate         DECIMAL(10,4)   NULL,
    RateTrend           NVARCHAR(10)    NULL         -- 'Rising' / 'Falling' / 'Stable'
);
GO
