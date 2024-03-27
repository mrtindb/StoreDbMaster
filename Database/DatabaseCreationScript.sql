create database StoreDB
GO

use StoreDB

ALTER DATABASE StoreDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE    
alter database StoreDB collate LATIN1_GENERAL_100_CI_AS_SC_UTF8
ALTER DATABASE StoreDB SET MULTI_USER

GO


/*
drop table Transactions
DROP TABLE Products
DROP TABLE Categories
DROP TABLE Discounts
DROP TABLE CustomerAccounts
DROP TABLE PaymentInformation*/

create table Categories(
CategoryID int identity(1,1),
CategoryName nvarchar(100),
constraint PK_CategoryID Primary Key (CategoryID)
)
GO

create table Products(
ProductID int  identity(1,1),
CategoryID int,
ProductName nvarchar(200),
Price money,
StoredQuantity int,
WarrantyExpirationPeriod int, /*in years, null if none*/
ProductImage varbinary(max),
constraint PK_ProductID Primary Key (ProductID),
constraint FK_CategoryID Foreign Key (CategoryID) references Categories(CategoryID) ON DELETE CASCADE
)
GO

create table Discounts(
DiscountID int  identity(1,1),
DiscountName nvarchar(200),
DiscountPercentage float,
CONSTRAINT PK_DiscountID PRIMARY KEY (DiscountID)
)
GO

CREATE TABLE PaymentInformation(
PaymentInformationID int,
CardNumber varchar(16),
CVC varchar(3),
Name varchar(100),
Surname varchar(100),
BillingAddress varchar(100),
CONSTRAINT PK_PaymentID PRIMARY KEY (PaymentInformationID)
)
GO


CREATE TABLE CustomerAccounts(
CustomerID int  identity(1,1),
Name nvarchar(100),
Surname nvarchar(100),
Email varchar(1000),
NewsletterEmails bit,
PaymentInformationID int,
Password varchar(1000),
Phone nvarchar(50),
ShippingAddress nvarchar(1000),
CONSTRAINT PK_CustomerID PRIMARY KEY (CustomerID),
CONSTRAINT FK_PaymentInformationID FOREIGN KEY (PaymentInformationID) REFERENCES PaymentInformation(PaymentInformationID) ON DELETE SET NULL
)
GO

CREATE TABLE Transactions(
TransactionID int  identity(1,1),
ProductID int,
Quantity int,
TransactionDate Datetime,
CustomerID int,
DiscountID int,

CONSTRAINT PK_TransactionID PRIMARY KEY (TransactionID),
CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Products(ProductID) ON DELETE NO ACTION,
CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES CustomerAccounts(CustomerID) ON DELETE NO ACTION,
CONSTRAINT FK_DiscountID FOREIGN KEY (DiscountID) REFERENCES Discounts(DiscountID) ON DELETE SET NULL
)
GO



ALTER TABLE Products
ADD CONSTRAINT CHK_Quantity CHECK (StoredQuantity>=0)

