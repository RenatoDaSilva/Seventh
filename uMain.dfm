object frmMain: TfrmMain
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = 'Servidor API REST'
  ClientHeight = 287
  ClientWidth = 346
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  Position = poScreenCenter
  OnShow = FormShow
  TextHeight = 15
  object lbPort: TLabel
    Left = 216
    Top = 20
    Width = 28
    Height = 15
    Caption = 'Porta'
  end
  object sbService: TSpeedButton
    Left = 16
    Top = 16
    Width = 145
    Height = 23
    AllowAllUp = True
    GroupIndex = 1
    Caption = 'Servi'#231'o'
    OnClick = sbServiceClick
  end
  object Label1: TLabel
    Left = 8
    Top = 45
    Width = 20
    Height = 15
    Caption = 'Log'
  end
  object mmLog: TMemo
    Left = 8
    Top = 64
    Width = 330
    Height = 217
    TabOrder = 0
  end
  object edPort: TEdit
    Left = 258
    Top = 16
    Width = 80
    Height = 23
    NumbersOnly = True
    TabOrder = 1
    Text = '80'
  end
  object IdHTTPServerMain: TIdHTTPServer
    OnStatus = IdHTTPServerMainStatus
    Bindings = <>
    OnBeforeBind = IdHTTPServerMainBeforeBind
    OnAfterBind = IdHTTPServerMainAfterBind
    OnCommandOther = IdHTTPServerMainCommandOther
    OnCommandGet = IdHTTPServerMainCommandGet
    Left = 280
    Top = 80
  end
end
