USE [SwimClubMeet]
GO


/*
	In version 1.5, the param IsArchived is revealed in the members dialogue.
	So as the fields are not NULL - this assigns a default setting based on the current activity of the member
*/
UPDATE [dbo].[Member] SET  [IsArchived] = 0;
GO



/* 
	New field introduced: IsSwimmer
	So as all queries work correctly ... a blanket assignment of the new field is performed.
	All members are assummed to be swimmer.
*/

UPDATE [dbo].[Member] SET [IsSwimmer] = 1;
      
GO

