USE [SwimClubMeet]
GO
/****** Object:  User [scmAdmin]    Script Date: 20/04/22 10:56:06 AM ******/
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'scmAdmin')
CREATE USER [scmAdmin] WITHOUT LOGIN WITH DEFAULT_SCHEMA=[scmAdmin]
GO
ALTER ROLE [SCM_Administrator] ADD MEMBER [scmAdmin]
GO
