// ============================================================================
//	(C) 2012  Robert Finch
//	robfinch@<remove>opencores.org
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
module cntlz8(
	input clk,
	input [7:0] i,
	output reg [3:0] o
);

always @(posedge clk)
	casex (i)
	8'b00000000:	o = 8;
	8'b00000001:	o = 7;
	8'b0000001x:	o = 6;
	8'b000001xx:	o = 5;
	8'b00001xxx:	o = 4;
	8'b0001xxxx:	o = 3;
	8'b001xxxxx:	o = 2;
	8'b01xxxxxx:	o = 1;
	8'b1xxxxxxx:	o = 0;
	endcase	

endmodule


module cntlz16(
	input clk,
	input [15:0] i,
	output reg [4:0] o
);
	wire [3:0] cnt1, cnt2;

	cntlz8 u1 (clk,i[ 7:0],cnt1);
	cntlz8 u2 (clk,i[15:8],cnt2);

	always @(posedge clk)
		o <= cnt2[3] ? cnt1 + 4'h8 : cnt2;

endmodule


// 88 slices / 154 LUTs / 22.5 ns
module cntlz64(
	input clk,
	input [63:0] i,
	output reg [6:0] o
);

	wire [4:0] cnt1, cnt2, cnt3, cnt4;

	cntlz16 u1 (clk,i[15: 0],cnt1);
	cntlz16 u2 (clk,i[31:16],cnt2);
	cntlz16 u3 (clk,i[47:32],cnt3);
	cntlz16 u4 (clk,i[63:48],cnt4);

	always @(posedge clk)
		o <=
			!cnt4[4] ? cnt4 :
			!cnt3[4] ? cnt3 + 7'd16 :
			!cnt2[4] ? cnt2 + 7'd32 :
			 cnt1 + 7'd48;

endmodule



// 5 slices / 10 LUTs / 7.702 ns
module cntlo8(
	input clk,
	input [7:0] i,
	output [3:0] o
);

cntlz8 u1 (clk,~i,o);

endmodule


module cntlo16(
	input clk,
	input [15:0] i,
	output [4:0] o
);

cntlz16 u1 (clk,~i,o);

endmodule


// 59 slices / 99 LUTs / 14.065 ns
module cntlo64(
	input clk,
	input [63:0] i,
	output [6:0] o
);

cntlz64 u1 (clk,~i,o);

endmodule


