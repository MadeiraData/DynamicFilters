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

-- Populate Sample data

INSERT INTO FilterTables
(FilterTableAlias,FilterTableName)
SELECT
 'Members','Operation.Members'
WHERE NOT EXISTS (SELECT NULL FROM FilterTables)

RAISERROR(N'Populated FilterTables with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;

INSERT INTO FilterOperators
SELECT *
FROM (
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
) AS v(OperatorID, IsMultiValue, OperatorName, OperatorTemplate)
WHERE NOT EXISTS (SELECT NULL FROM FilterOperators)

RAISERROR(N'Populated FilterOperators with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;

INSERT INTO FilterColumns
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
WHERE NOT EXISTS (SELECT NULL FROM FilterColumns)

RAISERROR(N'Populated FilterColumns with %d rows',0,1,@@ROWCOUNT) WITH NOWAIT;