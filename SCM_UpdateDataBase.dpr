program SCM_UpdateDataBase;

uses
  Vcl.Forms,
  frmSCMUpdateDataBase in 'frmSCMUpdateDataBase.pas' {SCMUpdateDataBase},
  dlgIsSyncedMsgBox in 'dlgIsSyncedMsgBox.pas' {IsSyncedMsgBox},
  utilVersion in 'utilVersion.pas',
  Vcl.Themes,
  Vcl.Styles,
  dlgSelectBuild in '..\SCM_SHARED\dlgSelectBuild.pas' {SelectBuild},
  scmBuildConfig in '..\SCM_SHARED\scmBuildConfig.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10 SlateGray');
  Application.CreateForm(TSCMUpdateDataBase, SCMUpdateDataBase);
  Application.CreateForm(TSelectBuild, SelectBuild);
  Application.Run;
end.
