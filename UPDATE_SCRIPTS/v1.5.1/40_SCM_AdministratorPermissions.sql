USE SwimClubMeet
GO

--CREATE ROLE SCM_Administrator AUTHORIZATION dbo
--go

GRANT SELECT ON dbo.HeatStatus TO SCM_Administrator
go
GRANT DELETE ON dbo.MembershipType TO SCM_Administrator
go
GRANT INSERT ON dbo.MembershipType TO SCM_Administrator
go
GRANT SELECT ON dbo.MembershipType TO SCM_Administrator
go
GRANT UPDATE ON dbo.MembershipType TO SCM_Administrator
go
GRANT SELECT ON dbo.EventStatus TO SCM_Administrator
go
GRANT SELECT ON dbo.SessionStatus TO SCM_Administrator
go
GRANT SELECT ON dbo.SwimClub TO SCM_Administrator
go
GRANT DELETE ON dbo.Session TO SCM_Administrator
go
GRANT INSERT ON dbo.Session TO SCM_Administrator
go
GRANT SELECT ON dbo.Session TO SCM_Administrator
go
GRANT UPDATE ON dbo.Session TO SCM_Administrator
go
GRANT DELETE ON dbo.Event TO SCM_Administrator
go
GRANT INSERT ON dbo.Event TO SCM_Administrator
go
GRANT SELECT ON dbo.Event TO SCM_Administrator
go
GRANT UPDATE ON dbo.Event TO SCM_Administrator
go
GRANT DELETE ON dbo.HeatIndividual TO SCM_Administrator
go
GRANT INSERT ON dbo.HeatIndividual TO SCM_Administrator
go
GRANT SELECT ON dbo.HeatIndividual TO SCM_Administrator
go
GRANT UPDATE ON dbo.HeatIndividual TO SCM_Administrator
go
GRANT DELETE ON dbo.Member TO SCM_Administrator
go
GRANT INSERT ON dbo.Member TO SCM_Administrator
go
GRANT SELECT ON dbo.Member TO SCM_Administrator
go
GRANT UPDATE ON dbo.Member TO SCM_Administrator
go
GRANT SELECT ON dbo.HeatType TO SCM_Administrator
go
GRANT DELETE ON dbo.Entrant TO SCM_Administrator
go
GRANT INSERT ON dbo.Entrant TO SCM_Administrator
go
GRANT SELECT ON dbo.Entrant TO SCM_Administrator
go
GRANT UPDATE ON dbo.Entrant TO SCM_Administrator
go
GRANT SELECT ON dbo.Stroke TO SCM_Administrator
go
GRANT SELECT ON dbo.Distance TO SCM_Administrator
go
GRANT SELECT ON dbo.EventType TO SCM_Administrator
go
GRANT DELETE ON dbo.HeatTeam TO SCM_Administrator
go
GRANT INSERT ON dbo.HeatTeam TO SCM_Administrator
go
GRANT SELECT ON dbo.HeatTeam TO SCM_Administrator
go
GRANT UPDATE ON dbo.HeatTeam TO SCM_Administrator
go
GRANT DELETE ON dbo.Team TO SCM_Administrator
go
GRANT INSERT ON dbo.Team TO SCM_Administrator
go
GRANT SELECT ON dbo.Team TO SCM_Administrator
go
GRANT UPDATE ON dbo.Team TO SCM_Administrator
go
GRANT DELETE ON dbo.TeamEntrant TO SCM_Administrator
go
GRANT INSERT ON dbo.TeamEntrant TO SCM_Administrator
go
GRANT SELECT ON dbo.TeamEntrant TO SCM_Administrator
go
GRANT UPDATE ON dbo.TeamEntrant TO SCM_Administrator
go
GRANT DELETE ON dbo.Split TO SCM_Administrator
go
GRANT INSERT ON dbo.Split TO SCM_Administrator
go
GRANT SELECT ON dbo.Split TO SCM_Administrator
go
GRANT UPDATE ON dbo.Split TO SCM_Administrator
go
GRANT SELECT ON dbo.Gender TO SCM_Administrator
go
GRANT DELETE ON dbo.TeamSplit TO SCM_Administrator
go
GRANT INSERT ON dbo.TeamSplit TO SCM_Administrator
go
GRANT SELECT ON dbo.TeamSplit TO SCM_Administrator
go
GRANT UPDATE ON dbo.TeamSplit TO SCM_Administrator
go
GRANT DELETE ON dbo.Qualify TO SCM_Administrator
go
GRANT INSERT ON dbo.Qualify TO SCM_Administrator
go
GRANT SELECT ON dbo.Qualify TO SCM_Administrator
go
GRANT UPDATE ON dbo.Qualify TO SCM_Administrator
go
GRANT DELETE ON dbo.ContactNum TO SCM_Administrator
go
GRANT INSERT ON dbo.ContactNum TO SCM_Administrator
go
GRANT SELECT ON dbo.ContactNum TO SCM_Administrator
go
GRANT UPDATE ON dbo.ContactNum TO SCM_Administrator
go
GRANT SELECT ON dbo.ContactNumType TO SCM_Administrator
go
GRANT DELETE ON dbo.Nominee TO SCM_Administrator
go
GRANT INSERT ON dbo.Nominee TO SCM_Administrator
go
GRANT SELECT ON dbo.Nominee TO SCM_Administrator
go
GRANT UPDATE ON dbo.Nominee TO SCM_Administrator
go
GRANT SELECT ON dbo.SCMSystem TO SCM_Administrator
go
GRANT DELETE ON dbo.ScoreDivision TO SCM_Administrator
go
GRANT INSERT ON dbo.ScoreDivision TO SCM_Administrator
go
GRANT SELECT ON dbo.ScoreDivision TO SCM_Administrator
go
GRANT UPDATE ON dbo.ScoreDivision TO SCM_Administrator
go
GRANT DELETE ON dbo.ScorePoints TO SCM_Administrator
go
GRANT INSERT ON dbo.ScorePoints TO SCM_Administrator
go
GRANT SELECT ON dbo.ScorePoints TO SCM_Administrator
go
GRANT UPDATE ON dbo.ScorePoints TO SCM_Administrator
go
GRANT DELETE ON dbo.House TO SCM_Administrator
go
GRANT INSERT ON dbo.House TO SCM_Administrator
go
GRANT SELECT ON dbo.House TO SCM_Administrator
go
GRANT UPDATE ON dbo.House TO SCM_Administrator
go
GRANT EXECUTE ON dbo.ABSMemberEventPlace TO SCM_Administrator
go
GRANT EXECUTE ON dbo.RaceTimeDIFF TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SwimmerAge TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SwimmerGenderToString TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SwimTimeToString TO SCM_Administrator
go
GRANT EXECUTE ON dbo.TimeToBeat_1 TO SCM_Administrator
go
GRANT EXECUTE ON dbo.TimeToBeat_2 TO SCM_Administrator
go
GRANT EXECUTE ON dbo.TimeToBeat TO SCM_Administrator
go
GRANT EXECUTE ON dbo.PersonalBest TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SwimTimeToMilliseconds TO SCM_Administrator
go
GRANT EXECUTE ON dbo.EntrantCount TO SCM_Administrator
go
GRANT EXECUTE ON dbo.NomineeCount TO SCM_Administrator
go
GRANT EXECUTE ON dbo.HeatCount TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SessionEntrantCount TO SCM_Administrator
go
GRANT EXECUTE ON dbo.SessionNomineeCount TO SCM_Administrator
go
GRANT EXECUTE ON dbo.IsPoolShortCourse TO SCM_Administrator
go
GRANT EXECUTE ON dbo.ABSHeatPlace TO SCM_Administrator
go
GRANT EXECUTE ON dbo.RELEventPlace TO SCM_Administrator
go
GRANT EXECUTE ON dbo.RELHeatPlace TO SCM_Administrator
go
GRANT EXECUTE ON dbo.ABSEventPlace TO SCM_Administrator
go
GRANT EXECUTE ON dbo.TimeToBeat_DEFAULT TO SCM_Administrator
go

