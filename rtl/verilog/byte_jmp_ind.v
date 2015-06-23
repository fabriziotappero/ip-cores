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
BYTE_JMP_IND1:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_JMP_IND2;
	end
	else if (dhit) begin
		pc[7:0] <= rdat8;
		radr <= radr34p1[33:2];
		radr2LSB <= radr34p1[1:0];
		state <= BYTE_JMP_IND3;
	end
	else
		dmiss <= `TRUE;
BYTE_JMP_IND2:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'd0;
		radr <= radr34p1[33:2];
		radr2LSB <= radr34p1[1:0];
		pc[7:0] <= dati;
		state <= BYTE_JMP_IND3;
	end
	else if (err_i) begin
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		dat_o <= 32'h0;
		state <= BUS_ERROR;
	end
BYTE_JMP_IND3:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_JMP_IND4;
	end
	else if (dhit) begin
		pc[15:8] <= rdat8;
		state <= IFETCH;
	end
	else
		dmiss <= `TRUE;
BYTE_JMP_IND4:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'd0;
		pc[15:8] <= dati;
		state <= IFETCH;
	end
	else if (err_i) begin
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		dat_o <= 32'h0;
		state <= BUS_ERROR;
	end
