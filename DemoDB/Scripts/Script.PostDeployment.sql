/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/

-- Populate Sample data for Dynamic Filters

INSERT INTO dbo.FilterTables
(FilterTableAlias,FilterTableName)
SELECT
 'Members','dbo.VW_Members'
WHERE NOT EXISTS (SELECT NULL FROM dbo.FilterTables)

RAISERROR(N'Populated FilterTables with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;

INSERT INTO dbo.FilterOperators
SELECT *
FROM (
VALUES
 (1, 0, 'Contains', '{Column} LIKE ''%'' + {Parameter} + ''%''')
,(2, 0, 'Not Contains', '{Column} NOT LIKE ''%'' + {Parameter} + ''%''')
,(3, 0, 'Starts With', '{Column} LIKE {Parameter} + ''%''')
,(4, 0, 'Ends With', '{Column} LIKE ''%'' + {Parameter}')
,(5, 0, 'Greater Than', '{Column} > {Parameter}')
,(6, 0, 'Greater Than or Equal', '{Column} >= {Parameter}')
,(7, 0, 'Less Than', '{Column} < {Parameter}')
,(8, 0, 'Less Than or Equal', '{Column} <= {Parameter}')
,(9, 0, 'Equals', '{Column} = {Parameter}')
,(10, 0, 'Not Equals', '{Column} <> {Parameter}')
,(11, 1, 'In', '{Column} IN (SELECT Value FROM {Parameter})')
,(12, 1, 'Not In', '{Column} NOT IN (SELECT Value FROM {Parameter})')
) AS v(OperatorID, IsMultiValue, OperatorName, OperatorTemplate)
WHERE NOT EXISTS (SELECT NULL FROM dbo.FilterOperators)

RAISERROR(N'Populated FilterOperators with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;

INSERT INTO dbo.FilterColumns
(ColumnFilterTableAlias,ColumnRealName,ColumnSqlDataType,ColumnDisplayName,ColumnSortEnabled,ColumnSupportedFilterOperators,QueryForAvailableValues)
SELECT *
FROM (
VALUES
 ('Members', 'Id', 'int', 'Member Id', 1, NULL, NULL)
,('Members', 'Username', 'nvarchar(10)', 'User Name', 1, '1, 2, 3, 4, 9, 10', NULL)
,('Members', 'FirstName', 'nvarchar(20)', 'First Name', 1, '1, 2, 3, 4, 9, 10', NULL)
,('Members', 'LastName', 'nvarchar(20)', 'Last Name', 1, '1, 2, 3, 4, 9, 10', NULL)
,('Members', 'CountryId', 'tinyint', 'Country', 1, '9,10,11,12', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Countries ORDER BY 2')
,('Members', 'GenderID', 'tinyint', 'Gender', 1, '9,10,11', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Genders ORDER BY 2')
,('Members', 'SexualPreferenceId', 'tinyint', 'Sexual Preference', 1, '9,10,11', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Genders ORDER BY 2')
,('Members', 'BirthDate', 'date', 'BirthDate', 1, '5, 6, 7, 8, 9, 10', NULL)
,('Members', 'RegistrationDateTime', 'datetime', 'Registration Date and Time', 1, '5, 6, 7, 8, 9, 10', NULL)
) AS v(ColumnFilterTableAlias,ColumnRealName,ColumnSqlDataType,ColumnDisplayName,ColumnSortEnabled,ColumnSupportedFilterOperators,QueryForAvailableValues)
WHERE NOT EXISTS (SELECT NULL FROM dbo.FilterColumns)

RAISERROR(N'Populated FilterColumns with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;
GO

-- Populate other tables with sample data

IF NOT EXISTS (SELECT NULL FROM Lists.ProductStatuses)
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

IF NOT EXISTS (SELECT NULL FROM Lists.OrderStatuses)
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

IF NOT EXISTS (SELECT NULL FROM Lists.Countries)
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

IF NOT EXISTS (SELECT NULL FROM Lists.Genders)
INSERT INTO
	Lists.Genders
(
	Id ,
	Name
)
VALUES
	( 1	, N'Male'	) ,
	( 2	, N'Female'	);

IF NOT EXISTS (SELECT NULL FROM Lists.MaritalStatuses)
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


IF NOT EXISTS (SELECT NULL FROM Lists.SessionEndReasons)
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


IF NOT EXISTS (SELECT NULL FROM Lists.InvitationStatuses)
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


IF NOT EXISTS (SELECT NULL FROM Lists.EventTypes)
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


	
IF NOT EXISTS (SELECT NULL FROM Marketing.Customers)
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

IF NOT EXISTS (SELECT NULL FROM Inventory.Products)
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

IF NOT EXISTS (SELECT NULL FROM Sales.Orders)
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

IF NOT EXISTS (SELECT NULL FROM Sales.OrderProducts)
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

IF NOT EXISTS (SELECT NULL FROM Operation.Members)
BEGIN

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
END
GO


IF NOT EXISTS (SELECT NULL FROM Operation.MemberSessions)
BEGIN
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

UPDATE
	Operation.MemberSessions
SET
	EndDateTime	= DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % (5 * 60 * 60) + 1 , LoginDateTime) ,
	EndReasonId	= ABS (CHECKSUM (NEWID ())) % 4 + 1
WHERE
	LoginDateTime < DATEADD (MINUTE , - (5 * 60) , SYSDATETIME ());
END
GO


IF NOT EXISTS (SELECT NULL FROM Operation.Invitations)
BEGIN
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

UPDATE
	Operation.Invitations
SET
	ResponseDateTime = DATEADD (SECOND , ABS (CHECKSUM (NEWID ())) % DATEDIFF (SECOND , CreationDateTime , SYSDATETIME ()) , CreationDateTime)
WHERE
	StatusId != 1;	-- Sent


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
END
GO


IF NOT EXISTS (SELECT NULL FROM Billing.Payments)
BEGIN
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
END
GO


IF NOT EXISTS (SELECT NULL FROM Billing.Transactions)
BEGIN
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
END
GO

IF NOT EXISTS (SELECT NULL FROM Operation.SessionEvents)
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
	URL			= N'www.madeiradata.com/' + REPLICATE (N'x' , ABS (CHECKSUM (NEWID ())) % 10 + 1)
FROM
	Operation.MemberSessions AS MemberSessions
CROSS JOIN
	sys.tables AS T1;

GO
