CREATE TABLE [Operation].[Invitations] (
    [Id]                  INT           IDENTITY (1, 1) NOT NULL,
    [RequestingSessionId] INT           NOT NULL,
    [ReceivingMemberId]   INT           NOT NULL,
    [CreationDateTime]    DATETIME2 (0) NOT NULL,
    [StatusId]            TINYINT       NOT NULL,
    [ResponseDateTime]    DATETIME2 (0) NULL,
    CONSTRAINT [pk_Invitations_c_Id] PRIMARY KEY CLUSTERED ([Id] ASC),
    CONSTRAINT [fk_Invitations_ReceivingMemberId_Members_Id] FOREIGN KEY ([ReceivingMemberId]) REFERENCES [Operation].[Members] ([Id]),
    CONSTRAINT [fk_Invitations_RequestingSessionId_MemberSessions_Id] FOREIGN KEY ([RequestingSessionId]) REFERENCES [Operation].[MemberSessions] ([Id]),
    CONSTRAINT [fk_Invitations_StatusId_InvitationStatuses_Id] FOREIGN KEY ([StatusId]) REFERENCES [Lists].[InvitationStatuses] ([Id])
);


GO
CREATE NONCLUSTERED INDEX [ix_Invitations_nc_nu_StatusId]
    ON [Operation].[Invitations]([StatusId] ASC);

