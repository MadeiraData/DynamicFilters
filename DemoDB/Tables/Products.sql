CREATE TABLE [Inventory].[Products] (
    [Id]              INT           IDENTITY (1, 1) NOT NULL,
    [Name]            NVARCHAR (50) NOT NULL,
    [ListPrice]       MONEY         NOT NULL,
    [ProductStatusId] TINYINT       NOT NULL,
    CONSTRAINT [pk_Products_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_Products_ProductStatusId_ProductStatuses_Id] FOREIGN KEY ([ProductStatusId]) REFERENCES [Lists].[ProductStatuses] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [ix_Products_nc_nu_ProductStatusId]
    ON [Inventory].[Products]([ProductStatusId] ASC, [ListPrice] DESC);

