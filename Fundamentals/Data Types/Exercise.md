# Data Types in SQL Server

## Introduction

This document contains 10 exercises designed to help you practice working with different data types in T-SQL using the `AdventureWorks2022` database. These exercises focus on understanding how different data types work and how to query them effectively.

## **Exercises**

### 1. Numeric Data Types

Write a query to select all products from the `Production.Product` table where the `ListPrice` is greater than 1000.

```sql
-- Your query here
```

### 2. Character Data Types (VARCHAR)

Select `ProductID`, `Name`, and `ProductNumber` from the `Production.Product` table where the `ProductNumber` starts with 'BK-'.

```sql
-- Your query here
```

### 3. Date Data Types

Retrieve all sales orders from the `Sales.SalesOrderHeader` table where the `OrderDate` is between '2013-01-01' and '2013-01-31'.

```sql
-- Your query here
```

### 4. Money Data Type

Select `ProductID`, `Name`, and `ListPrice` from the `Production.Product` table where the `ListPrice` is between $1000 and $2000.

```sql
-- Your query here
```

### 5. Bit Data Type (Boolean)

Retrieve all employees from the `HumanResources.Employee` table where the `SalariedFlag` is 1 (True).

```sql
-- Your query here
```

### 6. Decimal Data Type

Select `ProductID`, `Name`, and `Weight` from the `Production.Product` table where the `Weight` is greater than 100.

```sql
-- Your query here
```

### 7. NULL Values

Find all products from the `Production.Product` table where the `Color` is NULL.

```sql
-- Your query here
```

### 8. Datetime Comparison

Select `SalesOrderID`, `OrderDate`, and `ShipDate` from the `Sales.SalesOrderHeader` table where the `ShipDate` is the same day as the `OrderDate`.

```sql
-- Your query here
```

### 9. Character Length

Retrieve all products from the `Production.Product` table where the length of the `Name` is less than 10 characters.

```sql
-- Your query here
```

### 10. Combining Data Types

Select `BusinessEntityID`, `FirstName`, `LastName`, and `ModifiedDate` from the `Person.Person` table where the `LastName` is 'Smith' and the `ModifiedDate` is after '2013-01-01'.

```sql
-- Your query here
```

## **Solutions**

### 1. Numeric Data Types

```sql
SELECT *
FROM Production.Product
WHERE ListPrice > 1000;
```

This query demonstrates working with numeric data types by filtering products based on their price.

## **End**
