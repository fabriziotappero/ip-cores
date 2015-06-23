// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@sympatico.ca
//
// Raptor64Div.v
//  - 64 bit divider
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
module Raptor64Div(rst, clk, ld, sgn, isDivi, a, b, imm, qo, ro, dvByZr, done);
parameter DIV=3'd3;
parameter IDLE=3'd4;
parameter DONE=3'd5;
input clk;
input rst;
input ld;
input sgn;
input isDivi;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
output [63:0] qo;
reg [63:0] qo;
output [63:0] ro;
reg [63:0] ro;
output done;
output dvByZr;
reg dvByZr;

reg [63:0] aa,bb;
reg so;
reg [2:0] state;
reg [7:0] cnt;
wire cnt_done = cnt==8'd0;
assign done = state==DONE;
reg ce1;
reg [63:0] q;
reg [64:0] r;
wire b0 = bb <= r;
wire [63:0] r1 = b0 ? r - bb : r;

always @(posedge clk)
if (rst) begin
	aa <= 64'd0;
	bb <= 64'd0;
	q <= 64'd0;
	r <= 64'd0;
	qo <= 64'd0;
	ro <= 64'd0;
	cnt <= 8'd0;
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
			q <= a[63] ? -a : a;
			bb <= isDivi ? (imm[63] ? -imm : imm) :(b[63] ? -b : b);
			so <= isDivi ? a[63] ^ imm[63] : a[63] ^ b[63];
		end
		else begin
			q <= a;
			bb <= isDivi ? imm : b;
			so <= 1'b0;
			$display("bb=%d", isDivi ? imm : b);
		end
		dvByZr <= isDivi ? imm==64'd0 : b==64'd0;
		r <= 64'd0;
		cnt <= 8'd65;
		state <= DIV;
	end
DIV:
	if (!cnt_done) begin
		$display("cnt:%d r1=%h q[63:0]=%h", cnt,r1,q);
		q <= {q[62:0],b0};
		r <= {r1,q[63]};
	end
	else begin
		$display("cnt:%d r1=%h q[63:0]=%h", cnt,r1,q);
		if (sgn) begin
			if (so) begin
				qo <= -q;
				ro <= -r[64:1];
			end
			else begin
				qo <= q;
				ro <= r[64:1];
			end
		end
		else begin
			qo <= q;
			ro <= r[64:1];
		end
		state <= DONE;
	end
DONE:
	state <= IDLE;
endcase
end

endmodule

module Raptor64Div_tb();

reg rst;
reg clk;
reg ld;
wire done;
wire [63:0] qo,ro;

initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
	#100 ld = 1;
	#150 ld = 0;
end

always #10 clk = ~clk;	//  50 MHz


Raptor64Div u1
(
	.rst(rst),
	.clk(clk),
	.ld(ld),
	.sgn(1'b1),
	.isDivi(1'b0),
	.a(64'd10005),
	.b(64'd27),
	.imm(64'd123),
	.qo(qo),
	.ro(ro),
	.dvByZr(),
	.done(done)
);

endmodule

