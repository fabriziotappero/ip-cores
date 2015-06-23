// ============================================================================
//  2009-2012  Robert Finch
//  Stratford
//
//  RETPOP
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
//  RETPOP: near return from subroutine and pop stack items
//  Fetch ip from stack
// ============================================================================
//
RETPOP:
	begin
		state <= RETPOP_NACK;
		cyc_type <= `CT_RDMEM;
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= sssp;
	end
RETPOP_NACK:
	if (ack_i) begin
		state <= RETPOP1;
		cyc_type <= `CT_PASSIVE;
		sp    <= sp_inc;
		stb_o <= 1'b0;
		ip[7:0] <= dat_i;
	end
RETPOP1:
	begin
		state <= RETPOP1_NACK;
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= sssp;
	end
RETPOP1_NACK:
	if (ack_i) begin
		state <= IFETCH;
		cyc_type <= `CT_PASSIVE;
		wrregs <= 1'b1;
		w <= 1'b1;
		rrr <= 3'd4;
		res <= sp_inc + data16;
//		sp    <= sp_inc + data16;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		ip[15:8] <= dat_i;
	end
