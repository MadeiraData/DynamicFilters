CREATE TABLE [Marketing].[Customers] (
    [Id]               INT             IDENTITY (1, 1) NOT NULL,
    [Name]             NVARCHAR (50)   NOT NULL,
    [Phone]            NVARCHAR (20)   NULL,
    [BirthDate]        DATE            NULL,
    [SourceURL]        NVARCHAR (1000) NULL,
    [Country]          NCHAR (2)       NOT NULL,
    [LastPurchaseDate] DATE            NULL,
    CONSTRAINT [pk_Customers_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC)
);


GO
CREATE NONCLUSTERED INDEX [ix_Customers_nc_nu_Country]
    ON [Marketing].[Customers]([Country] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_Customers_nc_nu_SourceURL]
    ON [Marketing].[Customers]([SourceURL] ASC);

