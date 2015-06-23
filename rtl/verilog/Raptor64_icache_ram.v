`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_icache_ram.v
//
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
//
//=============================================================================
//
module Raptor64_icache_ram(wclk, we, adr, d, rclk, pc, insn);
input wclk;
input we;
input [13:0] adr;
input [63:0] d;
input rclk;
input [13:0] pc;
output [31:0] insn;

reg [31:0] ramLo [0:2047];
reg [31:0] ramHi [0:2047];
reg [13:2] radr;

always @(posedge wclk)
	if (we) begin
		ramLo[adr[13:3]] <= d[31: 0];
		ramHi[adr[13:3]] <= d[63:32];
	end

always @(posedge rclk)
	radr <= pc[13:2];

assign insn = radr[2] ? ramHi[radr[13:3]] : ramLo[radr[13:3]];

endmodule
