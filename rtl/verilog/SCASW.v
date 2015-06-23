// ============================================================================
//  SCASW
//
//
//  2009-2012  Robert Finch
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
//  Verilog 
//
// ============================================================================
//
SCASW:
`include "check_for_ints.v"
	else if (w && (di==16'hFFFF) && !df) begin
		ir <= `NOP;
		int_num <= 8'd13;
		state <= INT1;
	end
	else if ((repz|repnz) & cxz)
		state <= IFETCH;
	else begin
		if (!cyc_o) begin
			cyc_type <= `CT_RDMEM;
			lock_o <= 1'b1;
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			we_o  <= 1'b0;
			adr_o <= esdi;
		end
		else if (ack_i) begin
			cyc_type <= `CT_PASSIVE;
			state <= SCASW1;
			stb_o <= 1'b0;
			a <= ax;
			if (df) begin
				b[15:8] <= dat_i;
				di <= di_dec;
			end
			else begin
				b[7:0] <= dat_i;
				di <= di_inc;
			end
		end
	end
SCASW1:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= esdi;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		state <= SCASW2;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		a <= ax;
		if (df) begin
			b <= dat_i;
			di <= di_dec;
		end
		else begin
			b[15:8] <= dat_i;
			di <= di_inc;
		end
	end
SCASW2:
	begin
		pf <= pres;
		af <= carry   (1'b0,a[3],b[3],alu_o[3]);
		cf <= carry   (1'b0,a[15],b[15],alu_o[15]);
		vf <= overflow(1'b0,a[15],b[15],alu_o[15]);
		sf <= resnw;
		zf <= reszw;
		if (repz|repnz)
			cx <= cx_dec;
		if ((repz & reszw) | (repnz & !reszw))
			state <= SCASW;
		else
			state <= IFETCH;
	end
