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
DECLARE @SQL NVARCHAR(MAX), @JsonParams NVARCHAR(MAX) = N'[
	{"ColumnID": "1", "OperatorID": "11", "Value": [ "2" ]},
	{"ColumnID": "2", "OperatorID": "11", "Value": [ "DB1", "DB2" ] },
	{"ColumnID": "3", "OperatorID": "6",  "Value": [ "2018-11-11 15:00" ] }
]', @JsonOrdering NVARCHAR(MAX) = N'[
	{"ColumnId": "11", "Ascending": "1"},
	{"ColumnId": "5",  "Ascending": "1"}
]'

EXEC dbo.[FilterParseJsonParameters_Standalone] @SourceTableAlias = 'Members', @JsonParams = @JsonParams, @JsonOrdering = @JsonOrdering, @ParsedSQL = @SQL OUTPUT

PRINT @SQL

EXEC sp_executesql @SQL, N'@JsonParams NVARCHAR(MAX)', @JsonParams

*/
CREATE PROCEDURE [dbo].[FilterParseJsonParameters_Standalone]
	@SourceTableAlias	SYSNAME,				-- the alias of the table from FilterTables to be used as the source
	@JsonParams			NVARCHAR(MAX),			-- the JSON definition of the parameter values
	@JsonOrdering		NVARCHAR(MAX) = NULL,	-- the JSON definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the parsed SQL command to be used for sp_executesql.
	@ForceRecompile		BIT = 0,				-- forces the query to do parameter sniffing using OPTION(RECOMPILE)
	@RowNumberColumn	SYSNAME = 'RowNumber',	-- you can optionally change the name of the RowNumber column used for pagination (to avoid collision with existing columns)
	@RunCommand			BIT = 0					-- determines whether to run the parsed command (otherwise just output the command w/o running it)
AS BEGIN
SET XACT_ABORT ON;
SET ARITHABORT ON;
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

-- Prepare the ORDER BY clause (save in indexed temp table to ensure sort which might be distorted by the JOIN otherwise)
DECLARE @SortedColumns AS TABLE (ColumnRealName SYSNAME, IsAscending BIT, ColumnIndex BIGINT PRIMARY KEY);

INSERT INTO @SortedColumns
SELECT
	FilterColumns.ColumnRealName, Q.IsAscending, Q.ColumnIndex
FROM
(
	SELECT
		ColumnIndex			= [key],
		OrderingColumnID	= CONVERT(int, JSON_VALUE([value], '$.ColumnId')),
		IsAscending			= CONVERT(bit, JSON_VALUE([value], '$.Ascending'))
	FROM
		OPENJSON(@JsonOrdering, '$')
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

		-- If Operator is multi-valued, init local variable as a JSON array
		CASE WHEN FilterOperators.IsMultiValue = 1 THEN
			N' NVARCHAR(MAX);
			SELECT @p' + ParamIndex + N' = JSON_QUERY(P.[value], ''$.Value'')
			FROM OPENJSON(@JsonParams, ''$'') as P
			WHERE P.[key] = ' + ParamIndex + N';
			'
		
		-- If Operator is single-valued, declare the local variable as a regular variable, to ensure strong-typing.
		ELSE
			N' ' + FilterColumns.ColumnSqlDataType + N';
			SELECT @p' + ParamIndex + N' = CONVERT(' + FilterColumns.ColumnSqlDataType + N', V.[value])
			FROM OPENJSON(@JsonParams, ''$'') as P
			CROSS APPLY OPENJSON(JSON_QUERY(P.[value], ''$.Value''), ''$'') AS V
			WHERE P.[key] = ' + ParamIndex + N';
			'
		END
		,
	-- Parse the Operator template by replacing the placeholders
	@FilterString = @FilterString + N'
	AND ' + REPLACE(
			REPLACE(
			FilterOperators.OperatorTemplate
			, '{Column}',FilterColumns.ColumnRealName)
			, '{Parameter}', 

				-- If Operator is multi-valued, create strongly-typed subquery from JSON array parameter
				CASE WHEN FilterOperators.IsMultiValue = 1 THEN
					'(SELECT CONVERT(' + FilterColumns.ColumnSqlDataType + N', [value]) AS [Value] FROM OPENJSON(@p' + ParamIndex + N', ''$'') AS V) AS p'
		
				-- If Operator is single-valued, use already strongly-typed parameter
				ELSE
					'@p' + ParamIndex
				END
			)
FROM
	(
		SELECT DISTINCT
			ParamIndex			= CONVERT(nvarchar(max), P.[key]) COLLATE database_default,
			FilterColumnID		= CONVERT(int, JSON_VALUE(P.[value], '$.ColumnID')),
			FilterOperatorID	= CONVERT(int, JSON_VALUE(P.[value], '$.OperatorID'))
		FROM
			OPENJSON(@JsonParams, '$') AS P
	) AS ParamValues
JOIN
	FilterColumns
ON
	ParamValues.FilterColumnID = FilterColumns.ColumnID
JOIN
	FilterOperators
ON
	ParamValues.FilterOperatorID = FilterOperators.OperatorID
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

-- Optionally run the command
IF @RunCommand = 1
	EXEC sp_executesql @ParsedSQL, N'@JsonParams NVARCHAR(MAX)', @JsonParams
END