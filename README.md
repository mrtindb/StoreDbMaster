# StoreDbMaster
A C# WPF Application that controls a store database, based on MS SQL Server.

## Credits and contribution

`DatabaseCreationScript.sql` and `ProceduresScript.sql` are written by Denis Kaim ([GitHub](https://github.com/WarriorCod24), [Instagram](https://www.instagram.com/denis_kaim7?igsh=OHlhdjI1M3Q1bXds)), a former classmate of mine. This project is published with his explicit permission.

## Database properties
A multi-user database, consisting of the tables:
+ Categories
+ CustomerAccounts
+ Discounts
+ PaymentInformation
+ Products
+ Transactions

Database Diagram:

![Database UML Diagram](/Database/dbuml.png?raw=true "Optional Title")

## Application Interface
### Connect
First, the application must be connected to the MS SQL Server. This is done with a connection string, used to connect to the server. Leaving the text filed blank, we instruct the application to look for the server,
hosted on the computer, where the application is running (localhost).

![Application Connect Tab](/Application/connect.png?raw=true "Optional Title")
### Tabs
Each tab is used to visualise a different table from the database. The `Refresh` button is used to sync the displayed records with the actual table in the 
database.
![Categories Tab](/Application/categories.png?raw=true "Optional Title")

Having added two example records in Categories table, we can now add a product in Products table, selecting category from the dropdown and specifying
further details. The other tabs are implemented in a similar manner.

![Products Tab](/Application/products.png?raw=true "Optional Title")

Record deletion is done by ID for all tables.
Purchase of a product is implemented with a `transaction`, which takes care for the product quantity, the discount and the payment information, associated
with the buyer's account. If no problems arise, a new purchase record is created in the `Transactions` table.
