// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// IFETCH.v - fetch instructions
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
// Check for halted state and interrupts, then fetch instruction if no
// halt or interrupt.
// ============================================================================
//
IFETCH:
	if (!cyc_o) begin
		if (halt_i) begin
			// empty - do nothing until non-halted
		end
		else if (nmi_edge) begin
			sr1 <= sr;
			im <= ipl_i;
			tf <= 1'b0;
			sf <= 1'b1;
			iplr <= ipl_i;
			state <= INTA;
			nmi_edge <= 1'b0;
		end
		else if (ipl_i > im) begin
			sr1 <= sr;
			im <= ipl_i;
			tf <= 1'b0;
			sf <= 1'b1;
			iplr <= ipl_i;
			state <= INTA;
		end
		else if (tf) begin
			sr1 <= sr;
			tf <= 1'b0;
			sf <= 1'b1;
			vector <= `TRACE_VECTOR;
			state <= TRAP;
		end
		else begin
			fc_o <= {sf,2'b10};
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			sel_o <= 4'b1111;
			adr_o <= pc;
		end
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		pc <= pc + 32'd4;
		ir <= dat_i;
		Rn <= dat_i[25:21];
		state <= REGFETCHA;
	end
