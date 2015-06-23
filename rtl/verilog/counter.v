// ============================================================================
// (C) 2007 Robert Finch
// All Rights Reserved.
//
//	counter.v
//		generic up counter
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
module counter(rst, clk, ce, ld, d, q);
parameter WID=8;
input rst;
input clk;
input ce;
input ld;
input [WID:1] d;
output [WID:1] q;
reg [WID:1] q;

always @(posedge clk)
if (rst)
	q <= 0;
else if (ce) begin
	if (ld)
		q <= d;
	else
		q <= q + 1;
end

endmodule
