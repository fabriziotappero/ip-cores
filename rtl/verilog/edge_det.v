// ============================================================================
// (C) 2007 Robert Finch
// All Rights Reserved.
//
//	edge_det.v
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
//    Notes:
//
//	Edge detector
//	This little core detects an edge (positive, negative, and
//	either) in the input signal.
//
// ============================================================================
//
module edge_det(rst, clk, ce, i, pe, ne, ee);
input rst;		// reset
input clk;		// clock
input ce;		// clock enable
input i;		// input signal
output pe;		// positive transition detected
output ne;		// negative transition detected
output ee;		// either edge (positive or negative) transition detected

reg ed;
always @(posedge clk)
	if (rst)
		ed <= 1'b0;
	else if (ce)
		ed <= i;

assign pe = ~ed & i;	// positive: was low and is now high
assign ne = ed & ~i;	// negative: was high and is now low
assign ee = ed ^ i;		// either: signal is now opposite to what it was
	
endmodule
