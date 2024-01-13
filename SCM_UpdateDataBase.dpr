program SCM_UpdateDataBase;

uses
  Vcl.Forms,
  frmSCMUpdateDataBase in 'frmSCMUpdateDataBase.pas' {SCMUpdateDataBase},
  dlgUDBMsgBox in 'dlgUDBMsgBox.pas' {UDBMsgBox},
  utilVersion in 'utilVersion.pas',
  Vcl.Themes,
  Vcl.Styles,
  dlgSelectUpdateFolder in 'dlgSelectUpdateFolder.pas' {SelectUpdateFolder},
  UDBConfig in 'UDBConfig.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TSCMUpdateDataBase, SCMUpdateDataBase);
  Application.Run;
end.
