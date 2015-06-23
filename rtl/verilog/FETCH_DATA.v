//=============================================================================
//  (C) 2009-2012 Robert Finch, Stratford
//  robfinch<remove>@opencores.org
//
//  FETCH_DATA
//  Fetch data from memory.
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
//=============================================================================
//
FETCH_DATA:
	if (!cyc_o) begin
		cyc_type <= `CT_RDMEM;
		lock_o <= bus_locked | w;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= ea;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= w;
		stb_o <= 1'b0;
		if (d) begin
			a <= rrro;
			b[ 7:0] <= dat_i;
			b[15:8] <= {8{dat_i[7]}};
		end
		else begin
			b <= rrro;
			a[ 7:0] <= dat_i;
			a[15:8] <= {8{dat_i[7]}};
		end
		if (w)
			state <= FETCH_DATA1;
		else begin
			case(ir)
			8'h80:	state <= FETCH_IMM8;
			8'h81:	state <= FETCH_IMM16;
			8'h83:	state <= FETCH_IMM8;
			8'hC0:	state <= FETCH_IMM8;
			8'hC1:	state <= FETCH_IMM8;
			8'hC6:	state <= FETCH_IMM8;
			8'hC7:	state <= FETCH_IMM16;
			8'hF6:	state <= FETCH_IMM8;
			8'hF7:	state <= FETCH_IMM16;
			default: state <= EXECUTE;
			endcase
			hasFetchedData <= 1'b1;
		end
	end
FETCH_DATA1:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		lock_o <= bus_locked | w;
		stb_o <= 1'b1;
		adr_o <= ea_inc;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= bus_locked;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		if (d)
			b[15:8] <= dat_i;
		else
			a[15:8] <= dat_i;
		case(ir)
		8'h80:	state <= FETCH_IMM8;
		8'h81:	state <= FETCH_IMM16;
		8'h83:	state <= FETCH_IMM8;
		8'hC0:	state <= FETCH_IMM8;
		8'hC1:	state <= FETCH_IMM8;
		8'hC6:	state <= FETCH_IMM8;
		8'hC7:	state <= FETCH_IMM16;
		8'hF6:	state <= FETCH_IMM8;
		8'hF7:	state <= FETCH_IMM16;
		default: state <= EXECUTE;
		endcase
		hasFetchedData <= 1'b1;
	end
