// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// RTI.v - return from interrupt / trap
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
RTI1:
	if (!cyc_o) begin
		fc_o <= {3'b101};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp;
	end
	else if (ack_i) begin
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		im <= dat_i[18:16];
		sf <= dat_i[21];
		tf <= dat_i[23];
		ssp <= ssp + 32'd4;
		state <= RTI2;
	end
RTI2:
	if (!stb_o) begin
		fc_o <= {3'b101};
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp;
	end
	else if (ack_i) begin
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		cr0 <= dat_i[3:0];
		cr1 <= dat_i[7:4];
		cr2 <= dat_i[11:8];
		cr3 <= dat_i[15:12];
		cr4 <= dat_i[19:16];
		cr5 <= dat_i[23:20];
		cr6 <= dat_i[27:24];
		cr7 <= dat_i[31:28];
		ssp <= ssp + 32'd4;
		state <= RTI3;
	end
RTI3:
	if (!stb_o) begin
		fc_o <= {3'b101};
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= ssp;
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		pc <= dat_i;
		ssp <= ssp + 32'd4;
		state <= IFETCH;
	end
