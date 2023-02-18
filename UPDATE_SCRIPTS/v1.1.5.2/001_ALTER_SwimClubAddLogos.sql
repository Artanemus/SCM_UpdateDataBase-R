USE [SwimClubMeet]
;

-- Standard Alter Table SQL

ALTER TABLE dbo.SwimClub ADD LogoDir VARCHAR(max) NULL
;
ALTER TABLE dbo.SwimClub ADD LogoImg IMAGE NULL
;
ALTER TABLE dbo.SwimClub ADD LogoType NVARCHAR(5) NULL
;


