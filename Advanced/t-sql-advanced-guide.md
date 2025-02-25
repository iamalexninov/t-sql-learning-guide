# T-SQL Advanced Guide with AdventureWorks2022

## Advanced Section: Mastering T-SQL

### Complex Window Functions with Frames

Window functions can use frame clauses (ROWS/RANGE) to define which rows are included in the calculation window relative to the current row, enabling moving averages, running totals, and other advanced analytics.

**Example:**
```sql
SELECT 
    p.BusinessEntityID,
    p.FirstName + ' ' + p.LastName AS SalesPerson,
    YEAR(soh.OrderDate) AS SalesYear,
    MONTH(soh.OrderDate) AS SalesMonth,
    SUM(soh.TotalDue) AS MonthlySales,
    
    -- Moving average of sales for current month and 2 preceding months
    AVG(SUM(soh.TotalDue)) OVER (
        PARTITION BY p.BusinessEntityID 
        ORDER BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS MovingAvg3Month,
    
    -- Running total from beginning of year
    SUM(SUM(soh.TotalDue)) OVER (
        PARTITION BY p.BusinessEntityID, YEAR(soh.OrderDate)
        ORDER BY MONTH(soh.OrderDate)
        ROWS UNBOUNDED PRECEDING
    ) AS YearToDateSales,
    
    -- Comparison with previous month
    LAG(SUM(soh.TotalDue), 1) OVER (
        PARTITION BY p.BusinessEntityID 
        ORDER BY YEAR(soh.OrderDate), MONTH(soh.OrderDate)
    ) AS PreviousMonthSales
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
JOIN 
    Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
WHERE 
    soh.SalesPersonID IS NOT NULL
    AND YEAR(soh.OrderDate) = 2013
GROUP BY 
    p.BusinessEntityID, p.FirstName, p.LastName, 
    YEAR(soh.OrderDate), MONTH(soh.OrderDate)
ORDER BY 
    SalesPerson, SalesYear, SalesMonth;
```
This query calculates moving averages and running totals for sales people, showing month-to-month trends.

### Recursive CTEs

Recursive CTEs are powerful structures that reference themselves, enabling hierarchical data traversal, series generation, and complex graph operations.

**Example:**
```sql
WITH EmployeeHierarchy AS (
    -- Anchor member: top level employees (no manager)
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmployeeName,
        e.JobTitle,
        CAST(NULL AS NVARCHAR(50)) AS ManagerName,
        0 AS OrganizationLevel
    FROM 
        HumanResources.Employee e
    JOIN 
        Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    WHERE 
        e.OrganizationLevel = 1
    
    UNION ALL
    
    -- Recursive member: employees with managers
    SELECT 
        e.BusinessEntityID,
        p.FirstName + ' ' + p.LastName AS EmployeeName,
        e.JobTitle,
        pm.FirstName + ' ' + pm.LastName AS ManagerName,
        eh.OrganizationLevel + 1
    FROM 
        HumanResources.Employee e
    JOIN 
        Person.Person p ON e.BusinessEntityID = p.BusinessEntityID
    JOIN 
        HumanResources.Employee em ON e.ManagerID = em.BusinessEntityID
    JOIN 
        Person.Person pm ON em.BusinessEntityID = pm.BusinessEntityID
    JOIN 
        EmployeeHierarchy eh ON em.BusinessEntityID = eh.BusinessEntityID
)
SELECT 
    BusinessEntityID,
    REPLICATE('    ', OrganizationLevel) + EmployeeName AS EmployeeName,
    JobTitle,
    ManagerName,
    OrganizationLevel
FROM 
    EmployeeHierarchy
ORDER BY 
    OrganizationLevel, EmployeeName;
```
This recursive CTE generates a complete employee hierarchy with indentation to visualize reporting relationships.

### Pivoting and Unpivoting Data

PIVOT transforms rows into columns, creating cross-tabular reports. UNPIVOT does the opposite, converting columns back to rows for normalized data processing.

**Example:**
```sql
-- PIVOT example: Convert product subcategories to columns
SELECT
    ProductCategory,
    [Mountain Bikes], [Road Bikes], [Touring Bikes],
    [Handlebars], [Bottom Brackets], [Brakes],
    [Chains], [Cranksets], [Derailleurs],
    [Wheels], [Helmets], [Hydration Packs]
FROM (
    SELECT 
        pc.Name AS ProductCategory,
        ps.Name AS ProductSubcategory,
        p.ListPrice
    FROM 
        Production.Product p
    JOIN 
        Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
    JOIN 
        Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
) AS SourceData
PIVOT (
    AVG(ListPrice)
    FOR ProductSubcategory IN (
        [Mountain Bikes], [Road Bikes], [Touring Bikes],
        [Handlebars], [Bottom Brackets], [Brakes],
        [Chains], [Cranksets], [Derailleurs],
        [Wheels], [Helmets], [Hydration Packs]
    )
) AS PivotTable;

-- UNPIVOT example: Convert yearly sales columns to rows
SELECT 
    SalesPersonName,
    SalesYear,
    SalesAmount
FROM (
    SELECT 
        p.FirstName + ' ' + p.LastName AS SalesPersonName,
        SUM(CASE WHEN YEAR(soh.OrderDate) = 2011 THEN soh.TotalDue ELSE 0 END) AS [2011],
        SUM(CASE WHEN YEAR(soh.OrderDate) = 2012 THEN soh.TotalDue ELSE 0 END) AS [2012],
        SUM(CASE WHEN YEAR(soh.OrderDate) = 2013 THEN soh.TotalDue ELSE 0 END) AS [2013],
        SUM(CASE WHEN YEAR(soh.OrderDate) = 2014 THEN soh.TotalDue ELSE 0 END) AS [2014]
    FROM 
        Sales.SalesOrderHeader soh
    JOIN 
        Sales.SalesPerson sp ON soh.SalesPersonID = sp.BusinessEntityID
    JOIN 
        Person.Person p ON sp.BusinessEntityID = p.BusinessEntityID
    WHERE 
        soh.SalesPersonID IS NOT NULL
    GROUP BY 
        p.FirstName + ' ' + p.LastName
) AS PivotData
UNPIVOT (
    SalesAmount FOR SalesYear IN ([2011], [2012], [2013], [2014])
) AS UnpivotTable
ORDER BY 
    SalesPersonName, SalesYear;
```
This example shows both PIVOT and UNPIVOT operations on sales and product data.

### System Functions and DMVs (Dynamic Management Views)

System functions and DMVs provide insights into the database engine's internal operations, helping with performance monitoring, troubleshooting, and managing database objects.

**Example:**
```sql
-- Database file space usage
SELECT 
    db.name AS DatabaseName,
    mf.name AS FileName,
    mf.physical_name AS FilePath,
    mf.type_desc AS FileType,
    CAST(CAST(mf.size AS BIGINT) * 8 / 1024.0 AS DECIMAL(18,2)) AS FileSizeMB,
    CAST(CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS BIGINT) * 8 / 1024.0 AS DECIMAL(18,2)) AS SpaceUsedMB,
    CAST((CAST(mf.size AS BIGINT) * 8 / 1024.0) - 
         (CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS BIGINT) * 8 / 1024.0) AS DECIMAL(18,2)) AS FreeSpaceMB,
    CAST(((CAST(mf.size AS BIGINT) * 8 / 1024.0) - 
          (CAST(FILEPROPERTY(mf.name, 'SpaceUsed') AS BIGINT) * 8 / 1024.0)) / 
         (CAST(mf.size AS FLOAT) * 8 / 1024.0) * 100 AS DECIMAL(18,2)) AS FreeSpacePercent
FROM 
    sys.master_files mf
JOIN 
    sys.databases db ON mf.database_id = db.database_id
WHERE 
    db.name = 'AdventureWorks2022'
ORDER BY 
    FileSizeMB DESC;

-- Query performance statistics
SELECT TOP 20
    qs.execution_count AS ExecutionCount,
    qs.total_worker_time / 1000 AS TotalCPUTimeMS,
    qs.total_worker_time / 1000 / qs.execution_count AS AvgCPUTimeMS,
    qs.total_elapsed_time / 1000 AS TotalDurationMS,
    qs.total_elapsed_time / 1000 / qs.execution_count AS AvgDurationMS,
    qs.total_logical_reads AS TotalLogicalReads,
    qs.total_logical_reads / qs.execution_count AS AvgLogicalReads,
    qt.text AS QueryText,
    qp.query_plan AS QueryPlan,
    SUBSTRING(qt.text, (qs.statement_start_offset/2) + 1,
        ((CASE statement_end_offset 
            WHEN -1 THEN DATALENGTH(qt.text)
            ELSE qs.statement_end_offset END 
                - qs.statement_start_offset)/2) + 1) AS StatementText
FROM 
    sys.dm_exec_query_stats qs
CROSS APPLY 
    sys.dm_exec_sql_text(qs.sql_handle) AS qt
CROSS APPLY 
    sys.dm_exec_query_plan(qs.plan_handle) AS qp
ORDER BY 
    qs.total_worker_time DESC;
```
This example uses DMVs to analyze database file space usage and identify the most resource-intensive queries.

### Query Optimization Techniques

Query optimization involves analyzing and improving query execution plans for better performance through index tuning, query rewrites, and other techniques.

**Example:**
```sql
-- Original query
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    p.FirstName + ' ' + p.LastName AS CustomerName,
    pm.Name AS ProductModel,
    SUM(sod.OrderQty) AS TotalQuantity,
    SUM(sod.LineTotal) AS TotalAmount
FROM 
    Sales.SalesOrderHeader soh
JOIN 
    Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
JOIN 
    Sales.Customer c ON soh.CustomerID = c.CustomerID
JOIN 
    Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN 
    Production.Product pr ON sod.ProductID = pr.ProductID
JOIN 
    Production.ProductModel pm ON pr.ProductModelID = pm.ProductModelID
WHERE 
    soh.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
    AND soh.TotalDue > 5000
GROUP BY 
    soh.SalesOrderID, soh.OrderDate, p.FirstName, p.LastName, pm.Name;

-- Optimized query with table hints, filtered index, and query rewrites
-- First, create a filtered index (in practice)
-- CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_OrderDate_Filtered
-- ON Sales.SalesOrderHeader (OrderDate, CustomerID, TotalDue, SalesOrderID)
-- WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31' AND TotalDue > 5000;

-- Optimized query
SELECT 
    soh.SalesOrderID,
    soh.OrderDate,
    c.CustomerName,  -- Using derived table
    pm.Name AS ProductModel,
    SalesDetails.TotalQuantity,
    SalesDetails.TotalAmount
FROM 
    Sales.SalesOrderHeader soh WITH (INDEX(IX_SalesOrderHeader_OrderDate_Filtered))
JOIN (
    -- Pre-aggregate sales details
    SELECT 
        SalesOrderID,
        ProductID,
        SUM(OrderQty) AS TotalQuantity,
        SUM(LineTotal) AS TotalAmount
    FROM 
        Sales.SalesOrderDetail WITH (FORCESEEK)
    GROUP BY 
        SalesOrderID, ProductID
) AS SalesDetails ON soh.SalesOrderID = SalesDetails.SalesOrderID
JOIN (
    -- Pre-join customer information
    SELECT 
        c.CustomerID,
        p.FirstName + ' ' + p.LastName AS CustomerName
    FROM 
        Sales.Customer c
    JOIN 
        Person.Person p ON c.PersonID = p.BusinessEntityID
) AS c ON soh.CustomerID = c.CustomerID
JOIN 
    Production.Product pr ON SalesDetails.ProductID = pr.ProductID
JOIN 
    Production.ProductModel pm ON pr.ProductModelID = pm.ProductModelID
WHERE 
    soh.OrderDate BETWEEN '2013-01-01' AND '2013-12-31'
    AND soh.TotalDue > 5000
ORDER BY 
    soh.OrderDate, TotalAmount DESC
OPTION (RECOMPILE, OPTIMIZE FOR (@OrderDate = '2013-06-15'));
```
This example shows query optimization using derived tables, index hints, and query hints.

### Advanced Indexing Strategies

Advanced indexing involves creating specialized indexes (filtered, columnstore, covering) and understanding index maintenance to balance query performance with update overhead.

**Example:**
```sql
-- Filtered index for specific date range
CREATE NONCLUSTERED INDEX IX_SalesOrderHeader_2013
ON Sales.SalesOrderHeader (CustomerID, TotalDue)
INCLUDE (OrderDate, Status, ShipDate)
WHERE OrderDate BETWEEN '2013-01-01' AND '2013-12-31';

-- Covering index for a specific query pattern
CREATE NONCLUSTERED INDEX IX_Product_Covering
ON Production.Product (ProductSubcategoryID, ListPrice)
INCLUDE (Name, ProductNumber, Color, Size, Weight);

-- Index with computed column
ALTER TABLE Production.Product
ADD StandardCostUSD AS (StandardCost * 1.0);

CREATE NONCLUSTERED INDEX IX_Product_StandardCostUSD
ON Production.Product (StandardCostUSD);

-- Index maintenance script
DECLARE @IndexRebuildThreshold FLOAT = 30.0; -- Rebuild if fragmentation > 30%
DECLARE @IndexReorganizeThreshold FLOAT = 10.0; -- Reorganize if fragmentation > 10%

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT 
    @SQL = @SQL + 
    CASE 
        WHEN avg_fragmentation_in_percent > @IndexRebuildThreshold 
        THEN 'ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) + ' REBUILD WITH (ONLINE = ON, SORT_IN_TEMPDB = ON);' + CHAR(13) + CHAR(10)
        WHEN avg_fragmentation_in_percent > @IndexReorganizeThreshold 
        THEN 'ALTER INDEX ' + QUOTENAME(i.name) + ' ON ' + QUOTENAME(SCHEMA_NAME(t.schema_id)) + '.' + QUOTENAME(t.name) + ' REORGANIZE;' + CHAR(13) + CHAR(10)
        ELSE ''
    END
FROM 
    sys.dm_db_index_physical_stats (DB_ID(), NULL, NULL, NULL, 'LIMITED') ps
JOIN 
    sys.indexes i ON ps.object_id = i.object_id AND ps.index_id = i.index_id
JOIN 
    sys.tables t ON i.object_id = t.object_id
WHERE 
    ps.database_id = DB_ID()
    AND ps.avg_fragmentation_in_percent > @IndexReorganizeThreshold
    AND ps.page_count > 1000
    AND i.name IS NOT NULL;

PRINT @SQL;
-- EXEC sp_executesql @SQL; -- Uncomment to execute
```
This example demonstrates creating specialized indexes and a maintenance script to manage index fragmentation.

### Temporal Tables

Temporal tables track data changes over time, enabling point-in-time analysis and historical data access without requiring custom audit solutions.

**Example:**
```sql
-- Create a temporal table
CREATE TABLE dbo.ProductPricing (
    ProductID INT PRIMARY KEY CLUSTERED,
    Name NVARCHAR(50) NOT NULL,
    StandardCost MONEY NOT NULL,
    ListPrice MONEY NOT NULL,
    StartDate DATETIME2 GENERATED ALWAYS AS ROW START NOT NULL,
    EndDate DATETIME2 GENERATED ALWAYS AS ROW END NOT NULL,
    PERIOD FOR SYSTEM_TIME (StartDate, EndDate)
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE = dbo.ProductPricingHistory));

-- Insert initial data
INSERT INTO dbo.ProductPricing (ProductID, Name, StandardCost, ListPrice)
SELECT TOP 10
    ProductID, Name, StandardCost, ListPrice
FROM 
    Production.Product
WHERE 
    ListPrice > 0;

-- Update some prices (changes automatically tracked)
UPDATE dbo.ProductPricing
SET ListPrice = ListPrice * 1.1
WHERE ProductID IN (SELECT TOP 3 ProductID FROM dbo.ProductPricing);

-- Wait a moment for the change to be effective
WAITFOR DELAY '00:00:05';

-- Update prices again
UPDATE dbo.ProductPricing
SET ListPrice = ListPrice * 1.05
WHERE ProductID IN (SELECT TOP 5 ProductID FROM dbo.ProductPricing);

-- Query current data
SELECT * FROM dbo.ProductPricing;

-- Query historical data (as of a specific time)
DECLARE @PastTime DATETIME2 = DATEADD(SECOND, -3, GETDATE());
SELECT * FROM dbo.ProductPricing FOR SYSTEM_TIME AS OF @PastTime;

-- Query all historical versions
SELECT * FROM dbo.ProductPricing FOR SYSTEM_TIME ALL
ORDER BY ProductID, StartDate;
```
This example creates and uses a temporal table to track product pricing changes over time.

### JSON and XML Handling in SQL Server

SQL Server provides native support for JSON and XML data, including parsing, querying, and modifying these semi-structured data formats.

**Example:**
```sql
-- XML Example
DECLARE @ProductModelXML XML;

-- Get XML data from database
SELECT @ProductModelXML = CatalogDescription
FROM Production.ProductModel
WHERE ProductModelID = 19;

-- Query XML using XQuery
SELECT
    ProductModelID,
    Name,
    @ProductModelXML.value('(/p1:ProductDescription/p1:Summary/p1:Manufacturer)[1]', 'nvarchar(max)') AS Manufacturer,
    @ProductModelXML.value('(/p1:ProductDescription/p1:Summary/p1:Features)[1]', 'nvarchar(max)') AS Features,
    @ProductModelXML.query('/p1:ProductDescription/p1:Specifications') AS Specifications
FROM 
    Production.ProductModel
WHERE 
    ProductModelID = 19;

-- Create JSON from SQL data
SELECT TOP 5
    ProductID,
    Name,
    ProductNumber,
    Color,
    StandardCost,
    ListPrice,
    Size,
    Weight,
    ProductCategoryID,
    ProductModelID
FROM 
    Production.Product
FOR JSON PATH, ROOT('Products');

-- Parse and query JSON
DECLARE @ProductJSON NVARCHAR(MAX) = N'{
  "ProductID": 15,
  "Name": "Adjustable Race",
  "Color": "Magenta",
  "StandardCost": 39.99,
  "ListPrice": 59.99,
  "Inventory": [
    {"LocationID": 1, "Quantity": 408},
    {"LocationID": 5, "Quantity": 324},
    {"LocationID": 50, "Quantity": 353}
  ],
  "Tags": ["Component", "Metal", "Adjustable"]
}';

-- Extract values from JSON
SELECT
    JSON_VALUE(@ProductJSON, '$.ProductID') AS ProductID,
    JSON_VALUE(@ProductJSON, '$.Name') AS Name,
    JSON_VALUE(@ProductJSON, '$.Color') AS Color,
    JSON_VALUE(@ProductJSON, '$.StandardCost') AS StandardCost,
    JSON_QUERY(@ProductJSON, '$.Inventory') AS InventoryJSON,
    JSON_QUERY(@ProductJSON, '$.Tags') AS TagsJSON;

-- Use OPENJSON to parse JSON array into rows
SELECT 
    LocationID,
    Quantity
FROM 
    OPENJSON(@ProductJSON, '$.Inventory')
WITH (
    LocationID INT '$.LocationID',
    Quantity INT '$.Quantity'
);
```
This example demonstrates working with XML data from the AdventureWorks database and creating/parsing JSON data.

### Full-text Search Capabilities

Full-text search provides advanced text searching capabilities beyond LIKE patterns, including word stemming, thesaurus, and proximity searching.

**Example:**
```sql
-- Note: This assumes full-text catalog and indexes are set up
-- Create full-text catalog (if it doesn't exist)
IF NOT EXISTS (SELECT 1 FROM sys.fulltext_catalogs WHERE name = 'ProductCatalog')
BEGIN
    CREATE FULLTEXT CATALOG ProductCatalog AS DEFAULT;
END

-- Create full-text index (if it doesn't exist)
IF NOT EXISTS (
    SELECT 1 
    FROM sys.fulltext_indexes fi 
    JOIN sys.tables t ON fi.object_id = t.object_id 
    WHERE t.name = 'Product'
)
BEGIN
    CREATE FULLTEXT INDEX ON Production.Product(Name, ProductNumber)
    KEY INDEX PK_Product_ProductID
    ON ProductCatalog
    WITH CHANGE_TRACKING AUTO;
END

-- Basic CONTAINS search
SELECT 
    ProductID,
    Name,
    ProductNumber
FROM 
    Production.Product
WHERE 
    CONTAINS(Name, 'mountain OR road');

-- FREETEXT search (more natural language)
SELECT 
    ProductID,
    Name,
    ProductNumber
FROM 
    Production.Product
WHERE 
    FREETEXT(Name, 'bike accessories');

-- Advanced search with proximity and weighting
SELECT 
    ProductID,
    Name,
    ProductNumber,
    ListPrice
FROM 
    Production.Product
WHERE 
    CONTAINS(Name, 'NEAR((mountain, bike), 3)');

-- Search with inflectional forms
SELECT 
    ProductID,
    Name,
    ProductNumber
FROM 
    Production.Product
WHERE 
    CONTAINS(Name, 'FORMSOF(INFLECTIONAL, ride)');
```
This example demonstrates various full-text search techniques for finding products based on name.

### Service Broker Basics

Service Broker provides asynchronous message-based communication between databases, enabling reliable, transactional message queuing within SQL Server.

**Example:**
```sql
-- Create Service Broker objects (in a test database)
CREATE QUEUE OrderQueue;
CREATE SERVICE OrderService ON QUEUE OrderQueue ([http://schemas.microsoft.com/SQL/ServiceBroker/OrderContract]);

CREATE QUEUE ProcessingQueue;
CREATE SERVICE ProcessingService ON QUEUE ProcessingQueue ([http://schemas.microsoft.com/SQL/ServiceBroker/OrderContract]);

-- Start a conversation and send a message
DECLARE @ConversationHandle UNIQUEIDENTIFIER;
DECLARE @MessageBody XML;

BEGIN TRANSACTION;

SET @MessageBody = '<Order OrderID="12345" CustomerID="789" Amount="1599.99"/>';

BEGIN DIALOG CONVERSATION @ConversationHandle
FROM SERVICE OrderService
TO SERVICE 'ProcessingService'
ON CONTRACT [http://schemas.microsoft.com/SQL/ServiceBroker/OrderContract]
WITH ENCRYPTION = OFF;

SEND ON CONVERSATION @ConversationHandle
MESSAGE TYPE [http://schemas.microsoft.com/SQL/ServiceBroker/OrderMessage]
(@MessageBody);

COMMIT TRANSACTION;

-- Receive and process the message
DECLARE @ReceivedMessage XML;
DECLARE @ReceivedConversationHandle UNIQUEIDENTIFIER;

BEGIN TRANSACTION;

RECEIVE TOP(1)
    @ReceivedConversationHandle = conversation_handle,
    @ReceivedMessage = message_body
FROM 
    ProcessingQueue;

-- Process the message (in a real scenario, this would do actual work)
SELECT 
    @ReceivedMessage.value('(/Order/@OrderID)[1]', 'int') AS OrderID,
    @ReceivedMessage.value('(/Order/@CustomerID)[1]', 'int') AS CustomerID,
    @ReceivedMessage.value('(/Order/@Amount)[1]', 'money') AS Amount;

-- End the conversation
END CONVERSATION @ReceivedConversationHandle;

COMMIT TRANSACTION;
```
This example demonstrates Service Broker basics for asynchronous order processing.

### Hierarchical Data Manipulation

SQL Server provides specialized functions for working with hierarchical data structures, such as organization charts, bill of materials, or category trees.

**Example:**
```sql
-- Create a hierarchyid-based organization structure
CREATE TABLE dbo.Organization (
    OrgNode HIERARCHYID PRIMARY KEY,
    EmployeeID INT NOT NULL,
    EmployeeName NVARCHAR(100) NOT NULL,
    Title NVARCHAR(100) NOT NULL,
    Level AS OrgNode.GetLevel() PERSISTED
);

-- Insert sample data
INSERT INTO dbo.Organization (OrgNode, EmployeeID, EmployeeName, Title)
VALUES 
    (HIERARCHYID::GetRoot(), 1, 'Ken Sánchez', 'Chief Executive Officer'),
    (HIERARCHYID::GetRoot().GetDescendant(NULL, NULL), 2, 'Terri Duffy', 'Vice President of Engineering'),
    (HIERARCHYID::GetRoot().GetDescendant(NULL, NULL).GetDescendant(NULL, NULL), 3, 'Roberto Tamburello', 'Engineering Manager'),
    (HIERARCHYID::GetRoot().GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL), 4, 'Rob Walters', 'Senior Tool Designer'),
    (HIERARCHYID::GetRoot().GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL), 5, 'Thierry D''Hers', 'Tool Designer'),
    (HIERARCHYID::GetRoot().GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL).GetDescendant(NULL, NULL), 6, 'David Bradley', 'Junior Tool Designer');

-- Query the hierarchy with indentation
SELECT 
    REPLICATE('    ', Level) + EmployeeName AS Employee,
    Title,
    Level,
    OrgNode.ToString() AS OrgNodeString
FROM 
    dbo.Organization
ORDER BY 
    OrgNode;

-- Find all reports (direct and indirect) for a manager
SELECT 
    EmployeeName,
    Title,
    Level
FROM 
    dbo.Organization
WHERE 
    OrgNode.IsDescendantOf((SELECT OrgNode FROM dbo.Organization WHERE EmployeeID = 3)) = 1
    AND EmployeeID != 3
ORDER BY 
    OrgNode;

-- Get an employee's management chain
SELECT 
    EmployeeName,
    Title,
    Level
FROM 
    dbo.Organization
WHERE 
    (SELECT OrgNode FROM dbo.Organization WHERE EmployeeID = 5).IsDescendantOf(OrgNode) = 1
ORDER BY 
    Level;
```
This example uses the HIERARCHYID data type to manage and query an organizational hierarchy.

### MERGE Statement for Upserts

The MERGE statement performs insert, update, or delete operations in a single statement based on the results of a join with a source table, simplifying data synchronization.

**Example:**
```sql
-- Create a target table for product pricing
CREATE TABLE dbo.ProductPrices (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ListPrice MONEY NOT NULL,
    LastUpdated DATETIME2 NOT NULL DEFAULT GETDATE()
);

-- Insert some initial data
INSERT INTO dbo.ProductPrices (ProductID, Name, ListPrice)
SELECT TOP 5
    ProductID, Name, ListPrice
FROM 
    Production.Product
WHERE 
    ListPrice > 0;

-- Create a source table with updated prices
DECLARE @UpdatedPrices TABLE (
    ProductID INT PRIMARY KEY,
    NewListPrice MONEY NOT NULL
);

-- Insert updated and new product prices
INSERT INTO @UpdatedPrices (ProductID, NewListPrice)
VALUES 
    (1, 2024.99),  -- Existing product with updated price
    (2, 1599.99),  -- Existing product with updated price
    (700, 59.99),  -- New product
    (701, 89.99);  -- New product

-- Perform MERGE operation
MERGE dbo.ProductPrices AS target
USING (
    SELECT 
        up.ProductID,
        p.Name,
        up.NewListPrice
    FROM 
        @UpdatedPrices up
    LEFT JOIN 
        Production.Product p ON up.ProductID = p.ProductID
) AS source
ON target.ProductID = source.ProductID
WHEN MATCHED AND target.ListPrice <> source.NewListPrice THEN
    UPDATE SET 
        target.ListPrice = source.NewListPrice,
        target.LastUpdated = GETDATE()
WHEN NOT MATCHED BY TARGET THEN
    INSERT (ProductID, Name, ListPrice)
    VALUES (source.ProductID, source.Name, source.NewListPrice)
WHEN NOT MATCHED BY SOURCE THEN
    DELETE
OUTPUT 
    $action AS Action,
    inserted.ProductID,
    deleted.ListPrice AS OldPrice,
    inserted.ListPrice AS NewPrice;

-- Check results
SELECT * FROM dbo.ProductPrices;
```
This example uses MERGE to synchronize a product price table with updated values, handling inserts, updates, and deletes in a single operation.

### Transaction Isolation Levels

Transaction isolation levels control how transactions interact with each other, balancing data consistency with concurrency requirements.

**Example:**
```sql
-- READ UNCOMMITTED: Allows dirty reads, non-repeatable reads, and phantom rows
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
BEGIN TRANSACTION;
SELECT ProductID, Name, ListPrice FROM Production.Product WHERE ProductID = 1;
-- Potential dirty read - may see uncommitted changes from other transactions
COMMIT TRANSACTION;

-- READ COMMITTED: Prevents dirty reads, allows non-repeatable reads and phantom rows
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- Default
BEGIN TRANSACTION;
SELECT ProductID, Name, ListPrice FROM Production.Product WHERE ProductID = 1;
-- Wait 5 seconds (to simulate time passing)
WAITFOR DELAY '00:00:05';
SELECT ProductID, Name, ListPrice FROM Production.Product WHERE ProductID = 1;
-- Second read might return different results if another transaction updated the row
COMMIT TRANSACTION;

-- REPEATABLE READ: Prevents dirty and non-repeatable reads, allows phantom rows
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
SELECT ProductID, Name, ListPrice FROM Production.Product WHERE ListPrice > 2000;
-- Wait 5 seconds
WAITFOR DELAY '00:00:05';
SELECT ProductID, Name, ListPrice FROM Production.