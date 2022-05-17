USE AdventureWorks2008
GO

--zad1
SELECT FirstName, LastName, Demographics.value('declare default element namespace"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/YearlyIncome)[1]','varchar(250)') AS YearlyIncome FROM Person.Person
ORDER BY YearlyIncome DESC;
GO



