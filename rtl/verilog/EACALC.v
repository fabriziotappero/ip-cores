// ============================================================================
//  EACALC
//  - calculation of effective address
//
//
//  (C) 2009-2013  Robert Finch, Stratford
//  robfinch[remove]@finitron.ca
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
//
//  Verilog 
//
// - the effective address calculation may need to fetch an additional
//   eight or sixteen bit displacement value in order to calculate the
//   effective address.
// - the EA calc only needs to be done once as there is only ever a 
//   single memory operand address. Once the EA is calculated it is
//   used for both the fetch and the store when memory is the target.
// ============================================================================
//
EACALC:
	// Terminate an outstanding MODRM fetch cycle
	if (cyc_o) begin
		if (ack_i) begin
			term_code_read();
			mod   <= dat_i[7:6];
			rrr   <= dat_i[5:3];
			sreg3 <= dat_i[5:3];
			TTT   <= dat_i[5:3];
			rm    <= dat_i[2:0];
			$display("Mod/RM=%b_%b_%b", dat_i[7:6],dat_i[5:3],dat_i[2:0]);
		end
	end
	else begin

		disp16 <= 16'h0000;

		case(mod)

		2'b00:
			begin
				state <= EACALC1;
				// ToDo: error on stack state
				case(rm)
				3'd0:	offset <= bx + si;
				3'd1:	offset <= bx + di;
				3'd2:	offset <= bp + si;
				3'd3:	offset <= bp + di;
				3'd4:	offset <= si;
				3'd5:	offset <= di;
				3'd6:	begin
						state <= EACALC_DISP16;
						offset <= 16'h0000;
						end
				3'd7:	offset <= bx;
				endcase
			end

		2'b01:
			begin
				state <= EACALC_DISP8;
				case(rm)
				3'd0:	offset <= bx + si;
				3'd1:	offset <= bx + di;
				3'd2:	offset <= bp + si;
				3'd3:	offset <= bp + di;
				3'd4:	offset <= si;
				3'd5:	offset <= di;
				3'd6:	offset <= bp;
				3'd7:	offset <= bx;
				endcase
			end

		2'b10:
			begin
				state <= EACALC_DISP16;
				case(rm)
				3'd0:	offset <= bx + si;
				3'd1:	offset <= bx + di;
				3'd2:	offset <= bp + si;
				3'd3:	offset <= bp + di;
				3'd4:	offset <= si;
				3'd5:	offset <= di;
				3'd6:	offset <= bp;
				3'd7:	offset <= bx;
				endcase
			end

		2'b11:
			begin
				state <= EXECUTE;
				case(ir)
				`MOV_I8M:
					begin
						rrr <= rm;
						if (rrr==3'd0) state <= FETCH_IMM8;
					end
				`MOV_I16M:
					begin
						rrr <= rm;
						if (rrr==3'd0) state <= FETCH_IMM16;
					end
				`MOV_S2R:
					begin
						a <= rfso;
						b <= rfso;
					end
				`MOV_R2S:
					begin
						a <= rmo;
						b <= rmo;
					end
				`POP_MEM:
					begin
						ir <= 8'h58|rm;
						state <= POP;
					end
				`XCHG_MEM:
					begin
						wrregs <= 1'b1;
						res <= rmo;
						b <= rrro;
					end
				// shifts and rotates
				8'hD0,8'hD1,8'hD2,8'hD3:
					begin
						b <= rmo;
					end
				// The TEST instruction is the only one needing to fetch an immediate value.
				8'hF6,8'hF7:
					// 000 = TEST
					// 010 = NOT
					// 011 = NEG
					// 100 = MUL
					// 101 = IMUL
					// 110 = DIV
					// 111 = IDIV
					if (rrr==3'b000) begin	// TEST
						a <= rmo;
						state <= w ? FETCH_IMM16 : FETCH_IMM8;
					end
					else
						b <= rmo;
				default:
				    begin
						if (d) begin
							a <= rmo;
							b <= rrro;
						end
						else begin
							a <= rrro;
							b <= rmo;
						end
					end
				endcase
				hasFetchedData <= 1'b1;
			end
		endcase
	end

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Fetch 16 bit displacement
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
EACALC_DISP16:
	begin
		lock_o <= 1'b1;
		code_read();
		state <= EACALC_DISP16_ACK;
	end
EACALC_DISP16_ACK:
	if (ack_i) begin
		term_code_read();
		disp16[7:0] <= dat_i;
		state <= EACALC_DISP16a;
	end
EACALC_DISP16a:
	begin
		code_read();
		state <= EACALC_DISP16a_ACK;
	end
EACALC_DISP16a_ACK:
	if (ack_i) begin
		term_code_read();
		lock_o <= bus_locked;
		disp16[15:8] <= dat_i;
		state <= EACALC1;
	end

//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Fetch 8 bit displacement
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
EACALC_DISP8:
	begin
		code_read();
		state <= EACALC_DISP8_ACK;
	end
EACALC_DISP8_ACK:
	if (ack_i) begin
		term_code_read();
		disp16 <= {{8{dat_i[7]}},dat_i};
		state <= EACALC1;
	end


//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
// Add the displacement into the effective address
//- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
//
EACALC1:
	begin
		casex(ir)
		`EXTOP:
			casex(ir2)
			8'h00:
				begin
					case(rrr)
					3'b010: state <= FETCH_DESC;	// LLDT
					3'b011: state <= FETCH_DATA;	// LTR
					default: state <= FETCH_DATA;
					endcase
					if (w && (offsdisp==16'hFFFF)) begin
						int_num <= 8'h0d;
						state <= INT2;
					end
				end
			8'h01:
				begin
					case(rrr)
					3'b010: state <= FETCH_DESC;
					3'b011: state <= FETCH_DESC;
					default: state <= FETCH_DATA;
					endcase
					if (w && (offsdisp==16'hFFFF)) begin
						int_num <= 8'h0d;
						state <= INT2;
					end
				end
			8'h03:
				if (w && (offsdisp==16'hFFFF)) begin
					int_num <= 8'h0d;
					state <= INT2;
				end
				else
					state <= FETCH_DATA;
			default:
				if (w && (offsdisp==16'hFFFF)) begin
					int_num <= 8'h0d;
					state <= INT2;
				end
				else
					state <= FETCH_DATA;
			endcase
		`MOV_I8M: state <= FETCH_IMM8;
		`MOV_I16M:
			if (ip==16'hFFFF) begin
				int_num <= 8'h0d;
				state <= INT2;
			end
			else
				state <= FETCH_IMM16;
		`POP_MEM:
			begin
				state <= POP;
			end
		`XCHG_MEM:
			begin
//				bus_locked <= 1'b1;
				state <= FETCH_DATA;
			end
		8'b1000100x:	// Move to memory
			begin
				$display("EACALC1: state <= STORE_DATA");
				if (w && (offsdisp==16'hFFFF)) begin
					int_num <= 8'h0d;
					state <= INT2;
				end
				else begin	
					res <= rrro;
					state <= STORE_DATA;
				end
			end
		default:
			begin
				$display("EACALC1: state <= FETCH_DATA");
				if (w && (offsdisp==16'hFFFF)) begin
					int_num <= 8'h0d;
					state <= INT2;
				end
				else	
					state <= FETCH_DATA;
				if (ir==8'hff) begin
					case(rrr)
					3'b011: state <= CALLF;	// CAll FAR indirect
					3'b101: state <= JUMP_VECTOR1;	// JMP FAR indirect
					3'b110:	begin d <= 1'b0; state <= FETCH_DATA; end// for a push
					default: ;
					endcase
				end
			end
		endcase
//		ea <= ea + disp16;
		ea <= {seg_reg,`SEG_SHIFT} + offsdisp;	// offsdisp = offset + disp16
	end
