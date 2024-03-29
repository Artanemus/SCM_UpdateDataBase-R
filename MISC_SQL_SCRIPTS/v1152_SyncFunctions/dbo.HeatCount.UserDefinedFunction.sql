USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[HeatCount]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 14/8/2019
-- Description:	Count the number of heats in an event
-- =============================================
CREATE OR ALTER  FUNCTION [dbo].[HeatCount] (
    -- Add the parameters for the function here
    @EventID INT
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = @EventID

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = Count(HeatIndividual.EventID)
    FROM HeatIndividual
    WHERE HeatIndividual.EventID = @EventID
    GROUP BY HeatIndividual.EventID

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[HeatCount] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[HeatCount] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[HeatCount] TO [SCM_Marshall] AS [dbo]
GO
