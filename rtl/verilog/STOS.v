//=============================================================================
//  STOSB,STOSW
//  Store string data to memory.
//
//
//  2009-2013 Robert Finch
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
STOS:
	if (pe_nmi) begin
		rst_nmi <= 1'b1;
		int_num <= 8'h02;
		ir <= `NOP;
		state <= INT2;
	end
	else if (irq_i & ie) begin
		ir <= `NOP;
		state <= INTA0;
	end
	else if (w && (di==16'hFFFF)) begin
		ir <= `NOP;
		int_num <= 8'd13;
		state <= INT2;
	end
	else if (repdone)
		state <= IFETCH;
	else begin
		if (!cyc_o) begin
			cyc_type <= `CT_WRMEM;
			lock_o <= w;
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			we_o  <= 1'b1;
			adr_o <= esdi;
			dat_o <= (w & df) ? ah : al;
		end
		else if (ack_i) begin
			cyc_type <= `CT_PASSIVE;
			if (repz|repnz) begin
				state <= w ? STOS1 : STOS;
				cx <= cx_dec;
			end
			else
				state <= w ? STOS1 : IFETCH;
			lock_o <= w;
			cyc_o <= w;
			stb_o <= 1'b0;
			we_o  <= 1'b0;
			if (df)
				di <= di_dec;
			else
				di <= di_inc;
		end
	end
STOS1:
	begin
		cyc_type <= `CT_WRMEM;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= esdi;
		dat_o <= df ? al : ah;
		state <= STOS2;
	end
STOS2:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		if (repz|repnz)
			state <= STOS;
		else
			state <= IFETCH;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		if (df)
			di <= di_dec;
		else
			di <= di_inc;
	end
