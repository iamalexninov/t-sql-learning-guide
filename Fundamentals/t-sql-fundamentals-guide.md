# T-SQL Fundamentals Guide with AdventureWorks2022

## Beginner Section: Fundamentals

### Basic SELECT Statements and Query Structure

A SELECT statement is the foundation of T-SQL queries, used to retrieve data from database tables. The basic syntax includes SELECT (columns to return), FROM (tables to query), and optional clauses like WHERE, ORDER BY, etc.

**Example:**

```sql
SELECT
    BusinessEntityID,
    FirstName,
    LastName
FROM
    Person.Person
WHERE
    PersonType = 'EM';
```

This query retrieves employee ID, first name, and last name for all employees in the Person table.

### Data Types in SQL Server

SQL Server supports various data types to define what kind of data a column can store. These include numeric types (int, decimal), character types (char, varchar), date/time types (date, datetime), and specialized types (uniqueidentifier, xml).

**Example:**

```sql
SELECT
    name,
    system_type_id,
    max_length
FROM
    sys.types
WHERE
    is_user_defined = 0
ORDER BY
    name;
```

This query shows the built-in data types available in SQL Server, their system type IDs, and maximum lengths.

### Table Creation and Basic Constraints

Creating tables involves defining columns with data types and constraints. Constraints ensure data integrity and include PRIMARY KEY (unique identifier), FOREIGN KEY (relationship enforcement), UNIQUE, DEFAULT, and CHECK constraints.

**Example:**

```sql
CREATE TABLE dbo.SimpleCustomer (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) UNIQUE,
    DateCreated DATE DEFAULT GETDATE(),
    CustomerType CHAR(1) CHECK (CustomerType IN ('R', 'W'))
);
```

This creates a simple customer table with various constraints.

### INSERT, UPDATE, DELETE Operations

These are Data Manipulation Language (DML) operations used to add, modify, or remove data from tables.

**Example:**

```sql
-- INSERT example
INSERT INTO Production.ProductCategory
    (Name, ModifiedDate)
VALUES
    ('Outdoor Accessories', GETDATE());

-- UPDATE example
UPDATE HumanResources.Employee
SET VacationHours = VacationHours + 8
WHERE BusinessEntityID = 12;

-- DELETE example
DELETE FROM Production.ProductInventory
WHERE Quantity = 0 AND Shelf = 'N/A';
```

### WHERE Clause Filtering

The WHERE clause filters rows returned by a query based on specified conditions.

**Example:**

```sql
SELECT
    ProductID,
    Name,
    ListPrice
FROM
    Production.Product
WHERE
    ListPrice > 1000 AND Color = 'Black';
```

This query returns black products with a list price over $1000.

### Basic Operators

T-SQL provides comparison operators (=, <, >, <=, >=, <>) to compare values in queries.

**Example:**

```sql
SELECT
    ProductID,
    Name,
    ListPrice
FROM
    Production.Product
WHERE
    ListPrice >= 500 AND ListPrice <= 1000;
```

This query returns products with list prices between $500 and $1000, inclusive.

### NULL Handling

NULL represents missing or unknown data. Special operators (IS NULL, IS NOT NULL) are used to check for NULL values, as NULL cannot be compared using standard operators.

**Example:**

```sql
SELECT
    ProductID,
    Name,
    Color
FROM
    Production.Product
WHERE
    Color IS NULL;
```

This query returns products where the color is not specified.

### ORDER BY for Sorting Results

The ORDER BY clause sorts query results based on one or more columns in ascending (default) or descending order.

**Example:**

```sql
SELECT
    BusinessEntityID,
    LastName,
    FirstName
FROM
    Person.Person
ORDER BY
    LastName ASC,
    FirstName DESC;
```

This query returns person records sorted by last name (ascending) and then by first name (descending).

### Simple JOINs

JOINs combine rows from two or more tables based on related columns. INNER JOIN returns rows when there's a match in both tables. LEFT JOIN returns all rows from the left table and matching rows from the right table.

**Example:**

```sql
SELECT
    p.FirstName,
    p.LastName,
    e.JobTitle
FROM
    Person.Person p
INNER JOIN
    HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
WHERE
    e.Department = 'Engineering';
```

This query returns employees in the Engineering department with their names and job titles.

### Basic String Functions

T-SQL provides functions to manipulate string data, including SUBSTRING (extract part of a string), LEN (get string length), UPPER and LOWER (change case).

**Example:**

```sql
SELECT
    ProductNumber,
    Name,
    UPPER(LEFT(Name, 3)) AS ShortCode,
    LEN(Name) AS NameLength
FROM
    Production.Product
WHERE
    LEN(Name) > 30;
```

This query returns products with long names, showing a short code made from the first three letters (uppercase) and the name length.

### Basic Date Functions

Date functions manipulate date and time data. Common functions include GETDATE (current date/time), DATEADD (add interval), and DATEDIFF (difference between dates).

**Example:**

```sql
SELECT
    SalesOrderID,
    OrderDate,
    ShipDate,
    DATEDIFF(day, OrderDate, ShipDate) AS DaysToShip,
    DATEADD(day, 30, OrderDate) AS DueDate
FROM
    Sales.SalesOrderHeader
WHERE
    YEAR(OrderDate) = 2013;
```

This query shows orders from 2013, calculating days to ship and the due date (30 days after order date).

### Simple GROUP BY with Aggregates

GROUP BY organizes rows with the same values into summary rows. Aggregate functions (COUNT, SUM, AVG, MIN, MAX) perform calculations on grouped data.

**Example:**

```sql
SELECT
    ProductCategoryID,
    COUNT(*) AS ProductCount,
    AVG(ListPrice) AS AveragePrice,
    MIN(ListPrice) AS MinPrice,
    MAX(ListPrice) AS MaxPrice
FROM
    Production.Product
GROUP BY
    ProductCategoryID;
```

This query shows product statistics by category.

### HAVING Clause

The HAVING clause filters groups in a GROUP BY query, similar to how WHERE filters individual rows.

**Example:**

```sql
SELECT
    CustomerID,
    COUNT(*) AS OrderCount,
    SUM(TotalDue) AS TotalSpent
FROM
    Sales.SalesOrderHeader
GROUP BY
    CustomerID
HAVING
    COUNT(*) > 10 AND SUM(TotalDue) > 100000;
```

This query returns customers who placed more than 10 orders with a total spend exceeding $100,000.

### Basic Transaction Concepts

Transactions group database operations into a single unit of work. BEGIN TRANSACTION starts a transaction, COMMIT finalizes changes, and ROLLBACK undoes changes.

**Example:**

```sql
BEGIN TRANSACTION;

UPDATE Production.Product
SET ListPrice = ListPrice * 1.10
WHERE ProductSubcategoryID = 2;

-- Check if any products now exceed $2000
IF EXISTS (
    SELECT 1 FROM Production.Product
    WHERE ProductSubcategoryID = 2 AND ListPrice > 2000
)
BEGIN
    ROLLBACK TRANSACTION;
    PRINT 'Transaction rolled back: price limit exceeded';
END
ELSE
BEGIN
    COMMIT TRANSACTION;
    PRINT 'Transaction committed: prices updated';
END
```

This transaction increases prices by 10% for a product subcategory but rolls back if any price exceeds $2000.

## Practice Exercises - Beginner Level

1. Write a query to retrieve the ProductID, Name, and Color for all products in the Production.Product table.

2. Find all employees (Person.Person joined with HumanResources.Employee) whose job title contains the word "Manager".

3. List the top 10 most expensive products from the Production.Product table.

4. Find all products from Production.Product where the standard cost is greater than the list price.

5. Count how many products exist in each product subcategory.

6. Find all customers (Person.Person with PersonType = 'SC') who have a first name starting with 'A'.

7. Calculate the average freight cost per order for each shipping method in Sales.SalesOrderHeader.

8. Find all products that have never been ordered (hint: use LEFT JOIN with Sales.SalesOrderDetail).

9. List all product names along with their subcategory names (join Production.Product with Production.ProductSubcategory).

10. Find the total sales amount for each year from Sales.SalesOrderHeader.

11. Create a query that displays employee names (Person.Person) and their hire date (HumanResources.Employee), showing only employees hired in 2010.

12. Find the product with the highest inventory level in each location (Production.ProductInventory).

13. List all sales territories (Sales.SalesTerritory) along with the count of customers in each territory.

14. Find all products that contain the word "bike" in their name, regardless of case.

15. Calculate the age of each employee in years based on their birth date (HumanResources.Employee).

## Usefull Documentations

1. Data Types [https://learn.microsoft.com/en-us/sql/t-sql/data-types/data-types-transact-sql?view=sql-server-ver16]
