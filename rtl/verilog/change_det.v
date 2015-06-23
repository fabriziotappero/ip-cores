// ============================================================================
//	2006  Robert Finch
//	robfinch@<remove>sympatico.ca
//
//	change_det.v
//	- detects a change in a value
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
module change_det(rst, clk, ce, i, cd);
parameter WID=32;
input rst;			// reset
input clk;			// clock
input ce;			// clock enable
input [WID:1] i;	// input signal
output cd;			// change detected

reg [WID:1] hold;

always @(posedge clk)
	if (rst)
		hold <= i;
	else if (ce)
		hold <= i;

assign cd = i != hold;

endmodule
