CREATE TABLE [Operation].[Members] (
    [Id]                   INT             IDENTITY (1, 1) NOT NULL,
    [Username]             NVARCHAR (10)   NOT NULL,
    [Password]             NVARCHAR (10)   NOT NULL,
    [FirstName]            NVARCHAR (20)   NOT NULL,
    [LastName]             NVARCHAR (20)   NOT NULL,
    [StreetAddress]        NVARCHAR (100)  NULL,
    [CountryId]            TINYINT         NOT NULL,
    [PhoneNumber]          NVARCHAR (20)   NULL,
    [EmailAddress]         NVARCHAR (100)  NOT NULL,
    [GenderId]             TINYINT         NOT NULL,
    [BirthDate]            DATE            NOT NULL,
    [SexualPreferenceId]   TINYINT         NULL,
    [MaritalStatusId]      TINYINT         NULL,
    [Picture]              VARBINARY (MAX) NULL,
    [RegistrationDateTime] DATETIME2 (0)   NOT NULL,
    CONSTRAINT [pk_Members_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_Members_CountryId_Countries_Id] FOREIGN KEY ([CountryId]) REFERENCES [Lists].[Countries] ([Id]),
    CONSTRAINT [fk_Members_GenderId_Genders_Id] FOREIGN KEY ([GenderId]) REFERENCES [Lists].[Genders] ([Id]),
    CONSTRAINT [fk_Members_MaritalStatusId_MaritalStatuses_Id] FOREIGN KEY ([MaritalStatusId]) REFERENCES [Lists].[MaritalStatuses] ([Id]),
    CONSTRAINT [fk_Members_SexualPreferenceId_Genders_Id] FOREIGN KEY ([SexualPreferenceId]) REFERENCES [Lists].[Genders] ([Id])
);

