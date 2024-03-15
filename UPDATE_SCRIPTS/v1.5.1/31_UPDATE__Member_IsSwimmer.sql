USE [SwimClubMeet]
GO

/* 
	New field introduced: IsSwimmer
	So as all queries work correctly ... a blanket assignment of the new field is performed.
	All members are assummed to be swimmer.
*/

UPDATE [dbo].[Member] SET [IsSwimmer] = 1;
      
GO

