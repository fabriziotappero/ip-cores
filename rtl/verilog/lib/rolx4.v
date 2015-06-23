//=============================================================================
//	(C) 2006-2011  Robert Finch
//	All rights reserved.
//	robfinch@opencores.org
//
//	rolx4.v
//		Rotate or shift left by multiples of four bits.
//
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
//	Rotate or arithmetic shift left by 0, 4, 8 or 12 bits.
//	Parameterized with a default width of 32 bits.
//
//	Resource Usage Samples:
//	Ref. SpartanII
//	64 LUTs
//	
//	Webpack 7.1i xc3s1000-4ft256
//	64 LUTs / 32 slices / 11 ns		(32 bits)
//=============================================================================
//
// rol 0,4,8 or 12 bits
module rolx4
#(parameter WID = 32)
(
input op,
input [WID:1] a,
input [1:0] b,
output reg [WID:1] o
);
wire [12:1] opx = {12{op}};
always @(a, b, opx)
begin
	case (b)
	2'd0:	o <= a;
	2'd1:	o <= {a[WID- 4%WID:1],a[WID:WID- 3%WID]&opx[ 4:1]};
	2'd2:	o <= {a[WID- 8%WID:1],a[WID:WID- 7%WID]&opx[ 8:1]};
	2'd3:	o <= {a[WID-12%WID:1],a[WID:WID-11%WID]&opx[12:1]};
	endcase
end

endmodule
