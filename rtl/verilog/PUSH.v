// ============================================================================
//  PUSH register to stack
//
//
//  (C) 2009-2012  Robert Finch, Stratford
//  robfinch[remove]@opencores.org
//
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
//  Verilog 
//
// ============================================================================
//
PUSH:
	begin
		// Note SP is predecremented at the decode stage
		cyc_type <= `CT_WRMEM;
		lock_o <= 1'b1;
		cyc_o <= 1'b1;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		adr_o <= sssp;
		state <= PUSH1;
		case(ir)
		`PUSH_AX: dat_o <= ah;
		`PUSH_BX: dat_o <= bh;
		`PUSH_CX: dat_o <= ch;
		`PUSH_DX: dat_o <= dh;
		`PUSH_SP: dat_o <= sp[15:8];
		`PUSH_BP: dat_o <= bp[15:8];
		`PUSH_SI: dat_o <= si[15:8];
		`PUSH_DI: dat_o <= di[15:8];
		`PUSH_CS: dat_o <= cs[15:8];
		`PUSH_DS: dat_o <= ds[15:8];
		`PUSH_SS: dat_o <= ss[15:8];
		`PUSH_ES: dat_o <= es[15:8];
		`PUSHF:   dat_o <= flags[15:8];
		8'hFF:	dat_o <= a[15:8];
		default:	dat_o <= 8'hFF;		// only gets here if there's a hardware error
		endcase
	end
PUSH1:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		sp <= sp_dec;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		state <= PUSH2;
	end
PUSH2:
	begin
		cyc_type <= `CT_WRMEM;
		stb_o <= 1'b1;
		we_o <= 1'b1;
		adr_o <= sssp;
		state <= PUSH3;
		case(ir)
		`PUSH_AX: dat_o <= al;
		`PUSH_BX: dat_o <= bl;
		`PUSH_CX: dat_o <= cl;
		`PUSH_DX: dat_o <= dl;
		`PUSH_SP: dat_o <= sp[7:0];
		`PUSH_BP: dat_o <= bp[7:0];
		`PUSH_SI: dat_o <= si[7:0];
		`PUSH_DI: dat_o <= di[7:0];
		`PUSH_CS: dat_o <= cs[7:0];
		`PUSH_DS: dat_o <= ds[7:0];
		`PUSH_SS: dat_o <= ss[7:0];
		`PUSH_ES: dat_o <= es[7:0];
		`PUSHF:   dat_o <= flags[7:0];
		8'hFF: dat_o <= a[7:0];
		default:	dat_o <= 8'hFF;		// only get's here if there's a hardware error
		endcase
	end

// Note stack pointer is decrement already in DECODE
//
PUSH3:
	if (ack_i) begin
		cyc_type <= `CT_PASSIVE;
		lock_o <= 1'b0;
		cyc_o <= 1'b0;
		stb_o <= 1'b0;
		we_o <= 1'b0;
		state <= IFETCH;
	end
