CREATE TABLE [dbo].[FilterOperators] (
    [OperatorID]       INT            NOT NULL,
    [IsMultiValue]      BIT            NOT NULL,
    [OperatorName]     VARCHAR (50)   NOT NULL,
    [OperatorTemplate] VARCHAR (4000) NOT NULL,
    PRIMARY KEY CLUSTERED ([OperatorID] ASC)
);

