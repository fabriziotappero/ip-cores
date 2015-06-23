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
// RTI processing states for eight bit mode
//
BYTE_RTI9:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTI10;
	end
	else if (dhit) begin
		cf <= rdat8[0];
		zf <= rdat8[1];
		im <= rdat8[2];
		df <= rdat8[3];
		bf <= rdat8[4];
		vf <= rdat8[6];
		nf <= rdat8[7];
		sp <= sp_inc;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		state <= BYTE_RTI1;
	end
	else
		dmiss <= `TRUE;
BYTE_RTI10:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		cf <= dati[0];
		zf <= dati[1];
		im <= dati[2];
		df <= dati[3];
		bf <= dati[4];
		vf <= dati[6];
		nf <= dati[7];
		sp <= sp_inc;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		state <= BYTE_RTI1;
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
BYTE_RTI1:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= RTI2;
	end
	else if (dhit) begin
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[7:0] <= rdat8;
		state <= BYTE_RTI3;
	end
	else
		dmiss <= `TRUE;
BYTE_RTI2:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[7:0] <= dati;
		state <= BYTE_RTI3;
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
BYTE_RTI3:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTI4;
	end
	else if (dhit) begin
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[15:8] <= rdat8;
		state <= BYTE_RTI5;
	end
	else
		dmiss <= `TRUE;
BYTE_RTI4:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[15:8] <= dati;
		state <= BYTE_RTI5;
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
BYTE_RTI5:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTI6;
	end
	else if (dhit) begin
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[23:16] <= rdat8;
		state <= BYTE_RTI7;
	end
	else
		dmiss <= `TRUE;
BYTE_RTI6:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[23:16] <= dati;
		state <= BYTE_RTI7;
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
BYTE_RTI7:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTI8;
	end
	else if (dhit) begin
		pc[31:24] <= rdat8;
		state <= IFETCH;
	end
	else
		dmiss <= `TRUE;
BYTE_RTI8:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		pc[31:24] <= dati;
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
