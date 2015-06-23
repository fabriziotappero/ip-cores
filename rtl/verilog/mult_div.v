// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// rtf65002.v
//  - 32 bit CPU multiplier/divider
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
`include "rtf65002_defines.v"

module mult_div(rst, clk, ld, op, fn, a, b, p, q, r, done);
parameter IDLE=3'd0;
parameter MULT1=3'd1;
parameter MULT2=3'd2;
parameter MULT3=3'd3;
parameter FIX_SIGN=3'd4;
parameter DIV=3'd5;
input rst;
input clk;
input ld;
input [8:0] op;
input [3:0] fn;
input [31:0] a;
input [31:0] b;
output reg [63:0] p;
output reg [31:0] q;
output reg [31:0] r;
output done;

reg [31:0] aa, bb;
reg res_sgn;

reg [2:0] state;

assign done = state==IDLE;
wire [31:0] diff = r - bb;
wire [31:0] pa = a[31] ? -a : a;
wire [63:0] p1 = aa * bb;
reg [5:0] cnt;

always @(posedge clk)
if (rst)
state <= IDLE;
else begin
case(state)
IDLE:
	if (ld) begin
		cnt <= 6'd32;
		case(op)
		`MUL_IMM8,`MUL_IMM16,`MUL_IMM32:
			begin
				aa <= a;
				bb <= b;
				res_sgn <= 1'b0;
				state <= MULT1;
			end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8,`DIV_IMM16,`DIV_IMM32,
		`MOD_IMM8,`MOD_IMM16,`MOD_IMM32:
			begin
				aa <= a;
				bb <= b;
				q <= a[30:0];
				r <= a[31];
				res_sgn <= 1'b0;
				state <= DIV;
			end
`endif
		`RR:
			case(fn)
			`MUL_RR:
				begin
					aa <= a;
					bb <= b;
					res_sgn <= 1'b0;
					state <= MULT1;
				end
			`MULS_RR:
				begin
					aa <= a[31] ? -a : a;
					bb <= b[31] ? -b : b;
					res_sgn <= a[31] ^ b[31];
					state <= MULT1;
				end
`ifdef SUPPORT_DIVMOD
			`DIV_RR,`MOD_RR:
				begin
					aa <= a;
					bb <= b;
					q <= a[30:0];
					r <= a[31];
					res_sgn <= 1'b0;
					state <= DIV;
				end
			`DIVS_RR,`MODS_RR:
				begin
					aa <= a[31] ? -a : a;
					bb <= b[31] ? -b : b;
					q <= pa[30:0];
					r <= pa[31];
					res_sgn <= a[31] ^ b[31];
					state <= DIV;
				end
`endif
			default:
				state <= IDLE;
			endcase
		endcase
	end
// Three waut states for the multiply to take effect. These are needed at
// higher clock frequencies. The multipler is a multi-cycle path that
// requires a timing constraint.
MULT1:	state <= MULT2;
MULT2:	state <= MULT3;
MULT3:	begin
			p <= p1;
			state <= res_sgn ? FIX_SIGN : IDLE;
		end

`ifdef SUPPORT_DIVMOD
DIV:
	begin
		q <= {q[30:0],~diff[31]};
		if (cnt==6'd0) begin
			state <= res_sgn ? FIX_SIGN : IDLE;
			if (diff[31])
				r <= r[30:0];
			else
				r <= diff[30:0];
		end
		else begin
			if (diff[31])
				r <= {r[30:0],q[31]};
			else
				r <= {diff[30:0],q[31]};
		end
		cnt <= cnt - 6'd1;
	end
`endif

FIX_SIGN:
	begin
		state <= IDLE;
		if (res_sgn) begin
			p <= -p;
			q <= -q;
			r <= -r;
		end
	end
default:	state <= IDLE;
endcase
end

endmodule

module multdiv_tb();
reg rst;
reg clk;
reg ld;

initial begin
	#0 clk = 1'b0;
	#0 rst = 1'b0;
	#10 rst = 1'b1;
	#10 rst = 1'b0;
	#10 ld = 1'b1;
	#20 ld = 1'b0;
end

always #10 clk = ~clk;

mult_div umd1 (
	.rst(rst),
	.clk(clk),
	.ld(ld),
	.op(`RR),
	.fn(`DIV_RR),
	.a(32'h12345678),
	.b(32'd10),
	.p(),
	.q(),
	.r(),
	.done()
);

endmodule
