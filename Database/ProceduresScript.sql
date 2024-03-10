create procedure AddCategory 
 @CategoryName nvarchar(100)
AS
BEGIN
INSERT INTO Categories
VALUES ( @CategoryName)
END
GO

DROP PROC AddProduct
GO
CREATE PROCEDURE AddProduct
@Category nvarchar(100), @name nvarchar(200), @Price money, @StoredQuantity int, @WarrantyExp int
AS
BEGIN

DECLARE @CategoryID as int
SELECT @CategoryID = CategoryID FROM Categories WHERE @Category=CategoryName
INSERT INTO Products
VALUES(@CategoryID, @name, @Price, @StoredQuantity, @WarrantyExp,null)
END
GO



CREATE PROCEDURE AddDiscount
@Name nvarchar(200), @percentage float
AS
BEGIN
INSERT INTO Discounts
VALUES (@Name, @percentage)
END
GO

CREATE PROCEDURE AddCustomer
@Name nvarchar(100), 
@Surname nvarchar(100), 
@Email varchar(1000), 
@nle bit, 
@pword varchar(1000), 
@phone nvarchar(50), 
@ShippingAddress nvarchar(1000)
AS
BEGIN
INSERT INTO CustomerAccounts
VALUES (@Name, @Surname, @Email, @nle, null, @pword, @phone, @ShippingAddress)
END
GO


CREATE PROCEDURE AddPayment
@ID int,
@CardNumber varchar(16),
@CVC varchar(3),
@Name varchar(100),
@Surname varchar(100),
@BillingAddress varchar(100),
@AccountID int

AS
BEGIN
INSERT INTO PaymentInformation
VALUES(@ID, @CardNumber, @CVC, @Name, @Surname, @BillingAddress)

UPDATE CustomerAccounts
SET PaymentInformationID = @ID where @AccountID = CustomerID
END
GO

CREATE PROCEDURE DeleteUniversal @ID int, @TableName varchar(20)
AS
BEGIN
IF(@TableName = 'Categories') DELETE FROM Categories WHERE CategoryID=@ID
ELSE IF(@TableName = 'Products') DELETE FROM Products WHERE ProductID = @ID
ELSE IF(@TableName = 'CustomerAccounts') DELETE FROM CustomerAccounts WHERE CustomerID = @ID
ELSE IF(@TableName = 'Discounts') DELETE FROM Discounts WHERE DiscountID = @ID
ELSE IF(@TableName = 'PaymentInformation') DELETE FROM PaymentInformation WHERE PaymentInformationID = @ID
END
GO


CREATE PROCEDURE SelectCatalog @table varchar(50)
AS
BEGIN
IF(@table = 'Categories') SELECT CategoryName FROM Categories
ELSE IF(@table = 'Products') SELECT ProductName FROM Products
ELSE IF(@table = 'Discounts') SELECT DiscountName FROM Discounts
ELSE IF(@table = 'CustomerAccounts') SELECT CustomerID FROM CustomerAccounts
END
GO

CREATE PROCEDURE LoadProducts(@ProductName nvarchar(200), @Quantity int)
AS
BEGIN

DECLARE @ID int
SET @ID = (SELECT TOP 1 ProductID FROM Products WHERE @ProductName = ProductName)
UPDATE Products
SET StoredQuantity = StoredQuantity + @Quantity WHERE @ID = ProductID
END
GO
