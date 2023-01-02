USE [SwimClubMeet]
go

-- Standard Alter Table SQL

ALTER TABLE dbo.House ADD LogoType NVARCHAR(5) NULL
go
ALTER TABLE dbo.SwimClub ADD LogoDir VARCHAR(max) NULL
go
ALTER TABLE dbo.SwimClub ADD LogoImg IMAGE NULL
go
ALTER TABLE dbo.SwimClub ADD LogoType NVARCHAR(5) NULL
go



UPDATE [SwimClubMeet].[dbo].[SCMSystem]
SET [Major] = 6
  , [Minor] = 0
WHERE SCMSystemID = 1
GO
