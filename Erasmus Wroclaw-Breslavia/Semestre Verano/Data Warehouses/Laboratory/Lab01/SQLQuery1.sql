-- LAB 1 - SQL
-- TASK 2 - DATA MODELLING

--CREATE DATABASE OrdersDB;
--GO
--USE OrdersDB;
--GO

IF OBJECT_ID('dbo.OrderLine',    'U') IS NOT NULL DROP TABLE dbo.OrderLine;
IF OBJECT_ID('dbo.[Order]',      'U') IS NOT NULL DROP TABLE dbo.[Order];
IF OBJECT_ID('dbo.StoreProduct', 'U') IS NOT NULL DROP TABLE dbo.StoreProduct;
IF OBJECT_ID('dbo.Product',      'U') IS NOT NULL DROP TABLE dbo.Product;
IF OBJECT_ID('dbo.Category',     'U') IS NOT NULL DROP TABLE dbo.Category;
IF OBJECT_ID('dbo.Store',        'U') IS NOT NULL DROP TABLE dbo.Store;
IF OBJECT_ID('dbo.Customer',     'U') IS NOT NULL DROP TABLE dbo.Customer;

-- Category
CREATE TABLE dbo.Category (
    CategoryID INT NOT NULL IDENTITY(1,1),
    CategoryName NVARCHAR(100) NOT NULL,
    CONSTRAINT PK_Category PRIMARY KEY (CategoryID)
);

-- Product
CREATE TABLE dbo.Product (
    UPC NVARCHAR(13)   NOT NULL,   -- Unique barcode (R: defined by unique UPC)
    ProdName NVARCHAR(200)  NOT NULL,
    Manufacturer NVARCHAR(100)  NULL,
    Model NVARCHAR(100)  NULL,
    UnitListPrice DECIMAL(10,2) NOT NULL CHECK (UnitListPrice >= 0),
    CategoryID INT NOT NULL,
    CONSTRAINT PK_Product PRIMARY KEY (UPC),
    CONSTRAINT FK_Product_Cat FOREIGN KEY (CategoryID) REFERENCES dbo.Category(CategoryID)
);

-- Customer
CREATE TABLE dbo.Customer (
    CustomerID INT NOT NULL IDENTITY(1,1),
    CFirstName NVARCHAR(100) NOT NULL,
    CLastName NVARCHAR(100) NOT NULL,
    CPhone NVARCHAR(20) NULL,
    CStreet NVARCHAR(200) NULL,
    CZipCode NVARCHAR(20) NULL,
    -- R: discount cannot exceed 20% (domain constraint)
    Discount DECIMAL(5,2) NOT NULL DEFAULT 0
                CHECK (Discount >= 0 AND Discount <= 20),
    CONSTRAINT PK_Customer PRIMARY KEY (CustomerID)
);

-- Store
CREATE TABLE dbo.Store (
    StoreID INT NOT NULL IDENTITY(1,1),
    StoreName NVARCHAR(200) NOT NULL,
    StoreStreet NVARCHAR(200) NULL,
    StoreZip NVARCHAR(20)  NULL,
    CONSTRAINT PK_Store PRIMARY KEY (StoreID)
);

-- StoreProduct
CREATE TABLE dbo.StoreProduct (
    StoreID INT NOT NULL,
    UPC NVARCHAR(13)  NOT NULL,
    StorePrice DECIMAL(10,2) NOT NULL CHECK (StorePrice >= 0),
    StockQty INT NOT NULL CHECK (StockQty >= 0),
    CONSTRAINT PK_StoreProduct PRIMARY KEY (StoreID, UPC),
    CONSTRAINT FK_SP_Store   FOREIGN KEY (StoreID) REFERENCES dbo.Store(StoreID),
    CONSTRAINT FK_SP_Product FOREIGN KEY (UPC) REFERENCES dbo.Product(UPC)
);

-- Order
CREATE TABLE dbo.[Order] (
    OrderID INT NOT NULL IDENTITY(1,1),
    CustomerID INT NOT NULL,
    StoreID INT NOT NULL,
    OrderDateTime DATETIME   NOT NULL DEFAULT GETDATE(),  -- R03: day and time
    -- /total is a derived attribute – computed via view or trigger
    CONSTRAINT PK_Order     PRIMARY KEY (OrderID),
    CONSTRAINT FK_Order_Cust FOREIGN KEY (CustomerID) REFERENCES dbo.Customer(CustomerID),
    CONSTRAINT FK_Order_Store FOREIGN KEY (StoreID) REFERENCES dbo.Store(StoreID)
);

-- OrderLine
CREATE TABLE dbo.OrderLine (
    OrderID INT           NOT NULL,
    UPC NVARCHAR(13)  NOT NULL,
    Quantity INT NOT NULL CHECK (Quantity > 0),
    UnitSalePrice DECIMAL(10,2) NOT NULL CHECK (UnitSalePrice >= 0),
    -- /subtotal is derived: Quantity * UnitSalePrice  (stored for performance)
    Subtotal AS (Quantity * UnitSalePrice),
    CONSTRAINT PK_OrderLine PRIMARY KEY (OrderID, UPC),
    CONSTRAINT FK_OL_Order FOREIGN KEY (OrderID) REFERENCES dbo.[Order](OrderID),
    CONSTRAINT FK_OL_Product FOREIGN KEY (UPC) REFERENCES dbo.Product(UPC)
);

