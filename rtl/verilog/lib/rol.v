//=============================================================================
//	(C) 2006-2011  Robert Finch
//	All rights reserved.
//	robfinch@opencores.org
//
//	rol.v
//		Rotate or shift left by up to 64 bits.
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
//=============================================================================
//
// op
//	0	shift left
//	1	rotate left
module rol
#(parameter WID = 32)
(
input op,
input [WID:1] a,
input [5:0] b,
output [WID:1] o
);
wire [WID:1] t1, t2, t3;
assign o = t3;

rolx1  #(WID) u1 (op,  a, b[1:0], t1);
rolx4  #(WID) u2 (op, t1, b[3:2], t2);
rolx16 #(WID) u3 (op, t2, b[5:4], t3);

endmodule

