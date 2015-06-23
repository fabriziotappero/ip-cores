// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
`include "rtf65002_defines.v"

// This table being setup to set the pc increment. It should synthesize to a ROM.
module rtf65002_pcinc(opcode,suppress_pcinc,inc);
input [8:0] opcode;
input [3:0] suppress_pcinc;
output reg [3:0] inc;

always @(opcode,suppress_pcinc)
if (suppress_pcinc==4'hF)
	case(opcode)
	`BRK:	inc <= 4'd0;
	`INT0,`INT1: inc <= 4'd0;
	`BPL,`BMI,`BCS,`BCC,`BVS,`BVC,`BEQ,`BNE,`BRA,`BGT,`BLE,`BGE,`BLT,`BHI,`BLS:	inc <= 4'd2;
	`BRL: inc <= 4'd3;
	`EXEC,`ATNI: inc <= 4'd2;
	`CLC,`SEC,`CLD,`SED,`CLV,`CLI,`SEI:	inc <= 4'd1;
	`TAS,`TSA,`TAY,`TYA,`TAX,`TXA,`TSX,`TXS,`TYX,`TXY:	inc <= 4'd1;
	`TRS,`TSR: inc <= 4'd2;
	`INY,`DEY,`INX,`DEX,`INA,`DEA: inc <= 4'd1;
	`XCE: inc <= 4'd1;
	`STP,`WAI: inc <= 4'd1;
	`JMP,`JML,`JMP_IND,`JMP_INDX,`JMP_RIND,
	`JSR,`JSR_RIND,`JSL,`BSR,`JSR_INDX,`RTS,`RTL,`RTI: inc <= 4'd0;
	`JML,`JSL,`JMP_IND,`JMP_INDX,`JSR_INDX:	inc <= 4'd5;
	`JMP_RIND,`JSR_RIND: inc <= 4'd2;
	`NOP: inc <= 4'd1;
	`BSR: inc <= 4'd3;
	`RR: inc <= 4'd3;
	`LD_RR:	inc <= 4'd2;
	`ADD_IMM4,`SUB_IMM4,`AND_IMM4,`OR_IMM4,`EOR_IMM4,
	`ADD_R,`SUB_R,`AND_R,`OR_R,`EOR_R:	inc <= 4'd2;
	`ADD_IMM8,`SUB_IMM8,`AND_IMM8,`OR_IMM8,`EOR_IMM8,`ASL_IMM8,`LSR_IMM8:	inc <= 4'd3;
	`MUL_IMM8,`DIV_IMM8,`MOD_IMM8: inc <= 4'd3;
	`LDX_IMM8,`LDA_IMM8,`CMP_IMM8,`SUB_SP8: inc <= 4'd2;
	`ADD_IMM16,`SUB_IMM16,`AND_IMM16,`OR_IMM16,`EOR_IMM16:	inc <= 4'd4;
	`MUL_IMM16,`DIV_IMM16,`MOD_IMM16: inc <= 4'd4;
	`LDX_IMM16,`LDA_IMM16,`SUB_SP16: inc <= 4'd3;
	`ADD_IMM32,`SUB_IMM32,`AND_IMM32,`OR_IMM32,`EOR_IMM32:	inc <= 4'd6;
	`MUL_IMM32,`DIV_IMM32,`MOD_IMM32: inc <= 4'd6;
	`LDX_IMM32,`LDY_IMM32,`LDA_IMM32,`SUB_SP32,`CPX_IMM32,`CPY_IMM32: inc <= 4'd5;
	`ADD_ZPX,`SUB_ZPX,`AND_ZPX,`OR_ZPX,`EOR_ZPX,`LEA_ZPX: inc <= 4'd4;
	`ADD_IX,`SUB_IX,`AND_IX,`OR_IX,`EOR_IX,`LEA_IX: inc <= 4'd4;
	`ADD_IY,`SUB_IY,`AND_IY,`OR_IY,`EOR_IY,`LEA_IY: inc <= 4'd4;
	`ADD_ABS,`SUB_ABS,`AND_ABS,`OR_ABS,`EOR_ABS,`LEA_ABS: inc <= 4'd6;
	`ADD_ABSX,`SUB_ABSX,`AND_ABSX,`OR_ABSX,`EOR_ABSX,`LEA_ABSX: inc <= 4'd7;
	`ADD_RIND,`SUB_RIND,`AND_RIND,`OR_RIND,`EOR_RIND,`LEA_RIND: inc <= 4'd3;
	`ADD_DSP,`SUB_DSP,`AND_DSP,`OR_DSP,`EOR_DSP,`LEA_DSP: inc <= 4'd3;
	`ASL_ACC,`LSR_ACC,`ROR_ACC,`ROL_ACC: inc <= 4'd1;
	`ASL_RR,`ROL_RR,`LSR_RR,`ROR_RR,`INC_RR,`DEC_RR: inc <= 4'd2;
	`ST_RIND: inc <= 4'd2;
	`LDX_ZPX,`LDY_ZPX,`ST_DSP,`STX_ZPX,`STY_ZPX,`CPX_ZPX,`CPY_ZPX,
	`BMS_ZPX,`BMC_ZPX,`BMF_ZPX,`BMT_ZPX,
	`ASL_ZPX,`ROL_ZPX,`LSR_ZPX,`ROR_ZPX,`INC_ZPX,`DEC_ZPX,
	`ADD_DSP,`SUB_DSP,`OR_DSP,`AND_DSP,`EOR_DSP: inc <= 4'd3;
	`ORB_ZPX,`ST_ZPX,`STB_ZPX,`ADD_ZPX,`SUB_ZPX,`OR_ZPX,`AND_ZPX,`EOR_ZPX,
	`ADD_IX,`SUB_IX,`OR_IX,`AND_IX,`EOR_IX,`ST_IX,
	`ADD_IY,`SUB_IY,`OR_IY,`AND_IY,`EOR_IY,`ST_IY: inc <= 4'd4;
	`LDX_ABS,`LDY_ABS,`STX_ABS,`STY_ABS,
	`BMS_ABS,`BMC_ABS,`BMF_ABS,`BMT_ABS,
	`ASL_ABS,`ROL_ABS,`LSR_ABS,`ROR_ABS,`INC_ABS,`DEC_ABS,`CPX_ABS,`CPY_ABS: inc <= 4'd5;
	`ORB_ABS,`LDX_ABSY,`LDY_ABSX,`ST_ABS,`STB_ABS,
	`ADD_ABS,`SUB_ABS,`OR_ABS,`AND_ABS,`EOR_ABS,
	`BMS_ABSX,`BMC_ABSX,`BMF_ABSX,`BMT_ABSX,
	`ASL_ABSX,`ROL_ABSX,`LSR_ABSX,`ROR_ABSX,`INC_ABSX,`DEC_ABSX,`SPL_ABSX: inc <= 4'd6;
	`ORB_ABSX,`ST_ABSX,`STB_ABSX,
	`ADD_ABSX,`SUB_ABSX,`OR_ABSX,`AND_ABSX,`EOR_ABSX: inc <= 4'd7;
	`PHP,`PHA,`PHX,`PHY,`PLP,`PLA,`PLX,`PLY: inc <= 4'd1;
	`PUSH,`POP: inc <= 4'd2;
	`MVN,`MVP,`STS: inc <= 4'd1;
	`PG2:	inc <= 4'd1;
	`TON,`TOFF:	inc <= 4'd1;
	`PUSHA,`POPA: inc <= 4'd1;
	`SPL_ABS:	inc <= 4'd5;
	default:	inc <= 4'd0;	// unimplemented instruction
	endcase
else
	inc <= 4'd0;
endmodule

