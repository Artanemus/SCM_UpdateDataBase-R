USE SwimClubMeet
GO

--CREATE ROLE SCM_Guest AUTHORIZATION dbo
--go

GRANT SELECT ON dbo.HeatStatus TO SCM_Guest
go
GRANT SELECT ON dbo.MembershipType TO SCM_Guest
go
GRANT SELECT ON dbo.EventStatus TO SCM_Guest
go
GRANT SELECT ON dbo.SessionStatus TO SCM_Guest
go
GRANT SELECT ON dbo.SwimClub TO SCM_Guest
go
GRANT SELECT ON dbo.Session TO SCM_Guest
go
GRANT SELECT ON dbo.Event TO SCM_Guest
go
GRANT SELECT ON dbo.HeatIndividual TO SCM_Guest
go
GRANT SELECT ON dbo.Member TO SCM_Guest
go
GRANT SELECT ON dbo.HeatType TO SCM_Guest
go
GRANT SELECT ON dbo.Entrant TO SCM_Guest
go
GRANT SELECT ON dbo.Stroke TO SCM_Guest
go
GRANT SELECT ON dbo.Distance TO SCM_Guest
go
GRANT SELECT ON dbo.EventType TO SCM_Guest
go
GRANT SELECT ON dbo.HeatTeam TO SCM_Guest
go
GRANT SELECT ON dbo.Team TO SCM_Guest
go
GRANT SELECT ON dbo.TeamEntrant TO SCM_Guest
go
GRANT SELECT ON dbo.Split TO SCM_Guest
go
GRANT SELECT ON dbo.Gender TO SCM_Guest
go
GRANT SELECT ON dbo.TeamSplit TO SCM_Guest
go
GRANT SELECT ON dbo.Qualify TO SCM_Guest
go
GRANT SELECT ON dbo.ContactNum TO SCM_Guest
go
GRANT SELECT ON dbo.ContactNumType TO SCM_Guest
go
GRANT SELECT ON dbo.Nominee TO SCM_Guest
go
GRANT SELECT ON dbo.SCMSystem TO SCM_Guest
go
GRANT SELECT ON dbo.ScoreDivision TO SCM_Guest
go
GRANT SELECT ON dbo.ScorePoints TO SCM_Guest
go
GRANT SELECT ON dbo.House TO SCM_Guest
go
GRANT EXECUTE ON dbo.RaceTimeDIFF TO SCM_Guest
go
GRANT EXECUTE ON dbo.SwimmerAge TO SCM_Guest
go
GRANT EXECUTE ON dbo.SwimmerGenderToString TO SCM_Guest
go
GRANT EXECUTE ON dbo.SwimTimeToString TO SCM_Guest
go
GRANT EXECUTE ON dbo.TimeToBeat_1 TO SCM_Guest
go
GRANT EXECUTE ON dbo.TimeToBeat_2 TO SCM_Guest
go
GRANT EXECUTE ON dbo.TimeToBeat TO SCM_Guest
go
GRANT EXECUTE ON dbo.PersonalBest TO SCM_Guest
go
GRANT EXECUTE ON dbo.SwimTimeToMilliseconds TO SCM_Guest
go
GRANT EXECUTE ON dbo.EntrantCount TO SCM_Guest
go
GRANT EXECUTE ON dbo.NomineeCount TO SCM_Guest
go
GRANT EXECUTE ON dbo.HeatCount TO SCM_Guest
go
GRANT EXECUTE ON dbo.SessionEntrantCount TO SCM_Guest
go
GRANT EXECUTE ON dbo.SessionNomineeCount TO SCM_Guest
go
GRANT EXECUTE ON dbo.IsPoolShortCourse TO SCM_Guest
go
GRANT EXECUTE ON dbo.ABSHeatPlace TO SCM_Guest
go
GRANT EXECUTE ON dbo.RELEventPlace TO SCM_Guest
go
GRANT EXECUTE ON dbo.RELHeatPlace TO SCM_Guest
go
GRANT EXECUTE ON dbo.ABSEventPlace TO SCM_Guest
go
GRANT EXECUTE ON dbo.TimeToBeat_DEFAULT TO SCM_Guest
go
GRANT EXECUTE ON dbo.IsMemberNominated TO SCM_Guest
go
GRANT EXECUTE ON dbo.IsMemberQualified TO SCM_Guest
go
GRANT EXECUTE ON dbo.EntrantScore TO SCM_Guest
go

