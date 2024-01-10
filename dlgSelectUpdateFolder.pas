unit dlgSelectUpdateFolder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst, Vcl.ExtCtrls;

type
  TSelectUpdateFolder = class(TForm)
    Panel1: TPanel;
    CheckListBox1: TCheckListBox;
    Panel2: TPanel;
    btnCancel: TButton;
    btnOk: TButton;
    Panel3: TPanel;
    procedure FormCreate(Sender: TObject);
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
    fUDBScriptsPath: string;
    fRtnSubFolder: string;
    procedure InitCheckListBoxItems(const DIR: string);
    function GetCheckedItems(ListBox: TCheckListBox): string;

  public
    { Public declarations }
    property RtnSubFolder: string read fRtnSubFolder;
    property UDBScriptsPath: string write fUDBScriptsPath;

  end;

var
  SelectUpdateFolder: TSelectUpdateFolder;

implementation

{$R *.dfm}
uses
  StrUtils, System.IOUtils, System.Types, System.Masks;


procedure TSelectUpdateFolder.FormCreate(Sender: TObject);
begin
fRtnSubFolder := '';
end;

procedure TSelectUpdateFolder.btnCancelClick(Sender: TObject);
begin
  fRtnSubFolder := '';
  ModalResult := mrCancel;
end;

procedure TSelectUpdateFolder.btnOkClick(Sender: TObject);
begin
  fRtnSubFolder := GetCheckedItems(CheckListBox1);
  ModalResult := mrOK;
end;

procedure TSelectUpdateFolder.FormShow(Sender: TObject);
begin
  if fUDBScriptsPath.IsEmpty then
  begin
    ModalResult := mrCancel;
    Close;
  end;
  InitCheckListBoxItems(fUDBScriptsPath);
end;

function TSelectUpdateFolder.GetCheckedItems(ListBox: TCheckListBox): string;
var
  i: Integer;
begin
  result := '';
  for i := 0 to ListBox.Count - 1 do
  begin
    if ListBox.Checked[i] then
    begin
      result := ListBox.Items[i];
      break;
    end;
  end;
end;

function IniFileFilter(const Path: string; const SearchRec: TSearchRec): Boolean;
var
s: string;
begin
  // Return True if the file name ends with '.ini', False otherwise
  Result :=  false;
  s := SearchRec.Name;
  result := s.EndsWith('.ini', True); // Use True for case-insensitive comparison
end;

function FindFileType(const Path: string; const SearchRec: TSearchRec): Boolean;
var
  Mask: string;
begin
Mask := '*.ini';
  if MatchesMask(SearchRec.Name, Mask) then
      exit(True);
  exit(False);
end;

procedure TSelectUpdateFolder.InitCheckListBoxItems(const DIR: string);
var
  Folders: TStringDynArray;
  Files: TStringDynArray;
  Folder: string;
  LastFolder: string;
  Predicate: TDirectory.TFilterPredicate;
begin
  Folders := TDirectory.GetDirectories(DIR);
  CheckListBox1.Items.Clear;
  for Folder in Folders do
  begin
    // get the files in the folder
    Files := TDirectory.GetFiles(DIR, Predicate);
    LastFolder := ExtractFileName(ExcludeTrailingPathDelimiter(Folder));
    CheckListBox1.Items.Add(LowerCase(LastFolder));
  end;
end;


function MyGetFiles(const Path, Masks: string): TStringDynArray;
var
  MaskArray: TStringDynArray;
  Predicate: TDirectory.TFilterPredicate;
begin
  MaskArray := SplitString(Masks, ';');
  Predicate :=
    function(const Path: string; const SearchRec: TSearchRec): Boolean
    var
      Mask: string;
    begin
      for Mask in MaskArray do
        if MatchesMask(SearchRec.Name, Mask) then
          exit(True);
      exit(False);
    end;
  Result := TDirectory.GetFiles(Path, Predicate);
end;

end.
