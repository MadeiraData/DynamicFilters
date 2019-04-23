CREATE TABLE [Lists].[OrderStatuses] (
    [Id]   TINYINT       NOT NULL,
    [Name] NVARCHAR (50) NOT NULL,
    CONSTRAINT [pk_OrderStatuses_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);

