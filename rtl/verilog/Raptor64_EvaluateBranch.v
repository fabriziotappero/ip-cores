`include "Raptor64_opcodes.v"
`timescale 1ns / 1ps
//=============================================================================
//        __
//   \\__/ o\    (C) 2011,2012  Robert Finch
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
//  
//	Raptor64_EvaluateBranch.v
//  - Evaluate branch conditions.
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

module Raptor64_EvaluateBranch(ir, a, b, imm, rsf, takb);
input [31:0] ir;
input [63:0] a;
input [63:0] b;
input [63:0] imm;
input rsf;			// reservation flag
output takb;
reg takb;

wire [6:0] opcode = ir[31:25];
wire [4:0] func5 = ir[4:0];
wire [3:0] func4 = ir[3:0];
wire [3:0] cond4 = ir[18:15];
wire [3:0] cond4t = ir[14:11];

wire aeqz = a==64'd0;
wire beqz = b==64'd0;
wire immeqz = imm==64'd0;

wire eq = a==b;
wire eqi = a==imm;
wire lt = $signed(a) < $signed(b);
wire lti = $signed(a) < $signed(imm);
wire ltu = a < b;
wire ltui = a < imm;

always @(opcode or func5 or func4 or cond4 or cond4t or a or eq or eqi or lt or lti or ltu or ltui or aeqz or beqz or rsf)
case (opcode)
`BTRR:
	case(func5)
	`BRA:	takb = 1'b1;
	`BRN:	takb = 1'b0;
	`BEQ:	takb = eq;
	`BNE:	takb = !eq;
	`BLT:	takb = lt;
	`BLE:	takb = lt|eq;
	`BGT:	takb = !(lt|eq);
	`BGE:	takb = !lt;
	`BLTU:	takb = ltu;
	`BLEU:	takb = ltu|eq;
	`BGTU:	takb = !(ltu|eq);
	`BGEU:	takb = !ltu;
	`BOR:	takb = !aeqz || !beqz;
	`BAND:	takb = !aeqz && !beqz;
	`BNR:	takb = !rsf;
	`LOOP:	takb = !beqz;
	`BEQR:	takb = eq;
	`BNER:	takb = !eq;
	`BLTR:	takb = lt;
	`BLER:	takb = lt|eq;
	`BGTR:	takb = !(lt|eq);
	`BGER:	takb = !lt;
	`BLTUR:	takb = ltu;
	`BLEUR:	takb = ltu|eq;
	`BGTUR:	takb = !(ltu|eq);
	`BGEUR:	takb = !ltu;
	default:	takb = 1'b0;
	endcase
`BEQI:	takb = eqi;
`BNEI:	takb = !eqi;
`BLTI:	takb = lti;
`BLEI:	takb = lti|eqi;
`BGTI:	takb = !(lti|eqi);
`BGEI:	takb = !lti;
`BLTUI:	takb = ltui;
`BLEUI:	takb = ltui|eqi;
`BGTUI:	takb = !(ltui|eqi);
`BGEUI:	takb = !ltui;
`BTRI:
	case(cond4t)
	`BRA:	takb = 1'b1;
	`BRN:	takb = 1'b0;
	`BEQ:	takb = eqi;
	`BNE:	takb = !eqi;
	`BLT:	takb = lti;
	`BLE:	takb = lti|eqi;
	`BGT:	takb = !(lti|eqi);
	`BGE:	takb = !lti;
	`BLTU:	takb = ltui;
	`BLEU:	takb = ltui|eqi;
	`BGTU:	takb = !(ltui|eqi);
	`BGEU:	takb = !ltui;
	default:	takb = 1'b0;
	endcase
`TRAPcc: 
	case(func4)
	`TEQ:	takb = eq;
	`TNE:	takb = !eq;
	`TLT:	takb = lt;
	`TLE:	takb = lt|eq;
	`TGT:	takb = !(lt|eq);
	`TGE:	takb = !lt;
	`TLTU:	takb = ltu;
	`TLEU:	takb = ltu|eq;
	`TGTU:	takb = !(ltu|eq);
	`TGEU:	takb = !ltu;
	default:	takb = 1'b0;
	endcase
`TRAPcci: 
	case(cond4)
	`TEQI:	takb = eqi;
	`TNEI:	takb = !eqi;
	`TLTI:	takb = lti;
	`TLEI:	takb = lti|eqi;
	`TGTI:	takb = !(lti|eqi);
	`TGEI:	takb = !lti;
	`TLTUI:	takb = ltui;
	`TLEUI:	takb = ltui|eqi;
	`TGTUI:	takb = !(ltui|eqi);
	`TGEUI:	takb = !ltui;
	default:	takb = 1'b0;
	endcase
default:
	takb = 1'b0;
endcase

endmodule

