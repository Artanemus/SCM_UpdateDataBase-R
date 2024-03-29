USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[SwimTimeToMilliseconds]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 9/8/2019
-- Description:	SwimTime to Milliseconds
-- =============================================
CREATE OR ALTER  FUNCTION [dbo].[SwimTimeToMilliseconds] (
    -- Add the parameters for the function here
    @SwimTime TIME
    )
RETURNS INT
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result INT

    -- THIS IS ALSO LEGAL
    -- SELECT @Result = DATEDIFF(MILLISECOND, 0, @SwimTime)
    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = DATEPART(MILLISECOND, @SwimTime) + (DATEPART(second, @SwimTime) * 1000) + (DATEPART(minute, @SwimTime) * 1000 * 60)

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[SwimTimeToMilliseconds] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SwimTimeToMilliseconds] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SwimTimeToMilliseconds] TO [SCM_Marshall] AS [dbo]
GO
