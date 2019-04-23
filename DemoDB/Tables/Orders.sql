CREATE TABLE [Sales].[Orders] (
    [Id]            INT             IDENTITY (1, 1) NOT NULL,
    [CustomerId]    INT             NOT NULL,
    [DateAndTime]   DATETIME2 (0)   NOT NULL,
    [OrderStatusId] TINYINT         NOT NULL,
    [Comments]      NVARCHAR (1000) NULL,
    CONSTRAINT [pk_Orders_nc_Id] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [fk_Orders_CustomerId_Customers_Id] FOREIGN KEY ([CustomerId]) REFERENCES [Marketing].[Customers] ([Id]),
    CONSTRAINT [fk_Orders_OrderStatusId_OrderStatuses_Id] FOREIGN KEY ([OrderStatusId]) REFERENCES [Lists].[OrderStatuses] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [ix_Orders_nc_nu_CustomerId]
    ON [Sales].[Orders]([CustomerId] ASC);

