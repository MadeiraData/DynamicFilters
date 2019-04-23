CREATE TABLE [Sales].[OrderProducts] (
    [Id]        INT   IDENTITY (1, 1) NOT NULL,
    [OrderId]   INT   NOT NULL,
    [ProductId] INT   NOT NULL,
    [Quantity]  INT   NOT NULL,
    [UnitPrice] MONEY NOT NULL,
    CONSTRAINT [pk_OrderProducts_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_OrderProducts_OrderId_Orders_Id] FOREIGN KEY ([OrderId]) REFERENCES [Sales].[Orders] ([Id]),
    CONSTRAINT [fk_OrderProducts_ProductId_Products_Id] FOREIGN KEY ([ProductId]) REFERENCES [Inventory].[Products] ([Id])
);

