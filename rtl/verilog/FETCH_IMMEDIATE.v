// ============================================================================
//  FETCH_IMM16
//  - fetch 16 bit immediate from instruction stream as operand 'B'
//  FETCH_IMM8
//  - Fetch 8 bit immediate as operand 'B'
//
//
//  2009-2012  Robert Finch
//  robfinch[remove]@finitron.ca
//  Stratford
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
// - bus is locked if immediate value is unaligned in memory
// - immediate values are the last operand to be fetched, hence
//   the state machine can transition into the EXECUTE state.
// - we also know the immediate value can't be the target of an
//   operation.
// ============================================================================
//
FETCH_IMM8:
	begin
		code_read();
		state <= FETCH_IMM8_ACK;
	end

FETCH_IMM8_ACK:
	if (ack_i) begin
		term_code_read();
		lock_o <= bus_locked;
		b <= {{8{dat_i[7]}},dat_i};
		state <= EXECUTE;
	end

FETCH_IMM16:
	begin
		lock_o <= 1'b1;
		code_read();
		state <= FETCH_IMM16_ACK;
	end
FETCH_IMM16_ACK:
	if (ack_i) begin
		pause_code_read();
		state <= FETCH_IMM16a;
		b[ 7:0] <= dat_i;
	end
FETCH_IMM16a:
	begin
		continue_code_read();
		state <= FETCH_IMM16a_ACK;
	end
FETCH_IMM16a_ACK:
	if (ack_i) begin
		term_code_read();
		lock_o <= bus_locked;
		b[15:8] <= dat_i;
		$display("Fetched #%h", {dat_i,b[7:0]});
		state <= EXECUTE;
	end

