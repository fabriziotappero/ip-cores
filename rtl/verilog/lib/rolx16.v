//=============================================================================
//	(C) 2006-2011  Robert Finch
//	All rights reserved.
//	robfinch@opencores.org
//
//	rolx16.v
//		Rotate or shift left by multiples of sixteen bits.
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
//=============================================================================
//
// rol 0,16,32 or 48 bits
module rolx16(op, a, b, o);
parameter DBW = 32;
localparam DMSB = DBW-1;
input op;
input [DMSB:0] a;
input [1:0] b;
output [DMSB:0] o;
reg [DMSB:0] o;

wire [47:0] opx = {48{op}};
always @(b or a or opx) begin
	case (b)
	2'd0:	o <= a;
	2'd1:	o <= {a[DMSB-16:0],a[DMSB:DMSB-15]&opx[15:0]};
	2'd2:	o <= {a[DMSB-(32%DBW):0],a[DMSB:DMSB-(31%DBW)]&opx[31:0]};
	2'd3:	o <= {a[DMSB-(48%DBW):0],a[DMSB:DMSB-(47%DBW)]&opx[47:0]};
	endcase
end

endmodule
