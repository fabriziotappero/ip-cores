// ============================================================================
//  DECODER2.v
//  - Extended opcode decoder
//
//
//  2009-2012  Robert Finch
//  robfinch[remove]@opencores.org
//  Stratford
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
// ============================================================================
//
//
DECODER2:
	begin
		state <= IFETCH;
		case(ir)
		`MORE1:
			casex(ir2)
			`AAM:
				begin
					wrregs <= 1'b1;
					w <= 1'b1;
					rrr <= 3'd0;
					res <= alu_o;
					sf <= 1'b0;
					zf <= reszb;
					pf <= pres;
				end
			default:	;
			endcase
		`MORE2:
			casex(ir2)
			`AAD:
				begin
					wrregs <= 1'b1;
					w <= 1'b1;
					rrr <= 3'd0;
					res <= alu_o;
					sf <= 1'b0;
					zf <= reszw;
					pf <= pres;
				end
			default:	;
			endcase
		`EXTOP:
			casex(ir2)
			`LxDT:
				begin
					w <= 1'b1;
					`INITIATE_CODE_READ
					state <= EACALC;		// override state transition
				end
			default:	;
			endcase
		default:	;
		endcase
	end

