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
RTI1:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= RTI2;
	end
	else if (dhit) begin
		cf <= rdat[0];
		zf <= rdat[1];
		im <= rdat[2];
		df <= rdat[3];
		bf <= rdat[4];
		em1 <= rdat[29];
		vf <= rdat[30];
		nf <= rdat[31];
		isp <= isp_inc;
		radr <= isp_inc;
		state <= RTI3;
	end
	else
		dmiss <= `TRUE;
RTI2:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		cf <= dat_i[0];
		zf <= dat_i[1];
		im <= dat_i[2];
		df <= dat_i[3];
		bf <= dat_i[4];
		em1 <= dat_i[29];
		vf <= dat_i[30];
		nf <= dat_i[31];
		isp <= isp_inc;
		radr <= isp_inc;
		state <= RTI3;
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
RTI3:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= RTI4;
	end
	else if (dhit) begin
		isp <= isp_inc;
		em <= em1;
		pc <= rdat;
		state <= IFETCH;
	end
	else
		dmiss <= `TRUE;
RTI4:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		isp <= isp_inc;
		em <= em1;
		pc <= dat_i;
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
