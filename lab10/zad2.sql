USE AdventureWorks2008
GO


--zad2
SELECT FirstName, LastName,Demographics.value('declare default element namespace"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/NumberChildrenAtHome)[1][. > 0]','INT') -
Demographics.value('declare default element namespace"http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey";(/IndividualSurvey/TotalChildren)[1][. > 0]','INT') AS ChildDifference
FROM Person.Person
ORDER BY ChildDifference DESC;
GO


