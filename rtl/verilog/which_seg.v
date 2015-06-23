//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Determine segment register for memory access.
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
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
always @(modrm or prefix1 or prefix2 or cs or ds or es or ss or ir)
	case(ir)
	`SCASB: seg_reg <= es;
	`SCASW: seg_reg <= es;
	default:
		case(prefix1)
		`CS: seg_reg <= cs;
		`DS: seg_reg <= ds;
		`ES: seg_reg <= es;
		`SS: seg_reg <= ss;
		default:
			case(prefix2)
			`CS: seg_reg <= cs;
			`DS: seg_reg <= ds;
			`ES: seg_reg <= es;
			`SS: seg_reg <= ss;
			default:
				casex(ir)
				`CMPSB: seg_reg <= ds;
				`CMPSW: seg_reg <= ds;
				`LODSB:	seg_reg <= ds;
				`LODSW:	seg_reg <= ds;
				`MOVSB: seg_reg <= ds;
				`MOVSW: seg_reg <= ds;
				`STOSB: seg_reg <= ds;
				`STOSW: seg_reg <= ds;
				`MOV_AL2M: seg_reg <= ds;
				`MOV_AX2M: seg_reg <= ds;
				default:
					case(modrm)
					5'b00_000:	seg_reg <= ds;
					5'b00_001:	seg_reg <= ds;
					5'b00_010:	seg_reg <= ss;
					5'b00_011:	seg_reg <= ss;
					5'b00_100:	seg_reg <= ds;
					5'b00_101:	seg_reg <= ds;
					5'b00_110:	seg_reg <= ds;
					5'b00_111:	seg_reg <= ds;
				
					5'b01_000:	seg_reg <= ds;
					5'b01_001:	seg_reg <= ds;
					5'b01_010:	seg_reg <= ss;
					5'b01_011:	seg_reg <= ss;
					5'b01_100:	seg_reg <= ds;
					5'b01_101:	seg_reg <= ds;
					5'b01_110:	seg_reg <= ss;
					5'b01_111:	seg_reg <= ds;
				
					5'b10_000:	seg_reg <= ds;
					5'b10_001:	seg_reg <= ds;
					5'b10_010:	seg_reg <= ss;
					5'b10_011:	seg_reg <= ss;
					5'b10_100:	seg_reg <= ds;
					5'b10_101:	seg_reg <= ds;
					5'b10_110:	seg_reg <= ss;
					5'b10_111:	seg_reg <= ds;
				
					default:	seg_reg <= ds;
					endcase
				endcase
			endcase
		endcase
	endcase
	
	always @(state or modrm or prefix1 or prefix2 or ir)
		case(state)
		IFETCH,XI_FETCH,DECODE,FETCH_IMM8,FETCH_IMM16,FETCH_DISP8:
			S43 <= 2'b10;	// code segment
		PUSH,PUSH1,POP,POP1,
		IRET,IRET1,IRET2,IRET3,IRET4,IRET5,
		RETFPOP,RETFPOP1,RETFPOP2,RETFPOP3,
		RETPOP,RETPOP1:
			S43 <= 2'b01;	// stack
		default:
			case(prefix1)
			`CS: S43 <= 2'b10;
			`DS: S43 <= 2'b11;
			`ES: S43 <= 2'b00;
			`SS: S43 <= 2'b01;
			default:
				case(prefix2)
				`CS: S43 <= 2'b10;
				`DS: S43 <= 2'b11;
				`ES: S43 <= 2'b00;
				`SS: S43 <= 2'b01;
				default:
					casex(ir)
					`CMPSB: S43 <= 2'b11;
					`CMPSW: S43 <= 2'b11;
					`LODSB:	S43 <= 2'b11;
					`LODSW:	S43 <= 2'b11;
					`MOVSB: S43 <= 2'b11;
					`MOVSW: S43 <= 2'b11;
					`STOSB: S43 <= 2'b11;
					`STOSW: S43 <= 2'b11;
					`MOV_AL2M: S43 <= 2'b11;
					`MOV_AX2M: S43 <= 2'b11;
					default:
						case(modrm)
						5'b00_000:	S43 <= 2'b11;
						5'b00_001:	S43 <= 2'b11;
						5'b00_010:	S43 <= 2'b01;
						5'b00_011:	S43 <= 2'b01;
						5'b00_100:	S43 <= 2'b11;
						5'b00_101:	S43 <= 2'b11;
						5'b00_110:	S43 <= 2'b11;
						5'b00_111:	S43 <= 2'b11;
					
						5'b01_000:	S43 <= 2'b11;
						5'b01_001:	S43 <= 2'b11;
						5'b01_010:	S43 <= 2'b01;
						5'b01_011:	S43 <= 2'b01;
						5'b01_100:	S43 <= 2'b11;
						5'b01_101:	S43 <= 2'b11;
						5'b01_110:	S43 <= 2'b01;
						5'b01_111:	S43 <= 2'b11;
					
						5'b10_000:	S43 <= 2'b11;
						5'b10_001:	S43 <= 2'b11;
						5'b10_010:	S43 <= 2'b01;
						5'b10_011:	S43 <= 2'b01;
						5'b10_100:	S43 <= 2'b11;
						5'b10_101:	S43 <= 2'b11;
						5'b10_110:	S43 <= 2'b01;
						5'b10_111:	S43 <= 2'b11;
					
						default:	S43 <= 2'b11;
						endcase // modrm
					endcase // ir
				endcase // prefix2
			endcase // prefix1
		endcase // state

