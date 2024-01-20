object SelectUpdateFolder: TSelectUpdateFolder
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'List of Updates'
  ClientHeight = 540
  ClientWidth = 430
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  KeyPreview = True
  Position = poOwnerFormCenter
  OnCreate = FormCreate
  OnKeyDown = FormKeyDown
  OnShow = FormShow
  TextHeight = 21
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 430
    Height = 433
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 380
    ExplicitHeight = 432
    object ListBox1: TListBox
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 410
      Height = 413
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      AutoComplete = False
      Align = alClient
      BevelKind = bkFlat
      ExtendedSelect = False
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -24
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ItemHeight = 32
      Items.Strings = (
        '1.0.0.0'
        '1.0.0.2')
      ParentFont = False
      Sorted = True
      TabOrder = 0
      StyleElements = [seClient, seBorder]
      OnDblClick = ListBox1DblClick
      ExplicitWidth = 360
      ExplicitHeight = 412
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 474
    Width = 430
    Height = 66
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 473
    ExplicitWidth = 380
    object btnCancel: TButton
      Left = 104
      Top = 15
      Width = 108
      Height = 35
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnOk: TButton
      Left = 218
      Top = 15
      Width = 108
      Height = 35
      Caption = 'Ok'
      ModalResult = 1
      TabOrder = 1
      OnClick = btnOkClick
    end
  end
  object Panel3: TPanel
    Left = 0
    Top = 0
    Width = 430
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Select an update...'
    TabOrder = 2
    ExplicitWidth = 380
  end
end
