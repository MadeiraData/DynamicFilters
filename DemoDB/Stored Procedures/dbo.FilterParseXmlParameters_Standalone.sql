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
DECLARE @SQL NVARCHAR(MAX), @XmlParams XML = N'<Parameters>
    <Parameter columnId="3" operatorId="3">
		<Value>Ron</Value>
	</Parameter>
	<Parameter columnId="5" operatorId="11">
        <Value>1</Value>
        <Value>2</Value>
        <Value>3</Value>
    </Parameter>
</Parameters>', @XmlOrdering XML = N'<OrderingColumns>
	<ColumnOrder columnId="1" isAscending="1" />
	<ColumnOrder columnId="3" isAscending="0" />
</OrderingColumns>'

EXEC dbo.FilterParseXmlParameters_Standalone @SourceTableAlias = 'Members', @XmlParams = @XmlParams, @XmlOrdering = @XmlOrdering, @ParsedSQL = @SQL OUTPUT

PRINT @SQL

EXEC sp_executesql @SQL, N'@XmlParams xml', @XmlParams

*/
CREATE PROCEDURE [dbo].[FilterParseXmlParameters_Standalone]
	@SourceTableAlias	SYSNAME,	-- the alias of the table from FilterTables to be used as the source
	@XmlParams			XML = NULL,	-- the Xml definition of the parameter values
	@XmlOrdering		XML = NULL,	-- the Xml definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the parsed SQL command to be used for sp_executesql.
	@ForceRecompile		BIT = 1,				-- forces the query to do parameter sniffing using OPTION(RECOMPILE)
	@RowNumberColumn	SYSNAME = 'RowNumber',	-- you can optionally change the name of the RowNumber column used for pagination (to avoid collision with existing columns)
	@RunCommand			BIT = 1					-- determines whether to run the parsed command (otherwise just output the command w/o running it)
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
		ColumnIndex			= CONVERT(nvarchar(50),X.value('for $i in . return count(../*[. << $i]) + 1','int')),
		OrderingColumnID	= X.value('(@columnId)[1]','int'),
		IsAscending			= X.value('(@isAscending)[1]','bit')
	FROM
		@XmlOrdering.nodes('/OrderingColumns/ColumnOrder') AS T(X)
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

		-- If Operator is multi-valued, init local variable as a table
		CASE WHEN FilterOperators.IsMultiValue = 1 THEN
			N' AS Table ([value] ' + FilterColumns.ColumnSqlDataType + N');
			INSERT INTO @p' + ParamIndex + N'
			SELECT V.[value]
			FROM @XmlParams.nodes(''(/Parameters/Parameter)[' + ParamIndex + N']'') AS T(X)
			CROSS APPLY (SELECT XV.value(''(text())[1]'', ''' + FilterColumns.ColumnSqlDataType + N''') AS [value] FROM X.nodes(''./Value'') AS TV(XV)) AS V;
			'
		
		-- If Operator is single-valued, declare the local variable as a regular variable, to ensure strong-typing.
		ELSE
			N' ' + FilterColumns.ColumnSqlDataType + N';
			SELECT @p' + ParamIndex + N' = X.value(''(Value/text())[1]'', ''' + FilterColumns.ColumnSqlDataType + N''')
			FROM @XmlParams.nodes(''(/Parameters/Parameter)[' + ParamIndex + N']'') AS T(X);
			'
		END
		,
	-- Parse the Operator template by replacing the placeholders
	@FilterString = @FilterString + N'
	AND ' + REPLACE(
			REPLACE(
			FilterOperators.OperatorTemplate
			, '{Column}',FilterColumns.ColumnRealName)
			, '{Parameter}', '@p' + ParamIndex
			)
FROM
	(
	SELECT
		ParamIndex			= CONVERT(nvarchar(50),X.value('for $i in . return count(../*[. << $i]) + 1','int')),
		FilterColumnID		= X.value('(@columnId)[1]','int'),
		FilterOperatorID	= X.value('(@operatorId)[1]','int')
	FROM
		@XmlParams.nodes('/Parameters/Parameter') AS T(X)
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
	EXEC sp_executesql @ParsedSQL, N'@XmlParams xml', @XmlParams
END