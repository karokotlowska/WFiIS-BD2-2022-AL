--zad1

USE AdventureWorks2008;
GO
WITH cte1
(
SalesOrderID,
FirstName,
LastName,
Addres
)
AS
(
SELECT SalesOrderID, p.FirstName, p.LastName, a.AddressLine1 FROM Sales.SalesOrderHeader soh
JOIN Sales.Customer c ON c.CustomerID = soh.CustomerID
JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID = p.BusinessEntityID
JOIN Person.Address a ON a.AddressID = bea.AddressID
),
cte2
(
SalesOrderID,
PRid,
quantity,
total,
productname
)
AS
(
SELECT SalesOrderID As SOid, Det.ProductID As PRid, OrderQty As qty, LineTotal As
total, Prod.Name As ProductName
FROM Sales.SalesOrderDetail Det JOIN Production.Product Prod
ON Det.ProductID = Prod.ProductID
WHERE Prod.Name LIKE 'road %'

)

SELECT  * FROM cte1 INNER JOIN cte2 ON cte1.SalesOrderID=cte2.SalesOrderID






--zad2
USE AdventureWorks
GO

WITH cte3 AS(
    SELECT
        LastName + ' ' + FirstName as Employee,LastName + ' ' + FirstName as Supervisor, ManagerID, EmployeeID
    FROM HumanResources.Employee
    JOIN Person.Contact ON HumanResources.Employee.ContactID=Person.Contact.ContactID
    WHERE ManagerID IS NULL

UNION ALL

SELECT
    LastName + ' ' + FirstName as Employee, m.Employee as Supervisor, e.ManagerID, e.EmployeeID
    FROM HumanResources.Employee e
    JOIN Person.Contact ON e.ContactID=Person.Contact.ContactID
    JOIN cte3 m ON e.ManagerID=m.EmployeeID
)


SELECT Employee, Supervisor FROM cte3
ORDER BY Employee






--zad3
USE AdventureWorks2008
GO
WITH cte4(OrderID, BID, LN, Price) 
AS (
SELECT SalesOrderID,p.BusinessEntityID,p.LastName,soh.SubTotal FROM Sales.SalesOrderHeader soh 
JOIN Sales.Customer c ON c.CustomerID =soh.CustomerID 
JOIN Person.Person p ON c.PersonID =p.BusinessEntityID 
JOIN Person.BusinessEntityAddress bea ON bea.BusinessEntityID =p.BusinessEntityID 
JOIN Person.Address a ON a.AddressID =bea.AddressID
),
cte5 (LastName, FirstName, Total) 
AS (
SELECT TOP 20 LastName, FirstName, SUM(Price) as Total
FROM cte4
JOIN Person.Person as p ON p.BusinessEntityID = BID
JOIN Sales.SalesOrderDetail as s ON s.SalesOrderID =cte4.OrderID
JOIN Production.Product as pp ON pp.ProductID= s.ProductID
JOIN Production.ProductSubcategory as pps  ON pp.ProductSubcategoryID=pps.ProductSubcategoryID
JOIN Production.ProductCategory as ppc ON pps.ProductCategoryID=ppc.ProductCategoryID
WHERE ppc.Name= 'Bikes' 
GROUP BY LastName,FirstName
ORDER BY Total DESC

),
cte6(LastName, FirstName, Quartile, Total) 
AS(
SELECT LastName, FirstName, NTILE(4) OVER (ORDER BY SUM(Total) DESC) AS Quartile, Total
FROM cte5
GROUP BY LastName,FirstName, Total
)

SELECT LastName,FirstName,Quartile, Total FROM cte6 WHERE Quartile=2
