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
IFETCH:
	begin
		ic_whence <= IFETCH;
		vect <= {vbr[31:9],`BRK_VECTNO,2'b00};
		suppress_pcinc <= 4'hF;				// default: no suppression of increment
		opc <= pc;
		hwi <= `FALSE;
		isBusErr <= `FALSE;
		pg2 <= `FALSE;
		isIY <= `FALSE;
		isIY24 <= `FALSE;
		store_what <= `STW_DEF;
		if (nmi_edge & gie & !isExec & !isAtni) begin
			ir[7:0] <= `BRK;
			nmi_edge <= 1'b0;
			wai <= 1'b0;
			hwi <= `TRUE;
			next_state(DECODE);
			vect <= `NMI_VECT;
		end
		else if ((irq_i|spi) & gie & !isExec & !isAtni) begin
			wai <= 1'b0;
			if (im) begin
				if (ttrig) begin
					ir[7:0] <= `BRK;
					vect <= {vbr[31:9],9'd490,2'b00};
					next_state(DECODE);
				end
				else if (isExec) begin
					ir <= exbuf;
					exbuf <= 64'd0;
					suppress_pcinc <= 4'h0;
					next_state(DECODE);
				end
				else if (unCachedInsn) begin
					if (bhit) begin
						ir <= ibuf + exbuf;
						exbuf <= 64'd0;
						next_state(DECODE);
					end
					else begin
						pg2 <= pg2;
						state <= LOAD_IBUF1;
					end
				end
				else begin
					if (ihit) begin
						ir <= insn + exbuf;
						exbuf <= 64'd0;
						next_state(DECODE);
					end
					else begin
						pg2 <= pg2;
						next_state(ICACHE1);
					end
				end
			end
			else begin
				ir[7:0] <= `BRK;
				hwi <= `TRUE;
				if (spi) begin
					spi <= 1'b0;
					spi_cnt <= SPIN_CYCLES;
					vect <= {vbr[31:9],9'd3,2'b00};
				end
				else begin
					vect <= {vbr[31:9],irq_vect,2'b00};
				end
				next_state(DECODE);
			end
		end
		else if (!wai) begin
			if (ttrig) begin
				ir[7:0] <= `BRK;
				vect <= {vbr[31:9],9'd490,2'b00};
				next_state(DECODE);
			end
			else if (isExec) begin
				ir <= exbuf;
				exbuf <= 64'd0;
				suppress_pcinc <= 4'h0;
				next_state(DECODE);
			end
			else if (unCachedInsn) begin
				if (bhit) begin
					ir <= ibuf + exbuf;
					exbuf <= 64'd0;
					next_state(DECODE);
				end
				else begin
					pg2 <= pg2;
					state <= LOAD_IBUF1;
				end
			end
			else begin
				if (ihit) begin
					ir <= insn + exbuf;
					exbuf <= 64'd0;
					next_state(DECODE);
				end
				else begin
					pg2 <= pg2;
					next_state(ICACHE1);
				end
			end
		end
		// During a cache miss all these assignments will repeat. It's not a
		// problem. The history buffer will be stuffed with the same pc address
		// for several cycles until the cache load is complete.
`ifdef DEBUG
		if (hist_capture) begin
			history_buf[history_ndx] <= pc;
			history_ndx <= history_ndx+7'd1;
		end
`endif
		case(ir9)
		`TAS,`TXS:	begin isp <= res[31:0]; gie <= 1'b1; end
		`SUB_SP8,`SUB_SP16,`SUB_SP32:	isp <= res[31:0];
		`TRS:
			begin
				case(ir[15:12])
				4'h0:	begin
						$display("res=%h",res);
`ifdef SUPPORT_ICACHE
						icacheOn <= res[0];
`endif
`ifdef SUPPORT_DCACHE
						dcacheOn <= res[1];
						write_allocate <= res[2];
`endif
						end
				4'h5:	lfsr <= res[31:0];
				4'h7:	abs8 <= res[31:0];
				4'h8:	begin vbr <= {res[31:9],9'h000}; nmoi <= res[0]; end
				4'hE:	begin sp <= res[15:0]; spage[31:16] <= res[31:16]; end
				4'hF:	begin isp <= res[31:0]; gie <= 1'b1; end
				endcase
			end
		`RR:
			case(ir[23:20])
			`ADD_RR:	begin vf <= resv32; cf <= resc32; nf <= resn32; zf <= resz32; end
			`SUB_RR:	
					if (Rt==4'h0)	// CMP doesn't set overflow
						begin cf <= ~resc32; nf <= resn32; zf <= resz32; end
					else
						begin vf <= resv32; cf <= ~resc32; nf <= resn32; zf <= resz32; end
			`AND_RR:
				if (Rt==4'h0)	// BIT sets overflow
					begin nf <= b[31]; vf <= b[30]; zf <= resz32; end
				else
					begin nf <= resn32; zf <= resz32; end
			default:
					begin nf <= resn32; zf <= resz32; end
			endcase
		`LD_RR:	begin zf <= resz32; nf <= resn32; end
		`DEC_RR,`INC_RR: begin zf <= resz32; nf <= resn32; end
		`ADD_IMM4,`ADD_R,
		`ADD_IMM8,`ADD_IMM16,`ADD_IMM32,`ADD_ZPX,`ADD_IX,`ADD_IY,`ADD_ABS,`ADD_ABSX,`ADD_RIND:
			begin vf <= resv32; cf <= resc32; nf <= resn32; zf <= resz32; end
		`SUB_IMM4,`SUB_R,
		`SUB_IMM8,`SUB_IMM16,`SUB_IMM32,`SUB_ZPX,`SUB_IX,`SUB_IY,`SUB_ABS,`SUB_ABSX,`SUB_RIND:
			if (Rt==4'h0)	// CMP doesn't set overflow
				begin cf <= ~resc32; nf <= resn32; zf <= resz32; end
			else
				begin vf <= resv32; cf <= ~resc32; nf <= resn32; zf <= resz32; end
`ifdef SUPPORT_DIVMOD
		`DIV_IMM8,`DIV_IMM16,`DIV_IMM32,
		`MOD_IMM8,`MOD_IMM16,`MOD_IMM32,
`endif
		`MUL_IMM8,`MUL_IMM16,`MUL_IMM32:
			begin nf <= resn32; zf <= resz32; end
		`AND_IMM4,`AND_R,
		`AND_IMM8,`AND_IMM16,`AND_IMM32,`AND_ZPX,`AND_IX,`AND_IY,`AND_ABS,`AND_ABSX,`AND_RIND:
			if (Rt==4'h0)	// BIT sets overflow
				begin nf <= b[31]; vf <= b[30]; zf <= resz32; end
			else
				begin nf <= resn32; zf <= resz32; end
		`ORB_ZPX,`ORB_ABS,`ORB_ABSX,
		`OR_IMM4,`OR_R,
		`OR_IMM8,`OR_IMM16,`OR_IMM32,`OR_ZPX,`OR_IX,`OR_IY,`OR_ABS,`OR_ABSX,`OR_RIND,
		`EOR_IMM4,`EOR_R,
		`EOR_IMM8,`EOR_IMM16,`EOR_IMM32,`EOR_ZPX,`EOR_IX,`EOR_IY,`EOR_ABS,`EOR_ABSX,`EOR_RIND:
			begin nf <= resn32; zf <= resz32; end
		`ASL_ACC,`ROL_ACC,`LSR_ACC,`ROR_ACC:
			begin cf <= resc32; nf <= resn32; zf <= resz32; end
		`ASL_RR,`ROL_RR,`LSR_RR,`ROR_RR,
		`ASL_ZPX,`ASL_ABS,`ASL_ABSX,
		`ROL_ZPX,`ROL_ABS,`ROL_ABSX,
		`LSR_ZPX,`LSR_ABS,`LSR_ABSX,
		`ROR_ZPX,`ROR_ABS,`ROR_ABSX:
			begin cf <= resc32; nf <= resn32; zf <= resz32; end
		`ASL_IMM8: begin nf <= resn32; zf <= resz32; end
		`LSR_IMM8: begin nf <= resn32; zf <= resz32; end
		`BMT_ZPX,`BMT_ABS,`BMT_ABSX: begin nf <= resn32; zf <= resz32; end
		`INC_ZPX,`INC_ABS,`INC_ABSX: begin nf <= resn32; zf <= resz32; end
		`DEC_ZPX,`DEC_ABS,`DEC_ABSX: begin nf <= resn32; zf <= resz32; end
		`TAX,`TYX,`TSX,`DEX,`INX,
		`LDX_IMM32,`LDX_IMM16,`LDX_IMM8,`LDX_ZPY,`LDX_ABS,`LDX_ABSY,`PLX:
			begin nf <= resn32; zf <= resz32; end
		`TAY,`TXY,`DEY,`INY,
		`LDY_IMM32,`LDY_ZPX,`LDY_ABS,`LDY_ABSX,`PLY:
			begin nf <= resn32; zf <= resz32; end
		`CPX_IMM32,`CPX_ZPX,`CPX_ABS:	begin cf <= ~resc32; nf <= resn32; zf <= resz32; end
		`CPY_IMM32,`CPY_ZPX,`CPY_ABS:	begin cf <= ~resc32; nf <= resn32; zf <= resz32; end
		`CMP_IMM8: begin cf <= ~resc32; nf <= resn32; zf <= resz32; end
		`TSA,`TYA,`TXA,`INA,`DEA,
		`LDA_IMM32,`LDA_IMM16,`LDA_IMM8,`PLA:	begin nf <= resn32; zf <= resz32; end
		`POP:	begin nf <= resn32; zf <= resz32; end
		`TRB_ZPX,`TRB_ABS,`TSB_ZPX,`TSB_ABS:
			begin zf <= resz32; end
		`BMT_ZPX,`BMT_ABS,`BMT_ABSX:
			begin zf <= resz32; nf <= resn32; end
//		`SPL:	begin if (radr==65002) acc <= 32'h52544600; end
		endcase
	end
