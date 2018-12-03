

-- Create stored procedures

CREATE PROCEDURE
	Operation.usp_SendFakeInvitations
AS

DECLARE
	@tblEligibleMembers
TABLE
(
	MemberId		INT				NOT NULL ,
	BillingAmount	DECIMAL(19,2)	NOT NULL
);

DECLARE
	@tblPotentialCouples
TABLE
(
	RequestingMemberId	INT	NOT NULL ,
	ReceivingMemberId	INT	NOT NULL
);


-- Query 1

INSERT INTO
	@tblEligibleMembers
(
	MemberId ,
	BillingAmount
)
SELECT
	MemberId		= MemberId ,
	BillingAmount	= SUM (Amount)
FROM
	Billing.Payments
GROUP BY
	MemberId;


-- Query 2

DELETE FROM
	@tblEligibleMembers
WHERE
	BillingAmount < 6000.00;


-- Query 3

INSERT INTO
	@tblPotentialCouples
(
	RequestingMemberId ,
	ReceivingMemberId
)
SELECT
	RequestingMemberId	= RequestingMembers.Id ,
	ReceivingMemberId	= ReceivingMembers.Id
FROM
	(
		SELECT TOP (200)
			Id ,
			CountryId ,
			BirthDate ,
			SexualPreferenceId
		FROM
			Operation.Members
		ORDER BY
			NEWID () ASC
	)
	AS
		RequestingMembers
CROSS JOIN
	(
		SELECT TOP (200)
			Id ,
			CountryId ,
			GenderId ,
			BirthDate
		FROM
			Operation.Members
		WHERE
			MaritalStatusId != 2
		OR
			MaritalStatusId IS NULL
		ORDER BY
			NEWID () ASC
	)
	AS
		ReceivingMembers
WHERE
	RequestingMembers.CountryId = ReceivingMembers.CountryId
AND
	(RequestingMembers.SexualPreferenceId = ReceivingMembers.GenderId OR RequestingMembers.SexualPreferenceId IS NULL)
AND
	ABS (DATEDIFF (YEAR , RequestingMembers.BirthDate , ReceivingMembers.BirthDate)) <= 5
AND
	RequestingMembers.Id != ReceivingMembers.Id;


-- Query 4

DELETE FROM
	@tblPotentialCouples
WHERE
	RequestingMemberId NOT IN
		(
			SELECT
				MemberId
			FROM
				@tblEligibleMembers
		);


-- Query 5

INSERT INTO
	Operation.Invitations
(
	RequestingSessionId ,
	ReceivingMemberId ,
	CreationDateTime ,
	StatusId ,
	ResponseDateTime
)
SELECT
	RequestingSessionId	= RequestingSessions.Id ,
	ReceivingMemberId	= PotentialCouples.ReceivingMemberId ,
	CreationDateTime	= DATEADD (SECOND , 5 , RequestingSessions.LoginDateTime) ,
	StatusId			= 1 ,	-- Sent
	ResponseDateTime	= NULL
FROM
	@tblPotentialCouples AS PotentialCouples
CROSS APPLY
	(
		SELECT TOP (1)
			MemberSessions.Id ,
			MemberSessions.LoginDateTime
		FROM
			Operation.MemberSessions AS MemberSessions
		WHERE
			MemberSessions.MemberId = PotentialCouples.RequestingMemberId
		ORDER BY
			MemberSessions.LoginDateTime DESC
	)
	AS
		RequestingSessions;
