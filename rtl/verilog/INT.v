// ============================================================================
//  INT.v
//  - Interrupt handling
//
//
//  2009-2012  Robert Finch
//  robfinch[remove]@opencores.org
//  Stratford
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
//
//  Verilog 
//
// - bus is locked if immediate value is unaligned in memory
// - immediate values are the last operand to be fetched, hence
//   the state machine can transition into the EXECUTE state.
// - we also know the immediate value can't be the target of an
//   operation.
// ============================================================================
//
// Fetch interrupt number from instruction stream
//
INT:
	begin
		`INITIATE_CODE_READ
		lock_o <= 1'b1;
		sp <= sp_dec;		// pre-decrement
		state <= INT1;
	end
INT1:
	if (ack_i) begin
		`PAUSE_CODE_READ
		int_num <= dat_i;
		state <= INT2;
	end
INT2:
	begin
		cyc_type <= `CT_RDMEM;
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o  <= 1'b0;
		adr_o <= {int_num,2'b00};
		state <= INT3;
	end
INT3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		offset[7:0] <= dat_i;
		state <= INT4;
	end
INT4:
	begin
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= adr_o_inc;
		state <= INT5;
	end
INT5:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		offset[15:8] <= dat_i;
		state <= INT6;
	end
INT6:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= adr_o_inc;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		stb_o <= 1'b0;
		state <= INT7;
		selector[7:0] <= dat_i;
	end
INT7:
	if (!stb_o) begin
		cyc_type <= `CT_RDMEM;
		stb_o <= 1'b1;
		adr_o <= adr_o_inc;
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		state <= INT8;
		selector[15:8] <= dat_i;
	end
INT8:
	if (!cyc_o) begin
		`INITIATE_STACK_WRITE
		lock_o <= 1'b1;
		dat_o <= flags[15:8];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		state <= INT9;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
	end
INT9:
	if (!stb_o) begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= sssp;
		dat_o <= flags[7:0];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		state <= INT10;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		ie <= 1'b0;
		tf <= 1'b0;
	end
INT10:
	if (!stb_o) begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= sssp;
		dat_o <= cs[15:8];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		state <= INT11;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
	end
INT11:
	if (!stb_o) begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= sssp;
		dat_o <= cs[7:0];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		state <= INT12;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
	end
INT12:
	if (!stb_o) begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= sssp;
		dat_o <= ir_ip[15:8];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		state <= INT13;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
	end
INT13:
	if (!stb_o) begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o  <= 1'b1;
		adr_o <= sssp;
		dat_o <= ir_ip[7:0];
	end
	else if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		state <= IFETCH;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o  <= 1'b0;
		cs <= selector;
		ip <= offset;
	end
