USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[SessionNomineeCount]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 15/11/2019
-- Description:	Count the number of Nominees for a give session
-- =============================================
CREATE OR ALTER  FUNCTION [dbo].[SessionNomineeCount] (
    -- Add the parameters for the function here
    @SessionID INT
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = COUNT(Nominee.NomineeID)
    FROM Nominee
    INNER JOIN Event
        ON Nominee.EventID = Event.EventID
    WHERE (Event.SessionID = @SessionID);

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[SessionNomineeCount] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SessionNomineeCount] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SessionNomineeCount] TO [SCM_Marshall] AS [dbo]
GO
