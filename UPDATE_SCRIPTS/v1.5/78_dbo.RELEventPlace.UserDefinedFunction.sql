USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[RELEventPlace]    Script Date: 16/04/22 9:34:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 2020.11.04
-- Description:	Find the place of the member in the event relative to a given division.
-- =============================================
CREATE
    

 OR ALTER FUNCTION [dbo].[RELEventPlace] (
    -- Add the parameters for the function here
    @EventID INT
    , @MemberID INT
    , @DivisionID INT
    , @SessionStart DATETIME
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT;
    DECLARE @TempTBL TABLE (
        MemberID INT
        , ScoreDivisionID INT
        );

    INSERT INTO @TempTBL
    SELECT Member.MemberID
        , ScoreDivisionID
    FROM ScoreDivision
    JOIN Member
        ON ScoreDivision.GenderID = Member.GenderID
    WHERE dbo.SwimmerAge(@SessionStart, Member.DOB) <= AgeTo
        AND dbo.SwimmerAge(@SessionStart, Member.DOB) >= AgeFrom;

    WITH CTE_Event (
        Place
        , MemberID
        )
    AS (
        SELECT ROW_NUMBER() OVER (
                ORDER BY CASE 
                        WHEN RaceTime IS NULL
                            THEN 1
                        ELSE 0
                        END ASC
                    , CASE 
                        WHEN (CAST(CAST(RaceTime AS DATETIME) AS FLOAT) = 0)
                            THEN 1
                        ELSE 0
                        END ASC
                    , RaceTime ASC
                ) AS Place
            , Entrant.MemberID
        FROM Event
        INNER JOIN HeatIndividual
            ON Event.EventID = HeatIndividual.EventID
        INNER JOIN Entrant
            ON HeatIndividual.HeatID = Entrant.HeatID
        LEFT JOIN @TempTBL
            ON Entrant.MemberID = [@TempTBL].[MemberID]
        WHERE Event.EventID = @EventID
            AND Entrant.MemberID IS NOT NULL
            AND Entrant.IsDisqualified = 0
            AND Entrant.IsScratched = 0
            AND [@TempTBL].[ScoreDivisionID] = @DivisionID
        )
    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = (
            SELECT CTE_Event.Place
            FROM CTE_Event
            WHERE CTE_Event.MemberID = @MemberID
            )

    -- Return the result of the function
    RETURN @Result
END
GO
