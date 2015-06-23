program p8051Rom;

uses
  Forms,
  uMain in 'uMain.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'oc8051 rom maker';
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
