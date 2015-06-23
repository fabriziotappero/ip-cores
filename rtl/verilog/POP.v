// ============================================================================
// (C) 2011 Robert Finch
// All Rights Reserved.
// robfinch<remove>@opencores.org
//
// KLC32 - 32 bit CPU
// POP type instructions
// POP / UNLK
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
POP1:
	if (ir[25:1]==25'd0)
		state <= IFETCH;
	else begin
		Rn <= ir[25:21];
		ir[25:0] <= {ir[20:1],6'b0};
		if (ir[25:21]!=5'd0)
			state <= POP2;
	end
POP2:
	begin
		fc_o <= {sf,2'b01};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= sf ? ssp : usp;
		state <= POP3;
	end
POP3:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		if (sf)
			ssp <= ssp + 32'd4;
		else
			usp <= usp + 32'd4;
		res <= dat_i;
		state <= WRITEBACK;
	end

UNLK:
	if (!cyc_o) begin
		fc_o <= {sf,2'b01};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'b1111;
		adr_o <= a;
		if (sf)
			ssp <= a;
		else
			usp <= a;
	end
	else if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'b0000;
		if (sf)
			ssp <= ssp + 32'd4;
		else
			usp <= usp + 32'd4;
		res <= dat_i;
		state <= WRITEBACK;
	end

