//=============================================================================
//	(C) 2005-2011  Robert Finch
//	All rights reserved.
//	robfinch@opencores.org
//
//	shiftAndMask.v
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
//	Resource Usage Samples:
//	Ref. Spartan3
//	170 slices / 302 LUTs / 19.091ns
//	Webpack 9.2i Spartan3e  xc3s1200e 4fg320
//	170 slices / 302 LUTs / 14.450 ns (32 bits)
//	374 slices / 673 LUTs / 15.787 ns (64 bits)
//=============================================================================

module shiftAndMask(op, oz, a, b, mb, me, o, mo);
parameter WID = 64;
localparam DMSB = WID-1;
input [1:0] op;		// 0 = shl, 1 = rol, 2 = shr, 3 = asr
input oz;           // zero the output
input [DMSB:0] a;
input [5:0] b;
input [5:0] mb;
input [5:0] me;
output [DMSB:0] o;	// output
output [DMSB:0] mo;	// mask output

reg [DMSB:0] o;
reg [DMSB:0] mo;

integer nn;
wire [DMSB:0] rol_o;
wire fill_bit = a[DMSB] & op[0] & op[1];

rol #(WID) rol0(.op(op!=2'b00), .a(a), .b(b), .o(rol_o) );

// generate mask
always @(mb or me)
	for (nn = 0; nn < WID; nn = nn + 1)
		mo[nn] <= (nn >= mb) ^ (nn <= me) ^ (me >= mb);

always @(op or mo or rol_o or fill_bit or nn)
	for (nn = 0; nn < WID; nn = nn + 1)
		o[nn] <= oz ? 1'b0 : mo[nn] ? rol_o[nn] : fill_bit;

endmodule
