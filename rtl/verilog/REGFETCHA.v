// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// REGFETCHA.v - fetch register A / execute some instructions
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
REGFETCHA:
	begin
		Rcbit <= 1'b0;
		a <= rfo;
		b <= 32'd0;
		Rn <= ir[20:16];
		// RIX format ?
		if (hasConst16 && ir[15:0]==16'h8000)
			state <= FETCH_IMM32;
		else begin
			case(opcode)
			`ANDI:	imm <= {16'hFFFF,ir[15:0]};
			`ORI:	imm <= {16'h0000,ir[15:0]};
			`EORI:	imm <= {16'h0000,ir[15:0]};
			default:	imm <= {{16{ir[15]}},ir[15:0]};
			endcase
			state <= EXECUTE;
		end
		case(opcode)
		`MISC:
			case(func)
			`TRACE_ON:
					if (!sf) begin
						vector <= `PRIVILEGE_VIOLATION;
						state <= TRAP;
					end
					else begin
						tf <= 1'b1;
						state <= IFETCH;
					end
			`TRACE_OFF:
					if (!sf) begin
						vector <= `PRIVILEGE_VIOLATION;
						state <= TRAP;
					end
					else begin
						tf <= 1'b0;
						state <= IFETCH;
					end
			`SET_IM:
					if (!sf) begin
						vector <= `PRIVILEGE_VIOLATION;
						state <= TRAP;
					end
					else begin
						im <= ir[2:0];
						state <= IFETCH;
					end
			`USER_MODE: begin sf <= 1'b0; state <= IFETCH; end
			`JMP32:	state <= JMP32;
			`JSR32:	state <= JSR32;
			`RTS: state <= RTS;
			`RTI:
				if (!sf) begin
					vector <= `PRIVILEGE_VIOLATION;
					state <= TRAP;
				end
				else
					state <= RTI1;
			`RST:
				if (!sf) begin
					vector <= `PRIVILEGE_VIOLATION;
					state <= TRAP;
				end
				else begin
					rstsh <= 16'hFFFF;
					state <= IFETCH;
				end
			`STOP:
				if (!sf) begin
					vector <= `PRIVILEGE_VIOLATION;
					state <= TRAP;
				end
				else begin
					im <= ir[8:6];
					tf <= ir[9];
					sf <= ir[10];
					clk_en <= 1'b0;
					state <= IFETCH;
				end
			default:
				begin
				vector <= `ILLEGAL_INSN;
				state <= TRAP;
				end
			endcase

		`R:
			begin
				Rcbit <= ir[6];
				case(func)
				`UNLK:	state <= UNLK;
				`ABS,`SGN,`NEG,`NOT,
				`EXTB,`EXTH,
				`MFSPR,`MTSPR,
				`MOV_CRn2CRn,
				`EXEC:
					;
				default:
					begin
					vector <= `ILLEGAL_INSN;
					state <= TRAP;
					end
				endcase
			end

		`NOP: state <= IFETCH;
		`JSR: begin tgt <= {pc[31:26],ir[25:2],2'b00}; state <= JSR1; end
		`JMP: begin pc[25:2] <= ir[25:2]; state <= IFETCH; end
		`Bcc:
			case(cond)
			`BRA:	begin pc <= pc + brdisp; state <= IFETCH; end
			`BRN:	begin state <= IFETCH; end
			`BEQ:	begin if ( cr_zf) pc <= pc + brdisp; state <= IFETCH; end
			`BNE:	begin if (!cr_zf) pc <= pc + brdisp; state <= IFETCH; end
			`BMI:	begin if ( cr_nf) pc <= pc + brdisp; state <= IFETCH; end
			`BPL:	begin if (!cr_zf) pc <= pc + brdisp; state <= IFETCH; end
			`BHI:	begin if (!cr_cf & !cr_zf) pc <= pc + brdisp; state <= IFETCH; end
			`BLS:	begin if (cf |zf) pc <= pc + brdisp; state <= IFETCH; end
			`BHS:	begin if (!cr_cf) pc <= pc + brdisp; state <= IFETCH; end
			`BLO:	begin if ( cr_cf) pc <= pc + brdisp; state <= IFETCH; end
			`BGT:	begin if ((cr_nf & cr_vf & !cr_zf)|(!cr_nf & !cr_vf & !cr_zf)) pc <= pc + brdisp; state <= IFETCH; end
			`BLE:	begin if (cr_zf | (cr_nf & !cr_vf) | (!cr_nf & cr_vf)) pc <= pc + brdisp; state <= IFETCH; end
			`BGE:	begin if ((cr_nf & cr_vf)|(!cr_nf & !cr_vf)) pc <= pc + brdisp; state <= IFETCH; end
			`BLT:	begin if ((cr_nf & !cr_vf)|(!cr_nf & cr_vf)) pc <= pc + brdisp; state <= IFETCH; end
			`BVS:	begin if ( cr_vf) pc <= pc + brdisp; state <= IFETCH; end
			`BVC:	begin if (!cr_vf) pc <= pc + brdisp; state <= IFETCH; end
			endcase
		`TRAPcc:
			case(cond)
			`TRAP:	begin vector <= `TRAP_VECTOR + {ir[3:0],2'b00}; state <= TRAP; end
			`TEQ:	begin if ( cr_zf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TNE:	begin if (!cr_zf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TMI:	begin if ( cr_nf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TPL:	begin if (!cr_zf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`THI:	begin if (!cr_cf & !cr_zf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TLS:	begin if (cf |zf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`THS:	begin if (!cr_cf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TLO:	begin if ( cr_cf) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TGT:	begin if ((cr_nf & cr_vf & !cr_zf)|(!cr_nf & !cr_vf & !cr_zf)) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TLE:	begin if (cr_zf | (cr_nf & !cr_vf) | (!cr_nf & cr_vf)) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TGE:	begin if ((cr_nf & cr_vf)|(!cr_nf & !cr_vf)) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TLT:	begin if ((cr_nf & !cr_vf)|(!cr_nf & cr_vf)) begin vector <= `TRAP_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TVS:	begin if ( cr_vf) begin vector <= `TRAPV_VECTOR; state <= TRAP; end else state <= IFETCH; end
			`TVC:	begin if (!cr_vf) begin vector <= `TRAPV_VECTOR; state <= TRAP; end else state <= IFETCH; end
			endcase
		`SETcc:	Rn <= ir[15:11];
		`PUSH:	state <= PUSH1;
		`POP:	state <= POP1;

		`RR:
			begin
				state <= REGFETCHB;
				Rcbit <= ir[6];
				case(func)
				`JSR_RR,`JMP_RR,
				`ADD,`SUB,`CMP,
				`BCDADD,`BCDSUB,
				`AND,`OR,`EOR,`NAND,`NOR,`ENOR,
				`SHL,`SHR,`ROL,`ROR,
				`MULU,`MULS,`MULUH,`MULSH,`DIVU,`DIVS,`MODU,`MODS,
				`LWX,`LHX,`LBX,`LHUX,`LBUX,`SWX,`SHX,`SBX,
				`MIN,`MAX:
					;
				default:
					begin
					vector <= `ILLEGAL_INSN;
					state <= TRAP;
					end
				endcase
			end
			
		`RRR:
			state <= REGFETCHB;

		`CRxx:
			case(func1)
			`CROR:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd1:	cr1[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd2:	cr2[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd3:	cr3[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd4:	cr4[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd5:	cr5[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd6:	cr6[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					3'd7:	cr7[ir[12:11]] <= GetCrBit(ir[25:21])| GetCrBit(ir[20:16]);
					endcase
				end
			`CRORC:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd1:	cr1[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd2:	cr2[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd3:	cr3[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd4:	cr4[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd5:	cr5[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd6:	cr6[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					3'd7:	cr7[ir[12:11]] <= GetCrBit(ir[25:21])| ~GetCrBit(ir[20:16]);
					endcase
				end
			`CRAND:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd1:	cr1[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd2:	cr2[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd3:	cr3[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd4:	cr4[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd5:	cr5[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd6:	cr6[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					3'd7:	cr7[ir[12:11]] <= GetCrBit(ir[25:21])& GetCrBit(ir[20:16]);
					endcase
				end
			`CRANDC:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd1:	cr1[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd2:	cr2[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd3:	cr3[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd4:	cr4[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd5:	cr5[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd6:	cr6[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					3'd7:	cr7[ir[12:11]] <= GetCrBit(ir[25:21])& ~GetCrBit(ir[20:16]);
					endcase
				end
			`CRXOR:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd1:	cr1[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd2:	cr2[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd3:	cr3[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd4:	cr4[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd5:	cr5[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd6:	cr6[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					3'd7:	cr7[ir[12:11]] <= GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]);
					endcase
				end
			`CRNOR:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd1:	cr1[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd2:	cr2[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd3:	cr3[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd4:	cr4[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd5:	cr5[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd6:	cr6[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					3'd7:	cr7[ir[12:11]] <= ~(GetCrBit(ir[25:21])| GetCrBit(ir[20:16]));
					endcase
				end
			`CRNAND:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd1:	cr1[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd2:	cr2[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd3:	cr3[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd4:	cr4[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd5:	cr5[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd6:	cr6[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					3'd7:	cr7[ir[12:11]] <= ~(GetCrBit(ir[25:21])& GetCrBit(ir[20:16]));
					endcase
				end
			`CRXNOR:
				begin
					state <= IFETCH;
					case(ir[15:13])
					3'd0:	cr0[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd1:	cr1[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd2:	cr2[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd3:	cr3[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd4:	cr4[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd5:	cr5[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd6:	cr6[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					3'd7:	cr7[ir[12:11]] <= ~(GetCrBit(ir[25:21])^ GetCrBit(ir[20:16]));
					endcase
				end
			default:
				begin
				vector <= `ILLEGAL_INSN;
				state <= TRAP;
				end
			endcase
		`ADDI,`SUBI,`CMPI,
		`ANDI,`ORI,`EORI,
		`MULUI,`MULSI,`DIVUI,`DIVSI,
		`PEA,`LINK,`TAS,
		`LB,`LH,`LW,`LBU,`LHU:
			;	/* do nothing at this point */
		`SB,`SH,`SW:
			state <= REGFETCHB;
		default:
			begin
			vector <= `ILLEGAL_INSN;
			state <= TRAP;
			end
		endcase
	end

