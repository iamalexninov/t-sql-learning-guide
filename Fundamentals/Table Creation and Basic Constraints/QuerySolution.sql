-- Exercise 1:
create table Test_Customer(
	CustomerID int identity(1, 1) primary key,
	FirstName varchar(50) not null,
	LastName varchar(50) not null,
	Email varchar(50) unique,
	RegistrationDate date default getdate()
);

-- Exercise 2: 
create table Test_Products(
	ProductID int identity(1, 1) primary key,
	ProductName varchar(100) not null,
	Price decimal(10,2) not null check(Price > 0),
	CategoryID int,
	Description varchar(500),
	InStock bit default 1,
);

-- Exercise 3: 
create table Test_Orders(
	OrderID int identity(1, 1) primary key,
	CustomerID int not null,
	OrderDate datetime default getdate(),
	TotalAmount decimal(12,2) not null,
	Status varchar(20) default 'Pending'
	foreign key(CustomerID) references Test_Customer(CustomerID)
);

-- Exercise 4:
create table Test_OrderDetails(
	OrderID int not null,
	ProductID int not null,
	Quantity int not null check(Quantity > 0),
	UnitPrice decimal(10,2) not null check(UnitPrice > 0),
	primary key(OrderID, ProductID),
	foreign key(OrderID) references Test_Orders(OrderID),
	foreign key(ProductID) references Test_Products(ProductID)
);

-- Exercise 5:
create table Test_Employees(
	EmployeeID int identity(1, 1) primary key,
	FirstName varchar(50) not null,
	LastName varchar(50) not null,
	BirthDate date not null,
	HireDate date not null,
	Salary decimal(10,2) not null check(Salary between 15000 and 150000),
	constraint CHK_BirthDate check (BirthDate <= cast(sysdatetime() as date)),
	constraint CHK_HireDate check (datediff(year, BirthDate, HireDate) >= 18)
);