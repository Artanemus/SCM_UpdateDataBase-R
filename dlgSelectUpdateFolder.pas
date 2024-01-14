unit dlgSelectUpdateFolder;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants,
  System.Classes, Vcl.Graphics,  System.Types,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.CheckLst,
  Vcl.ExtCtrls,
  UDBConfig, System.Generics.Collections;

type
  TSelectUpdateFolder = class(TForm)
    btnCancel: TButton;
    btnOk: TButton;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    ListBox1: TListBox;
    procedure btnCancelClick(Sender: TObject);
    procedure btnOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ListBox1DblClick(Sender: TObject);
  private
    { Private declarations }
    fRootPath: string;
    fConfigList: TObjectList<TUDBConfig>;
    fSelectedConfig: TUDBConfig;
    function FindFiles(const Path, Masks: string): TStringDynArray;
//    function GetCheckedItem(ListBox: TCheckListBox): integer;
//    function GetCheckedUDBConfig(ListBox: TCheckListBox): TUDBConfig;
    procedure InitCheckListBoxItems(const DIR: string;
      ConfigList: TObjectList<TUDBConfig>);
  public
    { Public declarations }
    property ConfigList: TObjectList<TUDBConfig> write fConfigList;
    property SelectedConfig: TUDBConfig read fSelectedConfig;
    property RootPath: string write fRootPath;
  end;

var
  SelectUpdateFolder: TSelectUpdateFolder;

implementation

{$R *.dfm}

uses
  StrUtils, System.IOUtils, System.Masks;

procedure TSelectUpdateFolder.btnCancelClick(Sender: TObject);
begin
  fSelectedConfig := nil;
  ModalResult := mrCancel;
end;

procedure TSelectUpdateFolder.btnOkClick(Sender: TObject);
begin
  if (ListBox1.ItemIndex <> -1) then
  begin
    fSelectedConfig := TUDBConfig(ListBox1.Items.Objects
      [ListBox1.ItemIndex]);
    ModalResult := mrOK;
  end;
end;

function TSelectUpdateFolder.FindFiles(const Path, Masks: string): TStringDynArray;
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
        if MatchesMask(SearchRec.Name, Mask) then exit(True);
      exit(false);
    end;
  result := TDirectory.GetFiles(Path, Predicate);
end;

procedure TSelectUpdateFolder.FormCreate(Sender: TObject);
begin
  fConfigList := nil;
  fSelectedConfig := nil;
end;

procedure TSelectUpdateFolder.FormDestroy(Sender: TObject);
begin
  // code...
end;

procedure TSelectUpdateFolder.FormShow(Sender: TObject);
begin
  if fRootPath.IsEmpty or not Assigned(fConfigList) then
  begin
    ModalResult := mrCancel;
    Close;
  end;
  InitCheckListBoxItems(fRootPath, fConfigList);
end;

{
function TSelectUpdateFolder.GetCheckedItem(ListBox: TCheckListBox): integer;
var
  i: Integer;
begin
  result := -1;
  for i := 0 to ListBox.Count - 1 do
  begin
    if ListBox.Checked[i] then
    begin
      result := i;
      break;
    end;
  end;
end;
}
{
function TSelectUpdateFolder.GetCheckedUDBConfig(ListBox: TCheckListBox)
  : TUDBConfig;
var
  i: integer;
begin
  result := nil;
  i := GetCheckedItem(ListBox);
  if (i <> -1) then result := TUDBConfig(ListBox.Items.Objects[i]);
end;
}

procedure TSelectUpdateFolder.InitCheckListBoxItems(const DIR: string;
  ConfigList: TObjectList<TUDBConfig>);
var
  Folders: TStringDynArray;
  Files: TStringDynArray;
  aFile, s: string;
  Folder: string;
  Masks: String;
  UDBConfig: TUDBConfig;
begin
  Folders := TDirectory.GetDirectories(DIR);
  ListBox1.Items.Clear;
  ConfigList.Clear;
  for Folder in Folders do
  begin
    // get the files in the folder
    Masks := '*.ini';
    Files := FindFiles(Folder, Masks);
    for aFile in Files do
    begin
      // should only be one ini file in the each directory
      s := ExtractFileName(aFile);
      if (s = 'UDBConfig.ini') then
      begin
        UDBConfig := TUDBConfig.Create;
        UDBConfig.LoadIniFile(aFile);
        UDBConfig.FileName := aFile;
        ConfigList.Add(UDBConfig); // owns object
      end;
    end;

    // LastFolder := ExtractFileName(ExcludeTrailingPathDelimiter(Folder));
    // ListBox1.Items.Add(LowerCase(LastFolder));
  end;
  for UDBConfig in ConfigList do
  begin
    // create checkbox caption
    s := UDBConfig.GetVersionStr(udbIN) + ' > ' +
      UDBConfig.GetVersionStr(udbOUT);
    if UDBConfig.IsRelease = false then
      s := s + ' Prerelease';
    ListBox1.Items.AddObject(s, UDBConfig);
  end;
end;

procedure TSelectUpdateFolder.ListBox1DblClick(Sender: TObject);
begin
  btnOkClick(Sender);
end;

{
function IniFileFilter(const Path: string; const SearchRec: TSearchRec)
  : Boolean;
var
  s: string;
begin
  // Return True if the file name ends with '.ini', False otherwise
  result := false;
  s := SearchRec.Name;
  result := s.EndsWith('.ini', True);
  // Use True for case-insensitive comparison
end;

function FindFileType(const Path: string; const SearchRec: TSearchRec): Boolean;
var
  Mask: string;
begin
  Mask := '*.ini';
  if MatchesMask(SearchRec.Name, Mask) then exit(True);
  exit(false);
end;
}

end.
