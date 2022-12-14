USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[EntrantCount]    Script Date: 16/04/22 9:34:35 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 13/8/2019
-- Description:	Count the number of entrants for an event
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[EntrantCount] (
    -- Add the parameters for the function here
    @EventID INT
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = Count(Entrant.EntrantID)
    FROM Entrant
    INNER JOIN HeatIndividual
        ON Entrant.HeatID = HeatIndividual.HeatID
    WHERE (Entrant.MemberID IS NOT NULL)
    GROUP BY HeatIndividual.EventID
    HAVING HeatIndividual.EventID = @EventID

    -- Return the result of the function
    RETURN @Result
END
GO
