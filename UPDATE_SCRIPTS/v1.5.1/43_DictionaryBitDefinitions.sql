USE [SwimClubMeet]
GO

-- Dictionary Object Alter SQL
CREATE DEFAULT dbo.BIT_1 AS 1
GO

-- Dictionary Object Alter SQL
CREATE DEFAULT dbo.BIT_0 AS 0
GO

-- Standard Alter Table SQL
ALTER TABLE dbo.Member ADD IsSwimmer BIT NULL
GO


