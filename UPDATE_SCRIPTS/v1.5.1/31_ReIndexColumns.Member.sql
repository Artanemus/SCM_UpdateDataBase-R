USE [SwimClubMeet]
go

-- Drop Referencing Constraint SQL

ALTER TABLE dbo.ContactNum DROP CONSTRAINT FK_Member_ContactNum
go
ALTER TABLE dbo.Entrant DROP CONSTRAINT FK_Member_Entrant
go
ALTER TABLE dbo.Nominee DROP CONSTRAINT FK_Member_Nominee
go
ALTER TABLE dbo.TeamEntrant DROP CONSTRAINT FK_Member_TeamEntrant
go

-- Drop Constraint, Rename and Create Table SQL

EXEC sp_rename 'dbo.Member.PK_Member','PK_Member_02032023231945001','INDEX'
go
EXEC sp_rename 'dbo.FK_Gender_Member','FK_Gender__02032023231945002'
go
EXEC sp_rename 'dbo.FK_House_Member','FK_House_M_02032023231945003'
go
EXEC sp_rename 'dbo.FK_MembershipType_Member','FK_Members_02032023231945004'
go
EXEC sp_rename 'dbo.FK_SwimClub_Member','FK_SwimClu_02032023231945005'
go
EXEC sp_rename 'dbo.DF__Member__EnableEm__2B3F6F97', 'DF__Member_02032023231945006',OBJECT
go
EXEC sp_rename 'dbo.DF__Member__IsActive__2A4B4B5E', 'DF__Member_02032023231945007',OBJECT
go
EXEC sp_rename 'dbo.Member','Member_02032023231945000',OBJECT
go
CREATE TABLE dbo.Member
(
    MemberID                 int            IDENTITY,
    MembershipNum            int            NULL,
    MembershipStr            nvarchar(24)   NULL,
    MembershipDue            datetime       NULL,
    FirstName                nvarchar(128)  NULL,
    LastName                 nvarchar(128)  NULL,
    DOB                      datetime       NULL,
    IsArchived               bit            NULL,
    IsActive                 bit            CONSTRAINT DF__Member__IsActive__2A4B4B5E DEFAULT ((1)) NULL,
    IsSwimmer                bit            NULL,
    Email                    nvarchar(256)  NULL,
    EnableEmailOut           bit            CONSTRAINT DF__Member__EnableEm__2B3F6F97 DEFAULT ((0)) NULL,
    GenderID                 int            NULL,
    SwimClubID               int            NULL,
    MembershipTypeID         int            NULL,
    CreatedOn                datetime       NULL,
    ArchivedOn               datetime       NULL,
    EnableEmailNomineeForm   bit            NULL,
    EnableEmailSessionReport bit            NULL,
    HouseID                  int            NULL
)
ON [PRIMARY]
go
GRANT DELETE ON dbo.Member TO SCM_Administrator
go
GRANT INSERT ON dbo.Member TO SCM_Administrator
go
GRANT SELECT ON dbo.Member TO SCM_Administrator
go
GRANT UPDATE ON dbo.Member TO SCM_Administrator
go
GRANT SELECT ON dbo.Member TO SCM_Guest
go
GRANT SELECT ON dbo.Member TO SCM_Marshall
go

-- Insert Data SQL

SET IDENTITY_INSERT dbo.Member ON
go
INSERT INTO dbo.Member(
                       MemberID,
                       MembershipNum,
                       MembershipStr,
                       MembershipDue,
                       FirstName,
                       LastName,
                       DOB,
                       IsArchived,
                       IsActive,
                       IsSwimmer,
                       Email,
                       EnableEmailOut,
                       GenderID,
                       SwimClubID,
                       MembershipTypeID,
                       CreatedOn,
                       ArchivedOn,
                       EnableEmailNomineeForm,
                       EnableEmailSessionReport,
                       HouseID
                      )
                SELECT 
                       MemberID,
                       MembershipNum,
                       MembershipStr,
                       MembershipDue,
                       FirstName,
                       LastName,
                       DOB,
                       IsArchived,
                       IsActive,
                       IsSwimmer,
                       Email,
                       EnableEmailOut,
                       GenderID,
                       SwimClubID,
                       MembershipTypeID,
                       CreatedOn,
                       ArchivedOn,
                       EnableEmailNomineeForm,
                       EnableEmailSessionReport,
                       HouseID
                  FROM dbo.Member_02032023231945000 
go
SET IDENTITY_INSERT dbo.Member OFF
go

-- Add Constraint SQL

ALTER TABLE dbo.Member ADD CONSTRAINT PK_Member
PRIMARY KEY NONCLUSTERED (MemberID)
go

-- Add Referencing Foreign Keys SQL

ALTER TABLE dbo.ContactNum ADD CONSTRAINT FK_Member_ContactNum
FOREIGN KEY (MemberID)
REFERENCES dbo.Member (MemberID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.Entrant ADD CONSTRAINT FK_Member_Entrant
FOREIGN KEY (MemberID)
REFERENCES dbo.Member (MemberID)
 NOT FOR REPLICATION
go
ALTER TABLE dbo.Nominee ADD CONSTRAINT FK_Member_Nominee
FOREIGN KEY (MemberID)
REFERENCES dbo.Member (MemberID)
go
ALTER TABLE dbo.TeamEntrant ADD CONSTRAINT FK_Member_TeamEntrant
FOREIGN KEY (MemberID)
REFERENCES dbo.Member (MemberID)
go
ALTER TABLE dbo.Member ADD CONSTRAINT FK_Gender_Member
FOREIGN KEY (GenderID)
REFERENCES dbo.Gender (GenderID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Member ADD CONSTRAINT FK_House_Member
FOREIGN KEY (HouseID)
REFERENCES dbo.House (HouseID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Member ADD CONSTRAINT FK_MembershipType_Member
FOREIGN KEY (MembershipTypeID)
REFERENCES dbo.MembershipType (MembershipTypeID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Member ADD CONSTRAINT FK_SwimClub_Member
FOREIGN KEY (SwimClubID)
REFERENCES dbo.SwimClub (SwimClubID)
 ON DELETE SET NULL
go
