CREATE TYPE [dbo].[UDT_ColumnOrder] AS TABLE (
    [ColumnOrdinal] INT NOT NULL,
    [ColumnID]      INT NOT NULL,
    [IsAscending]   BIT NOT NULL);

