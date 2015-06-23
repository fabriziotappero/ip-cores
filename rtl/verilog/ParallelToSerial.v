// ============================================================================
//	2006,2007,2011  Robert Finch
//	robfinch@<remove>sympatico.ca
//
//	ParallelToSerial.v
//		Parallel to serial data converter (shift register).
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
module ParallelToSerial(rst, clk, ce, ld, qin, d, qh);
parameter WID=8;
input rst;			// reset
input clk;			// clock
input ce;			// clock enable
input ld;			// load
input qin;			// serial shifting input
input [WID:1] d;	// data to load
output qh;			// serial output

reg [WID:1] q;

always @(posedge clk)
	if (rst)
		q <= 0;
	else if (ce) begin
		if (ld)
			q <= d;
		else
			q <= {q[WID-1:1],qin};
	end

assign qh = q[WID];

endmodule
