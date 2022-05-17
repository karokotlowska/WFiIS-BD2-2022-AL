--zad1

USE AdventureWorks2008;
GO
WITH cte1 AS(
SELECT st.TerritoryID, c.CustomerID, COUNT (soh.SubTotal) AS  NoOrder
FROM Sales.Customer c
JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
JOIN Sales.SalesOrderHeader soh ON c.CustomerID = soh.CustomerID
GROUP BY st.TerritoryID, c.CustomerID
HAVING COUNT (soh.SubTotal)>26
)

SELECT p.LastName, st.[Name], cte1.NoOrder, DENSE_RANK() OVER (PARTITION BY st.[Name] ORDER BY cte1.NoOrder DESC) AS TopCustomer
FROM cte1, Sales.Customer c
JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
JOIN Person.BusinessEntity be ON  c.PersonID = be.BusinessEntityID
JOIN Person.Person p ON be.BusinessEntityID = p.BusinessEntityID
WHERE cte1.CustomerID = c.CustomerID AND cte1.TerritoryID = st.TerritoryID 
GROUP BY GROUPING SETS ((p.LastName, st.Name, cte1.NoOrder))



--zad2--pivot
USE AdventureWorks2008
GO
SELECT [Zmiana], ISNULL([Production],0) AS Production, ISNULL([Information Services],0) AS [Information Services], ISNULL([Marketing],0) AS [Marketing], ISNULL([Research and Development],0) AS [Research and Development]
FROM
(
	SELECT s.Name AS [Zmiana], d.Name AS [Name], 1 AS [Quantity]
	FROM HumanResources.Employee e 
	JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID=h.BusinessEntityID
	LEFT JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	LEFT JOIN HumanResources.Shift s ON h.ShiftID = s.ShiftID
	WHERE d.Name IN ('Production', 'Information Services', 'Marketing', 'Research and Development') AND h.EndDate IS NULL
) DataTableAlias

PIVOT
(
	SUM(Quantity)
	FOR Name
	IN (
		[Production], [Information Services], [Marketing], [Research and Development]
	)
) PivotTableAlias




--zad2--case
USE AdventureWorks2008
GO
WITH cte3(Zmiana,Name,Quantity) 
AS (
SELECT s.Name AS [Zmiana], d.Name AS [Name], 1 AS [Quantity]
	FROM HumanResources.Employee e 
	JOIN HumanResources.EmployeeDepartmentHistory h ON e.BusinessEntityID=h.BusinessEntityID
	LEFT JOIN HumanResources.Department d ON h.DepartmentID = d.DepartmentID
	LEFT JOIN HumanResources.Shift s ON h.ShiftID = s.ShiftID
	WHERE d.Name IN ('Production', 'Information Services', 'Marketing', 'Research and Development') AND h.EndDate IS NULL
)

SELECT Zmiana, ISNULL(Sum(CASE WHEN Name='Production' THEN Quantity END),0) AS 'Production', ISNULL(Sum(CASE WHEN Name='Information Services' THEN Quantity END),0) AS 'Information Service', ISNULL(Sum(CASE WHEN Name='Marketing' THEN Quantity END),0) AS 'Marketing', ISNULL(Sum(CASE WHEN Name='Research and Development' THEN Quantity END),0) AS 'Research and Development'
FROM cte3 
GROUP BY Zmiana,Quantity





--zad3

CREATE TABLE dbo.Target(ID int, Nazwa varchar(64), Cena int CONSTRAINT Target_PK PRIMARY KEY(ID));
CREATE TABLE dbo.Source(ID int, Nazwa varchar(64), Cena int CONSTRAINT Source_PK PRIMARY KEY(ID));
GO
INSERT dbo.Target(ID, Nazwa, Cena) VALUES(100, 'Volvo', 200000);
INSERT dbo.Target(ID, Nazwa, Cena) VALUES(101, 'Cadillac',100000);
INSERT dbo.Target(ID, Nazwa, Cena) VALUES(102, 'Citroen',50000);
GO
INSERT dbo.Source(ID, Nazwa, Cena) VALUES(103, 'Ford',80000);
INSERT dbo.Source(ID, Nazwa, Cena) VALUES(104, 'Chevrolet',70000);
INSERT dbo.Source(ID, Nazwa, Cena) VALUES(100, 'Audi',180000);
GO


DECLARE @table TABLE (
	operacja varchar(32),
	ID int,				
	nazwa varchar(32),	
	cena int			
)

BEGIN TRAN;
MERGE Target AS T
USING Source AS S 
ON (T.ID = S.ID)
WHEN NOT MATCHED BY TARGET THEN
	INSERT(ID, Nazwa, Cena) VALUES(S.ID, S.Nazwa, S.Cena)
WHEN MATCHED 
	THEN UPDATE SET T.Nazwa = S.Nazwa, T.Cena = S.Cena
WHEN NOT MATCHED BY SOURCE 
	THEN DELETE
OUTPUT $action, 
	CASE WHEN $action != 'DELETE' THEN inserted.ID ELSE deleted.ID END,
	CASE WHEN $action != 'DELETE' THEN inserted.Nazwa ELSE deleted.Nazwa END,
	CASE WHEN $action != 'DELETE' THEN inserted.Cena ELSE deleted.Cena END
INTO @table;

SELECT * FROM @table;
ROLLBACK TRAN;
GO

