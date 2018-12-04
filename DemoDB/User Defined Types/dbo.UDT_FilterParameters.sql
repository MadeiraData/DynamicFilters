CREATE TYPE [dbo].[UDT_FilterParameters] AS TABLE (
    [ParamIndex] INT            NOT NULL,
    [ColumnID]   INT            NOT NULL,
    [OperandID]  INT            NOT NULL,
    [Value]      NVARCHAR (MAX) NOT NULL);

