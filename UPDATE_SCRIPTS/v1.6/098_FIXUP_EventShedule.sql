USE [SwimClubMeet]
go

-- Drop Referencing Constraint SQL

ALTER TABLE dbo.Nominee DROP CONSTRAINT FK_Event_Nominee
go
ALTER TABLE dbo.HeatIndividual DROP CONSTRAINT FK_Event_HeatIndividual
go
ALTER TABLE dbo.HeatTeam DROP CONSTRAINT FK_Event_HeatTeam
go

-- Drop Constraint, Rename and Create Table SQL

EXEC sp_rename 'dbo.Event.PK_Event','PK_Event_01172023031745001','INDEX'
go
EXEC sp_rename 'dbo.FK_Session_Event','FK_Session_01172023031745002'
go
EXEC sp_rename 'dbo.FK_EventType_Event','FK_EventTy_01172023031745003'
go
EXEC sp_rename 'dbo.FK_Stroke_Event','FK_Stroke__01172023031745004'
go
EXEC sp_rename 'dbo.FK_Distance_Event','FK_Distanc_01172023031745005'
go
EXEC sp_rename 'dbo.FK_EventStatus_Event','FK_EventSt_01172023031745006'
go
EXEC sp_rename 'dbo.Event','Event_01172023031745000',OBJECT
go
CREATE TABLE dbo.Event
(
    EventID       int            IDENTITY,
    EventNum      int            NULL,
    Caption       nvarchar(128)  NULL,
    ClosedDT      datetime       NULL,
    SessionID     int            NULL,
    EventTypeID   int            NULL,
    StrokeID      int            NULL,
    DistanceID    int            NULL,
    EventStatusID int            NULL,
    ScheduleDT    time(7)        NULL
)
ON [PRIMARY]
go
GRANT DELETE ON dbo.Event TO SCM_Administrator
go
GRANT INSERT ON dbo.Event TO SCM_Administrator
go
GRANT SELECT ON dbo.Event TO SCM_Administrator
go
GRANT UPDATE ON dbo.Event TO SCM_Administrator
go
GRANT SELECT ON dbo.Event TO SCM_Guest
go
GRANT SELECT ON dbo.Event TO SCM_Marshall
go

-- Insert Data SQL

SET IDENTITY_INSERT dbo.Event ON
go
INSERT INTO dbo.Event(
                      EventID,
                      EventNum,
                      Caption,
                      ClosedDT,
                      SessionID,
                      EventTypeID,
                      StrokeID,
                      DistanceID,
                      EventStatusID
--                    ScheduleDT,
                     )
               SELECT 
                      EventID,
                      EventNum,
                      Caption,
                      ClosedDT,
                      SessionID,
                      EventTypeID,
                      StrokeID,
                      DistanceID,
                      EventStatusID
--                    CONVERT(time,ScheduleDT),
                 FROM dbo.Event_01172023031745000 
go
SET IDENTITY_INSERT dbo.Event OFF
go

-- Add Constraint SQL

ALTER TABLE dbo.Event ADD CONSTRAINT PK_Event
PRIMARY KEY NONCLUSTERED (EventID)
go

-- Add Referencing Foreign Keys SQL

ALTER TABLE dbo.Nominee ADD CONSTRAINT FK_Event_Nominee
FOREIGN KEY (EventID)
REFERENCES dbo.Event (EventID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.HeatIndividual ADD CONSTRAINT FK_Event_HeatIndividual
FOREIGN KEY (EventID)
REFERENCES dbo.Event (EventID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.HeatTeam ADD CONSTRAINT FK_Event_HeatTeam
FOREIGN KEY (EventID)
REFERENCES dbo.Event (EventID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.Event ADD CONSTRAINT FK_Session_Event
FOREIGN KEY (SessionID)
REFERENCES dbo.[Session] (SessionID)
 ON DELETE CASCADE
go
ALTER TABLE dbo.Event ADD CONSTRAINT FK_EventType_Event
FOREIGN KEY (EventTypeID)
REFERENCES dbo.EventType (EventTypeID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Event ADD CONSTRAINT FK_Stroke_Event
FOREIGN KEY (StrokeID)
REFERENCES dbo.Stroke (StrokeID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Event ADD CONSTRAINT FK_Distance_Event
FOREIGN KEY (DistanceID)
REFERENCES dbo.Distance (DistanceID)
 ON DELETE SET NULL
go
ALTER TABLE dbo.Event ADD CONSTRAINT FK_EventStatus_Event
FOREIGN KEY (EventStatusID)
REFERENCES dbo.EventStatus (EventStatusID)
 ON DELETE SET NULL
go
