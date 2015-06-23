// ============================================================================
//  FETCH_OFFSET_AND_SEGMENT.v
//  - Fetch 16 bit offset
//  - Fetch 16 bit segment
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
//
//  Verilog 
//
// ============================================================================
//
//
FETCH_OFFSET:
	begin
		lock_o <= 1'b1;
		`INITIATE_CODE_READ
		state <= FETCH_OFFSET1;
	end
FETCH_OFFSET1:
	if (ack_i) begin
		`PAUSE_CODE_READ
		offset[7:0] <= dat_i;
		state <= FETCH_OFFSET2;
	end
FETCH_OFFSET2:
	begin
		`CONTINUE_CODE_READ
		state <= FETCH_OFFSET3;
	end
FETCH_OFFSET3:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		offset[15:8] <= dat_i;
		state <= FETCH_SEGMENT;
	end
FETCH_SEGMENT:
	begin
		`INITIATE_CODE_READ
		state <= FETCH_SEGMENT1;
	end
FETCH_SEGMENT1:
	if (ack_i) begin
		`PAUSE_CODE_READ
		state <= FETCH_SEGMENT2;
		selector[7:0] <= dat_i;
	end
FETCH_SEGMENT2:
	begin
		`CONTINUE_CODE_READ
		state <= FETCH_SEGMENT3;
	end
FETCH_SEGMENT3:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		selector[15:8] <= dat_i;
		if (ir==`CALLF)
			state <= CALLF;
		else
			state <= JMPF;
	end
JMPF:
	begin
		cs <= selector;
		ip <= offset;
		state <= IFETCH;
	end

