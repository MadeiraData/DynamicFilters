CREATE TABLE [Billing].[Payments] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [MemberId]    NVARCHAR (20)   NOT NULL,
    [Amount]      DECIMAL (19, 2) NOT NULL,
    [DateAndTime] DATETIME2 (0)   NOT NULL,
    CONSTRAINT [pk_Payments_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

