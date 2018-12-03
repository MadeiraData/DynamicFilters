CREATE TABLE [Operation].[SessionEvents] (
    [Id]          INT             IDENTITY (1, 1) NOT NULL,
    [MemberId]    INT             NOT NULL,
    [SessionId]   INT             NOT NULL,
    [EventTypeId] TINYINT         NOT NULL,
    [DateAndTime] DATETIME2 (3)   NOT NULL,
    [URL]         NVARCHAR (1000) NOT NULL,
    CONSTRAINT [pk_SessionEvents_c_Id] PRIMARY KEY NONCLUSTERED ([Id] ASC),
    CONSTRAINT [fk_SessionEvents_EventTypeId_EventTypes_Id] FOREIGN KEY ([EventTypeId]) REFERENCES [Lists].[EventTypes] ([Id]),
    CONSTRAINT [fk_SessionEvents_MemberId_Members_Id] FOREIGN KEY ([MemberId]) REFERENCES [Operation].[Members] ([Id]),
    CONSTRAINT [fk_SessionEvents_SessionId_MemberSessions_Id] FOREIGN KEY ([SessionId]) REFERENCES [Operation].[MemberSessions] ([Id])
);


GO
CREATE CLUSTERED INDEX [ix_SessionEvents_c_nu_DateAndTime]
    ON [Operation].[SessionEvents]([DateAndTime] ASC);


GO
CREATE NONCLUSTERED INDEX [ix_SessionEvents_nc_nu_SessionId]
    ON [Operation].[SessionEvents]([SessionId] ASC);

