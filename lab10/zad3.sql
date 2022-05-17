USE AdventureWorks2008
GO

--zad3
SELECT Resume.query('declare namespace ns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume";
for $p in /ns:Resume

return
<person xmlns="http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/Resume">
<Name>{data($p/ns:Name/ns:Name.Last)}</Name>
<City>{data($p/ns:Address/ns:Addr.Location/ns:Location/ns:Loc.City)}</City>
<Street>{data($p/ns:Address/ns:Addr.Street)}</Street>
</person>
'
)
FROM HumanResources.JobCandidate
GO

