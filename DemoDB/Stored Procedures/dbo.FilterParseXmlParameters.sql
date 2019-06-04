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
    <Parameter columnId="1" operatorId="1">
		<Value>John</Value>
	</Parameter>
	<Parameter columnId="2" operatorId="4">
        <Value>1</Value>
        <Value>2</Value>
        <Value>3</Value>
    </Parameter>
</Parameters>', @XmlOrdering XML = N'<OrderingColumns>
	<ColumnOrder columnId="1" isAscending="1" />
	<ColumnOrder columnId="3" isAscending="0" />
</OrderingColumns>'

EXEC dbo.FilterParseXmlParameters @SourceTableAlias = 'Members', @XmlParams = @XmlParams, @XmlOrdering = @XmlOrdering, @ParsedSQL = @SQL OUTPUT

PRINT @SQL

*/
CREATE PROCEDURE [dbo].[FilterParseXmlParameters]
	@SourceTableAlias	SYSNAME,	-- the alias of the table from FilterTables to be used as the source
	@XmlParams			XML = NULL,	-- the Xml definition of the parameter values
	@XmlOrdering		XML = NULL,	-- the Xml definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the parsed SQL command to be used for sp_executesql.
	@ForceRecompile		BIT = 0,				-- forces the query to do parameter sniffing using OPTION(RECOMPILE)
	@RowNumberColumn	SYSNAME = 'RowNumber',	-- you can optionally change the name of the RowNumber column used for pagination (to avoid collision with existing columns)
	@RunCommand			BIT = 0					-- determines whether to run the parsed command (otherwise just output the command w/o running it)
AS
SET XACT_ABORT ON;
SET ARITHABORT ON;
SET NOCOUNT ON;
-- Init variables
DECLARE @TVPParams dbo.UDT_FilterParameters, @TVPOrdering dbo.UDT_ColumnOrder

-- Parse the Xml into a relational structures

INSERT INTO @TVPOrdering
SELECT
	ColumnIndex			= CONVERT(nvarchar(50),X.value('for $i in . return count(../*[. << $i]) + 1','int')),
	OrderingColumnID	= X.value('(@columnId)[1]','int'),
	IsAscending			= X.value('(@isAscending)[1]','bit')
FROM
	@XmlOrdering.nodes('/OrderingColumns/ColumnOrder') AS T(X)

INSERT INTO @TVPParams
SELECT
	ParamIndex			= CONVERT(nvarchar(50),X.value('for $i in . return count(../*[. << $i]) + 1','int')),
	FilterColumnID		= X.value('(@columnId)[1]','int'),
	FilterOperatorID	= X.value('(@operatorId)[1]','int'),
	Val					= V.[value]
FROM
	@XmlParams.nodes('/Parameters/Parameter') AS T(X)
CROSS APPLY (SELECT XV.value('(text())[1]', 'nvarchar(max)') AS [Value] FROM X.nodes('./Value') AS TV(XV)) AS V

-- Run the actual procedure with table-valued-parameters
EXEC dbo.FilterParseTVPParameters @SourceTableAlias, @TVPParams, @TVPOrdering, @PageSize, @Offset, @ParsedSQL OUTPUT, @ForceRecompile, @RowNumberColumn, @RunCommand