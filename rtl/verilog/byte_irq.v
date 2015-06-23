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
// IRQ processing states for 65C02 emulation mode
// The high order PC[31:16] is set to zero, forcing the IRQ routine to be in bank zero.
//
BYTE_IRQ1:
	if (ack_i) begin
		state <= BYTE_IRQ2;
		retstate <= BYTE_IRQ2;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		sp <= sp_dec;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
BYTE_IRQ2:
	begin
		radr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:8],sp[7:2]};
		wadr2LSB <= sp[1:0];
		wdat <= {4{pc[23:16]}};
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
		dat_o <= {4{pc[23:16]}};
		state <= BYTE_IRQ3;
	end
BYTE_IRQ3:
	if (ack_i) begin
		state <= BYTE_IRQ4;
		retstate <= BYTE_IRQ4;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		sp <= sp_dec;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
BYTE_IRQ4:
	begin
		radr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:8],sp[7:2]};
		wadr2LSB <= sp[1:0];
		wdat <= {4{pc[15:8]}};
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
		dat_o <= {4{pc[15:8]}};
		state <= BYTE_IRQ5;
	end
BYTE_IRQ5:
	if (ack_i) begin
		state <= BYTE_IRQ6;
		retstate <= BYTE_IRQ6;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		sp <= sp_dec;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
BYTE_IRQ6:
	begin
		radr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:8],sp[7:2]};
		wadr2LSB <= sp[1:0];
		wdat <= {4{pc[7:0]}};
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
		dat_o <= {4{pc[7:0]}};
		state <= BYTE_IRQ7;
	end
BYTE_IRQ7:
	if (ack_i) begin
		state <= BYTE_IRQ8;
		retstate <= BYTE_IRQ8;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		sp <= sp_dec;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
	end
BYTE_IRQ8:
	begin
		radr <= {spage[31:8],sp[7:2]};
		radr2LSB <= sp[1:0];
		wadr <= {spage[31:8],sp[7:2]};
		wadr2LSB <= sp[1:0];
		wdat <= {4{sr8[7:0]}};
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
		dat_o <= {4{sr8[7:0]}};
		state <= BYTE_IRQ9;
	end
BYTE_IRQ9:
	if (ack_i) begin
		load_what <= `PC_70;
		state <= LOAD_MAC1;
		retstate <= LOAD_MAC1;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		sel_o <= 4'h0;
		sp <= sp_dec;
		if (dhit) begin
			wrsel <= sel_o;
			wr <= 1'b1;
		end
		else if (write_allocate) begin
			state <= WAIT_DHIT;
			dmiss <= `TRUE;
		end
		pc[31:16] <= 16'h0000;
		radr <= vect[31:2];
		radr2LSB <= vect[1:0];
	end
	