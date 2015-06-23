unit main;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, IdUDPClient, IdBaseComponent, IdComponent, IdUDPBase,
  IdUDPServer, IdSocketHandle, Math, IdTCPServer, IdTCPConnection,
  IdTCPClient;

type
  TForm1 = class(TForm)
    IdUDPServer1: TIdUDPServer;
    Memo1: TMemo;
    IdUDPClient1: TIdUDPClient;
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Button2: TButton;
    Button3: TButton;
    Button5: TButton;
    Button4: TButton;
    Button6: TButton;
    procedure IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
      ABinding: TIdSocketHandle);
    procedure ButtonsClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

var
  cnt: Integer = 0;

const
  CmdDone	      =	0;
  CmdStatus			= 1;
  CmdLEDCtrl		= 2;
  CmdSetConfig	= 3;
  CmdSwChanged	= 4;
  CmdDataEcho		= 5;


procedure TForm1.IdUDPServer1UDPRead(Sender: TObject; AData: TStream;
  ABinding: TIdSocketHandle);
var
  S, T: String;
  i, l: Integer;
begin
  Memo1.Lines.Add(IntToStr (cnt) + ') Received ' + IntToStr (AData.Size) + ' bytes:');
  cnt := cnt + 1;
  l := min (AData.Size, 32);
  SetLength (S, l);
  AData.Read (S[1], l);
  T := '';
  for i := 0 to l - 1 do
    T := T + IntToHex (Ord (S[i + 1]), 2) + ' ';
  Memo1.Lines.Add (T + #13#10);
end;

procedure TForm1.FormShow(Sender: TObject);
begin
  IdUDPServer1.Active := True;
end;

procedure TForm1.ButtonsClick(Sender: TObject);
var
  S, T: String;
  i: Integer;
begin
  cnt := cnt + 1;
  IdUDPClient1.Host := Edit1.Text;
  case (TButton(Sender).Tag) of
    0: S := Chr(CmdLEDCtrl) + #1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    1: S := Chr(CmdLEDCtrl) + #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    2: S := Chr(CmdSetConfig) + #1#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    3: S := Chr(CmdSetConfig) + #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    4: S := Chr(CmdStatus) + #0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0#0;
    5: S := Chr(CmdDataEcho) + #1#2#3#4#5#6#7#8#9#10#11#12#13#14#15#16#17;
  end;
  for i := 0 to Length (S) - 1 do
    T := T + IntToHex (Ord (S[i + 1]), 2) + ' ';
  Memo1.Lines.Add(IntToStr (cnt) + ') Sending ' + IntToStr (Length (S)) + ' bytes:');
  Memo1.Lines.Add (T);
  IdUDPClient1.Send (S);
end;

end.
