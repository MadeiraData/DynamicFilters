

CREATE PROCEDURE
	Operation.usp_GetInvitationsByStatus
(
	@inStatusId AS TINYINT
)
AS

SELECT TOP (10)
	Id ,
	RequestingSessionId ,
	ReceivingMemberId ,
	CreationDateTime ,
	StatusId ,
	ResponseDateTime
FROM
	Operation.Invitations
WHERE
	StatusId = @inStatusId
ORDER BY
	CreationDateTime ASC;
