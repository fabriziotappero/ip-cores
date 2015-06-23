// ============================================================================
//  INW.v
//  - Fetch data from IO.
//
//
//  2009,2010,2012  Robert Finch
//  robfinch@opencores.org
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
//
//  Verilog 
//
// ============================================================================
//
INW:
	begin
		`INITIATE_CODE_READ
		state <= INW1;
	end
INW1:
	if (ack_i) begin
		`TERMINATE_CODE_READ
		ea <= {12'h000,dat_i};
		state <= INW2;
	end
INW2:
	begin
		cyc_type <= `CT_RDIO;
		mio_o <= 1'b0;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= ea;
		state <= INW3;
	end
INW3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		mio_o <= 1'b1;
		stb_o <= 1'b0;
		res[7:0] <= dat_i;
		state <= INW4;
	end
INW4:
	begin
		cyc_type <= `CT_RDIO;
		mio_o <= 1'b0;
		stb_o <= 1'b1;
		adr_o <= ea_inc;
		state <= INW5;
	end
INW5:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		mio_o <= 1'b1;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		wrregs <= 1'b1;
		w <= 1'b1;
		rrr <= 3'd0;
		res[15:8] <= dat_i;
		state <= IFETCH;
	end
