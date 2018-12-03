/*
	Fully Parameterized Search Query
	--------------------------------
	
	Copyright Eitan Blumin (c) 2018; email: eitan@madeiradata.com
	You may use the contents of this SQL script or parts of it, modified or otherwise
	for any purpose that you wish (including commercial).
	Under the single condition that you include in the script
	this comment block unchanged, and the URL to the original source, which is:
	http://www.eitanblumin.com/
*/


/*
---------------- Tables ----------------

FilterTables
---------------

A logical group of available filter columns. Each group will represent a single database view (possibly de-normalized).
*/

IF OBJECT_ID('FilterTables') IS NOT NULL AND OBJECTPROPERTY(OBJECT_ID('FilterTables'), 'IsTable') = 1
	DROP TABLE FilterTables;
GO
CREATE TABLE FilterTables
(
	FilterTableAlias SYSNAME NOT NULL PRIMARY KEY,
	FilterTableName SYSNAME NOT NULL
)

-- Sample data
INSERT INTO FilterTables
(FilterTableAlias,FilterTableName)
VALUES
 ('Members','Operation.Members')
,('Session Events','dbo.VW_SessionEvents')
,('Invitations','dbo.VW_Invitations')

GO
/*

FilterPredicates
-----------------

This table will contain the list of possible predicates and the template for each.
The templates use "placeholders" such as {Column} and {Parameter} which can later
be easily replaced with relevant values.
{Column}		= Placeholder for the column name to be filtered.
{Parameter}		= Placeholder for the local parameter that contains the filter data.

*/
IF OBJECT_ID('FilterPredicates') IS NOT NULL AND OBJECTPROPERTY(OBJECT_ID('FilterPredicates'), 'IsTable') = 1
	DROP TABLE FilterPredicates;
GO
CREATE TABLE FilterPredicates
(
	PredicateID INT PRIMARY KEY,
	IsMultiValue BIT NOT NULL,
	PredicateName VARCHAR(50) NOT NULL,
	PredicateTemplate VARCHAR(4000) NOT NULL
);
INSERT INTO FilterPredicates
VALUES
 (1, 0, 'Contains', '{Column} LIKE ''%'' + {Parameter} + ''%''')
,(2, 0, 'NotContains', '{Column} NOT LIKE ''%'' + {Parameter} + ''%''')
,(3, 0, 'StartsWith', '{Column} LIKE {Parameter} + ''%''')
,(4, 0, 'EndsWith', '{Column} LIKE ''%'' + {Parameter}')
,(5, 0, 'GreaterThan', '{Column} > {Parameter}')
,(6, 0, 'GreaterOrEqual', '{Column} >= {Parameter}')
,(7, 0, 'LessThan', '{Column} < {Parameter}')
,(8, 0, 'LessOrEqual', '{Column} <= {Parameter}')
,(9, 0, 'Equals', '{Column} = {Parameter}')
,(10, 0, 'NotEquals', '{Column} <> {Parameter}')
,(11, 1, 'In', '{Column} IN (SELECT Value FROM {Parameter})')
,(12, 1, 'NotIn', '{Column} NOT IN (SELECT Value FROM {Parameter})')

GO
/*

FilterColumns
----------------

This table will map column names from our target table to an ID and a data type.
Using this table, the GUI can identify columns that can be filtered,
and later the database back-end will use the same table for parsing.

The field QueryForAvailableValues accepts a database query that must return 3 columns:
 [value] - Will be used for returning the actual value to be used in the predicate template
 [label] - Will be used for displaying the label to the front-end user
 [group] - If not NULL, will be used for grouping the values into option groups

*/
IF OBJECT_ID('FilterColumns') IS NOT NULL AND OBJECTPROPERTY(OBJECT_ID('FilterColumns'), 'IsTable') = 1
	DROP TABLE FilterColumns;
GO
CREATE TABLE FilterColumns
(
	ColumnID INT NOT NULL IDENTITY(1,1) PRIMARY KEY,
	ColumnFilterTableAlias SYSNAME NOT NULL FOREIGN KEY REFERENCES FilterTables(FilterTableAlias) ON UPDATE CASCADE,
	ColumnRealName SYSNAME NOT NULL,
	ColumnSqlDataType VARCHAR(50) NOT NULL,
	ColumnDisplayName NVARCHAR(200) NULL,
	ColumnSortEnabled BIT NOT NULL,
	ColumnSupportedFilterPredicates VARCHAR(100) NULL,
	QueryForAvailableValues VARCHAR(4000) NULL
);

-- Sample data
INSERT INTO FilterColumns
(ColumnFilterTableAlias,ColumnRealName,ColumnSqlDataType,ColumnDisplayName,ColumnSortEnabled,ColumnSupportedFilterPredicates,QueryForAvailableValues)
VALUES
 ('Members', 'Id', 'int', 'Member Id', 1, NULL, NULL)
,('Members', 'Username', 'nvarchar(10)', 'User Name', 1, '1, 2, 3, 4, 9, 10', NULL)
,('Members', 'FirstName', 'nvarchar(20)', 'First Name', 1, '1, 2, 3, 4, 9, 10, 11, 12', NULL)
,('Members', 'LastName', 'nvarchar(20)', 'Last Name', 1, '1, 2, 3, 4, 9, 10, 11, 12', NULL)
,('Members', 'SampleID', 'int', 'Sample ID', 1, '9', NULL)
,('Members', 'CountryId', 'tinyint', 'Country', 1, '11', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Countries ORDER BY 2')
,('Members', 'GenderID', 'tinyint', 'Gender', 1, '11', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Genders ORDER BY 2')
,('Members', 'SexualPreferenceId', 'tinyint', 'Sexual Preference', 1, '11', 'SELECT Id AS [value], Name AS [label], NULL AS [group] FROM Lists.Genders ORDER BY 2')
,('Members', 'BirthDate', 'date', 'BirthDate', 1, '5, 6, 7, 8, 9, 10', NULL)
,('Members', 'RegistrationDateTime', 'datetime', 'Registration Date and Time', 1, '5, 6, 7, 8, 9, 10', NULL)

GO


/*
---------------- Stored Procedure ----------------
This is the stored procedure that will perform the parsing itself.
*/

IF OBJECT_ID('FilterParseJsonParameters') IS NOT NULL AND OBJECTPROPERTY(OBJECT_ID('FilterParseJsonParameters'), 'IsProcedure') = 1
	DROP PROCEDURE FilterParseJsonParameters;
GO
/*
	Fully Parameterized Search Query
	--------------------------------
	
	Copyright Eitan Blumin (c) 2018; email: eitan@madeiradata.com
	You may use the contents of this SQL script or parts of it, modified or otherwise
	for any purpose that you wish (including commercial).
	Under the single condition that you include in the script
	this comment block unchanged, and the URL to the original source, which is:
	http://www.eitanblumin.com/

--------------------------------
Example Usage:
--------------------------------
DECLARE @SQL NVARCHAR(MAX), @JsonParams NVARCHAR(MAX) = N'{ "Parameters": 
[
	{"columnId": "1", "operatorId": "11", "Value": [ "2" ]},
	{"columnId": "2", "operatorId": "11", "Value": [ "RTCMLIVEDB3", "TheOptionLiveDB" ] },
	{"columnId": "3", "operatorId": "6", "Value": "2018-11-11 15:00"}
]
}', @JsonOrdering NVARCHAR(MAX) = N'{ "OrderingColumns": 
[
	{"columnId": "11", "isAscending": "1"},
	{"columnId": "5", "isAscending": "1"}
] }'

EXEC dbo.FilterParseJsonParameters @SourceTableAlias = 'Members', @JsonParams = @JsonParams, @JsonOrdering = @JsonOrdering, @ParsedSQL = @SQL OUTPUT

PRINT @SQL

EXEC sp_executesql @SQL, N'@JsonParams NVARCHAR(MAX)', @JsonParams

*/
CREATE PROCEDURE FilterParseJsonParameters
	@SourceTableAlias	SYSNAME,				-- the alias of the table from FilterTables to be used as the source
	@JsonParams			NVARCHAR(MAX),			-- the JSON definition of the parameter values
	@JsonOrdering		NVARCHAR(MAX) = NULL,	-- the JSON definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) OUTPUT,	-- returns the parsed SQL command to be used for sp_executesql.
	@ForceRecompile		BIT = 1,				-- forces the query to do parameter sniffing using OPTION(RECOMPILE)
	@RowNumberColumn	SYSNAME = 'RowNumber'	-- you can optionally change the name of the RowNumber column used for pagination (to avoid collision with existing columns)
AS
SET NOCOUNT ON;
-- Init variables
DECLARE 
	@SourceTableName SYSNAME,
	@PageOrdering NVARCHAR(MAX),
	@FilterString NVARCHAR(MAX), 
	@FilterTablesString NVARCHAR(MAX), 
	@FilterParamInit NVARCHAR(4000)

SET @FilterString = N'';
SET @FilterTablesString = N'';

SELECT @SourceTableName = FilterTableName
FROM FilterTables
WHERE FilterTableAlias = @SourceTableAlias

IF @SourceTableName IS NULL
BEGIN
	RAISERROR(N'Table %s was not found in definitions',16,1,@SourceTableAlias);
	RETURN -1;
END

-- Prepare the ORDER BY clause (save in indexed temp table to ensure sort)
DECLARE @SortedColumns AS TABLE (ColumnRealName SYSNAME, IsAscending BIT, ColumnIndex BIGINT PRIMARY KEY);

INSERT INTO @SortedColumns
SELECT
	FilterColumns.ColumnRealName, Q.IsAscending, Q.ColumnIndex
FROM
(
	SELECT
		ColumnIndex			= [key],
		OrderingColumnID	= CONVERT(int, JSON_VALUE([value], '$.columnId')),
		IsAscending			= CONVERT(bit, JSON_VALUE([value], '$.isAscending'))
	FROM
		OPENJSON(@JsonOrdering, '$.OrderingColumns')
) AS Q
JOIN
	FilterColumns
ON
	Q.OrderingColumnID = FilterColumns.ColumnID
INNER JOIN
	FilterTables
ON
	FilterColumns.ColumnFilterTableAlias = FilterTables.FilterTableAlias
WHERE
	FilterColumns.ColumnSortEnabled = 1
AND FilterColumns.ColumnFilterTableAlias = @SourceTableAlias

SELECT
	@PageOrdering = ISNULL(@PageOrdering + N', ',N'') + ColumnRealName + N' ' + CASE WHEN IsAscending = 1 THEN 'ASC' ELSE 'DESC' END
FROM @SortedColumns

IF @PageOrdering IS NULL
	SET @PageOrdering = '(SELECT NULL)'

-- Parse filtering
SELECT
	@FilterParamInit = ISNULL(@FilterParamInit, '') + N'
DECLARE @p' + ParamIndex +

		-- If operand is multi-valued, declare local variable as a temporary table
		CASE WHEN FilterPredicates.IsMultiValue = 1 THEN
			N' TABLE ([Value] ' + FilterColumns.ColumnSqlDataType + N');
			INSERT INTO @p' + ParamIndex + N'
			SELECT CONVERT(' + FilterColumns.ColumnSqlDataType + N', b.[value])
			FROM OPENJSON(@JsonParams, ''$.Parameters'') AS a
			CROSS APPLY OPENJSON(a.[value], ''$.Value'') AS b WHERE a.[key] = ' + ParamIndex + N';
			'
		
		-- Otherwise, declare the local variable as a regular variable.
		ELSE
			N' ' + FilterColumns.ColumnSqlDataType + N';
			SELECT @p' + ParamIndex + N' = CONVERT(' + FilterColumns.ColumnSqlDataType + N', JSON_VALUE([value], ''$.Value'')) FROM OPENJSON(@JsonParams, ''$.Parameters'') WHERE [key] = ' + ParamIndex + N';
			'
		END
		,
	-- Parse the operand template by replacing the placeholders
	@FilterString = @FilterString + N'
	AND ' + REPLACE(
			REPLACE(
			FilterPredicates.PredicateTemplate
			, '{Column}',FilterColumns.ColumnRealName)
			, '{Parameter}', '@p' + ParamIndex)
FROM
	(
		-- This parses the XML into a relational structure
		SELECT
			ParamIndex			= CONVERT(nvarchar(max), [key]) COLLATE database_default,
			FilterColumnID		= CONVERT(int, JSON_VALUE([value], '$.columnId')),
			FilterPredicateID	= CONVERT(int, JSON_VALUE([value], '$.operatorId'))
		FROM
			OPENJSON(@JsonParams, '$.Parameters')
	) AS ParamValues
JOIN
	FilterColumns
ON
	ParamValues.FilterColumnID = FilterColumns.ColumnID
JOIN
	FilterPredicates
ON
	ParamValues.FilterPredicateID = FilterPredicates.PredicateID
INNER JOIN
	FilterTables
ON
	FilterColumns.ColumnFilterTableAlias = FilterTables.FilterTableAlias
WHERE
	FilterColumns.ColumnFilterTableAlias = @SourceTableAlias

-- Construct the final parsed SQL command
SET @ParsedSQL = ISNULL(@FilterParamInit, '') + N'
SELECT * FROM
(SELECT Main.*, ' + QUOTENAME(@RowNumberColumn) + N' = ROW_NUMBER() OVER( ORDER BY ' + @PageOrdering + N' )
FROM ' + @SourceTableName + N' AS Main
WHERE 1=1 ' + ISNULL(@FilterString,'') + N'
) AS Q
WHERE '+ QUOTENAME(@RowNumberColumn) + N' BETWEEN ' + CONVERT(nvarchar(50), @Offset) + N' AND ' + CONVERT(nvarchar(50), @Offset + @PageSize - 1) + N'
ORDER BY ' + QUOTENAME(@RowNumberColumn);

-- Optionally add RECOMPILE hint
IF @ForceRecompile = 1
	SET @ParsedSQL = @ParsedSQL + N'
OPTION (RECOMPILE)'
GO