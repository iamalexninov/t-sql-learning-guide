-- Basic Select Statement and Query Structure
use AdventureWorks2022
go

-- Exercise 1:
select 
	p.BusinessEntityID,
	p.FirstName,
	p.MiddleName,
	p.LastName
from Person.Person as p

-- Exercise 2:
select
	p.FirstName,
	p.LastName,
	p.EmailPromotion
from Person.Person as p

-- Exercise 3:
select * from HumanResources.Employee as hre 
where hre.JobTitle = 'Production Technician - WC60'

-- Exercise 4:
select pp.ProductID, pp.Name, pp.ListPrice  
from Production.Product as pp
order by pp.ListPrice desc;

-- Exercise 5: 
select 
	BusinessEntityID,
	NationalIDNumber,
	JobTitle,
	BirthDate,
	Gender,
	HireDate,
	SalariedFlag,
	VacationHours,
	SickLeaveHours
from HumanResources.Employee as e
where e.HireDate > '2009-01-01' and e.SalariedFlag = 1;

-- Exercise 6:
select distinct JobTitle from HumanResources.Employee

-- Exercise 7: 
select *
from Person.Person as p
where p.LastName like 'A%';

-- Exercise 8: 
select top 5 ProductID, Name, ListPrice
from Production.Product
order by ListPrice desc

-- Exercise 9:
select 
	BusinessEntityID as ID, 
	FirstName + ' ' + LastName as FullName
from Person.Person as p

-- Exercise 10:
select s.SalesOrderID, s.OrderDate, s.TotalDue  
from Sales.SalesOrderHeader as s
where s.TotalDue between 900 and 5000
order by s.TotalDue