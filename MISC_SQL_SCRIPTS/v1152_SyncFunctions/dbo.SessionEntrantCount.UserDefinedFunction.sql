USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[SessionEntrantCount]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 15/11/2019
-- Description:	Count the number of entrants in a given session
-- =============================================
CREATE OR ALTER  FUNCTION [dbo].[SessionEntrantCount] (
    -- Add the parameters for the function here
    @SessionID INT
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = Count(Entrant.MemberID)
    FROM Entrant
    INNER JOIN HeatIndividual
        ON Entrant.HeatID = HeatIndividual.HeatID
    INNER JOIN Event
        ON HeatIndividual.EventID = Event.EventID
    WHERE (Event.SessionID = @SessionID)
        AND (Entrant.MemberID > 0)

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[SessionEntrantCount] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SessionEntrantCount] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SessionEntrantCount] TO [SCM_Marshall] AS [dbo]
GO
