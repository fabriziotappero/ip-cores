`timescale 1ns / 1ps
// ============================================================================
//	(C) 2007,2012  Robert Finch
//  robfinch<remove>@opencores.org
//	All rights reserved.
//
//	PSGNoteOutMux.v
//	Version 1.0
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
//	Selects from one of five waveforms for output. Selected waveform
//	outputs are anded together. This is approximately how the
//	original SID worked.
//
//	Spartan3
//	Webpack 9.1i xc3s1000-4ft256
//	36 LUTs / 21 slices / 11ns
//============================================================================ */
//
module PSGNoteOutMux(s, a, b, c, d, e, o);
parameter WID = 12;
input [4:0] s;
input [WID-1:0] a,b,c,d,e;
output [WID-1:0] o;

wire [WID-1:0] o1,o2,o3,o4,o5;

assign o1 = s[4] ? e : {WID{1'b1}};
assign o2 = s[3] ? d : {WID{1'b1}};
assign o3 = s[2] ? c : {WID{1'b1}};
assign o4 = s[1] ? b : {WID{1'b1}};
assign o5 = s[0] ? a : {WID{1'b1}};

assign o = o1 & o2 & o3 & o4 & o5;

endmodule


