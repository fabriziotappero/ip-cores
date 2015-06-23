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
module rtf65002_itagmem4k(wclk, wr, adr, rclk, pc, hit0, hit1);
input wclk;
input wr;
input [33:0] adr;
input rclk;
input [31:0] pc;
output hit0;
output hit1;

wire [31:0] pcp8 = pc + 32'd8;
wire [31:0] tag0;
wire [31:0] tag1;
reg [31:0] rpc;
reg [31:0] rpcp8;

always @(posedge rclk)
	rpc <= pc;
always @(posedge rclk)
	rpcp8 <= pcp8;

// Note that only 1/2 the tag ram is used.
syncRam512x32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr({1'b0,adr[11:4]}),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr({1'b0,pc[11:4]}),
	.o(tag0)
);

syncRam512x32_1rw1r ram1 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wadr({1'b0,adr[11:4]}),
	.i(adr[31:0]),
	.wo(),

	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr({1'b0,pcp8[11:4]}),
	.o(tag1)
);

assign hit0 = tag0[31:12]==rpc[31:12] && tag0[0];
assign hit1 = tag1[31:12]==rpcp8[31:12] && tag1[0];

endmodule
