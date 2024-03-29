USE [SwimClubMeet]
GO
/****** Object:  UserDefinedFunction [dbo].[SwimmerGenderToString]    Script Date: 20/08/22 11:51:52 AM ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER OFF
GO

-- =============================================
-- Author:		Ben
-- Create date: 21/02/2019
-- Description:	Return the gender of the meber as a short string
-- =============================================
CREATE OR ALTER  FUNCTION [dbo].[SwimmerGenderToString] (
    -- Add the parameters for the function here
    @MemberID INT
    )
RETURNS NVARCHAR(2)
AS
BEGIN
    -- Declare the return variable here
    DECLARE @Result NVARCHAR(2)

    -- Add the T-SQL statements to compute the return value here
    SELECT @Result = CASE GenderID
            WHEN 1
                THEN 'M'
            WHEN 2
                THEN 'F'
            END
    FROM Member
    WHERE MemberID = @MemberID;

    -- Return the result of the function
    RETURN @Result
END
GO
GRANT EXECUTE ON [dbo].[SwimmerGenderToString] TO [SCM_Administrator] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SwimmerGenderToString] TO [SCM_Guest] AS [dbo]
GO
GRANT EXECUTE ON [dbo].[SwimmerGenderToString] TO [SCM_Marshall] AS [dbo]
GO
