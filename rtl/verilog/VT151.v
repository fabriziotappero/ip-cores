// ============================================================================
//	2007  Robert Finch
//	robfinch@<remove>sympatico.ca
//
// 74LS151 mux
// 8-to-1 mux with enable
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
// ============================================================================
//
module VT151(e_n, s, i0, i1, i2, i3, i4, i5, i6, i7, z, z_n);
parameter WID=1;
input e_n;
input [2:0] s;
input [WID:1] i0;
input [WID:1] i1;
input [WID:1] i2;
input [WID:1] i3;
input [WID:1] i4;
input [WID:1] i5;
input [WID:1] i6;
input [WID:1] i7;
output [WID:1] z;
output [WID:1] z_n;

reg [WID:1] z;

always @(e_n or s or i0 or i1 or i2 or i3 or i4 or i5 or i6 or i7)
	case({e_n,s})
	4'b0000:	z <= i0;
	4'b0001:	z <= i1;
	4'b0010:	z <= i2;
	4'b0011:	z <= i3;
	4'b0100:	z <= i4;
	4'b0101:	z <= i5;
	4'b0110:	z <= i6;
	4'b0111:	z <= i7;
	default:	z <= {WID{1'b0}};
	endcase

assign z_n = ~z;

endmodule
