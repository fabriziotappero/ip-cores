`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_logic.v
//  - logical datapath operations
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
//
//=============================================================================
//
module Raptor64_logic(xIR, a, b, imm, o);
input [31:0] xIR;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
output [63:0] o;
reg [63:0] o;

wire [6:0] xOpcode = xIR[31:25];
wire [5:0] xFunc = xIR[5:0];

always @(xOpcode or xFunc or a or b or imm)
case (xOpcode)
`RR:
	case(xFunc)
	`AND:	o = a & b;
	`OR:	o = a | b;
	`XOR:	o = a ^ b;
	`ANDC:	o = a & ~b;
	`NAND:	o = ~(a & b);
	`NOR:	o = ~(a | b);
	`XNOR:	o = ~(a ^ b);
	`ORC:	o = a | ~b;
	default:	o = 64'd0;
	endcase
`ANDI:	o = a & imm;
`ORI:	o = a | imm;
`XORI:	o = a ^ imm;
default:	o = 64'd0;
endcase

endmodule
