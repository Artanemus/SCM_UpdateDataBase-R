program SCM_UpdateDataBase;

uses
  Vcl.Forms,
  frmSCMUpdateDataBase in 'frmSCMUpdateDataBase.pas' {SCMUpdateDataBase},
  dlgIsSyncedMsgBox in 'dlgIsSyncedMsgBox.pas' {IsSyncedMsgBox},
  Vcl.Themes,
  Vcl.Styles,
  utilVersion in '..\SCM_SHARED\utilVersion.pas',
  dlgSelectBuild in 'dlgSelectBuild.pas' {SelectBuild},
  uUDB_Config in 'uUDB_Config.pas',
  uUDB_Defines in 'uUDB_Defines.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TSCMUpdateDataBase, SCMUpdateDataBase);
  Application.Run;
end.
