object SelectUpdateFolder: TSelectUpdateFolder
  Left = 0
  Top = 0
  Caption = 'SwimClubMeet Update Database'
  ClientHeight = 540
  ClientWidth = 419
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -16
  Font.Name = 'Segoe UI'
  Font.Style = []
  OnCreate = FormCreate
  OnShow = FormShow
  TextHeight = 21
  object Panel1: TPanel
    Left = 0
    Top = 41
    Width = 419
    Height = 433
    Align = alClient
    BevelOuter = bvNone
    TabOrder = 0
    ExplicitWidth = 415
    ExplicitHeight = 432
    object CheckListBox1: TCheckListBox
      AlignWithMargins = True
      Left = 10
      Top = 10
      Width = 399
      Height = 413
      Margins.Left = 10
      Margins.Top = 10
      Margins.Right = 10
      Margins.Bottom = 10
      Align = alClient
      CheckBoxPadding = 5
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -21
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ItemHeight = 35
      Items.Strings = (
        'v1.0.0.0'
        'v1.1.5.0'
        'v1.1.5.1'
        'v1.1.5.2'
        'v1.1.5.3')
      ParentFont = False
      Sorted = True
      TabOrder = 0
      ExplicitWidth = 395
      ExplicitHeight = 412
    end
  end
  object Panel2: TPanel
    Left = 0
    Top = 474
    Width = 419
    Height = 66
    Align = alBottom
    BevelEdges = [beTop]
    BevelKind = bkFlat
    BevelOuter = bvNone
    TabOrder = 1
    ExplicitTop = 473
    ExplicitWidth = 415
    object btnCancel: TButton
      Left = 98
      Top = 15
      Width = 108
      Height = 35
      Caption = 'Cancel'
      ModalResult = 2
      TabOrder = 0
      OnClick = btnCancelClick
    end
    object btnOk: TButton
      Left = 212
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
    Width = 419
    Height = 41
    Align = alTop
    BevelOuter = bvNone
    Caption = 'Select update to perform.'
    TabOrder = 2
    ExplicitWidth = 415
  end
end
