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
  Vcl.VirtualImage, dlgSelectUpdateFolder, UDBConfig,
  System.Generics.Collections, Vcl.Buttons, System.ImageList, Vcl.ImgList,
  Vcl.VirtualImageList;

type
  TSCMUpdateDataBase = class(TForm)
    ActionList1: TActionList;
    actnConnect: TAction;
    actnDisconnect: TAction;
    actnSelect: TAction;
    actnUDB: TAction;
    btnCancel: TButton;
    btnConnect: TButton;
    btnDisconnect: TButton;
    btnSelectFolder: TButton;
    btnUDB: TButton;
    chkbUseOSAuthentication: TCheckBox;
    edtPassword: TEdit;
    edtServerName: TEdit;
    edtUser: TEdit;
    GroupBox1: TGroupBox;
    Image2: TImage;
    ImageCollection1: TImageCollection;
    Label5: TLabel;
    lblCurrDBVer: TLabel;
    lblDBCURR: TLabel;
    lblDBIN: TLabel;
    lblDBOUT: TLabel;
    lblPassword: TLabel;
    lblPreRelease: TLabel;
    lblServerName: TLabel;
    lblUser: TLabel;
    Memo1: TMemo;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    progressBar: TProgressBar;
    qryDBExists: TFDQuery;
    qryVersion: TFDQuery;
    sbtnPassword: TSpeedButton;
    scmConnection: TFDConnection;
    shapeDBCURR: TShape;
    vimgChkBoxDBIN: TVirtualImage;
    vimgChkBoxDBOUT: TVirtualImage;
    VirtualImage1: TVirtualImage;
    VirtualImageList1: TVirtualImageList;
    procedure actnConnectExecute(Sender: TObject);
    procedure actnConnectUpdate(Sender: TObject);
    procedure actnDisconnectExecute(Sender: TObject);
    procedure actnDisconnectUpdate(Sender: TObject);
    procedure actnSelectExecute(Sender: TObject);
    procedure actnSelectUpdate(Sender: TObject);
    procedure actnUDBExecute(Sender: TObject);
    procedure actnUDBUpdate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure sbtnPasswordClick(Sender: TObject);
  private
  const
    IN_Major = 5;
    IN_Minor = 0;
    // ---------------------------------------------------------
    // SCMSystem START VALUES
    // ---------------------------------------------------------
    IN_Model = 1;
    IN_Version = 1;
    OUT_Major = 5;
    OUT_Minor = 1;
    // ---------------------------------------------------------
    // NEW SCMSystem UPDATE VALUES
    // ---------------------------------------------------------
    OUT_Model = 1;
    OUT_Version = 1;
    SCMCONFIGFILENAME = 'SCMConfig.ini';
  var
    // Flags that building is finalised or can't proceed.
    // Once set - btnUDB is not long visible. User may only exit.
    BuildDone: Boolean;
    FDBMajor: Integer;
    FDBMinor: Integer;
    // ---------------------------------------------------------
    // VALUES AFTER READ OF SCMSystem
    // ---------------------------------------------------------
    FDBModel: Integer;
    // Display Strings
    FDBVerCtrlStr: string;
    FDBVerCtrlStrVerbose: string;
    FDBVersion: Integer;
    fSelectedUDBConfig: TUDBConfig; // ref only
    FSQLPath: String;
    fUpdateScriptSubPath: String;
    UDBConfigList: TObjectList<TUDBConfig>;
    fIsSynced: boolean; // updated after calling CompareQryVsSelected
    // function CheckVersionControlText(var SQLPath: string): Boolean;
    procedure UpdateSyncedState;
    function ExecuteProcess(const FileName, Params: string; Folder: string;
      WaitUntilTerminated, WaitUntilIdle, RunMinimized: Boolean;
      var ErrorCode: Integer): Boolean;
    procedure ExecuteProcessScripts(var SQLPath: string);
    function ExecuteProcessSQLcmd(SQLFile, ServerName, UserName,
      Password: String; var errCode: Integer; UseOSAthent: Boolean = true;
      RunMinimized: Boolean = false; Log: Boolean = false): Boolean;
    // function BuildUpdateScriptSubPath(): String;

    procedure GetFileList(filePath, fileMask: String; var sl: TStringList);
    procedure LoadConfigData;
    procedure QueryDBVersion();
    procedure SaveConfigData;
    procedure SimpleLoadSettingString(ASection, AName: String;
      var AValue: String);
    procedure SimpleMakeTemporyFDConnection(Server, User, Password: String;
      OsAuthent: Boolean);
    procedure SimpleSaveSettingString(ASection, AName, AValue: String);
  end;

var
  SCMUpdateDataBase: TSCMUpdateDataBase;

const
  logOutFn = '\Documents\SCM_UpdateDataBase.log';
  SectionName = 'SCM_UpdateDataBase';
  logOutFnTmp = '\Documents\SCM_UpdateDataBase.tmp';
  defUpdateScriptsRootPath = 'UPDATE_SCRIPTS\';

implementation

uses System.IOUtils, System.Types, System.IniFiles,
  System.UITypes, utilVersion;

{$R *.dfm}

procedure TSCMUpdateDataBase.actnConnectExecute(Sender: TObject);
begin
  // Data entry checks.
  if edtServerName.Text = '' then exit;
  if not chkbUseOSAuthentication.Checked then
    if edtUser.Text = '' then exit;

  // Attempt a 'simple' connection to SQLEXPRESS
  SimpleMakeTemporyFDConnection(edtServerName.Text, edtUser.Text,
    edtPassword.Text, chkbUseOSAuthentication.Checked);

  // Display info
  Memo1.Clear;

  if scmConnection.Connected then
  begin
    // Read the current database version and display
    QueryDBVersion;
    lblDBCURR.Caption := IntToStr(FDBModel) + '.' + IntToStr(FDBVersion) + '.' +
      IntToStr(FDBMajor) + '.' + IntToStr(FDBMinor);
    lblDBCURR.Visible := true;

    if Assigned(fSelectedUDBConfig) then // AND CONNECTED
    begin
      UpdateSyncedState;  // update fSynced.
      if not fIsSynced then
            Memo1.Lines.Add('WARNING: The selected update doesn''t match the current version.');
    end;
    Memo1.Lines.Add('Connected to SwimClubMeet on MSSQL');
    Memo1.Lines.Add('ALWAYS backup your database before performing an update!' +
      sLineBreak);
   end
  else
  begin
    Memo1.Lines.Add('Connection failed.' + sLineBreak);
    Memo1.Lines.Add('Check your input settings.' + sLineBreak);
  end;
  Memo1.Lines.Add('READY ...');

  // Update button states in groupbox1.
  actnDisconnectUpdate(self);
  actnConnectUpdate(self);
  actnSelectUpdate(self)


end;

procedure TSCMUpdateDataBase.actnConnectUpdate(Sender: TObject);
begin
  // update TCONTROL visibility
  if scmConnection.Connected then
  begin
    btnConnect.Visible := false;
    btnUDB.Visible := true; // when connected ... updating permitted.
    // other display elements
    shapeDBCURR.Visible := true;
    lblDBCURR.Visible := true;
    lblCurrDBVer.Visible := true;
  end
  else
  begin
    btnConnect.Visible := true;
    // other display elements
    shapeDBCURR.Visible := false;
    lblDBCURR.Visible := false;
    lblCurrDBVer.Visible := false;
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

procedure TSCMUpdateDataBase.actnSelectExecute(Sender: TObject);
var
  dlg: TSelectUpdateFolder;
  rootDIR, s: string;
  mr: TModalResult;
begin
  // DEFAULT:
  // BUILDMEACLUB USES THE SUB-FOLDER WITHIN IT'S EXE PATH
  // ---------------------------------------------------------------
{$IFDEF DEBUG}
  rootDIR := TPath.GetDocumentsPath + '\GitHub\SCM_ERStudio\' +
    IncludeTrailingPathDelimiter(fUpdateScriptSubPath);
{$ELSE}
  // up to and including the colon or backslash .... SAFE
  rootDIR := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
    + IncludeTrailingPathDelimiter(fUpdateScriptSubPath);
{$IFEND}

  Memo1.Clear;

  // DOES PATH EXISTS?
  if not System.SysUtils.DirectoryExists(rootDIR, true) then
  begin
    s := 'The build scripts sub-folder is missing!' + sLineBreak +
      '(Default name : ''#EXEPATH#\UDB_SCRIPTS\''.)' + sLineBreak +
      'Cannot continue. Missing UDB system sub-folder.' + sLineBreak +
      'Press EXIT when ready.';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // only one shot at building granted
    btnUDB.Visible := false;
    BuildDone := true;
    Memo1.Lines.Add('ERROR: Missing UDB system sub-folder.') ;
    Memo1.Lines.Add('Press EXIT when ready.');
    exit;
  end;

  // Let the user select a database update configuration.
  dlg := TSelectUpdateFolder.Create(self);
  dlg.RootPath := rootDIR;
  dlg.ConfigList := UDBConfigList;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr)then
  begin
    if Assigned(dlg.SelectedConfig) then
    begin
      fSelectedUDBConfig := dlg.SelectedConfig;
      s := ExtractFilePath(fSelectedUDBConfig.GetScriptPath);
      if System.SysUtils.DirectoryExists(s) then
      begin
        lblDBIN.Caption := fSelectedUDBConfig.GetVersionStr(udbIN);
        lblDBOUT.Caption := fSelectedUDBConfig.GetVersionStr(udbOUT);
      end;
    end;
  end;
  dlg.Free;

  // After each select execute - check sync.
  if scmConnection.Connected and Assigned(fSelectedUDBConfig) then
  begin
    // read the current DB's model.version.major.minor
    QueryDBVersion;
    // is the current DB version = UDBConfig version?
    UpdateSyncedState;  // update fSynced
    if not fIsSynced then
    begin
      Memo1.Lines.Add('WARNING: The selected update doesn''t match the current version.');
    end;
  end;
  Memo1.Lines.Add('READY ...');

end;

procedure TSCMUpdateDataBase.actnSelectUpdate(Sender: TObject);
begin
  if Assigned(fSelectedUDBConfig) then
  begin
    if scmConnection.Connected then
    begin
      if fIsSynced then
      begin
        if vimgChkBoxDBIN.ImageName <> 'check_box' then
            vimgChkBoxDBIN.ImageName := 'check_box';
      end
      else
      begin
        if vimgChkBoxDBIN.ImageName <> 'RedCross' then
            vimgChkBoxDBIN.ImageName := 'RedCross';
      end;
      vimgChkBoxDBIN.Visible := true;
      if BuildDone then vimgChkBoxDBOUT.Visible := true;
    end
    else
    begin
      vimgChkBoxDBIN.Visible := false;
      vimgChkBoxDBOUT.Visible := false;
    end;

    lblDBIN.Visible := true;
    lblDBOUT.Visible := true;
    if fSelectedUDBConfig.IsRelease then lblPreRelease.Visible := false;
  end
  else
  begin
    lblDBIN.Visible := true;
    lblDBOUT.Visible := true;
    lblPreRelease.Visible := false;
  end;

end;

// ---------------------------------------------------------------
// E X E C U T E .
// U P D A T E   T H E   D A T A B A S E . . .
// ---------------------------------------------------------------
procedure TSCMUpdateDataBase.actnUDBExecute(Sender: TObject);
var
  s, FDir: String;
  errCount, errCode: Integer;
  mr: TModalResult;
  success, CntrlKeyPressed: Boolean;
begin

  progressBar.Position := 0;
  progressBar.Min := 0;
  btnUDB.Visible := false;
  CntrlKeyPressed := false;
  Memo1.Clear;

  if not scmConnection.Connected then exit;

  // ---------------------------------------------------------------
  // H I D D E N  - O P T I O N A L   M E T H O D
  // Locate any update folder (containing SQL update files)
  // ---------------------------------------------------------------
  if ((GetKeyState(VK_CONTROL) AND 128) = 128) then CntrlKeyPressed := true;

  // ---------------------------------------------------------------
  // Does the SwimClubMeet database exist on MS SQLEXPRESS?
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
      // single shot at building
      btnUDB.Visible := false;
      BuildDone := true;
      Memo1.Lines.Add(s);
      exit;
    end;

  end;

  // ---------------------------------------------------------------
  // Does the commandline app sqlcmd.exe exist?
  // ---------------------------------------------------------------
  success := ExecuteProcess('sqlcmd.exe', '-?', '', true, true, true, errCode);

  if not success then
  begin
    s := 'The application ''sqlcmd.exe'' wasn''t found!' + sLineBreak +
      'The MS SQLEXPRESS utility is missing.' + sLineBreak +
      'Press EXIT when ready.';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // single shot at building
    btnUDB.Visible := false;
    BuildDone := true;
    Memo1.Lines.Add(s);
    exit;
  end;

  // ---------------------------------------------------------------
  // A configuration folder hasn't been select. We have no Config object.
  // ---------------------------------------------------------------
  if not Assigned(fSelectedUDBConfig) then
  begin
    s := 'No configuration folder has been assigned.' + sLineBreak +
      'Use the select folder button.';
    MessageDlg(s, TMsgDlgType.mtWarning, [mbOk], 0);
    btnUDB.Visible := false;
    BuildDone := false;
    Memo1.Lines.Add(s);
    exit;
  end;

  // ---------------------------------------------------------------
  // update fIsSynced state. Current version = UDBConfig DBIN
  // ---------------------------------------------------------------
  UpdateSyncedState;

  // ---------------------------------------------------------------
  // Does the current DB 'SCM version' sync with this update app.
  // ---------------------------------------------------------------
  if not fIsSynced then
  begin
    // NOTE: L E T   O P T I O N A L   M E T H O D   T H R U  .
    if not CntrlKeyPressed then
    begin
      // wanted version 1,1,5,0
      s := 'The current version of this SCM database is ' + FDBVerCtrlStr + ' .'
        + sLineBreak + 'The version you selected ' +
        fSelectedUDBConfig.Description + sLineBreak +
        ' is the wrong version to run on this database.' + sLineBreak +
        'Select another version.';
      MessageDlg(s, TMsgDlgType.mtWarning, [mbOk], 0);
      btnUDB.Visible := false;
      BuildDone := false;
      Memo1.Lines.Add(s);
      exit;
    end;
  end;

  // ----------------------------------------------------------------
  // O P T I O N A L   M E T H O D  - RUN ANY SCRIPTS
  // LET THE USER LOCATE A FOLDER WITH SQL SCRIPTS
  // ----------------------------------------------------------------
  if CntrlKeyPressed then
  begin
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
        if Execute then FSQLPath := FileName;
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
  end
  else
  // ---------------------------------------------------------------
  // Does the DEFAULT update folder
  // (containing SQL update files) exist?
  // ---------------------------------------------------------------
  begin
{$IFDEF DEBUG}
    FSQLPath := TPath.GetDocumentsPath + '\GitHub\SCM_ERStudio\UDB_SCRIPTS\';
{$ELSE}
    // up to and including the colon or backslash .... SAFE
    FSQLPath := ExtractFilePath(Application.ExeName) + fUpdateScriptSubPath;
{$IFEND}
    if not TDirectory.Exists(FSQLPath) then
    begin
      s := 'The update folder ' + fUpdateScriptSubPath + ' wasn''t found.';
      MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0, mbOk);
      // single shot at building
      btnUDB.Visible := false;
      BuildDone := true;
      Memo1.Lines.Add(s);
      exit;
    end;
  end;

  // ASSERT: NEEDS TRAILING PATH DELIMITER
  FSQLPath := IncludeTrailingPathDelimiter(FSQLPath);

  // F I N A L   C H E C K S .

  // ---------------------------------------------------------------
  // Is there a SCM_VersionControl.txt?
  // ---------------------------------------------------------------
  if not fIsSynced then
  begin
    // L E T   O P T I O N A L   M E T H O D   T H R U  .
    if CntrlKeyPressed then
    begin
      // WARNING
      s := 'WARNING : Missing or mismatch with current database and SCM_VersionControl.txt.'
        + sLineBreak +
        'Select yes to continue with your swimming club database update' +
        sLineBreak + 'or select no to ABORT.';
      mr := MessageDlg(s, TMsgDlgType.mtWarning, [mbNo, mbYes], 0, mbNo);
      if mr = mrNo then
      begin
        Memo1.Lines.Add('Mismatch with version control.');
        Memo1.Lines.Add('READY ...');
        // user still permitted to update ...
        btnUDB.Visible := true;
        exit;
      end;
    end
    else
    begin
      s := 'Missing or mismatch with current database and SCM_VersionControl.txt.'
        + sLineBreak + 'Press EXIT when ready.';
      MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
      // single shot at building
      btnUDB.Visible := false;
      BuildDone := true;
      Memo1.Lines.Add(s);
      exit;
    end;
  end;

  ExecuteProcessScripts(FSQLPath);
  Memo1.Lines.Add('Update completed ...');
  btnUDB.Visible := false;
  BuildDone := true;
  Memo1.Lines.Add('Press EXIT when ready.');

  // WARNING:  O P T I O N A L   M E T H O D .
  if CntrlKeyPressed then
  begin
    s := 'Consider checking [SwimClubMeet].[dbo].SCMSystem. ' + sLineBreak +
      'Ensure that the version information is correct.';
    MessageDlg(s, TMsgDlgType.mtInformation, [mbOk], 0);
  end;

end;

procedure TSCMUpdateDataBase.actnUDBUpdate(Sender: TObject);
begin
  if BuildDone then // only one build per application running
      btnUDB.Visible := false;
  if not Assigned(fSelectedUDBConfig) then btnUDB.Enabled := false
  else btnUDB.Enabled := true;
end;

procedure TSCMUpdateDataBase.btnCancelClick(Sender: TObject);
begin
  scmConnection.Close;
  ModalResult := mrCancel;
  Close;
end;

procedure TSCMUpdateDataBase.UpdateSyncedState;
begin
  fIsSynced := false;
  if Assigned(fSelectedUDBConfig) and scmConnection.Connected then
  begin
    QueryDBVersion;
    if (FDBVersion = fSelectedUDBConfig.VersionIN) AND
      (FDBMajor = fSelectedUDBConfig.MajorIN) AND
      (FDBMinor = fSelectedUDBConfig.MinorIN) then fIsSynced := true;
  end;
end;

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
  if Folder <> '' then WorkingDirP := PChar(Folder)
  else WorkingDirP := nil;
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
    if WaitUntilIdle then WaitForInputIdle(hProcess, INFINITE);
    // CHECK ::WaitUntilTerminated was used in C++ sqlcmd.exe
    if WaitUntilTerminated then
      repeat Application.ProcessMessages;
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
  errCount, errCode: Integer;
  success: Boolean;
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
    vimgChkBoxDBIN.Visible := false;
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
    if FileExists(Str) then DeleteFile(Str);

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
    vimgChkBoxDBOUT.ImageIndex := 2; // GREEN CHECK MARK
    vimgChkBoxDBOUT.Visible := true;
    if errCount = 0 then
    begin
      Memo1.Lines.Add('ExecuteProcess completed without errors.' + sLineBreak);
      Memo1.Lines.Add
        ('You should check SCM_UpdateDataBase.log to ensure that sqlcmd.exe also reported no errors.'
        + sLineBreak);
      // * Version number of SwimClubMeet DataBase *
      // Only read this table if not errors reported.
      QueryDBVersion();
      s := 'SwimClubMeet database version control ' + FDBVerCtrlStr;
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
  if SQLFile.IsEmpty then exit;

  quotedSQLFile := AnsiQuotedStr(SQLFile, '"');
  {
    NOTE: -S [protocol:]server[instance_name][,port]
    NOTE: -E is not specified because it is the default and sqlcmd
    connects to the default instance by using Windows Authentication.
    TODO: include fullname and password authentication.
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

  if passed then Result := true; // flag success

end;

procedure TSCMUpdateDataBase.FormCreate(Sender: TObject);
begin
  // clear BMAC critical error flag
  BuildDone := false;
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
  FDBVerCtrlStr := '';
  FDBVerCtrlStrVerbose := '';
  vimgChkBoxDBIN.Visible := false;
  vimgChkBoxDBOUT.Visible := false;
  lblDBIN.Caption := '';
  lblDBOUT.Caption := '';
  lblDBCURR.Caption := '';
  lblDBCURR.Visible := false;
  lblPreRelease.Visible := false;
  fIsSynced := false;
  // default script folder - intiated by INNO installer.
  fUpdateScriptSubPath := 'UDB_SCRIPTS\';
  // hide password entry.
  sbtnPassword.Down := true;
  edtPassword.PasswordChar := '*';
  // A custom class to hold all the info on each update variant.
  UDBConfigList := TObjectList<TUDBConfig>.Create(true); // owns object

end;

procedure TSCMUpdateDataBase.FormDestroy(Sender: TObject);
begin
  // release custom class data.
  UDBConfigList.Clear;
  UDBConfigList.Free;
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
  for fn in List do sl.Add(fn);
end;

procedure TSCMUpdateDataBase.LoadConfigData;
var
  ASection: string;
  Server: string;
  User: string;
  Password: string;
  AValue: string;
  AName: string;

begin
  ASection := SectionName;
  AName := 'Server';
  SimpleLoadSettingString(ASection, AName, Server);
  if Server.IsEmpty then edtServerName.Text := 'localHost\SQLEXPRESS'
  else edtServerName.Text := Server;
  AName := 'User';
  SimpleLoadSettingString(ASection, AName, User);
  edtUser.Text := User;
  AName := 'Password';
  SimpleLoadSettingString(ASection, AName, Password);
  edtPassword.Text := Password;
  AName := 'OSAuthent';
  SimpleLoadSettingString(ASection, AName, AValue);
  if (Pos('y', AValue) <> 0) or (Pos('Y', AValue) <> 0) then
      chkbUseOSAuthentication.Checked := true
  else chkbUseOSAuthentication.Checked := false;
end;

procedure TSCMUpdateDataBase.QueryDBVersion();
var
  fld: TField;
begin
  FDBModel := 0;
  FDBVersion := 0;
  FDBMajor := 0;
  FDBMinor := 0;
  FDBVerCtrlStr := '';
  FDBVerCtrlStrVerbose := '';
  if scmConnection.Connected then
  begin
    // opening and closing a query performs a full refresh.
    qryVersion.Close;
    qryVersion.Open;
    if qryVersion.Active then
    begin
      FDBModel := qryVersion.FieldByName('SCMSystemID').AsInteger;
      FDBVersion := qryVersion.FieldByName('DBVersion').AsInteger;
      fld := qryVersion.FieldByName('Major');
      if Assigned(fld) then
      begin
        FDBMajor := fld.AsInteger;
      end;
      fld := qryVersion.FieldByName('Minor');
      if Assigned(fld) then
      begin
        FDBMinor := fld.AsInteger;
      end;
      // DISPLAY STRINGS
      FDBVerCtrlStr := IntToStr(FDBModel) + '.' + IntToStr(FDBVersion) + '.' +
        IntToStr(FDBMajor) + '.' + IntToStr(FDBMinor) + '.';
      FDBVerCtrlStrVerbose := 'Base: ' + IntToStr(FDBModel) + ' Version: ' +
        IntToStr(FDBVersion) + ' Major: ' + IntToStr(FDBMajor) + ' Minor: ' +
        IntToStr(FDBMinor)
    end;
  end;

end;

procedure TSCMUpdateDataBase.SaveConfigData;
var
  ASection, AName, AValue: String;
begin
  begin
    ASection := SectionName;
    AName := 'Server';
    SimpleSaveSettingString(ASection, AName, edtServerName.Text);
    AName := 'User';
    SimpleSaveSettingString(ASection, AName, edtUser.Text);
    AName := 'Password';
    SimpleSaveSettingString(ASection, AName, edtPassword.Text);
    AName := 'OSAuthent';
    if chkbUseOSAuthentication.Checked = true then AValue := 'Yes'
    else AValue := 'No';
    SimpleSaveSettingString(ASection, AName, AValue);
  end

end;

procedure TSCMUpdateDataBase.sbtnPasswordClick(Sender: TObject);
begin
  if TSpeedButton(Sender).Down then
    edtPassword.PasswordChar := '*'
  else
    edtPassword.PasswordChar := #0;
end;

{$REGION 'SIMPLE LOAD ROUTINES FOR TEMPORY FDAC CONNECTION'}

procedure TSCMUpdateDataBase.SimpleLoadSettingString(ASection, AName: String;
  var AValue: String);
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
    AValue := ini.ReadString(ASection, AName, '');
  finally
    ini.Free;
  end;
end;

procedure TSCMUpdateDataBase.SimpleMakeTemporyFDConnection(Server, User,
  Password: String; OsAuthent: Boolean);
var
  Value: String;
begin

  if Server.IsEmpty then exit;

  if not OsAuthent then
    if User.IsEmpty then exit;

  if (scmConnection.Connected) then scmConnection.Connected := false;

  scmConnection.Params.Clear();
  scmConnection.Params.Add('Server=' + Server);
  scmConnection.Params.Add('DriverID=MSSQL');
  // NOTE ASSUMPTION :: SwimClubMeet EXISTS.
  scmConnection.Params.Add('Database=SwimClubMeet');
  scmConnection.Params.Add('User_name=' + User);
  scmConnection.Params.Add('Password=' + Password);
  if OsAuthent then Value := 'Yes'
  else Value := 'No';
  scmConnection.Params.Add('OSAuthent=' + Value);
  scmConnection.Params.Add('Mars=yes');
  scmConnection.Params.Add('MetaDefSchema=dbo');
  scmConnection.Params.Add('ExtendedMetadata=False');
  scmConnection.Params.Add('ApplicationName=SCM_UpdateDataBase');
  scmConnection.Connected := true;

  // ON SUCCESS - Save connection details.
  if scmConnection.Connected Then SaveConfigData;
end;


procedure TSCMUpdateDataBase.SimpleSaveSettingString(ASection, AName,
  AValue: String);
var
  ini: TIniFile;
begin
  ini := TIniFile.Create(TPath.GetDocumentsPath + PathDelim +
    SCMCONFIGFILENAME);
  try
    ini.WriteString(ASection, AName, AValue);
  finally
    ini.Free;
  end;

end;


{$ENDREGION}


end.
