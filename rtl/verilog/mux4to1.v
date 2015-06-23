// (C) 2007,2012  Robert T Finch
// robfinch<remove>@opencores.org
// All Rights Reserved.
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
// Verilog 1995
//
// Webpack 9.1i  xc3s1000-4ft256
//  slices /  LUTs / MHz

module mux4to1(e, s, i0, i1, i2, i3, z);
parameter WID=4;
input e;
input [1:0] s;
input [WID:1] i0;
input [WID:1] i1;
input [WID:1] i2;
input [WID:1] i3;
output [WID:1] z;
reg [WID:1] z;

always @(e or s or i0 or i1 or i2 or i3)
	if (!e)
		z <= {WID{1'b0}};
	else begin
		case(s)
		2'b00:	z <= i0;
		2'b01:	z <= i1;
		2'b10:	z <= i2;
		2'b11:	z <= i3;
		endcase
	end

endmodule
