# T-SQL Intermediate Guide with AdventureWorks2022

## Intermediate Section: Building on the Basics

### Complex JOIN Operations

Beyond INNER and LEFT JOINs, T-SQL offers RIGHT JOIN (returns all rows from right table and matching rows from left), FULL JOIN (returns rows when there's a match in either table), and CROSS JOIN (cartesian product - all possible combinations).

**Example:**
```sql
SELECT 
    p.Name AS ProductName,
    ps.Name AS SubcategoryName,
    pc.Name AS CategoryName
FROM 
    Production.ProductCategory pc
FULL OUTER JOIN 
    Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID
RIGHT JOIN 
    Production.Product p ON ps.ProductSubcategoryID = p.ProductSubcategoryID
ORDER BY 
    ProductName;
```
This query shows all products with their subcategories and categories, including products without a subcategory.

### Subqueries and Derived Tables

Subqueries are queries nested inside another query. They can appear in SELECT, FROM, WHERE, or HAVING clauses. Derived tables are subqueries in the FROM clause that act as temporary tables.

**Example:**
```sql
SELECT 
    p.Name AS ProductName,
    p.ListPrice,
    PriceCategory
FROM 
    Production.Product p
INNER JOIN 
    (SELECT 
        ProductSubcategoryID,
        AVG(ListPrice) AS AvgPrice,
        CASE 
            WHEN AVG(ListPrice) < 100 THEN 'Budget'
            WHEN AVG(ListPrice) < 500 THEN 'Mid-Range'
            ELSE 'Premium'
        END AS PriceCategory
    FROM 
        Production.Product
    GROUP BY 
        ProductSubcategoryID) AS SubCatStats
ON 
    p.ProductSubcategoryID = SubCatStats.ProductSubcategoryID
WHERE 
    p.ListPrice > SubCatStats.AvgPrice;
```
This query finds products priced above their subcategory average, and categorizes each subcategory as Budget, Mid-Range, or Premium.

### Common Table Expressions (CTEs)

CTEs provide a way to create named temporary result sets that exist for the duration of a single statement. They can be referenced multiple times in the main query.

**Example:**
```sql
WITH SalesPerTerritory AS (
    SELECT 
        t.Name AS Territory,
        YEAR(h.OrderDate) AS OrderYear,
        SUM(h.TotalDue) AS TotalSales
    FROM 
        Sales.SalesOrderHeader h
    JOIN 
        Sales.SalesTerritory t ON h.TerritoryID = t.TerritoryID
    GROUP BY 
        t.Name, YEAR(h.OrderDate)
)
SELECT 
    Territory,
    [2011] AS Sales2011,
    [2012] AS Sales2012,
    [2013] AS Sales2013,
    [2014] AS Sales2014
FROM 
    SalesPerTerritory
PIVOT (
    SUM(TotalSales) 
    FOR OrderYear IN ([2011], [2012], [2013], [2014])
) AS PivotTable
ORDER BY 
    Territory;
```
This query uses a CTE and PIVOT to show yearly sales by territory in a cross-tabular format.

### UNION, INTERSECT, EXCEPT Operations

Set operations combine results from multiple queries: UNION combines all rows, INTERSECT returns only rows in both results, and EXCEPT returns rows in the first result but not the second.

**Example:**
```sql
-- Customers who are also employees
SELECT 
    p.BusinessEntityID, p.FirstName, p.LastName, 'Both' AS Status
FROM 
    Person.Person p
JOIN 
    Sales.Customer c ON p.BusinessEntityID = c.PersonID
INTERSECT
SELECT 
    p.BusinessEntityID, p.FirstName, p.LastName, 'Both'
FROM 
    Person.Person p
JOIN 
    HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID

UNION

-- Customers who are not employees
SELECT 
    p.BusinessEntityID, p.FirstName, p.LastName, 'Customer Only'
FROM 
    Person.Person p
JOIN 
    Sales.Customer c ON p.BusinessEntityID = c.PersonID
EXCEPT
SELECT 
    p.BusinessEntityID, p.FirstName, p.LastName, 'Customer Only'
FROM 
    Person.Person p
JOIN 
    HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID

ORDER BY 
    LastName, FirstName;
```
This query identifies people who are both customers and employees, as well as those who are customers only.

### Table Variables and Temporary Tables

Table variables (@table) and temporary tables (#table) store temporary data during query execution. Temp tables exist in tempdb, while table variables exist in memory.

**Example:**
```sql
DECLARE @HighValueCustomers TABLE (
    CustomerID INT PRIMARY KEY,
    TotalSpent MONEY,
    OrderCount INT
);

INSERT INTO @HighValueCustomers
SELECT 
    CustomerID,
    SUM(TotalDue) AS TotalSpent,
    COUNT(*) AS OrderCount
FROM 
    Sales.SalesOrderHeader
GROUP BY 
    CustomerID
HAVING 
    SUM(TotalDue) > 50000;

SELECT 
    c.CustomerID,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    c.TotalSpent,
    c.OrderCount,
    c.TotalSpent / c.OrderCount AS AvgOrderValue
FROM 
    @HighValueCustomers c
JOIN 
    Sales.Customer sc ON c.CustomerID = sc.CustomerID
JOIN 
    Person.Person p ON sc.PersonID = p.BusinessEntityID
ORDER BY 
    TotalSpent DESC;
```
This example uses a table variable to store high-value customers before joining with other tables for additional details.

### Logical Operators

Logical operators (AND, OR, NOT, IN, BETWEEN) combine or negate conditions in WHERE and HAVING clauses.

**Example:**
```sql
SELECT 
    ProductID,
    Name,
    Color,
    Size,
    ListPrice
FROM 
    Production.Product
WHERE 
    (Color = 'Red' OR Color = 'Black')
    AND Size IN ('S', 'M')
    AND ListPrice BETWEEN 500 AND 1000
    AND NOT ProductNumber LIKE 'BK-%';
```
This query finds red or black products in small or medium sizes, with prices between $500-$1000, excluding products with numbers starting with 'BK-'.

### CASE Expressions

CASE expressions provide conditional logic in T-SQL. They can be simple (comparing one expression to multiple values) or searched (evaluating multiple Boolean expressions).

**Example:**
```sql
SELECT 
    ProductID,
    Name,
    ListPrice,
    CASE 
        WHEN ListPrice = 0 THEN 'Free'
        WHEN ListPrice < 50 THEN 'Budget'
        WHEN ListPrice BETWEEN 50 AND 500 THEN 'Standard'
        WHEN ListPrice BETWEEN 500.01 AND 2000 THEN 'Premium'
        ELSE 'Luxury'
    END AS PriceCategory,
    CASE ProductLine
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Sport'
        ELSE 'Other'
    END AS ProductLineDesc
FROM 
    Production.Product
ORDER BY 
    ListPrice DESC;
```
This query categorizes products by price range and translates product line codes to descriptions.

### Window Functions

Window functions perform calculations across a set of rows related to the current row, without collapsing those rows like GROUP BY does. Common functions include ROW_NUMBER, RANK, DENSE_RANK, and NTILE.

**Example:**
```sql
SELECT 
    p.Name AS ProductName,
    ps.Name AS SubcategoryName,
    p.ListPrice,
    ROW_NUMBER() OVER(PARTITION BY ps.ProductSubcategoryID ORDER BY p.ListPrice DESC) AS PriceRank,
    RANK() OVER(PARTITION BY ps.ProductSubcategoryID ORDER BY p.ListPrice DESC) AS PriceRankWithTies,
    DENSE_RANK() OVER(PARTITION BY ps.ProductSubcategoryID ORDER BY p.ListPrice DESC) AS DensePriceRank,
    NTILE(4) OVER(PARTITION BY ps.ProductSubcategoryID ORDER BY p.ListPrice DESC) AS PriceQuartile
FROM 
    Production.Product p
JOIN 
    Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
WHERE 
    p.ListPrice > 0
ORDER BY 
    SubcategoryName, PriceRank;
```
This query ranks products by price within each subcategory, showing different ranking functions and quartiles.

### Creating and Using Views

Views are virtual tables based on SELECT queries. They can simplify complex queries, provide an abstraction layer, and implement security by restricting access to underlying tables.

**Example:**
```sql
-- Creating a view
CREATE VIEW Sales.vSalesPersonPerformance AS
SELECT 
    p.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS SalesPerson,
    sp.SalesQuota,
    SUM(so.TotalDue) AS TotalSales,
    COUNT(DISTINCT so.SalesOrderID) AS OrderCount,
    YEAR(so.OrderDate) AS SalesYear,
    DATEPART(quarter, so.OrderDate) AS SalesQuarter
FROM 
    Sales.SalesPerson sp
JOIN 
    Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
JOIN 
    Sales.SalesOrderHeader so ON sp.BusinessEntityID = so.SalesPersonID
GROUP BY 
    p.BusinessEntityID,
    p.FirstName + ' ' + p.LastName,
    sp.SalesQuota,
    YEAR(so.OrderDate),
    DATEPART(quarter, so.OrderDate);

-- Using the view
SELECT 
    SalesPerson,
    SalesYear,
    SalesQuarter,
    TotalSales,
    SalesQuota,
    CASE 
        WHEN SalesQuota IS NULL THEN NULL
        ELSE (TotalSales - SalesQuota) 
    END AS QuotaDifference,
    CASE 
        WHEN SalesQuota IS NULL THEN NULL
        ELSE (TotalSales / SalesQuota) * 100
    END AS QuotaPercentage
FROM 
    Sales.vSalesPersonPerformance
WHERE 
    SalesYear = 2013
ORDER BY 
    SalesYear, SalesQuarter, TotalSales DESC;
```
This example creates a view for sales performance and then queries it with additional calculations.

### User-defined Functions

User-defined functions (UDFs) are reusable code blocks that can return scalar values, tables, or inline tables. They can accept parameters and be used in queries like built-in functions.

**Example:**
```sql
-- Scalar function
CREATE FUNCTION dbo.CalculateAge
(
    @BirthDate DATE,
    @AsOfDate DATE = NULL
)
RETURNS INT
AS
BEGIN
    IF @AsOfDate IS NULL
        SET @AsOfDate = GETDATE();
        
    RETURN DATEDIFF(YEAR, @BirthDate, @AsOfDate) - 
        CASE 
            WHEN DATEADD(YEAR, DATEDIFF(YEAR, @BirthDate, @AsOfDate), @BirthDate) > @AsOfDate 
            THEN 1 
            ELSE 0 
        END;
END;

-- Using the function
SELECT 
    p.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS EmployeeName,
    e.BirthDate,
    dbo.CalculateAge(e.BirthDate, '2022-01-01') AS AgeAsOf2022
FROM 
    HumanResources.Employee e
JOIN 
    Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
ORDER BY 
    AgeAsOf2022 DESC;
```
This example creates a function to calculate age and uses it in a query.

### Basic Stored Procedures

Stored procedures are precompiled T-SQL code blocks that can accept parameters, perform operations, and return results. They can contain multiple statements, conditional logic, and error handling.

**Example:**
```sql
-- Creating a stored procedure
CREATE PROCEDURE Sales.GetCustomerOrders
    @CustomerID INT,
    @StartDate DATE = NULL,
    @EndDate DATE = NULL,
    @MinOrderAmount MONEY = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @StartDate IS NULL
        SET @StartDate = '2000-01-01';
    
    IF @EndDate IS NULL
        SET @EndDate = GETDATE();
    
    SELECT 
        so.SalesOrderID,
        so.OrderDate,
        so.TotalDue,
        so.Status,
        p.FirstName + ' ' + p.LastName AS CustomerName
    FROM 
        Sales.SalesOrderHeader so
    JOIN 
        Sales.Customer c ON so.CustomerID = c.CustomerID
    JOIN 
        Person.Person p ON c.PersonID = p.BusinessEntityID
    WHERE 
        so.CustomerID = @CustomerID
        AND so.OrderDate BETWEEN @StartDate AND @EndDate
        AND so.TotalDue >= @MinOrderAmount
    ORDER BY 
        so.OrderDate DESC;
END;

-- Executing the stored procedure
EXEC Sales.GetCustomerOrders 
    @CustomerID = 29825, 
    @StartDate = '2013-01-01', 
    @MinOrderAmount = 1000;
```
This example creates a stored procedure to retrieve customer orders with optional parameters and then executes it.

### Dynamic SQL Basics

Dynamic SQL constructs and executes SQL statements at runtime. It's useful for flexible queries where tables, columns, or conditions aren't known until runtime.

**Example:**
```sql
DECLARE 
    @TableName NVARCHAR(128) = 'Production.Product',
    @ColumnList NVARCHAR(MAX) = 'ProductID, Name, ListPrice, Color',
    @SearchColumn NVARCHAR(128) = 'Color',
    @SearchValue NVARCHAR(50) = 'Red',
    @SQL NVARCHAR(MAX);

SET @SQL = N'SELECT ' + @ColumnList + 
           N' FROM ' + @TableName + 
           N' WHERE ' + @SearchColumn + N' = @Value' +
           N' ORDER BY ListPrice DESC';

EXEC sp_executesql 
    @SQL,
    N'@Value NVARCHAR(50)',
    @Value = @SearchValue;
```
This example demonstrates constructing and executing a query dynamically based on variables.

### Table Partitioning Concepts

Table partitioning divides large tables into smaller, more manageable segments based on a partition column. It improves query performance and maintenance operations.

**Example:**
```sql
-- View partition information for a table
SELECT
    p.partition_number,
    p.rows,
    prv.value AS boundary_value,
    fg.name AS filegroup_name
FROM
    sys.partitions p
JOIN
    sys.indexes i ON p.object_id = i.object_id AND p.index_id = i.index_id
JOIN
    sys.partition_schemes ps ON i.data_space_id = ps.data_space_id
JOIN
    sys.partition_functions pf ON ps.function_id = pf.function_id
JOIN
    sys.partition_range_values prv ON pf.function_id = prv.function_id AND p.partition_number = prv.boundary_id + 1
JOIN
    sys.destination_data_spaces dds ON ps.data_space_id = dds.partition_scheme_id AND p.partition_number = dds.destination_id
JOIN
    sys.filegroups fg ON dds.data_space_id = fg.data_space_id
WHERE
    p.object_id = OBJECT_ID('Sales.SalesOrderDetail')
    AND i.index_id = 1
ORDER BY
    p.partition_number;
```
This query examines the partition structure of the SalesOrderDetail table.

### Using OVER Clause with Aggregate Functions

The OVER clause with aggregate functions performs aggregations while still returning individual rows, unlike GROUP BY which collapses rows.

**Example:**
```sql
SELECT 
    p.FirstName + ' ' + p.LastName AS SalesPerson,
    t.Name AS Territory,
    so.OrderDate,
    so.TotalDue,
    SUM(so.TotalDue) OVER(PARTITION BY so.SalesPersonID) AS PersonTotal,
    SUM(so.TotalDue) OVER(PARTITION BY t.TerritoryID) AS TerritoryTotal,
    SUM(so.TotalDue) OVER(PARTITION BY so.SalesPersonID ORDER BY so.OrderDate) AS RunningPersonTotal,
    SUM(so.TotalDue) OVER() AS GrandTotal,
    (so.TotalDue / SUM(so.TotalDue) OVER(PARTITION BY so.SalesPersonID)) * 100 AS PercentOfPersonTotal
FROM 
    Sales.SalesOrderHeader so
JOIN 
    Sales.SalesPerson sp ON so.SalesPersonID = sp.BusinessEntityID
JOIN 
    Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
JOIN 
    Sales.SalesTerritory t ON so.TerritoryID = t.TerritoryID
WHERE 
    YEAR(so.OrderDate) = 2013
ORDER BY 
    SalesPerson, OrderDate;
```
This query calculates various sales totals and percentages for each order.

### Error Handling with TRY...CATCH

TRY...CATCH blocks capture and handle errors in T-SQL code, similar to exception handling in programming languages.

**Example:**
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- Attempt to update product prices
    UPDATE Production.Product
    SET ListPrice = ListPrice * 1.1
    WHERE ProductSubcategoryID = 1;
    
    -- Intentional error - division by zero
    UPDATE Production.Product
    SET ListPrice = ListPrice / (ListPrice - ListPrice)
    WHERE ProductID = 1;
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    
    SELECT 
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage;
        
    -- Log error to a table (example)
    INSERT INTO dbo.ErrorLog (
        ErrorTime,
        ErrorNumber,
        ErrorMessage
    )
    VALUES (
        GETDATE(),
        ERROR_NUMBER(),
        ERROR_MESSAGE()
    );
END CATCH;
```
This example demonstrates wrapping potentially error-prone code in a TRY...CATCH block with transaction management.

### Indexing Basics and Query Performance

Indexes speed up data retrieval by providing quick lookup structures, similar to a book's index. Understanding index types and their impact on query performance is essential for optimization.

**Example:**
```sql
-- View index information
SELECT 
    i.name AS IndexName,
    i.type_desc AS IndexType,
    OBJECT_NAME(i.object_id) AS TableName,
    COL_NAME(ic.object_id, ic.column_id) AS ColumnName,
    ic.key_ordinal AS KeyOrderPosition,
    ic.is_included_column AS IsIncludedColumn
FROM 
    sys.indexes i
JOIN 
    sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
WHERE 
    i.object_id = OBJECT_ID('Production.Product')
ORDER BY 
    IndexName, KeyOrderPosition;

-- Compare execution plans
-- Enable actual execution plan (Ctrl+M) before running these queries

-- Query 1: Using clustered index (ProductID)
SELECT * FROM Production.Product WHERE ProductID = 980;

-- Query 2: Using nonclustered index (Name)
SELECT * FROM Production.Product WHERE Name = 'HL Road Frame - Red, 58';

-- Query 3: No suitable index
SELECT * FROM Production.Product WHERE Color = 'Red';
```
This example examines index structures and demonstrates how different queries use indexes.

### String Manipulation

T-SQL offers functions for advanced string operations like finding substrings (CHARINDEX, PATINDEX), replacing text (REPLACE), concatenating with insertion (STUFF), and more.

**Example:**
```sql
SELECT 
    ProductNumber,
    Name,
    -- Extract product prefix from product number
    LEFT(ProductNumber, CHARINDEX('-', ProductNumber) - 1) AS ProductPrefix,
    -- Find position of 'Road' in product name
    CHARINDEX('Road', Name) AS RoadPosition,
    -- Replace spaces with underscores
    REPLACE(Name, ' ', '_') AS NameWithUnderscores,
    -- Pattern matching for color code
    PATINDEX('%-%-%', ProductNumber) AS PatternMatch,
    -- Insert text into middle of string
    STUFF(Name, 5, 0, '[FEATURED] ') AS ModifiedName
FROM 
    Production.Product
WHERE 
    ProductNumber LIKE 'BK-%'
    OR ProductNumber LIKE 'FR-%';
```
This query demonstrates various string manipulation functions on product data.

### Date/Time Manipulation and Time Zones

T-SQL provides functions for working with dates, times, and time zones, including extracting parts of dates, calculating differences, and handling different time zone conversions.

**Example:**
```sql
SELECT 
    so.SalesOrderID,
    so.OrderDate,
    -- Extract date components
    YEAR(so.OrderDate) AS OrderYear,
    MONTH(so.OrderDate) AS OrderMonth,
    DAY(so.OrderDate) AS OrderDay,
    DATEPART(weekday, so.OrderDate) AS OrderWeekday,
    DATENAME(month, so.OrderDate) AS OrderMonthName,
    DATENAME(weekday, so.OrderDate) AS OrderDayName,
    -- Date calculations
    DATEDIFF(day, so.OrderDate, so.ShipDate) AS DaysToShip,
    DATEADD(day, 30, so.OrderDate) AS DueDate,
    EOMONTH(so.OrderDate) AS EndOfMonth,
    -- Convert between time zones (UTC to specific time zone)
    DATEADD(hour, -8, so.OrderDate) AS PacificTime, -- Simple