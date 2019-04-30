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

EXEC dbo.FilterParseJsonParameters @SourceTableAlias = 'Members', @JsonParams = @JsonParams, @JsonOrdering = @JsonOrdering, @ParsedSQL = @SQL OUTPUT

PRINT @SQL

*/
CREATE PROCEDURE [dbo].[FilterParseJsonParameters]
	@SourceTableAlias	SYSNAME,				-- the alias of the table from FilterTables to be used as the source
	@JsonParams			NVARCHAR(MAX),			-- the JSON definition of the parameter values
	@JsonOrdering		NVARCHAR(MAX) = NULL,	-- the JSON definition of the column ordering (optional)
	@PageSize			INT = 9999,
	@Offset				INT = 1,
	@ParsedSQL			NVARCHAR(MAX) = NULL OUTPUT,	-- returns the parsed SQL command to be used for sp_executesql.
	@ForceRecompile		BIT = 1,				-- forces the query to do parameter sniffing using OPTION(RECOMPILE)
	@RowNumberColumn	SYSNAME = 'RowNumber',	-- you can optionally change the name of the RowNumber column used for pagination (to avoid collision with existing columns)
	@RunCommand			BIT = 1					-- determines whether to run the parsed command (otherwise just output the command w/o running it)
AS
SET XACT_ABORT ON;
SET ARITHABORT ON;
SET NOCOUNT ON;
-- Init variables
DECLARE @TVPParams dbo.UDT_FilterParameters, @TVPOrdering dbo.UDT_ColumnOrder

-- Parse the JSON into a relational structures

INSERT INTO @TVPOrdering
SELECT
	ColumnIndex			= [key],
	OrderingColumnID	= CONVERT(int, JSON_VALUE([value], '$.ColumnId')),
	IsAscending			= CONVERT(bit, JSON_VALUE([value], '$.Ascending'))
FROM
	OPENJSON(@JsonOrdering, '$')

INSERT INTO @TVPParams
SELECT
	ParamIndex			= P.[key],
	FilterColumnID		= CONVERT(int, JSON_VALUE(P.[value], '$.ColumnID')),
	FilterOperatorID	= CONVERT(int, JSON_VALUE(P.[value], '$.OperatorID')),
	Val					= V.[value]
FROM
	OPENJSON(@JsonParams, '$') as P
CROSS APPLY OPENJSON(JSON_QUERY(P.[value], '$.Value'), '$') AS V

-- Run the actual procedure with table-valued-parameters
EXEC dbo.FilterParseTVPParameters @SourceTableAlias, @TVPParams, @TVPOrdering, @PageSize, @Offset, @ParsedSQL OUTPUT, @ForceRecompile, @RowNumberColumn, @RunCommand