--zad1

USE AdventureWorks2008;
GO

CREATE TABLE Employee
(
	ID integer NOT NULL IDENTITY(1, 1) ,
	FirstName VARCHAR(50),
	LastName VARCHAR(50),
	Email VARCHAR(50),
	AddressLine VARCHAR(51),
	Salary MONEY,
	ModifyDate datetime,
	CONSTRAINT [PK_Vlab.Employee_ID] PRIMARY KEY CLUSTERED
		( [ID] ASC
		)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON)
)
GO

CREATE TRIGGER zad1 ON Employee
FOR INSERT, UPDATE NOT FOR REPLICATION AS
BEGIN
	DECLARE @Count int;
	SET @Count = @@ROWCOUNT;
	IF @Count = 0
		RETURN;
	SET NOCOUNT ON;
	BEGIN TRY
		IF UPDATE([Salary])
		BEGIN
			DECLARE @value int;
			SET @value = (SELECT Salary FROM deleted WHERE deleted.ID IN (SELECT inserted.[ID] FROM inserted) )
			UPDATE [Vlab].[Employee]
			SET Salary = 
			(
				CASE 
					WHEN inserted.Salary > @value AND inserted.Salary >= 10 THEN inserted.Salary 
					WHEN @value IS NULL AND inserted.Salary >= 10 THEN inserted.Salary
				ELSE @value 
				END
			)
			FROM inserted
			WHERE [Vlab].[Employee].ID IN
			(SELECT inserted.[ID] FROM inserted)
			-- = inserted.ID ;
		END;
	END TRY
	
	BEGIN CATCH
	EXECUTE [dbo].[uspPrintError];
	-- Rollback
	IF @@TRANCOUNT > 0
		BEGIN
			ROLLBACK TRANSACTION;
		END
	EXECUTE [dbo].[uspLogError];
	END CATCH;
END;





--zad2

USE AdventureWorks2008;
GO


SET NOCOUNT ON;

DECLARE @productID INT, @productName NVARCHAR(32),
	@message VARCHAR(128), @cena NVARCHAR(16),  @purchaseOrderNumber NVARCHAR(32), @shipMethod NVARCHAR(32), @shipDate NVARCHAR(16);

PRINT '-------- Struktura AdventureWorks --------';

DECLARE zad2_cursor CURSOR FOR
SELECT ProductID, [Name]
FROM Production.Product 
ORDER BY [Name];

OPEN zad2_cursor

FETCH NEXT FROM zad2_cursor
INTO @productID, @productName

WHILE @@FETCH_STATUS = 0
BEGIN
	 PRINT ' '
	 SELECT @message = '----- Produkt: ' + @productName

	 PRINT @message

	 -- nested cursor

	 DECLARE fakturaCursor CURSOR FOR
	 SELECT  CONVERT(NVARCHAR,h.PurchaseOrderNumber), CONVERT(NVARCHAR,d.UnitPrice) AS UnitPrice, CONVERT(NVARCHAR,h.ShipMethodID), CONVERT(NVARCHAR,h.ShipDate)
	 FROM Sales.SalesOrderDetail d
	 JOIN sales.SalesOrderHeader h on d.SalesOrderID = h.SalesOrderID
	 WHERE d.ProductID = @productID

	 OPEN fakturaCursor
	 FETCH NEXT FROM fakturaCursor INTO   @purchaseOrderNumber,@cena, @shipMethod, @shipDate

	 IF @@FETCH_STATUS <> 0
	 PRINT '<<Brak produktow>>'

	 WHILE @@FETCH_STATUS = 0
	 BEGIN

		 SELECT @message = ' Numer zamowienia: ' + @purchaseOrderNumber +' Cena: ' + @cena + ' ID shippingu: ' + @shipMethod + ' Data wyslania: ' + @shipDate
		 IF @message is not NULL
			PRINT @message
		 FETCH NEXT FROM fakturaCursor INTO  @purchaseOrderNumber,@cena,  @shipMethod, @shipDate
	 END

	 CLOSE fakturaCursor
	 DEALLOCATE fakturaCursor
		-- next dept.
	 FETCH NEXT FROM zad2_cursor
	 INTO @productID, @productName
END
CLOSE zad2_cursor;
DEALLOCATE  zad2_cursor;
GO
