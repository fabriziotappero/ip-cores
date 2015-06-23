// ============================================================================
//        __
//   \\__/ o\    (C) 2013,2014  Robert Finch, Stratford
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
task load_tsk;
input [31:0] dat;
input [7:0] dat8;
begin
	case(load_what)
	`WORD_310:
				begin
					b <= dat;
					b8 <= dat8;		// for the orb instruction
					state <= CALC;
				end
	`WORD_311:	// For pla/plx/ply/pop/ldx/ldy
				begin
					if (ir9==`POP)
						Rt <= ir[15:12];
					res <= dat;
					state <= isPopa ? LOAD_MAC3 : IFETCH;
				end
	`WORD_312:
			begin
				b <= dat;
				radr <= y;
				wadr <= y;
				store_what <= `STW_B;
				x <= res[31:0];
				acc <= acc_dec;
				state <= STORE1;
			end
	`WORD_313:
			begin
				a <= dat;
				radr <= y;
				load_what <= `WORD_314;
				x <= res[31:0];
				state <= LOAD_MAC1;
			end
	`WORD_314:
			begin
				b <= dat;
				acc <= acc - 32'd1;
				state <= CMPS1;
			end
`ifdef SUPPORT_EM8
	`BYTE_70:
				begin
					b8 <= dat8;
					state <= BYTE_CALC;
				end
	`BYTE_71:
			begin
				res8 <= dat8;
				state <= BYTE_IFETCH;
			end
`endif
`ifdef SUPPORT_816
	`HALF_70:
				begin
					b16[7:0] <= dat8;
					load_what <= `HALF_158;
					if (radr2LSB==2'b11)
						radr <= radr+32'd1;
					radr2LSB <= radr2LSB + 2'b01;
					state <= LOAD_MAC1;
				end
	`HALF_158:
				begin
					b16[15:8] <= dat8;
					state <= HALF_CALC;
				end
	`HALF_71:
				begin
					res16[7:0] <= dat8;
					load_what <= `HALF_159;
					if (radr2LSB==2'b11)
						radr <= radr+32'd1;
					radr2LSB <= radr2LSB + 2'b01;
					next_state(LOAD_MAC1);
				end
	`HALF_159:
				begin
					res16[15:8] <= dat8;
					next_state(BYTE_IFETCH);
				end
	`HALF_71S:
				begin
					res16[7:0] <= dat8;
					load_what <= `HALF_159S;
					inc_sp();
					next_state(LOAD_MAC1);
				end
	`HALF_159S:
				begin
					res16[15:8] <= dat8;
					next_state(BYTE_IFETCH);
				end
	`BYTE_72:
				begin
					wdat[7:0] <= dat8;
					radr <= mvndst_address[31:2];
					radr2LSB <= mvndst_address[1:0];
					wadr <= mvndst_address[31:2];
					wadr2LSB <= mvndst_address[1:0];
					store_what <= `STW_DEF8;
					acc[15:0] <= acc_dec[15:0];
					if (ir9==`MVN) begin
						x[15:0] <= x_inc[15:0];
						y[15:0] <= y_inc[15:0];
					end
					else begin
						x[15:0] <= x_dec[15:0];
						y[15:0] <= y_dec[15:0];
					end
					next_state(STORE1);
				end
`endif
	`SR_310:	begin
					cf <= dat[0];
					zf <= dat[1];
					im <= dat[2];
					df <= dat[3];
					bf <= dat[4];
					x_bit <= dat[8];
					m_bit <= dat[9];
					m816 <= dat[10];
					tf <= dat[28];
					em <= dat[29];
					vf <= dat[30];
					nf <= dat[31];
					if (isRTI) begin
						// If we will be returning to emulation mode and emulating the 816
						// then force the upper part of the registers to zero if eigth bit
						// registers are selected.
//						if (dat[10] & dat[29]) begin
//							if (dat[8]) begin
//								x[31:8] <= 24'd0;
//								y[31:8] <= 24'd0;
//							end
//							//if (dat[9]) acc[31:8] <= 24'd0;
//						end
						radr <= isp;
						isp <= isp_inc;
						load_what <= `PC_310;
						state <= LOAD_MAC1;
					end
					else	// PLP
						state <= IFETCH;
				end
`ifdef SUPPORT_EM8
	`SR_70:		begin
					cf <= dat8[0];
					zf <= dat8[1];
					im <= dat8[2];
					df <= dat8[3];
					if (m816) begin
						x_bit <= dat8[4];
						m_bit <= dat8[5];
						if (dat8[4]) begin
							x[31:8] <= 24'd0;
							y[31:8] <= 24'd0;
						end
						//if (dat8[5]) acc[31:8] <= 24'd0;
					end
					else
						bf <= dat8[4];
					vf <= dat8[6];
					nf <= dat8[7];
					if (isRTI) begin
						load_what <= `PC_70;
						inc_sp();
						state <= LOAD_MAC1;
					end		
					else	// PLP
						state <= BYTE_IFETCH;
				end
	`PC_70:		begin
					pc[7:0] <= dat8;
					load_what <= `PC_158;
					if (isRTI|isRTS|isRTL) begin
						inc_sp();
					end
					else begin	// JMP (abs)
						radr <= radr34p1[33:2];
						radr2LSB <= radr34p1[1:0];
					end
					state <= LOAD_MAC1;
				end
	`PC_158:	begin
					pc[15:8] <= dat8;
					if ((isRTI&m816)|isRTL) begin
						load_what <= `PC_2316;
						inc_sp();
						state <= LOAD_MAC1;
					end
					else if (isRTS)	// rts instruction
						next_state(RTS1);
					else			// jmp (abs)
						next_state(BYTE_IFETCH);
				end
	`PC_2316:	begin
					pc[23:16] <= dat8;
					if (isRTL) begin
						load_what <= `NOTHING;
						next_state(RTS1);
					end
					else begin
						load_what <= `NOTHING;
						next_state(BYTE_IFETCH);
//						load_what <= `PC_3124;
//						if (isRTI) begin
//							inc_sp();
//						end
//						state <= LOAD_MAC1;	
					end
				end
	`PC_3124:	begin
					pc[31:24] <= dat8;
					load_what <= `NOTHING;
					next_state(BYTE_IFETCH);
				end
`endif
	`PC_310:	begin
					pc <= dat;
					load_what <= `NOTHING;
					if (isRTI) begin
						km <= `FALSE;
`ifdef DEBUG
						hist_capture <= `TRUE;
`endif
					end
					next_state(em ? BYTE_IFETCH : IFETCH);
//					else	// indirect jumps
//						next_state(IFETCH);
				end
	`IA_310:
			begin
				radr <= dat;
				wadr <= dat;
				wdat <= a;
				if (isIY)
					state <= IY3;
				else if (ir9==`ST_IX)
					state <= STORE1;
				else if (ir9==`LEA_IX) begin
					res <= dat;
					next_state(IFETCH);
				end
				else begin
					load_what <= `WORD_310;
					state <= LOAD_MAC1;
				end
			end
`ifdef SUPPORT_EM8
	`IA_70:
			begin
				radr <= radr34p1[33:2];
				radr2LSB <= radr34p1[1:0];
				ia[7:0] <= dat8;
				load_what <= `IA_158;
				state <= LOAD_MAC1;
			end
	`IA_158:
			begin
				ia[15:8] <= dat8;
				ia[31:16] <= {abs8[31:24],dbr};
				if (isIY24|isI24) begin
					radr <= radr34p1[33:2];
					radr2LSB <= radr34p1[1:0];
					load_what <= `IA_2316;
					state <= LOAD_MAC1;
				end
				else
					state <= isIY ? BYTE_IY5 : BYTE_IX5;
			end
	`IA_2316:
			begin
				ia[23:16] <= dat8;
				ia[31:24] <= abs8[31:24];
				state <= isIY24 ? BYTE_IY5 : BYTE_IX5;
			end
`endif
	endcase
end
endtask
