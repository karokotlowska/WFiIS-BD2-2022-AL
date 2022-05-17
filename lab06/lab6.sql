
USE [AdventureWorks2008]
GO

CREATE ROLE[DeptA] AUTHORIZATION[dbo]
GO

CREATE ROLE[DeptB] AUTHORIZATION[dbo]
GO


--odebranie roli do inserta
GRANT SELECT, DELETE, INSERT, UPDATE ON [dbo].[Employee] TO [DeptB] WITH GRANT OPTION
GO

GRANT SELECT ON [dbo].[Employee] TO [DeptA] WITH GRANT OPTION
GO

REVOKE INSERT ON[dbo].[Employee] TO [DeptB] CASCADE
GO


--tworzenie loginu i u?ytkownika db2labD w MS SQL
USE [master]
GO
CREATE LOGIN db2labD WITH PASSWORD=N'Passw0rd',
DEFAULT_DATABASE=[AdventureWorks2008],CHECK_EXPIRATION=OFF,CHECK_POLICY=OFF
GO

CREATE LOGIN db2labA WITH PASSWORD=N'Passw0rd',
DEFAULT_DATABASE=[AdventureWorks2008],CHECK_EXPIRATION=OFF,CHECK_POLICY=OFF
GO

USE [master]
GO
CREATE LOGIN db2labB WITH PASSWORD=N'Passw0rd',
DEFAULT_DATABASE=[AdventureWorks2008],CHECK_EXPIRATION=OFF,CHECK_POLICY=OFF
GO

USE [master]
GO
CREATE LOGIN db2labC WITH PASSWORD=N'Passw0rd',
DEFAULT_DATABASE=[AdventureWorks2008],CHECK_EXPIRATION=OFF,CHECK_POLICY=OFF
GO


USE [AdventureWorks2008]
GO
CREATE USER[db2labA] FOR LOGIN[db2labA]
GO

USE [AdventureWorks2008]
GO
CREATE USER[db2labB] FOR LOGIN[db2labB]
GO

USE [AdventureWorks2008]
GO
CREATE USER[db2labC] FOR LOGIN[db2labC]
GO

USE [AdventureWorks2008]
GO
CREATE USER[db2labD] FOR LOGIN[db2labD]
GO


GRANT DELETE ON [dbo].[Employee] TO [db2labC]
GO



--dodanie dodatkowych rol dla DeptA i DeptB
USE [AdventureWorks2008]
GO
EXEC sp_addrolemember 'DeptB', 'db2labD'
GO
EXEC sp_addrolemember 'DeptA', 'db2labD'
GO

--dodanie pozostalym userom roli deptA
USE [AdventureWorks2008]
GO
EXEC sp_addrolemember 'DeptA', 'db2labA'
GO
EXEC sp_addrolemember 'DeptA', 'db2labB'
GO
EXEC sp_addrolemember 'DeptA', 'db2labC'
GO


--Nada? dodatkowe uprawnienia dla db2labD do operacji INSERT.
GRANT INSERT ON [dbo].[Employee] TO [db2labD] 
GO

--Wykaza? efektywne uprawnienia dla db2lab[A,B,C,D]
SELECT db2users.[name] As Username
, db2users.[type] AS [User Type]
, db2users.type_desc AS [Type description]
, db2perm.permission_name AS [Permission]
, db2perm.state_desc AS [Permission State]
, db2perm.class_desc Class
, object_name(db2perm.major_id) AS [Object Name]
FROM sys.database_principals db2users
LEFT JOIN
sys.database_permissions db2perm
ON db2perm.grantee_principal_id = db2users.principal_id
WHERE db2users.name IN ('db2labA', 'db2labB', 'db2labC', 'db2labD')
EXEC sp_table_privileges
@table_name = 'Employee';
GO

--Przeprowadzi? i skomentowa? test polece? Insert,Update,Delete dla tychuser-ów.

EXECUTE AS USER = 'db2labD'; --ten user moze dodawac -OK
INSERT INTO [dbo].Employee (FirstName, LastName) VALUES ('B', 'A')
REVERT;
GO

EXECUTE AS USER = 'db2labD'; --ten user moze dodawac -OK
INSERT INTO [dbo].Employee (FirstName, LastName) VALUES ('A', 'A')
REVERT;
GO

EXECUTE AS USER= 'db2labD' -- UPDATE - OK
UPDATE [dbo].Employee SET [dbo].[Employee].Salary=200 WHERE [dbo].[Employee].LastName='A' REVERT;
GO

EXECUTE AS USER= 'db2labD' -- DeptA (tylko SELECT) oraz DeptB  -OK
SELECT * FROM [dbo].[Employee];
GO

EXECUTE AS USER= 'db2labD' -- DeptA (tylko SELECT) oraz DeptB  -OK
DELETE FROM [dbo].[Employee] WHERE [dbo].[Employee].FirstName = 'A';


--EXECUTE AS USER= 'db2labA' -- UPDATE - nie OK
--UPDATE [dbo].Employee SET [dbo].[Employee].Salary=200 WHERE [dbo].[Employee].LastName='A' REVERT;
--GO


--EXECUTE AS USER= 'db2labA' -- DeptA (tylko SELECT) -nie OK
--INSERT INTO [dbo].[Employee] (FirstName, LastName) values ('A', 'A');
--GO

--EXECUTE AS USER= 'db2labB' -- DeptA (tylko SELECT) -nie OK
--INSERT INTO [dbo].[Employee] (FirstName, LastName) values ('A', 'A');
--GO

--EXECUTE AS USER = 'db2labC'; --DeptA (tylko SELECT) -nie OK
--INSERT INTO [dbo].Employee (FirstName, LastName) VALUES ('A', 'A')
--REVERT;
--GO

--EXECUTE AS USER= 'db2labA' --  -nie OK
--DELETE FROM [dbo].[Employee] WHERE [dbo].[Employee].FirstName = 'A';



--usniecie rol i loginow
USE [master]
GO
DROP LOGIN[db2labD]
GO

USE [master]
GO
DROP USER[db2labD]
GO

USE [master]
GO
DROP LOGIN[db2labA]
GO

USE [master]
GO
DROP USER[db2labA]
GO

USE [master]
GO
DROP LOGIN[db2labC]
GO

USE [master]
GO
DROP USER[db2labC]
GO

USE [master]
GO
DROP LOGIN[db2labB]
GO

USE [master]
GO
DROP USER[db2labB]
GO

USE [master]
GO
DROP ROLE [DeptA]
DROP ROLE [DeptB]
GO

