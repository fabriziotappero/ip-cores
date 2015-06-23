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
module rtf65002_icachemem8k(wclk, wr, adr, dat, rclk, pc, insn);
input wclk;
input wr;
input [33:0] adr;
input [31:0] dat;
input rclk;
input [31:0] pc;
output reg [63:0] insn;

wire [63:0] insn0;
wire [63:0] insn1;
wire [31:0] pcp8 = pc + 32'd8;
reg [31:0] rpc;

always @(posedge rclk)
	rpc <= pc;

// memL and memH combined allow a 64 bit read
syncRam1kx32_1rw1r ramL0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0[31:0])
);

syncRam1kx32_1rw1r ramH0
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pc[12:3]),
	.o(insn0[63:32])
);

syncRam1kx32_1rw1r ramL1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(~adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1[31:0])
);

syncRam1kx32_1rw1r ramH1
(
	.wrst(1'b0),
	.wclk(wclk),
	.wce(adr[2]),
	.we(wr),
	.wsel(4'hF),
	.wadr(adr[12:3]),
	.i(dat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(pcp8[12:3]),
	.o(insn1[63:32])
);

always @(rpc or insn0 or insn1)
case(rpc[2:0])
3'd0:	insn <= insn0[63:0];
3'd1:	insn <= {insn1[7:0],insn0[63:8]};
3'd2:	insn <= {insn1[15:0],insn0[63:16]};
3'd3:	insn <= {insn1[23:0],insn0[63:24]};
3'd4:	insn <= {insn1[31:0],insn0[63:32]};
3'd5:	insn <= {insn1[39:0],insn0[63:40]};
3'd6:	insn <= {insn1[47:0],insn0[63:48]};
3'd7:	insn <= {insn1[55:0],insn0[63:56]};
endcase 
endmodule
