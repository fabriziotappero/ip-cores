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
module rtf65002_dtagmem(wclk, wr, wadr, cr, rclk, radr, hit);
input wclk;
input wr;
input [31:0] wadr;
input cr;
input rclk;
input [31:0] radr;
output hit;

reg [31:0] rradr;
wire [31:0] tag;

syncRam512x32_1rw1r u1
	(
		.wrst(1'b0),
		.wclk(wclk),
		.wce(1'b1),
		.we(wr),
		.wadr(wadr[10:2]),
		.i({wadr[31:1],cr}),
		.wo(),
		.rrst(1'b0),
		.rclk(rclk),
		.rce(1'b1),
		.radr(radr[10:2]),
		.o(tag)
	);


always @(posedge rclk)
	rradr <= radr;
	
assign hit = tag[31:11]==rradr[31:11] && tag[0];

endmodule
