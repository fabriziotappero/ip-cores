// ============================================================================
//	(C) 2007  Robert Finch
//	robfinch@<remove>sympatico.ca
//
// VT148 - 74LS148 priority encoder
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
// Webpack 9.1i  xc3s1000-4ft256
// 6 slices / 11 LUTs / 10.860 MHz

module VT148(en, i0, i1, i2, i3, i4, i5, i6, i7, o, gs, eo);
input en;	// enable - active low
input i0;	// input - active low
input i1;
input i2;
input i3;
input i4;
input i5;
input i6;
input i7;
output [2:0] o;
reg [2:0] o;
output gs;
output eo;

always @(en or i1 or i2 or i3 or i4 or i5 or i6 or i7)
	if (en)
		o = 3'd7;
	else if (!i7)
		o = 3'd0;
	else if (!i6)
		o = 3'd1;
	else if (!i5)
		o = 3'd2;
	else if (!i4)
		o = 3'd3;
	else if (!i3)
		o = 3'd4;
	else if (!i2)
		o = 3'd5;
	else if (!i1)
		o = 3'd6;
	else
		o = 3'd7;

nand(eo, i0,i1,i2,i3,i4,i5,i6,i7,!en);
or(gs, en,!eo);

endmodule
