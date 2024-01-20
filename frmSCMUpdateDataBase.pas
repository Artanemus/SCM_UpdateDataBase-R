unit frmSCMUpdateDataBase;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.ExtCtrls, Vcl.StdCtrls,
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
    btnSelectUpdate: TButton;
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
  private const
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

    // get a text string of the current database
    // version as discovered by QueryDBVersion
    function GetCURRVersionStr: string;

  var
    // Flags that building is finalised or can't proceed.
    // Once set - btnUDB is not long visible. User may only exit.
    BuildDone: Boolean;

    // ---------------------------------------------------------
    // VALUES AFTER calling QryDBVersion
    // ---------------------------------------------------------
    FDBMajor: Integer;
    FDBMinor: Integer;
    FDBModel: Integer;
    FDBVersion: Integer;
    fSelectedUDBConfig: TUDBConfig; // reference to selected TUDBConfig objrct
    UDBConfigList: TObjectList<TUDBConfig>;
    fIsSynced: Boolean; // updated after calling CompareQryVsSelected
    // function CheckVersionControlText(var SQLPath: string): Boolean;
    procedure AssertIsSyncedState;
    function IsSyncedMessage(ShowDlg: Boolean = false): TModalResult;
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
  defSubPath = 'UDB_SCRIPTS\';

implementation

uses System.IOUtils, System.Types, System.IniFiles,
  System.UITypes, utilVersion, Vcl.Dialogs;

{$R *.dfm}

procedure TSCMUpdateDataBase.actnConnectExecute(Sender: TObject);
var
  errCount: Integer;
  s: string;
begin
  // Data entry checks.
  if edtServerName.Text = '' then exit;
  if not chkbUseOSAuthentication.Checked then
    if edtUser.Text = '' then exit;

  // Attempt a 'simple' connection to SQLEXPRESS
  SimpleMakeTemporyFDConnection(edtServerName.Text, edtUser.Text,
    edtPassword.Text, chkbUseOSAuthentication.Checked);

  // Clear display text
  Memo1.Clear;

  if scmConnection.Connected then
  begin
    // ---------------------------------------------------------------
    // Does the SwimClubMeet database exist on MS SQLEXPRESS?
    // ---------------------------------------------------------------
    qryDBExists.Open;
    if qryDBExists.Active then
    begin
      errCount := qryDBExists.FieldByName('Result').AsInteger;
      qryDBExists.Close;
      // return 1 if exists, 0 if it doesn't.
      if not(errCount = 1) then
      begin
        // SwimClubMeet doesn't exists!
        s := 'Unexpected error! SwimClubMeet wasn''t found.' + sLineBreak +
          'The database must exists to perform updates!' + sLineBreak +
          'Press EXIT when ready.';
        MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
        // single shot at building
        // Display states are handled by TAction.Update ....
        BuildDone := true;
        Memo1.Lines.Add(s);
        exit;
      end;
    end;
  end;

  if scmConnection.Connected then
  begin
    // QueryDBVersion :: Read the current database version.
    // This procedure is called
    // (1) on connection
    // (2) after completion of a successful update.
    QueryDBVersion;
    // Display on left of screen the version number.
    lblDBCURR.Caption := GetCURRVersionStr;
    Memo1.Lines.Add('Connected to SwimClubMeet on MSSQL');
    Memo1.Lines.Add('ALWAYS backup your database before performing an update!' +
      sLineBreak);

    // Memo IsSynced WARNING message, if mismatch found.
    IsSyncedMessage(false);

  end
  else
  begin
    Memo1.Lines.Add('Connection failed.' + sLineBreak);
    Memo1.Lines.Add('Check your input settings.' + sLineBreak);
    lblDBCURR.Caption := '';
  end;
  Memo1.Lines.Add('READY ...');

  // State of the Display
  actnDisconnect.Update; // btnDisconnect Visibility
  // actnConnect.Update;
  // actnSelect.Update;
  actnUDB.Update; // btnUDB Enabled state.

end;

procedure TSCMUpdateDataBase.actnConnectUpdate(Sender: TObject);
begin
  // buttons enable state handled by actnUDBUpdate
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

end;

procedure TSCMUpdateDataBase.actnDisconnectExecute(Sender: TObject);
begin
  // disconnect
  scmConnection.Close;
  Memo1.Clear;
  Memo1.Lines.Add('Disconnected ...' + sLineBreak);
  // REQUIRED: update button state.
  actnConnectUpdate(self);
  BuildDone := false;
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
      btnUDB.Enabled := false;
end;

procedure TSCMUpdateDataBase.actnSelectExecute(Sender: TObject);
var
  dlg: TSelectUpdateFolder;
  rootDIR, s: string;
  mr: TModalResult;
begin

  // fSelectedUDBConfig := nil;

  // DEFAULT:
  // BUILDMEACLUB USES THE SUB-FOLDER WITHIN IT'S EXE PATH
  // ---------------------------------------------------------------
{$IFDEF DEBUG}
  rootDIR := TPath.GetDocumentsPath + '\GitHub\SCM_ERStudio\' +
    IncludeTrailingPathDelimiter(defSubPath);
{$ELSE}
  // up to and including the colon or backslash .... SAFE
  rootDIR := IncludeTrailingPathDelimiter(ExtractFilePath(Application.ExeName))
    + IncludeTrailingPathDelimiter(defSubPath);
{$IFEND}
  Memo1.Clear;

  // DOES PATH EXISTS?
  if not System.SysUtils.DirectoryExists(rootDIR, true) then
  begin
    s := 'The build scripts sub-folder is missing!' + sLineBreak +
      '(Default name : ''#EXEPATH#\' + defSubPath + '''.)' + sLineBreak +
      'Cannot continue. Missing UDB system sub-folder.' + sLineBreak +
      'Press EXIT when ready.';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // only one shot at building granted
    // Display states are handled by TAction.Update ....
    BuildDone := true;
    Memo1.Lines.Add(s);
    exit;
  end;

  // Let the user select a database update configuration.
  dlg := TSelectUpdateFolder.Create(self);
  dlg.RootPath := rootDIR;
  dlg.ConfigList := UDBConfigList;
  mr := dlg.ShowModal;
  if IsPositiveResult(mr) then
  begin
    if Assigned(dlg.SelectedConfig) then
        fSelectedUDBConfig := dlg.SelectedConfig;
  end;
  dlg.Free;

  if Assigned(fSelectedUDBConfig) then
  begin
    lblDBIN.Caption := fSelectedUDBConfig.GetVersionStr(udbIN);
    lblDBOUT.Caption := fSelectedUDBConfig.GetVersionStr(udbOUT);
    lblPreRelease.Caption := '';
    s := '';
    if not fSelectedUDBConfig.IsRelease then
      lblPreRelease.Caption := 'Pre-Release'
    else
      lblPreRelease.Caption := '';

    if fSelectedUDBConfig.IsPatch then
    begin
      s := 'Patch ' + IntToStr(fSelectedUDBConfig.PatchNum);
      if length(lblPreRelease.Caption) > 0 then s := ' ' + s;
      lblPreRelease.Caption := lblPreRelease.Caption + s;
    end;


  end
  else
  begin
    lblDBIN.Caption := '';
    lblDBOUT.Caption := '';
    lblPreRelease.Caption := '';
  end;

  // After each selection - display a warning IsSynced message, if required.
  if scmConnection.Connected and Assigned(fSelectedUDBConfig) then
      IsSyncedMessage(false);
  // Memo IsSynced WARNING message, if mismatch found.
  Memo1.Lines.Add('READY ...');

end;

procedure TSCMUpdateDataBase.actnSelectUpdate(Sender: TObject);
begin
  // if scmConnection.Connected then
  // btnSelectUpdate.Visible := true
  // else
  // begin
  // btnSelectUpdate.Visible := false;
  // if Assigned(fSelectedUDBConfig) then fSelectedUDBConfig := nil;
  // end;

  if Assigned(fSelectedUDBConfig) then
  begin
    if scmConnection.Connected then
    begin
      if fIsSynced then
      begin
        if vimgChkBoxDBIN.ImageName <> 'GreenCheckBox' then
            vimgChkBoxDBIN.ImageName := 'GreenCheckBox';
      end
      else
      begin
        if vimgChkBoxDBIN.ImageName <> 'RedCross' then
            vimgChkBoxDBIN.ImageName := 'RedCross';
      end;
      vimgChkBoxDBIN.Visible := true;
    end
    else
    begin
      vimgChkBoxDBIN.Visible := false;
    end;

    lblDBIN.Visible := true;
    lblDBOUT.Visible := true;
//    if fSelectedUDBConfig.IsRelease then lblPreRelease.Visible := false;
//    if not fSelectedUDBConfig.IsPatch then lblPatch.Visible := false;
  end
  else
  begin
    lblDBIN.Visible := false;
    lblDBOUT.Visible := false;
//    lblPreRelease.Visible := false;
//    lblPatch.Visible := false;
    vimgChkBoxDBIN.Visible := false;
  end;

  if BuildDone then btnSelectUpdate.Enabled := false
  else btnSelectUpdate.Enabled := true;

end;

// ---------------------------------------------------------------
// E X E C U T E .
// U P D A T E   T H E   D A T A B A S E . . .
// ---------------------------------------------------------------
procedure TSCMUpdateDataBase.actnUDBExecute(Sender: TObject);
var
  s: String;
  errCode: Integer;
  success: Boolean;
  SQLFolderPath: string;
  mr: TModalResult;
begin

  progressBar.Position := 0;
  progressBar.Min := 0;
  Memo1.Clear;

  // basic checks. (Some of these checks are covered by actnEDBUpdate.)
  if not scmConnection.Connected then exit;
  if not Assigned(fSelectedUDBConfig) then exit;

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
    // Display states are handled by TAction.Update ....
    BuildDone := true;
    Memo1.Lines.Add(s);
    actnConnect.Update;
    exit;
  end;

  // ---------------------------------------------------------------
  // DEFAULT: Show memo IsSynced WARNING message (if mismatch found).
  // ---------------------------------------------------------------
  mr := IsSyncedMessage(true); // Show dialogue. Returns mrYes or mrNo

  // User answers mrNo to 'So you want to perform the update'.
  if IsNegativeResult(mr) then
  begin
    Memo1.Lines.Add('READY ...');
    exit;
  end;

  // ---------------------------------------------------------------
  // get the path to the folder holding the SQL scripts
  // ---------------------------------------------------------------
  SQLFolderPath := IncludeTrailingPathDelimiter
    (ExtractFilePath(fSelectedUDBConfig.FileName));

  if not TDirectory.Exists(SQLFolderPath) then
  begin
    s := 'Unexpected error. Directory doesn''t exist.' + sLineBreak +
      'The update folder ' + SQLFolderPath + ' wasn''t found.';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0, mbOk);
    // single shot at building
    BuildDone := true;
    Memo1.Lines.Add(s);
    // ActionList1.UpdateAction(actnConnect);
    actnConnect.Update;
    // actnConnectUpdate(Self);
    exit;
  end;

  // F I N A L   C H E C K S .
  // set the BuildDone state only if scripts were found.
  ExecuteProcessScripts(SQLFolderPath);

  actnConnect.Update(); // btnUDB.visible state
  actnSelect.Update();
  actnUDB.Update(); // btnUDB.enabled state determined by boolean BuildDone

end;

procedure TSCMUpdateDataBase.actnUDBUpdate(Sender: TObject);
begin
  // stops UI flickering if enable state is tested before changing.
    // NOTE: visibility of btnUDB is handle bu actnConnectUpdate
  if BuildDone then // re-run the application to build again
  begin
    if btnUDB.Enabled then btnUDB.Enabled := false;
    exit;
  end;

  if not Assigned(fSelectedUDBConfig) then
  begin
    if btnUDB.Enabled then btnUDB.Enabled := false;
    exit;
  end;

  if not btnUDB.Enabled then  btnUDB.Enabled := true;

end;

procedure TSCMUpdateDataBase.btnCancelClick(Sender: TObject);
begin
  scmConnection.Close;
  ModalResult := mrCancel;
  Close;
end;

procedure TSCMUpdateDataBase.AssertIsSyncedState;
begin
  fIsSynced := false;
  // On connection the procedure QueryDBVersion is called.
  // This routine is dependant on the procedure being called.
  if Assigned(fSelectedUDBConfig) and scmConnection.Connected then
  begin
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
  GetFileList(SQLPath, '*.SQL', sl);
  sl.Sort; // Perform an ANSI sort

  vimgChkBoxDBOUT.Visible := false;

  // Are there SQL files in this directory?
  if sl.Count = 0 then
  begin
    s := 'No build scripts to run!' + sLineBreak + 'READY ...';
    MessageDlg(s, TMsgDlgType.mtError, [mbOk], 0);
    // Display states are handled by TAction.Update ....
    BuildDone := false;
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
    if errCount = 0 then
    begin
      vimgChkBoxDBOUT.ImageName := 'GreenCheckBox'; // GREEN CHECK MARK
      vimgChkBoxDBOUT.Visible := true;
      Memo1.Lines.Add('ExecuteProcess completed without errors.');
      Memo1.Lines.Add
        ('You should check SCM_UpdateDataBase.log to ensure that sqlcmd.exe also reported no errors.'
        );

      // Read the current database version.
      // This procedure is called
      // (1) on connection
      // (2) after completion of a successful update.
      QueryDBVersion();
      // Display on left of screen the version number.
      lblDBCURR.Caption := GetCURRVersionStr();
      s := 'SwimClubMeet database version (after update). ' + lblDBCURR.Caption;
      Memo1.Lines.Add(s);
    end
    else
    begin
      vimgChkBoxDBOUT.ImageName := 'RedCheckBox'; // RED CHECK MARK
      vimgChkBoxDBOUT.Visible := true;
      Memo1.Lines.Add('ExecuteProcess reported: ' + IntToStr(errCount) +
        ' errors.');
      Memo1.Lines.Add('View the SCM_UpdateDataBase.log for sqlcmd.exe errors.' +
        sLineBreak);
      lblDBCURR.Caption := '';
    end;
    // only one shot at building granted
    BuildDone := true;
    progressBar.Visible := false;
    actnConnect.Update;
    // finished with database - do a disconnect? (But it hides the Memo1 cntrl)
    Memo1.Lines.Add(sLineBreak +
      'UpdateDataBase has completed. Press EXIT when ready.');
  end
  else
    // we had scripts ... but user didn't do a build
      ;

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
  vimgChkBoxDBIN.Visible := false;
  vimgChkBoxDBOUT.Visible := false;
  lblDBIN.Caption := '';
  lblDBOUT.Caption := '';
  lblDBCURR.Caption := '';
  lblDBCURR.Visible := false;
  fIsSynced := false;
  // init after SelectUpdate.Execute
  lblPreRelease.Caption := '';

  // hide password entry.
  sbtnPassword.Down := true;
  edtPassword.PasswordChar := '*';
  // TUDBConfig - Object to hold all the info on each update variant.
  // Info extracted from the file, UDBConfig.ini
  // Object includes the SQL folder path
  fSelectedUDBConfig := nil;
  // A custom collection. Contains TUDBConfig objects
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

function TSCMUpdateDataBase.IsSyncedMessage(ShowDlg: Boolean = false)
  : TModalResult;
var
  verStrCURR: string;
  verStrIN: string;
  sl: TStringList;
begin
  Result := mrNone;
  // ---------------------------------------------------------------
  // Ensure QueryDBVersion() was called (occurs on connection).
  // THIS IS A WARNING. It's not considered and error and the user is
  // permitted to execute the update!
  // ---------------------------------------------------------------
  if scmConnection.Connected and Assigned(fSelectedUDBConfig) then
  begin
    //
    AssertIsSyncedState; // assert IsSynced state.
    // reads local fields, populated after call to QueryDBVersion()
    verStrCURR := GetCURRVersionStr();
    // reads object TUSBConfig after call to actnSelectExecute
    verStrIN := fSelectedUDBConfig.GetVersionStr(udbIN);

    if not fIsSynced then
    begin
      sl := TStringList.Create;
      sl.Add('The current version of this SwimClubMeet database is ' +
        verStrCURR + '.');
      sl.Add('The selected update''s base version is ' + verStrIN + '.');
      sl.Add('The two don''t match and running the update isn''t recommended.');
      Memo1.Lines.Add(sl.Text);

      if ShowDlg then
      begin
        sl.Add('Do you want to perform the update?');
        Result := MessageDlg(sl.Text, mtWarning, [mbYes, mbNo], 0, mbNo);
      end;

      sl.Free;
    end;
  end;

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

function TSCMUpdateDataBase.GetCURRVersionStr: string;
begin
  // Values populated after calling QueryDBVersion
  Result := IntToStr(FDBModel) + '.' + IntToStr(FDBVersion) + '.' +
    IntToStr(FDBMajor) + '.' + IntToStr(FDBMinor) + '.';
end;

procedure TSCMUpdateDataBase.QueryDBVersion();
var
  fld: TField;
begin
  FDBModel := 0;
  FDBVersion := 0;
  FDBMajor := 0;
  FDBMinor := 0;
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
  if TSpeedButton(Sender).Down then edtPassword.PasswordChar := '*'
  else edtPassword.PasswordChar := #0;
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
