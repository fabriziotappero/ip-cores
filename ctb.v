//
// This is a simple test bench for the confuser
//
// Author: Morris Jones
// San Jose State University
//
//

//`timescale 1ns/100ps

module ctb(clk,reset,push,din,Caddr,Cdata,Cpush,pushout,stopout,dout,sid0,sid1,
		sid2,sid3,sid4);
input clk;
output reset;
output push;
output [7:0] din;
input [7:0] dout;
input [31:0] sid0,sid1,sid2,sid3,sid4;
output [6:0] Caddr;
output [7:0] Cdata;
input pushout;
output stopout;
output Cpush;

reg [6:0] Caddr_raw;
reg [7:0] Cdata_raw;
reg Cpush_raw;
reg push_raw;
reg reset_raw;
reg [7:0] din_raw;
reg stopout_raw;

reg [7:0] fifo[0:65536*2];
reg [16:0] rp,wp;
reg [7:0] fifout[0:65536*2];
reg [17:0] rpo,wpo;


reg [160:0] crc[0:3];
//
// This is the pad registers
//
reg [159:0] pad0;
reg [160:0] pad1;
reg [161:0] pad2;
reg [162:0] pad3;
reg [31:0] injector;
reg [39:0] padsel;
reg [31:0] cdata;

//
// X^160+X^139+X^119+X^98+X^79+X^40+X^20+1
//
//                                     1        9	       6	       3        0
//                                     2        6        4        2
//                                     8
//
parameter [159:0] poly0=   160'H00000800_00800004_00008000_00000100_00100001;
//
//  X161+X140+X121+X100+X80+X60+X40+X20+1
//
parameter [160:0] poly1= 161'H0_00001000_02000010_00010000_10000100_00100001;
//
//  X162+X141+X121+X100 +X80+X60+X40+X20+1
//
//                                     1        9	       6	       3        0
//                                     2        6        4        2
//                                     8
//

parameter [161:0] poly2= 162'H0_00002000_02000010_00010000_10000100_00100001;
//
//  X163+X142+X122+X102+X82+X61+X41+X20+1
//
//                                     1        9	       6	       3        0
//                                     2        6        4        2
//                                     8
//
parameter [162:0] poly3= 162'H0_00004000_04000040_00040000_20000200_00100001;

//
// X32+X27+X21+X16+X10+X5+1
//
parameter [31:0] pinjector=32'H0821_0421;

//
// X40+X34+X27+X19+X12+X6+1
//
parameter [39:0] ppadsel = 40'H04_0808_1041;

//
// X32+X31+X29+X28+X26+X25+X24+X22+X21+X13+X11+X9+X8+X5+1
//
parameter [31:0] pcdata= 32'HB760_2B21;

integer fbt[0:3];

integer i;
integer data_out=0;

task per;
input [7:0] data;
begin
	fifo[wp]=data;
	wp=wp+1;
	data_out=data_out+1;
	if(wp==rp) $display("Come on Morris, FIFO overflow");
end
endtask

task pod;
input [7:0] data;
begin
	fifout[wpo]=data;
	wpo=wpo+1;
	if(wpo==rpo) $display("You overan the output fifo Morris");
end
endtask

task setpad;
input [6:0] regsel;
input [7:0] regval;
begin
//$display("Setting %d to %h",regsel,regval);
	case (regsel)
	// pad0
	 0:  pad0[  7:  0]=regval;
	 1:  pad0[ 15:  8]=regval;
	 2:  pad0[ 23: 16]=regval;
	 3:  pad0[ 31: 24]=regval;
	 4:  pad0[ 39: 32]=regval;
	 5:  pad0[ 47: 40]=regval;
	 6:  pad0[ 55: 48]=regval;
	 7:  pad0[ 63: 56]=regval;
	 8:  pad0[ 71: 64]=regval;
	 9:  pad0[ 79: 72]=regval;
	 10: pad0[ 87: 80]=regval;
	 11: pad0[ 95: 88]=regval;
	 12: pad0[103: 96]=regval;
	 13: pad0[111:104]=regval;
	 14: pad0[119:112]=regval;
	 15: pad0[127:120]=regval;
	 16: pad0[135:128]=regval;
	 17: pad0[143:136]=regval;
	 18: pad0[151:144]=regval;
	 19: pad0[159:152]=regval;
	 20: ;
	 // pad1
	 21: pad1[  7:  0]=regval;
	 22: pad1[ 15:  8]=regval;
	 23: pad1[ 23: 16]=regval;
	 24: pad1[ 31: 24]=regval;
	 25: pad1[ 39: 32]=regval;
	 26: pad1[ 47: 40]=regval;
	 27: pad1[ 55: 48]=regval;
	 28: pad1[ 63: 56]=regval;
	 29: pad1[ 71: 64]=regval;
	 30: pad1[ 79: 72]=regval;
	 31: pad1[ 87: 80]=regval;
	 32: pad1[ 95: 88]=regval;
	 33: pad1[103: 96]=regval;
	 34: pad1[111:104]=regval;
	 35: pad1[119:112]=regval;
	 36: pad1[127:120]=regval;
	 37: pad1[135:128]=regval;
	 38: pad1[143:136]=regval;
	 39: pad1[151:144]=regval;
	 40: pad1[159:152]=regval;
	 41: pad1[160]=regval[0];
	 // pad2
	 42: pad2[  7:  0]=regval;
	 43: pad2[ 15:  8]=regval;
	 44: pad2[ 23: 16]=regval;
	 45: pad2[ 31: 24]=regval;
	 46: pad2[ 39: 32]=regval;
	 47: pad2[ 47: 40]=regval;
	 48: pad2[ 55: 48]=regval;
	 49: pad2[ 63: 56]=regval;
	 50: pad2[ 71: 64]=regval;
	 51: pad2[ 79: 72]=regval;
	 52: pad2[ 87: 80]=regval;
	 53: pad2[ 95: 88]=regval;
	 54: pad2[103: 96]=regval;
	 55: pad2[111:104]=regval;
	 56: pad2[119:112]=regval;
	 57: pad2[127:120]=regval;
	 58: pad2[135:128]=regval;
	 59: pad2[143:136]=regval;
	 60: pad2[151:144]=regval;
	 61: pad2[159:152]=regval;
	 62: pad2[161:160]=regval[1:0];
	// pad3
	 63: pad3[  7:  0]=regval;
	 64: pad3[ 15:  8]=regval;
	 65: pad3[ 23: 16]=regval;
	 66: pad3[ 31: 24]=regval;
	 67: pad3[ 39: 32]=regval;
	 68: pad3[ 47: 40]=regval;
	 69: pad3[ 55: 48]=regval;
	 70: pad3[ 63: 56]=regval;
	 71: pad3[ 71: 64]=regval;
	 72: pad3[ 79: 72]=regval;
	 73: pad3[ 87: 80]=regval;
	 74: pad3[ 95: 88]=regval;
	 75: pad3[103: 96]=regval;
	 76: pad3[111:104]=regval;
	 77: pad3[119:112]=regval;
	 78: pad3[127:120]=regval;
	 79: pad3[135:128]=regval;
	 80: pad3[143:136]=regval;
	 81: pad3[151:144]=regval;
	 82: pad3[159:152]=regval;
	 83: pad3[162:160]=regval[2:0];
	 // injector
	 84: injector[ 7: 0]=regval;
	 85: injector[15: 8]=regval;
	 86: injector[23:16]=regval;
	 87: injector[31:24]=regval;
	 // padsel
	 88: padsel[ 7: 0]=regval;
	 89: padsel[15: 8]=regval;
	 90: padsel[23:16]=regval;
	 91: padsel[31:24]=regval;
	 92: padsel[39:32]=regval;
	 
	 default: ;
	endcase
	Cdata_raw=regval;
	Caddr_raw=regsel;
	Cpush_raw=1;
	@(posedge(clk));
	#0.1;
	Cdata_raw=R8(3);
	Caddr_raw=R8(3);
	Cpush_raw=0;
	#0.1;
	if(R8(3) > 125) begin
	  @(posedge(clk));
	  #0.2;
	end
	
end
endtask

assign Cdata=Cdata_raw;
assign Caddr=Caddr_raw;
assign Cpush=Cpush_raw;
assign push=push_raw;
assign stopout=stopout_raw;
//
// loads up a set of data for the routine...
//
task loadkey;
integer i;
reg [7:0] rr;
begin
  @(posedge(clk));
  #0.1;
  for(i=0; i < 95; i=i+1) begin
        rr=R8(i&4);
        setpad(i,rr);
  end
end

endtask
//
//
//

//
function [31:0] scrc;
input [1:0] wh;
reg [160:0] wcrc;
reg top;
integer i;
begin
	wcrc=crc[wh];
	for(i=0; i < 67; i=i+1) begin
	  top=wcrc[160];
	  wcrc= { wcrc[159:0],top };
	  if(top) begin
	    wcrc[fbt[wh]]=~wcrc[fbt[wh]];
	  end
	end
//$display("scrc wh %d scrcval %h",wh,wcrc[63:32]);
        crc[wh]=wcrc;
	scrc=wcrc[63:32];
end

endfunction
//
//
//
function [7:0] R8;
input [1:0] wh;
reg[31:0] wr;
begin
	wr = scrc(wh);
	wr=wr >> wr[31:29];
	R8=wr[7:0];
end
endfunction

task stepPad0;
reg hob;
begin
	hob=pad0[159];
	pad0={pad0[158:0],1'B0};
	if(hob) pad0 = pad0 ^ poly0;
end
endtask

task stepPad1;
reg hob;
begin
	hob=pad1[160];
	pad1={pad1[159:0],1'B0};
	if(hob) pad1 = pad1 ^ poly1;
end
endtask

task waitempty;
integer ix;
integer wt;
begin
	wt=data_out*150;
	while(data_out > 0) begin
		@(posedge(clk));
		wt=wt-1;
		if(wt <= 0) begin
			$display("Ran out of time waiting for you to send back all the answers");
			$finish;
		end
	end
	for(ix=0; ix < 300; ix=ix+1) @(posedge(clk));
end
endtask


task stepPad2;
reg hob;
begin
	hob=pad2[161];
	pad2={pad2[160:0],1'B0};
	if(hob) pad2 = pad2 ^ poly2;
end
endtask

task stepPad3;
reg hob;
begin
	hob=pad3[162];
	pad3={pad3[161:0],1'B0};
	if(hob) pad3 = pad3 ^ poly3;
end
endtask
//
// Move all 4 pads forward one
//
task stepPads;
begin
	stepPad0;
	stepPad1;
	stepPad2;
	stepPad3;
end
endtask
//
// steps the injector forward one...
//
task stepinjector;
reg hob;
begin
	hob=injector[31];
	injector={injector[30:0],1'B0};
	if(hob) injector=injector ^ pinjector;
//  $display(" si %h",injector);
end
endtask
//
// This steps the pad selector
//
task steppadsel;
reg hob;
begin
	hob=padsel[39];
	padsel={padsel[38:0],1'B0};
	if(hob) padsel=padsel ^ ppadsel;
end
endtask
//
// Steps the bit provided as bitin into the cdata register
//
task stepcdata;
input bitin;
reg hob;
begin
//  $display("pad3 %h ps %d padsel %h pad %b crc %h",pad3,
//  {padsel[31],padsel[3],padsel[5],padsel[19],padsel[8]}
//  ,padsel,bitin,cdata);
	hob=cdata[31];
	cdata={cdata[30:0],bitin};
	if(hob) cdata = cdata ^ pcdata;
end
endtask
function selpad;
input [1:0] dummy;
integer ps;
begin
	ps={padsel[31],padsel[3],padsel[5],padsel[19],padsel[8]};
	case(ps)
	  0: selpad=pad1[15];
	  1: selpad=pad0[37];
	  2: selpad=pad2[73];
	  3: selpad=pad3[99];
	  4: selpad=pad0[121];
	  5: selpad=pad1[130];
	  6: selpad=pad3[15];
	  7: selpad=pad2[9];
	  8: selpad=pad3[97];
	  9: selpad=pad2[140];
	  10: selpad=pad1[4];
	  11: selpad=pad0[88];
	  12: selpad=pad0[33];
	  13: selpad=pad1[75];
	  14: selpad=pad2[35];
	  15: selpad=pad3[155];
	  16: selpad=pad2[28];
	  17: selpad=pad1[150];
	  18: selpad=pad3[29];
	  19: selpad=pad0[144];
	  20: selpad=pad0[127];
	  21: selpad=pad1[125];
	  22: selpad=pad2[0];
	  23: selpad=pad3[5];
	  24: selpad=pad0[110];
	  25: selpad=pad3[87];
	  26: selpad=pad1[19];
	  27: selpad=pad2[82];
	  28: selpad=pad0[48];
	  29: selpad=pad1[47];
	  30: selpad=pad2[46];
	  31: selpad=pad3[51];
	endcase
end
endfunction
//
// confuse 4 bytes of information
//
integer pamt;

task conf4;
input [7:0] b3,b2,b1,b0;
integer ix;
begin
	while(data_out > 60000) @(posedge(clk));
	@(posedge(clk));
	cdata[31:24]=b3;
	cdata[23:16]=b2;
	cdata[15: 8]=b1;
	cdata[ 7: 0]=b0;
	per(b3);
	per(b2);
	per(b1);
	per(b0);
	pamt={1'b1,injector[30],injector[5],injector[9],injector[2],injector[27]};
	for(ix=0; ix < 39; ix=ix+1) stepinjector;
// $display("Stepped");
	for(ix=0; ix < pamt; ix=ix+1) begin
		stepcdata(selpad(0));
		stepPads;
		steppadsel;
	end
//$display("send CRC results %h",cdata);
	pod(cdata[31:24]);
	pod(cdata[23:16]);
	pod(cdata[15: 8]);
	pod(cdata[ 7: 0]);
        #40000;
end
endtask

//
// Set up the random number generator
//
integer ixw;
integer ixs;
initial begin
	Cpush_raw=0;
	push_raw=0;
	rp=0;
	wp=0;
	rpo=0;
	wpo=0;
	din_raw=8'Ha5;
	stopout_raw=0;
	#0.1;
//        $dumpfile("unconfuser.dump");
//        $dumpvars(0,ctb);
	$display("Starting up the test bench");
//      for(i=0; i < 32; i=i+1) begin
//              if(pcdata[i]==1) begin
//                      $display("cdata[%d]=1",i);
//              end
//      end
        crc[0]={sid0,sid1,sid2,sid3,sid4,1'b1};
	crc[1]={sid1,sid0,sid3,1'b1,sid2,sid4};
	crc[2]={sid3,sid2,sid4,sid1,1'b1,sid1};
	crc[3]={sid4,1'b1,sid3,sid2,sid1,sid0};
	fbt[0]=18;
	fbt[1]=39;
	fbt[2]=60;
	fbt[3]=101;
	reset_raw=1;	
	#55;
	reset_raw=0;
	loadkey;
	for(ixw=0; ixw<25; ixw=ixw+1) begin
		conf4(0,0,0,0);
	end
	for(ixw=0; ixw < 25; ixw=ixw+1) begin
		conf4(8'Hff,8'Hff,8'Hff,8'Hff);
	end
	for(ixs=0; ixs < 5; ixs=ixs+1) begin
	  $display("starting set %d",ixs);
	  waitempty;
	  loadkey;
	  for(ixw=0; ixw<2500; ixw=ixw+1) begin
		while(data_out > 65500) begin
			@(posedge(clk));
			#0.4;
		end
		conf4(R8(0),R8(0),R8(2),R8(1));
	  end
	end
	waitempty;
	$display("Run completed sucessfully");
	$finish;
end

assign reset=reset_raw;
//
// Check the data coming back...
//
always @(posedge(clk)) begin
	#0.1;
	if((pushout===1) && (stopout===0)) begin
	  if(rp==wp) begin
	    $display("Error --- You pushed something, and I'm not expecting anything");
	    $finish;
	  end
	  if(fifo[rp]===dout) begin
	    rp=rp+1;
	    data_out=data_out-1;
	  end
	  else begin
	    $display("Error --- Received %h expected %h",dout,fifo[rp]);
	    $finish;
	  end
	end
	stopout_raw=(R8(2)<66);
	
end

//
// Push data out to the fifo
//
always @(posedge(clk)) begin
	#1;
	push_raw=0;
	din_raw=R8(2);
	if(data_out < 56000) begin
	  if(rpo != wpo) begin
	    if(R8(3) < 150) begin
		push_raw=1;
		din_raw=fifout[rpo];
		rpo=rpo+1; 
		   
	    end
	  end
	end 
end
assign din=din_raw;


endmodule



