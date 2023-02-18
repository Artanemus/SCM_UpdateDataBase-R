USE SwimClubMeet;

IF EXISTS (SELECT * FROM [SwimClubMeet].[dbo].[SwimClub] WHERE [SwimClubID] = 1)
BEGIN
    UPDATE [SwimClubMeet].[dbo].[Member]
    SET SwimClubID = 1 
    WHERE SwimClubID IS NULL
END

;