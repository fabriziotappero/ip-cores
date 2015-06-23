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
module rtf65002_dcachemem(wclk, wr, sel, wadr, wdat, rclk, radr, rdat);
input wclk;
input wr;
input [3:0] sel;
input [31:0] wadr;
input [31:0] wdat;
input rclk;
input [31:0] radr;
output [31:0] rdat;

syncRam2kx32_1rw1r ram0 (
	.wrst(1'b0),
	.wclk(wclk),
	.wce(1'b1),
	.we(wr),
	.wsel(sel),
	.wadr(wadr[10:0]),
	.i(wdat),
	.wo(),
	.rrst(1'b0),
	.rclk(rclk),
	.rce(1'b1),
	.radr(radr[10:0]),
	.o(rdat)
);

endmodule
