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
BYTE_IFETCH:
	begin
		ic_whence <= BYTE_IFETCH;
		vect <= m816 ? `BRK_VECT_816 : `BYTE_IRQ_VECT;
		vect[31:16] <= abs8[31:16];
		suppress_pcinc <= 4'hF;				// default: no suppression of increment
		opc <= pc;
		hwi <= `FALSE;
		isBusErr <= `FALSE;
		pg2 <= `FALSE;
		isIY <= `FALSE;
		isIY24 <= `FALSE;
		store_what <= m16 ? `STW_DEF70 : `STW_DEF;
		if (nmi_edge & gie) begin
			ir[7:0] <= `BRK;
			nmi_edge <= 1'b0;
			wai <= 1'b0;
			hwi <= `TRUE;
			if (nmoi) begin
				vect <= `NMI_VECT;
				next_state(DECODE);
			end
			else begin
				vect <= m816 ? `NMI_VECT_816 : `BYTE_NMI_VECT;
				vect[31:16] <= abs8[31:16];
				next_state(BYTE_DECODE);
			end
		end
		else if (irq_i & gie) begin
			wai <= 1'b0;
			if (im) begin
				if (unCachedInsn) begin
					if (bhit) begin
						ir <= ibuf;
						next_state(BYTE_DECODE);
					end
					else
						next_state(LOAD_IBUF1);
				end
				else begin
					if (ihit) begin
						ir <= insn;
						next_state(BYTE_DECODE);
					end
					else
						next_state(ICACHE1);
				end
			end
			else begin
				ir[7:0] <= `BRK;
				if (m816)
					vect <= `IRQ_VECT_816;
				hwi <= `TRUE;
				if (nmoi) begin
					vect <= {vbr[31:9],irq_vect,2'b00};
					next_state(DECODE);
				end
				else begin
					next_state(BYTE_DECODE);
				end
			end
		end
		else if (!wai) begin
			if (unCachedInsn) begin
				if (bhit) begin
					ir <= ibuf;
					next_state(BYTE_DECODE);
				end
				else
					next_state(LOAD_IBUF1);
			end
			else begin
				if (ihit) begin
					ir <= insn;
					next_state(BYTE_DECODE);
				end
				else
					next_state(ICACHE1);
			end
		end
`ifdef DEBUG
		if (hist_capture) begin
			history_buf[history_ndx] <= pc;
			history_ndx <= history_ndx+7'd1;
		end
`endif
		case(ir[7:0])
		// Note the break flag is not affected by SEP/REP
		// Setting the index registers to eight bit zeros out the upper part of the register.
		`SEP:
			begin
				cf <= cf | ir[8];
				zf <= zf | ir[9];
				im <= im | ir[10];
				df <= df | ir[11];
				if (m816) begin
					x_bit <= x_bit | ir[12];
					m_bit <= m_bit | ir[13];
					//if (ir[13]) acc[31:8] <= 24'd0;
					if (ir[12]) begin
						x[31:8] <= 24'd0;
						y[31:8] <= 24'd0;
					end
				end
				vf <= vf | ir[14];
				nf <= nf | ir[15];
			end
		`REP:
			begin
				cf <= cf & ~ir[8];
				zf <= zf & ~ir[9];
				im <= im & ~ir[10];
				df <= df & ~ir[11];
				if (m816) begin
					x_bit <= x_bit & ~ir[12];
					m_bit <= m_bit & ~ir[13];
				end
				vf <= vf & ~ir[14];
				nf <= nf & ~ir[15];
			end
		`XBA:
			begin
				acc[15:0] <= res16[15:0];
				nf <= resn8;
				zf <= resz8;
			end
		`TAY,`TXY,`DEY,`INY:		if (xb16) begin y[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end	else begin y[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`TAX,`TYX,`TSX,`DEX,`INX:	if (xb16) begin x[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end else begin x[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`TSA,`TYA,`TXA,`INA,`DEA:	if (m16) begin acc[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end else begin acc[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`TAS,`TXS: begin if (m816) sp <= res16[15:0]; else sp <= {8'h01,res8[7:0]}; end
		`TCD:	begin dpr <= res16[15:0]; end
		`TDC:	begin acc[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end
		`ADC_IMM:
			begin
				if (m16) begin
					acc[15:0] <= df ? bcaio : res16[15:0];
					cf <= df ? bcaico : resc16;
//						vf <= resv8;
					vf <= (res16[15] ^ b16[15]) & (1'b1 ^ acc[15] ^ b16[15]);
					nf <= df ? bcaio[15] : resn16;
					zf <= df ? bcaio==16'h0000 : resz16;
				end
				else begin
					acc[7:0] <= df ? bcaio[7:0] : res8[7:0];
					cf <= df ? bcaico8 : resc8;
//						vf <= resv8;
					vf <= (res8[7] ^ b8[7]) & (1'b1 ^ acc[7] ^ b8[7]);
					nf <= df ? bcaio[7] : resn8;
					zf <= df ? bcaio[7:0]==8'h00 : resz8;
				end
			end
		`ADC_ZP,`ADC_ZPX,`ADC_IX,`ADC_IY,`ADC_IYL,`ADC_ABS,`ADC_ABSX,`ADC_ABSY,`ADC_I,`ADC_IL,`ADC_AL,`ADC_ALX,`ADC_DSP,`ADC_DSPIY:
			begin
				if (m16) begin
					acc[15:0] <= df ? bcao : res16[15:0];
					cf <= df ? bcaco : resc16;
					vf <= (res16[15] ^ b16[15]) & (1'b1 ^ acc[15] ^ b16[15]);
					nf <= df ? bcao[15] : resn16;
					zf <= df ? bcao==16'h0000 : resz16;
				end
				else begin
					acc[7:0] <= df ? bcao[7:0] : res8[7:0];
					cf <= df ? bcaco8 : resc8;
					vf <= (res8[7] ^ b8[7]) & (1'b1 ^ acc[7] ^ b8[7]);
					nf <= df ? bcao[7] : resn8;
					zf <= df ? bcao[7:0]==8'h00 : resz8;
				end
			end
		`SBC_IMM:
			begin
				if (m16) begin
					acc[15:0] <= df ? bcsio : res16[15:0];
					cf <= ~(df ? bcsico : resc16);
					vf <= (1'b1 ^ res16[15] ^ b16[15]) & (acc[15] ^ b16[15]);
					nf <= df ? bcsio[15] : resn16;
					zf <= df ? bcsio==16'h0000 : resz16;
				end
				else begin
					acc[7:0] <= df ? bcsio[7:0] : res8[7:0];
					cf <= ~(df ? bcsico8 : resc8);
					vf <= (1'b1 ^ res8[7] ^ b8[7]) & (acc[7] ^ b8[7]);
					nf <= df ? bcsio[7] : resn8;
					zf <= df ? bcsio[7:0]==8'h00 : resz8;
				end
			end
		`SBC_ZP,`SBC_ZPX,`SBC_IX,`SBC_IY,`SBC_IYL,`SBC_ABS,`SBC_ABSX,`SBC_ABSY,`SBC_I,`SBC_IL,`SBC_AL,`SBC_ALX,`SBC_DSP,`SBC_DSPIY:
			begin
				if (m16) begin
					acc[15:0] <= df ? bcso : res16[15:0];
					vf <= (1'b1 ^ res16[15] ^ b16[15]) & (acc[15] ^ b16[15]);
					cf <= ~(df ? bcsco : resc16);
					nf <= df ? bcso[15] : resn16;
					zf <= df ? bcso==16'h0000 : resz16;
				end
				else begin
					acc[7:0] <= df ? bcso[7:0] : res8[7:0];
					vf <= (1'b1 ^ res8[7] ^ b8[7]) & (acc[7] ^ b8[7]);
					cf <= ~(df ? bcsco8 : resc8);
					nf <= df ? bcso[7] : resn8;
					zf <= df ? bcso[7:0]==8'h00 : resz8;
				end
			end
		`CMP_IMM,`CMP_ZP,`CMP_ZPX,`CMP_IX,`CMP_IY,`CMP_IYL,`CMP_ABS,`CMP_ABSX,`CMP_ABSY,`CMP_I,`CMP_IL,`CMP_AL,`CMP_ALX,`CMP_DSP,`CMP_DSPIY:
				if (m16) begin cf <= ~resc16; nf <= resn16; zf <= resz16; end else begin cf <= ~resc8; nf <= resn8; zf <= resz8; end
		`CPX_IMM,`CPX_ZP,`CPX_ABS,
		`CPY_IMM,`CPY_ZP,`CPY_ABS:
				if (xb16) begin cf <= ~resc16; nf <= resn16; zf <= resz16; end else begin cf <= ~resc8; nf <= resn8; zf <= resz8; end
		`BIT_IMM,`BIT_ZP,`BIT_ZPX,`BIT_ABS,`BIT_ABSX:
				if (m16) begin nf <= b16[15]; vf <= b16[14]; zf <= resz16; end else begin nf <= b8[7]; vf <= b8[6]; zf <= resz8; end
		`TRB_ZP,`TRB_ABS,`TSB_ZP,`TSB_ABS:
			if (m16) begin zf <= resz16; end else begin zf <= resz8; end
		`LDA_IMM,`LDA_ZP,`LDA_ZPX,`LDA_IX,`LDA_IY,`LDA_IYL,`LDA_ABS,`LDA_ABSX,`LDA_ABSY,`LDA_I,`LDA_IL,`LDA_AL,`LDA_ALX,`LDA_DSP,`LDA_DSPIY,
		`AND_IMM,`AND_ZP,`AND_ZPX,`AND_IX,`AND_IY,`AND_IYL,`AND_ABS,`AND_ABSX,`AND_ABSY,`AND_I,`AND_IL,`AND_AL,`AND_ALX,`AND_DSP,`AND_DSPIY,
		`ORA_IMM,`ORA_ZP,`ORA_ZPX,`ORA_IX,`ORA_IY,`ORA_IYL,`ORA_ABS,`ORA_ABSX,`ORA_ABSY,`ORA_I,`ORA_IL,`ORA_AL,`ORA_ALX,`ORA_DSP,`ORA_DSPIY,
		`EOR_IMM,`EOR_ZP,`EOR_ZPX,`EOR_IX,`EOR_IY,`EOR_IYL,`EOR_ABS,`EOR_ABSX,`EOR_ABSY,`EOR_I,`EOR_IL,`EOR_AL,`EOR_ALX,`EOR_DSP,`EOR_DSPIY:
			if (m16) begin acc[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end
			else begin acc[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`ASL_ACC:	if (m16) begin acc[15:0] <= res16[15:0]; cf <= resc16; nf <= resn16; zf <= resz16; end else begin acc[7:0] <= res8[7:0]; cf <= resc8; nf <= resn8; zf <= resz8; end
		`ROL_ACC:	if (m16) begin acc[15:0] <= res16[15:0]; cf <= resc16; nf <= resn16; zf <= resz16; end else begin acc[7:0] <= res8[7:0]; cf <= resc8; nf <= resn8; zf <= resz8; end
		`LSR_ACC:	if (m16) begin acc[15:0] <= res16[15:0]; cf <= resc16; nf <= resn16; zf <= resz16; end else begin acc[7:0] <= res8[7:0]; cf <= resc8; nf <= resn8; zf <= resz8; end
		`ROR_ACC:	if (m16) begin acc[15:0] <= res16[15:0]; cf <= resc16; nf <= resn16; zf <= resz16; end else begin acc[7:0] <= res8[7:0]; cf <= resc8; nf <= resn8; zf <= resz8; end
		`ASL_ZP,`ASL_ZPX,`ASL_ABS,`ASL_ABSX: if (m16) begin cf <= resc16; nf <= resn16; zf <= resz16; end else begin cf <= resc8; nf <= resn8; zf <= resz8; end
		`ROL_ZP,`ROL_ZPX,`ROL_ABS,`ROL_ABSX: if (m16) begin cf <= resc16; nf <= resn16; zf <= resz16; end else begin cf <= resc8; nf <= resn8; zf <= resz8; end
		`LSR_ZP,`LSR_ZPX,`LSR_ABS,`LSR_ABSX: if (m16) begin cf <= resc16; nf <= resn16; zf <= resz16; end else begin cf <= resc8; nf <= resn8; zf <= resz8; end
		`ROR_ZP,`ROR_ZPX,`ROR_ABS,`ROR_ABSX: if (m16) begin cf <= resc16; nf <= resn16; zf <= resz16; end else begin cf <= resc8; nf <= resn8; zf <= resz8; end
		`INC_ZP,`INC_ZPX,`INC_ABS,`INC_ABSX: if (m16) begin nf <= resn16; zf <= resz16; end else begin nf <= resn8; zf <= resz8; end
		`DEC_ZP,`DEC_ZPX,`DEC_ABS,`DEC_ABSX: if (m16) begin nf <= resn16; zf <= resz16; end else begin nf <= resn8; zf <= resz8; end
		`PLA:	if (m16) begin acc[15:0] <= res16[15:0]; zf <= resz16; nf <= resn16; end else begin acc[7:0] <= res8[7:0]; zf <= resz8; nf <= resn8; end
		`PLX:	if (xb16) begin x[15:0] <= res16[15:0]; zf <= resz16; nf <= resn16; end else begin x[7:0] <= res8[7:0]; zf <= resz8; nf <= resn8; end
		`PLY:	if (xb16) begin y[15:0] <= res16[15:0]; zf <= resz16; nf <= resn16; end else begin y[7:0] <= res8[7:0]; zf <= resz8; nf <= resn8; end
		`PLB:	begin dbr <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`PLD:	begin dpr <= res16[15:0]; nf <= resn16; zf <= resz16; end
		`LDX_IMM,`LDX_ZP,`LDX_ZPY,`LDX_ABS,`LDX_ABSY:	if (xb16) begin x[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end else begin x[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		`LDY_IMM,`LDY_ZP,`LDY_ZPX,`LDY_ABS,`LDY_ABSX:	if (xb16) begin y[15:0] <= res16[15:0]; nf <= resn16; zf <= resz16; end else begin y[7:0] <= res8[7:0]; nf <= resn8; zf <= resz8; end
		endcase
	end
