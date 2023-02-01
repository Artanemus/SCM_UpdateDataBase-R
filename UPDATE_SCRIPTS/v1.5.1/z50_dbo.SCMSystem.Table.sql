USE [SwimClubMeet]
GO

UPDATE [dbo].[SCMSystem]
   SET [DBVersion] = 1
      ,[Major] = 5
      ,[Minor] = 0
 WHERE [dbo].[SCMSystem].SCMSystemID = 1
GO


