# Table Creation and Basic Constraints

## Introduction

This document contains 5 exercises designed to help you practice creating tables and implementing basic constraints in T-SQL using the SQL Server environment. These exercises will help you understand how to define tables, data types, and enforce data integrity through constraints.

## **Exercises**

### 1. Create a Simple Customer Table

Create a table named `Customers` with the following columns:

- `CustomerID` (integer, primary key)
- `FirstName` (varchar(50), not null)
- `LastName` (varchar(50), not null)
- `Email` (varchar(100), unique)
- `RegistrationDate` (date, default current date)

```sql
-- Your query here
```

### 2. Create a Products Table with Constraints

Create a table named `Products` with the following columns and constraints:

- `ProductID` (integer, primary key)
- `ProductName` (varchar(100), not null)
- `Price` (decimal(10,2), not null)
- `CategoryID` (integer)
- `Description` (varchar(500))
- `InStock` (bit, default 1)
- Add a constraint to ensure that `Price` is greater than 0

```sql
-- Your query here
```

### 3. Create an Orders Table with Foreign Key

Create a table named `Orders` with the following columns:

- `OrderID` (integer, primary key)
- `CustomerID` (integer, not null)
- `OrderDate` (datetime, default current date and time)
- `TotalAmount` (decimal(12,2), not null)
- `Status` (varchar(20), default 'Pending')
- Add a foreign key constraint that references the `CustomerID` from the `Customers` table

```sql
-- Your query here
```

### 4. Create a Join Table with Composite Primary Key

Create a table named `OrderDetails` that represents the many-to-many relationship between Orders and Products:

- `OrderID` (integer, not null)
- `ProductID` (integer, not null)
- `Quantity` (integer, not null)
- `UnitPrice` (decimal(10,2), not null)
- Make the combination of `OrderID` and `ProductID` the primary key
- Add foreign key constraints to reference both the `Orders` and `Products` tables

```sql
-- Your query here
```

### 5. Create a Table with Check Constraints

Create a table named `Employees` with multiple check constraints:

- `EmployeeID` (integer, primary key)
- `FirstName` (varchar(50), not null)
- `LastName` (varchar(50), not null)
- `BirthDate` (date, not null)
- `HireDate` (date, not null)
- `Salary` (decimal(10,2), not null)
- `Department` (varchar(50))
- Add a check constraint to ensure that `BirthDate` is not a future date
- Add a check constraint to ensure that `HireDate` is greater than or equal to `BirthDate`
- Add a check constraint to ensure that `Salary` is between 15000 and 150000

```sql
-- Your query here
```

## **Solutions**

### 1. Create a Simple Customer Table

```sql
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    Email VARCHAR(100) UNIQUE,
    RegistrationDate DATE DEFAULT GETDATE()
);
```

This query demonstrates how to create a basic table with a primary key, NOT NULL constraints, a UNIQUE constraint, and a DEFAULT constraint.

## **END**
