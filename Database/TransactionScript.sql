/* Transaction is inside a procedure to easen the implementation in the control software */
CREATE PROCEDURE ExecuteTransaction @ProductName nvarchar(200), @DesiredQuantity int, @Money money, @Email varchar(1000), @Password varchar(1000), @DiscountName nvarchar(200)
AS
BEGIN
BEGIN TRANSACTION
BEGIN TRY
DECLARE @ProductID int
SET @ProductID = (SELECT TOP 1 ProductID FROM Products WHERE @ProductName = ProductName)


DECLARE @DiscountID int
IF(@DiscountName is not null) BEGIN
SET @DiscountID = (SELECT TOP 1 DiscountID FROM Discounts WHERE @DiscountName = DiscountName)
END
ELSE
BEGIN SET @DiscountID = null
END

DECLARE @DiscountPercent int
IF(@DiscountID is null)BEGIN SET @DiscountPercent = 0 END
ELSE BEGIN SET @DiscountPercent = (SELECT DiscountPercentage FROM Discounts WHERE DiscountID = @DiscountID) END


DECLARE @BoolChecker bit
SET @BoolChecker = (SELECT dbo.udf_AccountVerification(@Email,@Password))
SET @BoolChecker = (SELECT dbo.udf_ImaLiPari(@Money, @ProductID, @DesiredQuantity, @DiscountPercent))
DECLARE @ClientID int
SET @ClientID = (SELECT TOP 1 CustomerID FROM CustomerAccounts WHERE @Email = Email)

IF((SELECT PaymentInformationID FROM CustomerAccounts WHERE CustomerID=@ClientID)is null) throw 50000, 'No payment info', 1

UPDATE Products
SET StoredQuantity=StoredQuantity-@DesiredQuantity WHERE @ProductID = ProductID

INSERT INTO Transactions 
VALUES (@ProductID, @DesiredQuantity, GETDATE(), @ClientID, @DiscountID)

END TRY
BEGIN CATCH
ROLLBACK TRAN
SELECT 'Error'
END CATCH
IF(@@TRANCOUNT<>0) BEGIN COMMIT TRAN; SELECT * FROM Transactions END
END






