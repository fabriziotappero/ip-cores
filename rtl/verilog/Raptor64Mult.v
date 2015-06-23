// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@sympatico.ca
//
// Raptor64Mult.v
//  - 64 bit multiplier
//
// This source file is free software: you can redistribute it and/or modify 
// it under the terms of the GNU Lesser General Public License as published 
// by the Free Software Foundation, either version 3 of the License, or     
// (at your option) any later version.                                      
//                                                                          
// This source file is distributed in the hope that it will be useful,      
// but WITHOUT ANY WARRANTY; without even the implied warranty of           
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the            
// GNU General Public License for more details.                             
//                                                                          
// You should have received a copy of the GNU General Public License        
// along with this program.  If not, see <http://www.gnu.org/licenses/>.    
//                                                                          
// ============================================================================
//
module Raptor64Mult(rst, clk, ld, sgn, isMuli, a, b, imm, o, done);
parameter SGNADJO=3'd2;
parameter MULT=3'd3;
parameter IDLE=3'd4;
parameter DONE=3'd5;
input clk;
input rst;
input ld;
input sgn;
input isMuli;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
output [127:0] o;
reg [127:0] o;
output done;

reg [63:0] aa,bb;
reg so;
reg [2:0] state;
reg [7:0] cnt;
wire cnt_done = cnt==8'd0;
assign done = state==DONE;
reg ce1;
reg [127:0] prod;
//wire [64:0] p1 = aa[0] ? prod[127:64] + b : prod[127:64];
//wire [65:0] p2 = aa[1] ? p1 + {b,1'b0} : p1;
wire [79:0] p1 = bb * aa[15:0] + prod[127:64];

always @(posedge clk)
if (rst) begin
	aa <= 64'd0;
	bb <= 64'd0;
	prod <= 128'd0;
	o <= 128'd0;
	state <= IDLE;
end
else
begin
if (!cnt_done)
	cnt <= cnt - 8'd1;

case(state)
IDLE:
	if (ld) begin
		if (sgn) begin
			aa <= a[63] ? -a : a;
			bb <= isMuli ? (imm[63] ? -imm : imm) :(b[63] ? -b : b);
			so <= isMuli ? a[63] ^ imm[63] : a[63] ^ b[63];
		end
		else begin
			aa <= a;
			bb <= isMuli ? imm : b;
			so <= 1'b0;
		end
		prod <= 128'd0;
		cnt <= 8'd4;
		state <= MULT;
	end
MULT:
	if (!cnt_done) begin
		aa <= {16'b0,aa[63:16]};
		prod <= {16'b0,prod[127:16]};
		prod[127:48] <= p1;
	end
	else begin
		if (sgn) begin
			if (so)
				o <= -prod;
			else
				o <= prod;
		end
		else
			o <= prod;
		state <= DONE;
	end
DONE:
	state <= IDLE;
endcase
end

endmodule

module Raptor64Mult_tb();

reg rst;
reg clk;
reg ld;
wire [127:0] o;

initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
	#100 ld = 1;
	#150 ld = 0;
end

always #10 clk = ~clk;	//  50 MHz


Raptor64Mult u1
(
	.rst(rst),
	.clk(clk),
	.ld(ld),
	.sgn(1'b1),
	.isMuli(1'b0),
	.a(64'd10005),
	.b(64'd1117),
	.imm(64'd27),
	.o(o)
);

endmodule

