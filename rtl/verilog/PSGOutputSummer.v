`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//	All rights reserved.
//	robfinch<remove>@opencores.org
//
//	PSGOutputSummer.v 
//		Sum the filtered and unfiltered output.
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
//============================================================================ */

module PSGOutputSummer(clk_i, cnt, ufi, fi, o);
input clk_i;		// master clock
input [7:0] cnt;	// clock divider
input [21:0] ufi;	// unfiltered audio input
input [21:0] fi;	// filtered audio input
output [21:0] o;	// summed output
reg [21:0] o;

always @(posedge clk_i)
	if (cnt==8'd0)
		o <= ufi + fi;

endmodule
