----zad1
USE AdventureWorks2008
GO

CREATE FUNCTION dbo.udf_zad1(@BusinessEntityID int, @Delimiter varchar(1))
RETURNS varchar(max) AS

BEGIN
    DECLARE
    @t VARCHAR(max);

    SET @t=(SELECT FirstName+@Delimiter+ LastName+@Delimiter +EmailAddress+@Delimiter +City AS RESULT 
    FROM Person.EmailAddress EA
    JOIN Person.BusinessEntity BE ON EA.BusinessEntityID =BE.BusinessEntityID
    JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID =BE.BusinessEntityID
    JOIN Person.Address A ON BEA.AddressID =A.AddressID
    JOIN Person.Person P ON P.BusinessEntityID =BE.BusinessEntityID
    WHERE EA.BusinessEntityID = @BusinessEntityID)

RETURN @t
END
GO

SELECT dbo.udf_zad1(5,':') AS result
GO


----zad2
USE AdventureWorks2008
GO

CREATE FUNCTION	udf_zad5 (@N int, @P int)
RETURNS TABLE 
AS RETURN (

WITH cte( LastName, FirstName, EmailAddress, Quartile, City) 
AS (
SELECT LastName, FirstName, EmailAddress, NTILE(@N) OVER (ORDER BY City, P.LastName DESC) AS Quartile, City
    FROM Person.EmailAddress EA 
		JOIN Person.BusinessEntity BE ON EA.BusinessEntityID = BE.BusinessEntityID
		JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = BE.BusinessEntityID
		JOIN Person.Address A ON BEA.AddressID = A.AddressID
		JOIN Person.Person P ON P.BusinessEntityID = BE.BusinessEntityID
) 
SELECT FirstName, LastName, EmailAddress, City FROM cte 
WHERE cte.Quartile=@P
)
GO

select * from udf_zad5(2000,5);



----zad3
USE AdventureWorks2008
GO
CREATE FUNCTION	udf_zad3 (@LastName varchar(max))
RETURNS TABLE 
AS RETURN (
select LastName, SOH.OrderDate, SOH.SubTotal FROM Person.EmailAddress EA
JOIN Person.BusinessEntity BE ON EA.BusinessEntityID = BE.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = BE.BusinessEntityID
JOIN Person.Address A ON BEA.AddressID = A.AddressID
JOIN Person.Person P ON P.BusinessEntityID = BE.BusinessEntityID
JOIN HumanResources.Employee Emp ON P.BusinessEntityID = Emp.BusinessEntityID
JOIN Sales.SalesPerson SP ON SP.BusinessEntityID = Emp.BusinessEntityID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesPersonID = SP.BusinessEntityID
WHERE LastName = @LastName
)
GO

select * from udf_zad3('Jiang');




----zad4
USE AdventureWorks2008
GO


CREATE FUNCTION	udf_zad4 (@number int)
RETURNS TABLE 
AS RETURN (
select TOP(@number) LastName, SOH.OrderDate, SOH.SubTotal,count(SalesPersonID) AS TOTAL FROM Person.EmailAddress EA
JOIN Person.BusinessEntity BE ON EA.BusinessEntityID = BE.BusinessEntityID
JOIN Person.BusinessEntityAddress BEA ON BEA.BusinessEntityID = BE.BusinessEntityID
JOIN Person.Address A ON BEA.AddressID = A.AddressID
JOIN Person.Person P ON P.BusinessEntityID = BE.BusinessEntityID
JOIN HumanResources.Employee Emp ON P.BusinessEntityID = Emp.BusinessEntityID
JOIN Sales.SalesPerson SP ON SP.BusinessEntityID = Emp.BusinessEntityID
JOIN Sales.SalesOrderHeader SOH ON SOH.SalesPersonID = SP.BusinessEntityID
GROUP BY LastName, SOH.OrderDate, SOH.SubTotal,SalesPersonID
ORDER BY COUNT(SalesPersonID) DESC
)
GO

select * from udf_zad4(20);


----zad5
USE AdventureWorks2008
GO

CREATE VIEW rndView AS SELECT RAND() rndResult
GO

CREATE FUNCTION dbo.udf_zad5 (@Min INT, @Max INT)
RETURNS DATE
BEGIN
	DECLARE @Random INT
	SELECT @Random = FLOOR(((@Max-@Min -1)*(SELECT rndResult FROM rndView) + @Min))
	RETURN DATEADD(day, @Random, GETDATE())
END
GO

SELECT dbo.udf_zad5(1, 10)
GO

