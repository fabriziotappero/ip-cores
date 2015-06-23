// ============================================================================
//	2007  Robert Finch
//	robfinch@<remove>sympatico.ca
//
// VT163 - 74LS163 counter
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
// 4 slices / 8 LUTs / 324.675 MHz

module VT163(clk, clr_n, ent, enp, ld_n, d, q, rco);
parameter WID=4;
input clk;
input clr_n;	// clear active low
input ent;		// clock enable
input enp;		// clock enable
input ld_n;		// load active low
input [WID:1] d;
output [WID:1] q;
reg [WID:1] q;
output rco;

assign rco = &{q[WID:1],ent};

always @(posedge clk)
	begin
		if (!clr_n)
			q <= {WID{1'b0}};
		else if (!ld_n)
			q <= d;
		else if (enp & ent)
			q <= q + {{WID-1{1'b0}},1'b1};
	end

endmodule
