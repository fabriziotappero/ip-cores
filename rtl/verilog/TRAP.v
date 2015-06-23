// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// TRAP.v
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
TRAP1:
	if (!cyc_o) begin
		fc_o <= {3'b101};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp - 32'd4;
		dat_o <= pc;
	end
	else if (ack_i) begin
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'b0000;
		sr1 <= sr;
		sf <= 1'b1;
		tf <= 1'b0;
		ssp <= ssp - 32'd4;
		state <= TRAP2;
	end
TRAP2:
	if (!stb_o) begin
		fc_o <= {3'b101};
		stb_o <= 1'b1;
		we_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp - 32'd4;
		dat_o <= cr;
	end
	else if (ack_i) begin
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'b0000;
		ssp <= ssp - 32'd4;
		state <= TRAP3;
	end
TRAP3:
	if (!stb_o) begin
		fc_o <= {3'b101};
		stb_o <= 1'b1;
		we_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp - 32'd4;
		dat_o <= sr1;
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'b0000;
		ssp <= ssp - 32'd4;
		state <= VECTOR;
	end

