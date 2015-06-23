//=============================================================================
//	(C) 2006-2011  Robert Finch
//	All rights reserved.
//	robfinch@opencores.org
//
//	rolx1.v
//		Rotate or shift to the left by zero, one, two or
//	three bits.
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
//	Funnel rotater / shifter
//	Rotate, arithmetic shift left, or logical shift /
//	arithmetic shift right by 0 to 63 bits.
//	Parameterized with a default width of 32 bits.
//
//
//	Rotate or shift left by 0 to 3 bits.
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
module rolx1
#(parameter WID = 32)
(
input op,					// 0=shift, 1= rotate
input [WID:1] a,
input [1:0] b,
output reg [WID:1] o
);
wire [2:0] opx = {3{op}};
always @(a, b, opx)
begin
	case(b)
	2'd0:	o <= a;
	2'd1:	o <= {a[WID-1:1],a[WID]&opx[0]};
	2'd2:	o <= {a[WID-2:1],a[WID:WID-1]&opx[1:0]};
	2'd3:	o <= {a[WID-3:1],a[WID:WID-2]&opx[2:0]};
	endcase
end

endmodule
