// ============================================================================
//  DECODE
//  - decode / dispatch instruction
//
//
//  (C) 2009-2012  Robert Finch
//  Stratford
//  robfinch[remove]@opencores.org
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
//  Verilog 
//
// Decode / dispatch instruction
// ============================================================================
//
DECODE:
	casex(ir)
	`MORE1: state <= XI_FETCH;
	`MORE2: state <= XI_FETCH;
	`EXTOP: state <= XI_FETCH;

	`DEC_REG,`INC_REG:
		begin
			w <= 1'b1;
			rrr <= ir[2:0];
			state <= REGFETCHA;
		end

	`LEA: state <= EXECUTE;

	//-----------------------------------------------------------------
	// Immediate Loads
	//-----------------------------------------------------------------
	
	`MOV_I2AL,`MOV_I2DL,`MOV_I2CL,`MOV_I2BL,`MOV_I2AH,`MOV_I2DH,`MOV_I2CH,`MOV_I2BH:
		begin
			`INITIATE_CODE_READ
			state <= MOV_I2BYTREG;
		end

	`MOV_I2AX,`MOV_I2DX,`MOV_I2CX,`MOV_I2BX,`MOV_I2SP,`MOV_I2BP,`MOV_I2SI,`MOV_I2DI:
		begin
			w <= 1'b1;
			rrr <= ir[2:0];
			if (ip==16'hFFFF) begin
				int_num <= 8'h0d;
				state <= INT2;
			end
			else
				state <= FETCH_IMM16;
		end
	
	`XLAT:
		if (!cyc_o) begin
			cyc_type <= `CT_RDMEM;
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			adr_o <= {seg_reg,`SEG_SHIFT} + bx + al;
		end
		else if (ack_i) begin
			cyc_type <= `CT_PASSIVE;
			cyc_o <= 1'b0;
			stb_o <= 1'b0;
			res <= dat_i;
			wrregs <= 1'b1;
			w <= 1'b0;
			rrr <= 3'd0;
			state <= IFETCH;
		end

	//-----------------------------------------------------------------
	// Arithmetic Operations
	//-----------------------------------------------------------------
	`AAA,`AAS:
		begin
			state <= IFETCH;
			wrregs <= 1'b1;
			w <= 1'b1;
			rrr <= 3'd0;
			res <= alu_o;
			af <= (al[3:0]>4'h9 || af);
			cf <= (al[3:0]>4'h9 || af);
		end
	`ADD_ALI8,`ADC_ALI8,`SUB_ALI8,`SBB_ALI8,`AND_ALI8,`OR_ALI8,`XOR_ALI8,`CMP_ALI8,`TEST_ALI8:
		begin
			w <= 1'b0;
			a <= {{8{al[7]}},al};
			rrr <= 3'd0;
			state <= FETCH_IMM8;
		end
	`ADD_AXI16,`ADC_AXI16,`SUB_AXI16,`SBB_AXI16,`AND_AXI16,`OR_AXI16,`XOR_AXI16,`CMP_AXI16,`TEST_AXI16:
		begin
			w <= 1'b1;
			a <= ax;
			rrr <= 3'd0;
			if (ip==16'hFFFF) begin
				int_num <= 8'h0d;
				state <= INT2;
			end
			else
				state <= FETCH_IMM16;
		end
	`ALU_I2R8:
		begin
			state <= FETCH_IMM8;
			a <= rrro;
		end
	`ALU_I2R16:
		begin
			state <= FETCH_IMM16;
			a <= rrro;
		end
	`XCHG_AXR:
		begin
			state <= IFETCH;
			wrregs <= 1'b1;
			w <= 1'b1;
			rrr <= ir[2:0];
			res <= ax;
			case(ir[2:0])
			3'd0:	ax <= ax;
			3'd1:	ax <= cx;
			3'd2:	ax <= dx;
			3'd3:	ax <= bx;
			3'd4:	ax <= sp;
			3'd5:	ax <= bp;
			3'd6:	ax <= si;
			3'd7:	ax <= di;
			endcase
		end
	`CBW: begin ax[15:8] <= {8{ax[7]}}; state <= IFETCH; end
	`CWD:
		begin
			state <= IFETCH;
			wrregs <= 1'b1;
			w <= 1'b1;
			rrr <= 3'd2;
			res <= {16{ax[15]}};
		end

	//-----------------------------------------------------------------
	// String Operations
	//-----------------------------------------------------------------
	`LODSB: state <= LODS;
	`LODSW: state <= LODS;
	`STOSB: state <= STOS;
	`STOSW: state <= STOS;
	`MOVSB: state <= MOVS;
	`MOVSW: state <= MOVS;
	`CMPSB: state <= CMPSB;
	`CMPSW: state <= CMPSW;
	`SCASB: state <= SCASB;
	`SCASW: state <= SCASW;

	//-----------------------------------------------------------------
	// Stack Operations
	//-----------------------------------------------------------------
	`PUSH_REG: begin sp <= sp_dec; state <= PUSH; end
	`PUSH_DS: begin sp <= sp_dec; state <= PUSH; end
	`PUSH_ES: begin sp <= sp_dec; state <= PUSH; end
	`PUSH_SS: begin sp <= sp_dec; state <= PUSH; end
	`PUSH_CS: begin sp <= sp_dec; state <= PUSH; end
	`PUSHF: begin sp <= sp_dec; state <= PUSH; end
	`POP_REG: state <= POP;
	`POP_DS: state <= POP;
	`POP_ES: state <= POP;
	`POP_SS: state <= POP;
	`POPF: state <= POP;

	//-----------------------------------------------------------------
	// Flow controls
	//-----------------------------------------------------------------
	`NOP: state <= IFETCH;
	`HLT: if (pe_nmi | (irq_i & ie)) state <= IFETCH;
	`WAI: if (!busy_i) state <= IFETCH;
	`LOOP: begin cx <= cx_dec; state <= BRANCH1; end
	`LOOPZ: begin cx <= cx_dec; state <= BRANCH1; end
	`LOOPNZ: begin cx <= cx_dec; state <= BRANCH1; end
	`Jcc: state <= BRANCH1;
	`JCXZ: state <= BRANCH1;
	`JMPS: state <= BRANCH1;
	`JMPF: state <= FETCH_OFFSET;
	`CALL: begin sp <= sp_dec; state <= FETCH_DISP16; end
	`CALLF: begin sp <= sp_dec; state <= FETCH_OFFSET; end
	`RET: state <= RETPOP;		// data16 is zero
	`RETPOP: state <= FETCH_STK_ADJ1;
	`RETF: state <= RETFPOP;	// data16 is zero
	`RETFPOP: state <= FETCH_STK_ADJ1;
	`IRET: state <= IRET1;
	`INT: state <= INT;
	`INT3: begin int_num <= 8'd3; state <= INT2; end
	`INTO:
		if (vf) begin
			int_num <= 8'd4;
			state <= INT2;
		end
		else
			state <= IFETCH;

	//-----------------------------------------------------------------
	// Flag register operations
	//-----------------------------------------------------------------
	`STI: begin ie <= 1'b1; state <= IFETCH; end
	`CLI: begin ie <= 1'b0; state <= IFETCH; end
	`STD: begin df <= 1'b1; state <= IFETCH; end
	`CLD: begin df <= 1'b0; state <= IFETCH; end
	`STC: begin cf <= 1'b1; state <= IFETCH; end
	`CLC: begin cf <= 1'b0; state <= IFETCH; end
	`CMC: begin cf <=  !cf; state <= IFETCH; end
	`LAHF:
		begin
			ax[15] <= sf;
			ax[14] <= zf;
			ax[12] <= af;
			ax[10] <= pf;
			ax[8] <= cf;
			state <= IFETCH;
		end
	`SAHF:
		begin
			sf <= ah[7];
			zf <= ah[6];
			af <= ah[4];
			pf <= ah[2];
			cf <= ah[0];
			state <= IFETCH;
		end

	//-----------------------------------------------------------------
	// IO instructions
	// - fetch port number, then vector
	//-----------------------------------------------------------------
	`INB: state <= INB;
	`INW: state <= INW;
	`OUTB: state <= OUTB;
	`OUTW: state <= OUTW;
	`INB_DX: begin ea <= {`SEG_SHIFT,dx}; state <= INB1; end
	`INW_DX: begin ea <= {`SEG_SHIFT,dx}; state <= INW1; end
	`OUTB_DX: begin ea <= {`SEG_SHIFT,dx}; state <= OUTB1; end
	`OUTW_DX: begin ea <= {`SEG_SHIFT,dx}; state <= OUTW1; end
	`INSB: state <= INSB;
	`OUTSB: state <= OUTSB;
	`OUTSW: state <= OUTSW;

	//-----------------------------------------------------------------
	// Control Prefix
	//-----------------------------------------------------------------
	`LOCK: begin lock_insn <= ir; state <= IFETCH; end
	`REPZ,`REPNZ,`CS,`DS,`ES,`SS: state <= IFETCH;

	//-----------------------------------------------------------------
	// disp16 instructions
	//-----------------------------------------------------------------
	`MOV_M2AL,`MOV_M2AX,`MOV_AL2M,`MOV_AX2M,`CALL,`JMP:
		begin
			code_read();
			state <= FETCH_DISP16_ACK;
		end

	default:
		begin
		if (v) shftamt <= cl[3:0];
		else shftamt <= 4'd1;
		//-----------------------------------------------------------------
		// MOD/RM instructions
		//-----------------------------------------------------------------
		$display("Fetching mod/rm, w=",w);
		if (ir==`MOV_R2S || ir==`MOV_S2R)
			w <= 1'b1;
		if (ir==`LDS || ir==`LES)
			w <= 1'b1;
		if (fetch_modrm) begin
			code_read();
			state <= EACALC;
		end
		else
			state <= IFETCH;
		end
	endcase
