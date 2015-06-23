// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// WRITE_FLAGS.v - update the CR registers
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
WRITE_FLAGS:
	begin
		state <= IFETCH;
		if (opcode==`CMPI || (opcode==`RR && func==`CMP)) begin
			$display("Writing flags to Cr%d",Rn[4:2]);
			case(Rn[4:2])
			3'd0:	cr0 <= {nf,zf,vf,cf};
			3'd1:	cr1 <= {nf,zf,vf,cf};
			3'd2:	cr2 <= {nf,zf,vf,cf};
			3'd3:	cr3 <= {nf,zf,vf,cf};
			3'd4:	cr4 <= {nf,zf,vf,cf};
			3'd5:	cr5 <= {nf,zf,vf,cf};
			3'd6:	cr6 <= {nf,zf,vf,cf};
			3'd7:	cr7 <= {nf,zf,vf,cf};
			endcase
		end
		else begin
			case(opcode)
			`R:
				case(func)
				`ABS,`SGN,`NEG,`NOT,`EXTB,`EXTH:
					if (Rcbit) cr0 <= {nf,zf,vf,cf};
				default:	;
				endcase
			`RR:
				case(func)
				`MULU,`MULS,`MULUH,`MULSH,`DIVU,`DIVS,`MODU,`MODS,
				`ADD,`SUB,`AND,`ANDC,`OR,`ORC,`EOR,`NAND,`NOR,`ENOR,
				`MIN,`MAX,
				`BCDADD,`BCDSUB,
				`SHL,`SHR,`ROL,`ROR,
				`LWX,`LHX,`LBX,`LHUX,`LBUX:
					if (Rcbit) cr0 <= {nf,zf,vf,cf};
				default:	;
			endcase
			`MULUI,`MULSI,`DIVUI,`DIVSI,
			`ADDI,`SUBI,`ANDI,`ORI,`EORI,`LW,`LH,`LB,`LHU,`LBU,`TAS:
				cr0 <= {nf,zf,vf,cf};
			default:	;
			endcase
		end
	end

