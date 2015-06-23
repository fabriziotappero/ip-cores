//=============================================================================
//  LODS
//  Fetch string data from memory.
//
//
//  2009,2010,2013 Robert Finch
//  Stratford
//  robfinch<remove>@finitron.ca
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
//=============================================================================
//
LODS:
	if (w && (si==16'hFFFF) && !df) begin
		ir <= `NOP;
		int_num <= 8'd13;
		state <= INT2;
	end
	else begin
		cyc_type <= `CT_RDMEM;
		lock_o <= w;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= {seg_reg,`SEG_SHIFT} + si;
		state <= LODS_NACK;
	end
LODS_NACK:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= w;
		cyc_o <= w;
		stb_o <= 1'b0;
		if (df) begin
			si <= si_dec;
			if (w)
				b[15:8] <= dat_i;
			else begin
				b[ 7:0] <= dat_i;
				b[15:8] <= {8{dat_i[7]}};
			end
		end
		else begin
			si <= si_inc;
			b[ 7:0] <= dat_i;
			b[15:8] <= {8{dat_i[7]}};
		end
		state <= w ? LODS1 : EXECUTE;
	end

LODS1:
	begin
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= {seg_reg,`SEG_SHIFT} + si;
		state <= LODS1_NACK;
	end
LODS1_NACK:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		if (df) begin
			si <= si_dec;
			b[7:0] <= dat_i;
		end
		else begin
			si <= si_inc;
			b[15:8] <= dat_i;
		end
		state <= EXECUTE;
	end

