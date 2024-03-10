USE MusicStore
--Заявка 1:  Извлича информация за имената и телефонните номера на клиентите, избран адрес на доставка и дали са избрали да получават брошури/ежеседмичен бюлетин с новини
GO
CREATE PROC Query1
AS
	SELECT Name + ' ' + Surname AS [Name of customer],Phone, ShippingAddress,[NewsletterEmails] = IIF(NewsletterEmails=1,'Yes','No')
	FROM CustomerAccounts
GO
EXEC Query1
GO
--Заявка 2: Извлича информация за имената на продуктите на цена между 60.00 и 90.00, тяхното количество в магазина и категорията им
CREATE PROC Query2
AS
	SELECT p.ProductName, p.StoredQuantity, c.CategoryName
	FROM Products AS p
	INNER JOIN Categories AS c
	ON p.CategoryID=c.CategoryID
	WHERE Price>=60 AND Price<=90
GO
EXEC Query2
GO
--Заявка 3: Сортира продуктите от категории "Аксесоари" и "Плочи" по цена и в азбучен ред
CREATE PROC Query3
AS
	SELECT p.ProductName,p.Price,c.CategoryName
	FROM Products AS p
	INNER JOIN Categories AS c
	ON p.CategoryID=c.CategoryID 
	WHERE c.CategoryName IN ('Аксесоари','Плочи')
	ORDER BY  p.Price ASC, ProductName ASC
GO
EXEC Query3
GO
--Заявка 4: Намира минималната цена на продукт от марката Gibson с гаранция
CREATE PROC Query4
AS
	SELECT MIN(Price) AS [Min Price]
	FROM Products
	WHERE ProductName LIKE '%Gibson%' AND WarrantyExpirationPeriod IS NOT NULL
GO
EXEC Query4
GO
--Заявка 5: Извлича информация за имената на клиентите и техните карти за плащане(служи и като проверка дали са използвали вече такава карта)
CREATE PROC Query5
AS
	SELECT c.Name+' '+c.Surname AS [Full Name], p.CardNumber, p.CVC
	FROM CustomerAccounts AS c
	LEFT OUTER JOIN PaymentInformation AS p
	ON c.PaymentInformationID=p.PaymentInformationID
GO
EXEC Query5
GO
--Заявка 6: Намира артикулите от категория 27 чрез процедура и параметър в клаузата WHERE и ги сортира в намаляващ ред спрямо съхраненото количество в магазина(бройката им)
CREATE OR ALTER PROC usp_CategorySortedByQuantity(@ID int )
AS
	SELECT ProductID,ProductName,Price,StoredQuantity
	FROM Products
	WHERE CategoryID=@ID
	ORDER BY StoredQuantity DESC
GO
EXEC usp_CategorySortedByQuantity 27
GO
--Заявка 7: Намира категориите, от които има поне един наличен продукт в магазина
CREATE PROC Query7
AS
	SELECT CategoryName
	FROM Categories
	WHERE EXISTS
	(SELECT 1
	FROM Products
	WHERE Categories.CategoryID=Products.CategoryID)
	ORDER BY CategoryName ASC
GO
EXEC Query7
GO
--Заявка 8: Извежда информация за продукта в най-голямо количество от всяка категория(при съвпадение се сортира по цена)
CREATE PROC Query8
AS
	SELECT c.CategoryName,ProductName,Price, StoredQuantity
	FROM Products AS p
	INNER JOIN Categories AS c
	ON p.CategoryID=c.CategoryID 
	WHERE StoredQuantity= 
	(SELECT MAX(StoredQuantity)
	FROM Products AS d
	WHERE p.CategoryID=d.CategoryID
	GROUP BY CategoryID)
	ORDER BY p.CategoryID ASC,p.Price ASC
GO
EXEC Query8
GO
--Заявка 9: Чрез функция намира дали определен продукт е наличен в магазина или не
USE MusicStore
GO
CREATE FUNCTION udf_IsProductInStore(@Name nvarchar(200))
RETURNS nvarchar(250)
AS
BEGIN
	DECLARE @print nvarchar(250)
	IF EXISTS(SELECT 1
	FROM Products
	WHERE ProductName=@Name)
	BEGIN
		SET	@print='Yes, '+@Name+' is in the store'
	END
	ELSE
	BEGIN
		SET @print='Sorry, '+@Name+' cannot be found in our store'
	END
	RETURN @print
END
SELECT dbo.udf_IsProductInStore('Перце за китара') AS [Is product found in store]
GO
--Заявка 10: Чрез функция проверява по даден имейл дали въведената парола съответства на тази от регистрацията
USE MusicStore
GO
CREATE FUNCTION udf_AccountVerification(@Email varchar(1000), @Password varchar(1000))
RETURNS BIT
AS
BEGIN
    DECLARE @result BIT
    SET @result=0
    IF (@Password=(Select Password FROM CustomerAccounts WHERE @Email=Email))
    BEGIN
        SET @result=1
    END
    ELSE
    BEGIN 
        SET @result = cast('Error Authenticating' as int);
    END
    RETURN @result
END
SELECT dbo.udf_AccountVerification('gosho@gmail.com','gogobogo234') AS [AccountVerification]
GO
--Заявка 11: Чрез функция проверява дали въведената сума пари е достатъчна за закупуване на определен продукт по зададени количество и негов номер
USE MusicStore
GO
CREATE FUNCTION udf_ImaLiPari(@Money money,@ProductID int, @Quantity int, @DiscountPercent int)
RETURNS BIT
AS
BEGIN
    DECLARE @price INT
    DECLARE @result BIT
    SET @price=(SELECT Price FROM Products WHERE @ProductID=ProductID)
    IF (@Money>=(@price - (@price*CAST(@DiscountPercent as float))/100)*@Quantity)
    BEGIN 
        SET @result=1
    END
    ELSE
    BEGIN
        SET @result=cast('Not Enough Money' as int)
    END
    RETURN @result
END 
SELECT dbo.udf_ImaLiPari(21,8,5,20) AS [Can you afford it]
GO
--Заявка 12: Намира информация за пълното име на клиентите, избраните от тях продукт и количество
CREATE PROC Query12
AS
	SELECT c.Name+' '+c.Surname AS [Full Name], p.ProductName, t.Quantity
	FROM Transactions as t
	INNER JOIN CustomerAccounts as c
	ON t.CustomerID=c.CustomerID
	INNER JOIN Products as p
	ON t.ProductID=p.ProductID
GO
EXEC Query12
GO
--Заявка 13: Намира стойността на покупката за всяка извършена транзакция
CREATE OR ALTER PROC Query13
AS
	SELECT TransactionID, (p.Price-p.Price*d.DiscountPercentage/100)*t.Quantity AS [Full Amount]
	FROM Transactions as t
	INNER JOIN CustomerAccounts as c
	ON t.CustomerID=c.CustomerID
	INNER JOIN Products as p
	ON t.ProductID=p.ProductID
	INNER JOIN Discounts as d
	ON t.DiscountID=d.DiscountID
GO
EXEC Query13
GO
--Заявка 14: Намира имената на клиентите, направили поръчка през последните 5 дни
CREATE PROC Query14
AS
	SELECT DISTINCT c.Name+' '+c.Surname as [Full Name]
	FROM Transactions AS t
	INNER JOIN CustomerAccounts AS c
	ON t.CustomerID=c.CustomerID
	WHERE t.TransactionDate BETWEEN DATEADD(day,-5,GETDATE()) AND GETDATE()
GO
EXEC Query14
GO
--Заявка 15: Намира най-купувания продукт
CREATE PROC Query15
AS
	SELECT p.ProductName
	FROM Transactions AS t
	INNER JOIN Products AS p
	ON t.ProductID=p.ProductID
	WHERE t.Quantity=(SELECT MAX(Quantity) FROM Transactions)
GO
EXEC Query15
GO