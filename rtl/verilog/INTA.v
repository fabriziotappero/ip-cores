// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// INTA.v - interrupt acknowledge
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
// ============================================================================
//
INTA:
	if (!cyc_o) begin
		fc_o <= 3'b111;
		inta_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b0001;
		adr_o <= {27'h7FFFFFF,iplr,2'b00};
	end
	else if (vpa_i) begin
		inta_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		vecnum <= 32'd24 + iplr;
		state <= FETCH_VECTOR;
	end
	else if (ack_i) begin
		inta_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		vecnum <= dat_i[7:0];
		state <= FETCH_VECTOR;
	end
	else if (err_i) begin
		inta_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		vecnum <= 32'd24;		// Spurious interrupt
		state <= FETCH_VECTOR;
	end
FETCH_VECTOR:
	if (!cyc_o) begin
		fc_o <= 3'b101;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= {vecnum,2'b00};
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		vector <= dat_i;
		state <= TRAP1;
	end
	// I don't bother with bus error checking here because if the cpu can't read the
	// vector table, bus error processing won't help.

