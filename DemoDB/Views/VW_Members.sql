CREATE VIEW [dbo].[VW_Members]
AS
SELECT
	[Id], [Username], [FirstName], [LastName], [StreetAddress], [CountryId], [EmailAddress], [GenderId], [BirthDate], [SexualPreferenceId], [MaritalStatusId], [RegistrationDateTime]
FROM Operation.Members
