unit uMain;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Buttons, inifiles;

type
  tbytes = array [0..3] of array [0..7] of boolean;
  tstr = array [0..7] of string;
  tRom = record
    bytes: tbytes;
    str: tstr;
  end;

  TForm1 = class(TForm)
    od1: TOpenDialog;
    rgOut: TRadioGroup;
    edtIn: TEdit;
    edtOut: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    sbIn: TSpeedButton;
    sbOut: TSpeedButton;
    btnMake: TBitBtn;
    btnExit: TBitBtn;
    sd1: TSaveDialog;
    Panel1: TPanel;
    Memo1: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure btnExitClick(Sender: TObject);
    procedure btnMakeClick(Sender: TObject);
    procedure sbInClick(Sender: TObject);
    procedure sbOutClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private
    { Private declarations }
    roms: array [0..2047] of tRom;
    function makeV(hFile:string): string;
    function hexToInt (hex:string):integer;
    function intToHex (int:integer):string;
    function inToBits (int:integer): string;
    procedure addB(rom, byt: integer; num:string);
    procedure addS(romN:integer);
    procedure simul (hex: string; str: tstrings);
    procedure simulIn (hex: string; str: tstrings);
    procedure syn (hex: string; str: tstrings);
    function n2 (n: integer):integer;
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
begin
  if od1.Execute then
    makeV(od1.FileName);
end;

//
function TForm1.makeV(hFile:string): string;
var str: TstringList;
    res, s: string;
    j, i, byts: integer;
    oaddr, naddr: longint;
begin
  try
    str:= tstringlist.create;
    str.LoadFromFile(hFile);
    res:= '';
    oaddr:=0;

    for i:=0 to str.Count-1 do begin
      byts:=(hexToInt(str[i][2])*16)+hexToInt(str[i][3]);
      naddr:=(hexToInt(str[i][4])*64)+(hexToInt(str[i][5])*32)+(hexToInt(str[i][6])*16)+hexToInt(str[i][7]);
      if ((naddr+byts)>0) then
        str[i]:=copy(str[i], 4, 4)+copy(str[i], 2, 2)+copy(str[i], 10,byts*2)
      else begin
        str[i]:='x';
        break;
      end;
    end;
    str.sort;

    for i:=0 to str.Count-1 do begin
      if str[i][1]='x' then break;
      byts:=(hexToInt(str[i][5])*16)+hexToInt(str[i][6]);
      naddr:=(hexToInt(str[i][1])*4096)+(hexToInt(str[i][2])*256)+(hexToInt(str[i][3])*16)+hexToInt(str[i][4]);
      s:='';
      if oaddr<>naddr then begin
        for j:=0 to naddr-oaddr-1 do begin
          s:= s+'00';
        end;
      end;
      res:=res+s+copy(str[i], 7,byts*2);
      oaddr:= naddr+byts
    end;
    str.free;
    result:=inToBits(oaddr)+res;
  except
    on e:exception do showmessage(e.message)
  end
end;

function TForm1.hexToInt (hex:string):integer;
begin
  if UpperCase(hex)='A' then begin result:= 10; exit end;
  if UpperCase(hex)='B' then begin result:= 11; exit end;
  if UpperCase(hex)='C' then begin result:= 12; exit end;
  if UpperCase(hex)='D' then begin result:= 13; exit end;
  if UpperCase(hex)='E' then begin result:= 14; exit end;
  if UpperCase(hex)='F' then begin result:= 15; exit end;
  result:= strToInt(hex)
end;

procedure TForm1.addB(rom, byt: integer; num:string);
var int: integer;
begin

  int:=hexToInt(num[1]);
  if int>7 then begin
    roms[rom].bytes[byt][7]:=true;
    int:= int-8;
  end else
    roms[rom].bytes[byt][7]:=false;
  if int>3 then begin
    roms[rom].bytes[byt][6]:=true;
    int:= int-4;
  end else
    roms[rom].bytes[byt][6]:=false;
  if int>1 then begin
    roms[rom].bytes[byt][5]:=true;
    int:= int-2;
  end else
    roms[rom].bytes[byt][5]:=false;
  if int=1 then begin
    roms[rom].bytes[byt][4]:=true;
  end else
    roms[rom].bytes[byt][4]:=false;

  int:=hexToInt(num[2]);
  if int>7 then begin
    roms[rom].bytes[byt][3]:=true;
    int:= int-8;
  end else
    roms[rom].bytes[byt][3]:=false;
  if int>3 then begin
    roms[rom].bytes[byt][2]:=true;
    int:= int-4;
  end else
    roms[rom].bytes[byt][2]:=false;
  if int>1 then begin
    roms[rom].bytes[byt][1]:=true;
    int:= int-2;
  end else
    roms[rom].bytes[byt][1]:=false;
  if int=1 then begin
    roms[rom].bytes[byt][0]:=true;
  end else
    roms[rom].bytes[byt][0]:=false;

end;

procedure TForm1.addS(romN:integer);
var r, i, j, num: integer;
begin
  for r:=0 to romN do begin
    for i:=0 to 7 do begin
      num:=0;
      if roms[r].bytes[3][i] then num:=num+8;
      if roms[r].bytes[2][i] then num:=num+4;
      if roms[r].bytes[1][i] then num:=num+2;
      if roms[r].bytes[0][i] then num:=num+1;
      for j:=0 to 3 do roms[r].bytes[j][i]:= false;
//if r=0 then memo1.lines.add(intToHex(num));
      roms[r].Str[i]:=intToHex(num)+roms[r].Str[i];
    end;
  end;
end;

function TForm1.intToHex (int:integer):string;
begin
  case int of
    15: result:='f';
    14: result:='e';
    13: result:='d';
    12: result:='c';
    11: result:='b';
    10: result:='a';
  else
     result:=IntToStr(int);
  end;
end;

procedure TForm1.simul (hex: string; str: tstrings);
var i, j: integer;
//    str: tstrings;
    s: string;
begin
  str.Clear;

  str.Add('');
  str.Add('///');
  str.Add('/// created by oc8051 rom maker');
  str.Add('/// author: Simon Teran (simont@opencores.org)');
  str.Add('///');
  str.Add('/// source file: '+edtIn.Text);
  str.Add('/// date: '+ datetoStr(date));
  str.Add('/// time: '+ timeToStr(time));
  str.Add('///');
  str.Add('');
  str.Add('module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);');
  str.Add('');
  str.Add('parameter INT_ROM_WID= '+intToStr(strToInt(copy(hex,1,2))) +';');
  str.Add('');
  str.Add('input rst, clk;');
  str.Add('input [15:0] addr;');
  str.Add('output ea_int;');
  str.Add('output [7:0] data1, data2, data3;');
  str.Add('reg ea_int;');
  str.Add('reg [7:0] data1, data2, data3;');
  str.Add('reg [7:0] buff [65535:0];');
  str.Add('integer i;');
  str.Add('');
  str.Add('wire ea;');
  str.Add('');
  str.Add('assign ea = | addr[15:INT_ROM_WID];');
  str.Add('');
  str.Add('initial');
  str.Add('begin');
  str.Add('    for (i=0; i<65536; i=i+1)');
  str.Add('      buff [i] = 8''h00;');
  str.Add('#2');
  str.Add('');

  hex := copy(hex,3,length(hex)-2);
  for i:=0 to (length(hex) div 2)-1 do begin
    s:='    buff [16''h';
    s:=s+intToHex(i div 4096);
    j:=i mod 4096;
    s:=s+intToHex(j div 256);
    j:=j mod 256;
    s:=s+'_'+intToHex(j div 16)+intToHex(j mod 16);
    S:=s+'] = 8''h';
    S:=s+copy(Hex,(i*2)+1,2)+';';
    str.Add(s);
  end;

  str.Add('end');
  str.Add('');
  str.Add('always @(posedge clk)');
  str.Add('begin');
  str.Add('  data1 <= #1 buff [addr];');
  str.Add('  data2 <= #1 buff [addr+1];');
  str.Add('  data3 <= #1 buff [addr+2];');
  str.Add('end');
  str.Add('');
  str.Add('always @(posedge clk or posedge rst)');
  str.Add(' if (rst)');
  str.Add('   ea_int <= #1 1''b1;');
  str.Add('  else ea_int <= #1 !ea;');
  str.Add('');
  str.Add('endmodule');

//  memo1.Lines.Clear;
//  memo1.Lines.AddStrings(str);

end;

procedure TForm1.syn (hex: string; str: tstrings);
var addrw, i, cntR, cntB:integer;
    tmp, astr: string;
//    str:tstrings;
begin
  str.Add('');
  str.Add('///');
  str.Add('/// created by oc8051 rom maker');
  str.Add('/// author: Simon Teran (simont@opencores.org)');
  str.Add('///');
  str.Add('/// source file: '+edtIn.Text);
  str.Add('/// date: '+ datetoStr(date));
  str.Add('/// time: '+ timeToStr(time));
  str.Add('///');
  str.Add('');
  astr:= '';
  addrw:=strToInt(copy(hex,1,2))-1;
  str.add('module ROM32X1(O, A0, A1, A2, A3, A4); // synthesis syn_black_box syn_resources="luts=2"');
  str.add('output O;');
  for i:= 0 to 4 do
    str.add('input A'+IntToStr(i)+';');
  str.add('endmodule');
  str.add('');
  str.add('//rom for 8051 processor');
  str.add('');

  str.Add('module oc8051_rom (rst, clk, addr, ea_int, data1, data2, data3);');
  str.Add('');
  str.Add('parameter INT_ROM_WID= '+intToStr(strToInt(copy(hex,1,2))) +';');
  str.Add('');
  str.Add('input rst, clk;');
  str.Add('input [15:0] addr;');
  str.Add('output ea_int;');
  str.Add('output [7:0] data1, data2, data3;');
  str.Add('reg ea_int;');
  str.add('reg [4:0] addr01;');
  str.Add('reg [7:0] data1, data2, data3;');
  str.Add('');
  str.Add('wire ea;');
  str.add('wire [15:0] addr_rst;');
  tmp := 'wire [7:0] int_data0, int_data1, int_data2, int_data3';
  for i:= 4 to n2(addrw-5)-1 do tmp:= tmp+', int_data'+intToStr(i);
  str.add(tmp+';');
  str.Add('');
  str.Add('assign ea = | addr[15:INT_ROM_WID];');
  str.add('');
  str.add('assign addr_rst = rst ? 16''h0000 : addr;');
  str.add('');
  str.add('  rom0 rom_0 (.a(addr01), .o(int_data0));');
  str.add('  rom1 rom_1 (.a(addr01), .o(int_data1));');
  for i:=2 to n2(addrw-5)-1 do
    str.add('  rom'+IntToStr(i)+' rom_'+IntToStr(i)+' (.a(addr_rst['+IntToStr(addrw)+':'+IntToStr(addrw-4)+']), .o(int_data'+IntToStr(i)+'));');
  str.add('');
  str.add('always @(addr_rst)');
  str.add('begin');
  str.add('  if (addr_rst[1])');
  str.add('    addr01= addr_rst['+IntToStr(addrw)+':'+IntToStr(addrw-4)+']+ 5''h1;');
  str.add('  else');
  str.add('    addr01= addr_rst['+IntToStr(addrw)+':'+IntToStr(addrw-4)+'];');
  str.add('end');
  str.add('');
  str.add('//');
  str.add('// always read tree bits in row');
  str.add('always @(posedge clk)');
  str.add('begin');
  str.add('  case(addr['+IntToStr(addrw-5)+':0])');
  for i:=0 to n2(addrw-5)-1 do begin
    str.add('    '+IntToStr(addrw-4)+'''d'+intToStr(i)+': begin');
    str.add('      data1 <= #1 int_data'+intToStr(i)+';');
    str.add('      data2 <= #1 int_data'+intToStr((i+1) mod n2(addrw-5))+';');
    str.add('      data3 <= #1 int_data'+intToStr((i+2) mod n2(addrw-5))+';');
    str.add('	end');
  end;
  str.add('    default: begin');
  str.add('      data1 <= #1 8''h00;');
  str.add('      data2 <= #1 8''h00;');
  str.add('      data3 <= #1 8''h00;');
  str.add('	end');
  str.add('  endcase');
  str.add('end');
  str.add('');
  str.Add('always @(posedge clk or posedge rst)');
  str.Add(' if (rst)');
  str.Add('   ea_int <= #1 1''b1;');
  str.Add('  else ea_int <= #1 !ea;');
  str.Add('');
  str.add('endmodule');
  str.add('');
  str.add('');

  hex := copy(hex,3,length(hex)-2);

  //init roms
  for cntR:= 0 to n2(addrw-5)-1 do begin
    for cntB:= 0 to 7 do begin
      roms[cntR].str[cntB]:='';
    end;
  end;

  cntR:=0;
  cntB:=0;
  for i:=0 to (length(Hex) div 2)-1 do begin
    AddB(cntR, cntB, copy(Hex,(i*2)+1,2));
    if (cntB=3) and (cntR=n2(addrw-5)-1) then begin
      addS(n2(addrw-5)-1);
      cntR:=0;
      cntB:=0;
    end else begin
      if (cntR=n2(addrw-5)-1) then begin
        inc(cntB);
        cntR:=0;
      end else inc(cntR);
    end;
  end;
  addS(n2(addrw-5)-1);


  astr:='';
  for i:=length(roms[0].str[0]) to 7 do astr := astr+'0';


  tmp:='';
  for i:=0 to 4 do tmp:=tmp+',a['+IntToStr(i)+']';

  for cntR:= 0 to n2(addrw-5)-1 do begin
    str.add('//rom'+intToStr(cntR));
    str.add('module rom'+intToStr(cntR)+' (o,a);');
    str.add('input [4:0] a;');
    str.add('output [7:0] o;');
    for cntB:= 0 to 7 do begin
      str.add('ROM32X1 u'+intToStr(cntB)+' (o['+intToStr(cntB)+']'+tmp+') /* synthesis xc_props="INIT='+astr+roms[cntR].str[cntB]+'" */;');
    end;
    str.add('endmodule');
    str.add('');
  end;

end;

procedure TForm1.btnExitClick(Sender: TObject);
begin
  close;
end;

procedure TForm1.btnMakeClick(Sender: TObject);
var str:tstrings;
    s: string;
begin
  if not fileexists(edtIn.Text) then raise exception.Create('File '''+edtIn.Text+''' don''t exist!!');
  if edtOut.Text='' then raise exception.Create('Output file not....');

  str:= tstringlist.Create;

  s:=makeV(edtIn.Text);
  case rgout.ItemIndex of
    0: simul(s, str);
    1: syn(s, str);
    2: simulIn(s, str);
  end;

  str.SaveToFile(edtOut.Text);
  str.free;

  showmessage('OK');
end;

procedure TForm1.sbInClick(Sender: TObject);
begin
  if od1.Execute then begin
    edtIn.Text:= od1.FileName;
    if rgOut.ItemIndex=2 then
      edtOut.Text:= copy(od1.FileName, 1, length(od1.FileName)-3)+'in'
    else
      edtOut.Text:= copy(od1.FileName, 1, length(od1.FileName)-3)+'v';
  end
end;

procedure TForm1.sbOutClick(Sender: TObject);
begin
  if sd1.Execute then
    edtOut.Text:= sd1.FileName;
end;

function TForm1.inToBits (int:integer): string;
begin
  case int of
    0..127: result := '07';
    128..255: result := '08';
    256..511: result := '09';
    512..1023: result := '10';
    1024..2047: result := '11';
    2048..4095: result := '12';
    4096..8191: result := '13';
    8192..16383: result := '14';
    16384..32767: result := '15';
  else result := '16';
  end;
end;

function TForm1.n2 (n: integer):integer;
var i: integer;
begin
  result:=1;
  for i:=0 to n do result:= result * 2;
end;

procedure TForm1.FormCreate(Sender: TObject);
var ini: tInifile;
begin
  ini := TIniFile.Create('RomMaker.ini');
  edtIn.text:= ini.ReadString('settings', 'inFile', '');
  edtOut.text:= ini.ReadString('settings', 'OutFile', '');
  RgOut.ItemIndex:= ini.ReadInteger('settings', 'Select', 0);
  od1.FileName:=ini.ReadString('settings', 'inFile', '');
  ini.free;
end;

procedure TForm1.FormDestroy(Sender: TObject);
var ini: tInifile;
begin
  ini := TIniFile.Create('RomMaker.ini');
  ini.WriteString('settings', 'inFile', edtIn.text);
  ini.WriteString('settings', 'OutFile', edtOut.text);
  ini.WriteInteger('settings', 'Select', RgOut.ItemIndex);
  ini.free;
end;

procedure TForm1.simulIn (hex: string; str: tstrings);
var i: integer;
begin
  str.Clear;
  str.Add('///');
  str.Add('/// created by oc8051 rom maker');
  str.Add('/// author: Simon Teran (simont@opencores.org)');
  str.Add('///');
  str.Add('/// source file: '+edtIn.Text);
  str.Add('/// date: '+ datetoStr(date));
  str.Add('/// time: '+ timeToStr(time));
  str.Add('///');

  hex := copy(hex,3,length(hex)-2);
  for i:=0 to (length(hex) div 2)-1 do
    str.Add(copy(Hex,(i*2)+1,2));
//  for i:=(length(hex) div 2) to 65535 do
//    str.Add('00');

//  memo1.Lines.Clear;
//  memo1.Lines.AddStrings(str);

end;

end.
