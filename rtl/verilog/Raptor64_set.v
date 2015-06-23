`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_set.v
//  - set datapath operations
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
module Raptor64_set(xIR, a, b, imm, o);
input [31:0] xIR;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
output [63:0] o;
reg [63:0] o;

wire [6:0] xOpcode = xIR[31:25];
wire [5:0] xFunc = xIR[5:0];

wire eqi = a==imm;
wire lti = $signed(a) < $signed(imm);
wire ltui = a < imm;
wire eq = a==b;
wire lt = $signed(a) < $signed(b);
wire ltu = a < b;

always @(xOpcode,xFunc,eq,lt,ltu,eqi,lti,ltui)
case (xOpcode)
`RR:
	case(xFunc)
	`SEQ:	o = eq;
	`SNE:	o = !eq;
	`SLT:	o = lt;
	`SLE:	o = lt|eq;
	`SGT:	o = !(lt|eq);
	`SGE:	o = !lt;
	`SLTU:	o = ltu;
	`SLEU:	o = ltu|eq;
	`SGTU:	o = !(ltu|eq);
	`SGEU:	o = !ltu;
	default:	o = 64'd0;
	endcase
`SEQI:	o = eqi;
`SNEI:	o = !eqi;
`SLTI:	o = lti;
`SLEI:	o = lti|eqi;
`SGTI:	o = !(lti|eqi);
`SGEI:	o = !lti;
`SLTUI:	o = ltui;
`SLEUI:	o = ltui|eqi;
`SGTUI:	o = !(ltui|eqi);
`SGEUI:	o = !ltui;
default:	o = 64'd0;
endcase

endmodule
