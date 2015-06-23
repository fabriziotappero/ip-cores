// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
module rtf65002_itagmem2way(whichrd, whichwr, wclk, wr, adr, rclk, pc, hit0, hit1);
output reg [1:0] whichrd;
input whichwr;
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output reg hit0;
output reg hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0a,tag0b;
wire [31:0] tag1a,tag1b;
reg [31:0] rpc;
reg [31:0] rpcp8;
wire hit0a,hit1a;
wire hit0b,hit1b;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

syncRam512x32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(!whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(tag0a)
);

syncRam512x32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(!whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:4]),
	.o(tag1a)
);

syncRam512x32_1rw1r ram2 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(tag0b)
);

syncRam512x32_1rw1r ram3 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(whichwr),
	.we(wr),
	.wadr(adr[12:4]),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:4]),
	.o(tag1b)
);

assign hit0a = tag0a[31:13]==rpc[31:13] && tag0a[0];
assign hit1a = tag1a[31:13]==rpcp8[31:13] && tag1a[0];
assign hit0b = tag0b[31:13]==rpc[31:13] && tag0b[0];
assign hit1b = tag1b[31:13]==rpcp8[31:13] && tag1b[0];

always @(hit0a or hit1a or hit0b or hit1b or whichwr)
if (hit0a & hit1a) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b00;
end
else if (hit0b & hit1b) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b01;
end
else if (hit0a & hit1b) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b10;
end
else if (hit0b & hit1a) begin
	hit0 <= 1'b1;
	hit1 <= 1'b1;
	whichrd <= 2'b11;
end
else begin
	whichrd <= 2'b00;
	if (whichwr) begin
		hit0 <= hit0b;
		hit1 <= hit1b;
	end
	else begin
		hit0 <= hit0a;
		hit1 <= hit1a;
	end
end


endmodule
