# Select Statement & Query Structure

## Introduction

This document contains 10 exercises designed to help you practice basic `SELECT` statements and query structures in T-SQL using the `AdventureWorks2022` database. These exercises cover fundamental query operations such as filtering, sorting, and using SQL clauses.

## **Exercises**

### 1. Retrieve All Columns from a Table

Write a query to select all columns from the `Person.Person` table.

```sql
-- Your query here
```

### 2. Retrieve Specific Columns

Select `FirstName`, `LastName`, and `EmailPromotion` from the `Person.Person` table.

```sql
-- Your query here
```

### 3. Use of WHERE Clause

Retrieve all employees from the `HumanResources.Employee` table where `JobTitle` is `'Production Technician - WC60'`.

```sql
-- Your query here
```

### 4. Sorting Results

Select `ProductID`, `Name`, and `ListPrice` from the `Production.Product` table and sort the results by `ListPrice` in descending order.

```sql
-- Your query here
```

### 5. Filtering with Multiple Conditions

Retrieve all employees from the `HumanResources.Employee` table who were hired after `'2009-01-01'` and whose `SalariedFlag` is `1`.

```sql
-- Your query here
```

### 6. Using DISTINCT

Select all unique `JobTitle` values from the `HumanResources.Employee` table.

```sql
-- Your query here
```

### 7. Using LIKE for Pattern Matching

Find all persons from the `Person.Person` table where the `LastName` starts with `A`.

```sql
-- Your query here
```

### 8. Using TOP to Limit Results

Retrieve the top 5 most expensive products (`ProductID`, `Name`, and `ListPrice`) from the `Production.Product` table.

```sql
-- Your query here
```

### 9. Using Aliases

Retrieve `BusinessEntityID`, `FirstName`, and `LastName` from the `Person.Person` table and rename the columns as `ID`, `First Name`, and `Last Name`.

```sql
-- Your query here
```

### 10. Using BETWEEN for Range Filtering

Select `SalesOrderID`, `OrderDate`, and `TotalDue` from the `Sales.SalesOrderHeader` table where the `TotalDue` is between `1000` and `5000`.

```sql
-- Your query here
```

## **Instructions**

1. Open SQL Server Management Studio (SSMS).
2. Connect to your SQL Server instance.
3. Make sure the `AdventureWorks2022` database is available.
4. Copy each query, execute it, and analyze the results.

Happy Learning! 🚀
