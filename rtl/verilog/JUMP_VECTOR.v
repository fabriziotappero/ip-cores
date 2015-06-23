// ============================================================================
//  JUMP_VECTOR
//  - fetch 32 bit vector into selector:offset and jump to it
//
//
//  2009,2010,2012  Robert Finch
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
//  Verilog 
//
// ============================================================================
//
JUMP_VECTOR1:
	begin
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= ea;		// ea set by EACALC
		state <= JUMP_VECTOR2;
	end
JUMP_VECTOR2:
	if (ack_i) begin
		ea    <= ea_inc;
		offset[7:0] <= dat_i;
		stb_o <= 1'b0;
		state <= JUMP_VECTOR3;
	end
JUMP_VECTOR3:
	begin
		stb_o <= 1'b1;
		adr_o <= ea;
		state <= JUMP_VECTOR4;
	end
JUMP_VECTOR4:
	if (ack_i) begin
		ea    <= ea_inc;
		stb_o <= 1'b0;
		offset[15:8] <= dat_i;
		state <= JUMP_VECTOR5;
	end
JUMP_VECTOR5:
	begin
		stb_o <= 1'b1;
		adr_o <= ea;
		state <= JUMP_VECTOR6;
	end
JUMP_VECTOR6:
	if (ack_i) begin
		ea    <= ea_inc;
		selector[7:0] <= dat_i;
		stb_o <= 1'b0;
		state <= JUMP_VECTOR7;
	end
JUMP_VECTOR7:
	begin
		stb_o <= 1'b1;
		adr_o <= ea;
		state <= JUMP_VECTOR8;
	end
JUMP_VECTOR8:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		selector[15:8] <= dat_i;
		state <= JUMP_VECTOR9;
	end
JUMP_VECTOR9:
	begin
		ip <= offset;
		cs <= selector;
		state <= IFETCH;
	end
