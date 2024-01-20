unit UDBConfig;

interface

uses system.IniFiles, system.SysUtils;

type

  TUDBVersion = (udbUnknown, udbIN, udbOUT);

  TUDBConfig = class(TObject)
  private
    { private declarations }
    fDBName: string; // =SwimClubMeet
    fIsRelease: boolean; // =false
    fIsPatch: boolean;
    fPatchNum: integer;
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

    fFileName: string; // full path and filename to UDBConfig.ini

  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure LoadIniFile(aFileName: string);
    procedure SaveIniFile(aFileName: string);
    function GetVersionStr(PickVersion: TUDBVersion): string;
    function GetScriptPath():string;

    property IsRelease: boolean read fIsRelease;
    property IsPatch: boolean read fIsPatch;
    property PatchNum: integer read fPatchNum;
    property FileName: string read fFileName write fFileName;
    property BaseIN: integer read fBaseIn;
    property VersionIN: integer read fVersionIn;
    property MajorIN: integer read fMajorIn;
    property MinorIN: integer read fMinorIn;
    property Description: string read fDescription;
  end;

implementation

{ TUDBConfig }

constructor TUDBConfig.Create;
begin
  inherited;
  fIsRelease := false; // the configuration update is pre-release by default;
  fIsPatch :=  false;
  fPatchNum := 0;
  fBaseOut := 0;
  fVersionOut := 1;
  fMajorOut := 0;
  fMinorOut := 0;
  fFileName := '';
end;

destructor TUDBConfig.Destroy;
begin
  // code
  inherited;
end;

function TUDBConfig.GetScriptPath: string;
var
  s: string;
begin
  result := '';
  s := ExtractFilePath(FileName);
  s := IncludeTrailingPathDelimiter(s);
  if (Length(s) > 0) then result := s;
end;

function TUDBConfig.GetVersionStr(PickVersion: TUDBVersion): string;
var
  s: string;
begin
  result := '';
  s := '';
  case PickVersion of
    udbUnknown: s := '';
    udbIN:
    s := IntToStr(fBaseIn) + '.' + IntToStr(fVersionIn) + '.' +
      IntToStr(fMajorIn) + '.' + IntToStr(fMinorIn);
    udbOUT:
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
    fIsRelease := ini.ReadBool('UDB', 'IsRelease', False);
    fIsPatch := ini.ReadBool('UDB', 'IsPatch', False);
    fPatchNum := ini.ReadInteger('UDB', 'PatchNum', 0);
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
    ini.WriteBool('UDB', 'IsPatch', fIsPatch);
    ini.WriteInteger('UD', 'Base', fPatchNum);
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
