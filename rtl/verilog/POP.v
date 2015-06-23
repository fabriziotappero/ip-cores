// ============================================================================
//  POP register from stack
//
//
//  (C) 2009,2010  Robert Finch
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
POP:
	begin
		cyc_type <= `CT_RDMEM;
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		adr_o <= sssp;
		w <= 1'b1;
		rrr <= ir[2:0];
		state <= POP1;
	end
POP1:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		sp <= sp_inc;
		res[7:0] <= dat_i;
		case(ir)
		`POP_SS: begin rrr <= 3'd2; end
		`POP_ES: begin rrr <= 3'd0; end
		`POP_DS: begin rrr <= 3'd3; end
		`POPF:
			begin
				cf <= dat_i[0];
				pf <= dat_i[2];
				af <= dat_i[4];
				zf <= dat_i[6];
				sf <= dat_i[7];
			end
		default: ;
		endcase
		state <= POP2;
	end
POP2:
	begin
		`CONTINUE_STACK_POP
		state <= POP3;
	end
POP3:
	if (ack_i) begin
		state <= IFETCH;
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sp <= sp_inc;
		res[15:8] <= dat_i;
		case(ir)
		`POP_AX,`POP_CX,`POP_BX,`POP_DX,
		`POP_SI,`POP_DI,`POP_BP,`POP_SP:
			wrregs <= 1'b1;
		`POP_SS,`POP_ES,`POP_DS:
			wrsregs <= 1'b1;
		`POPF:
			begin
				tf <= dat_i[0];
				ie <= dat_i[1];
				df <= dat_i[2];
				vf <= dat_i[3];
			end
		`POP_MEM:
			state <= STORE_DATA;
		default: ;
		endcase
	end
