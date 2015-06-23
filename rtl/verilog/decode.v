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
task decode_tsk;
	begin
		first_ifetch <= `TRUE;
		Rt <= 4'h0;		// Default
		state <= IFETCH;
		pc <= pc + pc_inc;
		pc_inc2 <= pc_inc;
		a <= rfoa;
		res <= alu_out;
		ttrig <= tf;
		oisp <= isp;	// for bus retry
		// This case statement should include all opcodes or the opcode
		// will end up being treated as an undefined operation.
		case(ir9)
		`STP:	clk_en <= 1'b0;
		`NOP:	;
//				casex(ir[63:0])
//				{`NOP,`NOP,`NOP,`NOP,`NOP,`NOP,`NOP,`NOP}:	pc <= pcp8;
//				{8'hxx,`NOP,`NOP,`NOP,`NOP,`NOP,`NOP,`NOP}:	pc <= pcp7;
//				{16'hxxxx,`NOP,`NOP,`NOP,`NOP,`NOP,`NOP}:	pc <= pcp6;
//				{24'hxxxxxx,`NOP,`NOP,`NOP,`NOP,`NOP}:	pc <= pcp5;
//				{32'hxxxxxxxx,`NOP,`NOP,`NOP,`NOP}:	pc <= pcp4;
//				{40'hxxxxxxxxxx,`NOP,`NOP,`NOP}:	pc <= pcp3;
//				{48'hxxxxxxxxxxxx,`NOP,`NOP}:	pc <= pcp2;
//				{56'hxxxxxxxxxxxxxx,`NOP}:	pc <= pcp1;
//				endcase
		`CLC:	cf <= 1'b0;
		`SEC:	cf <= 1'b1;
		`CLV:	vf <= 1'b0;
		`CLI:	im <= 1'b0;
		`CLD:	df <= 1'b0;
		`SED:	df <= 1'b1;
		`SEI:	im <= 1'b1;
		`WAI:	wai <= 1'b1;
		`TON:	tf <= 1'b1;
		`TOFF:	tf <= 1'b0;
		`HOFF:	hist_capture <= 1'b0;
		// Switching to 65c02 mode zeros out the upper part of the index registers.
		// Switching to 65c816 mode does not zero out the upper part of the index registers,
		// this is unlike switching from '02 to '816 mode. Also, the register size select
		// bits are not affected.
		`XCE:	begin
					em <= 1'b1;
					m816 <= ~cf;
					cf <= ~m816;
					if (cf) begin
						x[31:8] <= 24'd0;
						y[31:8] <= 24'd0;
					end
`ifdef SUPPORT_EM8
					next_state(BYTE_IFETCH);
`endif
				end
		`DEX:	Rt <= 4'd2;
					// DEX/BNE accelerator
//					if (ir[15:8]==`BNE) begin
//						if (x!=32'd1) begin
//							if (ir[23:16]==8'h01)
//								pc <= pc + {{16{ir[39]}},ir[39:24]} + 32'd1;
//							else
//								pc <= pc + {{24{ir[23]}},ir[23:16]} + 32'd1;
//						end
//						else begin
//							if (ir[23:16]==8'h01)
//								pc <= pcp5;
//							else
//								pc <= pcp3;
//						end
//					end
		`INX:	Rt <= 4'd2;
		`DEY:	Rt <= 4'd3;
		`INY:	Rt <= 4'd3;
		`DEA:	Rt <= 4'd1;
		`INA:	Rt <= 4'd1;
		`TSX:	Rt <= 4'd2;
		`TSA:	Rt <= 4'd1;
		`TXS:	;
		`TXA:	Rt <= 4'd1;
		`TXY:	Rt <= 4'd3;
		`TAX:	Rt <= 4'd2;
		`TAY:	Rt <= 4'd3;
		`TAS:	;
		`TYA:	Rt <= 4'd1;
		`TYX:	Rt <= 4'd2;
		`TRS:		;
		`TSR:		begin
						Rt <= ir[15:12];
						case(ir[11:8])
						4'h0:	;
						4'h2:	;
						4'h3:	;
						4'h4:	;
						4'h5:	lfsr <= {lfsr[30:0],lfsr_fb};
						4'd7:	;
						4'h8:	;
						4'h9:	;
`ifdef DEBUG
						4'hA:	history_ndx <= history_ndx + 6'd1;
`endif
						4'hE:	;
						4'hF:	;
						default:	;
						endcase
					end
		`ASL_ACC:	Rt <= 4'd1;
		`ROL_ACC:	Rt <= 4'd1;
		`LSR_ACC:	Rt <= 4'd1;
		`ROR_ACC:	Rt <= 4'd1;

		`RR:
			begin
				Rt <= ir[19:16];
				case(ir[23:20])
				`ADD_RR:	b <= rfob;
				`SUB_RR:	b <= rfob;
				`AND_RR:	b <= rfob;	// for bit flags
				`OR_RR:		b <= rfob;
				`EOR_RR:	b <= rfob;
				`MUL_RR:	begin b <= rfob; state <= MULDIV1; end
				`MULS_RR:	begin b <= rfob; state <= MULDIV1; end
`ifdef SUPPORT_DIVMOD
				`DIV_RR:	begin b <= rfob; state <= MULDIV1; end
				`DIVS_RR:	begin b <= rfob; state <= MULDIV1; end
				`MOD_RR:	begin b <= rfob; state <= MULDIV1; end
				`MODS_RR:	begin b <= rfob; state <= MULDIV1; end
`endif
`ifdef SUPPORT_SHIFT
				`ASL_RRR:	begin b <= rfob; state <= CALC; end
				`LSR_RRR:	begin b <= rfob; state <= CALC; end
`endif
				default:
					begin
						Rt <= 4'h0;
						pg2 <= `FALSE;
						ir <= {8{`BRK}};
						hwi <= `TRUE;
						vect <= {vbr[31:9],9'd495,2'b00};
						pc <= pc;		// override the pc increment
						state <= DECODE;
					end
				endcase
			end
		`LD_RR:		Rt <= ir[15:12];
		`ASL_RR:	Rt <= ir[15:12];
		`ROL_RR:	Rt <= ir[15:12];
		`LSR_RR:	Rt <= ir[15:12];
		`ROR_RR:	Rt <= ir[15:12];
		`DEC_RR:	Rt <= ir[15:12];
		`INC_RR:	Rt <= ir[15:12];
/*
		Can't P&R this
		`ADD_R:		begin Rt <= ir[11: 8]; b <= rfob; end
		`SUB_R:		begin Rt <= ir[11: 8]; b <= rfob; end
		`OR_R:		begin Rt <= ir[11: 8]; b <= rfob; end
		`AND_R:		begin Rt <= ir[11: 8]; b <= rfob; end
		`EOR_R:		begin Rt <= ir[11: 8]; b <= rfob; end
*/	
		`ADD_IMM4:	begin Rt <= ir[11: 8]; b <= {{28{ir[15]}},ir[15:12]}; end
		`SUB_IMM4:	begin Rt <= ir[11: 8]; b <= {{28{ir[15]}},ir[15:12]}; end
		`OR_IMM4:	begin Rt <= ir[11: 8]; b <= {{28{ir[15]}},ir[15:12]}; end
		`AND_IMM4:	begin Rt <= ir[11: 8]; b <= {{28{ir[15]}},ir[15:12]}; end
		`EOR_IMM4:	begin Rt <= ir[11: 8]; b <= {{28{ir[15]}},ir[15:12]}; end

		`ADD_IMM8:	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; end
		`SUB_IMM8:	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; end
		`MUL_IMM8:	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; state <= MULDIV1; end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8:	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; state <= MULDIV1; end
		`MOD_IMM8:	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; state <= MULDIV1; end
`endif
		`OR_IMM8:	begin Rt <= ir[15:12]; end
		`AND_IMM8: 	begin Rt <= ir[15:12]; b <= {{24{ir[23]}},ir[23:16]}; end
		`EOR_IMM8:	begin Rt <= ir[15:12]; end
		`CMP_IMM8:	;
`ifdef SUPPORT_SHIFT
		`ASL_IMM8:	begin Rt <= ir[15:12]; b <= ir[20:16]; state <= CALC; end
		`LSR_IMM8:	begin Rt <= ir[15:12]; b <= ir[20:16]; state <= CALC; end
`endif

		`ADD_IMM16:	begin Rt <= ir[15:12]; a <= rfoa; b <= {{16{ir[31]}},ir[31:16]}; end
		`SUB_IMM16:	begin Rt <= ir[15:12]; a <= rfoa; b <= {{16{ir[31]}},ir[31:16]}; end
		`MUL_IMM16:	begin Rt <= ir[15:12]; b <= {{16{ir[31]}},ir[31:16]}; state <= MULDIV1; end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM16:	begin Rt <= ir[15:12]; b <= {{16{ir[31]}},ir[31:16]}; state <= MULDIV1; end
		`MOD_IMM16:	begin Rt <= ir[15:12]; b <= {{16{ir[31]}},ir[31:16]}; state <= MULDIV1; end
`endif
		`OR_IMM16:	begin Rt <= ir[15:12]; end
		`AND_IMM16:	begin Rt <= ir[15:12]; b <= {{16{ir[31]}},ir[31:16]}; end
		`EOR_IMM16:	begin Rt <= ir[15:12]; end
	
		`ADD_IMM32:	begin Rt <= ir[15:12]; b <= ir[47:16]; end
		`SUB_IMM32:	begin Rt <= ir[15:12]; b <= ir[47:16]; end
		`MUL_IMM16:	begin Rt <= ir[15:12]; b <= ir[47:16]; state <= MULDIV1; end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM32:	begin Rt <= ir[15:12]; b <= ir[47:16]; state <= MULDIV1; end
		`MOD_IMM32:	begin Rt <= ir[15:12]; b <= ir[47:16]; state <= MULDIV1; end
`endif
		`OR_IMM32:	begin Rt <= ir[15:12]; end
		`AND_IMM32:	begin Rt <= ir[15:12]; b <= ir[47:16]; end
		`EOR_IMM32:	begin Rt <= ir[15:12]; end

		`LDA_IMM32:	Rt <= 4'd1;
		`LDX_IMM32:	Rt <= 4'd2;
		`LDY_IMM32: Rt <= 4'd3;
		`LDA_IMM16:	Rt <= 4'd1;
		`LDX_IMM16: Rt <= 4'd2;
		`LDA_IMM8: Rt <= 4'd1;
		`LDX_IMM8: Rt <= 4'd2;

		`SUB_SP8:	;
		`SUB_SP16:	;
		`SUB_SP32:	;

		`CPX_IMM32:	;
		`CPY_IMM32:	;

		`LDX_ZPX:
			begin
				Rt <= 4'd2;
				radr <= zpx32xy_address;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`LDY_ZPX:
			begin
				Rt <= 4'd3;
				radr <= zpx32xy_address;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`ORB_ZPX:
			begin
				Rt <= ir[19:16];
				radr <= zpx32_address[31:2];
				radr2LSB <= zpx32_address[1:0];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`LDX_ABS:
			begin
				Rt <= 4'd2;
				radr <= ir[39:8];
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`LDY_ABS:
			begin
				Rt <= 4'd3;
				radr <= ir[39:8];
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`ORB_ABS:
			begin
				Rt <= ir[15:12];
				radr <= ir[47:18];
				radr2LSB <= ir[17:16];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`LDX_ABSY:
			begin
				Rt <= 4'd2;
				radr <= absx32xy_address;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`LDY_ABSX:
			begin
				Rt <= 4'd3;
				radr <= absx32xy_address;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`ORB_ABSX:
			begin
				Rt <= ir[19:16];
				radr <= absx32_address[31:2];
				radr2LSB <= absx32_address[1:0];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`ST_ZPX:
			begin
				wadr <= zpx32_address;
				store_what <= `STW_RFA;
				state <= STORE1;
			end
		`STB_ZPX:
			begin
				wadr <= zpx32_address[31:2];
				wadr2LSB <= zpx32_address[1:0];
				store_what <= `STW_RFA8;
				state <= STORE1;
			end
		`ST_DSP:
			begin
				wadr <= {24'b0,ir[23:16]} + isp;
				store_what <= `STW_RFA;
				state <= STORE1;
			end
		`ST_ABS:
			begin
				wadr <= ir[47:16];
				store_what <= `STW_RFA;
				state <= STORE1;
			end
		`STB_ABS:
			begin
				wadr <= ir[47:18];
				wadr2LSB <= ir[17:16];
				store_what <= `STW_RFA8;
				state <= STORE1;
			end
		`ST_ABSX:
			begin
				wadr <= absx32_address;
				store_what <= `STW_RFA;
				state <= STORE1;
			end
		`STB_ABSX:
			begin
				wadr <= absx32_address[31:2];
				wadr2LSB <= absx32_address[1:0];
				store_what <= `STW_RFA8;
				state <= STORE1;
			end
		`STX_ZPX:
			begin
				wadr <= zpx32xy_address;
				store_what <= `STW_X;
				state <= STORE1;
			end
		`STX_ABS:
			begin
				wadr <= ir[39:8];
				store_what <= `STW_X;
				state <= STORE1;
			end
		`STY_ZPX:
			begin
				wadr <= zpx32xy_address;
				store_what <= `STW_Y;
				state <= STORE1;
			end
		`STY_ABS:
			begin
				wadr <= ir[39:8];
				store_what <= `STW_Y;
				state <= STORE1;
			end
		`ADD_ZPX,`SUB_ZPX,`AND_ZPX,`TRB_ZPX:
			begin
				Rt <= ir[19:16];
				radr <= zpx32_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`LEA_ZPX:
			begin
				Rt <= ir[19:16];
				res <= zpx32_address;
				state <= IFETCH;
			end
		// Trim a clock cycle off of loads by testing for Ra = 0.
		`OR_ZPX,`EOR_ZPX,`TSB_ZPX:
			begin
				Rt <= ir[19:16];
				radr <= zpx32_address;
				load_what <= (Ra==4'd0) ? `WORD_311: `WORD_310;
				state <= LOAD_MAC1;
			end
		`ASL_ZPX,`ROL_ZPX,`LSR_ZPX,`ROR_ZPX,`INC_ZPX,`DEC_ZPX:
			begin
				radr <= zpx32xy_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`BMS_ZPX,`BMC_ZPX,`BMF_ZPX,`BMT_ZPX:
			begin
				radr <= zpx32xy_address + acc[31:5];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`LEA_DSP:
			begin
				Rt <= ir[15:12];
				res <= {24'b0,ir[23:16]} + isp;
				state <= IFETCH;
			end
		`ADD_DSP,`SUB_DSP,`OR_DSP,`AND_DSP,`EOR_DSP:
			begin
				Rt <= ir[15:12];
				radr <= {24'b0,ir[23:16]} + isp;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`ADD_IX,`SUB_IX,`OR_IX,`AND_IX,`EOR_IX,`ST_IX,`LEA_IX:
			begin
				if (ir[7:0]!=`ST_IX)	// for ST_IX, Rt=0
					Rt <= ir[19:16];
				radr <= zpx32_address;
				load_what <= `IA_310;
				store_what <= `STW_A;
				state <= LOAD_MAC1;			
			end
		`LEA_RIND:
			begin
				Rt <= ir[19:16];
				res <= rfob;
				state <= IFETCH;
			end
		`ADD_RIND,`SUB_RIND,`OR_RIND,`AND_RIND,`EOR_RIND:
			begin
				radr <= rfob;
				Rt <= ir[19:16];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`ST_RIND:
			begin
				wadr <= rfob;
				store_what <= `STW_RFA;
				state <= STORE1;
			end
		`ADD_IY,`SUB_IY,`OR_IY,`AND_IY,`EOR_IY,`ST_IY,`LEA_IY:
			begin
				if (ir[7:0]!=`ST_IY)	// for ST_IY, Rt=0
					Rt <= ir[19:16];
				isIY <= 1'b1;
				radr <= ir[31:20];
				load_what <= `IA_310;
				store_what <= `STW_A;
				state <= LOAD_MAC1;	
			end
		`LEA_ABS:
			begin
				res <= ir[47:16];
				Rt <= ir[15:12];
				state <= IFETCH;
			end
		`OR_ABS,`EOR_ABS,`TSB_ABS:
			begin
				radr <= ir[47:16];
				Rt <= ir[15:12];
				load_what <= (Ra==4'd0) ? `WORD_311 : `WORD_310;
				state <= LOAD_MAC1;
			end
		`ADD_ABS,`SUB_ABS,`AND_ABS,`TRB_ABS:
			begin
				radr <= ir[47:16];
				Rt <= ir[15:12];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`ASL_ABS,`ROL_ABS,`LSR_ABS,`ROR_ABS,`INC_ABS,`DEC_ABS:
			begin
				radr <= ir[39:8];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`SPL_ABS:
			begin
				Rt <= 4'h0;
				radr <= ir[39:8];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`BMS_ABS,`BMC_ABS,`BMF_ABS,`BMT_ABS:
			begin
				radr <= ir[39:8] + acc[31:5];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`LEA_ABSX:
			begin
				res <= absx32_address;
				Rt <= ir[19:16];
				state <= IFETCH;
			end
		`ADD_ABSX,`SUB_ABSX,`AND_ABSX:
			begin
				radr <= absx32_address;
				Rt <= ir[19:16];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`OR_ABSX,`EOR_ABSX:
			begin
				radr <= absx32_address;
				Rt <= ir[19:16];
				load_what <= (Ra==4'd0) ? `WORD_311 : `WORD_310;
				state <= LOAD_MAC1;
			end
		`ASL_ABSX,`ROL_ABSX,`LSR_ABSX,`ROR_ABSX,`INC_ABSX,`DEC_ABSX:
			begin
				radr <= absx32xy_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`BMS_ABSX,`BMC_ABSX,`BMF_ABSX,`BMT_ABSX:
			begin
				radr <= absx32xy_address + acc[31:5];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`SPL_ABSX:
			begin
				Rt <= 4'h0;
				radr <= absx32xy_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end

		`CPX_ZPX:
			begin
				radr <= zpx32xy_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`CPY_ZPX:
			begin
				radr <= zpx32xy_address;
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`CPX_ABS:
			begin
				radr <= ir[39:8];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`CPY_ABS:
			begin
				radr <= ir[39:8];
				load_what <= `WORD_310;
				state <= LOAD_MAC1;
			end
		`BRK:
			begin
				bf <= !hwi;
				km <= `TRUE;
`ifdef DEBUG
				hist_capture <= `FALSE;
`endif
				radr <= isp_dec;
				wadr <= isp_dec;
				isp <= isp_dec;
				store_what <= `STW_PCHWI;
				state <= STORE1;
			end
		`INT0,`INT1:
			begin
				pg2 <= `FALSE;
				ir <= {8{`BRK}};
				vect <= {vbr[31:9],ir[0],ir[15:8],2'b00};
				state <= DECODE;
			end
		`JMP:
			begin
				pc[15:0] <= ir[23:8];
				state <= IFETCH;
			end
		`JML:
			begin
				pc <= ir[39:8];
				state <= IFETCH;
			end
		`JMP_IND:
			begin
				radr <= ir[39:8];
				load_what <= `PC_310;
				state <= LOAD_MAC1;
			end
		`JMP_INDX:
			begin
				radr <= ir[39:8] + x;
				load_what <= `PC_310;
				state <= LOAD_MAC1;
			end
		`JMP_RIND:
			begin
				pc <= rfoa;
				res <= pc + 32'd2;
				Rt <= ir[15:12];
				state <= IFETCH;
			end
		`JSR:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				isp <= isp_dec;
				store_what <= `STW_DEF;
				wdat <= pc+{31'd1,suppress_pcinc[0]};
				pc <= {pc[31:16],ir[23:8]};
				state <= STORE1;
			end
		`JSR_RIND:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				wdat <= pc + 32'd2;
				isp <= isp_dec;
				store_what <= `STW_DEF;
				pc <= rfoa;
				state <= STORE1;
			end
		`JSL,`JSR_INDX,`JSR_IND:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				isp <= isp_dec;
				store_what <= `STW_DEF;
				wdat <= suppress_pcinc[0] ? pc + 32'd5 : pc + 32'd2;
				pc <= ir[39:8];		// This pc assignment will be overridden later by JSR_INDX
				state <= STORE1;
			end
		`BSR:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				isp <= isp_dec;
				store_what <= `STW_DEF;
				wdat <= pc+{31'd1,suppress_pcinc[0]};
				pc <= pc + {{16{ir[23]}},ir[23:8]};
				state <= STORE1;
			end
		`RTS,`RTL:
				begin
				radr <= isp;
				isp <= isp_inc;
				load_what <= `PC_310;
				state <= LOAD_MAC1;
				end
		`RTI:	begin
				hist_capture <= `TRUE;
				radr <= isp;
				isp <= isp_inc;
				load_what <= `SR_310;
				state <= LOAD_MAC1;
				end
		`BEQ,`BNE,`BPL,`BMI,`BCC,`BCS,`BVC,`BVS,`BRA,
		`BGT,`BGE,`BLT,`BLE,`BHI,`BLS:
			begin
				if (ir[15:8]==8'h00) begin
					pg2 <= `FALSE;
					ir <= {8{`BRK}};
					pc <= pc;		// override the pc increment
					vect <= {vbr[31:9],`SLP_VECTNO,2'b00};
					state <= DECODE;
				end
				else if (ir[15:8]==8'h1) begin
					if (takb)
						pc <= pc + {{16{ir[31]}},ir[31:16]};
					else
						pc <= pcp4;
				end
				else begin
					if (takb)
						pc <= pc + {{24{ir[15]}},ir[15:8]};
					else
						pc <= pcp2;
				end
			end
		`BRL:
			begin
				if (ir[23:8]==16'h0000) begin
					pg2 <= `FALSE;
					ir <= {8{`BRK}};
					vect <= {vbr[31:9],`SLP_VECTNO,2'b00};
					pc <= pc;		// override the pc increment
					state <= DECODE;
				end
				else begin
					pc <= pc + {{16{ir[23]}},ir[23:8]};
					state <= IFETCH;
				end
			end
`ifdef SUPPORT_EXEC
		`EXEC,`ATNI:
			begin
				exbuf[31:0] <= rfoa;
				exbuf[63:32] <= rfob;
			end
`endif
		`PHP:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				store_what <= `STW_SR;
				isp <= isp_dec;
				state <= STORE1;
			end
		`PHA:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				store_what <= `STW_ACC;
				isp <= isp_dec;
				state <= STORE1;
			end
		`PHX:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				store_what <= `STW_X;
				isp <= isp_dec;
				state <= STORE1;
			end
		`PHY:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				store_what <= `STW_Y;
				isp <= isp_dec;
				state <= STORE1;
			end
		`PUSH:
			begin
				if (ir[15:12]==4'h0) begin
					radr <= isp_dec;
					wadr <= isp_dec;
					isp <= isp_dec;
				end
				else begin
					radr <= rfob-32'd1;
					wadr <= rfob-32'd1;
					wrrf <= 1'b1;
					Rt <= ir[15:12];
					res <= rfob-32'd1;
				end
				store_what <= `STW_A;
				state <= STORE1;
			end
		`PUSHA:
			begin
				radr <= isp_dec;
				wadr <= isp_dec;
				ir[11:8] <= 4'd1;
				store_what <= `STW_RFA;
				state <= STORE1;
				isp <= isp_dec;
			end
		`PLP:
			begin
				radr <= isp;
				isp <= isp_inc;
				load_what <= `SR_310;
				state <= LOAD_MAC1;
			end
		`PLA:
			begin
				Rt <= 4'd1;
				radr <= isp;
				isp <= isp_inc;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`PLX:
			begin
				Rt <= 4'd2;
				radr <= isp;
				isp <= isp_inc;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`PLY:
			begin
				Rt <= 4'd3;
				radr <= isp;
				isp <= isp_inc;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`POP:
			begin
				if (ir[11:8]!=4'h0) begin
					Rt <= ir[11:8];
					res <= rfoa+32'd1;
					wrrf <= 1'b1;
					radr <= rfoa;
				end
				else begin
					radr <= isp;
					isp <= isp_inc;
				end
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
		`POPA:
			begin
				Rt <= 4'd15;
				radr <= isp;
				isp <= isp_inc;
				load_what <= `WORD_311;
				state <= LOAD_MAC1;
			end
`ifdef SUPPORT_STRING
		`MVN:
			begin
				Rt <= 4'd3;
				radr <= x;
				res <= x_inc;
				load_what <= `WORD_312;
				pc <= pc;
				state <= LOAD_MAC1;
			end
		`MVP:
			begin
				Rt <= 4'd3;
				radr <= x;
				res <= x_dec;
				load_what <= `WORD_312;
				pc <= pc;
				state <= LOAD_MAC1;
			end
		`STS:
			begin
				Rt <= 4'd3;
				radr <= y;
				wadr <= y;
				store_what <= `STW_X;
				acc <= acc_dec;
				pc <= pc;
				state <= STORE1;
			end
		`CMPS:
			begin
				Rt <= 4'd3;
				radr <= x;
				res <= x_inc;
				pc <= pc;
				load_what <= `WORD_313;
				state <= LOAD_MAC1;
			end
`endif
		`PG2:	begin
					pg2 <= `TRUE;
					ir <= ir[63:8];
					state <= DECODE;
				end
		default:	// unimplemented opcode
			begin
				res <= 32'd0;
				pg2 <= `FALSE;
				ir <= {8{`BRK}};
				hwi <= `TRUE;
				vect <= {vbr[31:9],9'd495,2'b00};
				pc <= pc;		// override the pc increment
				state <= DECODE;
			end
		endcase
	end
endtask
