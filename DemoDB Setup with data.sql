USE
	master;
GO

-- Create the "DemoDB" database

IF
	DB_ID (N'DemoDB') IS NOT NULL
BEGIN

	ALTER DATABASE
		DemoDB
	SET
		SINGLE_USER
	WITH
		ROLLBACK IMMEDIATE;

	DROP DATABASE
		DemoDB;

END;
GO


CREATE DATABASE
	DemoDB;
GO


ALTER DATABASE
	DemoDB
SET RECOVERY
	SIMPLE;
GO


-- Create schemas

USE
	DemoDB;
GO


CREATE SCHEMA
	Lists;
GO


CREATE SCHEMA
	Marketing;
GO


CREATE SCHEMA
	Sales;
GO


CREATE SCHEMA
	Inventory;
GO


CREATE SCHEMA
	Operation;
GO


CREATE SCHEMA
	Billing;
GO


-- Create list tables

CREATE TABLE
	Lists.ProductStatuses
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL ,

	CONSTRAINT
		pk_ProductStatuses_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.ProductStatuses
(
	Id ,
	Name
)
VALUES
	( 1	, N'New'		) ,
	( 2	, N'Beta'		) ,
	( 3	, N'Sale'		) ,
	( 4	, N'Obsolete'	);
GO


CREATE TABLE
	Lists.OrderStatuses
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL ,

	CONSTRAINT
		pk_OrderStatuses_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.OrderStatuses
(
	Id ,
	Name
)
VALUES
	( 1	, N'New'				) ,
	( 2	, N'Pending Payment'	) ,
	( 3	, N'Paid'				) ,
	( 4	, N'Packed'				) ,
	( 5	, N'Shipped'			) ,
	( 6	, N'Delivered'			) ,
	( 7	, N'Closed'				) ,
	( 8	, N'Cancelled'			);
GO


CREATE TABLE
	Lists.Countries
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL ,

	CONSTRAINT
		pk_Countries_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.Countries
(
	Id ,
	Name
)
VALUES
	( 1	, N'Israel'		) ,
	( 2	, N'USA'		) ,
	( 3	, N'England'	) ,
	( 4	, N'France'		) ,
	( 5	, N'Italy'		);
GO


CREATE TABLE
	Lists.Genders
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL

	CONSTRAINT
		pk_Genders_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.Genders
(
	Id ,
	Name
)
VALUES
	( 1	, N'Male'	) ,
	( 2	, N'Female'	);
GO


CREATE TABLE
	Lists.MaritalStatuses
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL

	CONSTRAINT
		pk_MaritalStatuses_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.MaritalStatuses
(
	Id ,
	Name
)
VALUES
	( 1	, N'Single'		) ,
	( 2	, N'Married'	) ,
	( 3	, N'Divorced'	) ,
	( 4	, N'Widowed'	);
GO


CREATE TABLE
	Lists.SessionEndReasons
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL

	CONSTRAINT
		pk_SessionEndReasons_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.SessionEndReasons
(
	Id ,
	Name
)
VALUES
	( 1	, N'Logout'					) ,
	( 2	, N'Disconnection'			) ,
	( 3	, N'Inactive'				) ,
	( 4	, N'Another Session Opened'	);
GO


CREATE TABLE
	Lists.InvitationStatuses
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL

	CONSTRAINT
		pk_InvitationStatuses_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.InvitationStatuses
(
	Id ,
	Name
)
VALUES
	( 1	, N'Sent'		) ,
	( 2	, N'Accepted'	) ,
	( 3	, N'Denied'		) ,
	( 4	, N'Cancelled'	);
GO


CREATE TABLE
	Lists.EventTypes
(
	Id		TINYINT			NOT NULL ,
	Name	NVARCHAR(50)	NOT NULL ,

	CONSTRAINT
		pk_EventTypes_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


INSERT INTO
	Lists.EventTypes
(
	Id ,
	Name
)
VALUES
	( 1	, N'Click'		) ,
	( 2	, N'Mouse Move'	) ,
	( 3	, N'Refresh'	) ,
	( 4	, N'Open'		) ,
	( 5	, N'Close'		);
GO


-- Create operational tables

CREATE TABLE
	Marketing.Customers
(
	Id					INT				NOT NULL	IDENTITY(1,1) ,
	Name				NVARCHAR(50)	NOT NULL ,
	Phone				NVARCHAR(20)	NULL ,
	BirthDate			DATE			NULL ,
	SourceURL			NVARCHAR(1000)	NULL ,
	Country				NCHAR(2)		NOT NULL ,
	LastPurchaseDate	DATE			NULL ,

	CONSTRAINT
		pk_Customers_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO

CREATE TABLE
	Inventory.Products
(
	Id				INT				NOT NULL	IDENTITY(1,1) ,
	Name			NVARCHAR(50)	NOT NULL ,
	ListPrice		MONEY			NOT NULL ,
	ProductStatusId	TINYINT			NOT NULL ,

	CONSTRAINT
		pk_Products_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_Products_ProductStatusId_ProductStatuses_Id
	FOREIGN KEY
		(ProductStatusId)
	REFERENCES
		Lists.ProductStatuses (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Sales.Orders
(
	Id				INT				NOT NULL	IDENTITY(1,1) ,
	CustomerId		INT				NOT NULL ,
	DateAndTime		DATETIME2(0)	NOT NULL ,
	OrderStatusId	TINYINT			NOT NULL ,
	Comments		NVARCHAR(1000)	NULL ,

	CONSTRAINT
		pk_Orders_nc_Id
	PRIMARY KEY NONCLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_Orders_CustomerId_Customers_Id
	FOREIGN KEY
		(CustomerId)
	REFERENCES
		Marketing.Customers (Id) ,

	CONSTRAINT
		fk_Orders_OrderStatusId_OrderStatuses_Id
	FOREIGN KEY
		(OrderStatusId)
	REFERENCES
		Lists.OrderStatuses (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Sales.OrderProducts
(
	Id			INT		NOT NULL	IDENTITY(1,1) ,
	OrderId		INT		NOT NULL ,
	ProductId	INT		NOT NULL ,
	Quantity	INT		NOT NULL ,
	UnitPrice	MONEY	NOT NULL ,

	CONSTRAINT
		pk_OrderProducts_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_OrderProducts_OrderId_Orders_Id
	FOREIGN KEY
		(OrderId)
	REFERENCES
		Sales.Orders (Id) ,

	CONSTRAINT
		fk_OrderProducts_ProductId_Products_Id
	FOREIGN KEY
		(ProductId)
	REFERENCES
		Inventory.Products (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Operation.Members
(
	Id						INT				NOT NULL	IDENTITY (1,1) ,
	Username				NVARCHAR(10)	NOT NULL ,
	Password				NVARCHAR(10)	NOT NULL ,
	FirstName				NVARCHAR(20)	NOT NULL ,
	LastName				NVARCHAR(20)	NOT NULL ,
	StreetAddress			NVARCHAR(100)	NULL ,
	CountryId				TINYINT			NOT NULL ,
	PhoneNumber				NVARCHAR(20)	NULL ,
	EmailAddress			NVARCHAR(100)	NOT NULL ,
	GenderId				TINYINT			NOT NULL ,
	BirthDate				DATE			NOT NULL ,
	SexualPreferenceId		TINYINT			NULL ,
	MaritalStatusId			TINYINT			NULL ,
	Picture					VARBINARY(MAX)	NULL ,
	RegistrationDateTime	DATETIME2(0)	NOT NULL ,
	ReferringMemberId		INT				NULL ,

	CONSTRAINT
		pk_Members_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_Members_CountryId_Countries_Id
	FOREIGN KEY
		(CountryId)
	REFERENCES
		Lists.Countries (Id) ,

	CONSTRAINT
		fk_Members_GenderId_Genders_Id
	FOREIGN KEY
		(GenderId)
	REFERENCES
		Lists.Genders (Id) ,

	CONSTRAINT
		fk_Members_SexualPreferenceId_Genders_Id
	FOREIGN KEY
		(SexualPreferenceId)
	REFERENCES
		Lists.Genders (Id) ,

	CONSTRAINT
		fk_Members_MaritalStatusId_MaritalStatuses_Id
	FOREIGN KEY
		(MaritalStatusId)
	REFERENCES
		Lists.MaritalStatuses (Id) ,

	CONSTRAINT
		fk_Members_ReferringMemberId_Members_Id
	FOREIGN KEY
		(ReferringMemberId)
	REFERENCES
		Operation.Members (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Operation.MemberSessions
(
	Id				INT				NOT NULL	IDENTITY (1,1) ,
	MemberId		INT				NOT NULL ,
	LoginDateTime	DATETIME2(0)	NOT NULL ,
	EndDateTime		DATETIME2(0)	NULL ,
	EndReasonId		TINYINT			NULL ,

	CONSTRAINT
		pk_MemberSessions_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_MemberSessions_MemberId_Members_Id
	FOREIGN KEY
		(MemberId)
	REFERENCES
		Operation.Members (Id) ,

	CONSTRAINT
		fk_MemberSessions_EndReasonId_SessionEndReasons_Id
	FOREIGN KEY
		(EndReasonId)
	REFERENCES
		Lists.SessionEndReasons (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Operation.Invitations
(
	Id					INT				NOT NULL	IDENTITY(1,1) ,
	RequestingSessionId	INT				NOT NULL ,
	ReceivingMemberId	INT				NOT NULL ,
	CreationDateTime	DATETIME2(0)	NOT NULL ,
	StatusId			TINYINT			NOT NULL ,
	ResponseDateTime	DATETIME2(0)	NULL ,

	CONSTRAINT
		pk_Invitations_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_Invitations_StatusId_InvitationStatuses_Id
	FOREIGN KEY
		(StatusId)
	REFERENCES
		Lists.InvitationStatuses (Id)
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Billing.Payments
(
	Id					INT				NOT NULL	IDENTITY(1,1) ,
	MemberId			NVARCHAR(20)	NOT NULL ,
	Amount				DECIMAL(19,2)	NOT NULL ,
	DateAndTime			DATETIME2(0)	NOT NULL

	CONSTRAINT
		pk_Payments_c_Id
	PRIMARY KEY CLUSTERED
		(Id ASC)
	ON
		[PRIMARY]
)
ON
	[PRIMARY];
GO


CREATE TABLE
	Billing.Transactions
(
	TransactionId		INT				NOT NULL	IDENTITY (1,1) ,
	AccountId			INT				NOT NULL ,
	TransactionDateTime	DATETIME2(0)	NOT NULL ,
	Amount				MONEY			NOT NULL ,

	CONSTRAINT
		pk_Transactions_nc_TransactionId
	PRIMARY KEY NONCLUSTERED
		(TransactionId ASC)
);
GO


CREATE TABLE
	Operation.SessionEvents
(
	Id				INT				NOT NULL	IDENTITY (1,1) ,
	MemberId		INT				NOT NULL ,
	SessionId		INT				NOT NULL ,
	EventTypeId		TINYINT			NOT NULL ,
	DateAndTime		DATETIME2(3)	NOT NULL ,
	URL				NVARCHAR(1000)	NOT NULL ,

	CONSTRAINT
		pk_SessionEvents_c_Id
	PRIMARY KEY NONCLUSTERED
		(Id ASC)
	ON
		[PRIMARY] ,

	CONSTRAINT
		fk_SessionEvents_MemberId_Members_Id
	FOREIGN KEY
		(MemberId)
	REFERENCES
		Operation.Members (Id) ,

	CONSTRAINT
		fk_SessionEvents_SessionId_MemberSessions_Id
	FOREIGN KEY
		(SessionId)
	REFERENCES
		Operation.MemberSessions (Id) ,

	CONSTRAINT
		fk_SessionEvents_EventTypeId_EventTypes_Id
	FOREIGN KEY
		(EventTypeId)
	REFERENCES
		Lists.EventTypes (Id)
)
ON
	[PRIMARY];
GO

-- Populate the operational tables

INSERT INTO
	Marketing.Customers WITH (TABLOCK)
(
	Name ,
	Phone ,
	BirthDate ,
	SourceURL ,
	Country ,
	LastPurchaseDate
)
SELECT TOP (100000)
	Name				= N'Customer #' + CAST (ROW_NUMBER () OVER (ORDER BY (SELECT NULL) ASC) AS NVARCHAR(50)) ,
	Phone				=	CASE
								WHEN ABS (CHECKSUM (NEWID ())) % 100 <= 70
									THEN LEFT (CAST (NEWID () AS NVARCHAR(MAX)) , 20)
								ELSE
									NULL
							END ,
	BirthDate			=	CASE
								WHEN ABS (CHECKSUM (NEWID ())) % 100 <= 70
									THEN DATEADD (DAY , - ABS (CHECKSUM (NEWID ())) % (365 * 60) - (365 * 20) , SYSDATETIME ())
								ELSE
									NULL
							END ,
	SourceURL			=	CASE
								WHEN ABS (CHECKSUM (NEWID ())) % 100 <= 80
									THEN N'http://www.abc.com/' + CAST (NEWID () AS NVARCHAR(1000))
								ELSE
									NULL
							END ,
	Country				=	CASE
								WHEN
									RandomNumbers.RandomNumber BETWEEN 1 AND 40
								THEN
									N'US'
								WHEN
									RandomNumbers.RandomNumber BETWEEN 41 AND 70
								THEN
									N'CN'
								WHEN
									RandomNumbers.RandomNumber BETWEEN 71 AND 99
								THEN
									N'UK'
								WHEN
									RandomNumbers.RandomNumber = 100
								THEN
									Countries.Country
							END ,
	LastPurchaseDate	= DATEADD (DAY , - (ABS (CHECKSUM (NEWID ())) % (365)) , SYSDATETIME ())
FROM
	sys.all_columns
CROSS JOIN
	(
		VALUES
			(N'AF') ,
			(N'BE') ,
			(N'CL') ,
			(N'DK') ,
			(N'EG') ,
			(N'FR') ,
			(N'GR') ,
			(N'IL') ,
			(N'JP') ,
			(N'MT') ,
			(N'NO') ,
			(N'PT') ,
			(N'SE') ,
			(N'TR') ,
			(N'VE')
	)
	AS
		Countries (Country)
CROSS JOIN
	(
		SELECT
			RandomNumber = ABS (CHECKSUM (NEWID ())) % 100 + 1
	)
	AS
		RandomNumbers
ORDER BY
	NEWID () ASC;
GO


CREATE NONCLUSTERED INDEX
	ix_Customers_nc_nu_SourceURL
ON
	Marketing.Customers (SourceURL ASC);
GO


CREATE NONCLUSTERED INDEX
	ix_Customers_nc_nu_Country
ON
	Marketing.Customers (Country ASC);
GO


INSERT INTO
	Inventory.Products WITH (TABLOCK)
(
	Name ,
	ListPrice ,
	ProductStatusId
)
SELECT TOP (100000)
	Name			= N'Product #' + CAST (ROW_NUMBER () OVER (ORDER BY (SELECT NULL) ASC) AS NVARCHAR(50)) ,
	UnitPrice		= CAST ((ABS (CHECKSUM (NEWID ())) % 100000 / 100.0) AS MONEY) ,
	ProductStatusId	= ABS (CHECKSUM (NEWID ())) % 4 + 1
FROM
	sys.all_columns AS T1
CROSS JOIN
	sys.all_columns AS T2;
GO


CREATE NONCLUSTERED INDEX
	ix_Products_nc_nu_ProductStatusId
ON
	Inventory.Products
	(
		ProductStatusId	ASC ,
		ListPrice		DESC
	);
GO


INSERT INTO
	Sales.Orders WITH (TABLOCK)
(
	CustomerId ,
	DateAndTime ,
	OrderStatusId ,
	Comments
)
SELECT TOP (1000000)
	CustomerId		= Customers.Id ,
	DateAndTime		= DATEADD (MINUTE , - ABS (CHECKSUM (NEWID ())) % (60 * 24 * 365 * 5) , SYSDATETIME ()) ,
	OrderStatusId	= ABS (CHECKSUM (NEWID ())) % 8 + 1 ,
	Comments		=	CASE
							WHEN ABS (CHECKSUM (NEWID ())) % 100 <= 40
								THEN REPLICATE (N'Bla ' , ABS (CHECKSUM (NEWID ())) % 50)
							ELSE
								NULL
						END
FROM
	Marketing.Customers AS Customers
CROSS JOIN
	(
		VALUES (1) , (2) , (3) , (4) , (5) , (6) , (7) , (8) , (9) , (10)
	)
	AS
		Numbers (Number)
ORDER BY
	NEWID () ASC;
GO


CREATE NONCLUSTERED INDEX
	ix_Orders_nc_nu_CustomerId
ON
	Sales.Orders (CustomerId ASC);
GO


INSERT INTO
	Sales.OrderProducts WITH (TABLOCK)
(
	OrderId ,
	ProductId ,
	Quantity ,
	UnitPrice
)
SELECT TOP (3000000)
	OrderId		= Orders.Id ,
	ProductId	= ABS (CHECKSUM (NEWID ())) % 100000 + 1 ,
	Quantity	= ABS (CHECKSUM (NEWID ())) % 10 + 1 ,
	UnitPrice	= CAST ((ABS (CHECKSUM (NEWID ())) % 100000 / 100.0) AS MONEY)
FROM
	Sales.Orders AS Orders
CROSS JOIN
	(
		VALUES (1) , (2) , (3) , (4) , (5) , (6) , (7) , (8) , (9) , (10)
	)
	AS
		Numbers (Number)
ORDER BY
	NEWID () ASC;
GO

DECLARE
	@tblFirstNames
TABLE
(
	Name		NVARCHAR(20)	NOT NULL ,
	GenderId	TINYINT			NOT NULL
);

INSERT INTO
	@tblFirstNames
(
	Name ,
	GenderId
)
SELECT
	Name		= N'John' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'David' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'James' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Ron' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Bruce' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Bryan' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Gimmy' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Rick' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Paul' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Phil' ,
	GenderId	= 1

UNION ALL

SELECT
	Name		= N'Laura' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Jane' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Sara' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Lian' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Rita' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Samantha' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Suzan' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Marry' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Monica' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Julia' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Shila' ,
	GenderId	= 2

UNION ALL

SELECT
	Name		= N'Angela' ,
	GenderId	= 2;

DECLARE
	@tblLastNames
TABLE
(
	Name NVARCHAR(20) NOT NULL
);

INSERT INTO @tblLastNames
(
	Name
)
SELECT
	Name = N'Jones'

UNION ALL

SELECT
	Name = N'McDonald'

UNION ALL

SELECT
	Name = N'Simon'

UNION ALL

SELECT
	Name = N'Petty'

UNION ALL

SELECT
	Name = N'Bond'

UNION ALL

SELECT
	Name = N'Simpson'

UNION ALL

SELECT
	Name = N'Polsky'

UNION ALL

SELECT
	Name = N'Mayers'

UNION ALL

SELECT
	Name = N'Taylor'

UNION ALL

SELECT
	Name = N'Austin'

UNION ALL

SELECT
	Name = N'Ramsfeld';

INSERT INTO
	Operation.Members WITH (TABLOCK)
(
	UserName ,
	Password ,
	FirstName ,
	LastName ,
	StreetAddress ,
	CountryId ,
	PhoneNumber ,
	EmailAddress ,
	GenderId ,
	BirthDate ,
	SexualPreferenceId ,
	MaritalStatusId ,
	Picture ,
	RegistrationDateTime ,
	ReferringMemberId
)
SELECT TOP (100000)
	UserName				= REPLICATE (N'X' , ABS (CHECKSUM (NEWID ())) % 10 + 1) ,
	Password				= CAST (ROW_NUMBER () OVER (ORDER BY (SELECT NULL) ASC) AS NVARCHAR(10)) ,
	FirstName				= FirstNames.Name ,
	LastName				= LastNames.Name ,
	StreetAddress			=	CASE
									WHEN ABS (CHECKSUM (NEWID ())) % 100 < 20
										THEN NULL
									ELSE
										REPLICATE (N'X' , ABS (CHECKSUM (NEWID ())) % 100 + 1)
								END ,
	CountryId				= ABS (CHECKSUM (NEWID ())) % 5 + 1 ,
	PhoneNumber				=	CASE
									WHEN ABS (CHECKSUM (NEWID ())) % 100 < 20
										THEN NULL
									ELSE
										CAST ((ABS (CHECKSUM (NEWID ())) % 1000000000 + 100000000) AS NVARCHAR(20))
								END ,
	EmailAddress			= REPLICATE (N'x' , ABS (CHECKSUM (NEWID ())) % 10 + 1) + N'@gmail.com' ,
	GenderId				= FirstNames.GenderId ,
	BirthDate				= CAST (DATEADD (DAY , DATEDIFF (DAY , '1900-01-01' , SYSDATETIME ()) - (19 * 365) - (ABS (CHECKSUM (NEWID ())) % (30 * 365)) , '1900-01-01') AS DATE) ,
	SexualPreferenceId		=	CASE RandomValueTable.RandomValue
									WHEN 1
										THEN 1
									WHEN 2
										THEN 2
									WHEN 3
										THEN NULL
								END ,	
	MaritalStatusId			=	CASE
									WHEN ABS (CHECKSUM (NEWID ())) % 100 < 20
										THEN NULL
									ELSE
										ABS (CHECKSUM (NEWID ())) % 4 + 1
								END ,
	Picture					=	CASE
									WHEN ABS (CHECKSUM (NEWID ())) % 100 < 30
										THEN NULL
									ELSE
										CAST (REPLICATE (N'Picture' , ABS (CHECKSUM (NEWID ())) % 1000 + 1) AS VARBINARY(MAX))
								END ,
	RegistrationDateTime	= SYSDATETIME () ,
	ReferringMemberId		= NULL
FROM
	sys.all_columns
CROSS JOIN
	@tblFirstNames AS FirstNames
CROSS JOIN
	@tblLastNames AS LastNames
CROSS JOIN
	(
		SELECT
			RandomValue = ABS (CHECKSUM (NEWID ())) % 3 + 1
	)
	AS
		RandomValueTable
ORDER BY
	NEWID () ASC;
GO


UPDATE
	Operation.Members
SET
	RegistrationDateTime	= DATEADD (SECOND , (19 * 365 * 24 * 60 * 60) + (ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , DATEADD (SECOND , 19 * 365 * 24 * 60 * 60 , CAST (BirthDate AS DATETIME2(0))) , SYSDATETIME ())) , CAST (BirthDate AS DATETIME2(0))) ,
	ReferringMemberId		=	CASE
									WHEN Id = 1
										THEN NULL
									WHEN ABS (CHECKSUM (NEWID ())) % 100 < 30
										THEN NULL
									ELSE
										ABS (CHECKSUM (NEWID ())) % (Id - 1) + 1
								END
GO


INSERT INTO
	Operation.MemberSessions
(
	MemberId ,
	LoginDateTime ,
	EndDateTime ,
	EndReasonId
)
SELECT TOP (1000000)
	MemberId		= Members.Id ,
	LoginDateTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , Members.RegistrationDateTime , SYSDATETIME ()) , Members.RegistrationDateTime) ,
	EndDateTime		= NULL ,
	EndReasonId		= NULL
FROM
	Operation.Members AS Members
CROSS JOIN
	sys.objects
ORDER BY
	NEWID () ASC;
GO


UPDATE
	Operation.MemberSessions
SET
	EndDateTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % (5 * 60 * 60) + 1 , LoginDateTime) ,
	EndReasonId	= ABS (CHECKSUM (NEWID ())) % 4 + 1
WHERE
	LoginDateTime < DATEADD (MINUTE , - (5 * 60) , SYSDATETIME ());
GO


INSERT INTO
	Operation.Invitations WITH (TABLOCK)
(
	RequestingSessionId ,
	ReceivingMemberId ,
	CreationDateTime ,
	StatusId ,
	ResponseDateTime
)
SELECT TOP (5000000)
	RequestingSessionId	= ABS (CHECKSUM (NEWID ())) % 1000000 + 1 ,
	ReceivingMemberId	= ABS (CHECKSUM (NEWID ())) % 100000 + 1 ,
	CreationDateTime	= DATEADD (SECOND , - ABS (CHECKSUM (NEWID ())) % (365 * 24 * 60 * 60) , SYSDATETIME ()) ,
	StatusId			= ABS (CHECKSUM (NEWID ())) % 3 + 1 ,
	ResponseDateTime	= NULL
FROM
	sys.all_columns AS T1
CROSS JOIN
	sys.all_columns AS T2;
GO


UPDATE
	Operation.Invitations
SET
	ResponseDateTime = DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , CreationDateTime , SYSDATETIME ()) , CreationDateTime)
WHERE
	StatusId != 1;	-- Sent
GO


INSERT INTO
	Operation.Invitations WITH (TABLOCK)
(
	RequestingSessionId ,
	ReceivingMemberId ,
	CreationDateTime ,
	StatusId ,
	ResponseDateTime
)
SELECT TOP (10)
	RequestingSessionId	= ABS (CHECKSUM (NEWID ())) % 1000000 + 1 ,
	ReceivingMemberId	= ABS (CHECKSUM (NEWID ())) % 100000 + 1 ,
	CreationDateTime	= DATEADD (SECOND , - ABS (CHECKSUM (NEWID ())) % (365 * 24 * 60 * 60) , SYSDATETIME ()) ,
	StatusId			= 4 ,
	ResponseDateTime	= NULL
FROM
	sys.all_columns;
GO


CREATE NONCLUSTERED INDEX
	ix_Invitations_nc_nu_StatusId
ON
	Operation.Invitations (StatusId ASC);
GO


INSERT INTO
	Billing.Payments WITH (TABLOCK)
(
	MemberId ,
	Amount ,
	DateAndTime
)
SELECT TOP (2000000)
	MemberId	= Members.Id ,
	Amount		= CAST ((ABS (CHECKSUM (NEWID ())) % 100000 / 100.0) AS DECIMAL(19,2)) ,
	DateAndTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , Members.RegistrationDateTime , SYSDATETIME ()) , Members.RegistrationDateTime)
FROM
	Operation.Members AS Members
CROSS JOIN
	sys.objects
ORDER BY
	NEWID () ASC;
GO


INSERT INTO
	Billing.Payments WITH (TABLOCK)
(
	MemberId ,
	Amount ,
	DateAndTime
)
SELECT TOP (100000)
	MemberId	= Members.Id ,
	Amount		= CAST ((ABS (CHECKSUM (NEWID ())) % 100000 / 100.0) AS DECIMAL(19,2)) ,
	DateAndTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , Members.RegistrationDateTime , SYSDATETIME ()) , Members.RegistrationDateTime)
FROM
	Operation.Members AS Members
CROSS JOIN
	sys.all_columns AS T1
CROSS JOIN
	sys.all_columns AS T2
WHERE
	Members.Id = 54321;
GO


INSERT INTO
	Billing.Transactions WITH (TABLOCK)
(
	AccountId ,
	TransactionDateTime ,
	Amount
)
SELECT TOP (1000000)
	AccountId			= ABS (CHECKSUM (NEWID ())) % 50000 + 1 ,
	TransactionDateTime	= DATEADD (DAY , - ABS (CHECKSUM (NEWID ())) % 3650 , SYSDATETIME ()) ,
	Amount				= CAST ((CHECKSUM (NEWID ()) % 100) AS MONEY)
FROM
	sys.all_columns AS T1
CROSS JOIN
	sys.all_columns AS T2;
GO


CREATE CLUSTERED INDEX
	ix_Transactions_AccountId#TransactionDateTime
ON
	Billing.Transactions
		(
			AccountId			ASC ,
			TransactionDateTime	ASC
		);
GO


INSERT INTO
	Operation.SessionEvents WITH (TABLOCK)
(
	MemberId ,
	SessionId ,
	EventTypeId ,
	DateAndTime ,
	URL
)
SELECT TOP (2000000)
	MemberId	= ABS (CHECKSUM (NEWID ())) % 100000 + 1 ,
	SessionId	= MemberSessions.Id ,
	EventTypeId	= ABS (CHECKSUM (NEWID ())) % 5 + 1 ,
	DateAndTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , MemberSessions.LoginDateTime , ISNULL (MemberSEssions.EndDateTime , SYSDATETIME ())) , MemberSessions.LoginDateTime) ,
	URL			= N'www.madeirasql.com/' + REPLICATE (N'x' , ABS (CHECKSUM (NEWID ())) % 10 + 1)
FROM
	Operation.MemberSessions AS MemberSessions
CROSS JOIN
	sys.tables AS T1;
GO


CREATE CLUSTERED INDEX
	ix_SessionEvents_c_nu_DateAndTime
ON
	Operation.SessionEvents (DateAndTime ASC);
GO


CREATE NONCLUSTERED INDEX
	ix_SessionEvents_nc_nu_SessionId
ON
	Operation.SessionEvents (SessionId ASC);
GO

-- Create stored procedures

CREATE PROCEDURE
	Sales.usp_GetOrdersByCustomerId
(
	@CustomerId AS INT
)
AS

DECLARE
	@CustomerAge AS TINYINT;

SELECT
	@CustomerAge = DATEDIFF (YEAR , BirthDate , SYSDATETIME ())
FROM
	Marketing.Customers
WHERE
	Id = @CustomerId;

IF
	@CustomerAge < 18
BEGIN

	RAISERROR (N'Customer is too young.' , 16 , 1);

	RETURN;

END;

SELECT
	Id ,
	DateAndTime ,
	OrderStatusId ,
	Comments
FROM
	Sales.Orders
WHERE
	CustomerId = @CustomerId
ORDER BY
	Id ASC;
GO


CREATE PROCEDURE
	Operation.usp_GetInvitationsByStatus
(
	@inStatusId AS TINYINT
)
AS

SELECT TOP (10)
	Id ,
	RequestingSessionId ,
	ReceivingMemberId ,
	CreationDateTime ,
	StatusId ,
	ResponseDateTime
FROM
	Operation.Invitations
WHERE
	StatusId = @inStatusId
ORDER BY
	CreationDateTime ASC;
GO
