USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[ABSHeatPlace]    Script Date: 16/04/22 9:34:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 2020.11.04
-- Description:	Find the ABSOLUTE place of the member in the heat.
-- =============================================
CREATE
    

 OR ALTER FUNCTION [dbo].[ABSHeatPlace] (
    -- Add the parameters for the function here
    @HeatID INT
    , @MemberID INT
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT;

    WITH CTE_Heat (
        Place
        , RaceTime
        , HeatID
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
            , Entrant.RaceTime
            , HeatIndividual.HeatID
            , Entrant.MemberID
        FROM HeatIndividual
        INNER JOIN Entrant
            ON HeatIndividual.HeatID = Entrant.HeatID
        WHERE HeatIndividual.HeatID = @HeatID
            AND MemberID IS NOT NULL
            AND Entrant.IsDisqualified = 0
            AND Entrant.IsScratched = 0
        )
    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = (
            SELECT CTE_Heat.Place
            FROM CTE_Heat
            WHERE CTE_Heat.MemberID = @MemberID
            )

    -- Return the result of the function
    RETURN @Result
END
GO
