
USE AdventureWorks2008;
GO



--zad1
WITH UDA(name) AS(
SELECT TOP(20) FirstName From Person.Person)
SELECT dbo.Aggregate1(name) FROM UDA;
go

--zad2
DECLARE @z2 [dbo].[Type1]
SET @z2= '00289451111'
SELECT @z2.ToString() AS [ToString]
go

--zad3
SELECT * FROM dbo.Function6();
