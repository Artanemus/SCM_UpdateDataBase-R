USE [SwimClubMeet]
GO

/****** Object:  UserDefinedFunction [dbo].[IsMemberNominated]    Script Date: 25/05/22 2:43:02 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Author:		Ben Ambrose
-- Create date: 25/05/2022
-- Description:	Is the member nominated for the event
-- =============================================
CREATE OR ALTER FUNCTION [dbo].[IsMemberNominated] 
(
	-- Add the parameters for the function here
	@MemberID int
	,@EventID int
)
RETURNS Bit
AS
BEGIN
	-- Declare the return variable here
	DECLARE @Result Bit

	-- Add the T-SQL statements to compute the return value here
    SELECT @Result = (
            SELECT CASE 
                    WHEN [NomineeID] IS NOT NULL
                        THEN 0
                    ELSE 1
                    END
            FROM Nominee
            WHERE MemberID = @MemberID AND EventID = @EventID
            )

	-- Return the result of the function
	RETURN @Result

END
GO


