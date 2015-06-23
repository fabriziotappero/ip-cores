// ============================================================================
//  2009-2012 Robert Finch
//  robfinch[remove]@opencores.org
//  Stratford
//
//  FETCH_STK_ADJ
//  - fetch stack adjustment word
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
// - fetch 16 bit stack adjustment
//
// ============================================================================
//
FETCH_STK_ADJ1:
	begin
		`INITIATE_CODE_READ
		state <= FETCH_STK_ADJ1_ACK;
	end
FETCH_STK_ADJ1_ACK:
	if (ack_i) begin
		`PAUSE_CODE_READ
		data16[7:0] <= dat_i;
		state <= FETCH_STK_ADJ2;
	end
FETCH_STK_ADJ2:
	begin
		`CONTINUE_CODE_READ
		state <= FETCH_STK_ADJ2_ACK;
	end
FETCH_STK_ADJ2_ACK:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		if(ir==`RETPOP)
			state <= RETPOP;
		else
			state <= RETFPOP;
		data16[15:8] <= dat_i;
	end
