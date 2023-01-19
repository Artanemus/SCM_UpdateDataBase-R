USE [SwimClubMeet];

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 25 WHERE [Caption] = '25m';

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 50 WHERE [Caption] = '50m';

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 100 WHERE [Caption] = '100m';

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 200 WHERE [Caption] = '200m';

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 400 WHERE [Caption] = '400m';

UPDATE [SwimClubMeet].[dbo].[Distance] 
SET [Meters] = 1000 WHERE [Caption] = '1000m';
