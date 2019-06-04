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
    <Parameter columnId="1" operatorId="11">
		<Value>1</Value>
		<Value>2</Value>
		<Value>3</Value>
	</Parameter>
	<Parameter columnId="3" operatorId="6">
        <Value>2018-11-11 15:00</Value>
    </Parameter>
</Parameters>', @XmlOrdering XML = N'<OrderingColumns>
	<ColumnOrder columnId="1" isAscending="1" />
	<ColumnOrder columnId="5" isAscending="0" />
</OrderingColumns>'

DECLARE 
	@CMD		NVARCHAR(MAX),
	@CMDParams	NVARCHAR(MAX)

EXEC dbo.[FilterParseXmlParameters_with_Encapsulation] @SourceTableAlias = 'Members', @XmlParams = @XmlParams, @XmlOrdering = @XmlOrdering
		, @ParsedSQL = @SQL OUTPUT, @CMD = @CMD OUTPUT, @CMDParams = @CMDParams OUTPUT

PRINT @SQL
PRINT '------------------------------------'
PRINT @CMD
PRINT '------------------------------------'
PRINT @CMDParams

SELECT @SQL, @CMD, @CMDParams

EXEC sp_executesql @SQL
, N'@XmlParams NVARCHAR(MAX), @CMD NVARCHAR(MAX), @CMDParams NVARCHAR(MAX)'
, @XmlParams, @CMD, @CMDParams

*/
CREATE PROCEDURE [dbo].[FilterParseXmlParameters_with_Encapsulation]
	@SourceTableAlias	SYSNAME,				-- the alias of the table from FilterTables to be used as the source
	@XmlParams			XML,			-- the XML definition of the parameter values
	@XmlOrdering		XML = NULL,		-- the XML definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the parsed SQL command to be used for outer sp_executesql.
	@CMD				NVARCHAR(MAX) = NULL OUTPUT,	-- returns the inner SQL command to be delivered for inner sp_executesql
	@CMDParams			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the inner SQL command parameters to be delivered for inner sp_executesql
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
	@FilterParamInit NVARCHAR(MAX),
	@CMDParamsSet NVARCHAR(MAX)

SET @FilterString = N'';
SET @FilterTablesString = N'';
SET @CMD = NULL
SET @CMDParams = NULL

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
	  @CMDParams = ISNULL(@CMDParams + N', ', N'') + N'@p' + ParamIndex + ' ' + 

		-- If Operator is multi-valued, use weak-typing
		CASE WHEN FilterOperators.IsMultiValue = 1 THEN N'xml'
		
		-- If Operator is single-valued, use strong-typing.
		ELSE FilterColumns.ColumnSqlDataType
		END
	, @CMDParamsSet = ISNULL(@CMDParamsSet + N', ', N'') + N'@p' + ParamIndex
	, @FilterParamInit = ISNULL(@FilterParamInit, N'') + N'
DECLARE @p' + ParamIndex +

		-- If Operator is multi-valued, init local variable as an XML document
		CASE WHEN FilterOperators.IsMultiValue = 1 THEN
			N' AS XML;
			SELECT @p' + ParamIndex + N' = X.query(''.'') FROM @XmlParams.nodes(''(/Parameters/Parameter)[' + ParamIndex + N']'') AS T(X);'
		
		-- If Operator is single-valued, declare the local variable as a regular variable, to ensure strong-typing.
		ELSE
			N' ' + FilterColumns.ColumnSqlDataType + N';
			SELECT @p' + ParamIndex + N' = X.value(''(Value/text())[1]'', ''' + FilterColumns.ColumnSqlDataType + N''') FROM @XmlParams.nodes(''(/Parameters/Parameter)[' + ParamIndex + N']'') AS T(X);'
		END
		,
	-- Parse the Operator template by replacing the placeholders
	@FilterString = @FilterString + N'
	AND ' + REPLACE(
			REPLACE(
			FilterOperators.OperatorTemplate
			, '{Column}',FilterColumns.ColumnRealName)
			, '{Parameter}',

			-- If Operator is multi-valued, create strongly-typed subquery from XML parameter
			CASE WHEN FilterOperators.IsMultiValue = 1 THEN
				'(SELECT X.value(''(text())[1]'', ''' + FilterColumns.ColumnSqlDataType + N''') FROM @p' + ParamIndex + N'.nodes(''Parameter/Value'') AS T(X)) AS p'
		
			-- If Operator is single-valued, use already strongly-typed parameter
			ELSE
				'@p' + ParamIndex
			END
			)
FROM
	(
		SELECT DISTINCT
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

-- Construct SQL query
SET @CMD = N'SELECT * FROM
(SELECT Main.*, ' + QUOTENAME(@RowNumberColumn) + N' = ROW_NUMBER() OVER( ORDER BY ' + @PageOrdering + N' )
FROM ' + @SourceTableName + N' AS Main
WHERE 1=1 ' + ISNULL(@FilterString,'') + N'
) AS Q
WHERE '+ QUOTENAME(@RowNumberColumn) + N' BETWEEN ' + CONVERT(nvarchar(50), @Offset) + N' AND ' + CONVERT(nvarchar(50), @Offset + @PageSize - 1) + N'
ORDER BY ' + QUOTENAME(@RowNumberColumn);

-- Optionally add RECOMPILE hint
IF @ForceRecompile = 1
	SET @CMD = @CMD + N'
OPTION (RECOMPILE)'

-- Construct the final parsed SQL command
SET @ParsedSQL = ISNULL(@FilterParamInit, '') + N'
EXEC sp_executesql @CMD, @CMDParams' + ISNULL(N', ' + @CMDParamsSet, N'')


-- Optionally run the command
IF @RunCommand = 1
	EXEC sp_executesql @ParsedSQL, N'@XmlParams NVARCHAR(MAX), @CMD NVARCHAR(MAX), @CMDParams NVARCHAR(MAX)', @XmlParams, @CMD, @CMDParams
END