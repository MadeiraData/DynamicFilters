CREATE TABLE [dbo].[FilterColumns] (
    [ColumnID]                        INT            IDENTITY (1, 1) NOT NULL,
    [ColumnFilterTableAlias]          [sysname]      NOT NULL,
    [ColumnRealName]                  [sysname]      NOT NULL,
    [ColumnSqlDataType]               VARCHAR (50)   NOT NULL,
    [ColumnDisplayName]               NVARCHAR (200) NULL,
    [ColumnSortEnabled]               BIT            NOT NULL,
    [ColumnSupportedFilterOperators] VARCHAR (100)  NULL,
    [QueryForAvailableValues]         VARCHAR (4000) NULL,
    PRIMARY KEY CLUSTERED ([ColumnID] ASC),
    FOREIGN KEY ([ColumnFilterTableAlias]) REFERENCES [dbo].[FilterTables] ([FilterTableAlias]) ON UPDATE CASCADE
);

