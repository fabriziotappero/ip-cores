object Form1: TForm1
  Left = 192
  Top = 114
  Width = 763
  Height = 560
  Caption = 'FPGA Cheap Ethernet test'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  DesignSize = (
    755
    526)
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 24
    Top = 20
    Width = 69
    Height = 13
    Caption = 'Destination IP '
  end
  object Memo1: TMemo
    Left = 8
    Top = 52
    Width = 739
    Height = 464
    Anchors = [akLeft, akTop, akRight, akBottom]
    TabOrder = 0
  end
  object Button1: TButton
    Left = 244
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Led ON'
    TabOrder = 1
    OnClick = ButtonsClick
  end
  object Edit1: TEdit
    Left = 104
    Top = 16
    Width = 121
    Height = 21
    TabOrder = 2
    Text = '192.168.1.44'
  end
  object Button2: TButton
    Tag = 1
    Left = 328
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Led OFF'
    TabOrder = 3
    OnClick = ButtonsClick
  end
  object Button3: TButton
    Tag = 5
    Left = 664
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Echo'
    TabOrder = 4
    OnClick = ButtonsClick
  end
  object Button5: TButton
    Tag = 4
    Left = 580
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Get Status'
    TabOrder = 5
    OnClick = ButtonsClick
  end
  object Button4: TButton
    Tag = 2
    Left = 412
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Autosend ON'
    TabOrder = 6
    OnClick = ButtonsClick
  end
  object Button6: TButton
    Tag = 3
    Left = 496
    Top = 16
    Width = 75
    Height = 25
    Caption = 'Autosend OFF'
    TabOrder = 7
    OnClick = ButtonsClick
  end
  object IdUDPServer1: TIdUDPServer
    Bindings = <
      item
        IP = '0.0.0.0'
        Port = 1024
      end>
    DefaultPort = 0
    OnUDPRead = IdUDPServer1UDPRead
    Left = 204
    Top = 64
  end
  object IdUDPClient1: TIdUDPClient
    Host = '192.168.1.44'
    Port = 1024
    Left = 152
    Top = 64
  end
end
