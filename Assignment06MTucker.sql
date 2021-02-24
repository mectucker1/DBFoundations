--*************************************************************************--
-- Title: Assignment06
-- Author: YourNameHere
-- Desc: This file demonstrates how to use Views
-- Change Log: When,Who,What
-- 2021-02-17,MTucker,Created File, completed all questions
--**************************************************************************--
Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment06DB_MTucker')
	 Begin 
	  Alter Database [Assignment06DB_MTucker] set Single_user With Rollback Immediate;
	  Drop Database Assignment06DB_MTucker;
	 End
	Create Database Assignment06DB_MTucker;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment06DB_MTucker;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [mOney] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL -- New Column
,[ProductID] [int] NOT NULL
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From Categories;
go
Select * From Products;
go
Select * From Employees;
go
Select * From Inventories;
go

/********************************* Questions and Answers *********************************/
/*'NOTES------------------------------------------------------------------------------------ 
 1) You can use any name you like for you views, but be descriptive and consistent
 2) You can use your working code from assignment 5 for much of this assignment
 3) You must use the BASIC views for each table after they are created in Question 1
------------------------------------------------------------------------------------------'*/

-- Question 1 (5 pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


CREATE VIEW vCategories
WITH SCHEMABINDING
AS 
SELECT
	CategoryID,
	CategoryName
FROM dbo.Categories
GO 

CREATE VIEW vProducts
WITH SCHEMABINDING
AS
SELECT
	ProductID,
	ProductName,
	CategoryID,
	UnitPrice
FROM dbo.Products
GO 

CREATE VIEW vEmployees 
WITH SCHEMABINDING
AS
SELECT
	EmployeeID,
	EmployeeFirstName,
	EmployeeLastName,
	ManagerID
FROM dbo.Employees
GO 

CREATE VIEW vInventories
WITH SCHEMABINDING
AS
SELECT
	InventoryID,
	InventoryDate,
	EmployeeID,
	ProductID,
	Count 
FROM dbo.Inventories
GO 



-- Question 2 (5 pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?
DENY SELECT ON Categories TO PUBLIC
DENY SELECT ON Products TO PUBLIC
DENY SELECT ON Employees TO PUBLIC
DENY SELECT ON Inventories TO PUBLIC

GRANT SELECT ON vCategories TO PUBLIC
GRANT SELECT ON vProducts TO PUBLIC
GRANT SELECT ON vEmployees TO PUBLIC
GRANT SELECT ON vInventories TO PUBLIC

-- Question 3 (10 pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,UnitPrice
-- Beverages,Chai,18.00
-- Beverages,Chang,19.00
-- Beverages,Chartreuse verte,18.00

/*
-- From Assignment 5 Q1
SELECT 
	c.CategoryName, 
	p.ProductName, 
	p.UnitPrice 
FROM Categories AS c 
INNER JOIN Products AS p 
	ON c.CategoryID = p.CategoryID
ORDER BY c.CategoryName, p.ProductName
GO
*/

-- I've chosen to use "TOP 1000000" to enable me to use the order by clause, recognizing that this is not always best practice.

GO
CREATE VIEW vProductsByCategories
WITH SCHEMABINDING
AS 
SELECT TOP 1000000 
	c.CategoryName, 
	p.ProductName, 
	p.UnitPrice 
FROM dbo.Categories AS c 
INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
ORDER BY c.CategoryName, p.ProductName
GO


-- Question 4 (10 pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

-- Here is an example of some rows selected from the view:
--ProductName,InventoryDate,Count
--Alice Mutton,2017-01-01,15
--Alice Mutton,2017-02-01,78
--Alice Mutton,2017-03-01,83

/* 
-- From Assignment 05 Q2
SELECT
	p.ProductName,
	i.Count, 
	i.InventoryDate
FROM Products AS p 
INNER JOIN Inventories AS i 
	ON p.ProductID = i.ProductID
ORDER BY p.ProductName, i.InventoryDate, i.Count
GO
*/

GO
CREATE VIEW vInventoriesByProductsByDates
WITH SCHEMABINDING
AS 
SELECT TOP 100000 
	p.ProductName,
	i.Count, 
	i.InventoryDate
FROM dbo.Products AS p 
INNER JOIN dbo.Inventories AS i 
	ON p.ProductID = i.ProductID
ORDER BY p.ProductName, i.InventoryDate, i.Count
GO



-- Question 5 (10 pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

-- Here is an example of some rows selected from the view:
-- InventoryDate,EmployeeName
-- 2017-01-01,Steven Buchanan
-- 2017-02-01,Robert King
-- 2017-03-01,Anne Dodsworth

/*

-- From Assignment 05 Q3
SELECT
DISTINCT(i.InventoryDate),
	e.EmployeeID,
	e.EmployeeFirstName, 
	e.EmployeeLastName 
FROM Inventories AS i 
INNER JOIN Employees AS e 
	ON e.EmployeeID = i.EmployeeID
ORDER BY i.InventoryDate
GO
*/


-- I was getting an error when using DISTINCT along with TOP 10000.
-- Rather than tricking the system to allow me to sort the data in the view, I select all form the view and add an order clause there.  

GO
CREATE VIEW vInventoriesByEmployeesByDates 
WITH SCHEMABINDING
AS 
SELECT 
	DISTINCT(i.InventoryDate),
	e.EmployeeID,
	e.EmployeeFirstName, 
	e.EmployeeLastName 
FROM dbo.Inventories AS i 
INNER JOIN dbo.Employees AS e 
	ON e.EmployeeID = i.EmployeeID
GO

SELECT * FROM vInventoriesByEmployeesByDates
ORDER BY InventoryDate
GO

-- Question 6 (10 pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count
-- Beverages,Chai,2017-01-01,72
-- Beverages,Chai,2017-02-01,52
-- Beverages,Chai,2017-03-01,54


/*
-- Assignment 05 Q4

SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count 
FROM Categories AS c 
INNER JOIN Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN Inventories AS i 
	ON i.ProductID = p.ProductID
ORDER BY
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count 
GO 
*/

GO
CREATE VIEW vInventoriesByProductsByCategories
WITH SCHEMABINDING
AS
SELECT TOP 100000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count 
FROM dbo.Categories AS c 
INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN dbo.Inventories AS i 
	ON i.ProductID = p.ProductID
ORDER BY
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count 
GO 

-- Question 7 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chartreuse verte,2017-01-01,61,Steven Buchanan

/*
-- Assignment 5 Q5

SELECT
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	e.EmployeeLastName,
	e.EmployeeFirstName
FROM Categories AS c 
INNER JOIN Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN Inventories AS i 
	ON i.ProductID = p.ProductID
INNER JOIN Employees AS e 
	ON i.EmployeeID = e.EmployeeID
ORDER BY
	i.InventoryDate,
	c.CategoryName,
	p.ProductName,
	e.EmployeeLastName,
	e.EmployeeFirstName 
GO 
*/

GO
CREATE VIEW vInventoriesByProductsByEmployees
WITH SCHEMABINDING
AS
SELECT TOP 100000
	c.CategoryName,
	p.ProductName,
	i.InventoryDate,
	i.Count,
	e.EmployeeLastName,
	e.EmployeeFirstName
FROM dbo.Categories AS c 
INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN dbo.Inventories AS i 
	ON i.ProductID = p.ProductID
INNER JOIN dbo.Employees AS e 
	ON i.EmployeeID = e.EmployeeID
ORDER BY
	i.InventoryDate,
	c.CategoryName,
	p.ProductName,
	e.EmployeeLastName,
	e.EmployeeFirstName 
GO 


-- Question 8 (10 pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

-- Here is an example of some rows selected from the view:
-- CategoryName,ProductName,InventoryDate,Count,EmployeeName
-- Beverages,Chai,2017-01-01,72,Steven Buchanan
-- Beverages,Chang,2017-01-01,46,Steven Buchanan
-- Beverages,Chai,2017-02-01,52,Robert King

/*
-- Assignment 5 Q6
SELECT
	i.InventoryDate,
	c.CategoryName,
	p.ProductName,
	i.Count,
	e.EmployeeLastName,
	e.EmployeeFirstName
FROM Categories AS c 
INNER JOIN Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN Inventories AS i 
	ON i.ProductID = p.ProductID
INNER JOIN Employees AS e 
	ON i.EmployeeID = e.EmployeeID
WHERE p.ProductID IN 
	(SELECT ProductID FROM Products WHERE ProductName IN ('Chai','Chang'))
ORDER BY
	i.InventoryDate,
	c.CategoryName,
	p.ProductName
GO 
*/ 

CREATE VIEW vInventoriesForChaiAndChangByEmployees
WITH SCHEMABINDING
AS
SELECT TOP 100000
	i.InventoryDate,
	c.CategoryName,
	p.ProductName,
	i.Count,
	e.EmployeeLastName,
	e.EmployeeFirstName
FROM dbo.Categories AS c 
INNER JOIN dbo.Products AS p 
	ON c.CategoryID = p.CategoryID
INNER JOIN dbo.Inventories AS i 
	ON i.ProductID = p.ProductID
INNER JOIN dbo.Employees AS e 
	ON i.EmployeeID = e.EmployeeID
WHERE p.ProductID IN 
	(SELECT ProductID FROM dbo.Products WHERE ProductName IN ('Chai','Chang'))
ORDER BY
	i.InventoryDate,
	c.CategoryName,
	p.ProductName
GO 

-- Question 9 (10 pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

-- Here is an example of some rows selected from the view:
-- Manager,Employee
-- Andrew Fuller,Andrew Fuller
-- Andrew Fuller,Janet Leverling
-- Andrew Fuller,Laura Callahan

/*
-- Assignment 5 Q7

SELECT
	mgr.EmployeeFirstName AS ManagerFirstName,
	mgr.EmployeeLastName AS ManagerLastName,
	emp.EmployeeFirstName,
	emp.EmployeeLastName
FROM Employees AS emp
LEFT OUTER JOIN Employees AS mgr 	
	ON emp.ManagerID = mgr.EmployeeID
ORDER BY mgr.EmployeeFirstName
GO
*/

-- Here I am trying out using aliases in the order by clause

CREATE VIEW vEmployeesByManager
WITH SCHEMABINDING
AS
SELECT TOP 100000
	mgr.EmployeeFirstName AS ManagerFirstName,
	mgr.EmployeeLastName AS ManagerLastName,
	emp.EmployeeFirstName,
	emp.EmployeeLastName
FROM dbo.Employees AS emp
LEFT OUTER JOIN dbo.Employees AS mgr 	
	ON emp.ManagerID = mgr.EmployeeID
GO

SELECT * FROM vEmployeesByManager
ORDER BY ManagerFirstName, ManagerLastName
GO

-- Question 10 (10 pts): How can you create one view to show all the data from all four 
-- BASIC Views?

-- Here is an example of some rows selected from the view:
-- CategoryID,CategoryName,ProductID,ProductName,UnitPrice,InventoryID,InventoryDate,Count,EmployeeID,Employee,Manager
-- 1,Beverages,1,Chai,18.00,1,2017-01-01,72,5,Steven Buchanan,Andrew Fuller
-- 1,Beverages,1,Chai,18.00,78,2017-02-01,52,7,Robert King,Steven Buchanan
-- 1,Beverages,1,Chai,18.00,155,2017-03-01,54,9,Anne Dodsworth,Steven Buchanan

-- As instructions are to show data from BASIC views, I'm not pulling data from the dbo tables directly
-- Instead, I'll join the view tables themselves.
-- As I'm working in abstraction layers only, I don't need to use SchemaBind here.
-- The example rows don't include ManagerID, but I kept that in. 
-- I also had to do a self join of the view table for employee in order to show the manager's name in the same row.
-- I concatenated first name and last names for employees and managers 

GO
CREATE VIEW vInventoriesByProductsByCategoriesByEmployees
AS
SELECT TOP 100000
	vc.CategoryID,
	vc.CategoryName,
	vp.ProductID,
	vp.ProductName,
	vp.UnitPrice,
	vi.InventoryID,
	vi.InventoryDate,
	vi.Count,
	ve.EmployeeID,
	ve.EmployeeFirstName +' '+ ve.EmployeeLastName AS EmployeeName,
	ve.ManagerID,
	vmgr.EmployeeFirstName + ' ' + vmgr.EmployeeLastName AS ManagerName
FROM vCategories AS vc 
INNER JOIN vProducts AS vp 
	ON vc.CategoryID = vp.CategoryID
INNER JOIN vInventories AS vi 
	ON vi.ProductID = vp.ProductID
INNER JOIN vEmployees AS ve 
	ON vi.EmployeeID = ve.EmployeeID
LEFT OUTER JOIN vEmployees AS vmgr 	
	ON ve.ManagerID = vmgr.EmployeeID
GO 





-- Test your Views (NOTE: You must change the names to match yours as needed!)
Select * From [dbo].[vCategories]
Select * From [dbo].[vProducts]
Select * From [dbo].[vInventories]
Select * From [dbo].[vEmployees]

Select * From [dbo].[vProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByDates]
Select * From [dbo].[vInventoriesByEmployeesByDates]
Select * From [dbo].[vInventoriesByProductsByCategories]
Select * From [dbo].[vInventoriesByProductsByEmployees]
Select * From [dbo].[vInventoriesForChaiAndChangByEmployees]
Select * From [dbo].[vEmployeesByManager]
Select * From [dbo].[vInventoriesByProductsByCategoriesByEmployees]
/***************************************************************************************/