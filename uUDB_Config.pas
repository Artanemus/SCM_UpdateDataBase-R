unit uUDB_Config;

interface

uses system.IniFiles, system.SysUtils;

type

  TscmBuildVersion = (bvUnknown, bvIN, bvOUT);

  TUDB_Config = class(TObject)
  private
    { private declarations }
    fDBName: string; // =SwimClubMeet
    fDescription: string; // ="v1.1.5.1 to v1.1.5.2"
    fNotes: string; // MultiLine text.  \r\n ...

    fBaseIn: integer; // internal use only
    fVersionIn: integer; // depreciated
    fPatchIn: integer; // depreciated

    // RAD STUDIO VERSIONING
    fMajorIn: integer;
    fMinorIn: integer;
    fReleaseIn: integer;
    fBuildIn: integer;

    fBaseOut: integer;  // internal use only
    fVersionOut: integer; // depreciated
    fPatchOut: integer; // depreciated

    // RAD STUDIO VERSIONING
    fMajorOut: integer;
    fMinorOut: integer;
    fReleaseOut: integer;
    fBuildOut: integer;
    fFileName: string;  // full path and filename to UDBConfig.ini

  protected
    { protected declarations }
  public
    { public declarations }
    constructor Create; reintroduce;
    destructor Destroy; override;
    procedure LoadIniFile(aFileName: string);
    procedure SaveIniFile(aFileName: string);
    function GetVersionStr(PickVersion: TscmBuildVersion): string;
    function GetScriptPath():string;

    property FileName: string read fFileName write fFileName;
    property DBName: string read FDBName write FDBName;
    property Description: string read fDescription;
    property Notes: string read fNotes;

    // Base MYSQL, MSSQL, ORACLE, etc
    // Version Used by SwimClubMeet database on MSSQL
    // Major.Minor.Release.Build per RAD Studio
    // Patch number - checks build number before patching...

    //  IN --------------------------------------------------------
    property BaseIN: integer read fBaseIn;
    property VersionIN: integer read fVersionIn;
    property PatchIn: integer read fPatchIn;
    // RAD STUDIO VERSIONING
    property MajorIN: integer read fMajorIn;
    property MinorIN: integer read fMinorIn;
    property ReleaseIN: integer read fReleaseIn;
    property BuildIn: integer read fBuildIn;

    // OUT --------------------------------------------------------
    property BaseOUT: integer read fBaseOut;
    property VersionOUT: integer read fVersionOUT;
    property PatchOut: integer read fPatchOut;
    // RAD STUDIO VERSIONING
    property MajorOUT: integer read fMajorOUT;
    property MinorOUT: integer read fMinorOUT;
    property ReleaseOUT: integer read fReleaseOUT;
    property BuildOut: integer read fBuildOut;

  end;

implementation

{ TUDBConfig }

constructor TUDB_Config.Create;
begin
  inherited;
  fFileName := '';

  //  IN --------------------------------------------------------
  fPatchIn := 0;
  fBaseIn:= 0;  // internal use only - MYSQL, MSSQL, ORACLE, etc
  fVersionIn := 1; // Version Used by SwimClubMeet database on MSSQL
  // RAD STUDIO VERSIONING
  fMajorIn := 0;
  fMinorIn := 0;
  fReleaseIn := 0;
  fBuildIn := 0;

  // OUT --------------------------------------------------------
  fPatchOut := 0;
  fBaseOut := 0;  // internal use only - MYSQL, MSSQL, ORACLE, etc
  fVersionOut := 1;  // Version Used by SwimClubMeet database on MSSQL
  // RAD STUDIO VERSIONING
  fMajorOut := 0;
  fMinorOut := 0;
  fReleaseOut := 0;
  fBuildOut := 0;

end;

destructor TUDB_Config.Destroy;
begin
  // code
  inherited;
end;

function TUDB_Config.GetScriptPath: string;
var
  s: string;
begin
  result := '';
  s := ExtractFilePath(FileName);
  s := IncludeTrailingPathDelimiter(s);
  if (Length(s) > 0) then result := s;
end;

function TUDB_Config.GetVersionStr(PickVersion: TscmBuildVersion): string;
var
  s: string;
begin
  // Used by SwimClubMeet database on MSSQL
  result := '';
  s := '';
  case PickVersion of
    bvUnknown: s := '';
    bvIN:
      begin
        s := IntToStr(fBaseIn) + '.' + IntToStr(fVersionIn) + '.' +
          IntToStr(fMajorIn) + '.' + IntToStr(fMinorIn);
        if (fPatchIn > 0) then s := s + '.P' + IntToStr(fPatchIn);
      end;
    bvOUT:
      begin
        s := IntToStr(fBaseOut) + '.' + IntToStr(fVersionOut) + '.' +
          IntToStr(fMajorOut) + '.' + IntToStr(fMinorOut);
        if (fPatchOut > 0) then s := s + '.P' + IntToStr(fPatchOut);
      end;
  end;

  if (length(s) > 0) then result := s;
end;

procedure TUDB_Config.LoadIniFile(aFileName: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(aFileName);
  try
    fDBName := ini.ReadString('BUILDCONFIG', 'DatabaseName', '');
    fDescription := ini.ReadString('BUILDCONFIG', 'Description', '');
    fNotes := ini.ReadString('BUILDCONFIG', 'Notes', '');
    // Convert literal \r\n back into actual line breaks
    fNotes := fNotes.Replace('\r\n', sLineBreak);
    fNotes := fNotes.Replace('\t', #9);

    //  IN --------------------------------------------------------
    fBaseIn := ini.ReadInteger('BUILDIN', 'Base', 1);  // internal use only
    fPatchIn := ini.ReadInteger('BUILDIN', 'Patch', 0);
    fVersionIn := ini.ReadInteger('BUILDIN', 'Version', 1);
    // RAD STUDIO VERSIONING
    fMajorIn := ini.ReadInteger('BUILDIN', 'Major', 0);
    fMinorIn := ini.ReadInteger('BUILDIN', 'Minor', 0);
    fReleaseIn := ini.ReadInteger('BUILDIN', 'Release', 0);
    fBuildIn := ini.ReadInteger('BUILDIN', 'Build', 0);

    // OUT --------------------------------------------------------
    fBaseOut := ini.ReadInteger('BUILDOUT', 'Base', 1); // internal use only
    fPatchOut := ini.ReadInteger('BUILDOUT', 'Patch', 0);
    fVersionOut := ini.ReadInteger('BUILDOUT', 'Version', 1);
    // RAD STUDIO VERSIONING
    fMajorOut := ini.ReadInteger('BUILDOUT', 'Major', 0);
    fMinorOut := ini.ReadInteger('BUILDOUT', 'Minor', 0);
    fReleaseOut := ini.ReadInteger('BUILDOUT', 'Release', 0);
    fBuildOut := ini.ReadInteger('BUILDOUT', 'Build', 0);

  finally
    ini.Free;
  end;
end;

procedure TUDB_Config.SaveIniFile(aFileName: string);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(aFileName);
  try
    ini.WriteString('BUILDCONFIG', 'DatabaseName', fDBName);
    ini.WriteString('BUILDCONFIG', 'Description', fDescription);

    // Convert actual line breaks to literal \r\n
    fNotes := fNotes.Replace(sLineBreak, '\r\n');
    fNotes := fNotes.Replace(#9, '\t');
    ini.WriteString('BUILDCONFIG', 'Notes', fNotes);

    //  IN --------------------------------------------------------
    ini.WriteInteger('BUILDIN', 'Base', fBaseIn);   // internal use only
    ini.WriteInteger('BUILDIN', 'Patch', fPatchIn);
    ini.WriteInteger('BUILDIN', 'Version', fVersionIn);
    // RAD STUDIO VERSIONING
    ini.WriteInteger('BUILDIN', 'Major', fMajorIn);
    ini.WriteInteger('BUILDIN', 'Minor', fMinorIn);
    ini.WriteInteger('BUILDIN', 'Release', fReleaseIn);
    ini.WriteInteger('BUILDIN', 'Build', fBuildIn);

    // OUT --------------------------------------------------------
    ini.WriteInteger('BUILDOUT', 'Base', fBaseOut);  // internal use only
    ini.WriteInteger('BUILDOUT', 'Patch', fPatchOut);
    ini.WriteInteger('BUILDOUT', 'Version', fVersionOut);
    // RAD STUDIO VERSIONING
    ini.WriteInteger('BUILDOUT', 'Major', fMajorOut);
    ini.WriteInteger('BUILDOUT', 'Minor', fMinorOut);
    ini.WriteInteger('BUILDOUT', 'Release', fReleaseOut);
    ini.WriteInteger('BUILDOUT', 'Build', fBuildOut);

  finally
    ini.Free;
  end;
end;

end.
