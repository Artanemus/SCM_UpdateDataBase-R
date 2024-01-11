unit UDBConfig;

interface

uses system.IniFiles;

type TUDBConfig = class(TObject)
private
  { private declarations }
  fDBName: string; // =SwimClubMeet
  fOriginalDB: string; //="v1.1.5.1"
  fUpdatedDB: string; //="v1.1.5.2"
  fIsRelease: boolean; //=false
  fDescription: string; //="v1.1.5.1 to v1.1.5.2"
  fNotes: string; //="FINA disqualification codes."
  fBase: integer; //=1
  fVersion: integer; //=1
  fMajor: integer; //=5
  fMinor: integer; //=2
protected
  { protected declarations }
public
  { public declarations }
  constructor Create; reintroduce;
  destructor Destroy; override;
  procedure LoadIniFile(aFileName: string);
  procedure SaveIniFile(aFileName: string);

  property OriginalDB: string read FOriginalDB;
  property UpdatedDB: string read fUpdatedDB;
  property IsRelease: boolean read fIsRelease;

published
  { published declarations }


end;

implementation

{ TUDBConfig }

constructor TUDBConfig.Create;
begin
  inherited;
  fIsRelease := false; // the configuration update is pre-release by default;
  fBase := 1;
  fVersion := 1;
  fMajor := 0;
  fMinor := 0;
end;

destructor TUDBConfig.Destroy;
begin
  // code
  inherited;
end;

procedure TUDBConfig.LoadIniFile(aFileName: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(aFileName);
  try
    fDBName := ini.ReadString('UDB', 'DBName', '');
    fOriginalDB := ini.ReadString('UDB', 'OriginalDB', '');
    fUpdatedDB := ini.ReadString('UDB', 'UpdatedDB', '');
    fIsRelease := ini.ReadBool('UDB', 'IsRelease', false);
    fDescription := ini.ReadString('UDB', 'Description', '');
    fNotes := ini.ReadString('UDB', 'Notes', '');
    fBase := ini.ReadInteger('UDB', 'Base', 1);
    fVersion := ini.ReadInteger('UDB', 'Version', 1);
    fMajor := ini.ReadInteger('UDB', 'Major', 0);
    fMinor := ini.ReadInteger('UDB', 'Minor', 0);
  finally
    ini.Free;
  end;
end;

procedure TUDBConfig.SaveIniFile(aFileName: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(aFileName);
  try
    ini.WriteString('UDB', 'DBName', fDBName);
    ini.WriteString('UDB', 'OriginalDB', fOriginalDB);
    ini.WriteString('UDB', 'UpdatedDB', fUpdatedDB);
    ini.WriteBool('UDB', 'IsRelease', fIsRelease);
    ini.WriteString('UDB', 'Description', fDescription);
    ini.WriteString('UDB', 'Notes', fNotes);
    ini.WriteInteger('UDB', 'Base', fBase);
    ini.WriteInteger('UDB', 'Version', fVersion);
    ini.WriteInteger('UDB', 'Major', fMajor);
    ini.WriteInteger('UDB', 'Minor', fMinor);
  finally
    ini.Free;
  end;
end;

end.
