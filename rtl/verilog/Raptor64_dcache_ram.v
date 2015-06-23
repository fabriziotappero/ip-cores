// ============================================================================
// (C) 2012 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// Raptor64.v - dcache_ram
//  - 64 bit CPU data cache ram
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
module Raptor64_dcache_ram(wclk,wr,sel,wadr,i,rclk,radr,o);
input wclk;
input wr;
input [7:0] sel;
input [14:3] wadr;
input [63:0] i;
input rclk;
input [14:3] radr;
output [63:0] o;

reg [63:0] mem [0:4095];
reg [14:3] rradr;

always @(posedge wclk)
	if (wr) begin
		if (sel[0]) mem[wadr][ 7: 0] <= i[ 7: 0];
		if (sel[1]) mem[wadr][15: 8] <= i[15: 8];
		if (sel[2]) mem[wadr][23:16] <= i[23:16];
		if (sel[3]) mem[wadr][31:24] <= i[31:24];
		if (sel[4]) mem[wadr][39:32] <= i[39:32];
		if (sel[5]) mem[wadr][47:40] <= i[47:40];
		if (sel[6]) mem[wadr][55:48] <= i[55:48];
		if (sel[7]) mem[wadr][63:56] <= i[63:56];
	end

always @(posedge rclk)
	rradr <= radr[14:3];

assign o = mem[rradr];

endmodule

