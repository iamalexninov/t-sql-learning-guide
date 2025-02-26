-- Data Types Exercises
use AdventureWorks2022
go

-- Exercise 1:
select * from Production.Product 
where ListPrice > 1000 
order by ListPrice asc;

-- Exercise 2: 
select ProductID, Name, ProductNumber
from Production.Product
where ProductNumber like 'BK-%';

-- Exercise 3:
select *
from Sales.SalesOrderHeader 
where OrderDate between '2013-01-01' and '2013-01-31';

-- Exercise 4:
select ProductID, Name, ListPrice
from Production.Product
where ListPrice between 1000 and 2000
order by ListPrice;

-- Exercise 5:
select * 
from HumanResources.Employee
where SalariedFlag = 1

-- Exercise 6:
select ProductID, Name, Weight
from Production.Product
where Weight > 100
order by Weight;

-- Exercise 7:
select *
from Production.Product
where Color is null;

-- Exercise 8:
select SalesOrderID, OrderDate, ShipDate 
from Sales.SalesOrderHeader
where ShipDate = OrderDate

-- Exercise 9:
select *
from Production.Product
where len(Name) > 10

-- Exercise 10: 
select BusinessEntityID, FirstName, LastName, ModifiedDate
from Person.Person
where LastName = 'Smith' and ModifiedDate > '2013-01-01'
order by ModifiedDate