// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// MULTDIV.v
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
MULTDIV1:
	begin
		state <= IsMult ? MULT1 : DIV1;
		cnt <= 6'd0;
		case(opcode)
		`RR:	// RR
			case(func)
			`MULS,`MULSH,`DIVS,`MODS:
				begin
					aa <= a[31] ? -a : a;
					bb <= b[31] ? -b : b;
					res_sgn <= a[31] ^ b[31];
				end
			`MULU,`MULUH,`DIVU,`MODU:
				begin
					aa <= a;
					bb <= b;
					res_sgn <= 1'b0;
				end
			endcase
		`MULSI,`DIVSI:
			begin
				aa <= a[31] ? -a : a;
				bb <= imm[31] ? -imm : imm;
				res_sgn <= a[31] ^ imm[31];
			end
		`MULUI,`DIVUI:
			begin
				aa <= a;
				bb <= imm;
				res_sgn <= 1'b0;
			end
		endcase
	end

MULT1:  begin prod <= {mp3,mp0} + {mp1,16'd0}; state <= MULT2; end
MULT2:	begin prod <= prod + {mp2,16'd0}; state <= res_sgn ? MULT6 : MULTDIV2; end
MULT6:
	begin
		state <= MULTDIV2;
		prod <= -prod;
	end

// Non-restoring divide
DIV1:
	if (cnt <= 32) begin
		cnt <= cnt + 8'd1;
		aa[0] <= ~div_dif[31];		// get test result
		aa[31:1] <= aa[30:0];			// shift quotient
		div_r0[0] <= aa[31];			// shift bit into test area (remainder)
		if (~div_dif[31])
			div_r0[31:1] <= div_dif[31:0];
		else
			div_r0[31:1] <= div_r0[30:0];
	end
	else
		state <= DIV2;
DIV2:
	begin
		state <= MULTDIV2;
		if (res_sgn) begin
			div_q <= -aa;
			div_r <= -div_r0;
		end
		else begin
			div_q <= aa;
			div_r <= div_r0;
		end
	end

MULTDIV2:
	begin
		state <= WRITEBACK;
		case(opcode)
		`RR:
			case(func)
			`MULU:	begin res <= prod[31:0]; vf <= |prod[63:32]; end
			`MULS:	begin res <= prod[31:0]; vf <= prod[31] ? ~&prod[63:32] : |prod[63:32]; end
			`MULUH:	begin res <= prod[63:32]; end
			`MULSH:	begin res <= prod[63:32]; end
			`DIVS:	res <= div_q;
			`DIVU:	res <= div_q;
			`MODS:	res <= div_r;
			`MODU:	res <= div_r;
			endcase
		`MULSI:	begin res <= prod[31:0]; vf <= prod[31] ? ~&prod[63:32] : |prod[63:32]; end
		`MULUI: begin res <= prod[31:0]; vf <= |prod[63:32]; end
		`DIVUI:	res <= div_q;
		`DIVSI:	res <= div_q;
		endcase
	end
