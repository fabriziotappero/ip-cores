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
// Eight bit mode RTS/RTL states
//
BYTE_RTS1:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTS2;
	end
	else if (dhit) begin
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[7:0] <= rdat8;
		state <= BYTE_RTS3;
	end
	else
		dmiss <= `TRUE;
BYTE_RTS2:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		pc[7:0] <= dati;
		state <= BYTE_RTS3;
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
BYTE_RTS3:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTS4;
	end
	else if (dhit) begin
		if (ir[7:0]==`RTL) begin
			radr <= {spage[31:8],sp_inc[7:2]};
			radr2LSB <= sp_inc[1:0];
			sp <= sp_inc;
		end
		pc[15:8] <= rdat8;
		state <= BYTE_RTS5;
	end
	else
		dmiss <= `TRUE;
BYTE_RTS4:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		pc[15:8] <= dati;
		if (ir[7:0]==`RTL) begin
			radr <= {spage[31:8],sp_inc[7:2]};
			radr2LSB <= sp_inc[1:0];
			sp <= sp_inc;
		end
		state <= BYTE_RTS5;
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
BYTE_RTS5:
	if (ir[7:0]!=`RTL) begin
		pc <= pc + 32'd1;
		state <= IFETCH;
	end
	else begin
		if (unCachedData) begin
			cyc_o <= 1'b1;
			stb_o <= 1'b1;
			sel_o <= 4'hF;
			adr_o <= {radr,2'b00};
			state <= BYTE_RTS6;
		end
		else if (dhit) begin
			radr <= {spage[31:8],sp_inc[7:2]};
			radr2LSB <= sp_inc[1:0];
			sp <= sp_inc;
			pc[23:16] <= rdat8;
			state <= BYTE_RTS7;
		end
		else
			dmiss <= `TRUE;
	end
BYTE_RTS6:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		pc[23:16] <= dati;
		radr <= {spage[31:8],sp_inc[7:2]};
		radr2LSB <= sp_inc[1:0];
		sp <= sp_inc;
		state <= BYTE_RTS7;
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
BYTE_RTS7:
	if (unCachedData) begin
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		sel_o <= 4'hF;
		adr_o <= {radr,2'b00};
		state <= BYTE_RTS8;
	end
	else if (dhit) begin
		pc[31:24] <= rdat8;
		state <= BYTE_RTS9;
	end
	else
		dmiss <= `TRUE;
BYTE_RTS8:
	if (ack_i) begin
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'h0;
		pc[31:24] <= dati;
		state <= BYTE_RTS9;
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
BYTE_RTS9:
	begin
		pc <= pc + 32'd1;
		state <= IFETCH;
	end

