USE [SwimClubMeet]
go

-- Drop Constraint, Rename and Create Table SQL

EXEC sp_rename 'dbo.ContactNum.PK_ContactNum','PK_Contact_01172023031455001','INDEX'
go
EXEC sp_rename 'dbo.FK_Member_ContactNum','FK_Member__01172023031455002'
go
EXEC sp_rename 'dbo.FK_ContactNumType_ContactNum','FK_Contact_01172023031455003'
go
EXEC sp_rename 'dbo.ContactNum','ContactNum_01172023031455000',OBJECT
go
CREATE TABLE dbo.ContactNum
(
    ContactNumID     int           IDENTITY,
    Number           nvarchar(30)  NULL,
    ContactNumTypeID int           NULL,
    MemberID         int           NULL,
    IsArchived       bit            NOT NULL
)
ON [PRIMARY]
go
GRANT DELETE ON dbo.ContactNum TO SCM_Administrator
go
GRANT INSERT ON dbo.ContactNum TO SCM_Administrator
go
GRANT SELECT ON dbo.ContactNum TO SCM_Administrator
go
GRANT UPDATE ON dbo.ContactNum TO SCM_Administrator
go
GRANT SELECT ON dbo.ContactNum TO SCM_Guest
go
GRANT SELECT ON dbo.ContactNum TO SCM_Marshall
go

-- Insert Data SQL

SET IDENTITY_INSERT dbo.ContactNum ON
go
INSERT INTO dbo.ContactNum(
                           ContactNumID,
                           Number,
                           ContactNumTypeID,
                           MemberID,
                           IsArchived
                          )
                    SELECT 
                           ContactNumID,
                           Number,
                           ContactNumTypeID,
                           MemberID,
                           0
                      FROM dbo.ContactNum_01172023031455000 
go
SET IDENTITY_INSERT dbo.ContactNum OFF
go

-- Add Constraint SQL

ALTER TABLE dbo.ContactNum ADD CONSTRAINT PK_ContactNum
PRIMARY KEY CLUSTERED (ContactNumID)
go

-- Add Referencing Foreign Keys SQL

ALTER TABLE dbo.ContactNum ADD CONSTRAINT FK_Member_ContactNum
FOREIGN KEY (MemberID)
REFERENCES dbo.Member (MemberID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.ContactNum ADD CONSTRAINT FK_ContactNumType_ContactNum
FOREIGN KEY (ContactNumTypeID)
REFERENCES dbo.ContactNumType (ContactNumTypeID)
 ON DELETE SET NULL
go
