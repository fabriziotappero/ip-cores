`timescale 1ns / 1ps
// ============================================================================
//        __
//   \\__/ o\    (C) 2012-2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//
// Cached Reciprocal Divider
// - Allows divides to be performed in three clock cycles by storing the
//   reciprocal of the divisor in a cache, then using a multiply for
//   subsequent divides.
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
module cr_div(rst, clk, addr, start, a, b, q, r, done);
parameter IDLE = 3'd1;
parameter RECIP = 3'd2;
parameter RECIP1 = 3'd3;
parameter DONE = 3'd4;
input rst;
input clk;
input [31:0] addr;
input start;
input [31:0] a;
input [31:0] b;
output [31:0] q;
output [31:0] r;
output done;

reg [2:0] state;
reg [31:0] bcache [0:63];		// 'b' is the cache tag
reg [31:0] recip_cache [0:63];	// cache of reciprocals
wire [63:0] prod = recip_cache[addr[7:2]] * a;
reg [31:0] q,r;
reg [7:0] cnt;
wire cnt_done = cnt==8'd0;
assign done = state==DONE;

wire b0 = b <= r;
wire [31:0] r1 = b0 ? r - b : r;

always @(posedge clk)
if (rst) begin
	state <= IDLE;
end
else begin
if (!cnt_done)
	cnt <= cnt - 8'd1;
case(state)
IDLE:
	if (start) begin
		// Note: we are calculating the inverse as a fraction less than one, so
		// we start by placing the dividend directly into the remainder field
		// rather than the quotient field as for a normal divide. We can save
		// 32 clock cycles this way. We know there would just be 32 leading
		// zeros because the fraction is less than one.
		q <= 32'd0;
		r <= 32'd1;
		if (b==1) begin
			q <= a;
			r <= 0;
			state <= DONE;
		end
		// Here is what speeds things up, if we find the reciprocal cached, the
		// quotient is returned right away after a multiply.
		else if (b==bcache[addr[7:2]]) begin
			q <= prod[63:32];
			state <= DONE;
		end
		else
			state <= RECIP;
		cnt <= 8'd33;
	end
// This state computes the reciprocal and caches it if the reciprocal isn't in
// the cache already.
RECIP:
	if (!cnt_done) begin
		q <= {q[30:0],b0};
		r <= {r1,q[31]};
	end
	else begin
		bcache[addr[7:2]] <= b;
		recip_cache[addr[7:2]] <= q;
		state <= RECIP1;
	end
// State to compute the quotient using the newly cached reciprocal.
RECIP1:
	begin
		q <= prod[63:32];
		state <= DONE;
	end
// Compute the remainder. You may not want to since it's a resource hog - it
// takes an additional multiply and subtract. The remainder is often easily
// calculated by program code rather than hardware.
DONE:
	begin
	$display("==========================");
	$display("a=%d,b=%d",a,b);
	$display("q=%d,r=%d",q,a - b * q);
	$display("rc[%h]=%d",addr[7:2],recip_cache[addr[7:2]]);
	$display("==========================");
	r <= a - b * q;
	state <= IDLE;
	end
endcase
end

endmodule

module cr_div_tb();

reg rst;
reg clk;
reg start;
wire done;
wire [31:0] q,r;
reg [31:0] a,b;
reg [7:0] cnt;
reg [7:0] cycles;
reg [31:0] addr,oaddr;

initial begin
	clk = 1;
	rst = 0;
	#100 rst = 1;
	#100 rst = 0;
	#100 start = 1;
	#150 start = 0;
end

always #10 clk = ~clk;	//  50 MHz

cr_div u1
(
	.rst(rst),
	.clk(clk),
	.start(start),
	.addr(addr),
	.a(a),
	.b(b),
	.q(q),
	.r(r),
	.done(done)
);

always @(posedge clk)
if (rst) begin
addr <= 32'd0;
cycles <= 8'h0;
end
else begin
start <= 1'b0;
cycles <= cycles + 8'd1;
oaddr <= addr;
if (done)
	addr <= addr + 32'd4;
if (addr != oaddr) begin
	start <= 1'b1;
	cycles <= 8'h00;
end
case(addr)
10'h00:	begin a = 32'd10005; b = 32'd27; end
10'h04:	begin a = 32'd9999; b = 32'd21; end
10'h08:	begin a = 32'd9999; b = 32'd0; end
10'h0C:	begin a = 32'hFFFFFFFF; b = 32'd1; end
10'h10: begin a = 32'h36969; b = 27; end
10'h14:	begin a = 32'd0; b = 32'hFFFFFFFF; end
10'h18:	begin a = 32'd1; b = 32'hFFFFFFFF; end
10'h1C:	begin a = 32'hFFFFFFFF; b = 32'd2; end
10'h100:begin a = 32'd3721; b = 32'd27; end			// <- this one simulates a loop (hits the same cache address as h00
default:	begin a = 32'd999; b = 32'd99;  end
endcase
$display("addr=%h,a=%d,b=%d,q=%d,r=%d,done=%d,cycles=%d",addr,a,b,q,r,done,cycles);
end

endmodule
