unit frmSCMUpdateDataBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls,
  FireDAC.Stan.Intf, FireDAC.Stan.Option, FireDAC.Stan.Error, FireDAC.UI.Intf,
  FireDAC.Phys.Intf, FireDAC.Stan.Def, FireDAC.Stan.Pool, FireDAC.Stan.Async,
  FireDAC.Phys, FireDAC.VCLUI.Wait, Data.DB, FireDAC.Comp.Client,
  FireDAC.Stan.Param, FireDAC.DatS, FireDAC.DApt.Intf, FireDAC.DApt,
  FireDAC.Comp.DataSet, FireDAC.Phys.MSSQL, FireDAC.Phys.MSSQLDef, Vcl.ComCtrls,
  System.Actions, Vcl.ActnList, Vcl.BaseImageCollection, Vcl.ImageCollection,
  Vcl.VirtualImage;

type
  TSCMUpdateDataBase = class(TForm)
    Panel1: TPanel;
    btnUDB: TButton;
    Panel2: TPanel;
    Panel3: TPanel;
    Memo1: TMemo;
    Label5: TLabel;
    Image2: TImage;
    btnCancel: TButton;
    scmConnection: TFDConnection;
    qryVersion: TFDQuery;
    progressBar: TProgressBar;
    ActionList1: TActionList;
    actnConnect: TAction;
    actnDisconnect: TAction;
    actnUDB: TAction;
    GroupBox1: TGroupBox;
    Label1: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    btnConnect: TButton;
    btnDisconnect: TButton;
    chkbUseOSAuthentication: TCheckBox;
    edtPassword: TEdit;
    edtServerName: TEdit;
    edtUser: TEdit;
    Panel4: TPanel;
    qryDBExists: TFDQuery;
    VirtualImage1: TVirtualImage;
    ImageCollection1: TImageCollection;
    procedure actnConnectExecute(Sender: TObject);
    procedure actnConnectUpdate(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure actnDisconnectExecute(Sender: TObject);
    procedure actnDisconnectUpdate(Sender: TObject);
    procedure actnUDBExecute(Sender: TObject);
    procedure actnUDBUpdate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);

  private const
    SCMCONFIGFILENAME = 'SCMConfig.ini';

  private
    { Private declarations }
    FDBVersion: Integer;
    FDBMajor: Integer;
    FDBMinor: Integer;
    FSQLPath: String;

    // Flags that building is finalised or can't proceed.
    // Once set - btnUDB is not long visible. User may only exit.
    BuildDone: Boolean;

    function ExecuteProcess(const FileName, Params: string; Folder: string;
      WaitUntilTerminated, WaitUntilIdle, RunMinimized: Boolean;
      var ErrorCode: Integer): Boolean;

    function ExecuteProcessSQLcmd(SQLFile, ServerName, UserName,
      Password: String; var errCode: Integer; UseOSAthent: Boolean = true;
      RunMinimized: Boolean = false; Log: Boolean = false): Boolean;

    function CheckVersionControl(var SQLPath: string): Boolean;
    function CheckVersion(): Boolean;

    procedure GetFileList(filePath, fileMask: String; var sl: TStringList);
    procedure GetSCM_DB_Version(var DBVersion, Major, Minor: Integer);
    procedure LoadConfigData;
    procedure SaveConfigData;

    procedure SimpleLoadSettingString(Section, Name: String; var Value: String);
    procedure SimpleSaveSettingString(Section, Name, Value: String);
    procedure SimpleMakeTemporyFDConnection(Server, User, Password: String;
      OsAuthent: Boolean);

    procedure ExecuteProcessScripts(var SQLPath: string);

  public
    { Public declarations }
  end;

var
  SCMUpdateDataBase: TSCMUpdateDataBase;

const
  logOutFn = '\Documents\SCM_UpdateDataBase.log';
  SectionName = 'SCM_UpdateDataBase';
  logOutFnTmp = '\Documents\SCM_UpdateDataBase.tmp';
  defUpdateScriptsPath = 'UPDATE_SCRIPTS\v1.5.1\';
implementation

uses System.IOUtils, System.Types, System.IniFiles,
  System.UITypes, utilVersion;

{$R *.dfm}

function TSCMUpdateDataBase.ExecuteProcess(const FileName, Params: string;
  Folder: string; WaitUntilTerminated, WaitUntilIdle, RunMinimized: Boolean;
  var ErrorCode: Integer): Boolean;
var
  CmdLine: string;
  WorkingDirP: PChar;
  StartupInfo: TStartupInfo;
  ProcessInfo: TProcessInformation;
begin
  Result := true;
  CmdLine := '"' + FileName + '" ' + Params;
  if Folder = '' then
    Folder := ExcludeTrailingPathDelimiter(ExtractFilePath(FileName));
  ZeroMemory(@StartupInfo, SizeOf(StartupInfo));
  StartupInfo.cb := SizeOf(StartupInfo);
  if RunMinimized then
  begin
    StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
    StartupInfo.wShowWindow := SW_SHOWMINIMIZED;
  end;
  if Folder <> '' then
    WorkingDirP := PChar(Folder)
  else
    WorkingDirP := nil;
  if not CreateProcess(nil, PChar(CmdLine), nil, nil, false, 0, nil,
    WorkingDirP, StartupInfo, ProcessInfo) then
  begin
    Result := false;
    ErrorCode := GetLastError;
    exit;
  end;
  with ProcessInfo do
  begin
    CloseHandle(hThread); // CHECK - CLOSE HERE? or move line down?
    if WaitUntilIdle then
      WaitForInputIdle(hProcess, INFINITE);
    // CHECK ::WaitUntilTerminated was used in C++ sqlcmd.exe
    if WaitUntilTerminated then
      repeat
        Application.ProcessMessages;
      until MsgWaitForMultipleObjects(1, hProcess, false, INFINITE, QS_ALLINPUT)
        <> WAIT_OBJECT_0 + 1;
    CloseHandle(hProcess);
    // CHECK :: CloseHandle(hThread); was originally placed here in C++ ...
  end;
end;

procedure TSCMUpdateDataBase.ExecuteProcessScripts(var SQLPath: string);
var
sl: TStringList;
s, Str, fp, fn: String;
mr: TModalResult;
errCount, errCode: integer;
success: boolean;
begin
  // Look for SQL file to execute ...
  sl := TStringList.Create;
  GetFileList(FSQLPath, '*.SQL', sl);
  sl.Sort; // Perform an ANSI sort

  // Are there SQL files in this directory?
  if sl.Count = 0 then
  begin
    s := 'No build scripts to run!' + sLineBreak + 'READY ...';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // update button remains visible - try again ....
    btnUDB.Visible := true;
    FreeAndNil(sl);
    Memo1.Lines.Add(s);
    exit;
  end;

  // Final message before running update
  s := 'Found ' + IntToStr(sl.Count) + ' scripts to run.' + sLineBreak +
    'Select yes to update your swimming club database.';
  mr := MessageDlg(s, TMsgDlgType.mtConfirmation, [mbNo, mbYes], 0);

  Memo1.Lines.Add('Found ' + IntToStr(sl.Count) + ' scripts to run.');
  if mr = mrYes then
  begin
    progressBar.Visible := true;
    progressBar.Max := sl.Count;
    errCount := 0;
    // echo message in memopad
    Memo1.Lines.Add('Found ' + IntToStr(sl.Count) + ' scripts to run.');
    Str := GetEnvironmentVariable('USERPROFILE') + logOutFn;
    Memo1.Lines.Add('Sending log to ' + Str + sLineBreak);

    // clear the log file
    if FileExists(Str) then
      DeleteFile(Str);

    for fp in sl do
    begin
      // get filename ...
      fn := ExtractFileName(fp);
      // display the info and break
      Memo1.Lines.Add(fn);

      // *******************************************************************
      // SQL file, servername, rtn errCode, run silent, create log file ...
      // -------------------------------------------------------------------
      success := ExecuteProcessSQLcmd(fp, edtServerName.Text, edtUser.Text,
        edtPassword.Text, errCode, chkbUseOSAuthentication.Checked, true, true);
      // *******************************************************************

      if not success then
      begin
        errCount := errCount + 1;
        Memo1.Lines.Add('Error: ' + IntToStr(errCode) + fn);
      end;

      progressBar.Position := progressBar.Position + 1;
    end;
    Memo1.Lines.Add(sLineBreak + 'FINISHED');
    if errCount = 0 then
    begin
      Memo1.Lines.Add('ExecuteProcess completed without errors.' + sLineBreak);
      Memo1.Lines.Add
        ('You should check SCM_UpdateDataBase.log to ensure that sqlcmd.exe also reported no errors.'
        + sLineBreak);
      // * Version number of SwimClubMeet DataBase *
      // Only read this table if not errors reported.
      GetSCM_DB_Version(FDBVersion, FDBMajor, FDBMinor);
      s := 'SwimClubMeet database build info ... Version: ' +
        IntToStr(FDBVersion) + '.' + IntToStr(FDBMajor) + '.' +
        IntToStr(FDBMinor);
      Memo1.Lines.Add(s);
    end
    else
    begin
      Memo1.Lines.Add('ExecuteProcess reported: ' + IntToStr(errCount) +
        ' errors.' + sLineBreak);
      Memo1.Lines.Add('View the SCM_UpdateDataBase.log for sqlcmd.exe errors.' +
        sLineBreak);
    end;
    // only one shot at building granted
    btnUDB.Visible := false;
    BuildDone := true;
    progressBar.Visible := false;

    // finished with database - do a disconnect? (But it hides the Memo1 cntrl)
    Memo1.Lines.Add(sLineBreak +
      'UpdateDataBase has completed. Press EXIT when ready.');
  end
  else
    // we had scripts ... but user didn't do a build
    btnUDB.Visible := true;

  FreeAndNil(sl);

end;

function TSCMUpdateDataBase.ExecuteProcessSQLcmd(SQLFile, ServerName, UserName,
  Password: String; var errCode: Integer; UseOSAthent: Boolean;
  RunMinimized: Boolean; Log: Boolean): Boolean;
var
  Param: String;
  logOutFile, logOutFileTmp, quotedSQLFile: String;
  passed: Boolean;

  Str: string;
  F1, F2: TextFile;

begin
  // initialise as failed
  Result := false;
  errCode := 0;

  // the string isn't empty
  if SQLFile.IsEmpty then
    exit;

  quotedSQLFile := AnsiQuotedStr(SQLFile, '"');
  {
    NOTE: -S [protocol:]server[instance_name][,port]
    NOTE: -E is not specified because it is the default and sqlcmd
    connects to the default instance by using Windows Authentication.
    TODO: include name and password authentication.
    NOTE: -i input file
    NOTE: -V (uppercase V)  error_severity_level. Any error above value
    will be reported
  }

  // ServerName ...
  Param := '-S ' + ServerName;
  if UseOSAthent then
    // using windows OS Authentication
    Param := Param + ' -E '
  else
    // UserName and Password
    Param := Param + ' -U ' + UserName + ' -P ' + Password;
  // input file
  Param := Param + ' -i ' + quotedSQLFile + ' ';

  if Log then
  begin
    Str := GetEnvironmentVariable('USERPROFILE');
    logOutFile := Str + logOutFn;
    logOutFileTmp := Str + logOutFnTmp;
    // ENSURE an ouput file exist else the PIPE redirection won't work.
    if not FileExists(logOutFile) then
    begin
      AssignFile(F2, logOutFile);
      // create a header string with some useful info.
      Str := 'SwimClubMeet BuildMeAClub log file ' +
        FormatDateTime('dd/mmmm/yyyy hh:nn', Now);
      Rewrite(F2);
      Writeln(F2, Str);
      CloseFile(F2);
    end;
    // ... surround output file in quotes
    quotedSQLFile := AnsiQuotedStr(logOutFileTmp, '"');
    Param := Param + ' -o ' + quotedSQLFile + ' ';
    // DRATS!!!! NOT WORKING :-(
    // NOTE: Last in param list - PIPE - APPEND TO EXISTING FILE.
    // Param := Param + ' >> ' + logOutFileTmp + ' ';
  end;

  // ---------------------------------------------------------------
  // Folder param(3) not required. Wait until process is completed.
  // ---------------------------------------------------------------
  passed := ExecuteProcess('sqlcmd.exe', Param, '', true, true,
    RunMinimized, errCode);

  if (Log) then
  begin
    if (FileExists(logOutFileTmp) = true) and (FileExists(logOutFile) = true)
    then
    begin
      AssignFile(F1, logOutFileTmp);
      AssignFile(F2, logOutFile);
      Reset(F1);
      Append(F2);

      while not(EOF(F1)) do
      begin
        Readln(F1, Str);
        Writeln(F2, Str);
      end;
      CloseFile(F1);
      CloseFile(F2);
      DeleteFile(logOutFileTmp);
    end;
  end;

  if passed then
    Result := true; // flag success

end;

procedure TSCMUpdateDataBase.FormCreate(Sender: TObject);
begin
  BuildDone := false; // clear BMAC critical error flag
  // Display the Major.Minor.Release.Build version details
  Caption := 'SCM UpdateDataBase Version ' + utilVersion.FileVersion;
  // Prepare the display
  GroupBox1.Visible := true;
  btnConnect.Visible := true;
  progressBar.Visible := false;
  btnUDB.Visible := false;
  btnDisconnect.Visible := false;
  LoadConfigData;
  // Memo already populated with useful user info... indicate ready...
  Memo1.Lines.Add('READY ...');
  // init DB version control
  FDBVersion := 0;
  FDBMajor := 0;
  FDBMinor := 0;
end;

procedure TSCMUpdateDataBase.GetFileList(filePath, fileMask: String;
  var sl: TStringList);
var
  searchOption: TSearchOption;
  List: TStringDynArray;
  fn: String;
begin
  searchOption := TSearchOption.soTopDirectoryOnly;
  try
    List := TDirectory.GetFiles(filePath, fileMask, searchOption);
  except
    // Not expecting errors as the filePath has been asserted.
    // Catch unexpected exceptions.
    on E: Exception do
    begin
      MessageDlg('Incorrect path or search mask', mtError, [mbOk], 0);
      exit;
    end
  end;
  // * Populate the stringlist with matching filenames
  sl.Clear();
  for fn in List do
    sl.Add(fn);
end;

procedure TSCMUpdateDataBase.GetSCM_DB_Version(var DBVersion, Major,
  Minor: Integer);
var
  fld: TField;
begin
  DBVersion := 0;
  Major := 0;
  Minor := 0;
  if scmConnection.Connected then
  begin
    // opening and closing a query performs a full refresh.
    qryVersion.Close;
    qryVersion.Open;
    if qryVersion.Active then
    begin
      DBVersion := qryVersion.FieldByName('DBVersion').AsInteger;
      fld := qryVersion.FieldByName('Major');
      if Assigned(fld) then
      begin
        Major := fld.AsInteger;
      end;
      fld := qryVersion.FieldByName('Minor');
      if Assigned(fld) then
      begin
        Minor := fld.AsInteger;
      end;
    end;
  end;

end;

{$REGION 'SIMPLE LOAD ROUTINES FOR TEMPORY FDAC CONNECTION'}

procedure TSCMUpdateDataBase.LoadConfigData;
var
  Section: string;
  Server: string;
  User: string;
  Password: string;
  Value: string;

begin
  Section := SectionName;
  Name := 'Server';
  SimpleLoadSettingString(Section, Name, Server);
  if Server.IsEmpty then
    edtServerName.Text := 'localHost\SQLEXPRESS'
  else
    edtServerName.Text := Server;
  Name := 'User';
  SimpleLoadSettingString(Section, Name, User);
  edtUser.Text := User;
  Name := 'Password';
  SimpleLoadSettingString(Section, Name, Password);
  edtPassword.Text := Password;
  Name := 'OSAuthent';
  SimpleLoadSettingString(Section, Name, Value);
  if (Pos('y', Value) <> 0) or (Pos('Y', Value) <> 0) then
    chkbUseOSAuthentication.Checked := true
  else
    chkbUseOSAuthentication.Checked := false;
end;

procedure TSCMUpdateDataBase.SaveConfigData;
var
  Section, Name, Value: String;
begin
  begin
    Section := SectionName;
    Name := 'Server';
    SimpleSaveSettingString(Section, Name, edtServerName.Text);
    Name := 'User';
    SimpleSaveSettingString(Section, Name, edtUser.Text);
    Name := 'Password';
    SimpleSaveSettingString(Section, Name, edtPassword.Text);
    Name := 'OSAuthent';
    if chkbUseOSAuthentication.Checked = true then
      Value := 'Yes'
    else
      Value := 'No';
    SimpleSaveSettingString(Section, Name, Value);
  end

end;

procedure TSCMUpdateDataBase.SimpleLoadSettingString(Section, Name: String;
  var Value: String);
var
  ini: TIniFile;
begin
  // Note: OneDrive enabled: 'Personal'
  // The routine TPath.GetDocumentsPath normally returns ...
  // C:\Users\<username>\Documents (Windows Vista or later)
  // but is instead mapped to C:\Users\<username>\OneDrive\Documents.
  //
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim +
    SCMCONFIGFILENAME);
  try
    Value := ini.ReadString(Section, Name, '');
  finally
    ini.Free;
  end;
end;

procedure TSCMUpdateDataBase.SimpleMakeTemporyFDConnection(Server, User,
  Password: String; OsAuthent: Boolean);
var
  Value: String;
begin

  if Server.IsEmpty then
    exit;

  if not OsAuthent then
    if User.IsEmpty then
      exit;

  if (scmConnection.Connected) then
    scmConnection.Connected := false;

  scmConnection.Params.Clear();
  scmConnection.Params.Add('Server=' + Server);
  scmConnection.Params.Add('DriverID=MSSQL');
  // NOTE ASSUMPTION :: SwimClubMeet EXISTS.
  scmConnection.Params.Add('Database=SwimClubMeet');
  scmConnection.Params.Add('User_name=' + User);
  scmConnection.Params.Add('Password=' + Password);
  if OsAuthent then
    Value := 'Yes'
  else
    Value := 'No';
  scmConnection.Params.Add('OSAuthent=' + Value);
  scmConnection.Params.Add('Mars=yes');
  scmConnection.Params.Add('MetaDefSchema=dbo');
  scmConnection.Params.Add('ExtendedMetadata=False');
  scmConnection.Params.Add('ApplicationName=SCM_UpdateDataBase');
  scmConnection.Connected := true;

  // ON SUCCESS - Save connection details.
  if scmConnection.Connected Then
    SaveConfigData;
end;

function TSCMUpdateDataBase.CheckVersion: Boolean;
begin
  Result := false;
  if (FDBVersion = 1) AND (FDBMajor = 5) AND (FDBMinor = 0) then
    Result := true;
end;

function TSCMUpdateDataBase.CheckVersionControl(var SQLPath: string): Boolean;
var
  s, s2: string;
  slv: TStringList;
  i, version, Major, Minor: Integer;
begin
  // Look for version control. Is the update permitted?
  // TODO: add additional params to tighten params
  Result := false;
  version := 0;
  Major := 0;
  Minor := 0;

  if FDBVersion > 0 then
  begin

    // in this build - version control should read 1,1,5,1

    s := SQLPath + 'SCM_VersionControl.txt';
    s2 := '';
    if FileExists(s) then
    begin
      slv := TStringList.Create;
      slv.LoadFromFile(s);

      // VERSION ...
      i := slv.IndexOfName('Version');
      if i <> -1 then
      begin
        s := slv.ValueFromIndex[i];
        s2 := s2 + 'V' + s;
        version := StrToIntDef(s, 0);
      end;

      // Major ...
      i := slv.IndexOfName('Major');
      if i <> -1 then
      begin
        s := slv.ValueFromIndex[i];
        s2 := s2 + '.' + s;
        Major := StrToIntDef(s, 0);
      end;

      // Minor ...
      i := slv.IndexOfName('Minor');
      if i <> -1 then
      begin
        s := slv.ValueFromIndex[i];
        s2 := s2 + '.' + s;
        Minor := StrToIntDef(s, 0);
      end;

      s2 := 'V' + IntToStr(FDBVersion) + '.' + IntToStr(FDBMajor) + '.' +
        IntToStr(FDBMinor) + ' >>> ' + s2;
      Memo1.Lines.Add('Version control reported: ' + s2);

      // version number must equate.
      if version = FDBVersion then
      begin
        // IF MAJORS EQUATE ....
        if Major = FDBMajor then
        begin
          // minor must be equal or greater.
          if Minor >= FDBMinor then
          begin
            Result := true;
          end
        end
        // Pass if exceeds FBMajor - don't care about minor.
        else if Major > FDBMajor then
          Result := true;
      end;

      FreeAndNil(slv);
    end;
  end;
end;

procedure TSCMUpdateDataBase.SimpleSaveSettingString(Section, Name,
  Value: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim +
    SCMCONFIGFILENAME);
  try
    ini.WriteString(Section, Name, Value);
  finally
    ini.Free;
  end;

end;

{$ENDREGION}

procedure TSCMUpdateDataBase.btnCancelClick(Sender: TObject);
begin
  scmConnection.Close;
  ModalResult := mrCancel;
  Close;
end;

procedure TSCMUpdateDataBase.actnConnectExecute(Sender: TObject);
var
  Str: string;
begin
  // TODO : do we have the text inputted to make a connection?
  if edtServerName.Text = '' then
  begin
    Beep;
    exit;
  end;

  if not chkbUseOSAuthentication.Checked then
    if edtUser.Text = '' then
    begin
      Beep;
      exit;
    end;

  // attempt a 'simple' connection to SQLEXPRESS
  // read SCM DB version
  SimpleMakeTemporyFDConnection(edtServerName.Text, edtUser.Text,
    edtPassword.Text, chkbUseOSAuthentication.Checked);
  if scmConnection.Connected then
  begin
    Memo1.Clear;
    Memo1.Lines.Add('Connected to SwimClubMeet on MSSQL' + sLineBreak);
    // * Version number of SwimClubMeet DataBase *
    GetSCM_DB_Version(FDBVersion, FDBMajor, FDBMinor);
    Str := 'Version: ' + IntToStr(FDBVersion) + '.' + IntToStr(FDBMajor) + '.' +
      IntToStr(FDBMinor);
    Memo1.Lines.Add('Reading SwimClubMeet internal database info ' + Str +
      sLineBreak);
    Memo1.Lines.Add('ALWAYS backup your database before performing an update!' +
      sLineBreak);
    if not BuildDone then
      Memo1.Lines.Add('READY ... Press ''Update DataBase'' to continue.')
    else
      Memo1.Lines.Add('READY ...');
  end;
  // Call to action is required: update button state.
  actnDisconnectUpdate(self);
end;

procedure TSCMUpdateDataBase.actnConnectUpdate(Sender: TObject);
begin
  // update TCONTROL visibility
  if scmConnection.Connected then
  begin
    btnConnect.Visible := false;
    btnUDB.Visible := true; // when connected ... updating permitted.
  end
  else
  begin
    btnConnect.Visible := true;
  end;
  if BuildDone then // only one build per application running
    btnUDB.Visible := false;
end;

procedure TSCMUpdateDataBase.actnDisconnectExecute(Sender: TObject);
begin
  // disconnect
  scmConnection.Close;
  Memo1.Clear;
  Memo1.Lines.Add('Disconnected ...' + sLineBreak);
  // REQUIRED: update button state.
  actnConnectUpdate(self);
end;

procedure TSCMUpdateDataBase.actnDisconnectUpdate(Sender: TObject);
begin
  // update TCONTROL visibility
  if scmConnection.Connected then
  begin
    btnDisconnect.Visible := true;
  end
  else
  begin
    btnDisconnect.Visible := false;
    btnUDB.Visible := false; // no connection ... no updating.
  end;
  if BuildDone then // only one build per application running
    btnUDB.Visible := false;
end;

procedure TSCMUpdateDataBase.actnUDBUpdate(Sender: TObject);
begin
  if BuildDone then // only one build per application running
    btnUDB.Visible := false;
end;

procedure TSCMUpdateDataBase.actnUDBExecute(Sender: TObject);
var
  s, FDir: String;
  errCount, errCode: Integer;
  mr: TModalResult;
  success: Boolean;
begin
  // UPDATE THE DATABASE...
  progressBar.Position := 0;
  progressBar.Min := 0;
  btnUDB.Visible := false;
  Memo1.Clear;

  if not scmConnection.Connected then
    exit;

  // ---------------------------------------------------------------
  // Does the SwimClubMeet database already exists on MS SQLEXPRESS?
  // ---------------------------------------------------------------
  qryDBExists.Open;
  if qryDBExists.Active then
  begin
    errCount := qryDBExists.FieldByName('Result').AsInteger;
    qryDBExists.Close;
    // non zero value indicates SwimClubMeet already exists.
    if not(errCount = 1) then
    begin
      // SwimClubMeet doesn't exists!
      s := 'Unexpected error!' + sLineBreak +
        'The SwimClubMeet database must exists!' + sLineBreak +
        'Press EXIT when ready.';
      MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
      // only one shot at building granted
      btnUDB.Visible := false;
      BuildDone := true;
      Memo1.Lines.Add(s);
      exit;
    end;

  end;

  success := ExecuteProcess('sqlcmd.exe', '-?', '', true, true, true, errCode);

  if not success then
  begin
    s := 'The application ''sqlcmd.exe'' wasn''t found!' + sLineBreak +
      'The MS SQLEXPRESS utility is missing.' + sLineBreak +
      'Press EXIT when ready.';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // only one shot at building granted
    btnUDB.Visible := false;
    BuildDone := true;
    Memo1.Lines.Add(s);
    exit;
  end;

  FSQLPath := ExtractFilePath(Application.ExeName) + defUpdateScriptsPath;
  if TDirectory.Exists(FSQLPath) then
  begin
    s := 'The default folder ' + defUpdateScriptsPath + ' was found.' +
      sLineBreak + 'Select yes to continue or no to locate another folder.';
    mr := MessageDlg(s, TMsgDlgType.mtConfirmation, [mbNo, mbYes], 0, mbYes);
    Memo1.Lines.Add('Running ' + defUpdateScriptsPath);
    if (mr = mrYes) then
    begin
      if CheckVersion then
      begin
        ExecuteProcessScripts(FSQLPath);
        s := 'Press EXIT when ready.';
      end
      else
      begin
        // wanted version 1,1,5,0
        s := 'The current version of the database cant''t be' + sLineBreak +
          'updated with the supplied SQL scripts.' + sLineBreak +
          'Press EXIT when ready.';
        MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
      end;

      btnUDB.Visible := false;
      BuildDone := true;
      Memo1.Lines.Add(s);
      exit;

    end;
  end;

  // ----------------------------------------------------------------
  // LET THE USER LOCATE A FOLDER WITH SQL SCRIPTS
  // AND VERSION CONTROL TEXT FILE
  // ----------------------------------------------------------------
  // DEFAULT STARTING DIRECTORY
  FDir := GetEnvironmentVariable('USERPROFILE') + '\Documents\';
  FSQLPath := '';

  // DEPRECIATED : Only Vista and above can run TFileOpenDialog
  // if Win32MajorVersion >= 6 then

  // PROMPT USER TO SELECT A FOLDER CONTAINING SCRIPTS FOR UPDATE
  // NOTE: doesn't return trailing path delimeter
  with TFileOpenDialog.Create(nil) do
    try
      Title := 'Select SCM Update Folder ...';
      Options := [fdoPickFolders, fdoPathMustExist, fdoForceFileSystem];
      // YMMV
      OkButtonLabel := 'Select';
      DefaultFolder := FDir;
      FileName := FDir;
      if Execute then
        FSQLPath := FileName;
    finally
      Free;
    end;

  if FSQLPath.IsEmpty then
  begin
    // user aborted + permit retry
    btnUDB.Visible := true;
    Memo1.Clear;
    Memo1.Lines.Add('READY ...');
    exit;
  end;

  FSQLPath := IncludeTrailingPathDelimiter(FSQLPath);

  // TODO: finalize VersionControl
  success := CheckVersionControl(FSQLPath);
  if not success then
  begin
    // Final message before running update
    s := 'Mismatch with current database and version control.' + sLineBreak +
      'Select yes to continue with your swimming club database update' +
      sLineBreak + 'or select no to ABORT.';
    mr := MessageDlg(s, TMsgDlgType.mtConfirmation, [mbNo, mbYes], 0, mbNo);
    if mr = mrNo then
    begin
      Memo1.Lines.Add('Mismatch with version control.');
      Memo1.Lines.Add('Version control failed.' + sLineBreak);
      Memo1.Lines.Add('READY ...');
      // user still permitted to update ...
      btnUDB.Visible := true;
      exit;
    end;
  end;

  ExecuteProcessScripts(FSQLPath);
  Memo1.Lines.Add('READY ...');

end;

end.
