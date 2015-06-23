// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch@<remove>@opencores.org
//
//	syncRam512x64_1rw1r.v
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
module syncRam512x64_1rw1r(
	input wrst,
	input wclk,
	input wce,
	input we,
	input [8:0] wadr,
	input [63:0] i,
	output [63:0] wo,

	input rrst,
	input rclk,
	input rce,
	input [8:0] radr,
	output [63:0] ro
);

syncRam512x32_1rw1r u1
(
	.wrst(wrst),
	.wclk(wclk),
	.wce(wce),
	.we(we),
	.wadr(wadr),
	.i(i[31:0]),
	.wo(wo[31:0]),
	.rrst(rrst),
	.rclk(rclk),
	.rce(rce),
	.radr(radr),
	.o(ro[31:0])
);

syncRam512x32_1rw1r u2
(
	.wrst(wrst),
	.wclk(wclk),
	.wce(wce),
	.we(we),
	.wadr(wadr),
	.i(i[63:32]),
	.wo(wo[63:32]),
	.rrst(rrst),
	.rclk(rclk),
	.rce(rce),
	.radr(radr),
	.o(ro[63:32])
);

endmodule
