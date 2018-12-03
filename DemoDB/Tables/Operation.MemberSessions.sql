CREATE TABLE [Operation].[MemberSessions] (
    [Id]            INT           IDENTITY (1, 1) NOT NULL,
    [MemberId]      INT           NOT NULL,
    [LoginDateTime] DATETIME2 (0) NOT NULL,
    [EndDateTime]   DATETIME2 (0) NULL,
    [EndReasonId]   TINYINT       NULL,
    CONSTRAINT [pk_MemberSessions_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_MemberSessions_EndReasonId_SessionEndReasons_Id] FOREIGN KEY ([EndReasonId]) REFERENCES [Lists].[SessionEndReasons] ([Id]),
    CONSTRAINT [fk_MemberSessions_MemberId_Members_Id] FOREIGN KEY ([MemberId]) REFERENCES [Operation].[Members] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [ix_MemberSessions_nc_nu_LoginDateTime]
    ON [Operation].[MemberSessions]([LoginDateTime] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_MemberSessions_nc_nu_MemberId]
    ON [Operation].[MemberSessions]([MemberId] ASC);

