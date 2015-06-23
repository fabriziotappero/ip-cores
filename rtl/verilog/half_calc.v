// ============================================================================
//        __
//   \\__/ o\    (C) 2014  Robert Finch, Stratford
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
// Datapath calculations - sixteen bit mode                                                                
// ============================================================================
//
HALF_CALC:
	begin
		state <= BYTE_IFETCH;
		store_what <= `STW_DEF70;
		case(ir[7:0])
		`ADC_IMM,`ADC_ZP,`ADC_ZPX,`ADC_IX,`ADC_IY,`ADC_IYL,`ADC_ABS,`ADC_ABSX,`ADC_ABSY,`ADC_AL,`ADC_ALX,`ADC_I,`ADC_IL,`ADC_DSP,`ADC_DSPIY:	begin res16 <= acc16 + b16 + {15'd0,cf}; end
		`SBC_IMM,`SBC_ZP,`SBC_ZPX,`SBC_IX,`SBC_IY,`SBC_IYL,`SBC_ABS,`SBC_ABSX,`SBC_ABSY,`SBC_AL,`SBC_ALX,`SBC_I,`SBC_IL,`SBC_DSP,`SBC_DSPIY:	begin res16 <= acc16 - b16 - {15'd0,~cf}; end
		`CMP_IMM,`CMP_ZP,`CMP_ZPX,`CMP_IX,`CMP_IY,`CMP_IYL,`CMP_ABS,`CMP_ABSX,`CMP_ABSY,`CMP_AL,`CMP_ALX,`CMP_I,`CMP_IL,`CMP_DSP,`CMP_DSPIY:	begin res16 <= acc16 - b16; end
		`AND_IMM,`AND_ZP,`AND_ZPX,`AND_IX,`AND_IY,`AND_IYL,`AND_ABS,`AND_ABSX,`AND_ABSY,`AND_AL,`AND_ALX,`AND_I,`AND_IL,`AND_DSP,`AND_DSPIY:	begin res16 <= acc16 & b16; end
		`ORA_IMM,`ORA_ZP,`ORA_ZPX,`ORA_IX,`ORA_IY,`ORA_IYL,`ORA_ABS,`ORA_ABSX,`ORA_ABSY,`ORA_AL,`ORA_ALX,`ORA_I,`ORA_IL,`ORA_DSP,`ORA_DSPIY:	begin res16 <= acc16 | b16; end
		`EOR_IMM,`EOR_ZP,`EOR_ZPX,`EOR_IX,`EOR_IY,`EOR_IYL,`EOR_ABS,`EOR_ABSX,`EOR_ABSY,`EOR_AL,`EOR_ALX,`EOR_I,`EOR_IL,`EOR_DSP,`EOR_DSPIY:	begin res16 <= acc16 ^ b16; end
		`LDA_IMM,`LDA_ZP,`LDA_ZPX,`LDA_IX,`LDA_IY,`LDA_IYL,`LDA_ABS,`LDA_ABSX,`LDA_ABSY,`LDA_AL,`LDA_ALX,`LDA_I,`LDA_IL,`LDA_DSP,`LDA_DSPIY:	begin res16 <= b16; end
		`BIT_IMM,`BIT_ZP,`BIT_ZPX,`BIT_ABS,`BIT_ABSX:	begin res16 <= acc16 & b16; end
		`TRB_ZP,`TRB_ABS:	begin res16 <= ~acc16 & b16; wdat <= ~acc16 & b16; state <= STORE1; end
		`TSB_ZP,`TSB_ABS:	begin res16 <= acc16 | b16; wdat <= acc16 | b16; state <= STORE1; end
		`LDX_IMM,`LDX_ZP,`LDX_ZPY,`LDX_ABS,`LDX_ABSY:	begin res16 <= b16; end
		`LDY_IMM,`LDY_ZP,`LDY_ZPX,`LDY_ABS,`LDY_ABSX:	begin res16 <= b16; end
		`CPX_IMM,`CPX_ZP,`CPX_ABS:	begin res16 <= x16 - b16; end
		`CPY_IMM,`CPY_ZP,`CPY_ABS:	begin res16 <= y16 - b16; end
		`ASL_ZP,`ASL_ZPX,`ASL_ABS,`ASL_ABSX:	begin res16 <= {b16,1'b0}; wdat <= {b16[14:0],1'b0}; state <= STORE1; end
		`ROL_ZP,`ROL_ZPX,`ROL_ABS,`ROL_ABSX:	begin res16 <= {b16,cf}; wdat <= {b16[14:0],cf}; state <= STORE1; end
		`LSR_ZP,`LSR_ZPX,`LSR_ABS,`LSR_ABSX:	begin res16 <= {b16[0],1'b0,b16[15:1]}; wdat <= {1'b0,b16[15:1]}; state <= STORE1; end
		`ROR_ZP,`ROR_ZPX,`ROR_ABS,`ROR_ABSX:	begin res16 <= {b16[0],cf,b16[15:1]}; wdat <= {cf,b16[15:1]}; state <= STORE1; end
		`INC_ZP,`INC_ZPX,`INC_ABS,`INC_ABSX:	begin res16 <= b16 + 16'd1; wdat <= {b16+16'd1}; state <= STORE1; end
		`DEC_ZP,`DEC_ZPX,`DEC_ABS,`DEC_ABSX:	begin res16 <= b16 - 16'd1; wdat <= {b16-16'd1}; state <= STORE1; end
		endcase
	end
