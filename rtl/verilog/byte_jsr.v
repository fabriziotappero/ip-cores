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
BYTE_JSR1:
	if (ack_i) begin
		state <= BYTE_JSR2;
		retstate <= BYTE_JSR2;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
	else if (err_i) begin
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		dat_o <= 32'h0;
		state <= BUS_ERROR;
	end
BYTE_JSR2:
	begin
		radr <= {spage[31:8],sp[7:2]};
		wadr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr2LSB <= sp[1:0];
		wdat <= {4{pcp2[7:0]}};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		case(sp[1:0])
		2'd0:	sel_o <= 4'b0001;
		2'd1:	sel_o <= 4'b0010;
		2'd2:	sel_o <= 4'b0100;
		2'd3:	sel_o <= 4'b1000;
		endcase
		adr_o <= {spage[31:8],sp[7:2],2'b00};
		dat_o <= {4{pcp2[7:0]}};
		sp <= sp_dec;
		state <= BYTE_JSR3;
	end
BYTE_JSR3:
	if (ack_i) begin
		state <= IFETCH;
		retstate <= IFETCH;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		pc[15:0] <= ir[23:8];
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
	else if (err_i) begin
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		dat_o <= 32'h0;
		state <= BUS_ERROR;
	end

BYTE_JSR_INDX1:
	if (ack_i) begin
		state <= BYTE_JSR_INDX2;
		retstate <= BYTE_JSR_INDX2;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
BYTE_JSR_INDX2:
	begin
		radr <= {spage[31:8],sp[7:2]};
		wadr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr2LSB <= sp[1:0];
		wdat <= {4{pcp2[7:0]}};
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		case(sp[1:0])
		2'd0:	sel_o <= 4'b0001;
		2'd1:	sel_o <= 4'b0010;
		2'd2:	sel_o <= 4'b0100;
		2'd3:	sel_o <= 4'b1000;
		endcase
		adr_o <= {spage[31:8],sp[7:2],2'b00};
		dat_o <= {4{pcp2[7:0]}};
		sp <= sp_dec;
		state <= BYTE_JSR_INDX3;
	end
BYTE_JSR_INDX3:
	if (ack_i) begin
		load_what <= `PC_70;
		state <= LOAD_MAC1;
		retstate <= LOAD_MAC1;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		adr_o <= 34'd0;
		dat_o <= 32'd0;
		radr <= absx_address[15:2];
		radr2LSB <= absx_address[1:0];
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
	else if (err_i) begin
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		dat_o <= 32'h0;
		state <= BUS_ERROR;
	end
