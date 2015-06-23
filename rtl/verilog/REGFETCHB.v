// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// REGFETCHB.v - fetch the B side register
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
REGFETCHB:
	begin
		b <= rfo;
		Rn <= ir[15:11];
		if (opcode==`RRR || (opcode==`RR && (func==`SWX||func==`SHX||func==`SBX)))
			state <= REGFETCHC;
		else begin
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
		end
	end
