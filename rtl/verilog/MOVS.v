//=============================================================================
//  MOVSB,MOVSW
//  - moves a byte at a time to account for both bytes and words
//
//
//  2009-2012 Robert Finch
//  Stratford
//  robfinch<remove>@opencores.org
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
MOVS:
`include "check_for_ints.v"
	else if (w && (si==16'hFFFF)) begin
		ir <= `NOP;
		int_num <= 8'd13;
		state <= INT1;
	end
	else if ((repz|repnz) & cxz)
		state <= IFETCH;
	else begin
		if (!cyc_o) begin
			cyc_type <= `CT_RDMEM;
			lock_o <= w;
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			we_o  <= 1'b0;
			adr_o <= dssi;
		end
		else if (ack_i) begin
			cyc_type <= `CT_PASSIVE;
			state <= w ? MOVS1 : MOVS3;
			cyc_o <= 1'b0;
			stb_o <= 1'b0;
			a[7:0] <= dat_i;
			si <= df ? si_dec : si_inc;
		end
	end
MOVS1:
	if (!cyc_o) begin
		cyc_type <= `CT_WRMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= esdi;
		dat_o <= a[7:0];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		di <= df ? di_dec : di_inc;
		state <= MOVS2;
	end
MOVS2:
	begin
		cyc_type <= `CT_RDMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= dssi;
		state <= MOVS3;
	end
MOVS3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		a[7:0] <= dat_i;
		si <= df ? si_dec : si_inc;
		state <= MOVS4;
	end
MOVS4:
	begin
		cyc_type <= `CT_WRMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= esdi;
		dat_o <= a[7:0];
		state <= MOVS5;
	end
MOVS5:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		di <= df ? di_dec : di_inc;
		if (repz|repnz) begin
			cx <= cx_dec;
			state <= MOVS;
		end
		else
			state <= IFETCH;
	end
