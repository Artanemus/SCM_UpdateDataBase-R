/*
   Friday, 3 February 20234:24:14 PM
   User: 
   Server: DESKTOP-MOITPNS\SQLEXPRESS
   Database: SwimClubMeet
   Application: 
*/

/* To prevent any potential data loss issues, you should review this script in detail before running it outside the context of the database designer.*/
BEGIN TRANSACTION
SET QUOTED_IDENTIFIER ON
SET ARITHABORT ON
SET NUMERIC_ROUNDABORT OFF
SET CONCAT_NULL_YIELDS_NULL ON
SET ANSI_NULLS ON
SET ANSI_PADDING ON
SET ANSI_WARNINGS ON
COMMIT
BEGIN TRANSACTION
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT DF__Member__IsArchiv__628FA481
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT DF__Member__IsActive__6383C8BA
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT DF__Member__IsSwimme__6477ECF3
GO
ALTER TABLE dbo.Member
	DROP COLUMN IsSwimmer
GO
ALTER TABLE dbo.Member SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Member', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Member', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Member', 'Object', 'CONTROL') as Contr_Per 