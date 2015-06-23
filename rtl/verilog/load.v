// ============================================================================
//        __
//   \\__/ o\    (C) 2013  Robert Finch, Stratford
//    \  __ /    All rights reserved.
//     \/_//     robfinch<remove>@opencores.org
//       ||
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
// Performs the data fetch for both eight bit and 32 bit modes
// Handle the following address modes: zp : zp,Rn : abs : abs,Rn
LOAD1:
	if (unCachedData) begin
		if (isRMW)
			lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hf;
		adr_o <= {radr,2'b00};
		state <= LOAD2;
	end
	else if (dhit) begin
		b8 <= rdat8;
		b <= rdat;
		state <= em ? BYTE_CALC : CALC;
	end
	else
		dmiss <= `TRUE;
LOAD2:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'd0;
		b8 <= dati;
		b <= dat_i;
		state <= em ? BYTE_CALC : CALC;
	end
	else if (err_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'd0;
		state <= BUS_ERROR;
	end
