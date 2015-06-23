// ============================================================================
//  RETFPOP: far return from subroutine and pop stack items
//  Fetch ip from stack
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
//  Verilog 
//
// ============================================================================
//
RETFPOP:
	begin
		lock_o <= 1'b1;
		`INITIATE_STACK_POP
		state <= RETFPOP1;
	end
RETFPOP1:
	if (ack_i) begin
		`PAUSE_STACK_POP
		ip[7:0] <= dat_i;
		state <= RETFPOP2;
	end
RETFPOP2:
	begin
		`CONTINUE_STACK_POP
		state <= RETFPOP3;
	end
RETFPOP3:
	if (ack_i) begin
		`PAUSE_STACK_POP
		ip[15:8] <= dat_i;
		state <= RETFPOP4;
	end
RETFPOP4:
	begin
		`CONTINUE_STACK_POP
		state <= RETFPOP5;
	end
RETFPOP5:
	if (ack_i) begin
		`PAUSE_STACK_POP
		cs[7:0] <= dat_i;
		state <= RETFPOP6;
	end
RETFPOP6:
	begin
		`CONTINUE_STACK_POP
		state <= RETFPOP7;
	end
RETFPOP7:
	if (ack_i) begin
		lock_o <= 1'b0;
		`COMPLETE_STACK_POP
		cs[15:8] <= dat_i;
		state <= RETFPOP8;
	end
RETFPOP8:
	begin
		wrregs <= 1'b1;
		w <= 1'b1;
		rrr <= 3'd4;
		res <= sp + data16;
		state <= IFETCH;
	end

