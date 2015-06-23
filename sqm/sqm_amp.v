/*
	SQmusic
	logarithmic digital amplifier to use with SQMUSIC
  Version 0.1, tested on simulation only with Capcom's 1942

  (c) Jose Tejada Gomez, 9th May 2013
  You can use this file following the GNU GENERAL PUBLIC LICENSE version 3
  Read the details of the license in:
  http://www.gnu.org/licenses/gpl.txt
  
  Send comments to: jose.tejada@ieee.org

*/
`timescale 1ns / 1ps
module SQM_AMP(
	input [3:0]A, input [3:0]B, input [3:0]C, // input channels
	output [15:0] Y
);

wire[11:0] Alog, Blog, Clog;

SQM_LOG adac( .din(A), .dout(Alog) );
SQM_LOG bdac( .din(B), .dout(Blog) );
SQM_LOG cdac( .din(C), .dout(Clog) );
//always @(*)
assign Y=Alog+Blog+Clog;
endmodule

module SQM_LOG(
	input [3:0]din,
	output reg [11:0]dout );

always @(din)
	case (din)
		0: dout=0;
		1: dout=16;
		2: dout=19;
		3: dout=32;
		4: dout=39;
		5: dout=64;
		6: dout=78;
		7: dout=128;
		8: dout=155;
		9: dout=256;
	 10: dout=310;
	 11: dout=512;
	 12: dout=621;
	 13: dout=1024;
	 14: dout=1448;
	 15: dout=2048;
	endcase
	
endmodule
