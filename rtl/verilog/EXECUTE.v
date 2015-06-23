// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// EXECUTE.v
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
EXECUTE:
	begin
		state <= WRITEBACK;
		case(opcode)
		`R:
			begin
				case(func)
				`ABS:	res <= a[31] ? -a : a;
				`SGN:	res <= a[31] ? 32'hFFFFFFFF : |a;
				`NEG:	res <= -a;
				`NOT:	res <= ~a;
				`EXTB:	res <= {{24{a[7]}},a[7:0]};
				`EXTH:	res <= {{16{a[15]}},a[15:0]};
				`MFSPR:
					casex(ir[25:21])
					5'b00xxx:	res <= GetCr(ir[23:21]);
					5'b01000:	res <= cr;
					5'b01001:	res <= usp;
					5'b01010:	
							if (!sf) begin
								vector <= `PRIVILEGE_VIOLATION;
								state <= TRAP;
							end
							else begin
								res <= im;
							end
					5'b01011:	res <= be_addr;
					5'b01111:	res <= tick;
					endcase
				`MTSPR:
					casex(ir[20:16])
					5'b00xxx:	// MTSPR CRn,Rn
						begin
							state <= IFETCH;
							case(ir[18:16])
							3'd0:	cr0 <= a[3:0];
							3'd1:	cr1 <= a[3:0];
							3'd2:	cr2 <= a[3:0];
							3'd3:	cr3 <= a[3:0];
							3'd4:	cr4 <= a[3:0];
							3'd5:	cr5 <= a[3:0];
							3'd6:	cr6 <= a[3:0];
							3'd7:	cr7 <= a[3:0];
							endcase
						end
					5'b01000:	// MTSPR CR,Rn
						begin
							state <= IFETCH;
							cr0 <= a[3:0];
							cr1 <= a[7:4];
							cr2 <= a[11:8];
							cr3 <= a[15:12];
							cr4 <= a[19:16];
							cr5 <= a[23:20];
							cr6 <= a[27:24];
							cr7 <= a[31:28];
						end
					5'b01001:	usp <= a;	// MTSPR USP,Rn
					5'b01010:
							if (!sf) begin
								vector <= `PRIVILEGE_VIOLATION;
								state <= TRAP;
							end
							else begin
								im <= a[2:0];
								state <= IFETCH;
							end
					endcase
				`EXEC:
					begin
					ir <= a;
					Rn <= a[25:21];
					state <= REGFETCHA;
					end
				`MOV_CRn2CRn:
					begin
					state <= IFETCH;
					case(ir[18:16])
					3'd0:	cr0 <= GetCr(ir[23:21]);
					3'd1:	cr1 <= GetCr(ir[23:21]);
					3'd2:	cr2 <= GetCr(ir[23:21]);
					3'd3:	cr3 <= GetCr(ir[23:21]);
					3'd4:	cr4 <= GetCr(ir[23:21]);
					3'd5:	cr5 <= GetCr(ir[23:21]);
					3'd6:	cr6 <= GetCr(ir[23:21]);
					3'd7:	cr7 <= GetCr(ir[23:21]);
					endcase
					end
				default:	res <= 32'd0;
				endcase
			end
		`RR:
			begin
				case(func)
				`ADD:	res <= a + b;
				`SUB:	res <= a - b;
				`CMP:	res <= a - b;
				`AND:	res <= a & b;
				`ANDC:	res <= a & ~b;
				`OR:	res <= a | b;
				`ORC:	res <= a | ~b;
				`EOR:	res <= a ^ b;
				`NAND:	res <= ~(a & b);
				`NOR:	res <= ~(a | b);
				`ENOR:	res <= ~(a ^ b);
				`SHL:	res <= shlo[31: 0];
				`SHR:	res <= shro[63:32];
				`ROL:	res <= shlo[31:0]|shlo[63:32];
				`ROR:	res <= shro[31:0]|shro[63:32];
				`MIN:	res <= as < bs ? as : bs;
				`MAX:	res <= as < bs ? bs : as;
				`BCDADD:	res <= bcdaddo;
				`BCDSUB:	res <= bcdsubo;
				default:	res <= 32'd0;
				endcase
				if (func==`JMP_RR) begin
					pc <= a + b;
					pc[1:0] <= 2'b00;
					state <= IFETCH;
				end
				else if (func==`JSR_RR) begin
					tgt <= a + b;
					tgt[1:0] <= 2'b00;
					state <= JSR1;
				end
				case(func)
				`LWX:	begin ea <= a + b; mopcode <= `LW; state <= MEMORY1; end
				`LHX:	begin ea <= a + b; mopcode <= `LH; state <= MEMORY1; end
				`LHUX:	begin ea <= a + b; mopcode <= `LHU; state <= MEMORY1; end
				`LBX:	begin ea <= a + b; mopcode <= `LB; state <= MEMORY1; end
				`LBUX:	begin ea <= a + b; mopcode <= `LBU; state <= MEMORY1; end
				`SBX:	begin ea <= a + b; mopcode <= `SB; b <= c; state <= MEMORY1; end
				`SHX:	begin ea <= a + b; mopcode <= `SH; b <= c; state <= MEMORY1; end
				`SWX:	begin ea <= a + b; mopcode <= `SW; b <= c; state <= MEMORY1; end

				`MULU:	state <= MULTDIV1;
				`MULS:	state <= MULTDIV1;
				`MULUH:	state <= MULTDIV1;
				`MULSH:	state <= MULTDIV1;
				`DIVU:	state <= MULTDIV1;
				`DIVS:  state <= MULTDIV1;
				`MODU:	state <= MULTDIV1;
				`MODS:	state <= MULTDIV1;
				endcase
			end
		`SETcc:
			begin
				case(cond)
				`SET:	res <= 32'd1;
				`SEQ:	res <=  cr_zf;
				`SNE:	res <= !cr_zf;
				`SMI:	res <= ( cr_nf);
				`SPL:	res <= (!cr_zf);
				`SHI:	res <= (!cr_cf & !cr_zf);
				`SLS:	res <= (cf |zf);
				`SHS:	res <= (!cr_cf);
				`SLO:	res <= ( cr_cf);
				`SGT:	res <= ((cr_nf & cr_vf & !cr_zf)|(!cr_nf & !cr_vf & !cr_zf));
				`SLE:	res <= (cr_zf | (cr_nf & !cr_vf) | (!cr_nf & cr_vf));
				`SGE:	res <= ((cr_nf & cr_vf)|(!cr_nf & !cr_vf));
				`SLT:	res <= ((cr_nf & !cr_vf)|(!cr_nf & cr_vf));
				`SVS:	res <= ( cr_vf);
				`SVC:	res <= (!cr_vf);
				endcase
			end
		`ADDI:	res <= a + imm;
		`SUBI:	res <= a - imm;
		`CMPI:	res <= a - imm;
		`ANDI:	res <= a & imm;
		`ORI:	res <= a | imm;
		`EORI:	res <= a ^ imm;
/*
			case(ir[20:16])
			`ORI_CCR:
				begin
					state <= IFETCH;
					cr0 <= cr0 | imm[3:0];
					cr1 <= cr1 | imm[7:4];
					cr2 <= cr2 | imm[11:8];
					cr3 <= cr3 | imm[15:12];
					cr4 <= cr4 | imm[19:16];
					cr5 <= cr5 | imm[23:20];
					cr6 <= cr6 | imm[27:24];
					cr7 <= cr7 | imm[31:28];
				end
			`ANDI_CCR:
				begin
					state <= IFETCH;
					cr0 <= cr0 & imm[3:0];
					cr1 <= cr1 & imm[7:4];
					cr2 <= cr2 & imm[11:8];
					cr3 <= cr3 & imm[15:12];
					cr4 <= cr4 & imm[19:16];
					cr5 <= cr5 & imm[23:20];
					cr6 <= cr6 & imm[27:24];
					cr7 <= cr7 & imm[31:28];
				end
			`EORI_CCR:
				begin
					state <= IFETCH;
					cr0 <= cr0 ^ imm[3:0];
					cr1 <= cr1 ^ imm[7:4];
					cr2 <= cr2 ^ imm[11:8];
					cr3 <= cr3 ^ imm[15:12];
					cr4 <= cr4 ^ imm[19:16];
					cr5 <= cr5 ^ imm[23:20];
					cr6 <= cr6 ^ imm[27:24];
					cr7 <= cr7 ^ imm[31:28];
				end
			endcase
*/
		`LINK:	state <= LINK;
		`MULUI:	state <= MULTDIV1;
		`MULSI:	state <= MULTDIV1;
		`DIVUI:	state <= MULTDIV1;
		`DIVSI:	state <= MULTDIV1;
		default:	res <= 32'd0;
		endcase
		case(opcode)
		`TAS:	begin ea <= a + imm; mopcode <= opcode; state <= TAS; end
		`LW:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`LH:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`LB:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`LHU:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`LBU:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`SW:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`SH:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`SB:	begin ea <= a + imm; mopcode <= opcode; state <= MEMORY1; end
		`PEA:	begin ea <= a + imm; mopcode <= opcode; state <= PEA; end
		default:	ea <= 32'd0;
		endcase
	end
