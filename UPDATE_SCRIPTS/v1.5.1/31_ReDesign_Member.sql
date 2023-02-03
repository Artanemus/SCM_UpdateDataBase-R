/*
   Friday, 3 February 20234:38:12 PM
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
	DROP CONSTRAINT FK_SwimClub_Member
GO
ALTER TABLE dbo.SwimClub SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.SwimClub', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.SwimClub', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.SwimClub', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT FK_MembershipType_Member
GO
ALTER TABLE dbo.MembershipType SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.MembershipType', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.MembershipType', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.MembershipType', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT FK_House_Member
GO
ALTER TABLE dbo.House SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.House', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.House', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.House', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT FK_Gender_Member
GO
ALTER TABLE dbo.Gender SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Gender', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Gender', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Gender', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Member
	DROP CONSTRAINT DF__Member__EnableEm__2B3F6F97
GO
CREATE TABLE dbo.Tmp_Member
	(
	MemberID int NOT NULL IDENTITY (1, 1),
	MembershipNum int NULL,
	MembershipStr nvarchar(24) NULL,
	MembershipDue datetime NULL,
	FirstName nvarchar(128) NULL,
	LastName nvarchar(128) NULL,
	DOB datetime NULL,
	IsArchived bit NULL,
	IsActive bit NULL,
	IsSwimmer bit NULL,
	Email nvarchar(256) NULL,
	EnableEmailOut bit NULL,
	GenderID int NULL,
	SwimClubID int NULL,
	MembershipTypeID int NULL,
	CreatedOn datetime NULL,
	ArchivedOn datetime NULL,
	EnableEmailNomineeForm bit NULL,
	EnableEmailSessionReport bit NULL,
	HouseID int NULL
	)  ON [PRIMARY]
GO
ALTER TABLE dbo.Tmp_Member SET (LOCK_ESCALATION = TABLE)
GO
GRANT DELETE ON dbo.Tmp_Member TO SCM_Administrator  AS dbo
GO
GRANT INSERT ON dbo.Tmp_Member TO SCM_Administrator  AS dbo
GO
GRANT SELECT ON dbo.Tmp_Member TO SCM_Administrator  AS dbo
GO
GRANT SELECT ON dbo.Tmp_Member TO SCM_Guest  AS dbo
GO
GRANT SELECT ON dbo.Tmp_Member TO SCM_Marshall  AS dbo
GO
GRANT UPDATE ON dbo.Tmp_Member TO SCM_Administrator  AS dbo
GO
ALTER TABLE dbo.Tmp_Member ADD CONSTRAINT
	DF_Member_IsArchived DEFAULT 0 FOR IsArchived
GO
ALTER TABLE dbo.Tmp_Member ADD CONSTRAINT
	DF_Member_IsActive DEFAULT 1 FOR IsActive
GO
ALTER TABLE dbo.Tmp_Member ADD CONSTRAINT
	DF_Member_IsSwimmer DEFAULT 1 FOR IsSwimmer
GO
ALTER TABLE dbo.Tmp_Member ADD CONSTRAINT
	DF__Member__EnableEm__2B3F6F97 DEFAULT ((0)) FOR EnableEmailOut
GO
SET IDENTITY_INSERT dbo.Tmp_Member ON
GO
IF EXISTS(SELECT * FROM dbo.Member)
	 EXEC('INSERT INTO dbo.Tmp_Member (MemberID, MembershipNum, MembershipStr, MembershipDue, FirstName, LastName, DOB, IsArchived, IsActive, Email, EnableEmailOut, GenderID, SwimClubID, MembershipTypeID, CreatedOn, ArchivedOn, EnableEmailNomineeForm, EnableEmailSessionReport, HouseID)
		SELECT MemberID, MembershipNum, MembershipStr, MembershipDue, FirstName, LastName, DOB, IsArchived, IsActive, Email, EnableEmailOut, GenderID, SwimClubID, MembershipTypeID, CreatedOn, ArchivedOn, EnableEmailNomineeForm, EnableEmailSessionReport, HouseID FROM dbo.Member WITH (HOLDLOCK TABLOCKX)')
GO
SET IDENTITY_INSERT dbo.Tmp_Member OFF
GO
ALTER TABLE dbo.ContactNum
	DROP CONSTRAINT FK_Member_ContactNum
GO
ALTER TABLE dbo.Entrant
	DROP CONSTRAINT FK_Member_Entrant
GO
ALTER TABLE dbo.Nominee
	DROP CONSTRAINT FK_Member_Nominee
GO
ALTER TABLE dbo.TeamEntrant
	DROP CONSTRAINT FK_Member_TeamEntrant
GO
DROP TABLE dbo.Member
GO
EXECUTE sp_rename N'dbo.Tmp_Member', N'Member', 'OBJECT' 
GO
ALTER TABLE dbo.Member ADD CONSTRAINT
	PK_Member PRIMARY KEY NONCLUSTERED 
	(
	MemberID
	) WITH( STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]

GO
ALTER TABLE dbo.Member ADD CONSTRAINT
	FK_Gender_Member FOREIGN KEY
	(
	GenderID
	) REFERENCES dbo.Gender
	(
	GenderID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
ALTER TABLE dbo.Member ADD CONSTRAINT
	FK_House_Member FOREIGN KEY
	(
	HouseID
	) REFERENCES dbo.House
	(
	HouseID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
ALTER TABLE dbo.Member ADD CONSTRAINT
	FK_MembershipType_Member FOREIGN KEY
	(
	MembershipTypeID
	) REFERENCES dbo.MembershipType
	(
	MembershipTypeID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
ALTER TABLE dbo.Member ADD CONSTRAINT
	FK_SwimClub_Member FOREIGN KEY
	(
	SwimClubID
	) REFERENCES dbo.SwimClub
	(
	SwimClubID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Member', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Member', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Member', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.TeamEntrant ADD CONSTRAINT
	FK_Member_TeamEntrant FOREIGN KEY
	(
	MemberID
	) REFERENCES dbo.Member
	(
	MemberID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
ALTER TABLE dbo.TeamEntrant SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.TeamEntrant', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.TeamEntrant', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.TeamEntrant', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Nominee ADD CONSTRAINT
	FK_Member_Nominee FOREIGN KEY
	(
	MemberID
	) REFERENCES dbo.Member
	(
	MemberID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	
GO
ALTER TABLE dbo.Nominee SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Nominee', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Nominee', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Nominee', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.Entrant WITH NOCHECK ADD CONSTRAINT
	FK_Member_Entrant FOREIGN KEY
	(
	MemberID
	) REFERENCES dbo.Member
	(
	MemberID
	) ON UPDATE  NO ACTION 
	 ON DELETE  SET NULL 
	 NOT FOR REPLICATION

GO
ALTER TABLE dbo.Entrant SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.Entrant', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.Entrant', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.Entrant', 'Object', 'CONTROL') as Contr_Per BEGIN TRANSACTION
GO
ALTER TABLE dbo.ContactNum ADD CONSTRAINT
	FK_Member_ContactNum FOREIGN KEY
	(
	MemberID
	) REFERENCES dbo.Member
	(
	MemberID
	) ON UPDATE  NO ACTION 
	 ON DELETE  CASCADE 
	
GO
ALTER TABLE dbo.ContactNum SET (LOCK_ESCALATION = TABLE)
GO
COMMIT
select Has_Perms_By_Name(N'dbo.ContactNum', 'Object', 'ALTER') as ALT_Per, Has_Perms_By_Name(N'dbo.ContactNum', 'Object', 'VIEW DEFINITION') as View_def_Per, Has_Perms_By_Name(N'dbo.ContactNum', 'Object', 'CONTROL') as Contr_Per 