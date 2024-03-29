USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[PersonalBest]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 3/8/2019
-- Updated 16/5/2020
-- Description:	Find the 'Personal Best' 
--				race time for a given Member
-- =============================================
CREATE OR ALTER
    

   FUNCTION [dbo].[PersonalBest] (
    -- Add the parameters for the function here
    @MemberID INT
    , @DistanceID INT
    , @StrokeID INT
    , @SessionDate DATETIME = NULL
    )
RETURNS TIME
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result TIME

    -- use a default sessiontime
    IF @SessionDate IS NULL
        SET @SessionDate = GETDATE();

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = MIN(Entrant.RaceTime)
    -- CAST(CAST(MIN(Entrant.RaceTime) AS DATETIME) AS FLOAT) AS PersonalBest
    FROM Entrant
    INNER JOIN HeatIndividual
        ON Entrant.HeatID = HeatIndividual.HeatID
    INNER JOIN Event
        ON HeatIndividual.EventID = Event.EventID
    INNER JOIN Session
        ON Event.SessionID = Session.SessionID
    WHERE (Event.StrokeID = @StrokeID)
        AND (Event.DistanceID = @DistanceID)
        AND (Entrant.RaceTime IS NOT NULL)
        AND (Entrant.IsDisqualified <> 1) -- added 16/5/2020
        AND (Entrant.IsScratched <> 1) -- added 16/5/2020
        AND (Session.SessionStart < @SessionDate)
    GROUP BY Entrant.MemberID
    HAVING (Entrant.MemberID = @MemberID)

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[PersonalBest] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[PersonalBest] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[PersonalBest] TO [SCM_Marshall] AS [dbo]
GO
