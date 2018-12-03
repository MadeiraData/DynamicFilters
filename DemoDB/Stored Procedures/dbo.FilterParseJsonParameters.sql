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