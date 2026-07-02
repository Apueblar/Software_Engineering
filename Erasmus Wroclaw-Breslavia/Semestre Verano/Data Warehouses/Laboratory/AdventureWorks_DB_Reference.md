# AdventureWorks OLTP – Database Reference for SQL Query Generation

## Context

AdventureWorks is a Microsoft sample database representing a fictional bicycle manufacturer and seller called **Adventure Works Cycles**. It sells bicycles (mountain, road, touring) and accessories to North American, European, and Asian markets. The database is a standard **OLTP** (transactional) system — normalized, row-based, designed for day-to-day operations.

For the purposes of this context, we focus **only on sales-related schemas**: `Sales`, `Production`, and `Person`.

---

## Schema Overview

| Schema | Purpose |
|---|---|
| `Sales` | Orders, customers, territories, salespersons |
| `Production` | Products, categories, inventory |
| `Person` | People, addresses, contact info |
| `HumanResources` | Employees |

---

## Core Tables and Attributes

### SALES ORDERS

#### `Sales.SalesOrderHeader`
One row per order (the "header" / summary of the order).

| Column | Type | Description |
|---|---|---|
| `SalesOrderID` | int PK | Unique order identifier |
| `OrderDate` | datetime | Date the order was placed |
| `DueDate` | datetime | Expected delivery date |
| `ShipDate` | datetime | Actual ship date |
| `Status` | tinyint | Order status: 1=In process, 2=Approved, 3=Backordered, 4=Rejected, 5=Shipped, 6=Cancelled |
| `OnlineOrderFlag` | bit | 1 = Online order, 0 = In-store (via sales rep) |
| `SalesOrderNumber` | nvarchar | Human-readable order number |
| `CustomerID` | int FK | Links to `Sales.Customer` |
| `SalesPersonID` | int FK (nullable) | Links to `Sales.SalesPerson` — NULL for online orders |
| `TerritoryID` | int FK | Links to `Sales.SalesTerritory` |
| `BillToAddressID` | int FK | Links to `Person.Address` |
| `ShipToAddressID` | int FK | Links to `Person.Address` |
| `SubTotal` | money | Order subtotal before tax/freight |
| `TaxAmt` | money | Tax amount |
| `Freight` | money | Shipping cost |
| `TotalDue` | money | SubTotal + TaxAmt + Freight |
| `ModifiedDate` | datetime | Last modified timestamp |

**Key notes:**
- `SubTotal` = sum of line items from `SalesOrderDetail`
- `TotalDue` = the full amount billed to the customer
- Online orders have `SalesPersonID = NULL`

---

#### `Sales.SalesOrderDetail`
One row per **line item** within an order. One order header → many detail rows.

| Column | Type | Description |
|---|---|---|
| `SalesOrderID` | int PK/FK | Links to `Sales.SalesOrderHeader` |
| `SalesOrderDetailID` | int PK | Unique line item ID within the order |
| `ProductID` | int FK | Links to `Production.Product` |
| `OrderQty` | smallint | Quantity ordered |
| `UnitPrice` | money | Price per unit at time of sale |
| `UnitPriceDiscount` | money | Discount applied per unit (as a rate, e.g. 0.10 = 10%) |
| `LineTotal` | money | Computed: `OrderQty * UnitPrice * (1 - UnitPriceDiscount)` |
| `ModifiedDate` | datetime | Last modified timestamp |

**Key notes:**
- Composite PK: (`SalesOrderID`, `SalesOrderDetailID`)
- To get actual revenue per line: `OrderQty * UnitPrice * (1 - UnitPriceDiscount)`
- To get total discount value: `OrderQty * UnitPrice * UnitPriceDiscount`

---

### PRODUCTS

#### `Production.Product`
Central product table — one row per sellable product.

| Column | Type | Description |
|---|---|---|
| `ProductID` | int PK | Unique product identifier |
| `Name` | nvarchar | Product name |
| `ProductNumber` | nvarchar | Unique product code (e.g. "BK-M68B-38") |
| `MakeFlag` | bit | 1 = manufactured in-house, 0 = purchased from vendor |
| `FinishedGoodsFlag` | bit | 1 = sellable to customers, 0 = component only |
| `Color` | nvarchar (nullable) | Product color |
| `SafetyStockLevel` | smallint | Minimum inventory threshold |
| `ReorderPoint` | smallint | Reorder trigger level |
| `StandardCost` | money | Manufacturing/purchase cost |
| `ListPrice` | money | Retail list price (0 if not sold individually) |
| `Size` | nvarchar (nullable) | Product size |
| `SizeUnitMeasureCode` | nchar (nullable) | Unit for size (e.g. CM, IN) |
| `WeightUnitMeasureCode` | nchar (nullable) | Unit for weight (e.g. G, LB) |
| `Weight` | decimal (nullable) | Product weight |
| `ProductLine` | nchar (nullable) | R=Road, M=Mountain, T=Touring, S=Standard |
| `Class` | nchar (nullable) | H=High, M=Medium, L=Low |
| `Style` | nchar (nullable) | W=Womens, M=Mens, U=Universal |
| `ProductSubcategoryID` | int FK (nullable) | Links to `Production.ProductSubcategory` |
| `ProductModelID` | int FK (nullable) | Links to `Production.ProductModel` |
| `SellStartDate` | datetime | Date product became available for sale |
| `SellEndDate` | datetime (nullable) | Date product was discontinued |
| `DiscontinuedDate` | datetime (nullable) | Date product was fully discontinued |
| `ModifiedDate` | datetime | Last modified timestamp |

**Key notes:**
- Products with `ListPrice = 0` are typically components, not sold individually
- `MakeFlag = 1` → manufactured (IsManufactured = Yes)
- `FinishedGoodsFlag = 0` → not a retail product

---

#### `Production.ProductSubcategory`
Groups products into subcategories (e.g. "Mountain Bikes", "Road Bikes").

| Column | Type | Description |
|---|---|---|
| `ProductSubcategoryID` | int PK | Unique subcategory ID |
| `ProductCategoryID` | int FK | Links to `Production.ProductCategory` |
| `Name` | nvarchar | Subcategory name (e.g. "Mountain Bikes") |
| `ModifiedDate` | datetime | Last modified |

---

#### `Production.ProductCategory`
Top-level product groupings.

| Column | Type | Description |
|---|---|---|
| `ProductCategoryID` | int PK | Unique category ID |
| `Name` | nvarchar | Category name: "Bikes", "Components", "Clothing", "Accessories" |
| `ModifiedDate` | datetime | Last modified |

**Hierarchy:** `ProductCategory` → `ProductSubcategory` → `Product`

---

#### `Production.ProductModel`
Describes a model that can have multiple product variants (e.g. different sizes).

| Column | Type | Description |
|---|---|---|
| `ProductModelID` | int PK | Unique model ID |
| `Name` | nvarchar | Model name |
| `CatalogDescription` | xml (nullable) | XML product description |
| `ModifiedDate` | datetime | Last modified |

---

### CUSTOMERS

#### `Sales.Customer`
Represents a customer entity. Customers are either individuals or stores.

| Column | Type | Description |
|---|---|---|
| `CustomerID` | int PK | Unique customer identifier |
| `PersonID` | int FK (nullable) | Links to `Person.Person` — set for individual customers |
| `StoreID` | int FK (nullable) | Links to `Sales.Store` — set for store/reseller customers |
| `TerritoryID` | int FK | Links to `Sales.SalesTerritory` |
| `AccountNumber` | varchar | Customer account number |
| `ModifiedDate` | datetime | Last modified |

**Key notes:**
- If `PersonID` is set and `StoreID` is NULL → **individual customer** (online buyer)
- If `StoreID` is set → **store/reseller customer** (~700 stores)
- ~18,000 individual customers total

---

#### `Person.Person`
Contains personal details for any individual in the system (customers, employees, vendors).

| Column | Type | Description |
|---|---|---|
| `BusinessEntityID` | int PK | Unique person ID |
| `PersonType` | nchar | SC=Store Contact, IN=Individual, SP=Sales Person, EM=Employee, VC=Vendor Contact, GC=General Contact |
| `NameStyle` | bit | 0 = Western name order |
| `Title` | nvarchar (nullable) | Mr., Ms., Dr., etc. |
| `FirstName` | nvarchar | First name |
| `MiddleName` | nvarchar (nullable) | Middle name |
| `LastName` | nvarchar | Last name |
| `EmailPromotion` | int | Email promotion preference |
| `ModifiedDate` | datetime | Last modified |

---

#### `Sales.Store`
Represents store/reseller customers.

| Column | Type | Description |
|---|---|---|
| `BusinessEntityID` | int PK | Unique store ID |
| `Name` | nvarchar | Store name |
| `SalesPersonID` | int FK (nullable) | Assigned sales representative |
| `ModifiedDate` | datetime | Last modified |

---

### ADDRESSES

#### `Person.Address`
Physical addresses (used for billing and shipping).

| Column | Type | Description |
|---|---|---|
| `AddressID` | int PK | Unique address ID |
| `AddressLine1` | nvarchar | Street address |
| `AddressLine2` | nvarchar (nullable) | Additional address info |
| `City` | nvarchar | City name |
| `StateProvinceID` | int FK | Links to `Person.StateProvince` |
| `PostalCode` | nvarchar | Postal/ZIP code |
| `ModifiedDate` | datetime | Last modified |

---

#### `Person.StateProvince`
State or province information.

| Column | Type | Description |
|---|---|---|
| `StateProvinceID` | int PK | Unique state/province ID |
| `StateProvinceCode` | nchar | Abbreviation (e.g. "WA") |
| `CountryRegionCode` | nvarchar FK | Links to `Person.CountryRegion` |
| `Name` | nvarchar | Full state/province name |
| `TerritoryID` | int FK | Links to `Sales.SalesTerritory` |
| `IsOnlyStateProvinceFlag` | bit | Whether this is the only state/province in the country |

---

#### `Person.CountryRegion`

| Column | Type | Description |
|---|---|---|
| `CountryRegionCode` | nvarchar PK | ISO country code (e.g. "US", "CA") |
| `Name` | nvarchar | Country/region name |

---

### SALES TERRITORY

#### `Sales.SalesTerritory`
Defines geographic sales regions.

| Column | Type | Description |
|---|---|---|
| `TerritoryID` | int PK | Unique territory ID |
| `Name` | nvarchar | Territory name (e.g. "Northwest", "Central") |
| `CountryRegionCode` | nvarchar FK | Country of the territory |
| `Group` | nvarchar | Continent group: "North America", "Europe", "Pacific" |
| `SalesYTD` | money | Sales year-to-date |
| `SalesLastYear` | money | Sales from previous year |
| `CostYTD` | money | Costs year-to-date |
| `CostLastYear` | money | Costs from previous year |
| `ModifiedDate` | datetime | Last modified |

---

### EMPLOYEES & SALESPERSONS

#### `HumanResources.Employee`
General employee information.

| Column | Type | Description |
|---|---|---|
| `BusinessEntityID` | int PK/FK | Links to `Person.Person` |
| `NationalIDNumber` | nvarchar | National ID / SSN |
| `LoginID` | nvarchar | Domain login |
| `JobTitle` | nvarchar | Job title |
| `BirthDate` | date | Date of birth |
| `MaritalStatus` | nchar | M=Married, S=Single |
| `Gender` | nchar | M=Male, F=Female |
| `HireDate` | date | Date hired |
| `SalariedFlag` | bit | 1=Salaried, 0=Hourly |
| `VacationHours` | smallint | Accrued vacation hours |
| `SickLeaveHours` | smallint | Accrued sick leave |
| `ModifiedDate` | datetime | Last modified |

---

#### `Sales.SalesPerson`
Additional details for employees who are salespersons.

| Column | Type | Description |
|---|---|---|
| `BusinessEntityID` | int PK/FK | Links to `HumanResources.Employee` |
| `TerritoryID` | int FK (nullable) | Assigned sales territory |
| `SalesQuota` | money (nullable) | Assigned sales quota |
| `Bonus` | money | Bonus amount |
| `CommissionPct` | smallmoney | Commission percentage |
| `SalesYTD` | money | Year-to-date sales |
| `SalesLastYear` | money | Sales from prior year |
| `ModifiedDate` | datetime | Last modified |

---

## Key Relationships (JOIN Paths)

```
Sales.SalesOrderHeader
  └── CustomerID         → Sales.Customer.CustomerID
        ├── PersonID     → Person.Person.BusinessEntityID
        └── StoreID      → Sales.Store.BusinessEntityID

  └── SalesPersonID      → Sales.SalesPerson.BusinessEntityID
                         → HumanResources.Employee.BusinessEntityID
                         → Person.Person.BusinessEntityID

  └── TerritoryID        → Sales.SalesTerritory.TerritoryID

  └── ShipToAddressID    → Person.Address.AddressID
        └── StateProvinceID → Person.StateProvince.StateProvinceID
              └── CountryRegionCode → Person.CountryRegion.CountryRegionCode

Sales.SalesOrderDetail
  └── SalesOrderID       → Sales.SalesOrderHeader.SalesOrderID
  └── ProductID          → Production.Product.ProductID
        └── ProductSubcategoryID → Production.ProductSubcategory.ProductSubcategoryID
              └── ProductCategoryID → Production.ProductCategory.ProductCategoryID
        └── ProductModelID → Production.ProductModel.ProductModelID
```

---

## Common Query Patterns

### Get full product hierarchy
```sql
SELECT
    p.ProductID, p.Name AS ProductName, p.ProductNumber,
    ps.Name AS SubCategory,
    pc.Name AS Category
FROM Production.Product p
LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
```

### Get orders with salesperson name
```sql
SELECT
    soh.SalesOrderID, soh.OrderDate, soh.TotalDue,
    per.FirstName + ' ' + per.LastName AS SalesPersonName
FROM Sales.SalesOrderHeader soh
LEFT JOIN Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
LEFT JOIN Person.Person per ON sp.BusinessEntityID = per.BusinessEntityID
```

### Get order line items with product details
```sql
SELECT
    soh.SalesOrderID, soh.OrderDate,
    p.Name AS ProductName,
    sod.OrderQty, sod.UnitPrice, sod.UnitPriceDiscount,
    sod.LineTotal
FROM Sales.SalesOrderHeader soh
JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN Production.Product p ON sod.ProductID = p.ProductID
```

### Get yearly sales totals
```sql
SELECT
    YEAR(soh.OrderDate) AS OrderYear,
    SUM(soh.SubTotal) AS TotalSales,
    COUNT(DISTINCT soh.SalesOrderID) AS NumberOfOrders
FROM Sales.SalesOrderHeader soh
WHERE soh.Status = 5 -- Shipped only
GROUP BY YEAR(soh.OrderDate)
ORDER BY OrderYear
```

### Get customer type
```sql
SELECT
    c.CustomerID,
    CASE
        WHEN c.StoreID IS NULL THEN 'Individual'
        ELSE 'Store'
    END AS CustomerType,
    COALESCE(s.Name, per.FirstName + ' ' + per.LastName) AS CustomerName
FROM Sales.Customer c
LEFT JOIN Sales.Store s ON c.StoreID = s.BusinessEntityID
LEFT JOIN Person.Person per ON c.PersonID = per.BusinessEntityID
```

---

## Quick Reference: Useful Flags and Codes

| Column | Value | Meaning |
|---|---|---|
| `SalesOrderHeader.OnlineOrderFlag` | 1 | Online order (no sales rep) |
| `SalesOrderHeader.OnlineOrderFlag` | 0 | In-store order (via sales rep) |
| `SalesOrderHeader.Status` | 1 | In process |
| `SalesOrderHeader.Status` | 2 | Approved |
| `SalesOrderHeader.Status` | 3 | Backordered |
| `SalesOrderHeader.Status` | 4 | Rejected |
| `SalesOrderHeader.Status` | 5 | Shipped |
| `SalesOrderHeader.Status` | 6 | Cancelled |
| `Product.MakeFlag` | 1 | Manufactured in-house |
| `Product.MakeFlag` | 0 | Purchased externally |
| `Product.FinishedGoodsFlag` | 1 | Sellable retail product |
| `Product.ProductLine` | R / M / T / S | Road / Mountain / Touring / Standard |
| `Product.Class` | H / M / L | High / Medium / Low |
| `Person.Person.PersonType` | SP | Sales Person |
| `Person.Person.PersonType` | IN | Individual customer |
| `Person.Person.PersonType` | SC | Store Contact |
| `Person.Person.PersonType` | EM | Employee |
| `SalesTerritory.Group` | North America / Europe / Pacific | Continental region |

---

## Data Scope Notes

- Sales data covers roughly **2011–2014**
- There are approximately **31,000 orders** total
- ~**504 products** in the catalog (~295 are finished goods)
- ~**19,000 customers** (~700 stores, ~18,000 individuals)
- ~**17 salespersons** active in the system
- `SubTotal` in `SalesOrderHeader` is the canonical revenue figure (excludes tax/freight)
- For profit calculations: `Profit = (UnitPrice - StandardCost) * OrderQty`
