CREATE TABLE [Billing].[Transactions] (
    [TransactionId]       INT           IDENTITY (1, 1) NOT NULL,
    [AccountId]           INT           NOT NULL,
    [TransactionDateTime] DATETIME2 (0) NOT NULL,
    [Amount]              MONEY         NOT NULL,
    CONSTRAINT [pk_Transactions_nc_TransactionId] PRIMARY KEY NONCLUSTERED ([TransactionId] ASC)
);


GO
CREATE CLUSTERED INDEX [ix_Transactions_AccountId#TransactionDateTime]
    ON [Billing].[Transactions]([AccountId] ASC, [TransactionDateTime] ASC);

