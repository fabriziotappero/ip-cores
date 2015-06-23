// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// JSR.v - jump to subroutine
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
JSR32:
	if (!cyc_o) begin
		fc_o <= {sf,2'b10};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= pc;
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		pc <= pc + 32'd4;
		tgt <= dat_i;
		state <= JSR1;
	end
JSR1:
	if (!cyc_o) begin
		fc_o <= {sf,2'b01};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		sel_o <= 4'b1111;
		if (sf)
			adr_o <= ssp - 32'd4;
		else
			adr_o <= usp - 32'd4;
		dat_o <= pc;
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'b0000;
		if (sf)
			ssp <= ssp - 32'd4;
		else
			usp <= usp - 32'd4;
		pc <= tgt;
		state <= IFETCH;
	end
