unit dlgIsSyncedMsgBox;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ExtCtrls, Vcl.StdCtrls;

type
  TIsSyncedMsgBox = class(TForm)
    Panel1: TPanel;
    btnNo: TButton;
    btnYes: TButton;
    Label1: TLabel;
    Label2: TLabel;
    Image1: TImage;
    procedure btnNoClick(Sender: TObject);
    procedure btnYesClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Private declarations }
    FFolderPath: String;
  public
    { Public declarations }
    property FolderPath: string read FFolderPath write FFolderPath;
  end;

var
  IsSyncedMsgBox: TIsSyncedMsgBox;

implementation

{$R *.dfm}

procedure TIsSyncedMsgBox.btnNoClick(Sender: TObject);
begin
  ModalResult := btnNo.ModalResult;
  Close;
end;

procedure TIsSyncedMsgBox.btnYesClick(Sender: TObject);
begin
  ModalResult := btnYes.ModalResult;
  Close;
end;

procedure TIsSyncedMsgBox.FormCreate(Sender: TObject);
begin
  FFolderPath := '';
end;

end.
