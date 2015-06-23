/*
Author: Sebastien Riou (acapola)
Creation date: 22:22:43 01/10/2011 

$LastChangedDate: 2011-03-07 14:17:52 +0100 (Mon, 07 Mar 2011) $
$LastChangedBy: acapola $
$LastChangedRevision: 18 $
$HeadURL: file:///svn/iso7816_3_master/iso7816_3_master/trunk/test/FiDiAnalyzer.v $				 

This file is under the BSD licence:
Copyright (c) 2011, Sebastien Riou

All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer. 
Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution. 
The names of contributors may not be used to endorse or promote products derived from this software without specific prior written permission. 
THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
"AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR
CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
`default_nettype none


module FiDiAnalyzer(
	input wire [3:0] fiCode,
	input wire [3:0] diCode,
	output wire [12:0] fi,
	output reg [7:0] di,
	output reg [12:0] cyclesPerEtu, //truncate values to 'floor' integer value
	output wire [7:0] fMax				//in 0.1MHz units
	);

reg [13+8-1:0] fiStuff;
assign {fi,fMax} = fiStuff;
always @(*) begin:fiBlock
	case(fiCode)
		4'b0000: fiStuff = {12'd0372,8'd040};
		4'b0001: fiStuff = {12'd0372,8'd050};
		4'b0010: fiStuff = {12'd0558,8'd060};
		4'b0011: fiStuff = {12'd0744,8'd080};
		4'b0100: fiStuff = {12'd1116,8'd120};
		4'b0101: fiStuff = {12'd1488,8'd160};
		4'b0110: fiStuff = {12'd1860,8'd200};
		4'b0111: fiStuff = {12'd0000,8'd000};
		4'b1000: fiStuff = {12'd0000,8'd000};
		4'b1001: fiStuff = {12'd0512,8'd050};
		4'b1010: fiStuff = {12'd0768,8'd075};
		4'b1011: fiStuff = {12'd1024,8'd100};
		4'b1100: fiStuff = {12'd1536,8'd150};
		4'b1101: fiStuff = {12'd2048,8'd200};
		4'b1110: fiStuff = {12'd0000,8'd000};
		4'b1111: fiStuff = {12'd0000,8'd000};
	endcase
end

always @(*) begin:diBlock
	case(diCode)
		4'b0000: di = 0;
		4'b0001: di = 1;
		4'b0010: di = 2;
		4'b0011: di = 4;
		4'b0100: di = 8;
		4'b0101: di = 16;
		4'b0110: di = 32;
		4'b0111: di = 64;
		4'b1000: di = 0;
		4'b1001: di = 12;
		4'b1010: di = 20;
		4'b1011: di = 0;
		4'b1100: di = 0;
		4'b1101: di = 0;
		4'b1110: di = 0;
		4'b1111: di = 0;
	endcase
end

always @(*) begin:cyclesPerEtuBlock
	case({fiCode,diCode})
		8'h01: cyclesPerEtu = 372/1;
		8'h02: cyclesPerEtu = 372/2;
		8'h03: cyclesPerEtu = 372/4;
		8'h04: cyclesPerEtu = 372/8;
		8'h05: cyclesPerEtu = 372/16;
		8'h06: cyclesPerEtu = 372/32;
		8'h07: cyclesPerEtu = 372/64;
		8'h09: cyclesPerEtu = 372/12;
		8'h0A: cyclesPerEtu = 372/20;
		
		8'h11: cyclesPerEtu = 372/1;
		8'h12: cyclesPerEtu = 372/2;
		8'h13: cyclesPerEtu = 372/4;
		8'h14: cyclesPerEtu = 372/8;
		8'h15: cyclesPerEtu = 372/16;
		8'h16: cyclesPerEtu = 372/32;
		8'h17: cyclesPerEtu = 372/64;
		8'h19: cyclesPerEtu = 372/12;
		8'h1A: cyclesPerEtu = 372/20;
		
		8'h21: cyclesPerEtu = 558/1;
		8'h22: cyclesPerEtu = 558/2;
		8'h23: cyclesPerEtu = 558/4;
		8'h24: cyclesPerEtu = 558/8;
		8'h25: cyclesPerEtu = 558/16;
		8'h26: cyclesPerEtu = 558/32;
		8'h27: cyclesPerEtu = 558/64;
		8'h29: cyclesPerEtu = 558/12;
		8'h2A: cyclesPerEtu = 558/20;
		
		8'h31: cyclesPerEtu = 744/1;
		8'h32: cyclesPerEtu = 744/2;
		8'h33: cyclesPerEtu = 744/4;
		8'h34: cyclesPerEtu = 744/8;
		8'h35: cyclesPerEtu = 744/16;
		8'h36: cyclesPerEtu = 744/32;
		8'h37: cyclesPerEtu = 744/64;
		8'h39: cyclesPerEtu = 744/12;
		8'h3A: cyclesPerEtu = 744/20;
		
		8'h41: cyclesPerEtu = 1116/1;
		8'h42: cyclesPerEtu = 1116/2;
		8'h43: cyclesPerEtu = 1116/4;
		8'h44: cyclesPerEtu = 1116/8;
		8'h45: cyclesPerEtu = 1116/16;
		8'h46: cyclesPerEtu = 1116/32;
		8'h47: cyclesPerEtu = 1116/64;
		8'h49: cyclesPerEtu = 1116/12;
		8'h4A: cyclesPerEtu = 1116/20;
		
		8'h51: cyclesPerEtu = 1488/1;
		8'h52: cyclesPerEtu = 1488/2;
		8'h53: cyclesPerEtu = 1488/4;
		8'h54: cyclesPerEtu = 1488/8;
		8'h55: cyclesPerEtu = 1488/16;
		8'h56: cyclesPerEtu = 1488/32;
		8'h57: cyclesPerEtu = 1488/64;
		8'h59: cyclesPerEtu = 1488/12;
		8'h5A: cyclesPerEtu = 1488/20;
		
		8'h61: cyclesPerEtu = 1860/1;
		8'h62: cyclesPerEtu = 1860/2;
		8'h63: cyclesPerEtu = 1860/4;
		8'h64: cyclesPerEtu = 1860/8;
		8'h65: cyclesPerEtu = 1860/16;
		8'h66: cyclesPerEtu = 1860/32;
		8'h67: cyclesPerEtu = 1860/64;
		8'h69: cyclesPerEtu = 1860/12;
		8'h6A: cyclesPerEtu = 1860/20;
		
		8'h91: cyclesPerEtu = 512/1;
		8'h92: cyclesPerEtu = 512/2;
		8'h93: cyclesPerEtu = 512/4;
		8'h94: cyclesPerEtu = 512/8;
		8'h95: cyclesPerEtu = 512/16;
		8'h96: cyclesPerEtu = 512/32;
		8'h97: cyclesPerEtu = 512/64;
		8'h99: cyclesPerEtu = 512/12;
		8'h9A: cyclesPerEtu = 512/20;
		
		8'hA1: cyclesPerEtu = 768/1;
		8'hA2: cyclesPerEtu = 768/2;
		8'hA3: cyclesPerEtu = 768/4;
		8'hA4: cyclesPerEtu = 768/8;
		8'hA5: cyclesPerEtu = 768/16;
		8'hA6: cyclesPerEtu = 768/32;
		8'hA7: cyclesPerEtu = 768/64;
		8'hA9: cyclesPerEtu = 768/12;
		8'hAA: cyclesPerEtu = 768/20;
		
		8'hB1: cyclesPerEtu = 1024/1;
		8'hB2: cyclesPerEtu = 1024/2;
		8'hB3: cyclesPerEtu = 1024/4;
		8'hB4: cyclesPerEtu = 1024/8;
		8'hB5: cyclesPerEtu = 1024/16;
		8'hB6: cyclesPerEtu = 1024/32;
		8'hB7: cyclesPerEtu = 1024/64;
		8'hB9: cyclesPerEtu = 1024/12;
		8'hBA: cyclesPerEtu = 1024/20;
		
		8'hC1: cyclesPerEtu = 1536/1;
		8'hC2: cyclesPerEtu = 1536/2;
		8'hC3: cyclesPerEtu = 1536/4;
		8'hC4: cyclesPerEtu = 1536/8;
		8'hC5: cyclesPerEtu = 1536/16;
		8'hC6: cyclesPerEtu = 1536/32;
		8'hC7: cyclesPerEtu = 1536/64;
		8'hC9: cyclesPerEtu = 1536/12;
		8'hCA: cyclesPerEtu = 1536/20;
		
		8'hD1: cyclesPerEtu = 2048/1;
		8'hD2: cyclesPerEtu = 2048/2;
		8'hD3: cyclesPerEtu = 2048/4;
		8'hD4: cyclesPerEtu = 2048/8;
		8'hD5: cyclesPerEtu = 2048/16;
		8'hD6: cyclesPerEtu = 2048/32;
		8'hD7: cyclesPerEtu = 2048/64;
		8'hD9: cyclesPerEtu = 2048/12;
		8'hDA: cyclesPerEtu = 2048/20;
		
		default: cyclesPerEtu = 0;//RFU
	endcase
end
		
endmodule
`default_nettype wire

