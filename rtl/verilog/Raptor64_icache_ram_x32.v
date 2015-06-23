// ============================================================================
// (C) 2012 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// Raptor64.v - icache_ram
//  - 64 bit CPU instruction cache ram
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
module Raptor64_icache_ram_x32(clk, icaccess, ack_i, adr_i, dat_i, pc, insn);
input clk;
input icaccess;
input ack_i;
input [12:0] adr_i;
input [31:0] dat_i;
input [63:0] pc;
output [41:0] insn;
reg [41:0] insn;

wire [127:0] insnbundle;

syncRam512x32_1rw1r u1
(
	.wrst(1'b0),
	.wclk(clk),
	.wce(icaccess && adr_i[3:2]==2'b00),
	.we(ack_i),
	.wadr(adr_i[12:4]),
	.i(dat_i),
	.wo(),

	.rrst(1'b0),
	.rclk(~clk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(insnbundle[31:0])
);
syncRam512x32_1rw1r u2
(
	.wrst(1'b0),
	.wclk(clk),
	.wce(icaccess && adr_i[3:2]==2'b01),
	.we(ack_i),
	.wadr(adr_i[12:4]),
	.i(dat_i),
	.wo(),

	.rrst(1'b0),
	.rclk(~clk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(insnbundle[63:32])
);
syncRam512x32_1rw1r u3
(
	.wrst(1'b0),
	.wclk(clk),
	.wce(icaccess && adr_i[3:2]==2'b10),
	.we(ack_i),
	.wadr(adr_i[12:4]),
	.i(dat_i),
	.wo(),

	.rrst(1'b0),
	.rclk(~clk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(insnbundle[95:64])
);
syncRam512x32_1rw1r u4
(
	.wrst(1'b0),
	.wclk(clk),
	.wce(icaccess && adr_i[3:2]==2'b11),
	.we(ack_i),
	.wadr(adr_i[12:4]),
	.i(dat_i),
	.wo(),

	.rrst(1'b0),
	.rclk(~clk),
	.rce(1'b1),
	.radr(pc[12:4]),
	.o(insnbundle[127:96])
);

always @(pc or insnbundle)
	case(pc[3:2])
	2'd0:	insn <= insnbundle[ 41: 0];
	2'd1:	insn <= insnbundle[ 83:42];
	2'd2:	insn <= insnbundle[125:84];
	2'd3:	insn <= 42'h3EFFFFFFFFF;	// NOP instruction
	endcase

endmodule
