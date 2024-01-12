unit UDBConfig;

interface

uses system.IniFiles, system.SysUtils;

type TUDBConfig = class(TObject)
private
  { private declarations }
    fDBName: string; // =SwimClubMeet
    fIsRelease: boolean; // =false
    fDescription: string; // ="v1.1.5.1 to v1.1.5.2"
    fNotes: string; // ="FINA disqualification codes."

    fBaseIn: integer;
    fVersionIn: integer;
    fMajorIn: integer;
    fMinorIn: integer;

    fBaseOut: integer;
    fVersionOut: integer;
    fMajorOut: integer;
    fMinorOut: integer;

protected
  { protected declarations }

public
  { public declarations }
  constructor Create; reintroduce;
  destructor Destroy; override;
  procedure LoadIniFile(aFileName: string);
  procedure SaveIniFile(aFileName: string);
  function GetDBConfigStr(DoInConfig: boolean): string;

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
  fBaseOut := 0;
  fVersionOut := 1;
  fMajorOut := 0;
  fMinorOut := 0;
end;

destructor TUDBConfig.Destroy;
begin
  // code
  inherited;
end;

function TUDBConfig.GetDBConfigStr(DoInConfig: boolean): string;
var
  s: string;
begin
  result := '';
  s := '';
  if DoInConfig then
  begin
    s := IntToStr(fBaseIn) + '.' + IntToStr(fVersionIn) + '.' +
      IntToStr(fMajorIn) + '.' + IntToStr(fMinorIn);
  end
  else
  begin
    s := IntToStr(fBaseOut) + '.' + IntToStr(fVersionOut) + '.' +
      IntToStr(fMajorOut) + '.' + IntToStr(fMinorOut);
  end;

  if (length(s) > 0) then result := s;
end;

procedure TUDBConfig.LoadIniFile(aFileName: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(aFileName);
  try
    fDBName := ini.ReadString('UDB', 'DatabaseName', '');
    fIsRelease := ini.ReadBool('UDB', 'IsRelease', false);
    fDescription := ini.ReadString('UDB', 'Description', '');
    fNotes := ini.ReadString('UDB', 'Notes', '');
    fBaseIn := ini.ReadInteger('UDBIN', 'Base', 1);
    fVersionIn := ini.ReadInteger('UDBIN', 'Version', 1);
    fMajorIn := ini.ReadInteger('UDBIN', 'Major', 0);
    fMinorIn := ini.ReadInteger('UDBIN', 'Minor', 0);
    fBaseOut := ini.ReadInteger('UDBOUT', 'Base', 1);
    fVersionOut := ini.ReadInteger('UDBOUT', 'Version', 1);
    fMajorOut := ini.ReadInteger('UDBOUT', 'Major', 0);
    fMinorOut := ini.ReadInteger('UDBOUT', 'Minor', 0);
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
    ini.WriteString('UDB', 'DatabaseName', fDBName);
    ini.WriteBool('UDB', 'IsRelease', fIsRelease);
    ini.WriteString('UDB', 'Description', fDescription);
    ini.WriteString('UDB', 'Notes', fNotes);
    ini.WriteInteger('UDBIN', 'Base', fBaseIn);
    ini.WriteInteger('UDBIN', 'Version', fVersionIn);
    ini.WriteInteger('UDBIN', 'Major', fMajorIn);
    ini.WriteInteger('UDBIN', 'Minor', fMinorIn);
    ini.WriteInteger('UDBOUT', 'Base', fBaseOut);
    ini.WriteInteger('UDBOUT', 'Version', fVersionOut);
    ini.WriteInteger('UDBOUT', 'Major', fMajorOut);
    ini.WriteInteger('UDBOUT', 'Minor', fMinorOut);
  finally
    ini.Free;
  end;
end;

end.
