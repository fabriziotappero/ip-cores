// ============================================================================
//  STORE_DATA
//  - store data to memory.
//
//
//  (C) 2009,2010,2012  Robert Finch
//  robfinch[remove]@opencores.org
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
STORE_DATA:
	begin
		cyc_type <= `CT_WRMEM;
		lock_o <= bus_locked | w;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= ea;
		dat_o <= res[7:0];
		state <= STORE_DATA1;
	end
STORE_DATA1:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		if (w) begin
			state <= STORE_DATA2;
		end
		else begin
			cyc_o <= 1'b0;
			lock_o <= 1'b0;
			state <= IFETCH;
		end
	end
STORE_DATA2:
	begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= ea_inc;
		dat_o <= res[15:8];
		state <= STORE_DATA3;
	end
STORE_DATA3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
 		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		state <= IFETCH;
	end
