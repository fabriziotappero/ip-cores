// ============================================================================
//  (C) 2009,2010,2012  Robert Finch
//  robfinch<remove>@opencores.org
//
//  EXECUTE
//  - execute instruction
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
// ============================================================================
//
EXECUTE:
	begin
		casex(ir)

		`EXTOP:
			casex(ir2)
			`LxDT: state <= FETCH_DESC;
			endcase

		`DAA:
			begin
				state <= IFETCH;
			end

		`ALU_I2R8,`ALU_I2R16,`ADD,`ADD_ALI8,`ADD_AXI16,`ADC,`ADC_ALI8,`ADC_AXI16:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				res <= alu_o;
				pf <= pres;
				af <= carry   (1'b0,a[3],b[3],alu_o[3]);
				cf <= carry   (1'b0,amsb,bmsb,resn);
				vf <= overflow(1'b0,amsb,bmsb,resn);
				sf <= resn;
				zf <= resz;
			end

		`AND,`OR,`XOR,`AND_ALI8,`OR_ALI8,`XOR_ALI8,`AND_AXI16,`OR_AXI16,`XOR_AXI16:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				res <= alu_o;
				pf <= pres;
				cf <= 1'b0;
				vf <= 1'b0;
				sf <= resn;
				zf <= resz;
			end

		`TEST:
			begin
				state <= IFETCH;
				res <= alu_o;
				pf <= pres;
				cf <= 1'b0;
				vf <= 1'b0;
				sf <= resn;
				zf <= resz;
			end

		`CMP,`CMP_ALI8,`CMP_AXI16:
			begin
				state <= IFETCH;
				pf <= pres;
				af <= carry   (1'b1,a[3],b[3],alu_o[3]);
				cf <= carry   (1'b1,amsb,bmsb,resn);
				vf <= overflow(1'b1,amsb,bmsb,resn);
				sf <= resn;
				zf <= resz;
			end

		`SBB,`SUB,`SBB_ALI8,`SUB_ALI8,`SBB_AXI16,`SUB_AXI16:
			begin
				wrregs <= 1'b1;
				state <= IFETCH;
				res <= alu_o;
				pf <= pres;
				af <= carry   (1'b1,a[3],b[3],alu_o[3]);
				cf <= carry   (1'b1,amsb,bmsb,resn);
				vf <= overflow(1'b1,amsb,bmsb,resn);
				sf <= resn;
				zf <= resz;
			end

		8'hF6,8'hF7:
			begin
				state <= IFETCH;
				res <= alu_o;
				case(TTT)
				3'd0:	// TEST
					begin
						pf <= pres;
						cf <= 1'b0;
						vf <= 1'b0;
						sf <= resn;
						zf <= resz;
					end
				3'd2:	// NOT
					begin
						wrregs <= 1'b1;
					end
				3'd3:	// NEG
					begin
						pf <= pres;
						af <= carry   (1'b1,1'b0,b[3],alu_o[3]);
						cf <= carry   (1'b1,1'b0,bmsb,resn);
						vf <= overflow(1'b1,1'b0,bmsb,resn);
						sf <= resn;
						zf <= resz;
						wrregs <= 1'b1;
					end
				// Normally only a single register update is required, however with 
				// multiply word both AX and DX need to be updated. So we bypass the
				// regular update here.
				3'd4:
					begin
						if (w) begin
							ax <= p32[15:0];
							dx <= p32[31:16];
							cf <= p32[31:16]!=16'd0;
							vf <= p32[31:16]!=16'd0;
						end
						else begin
							ax <= p16;
							cf <= p16[15:8]!=8'd0;
							vf <= p16[15:8]!=8'd0;
						end
					end
				3'd5:
					begin
						if (w) begin
							ax <= wp[15:0];
							dx <= wp[31:16];
							cf <= p32[31:16]!=16'd0;
							vf <= p32[31:16]!=16'd0;
						end
						else begin
							ax <= p;
							cf <= p[15:8]!=8'd0;
							vf <= p[15:8]!=8'd0;
						end
					end
				3'd6,3'd7:
					begin
						$display("state <= DIVIDE1");
						state <= DIVIDE1;
					end
				default:	;
				endcase
			end

		`INC_REG:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				w <= 1'b1;
				res <= alu_o;
				pf <= pres;
				af <= carry   (1'b0,a[3],b[3],alu_o[3]);
				vf <= overflow(1'b0,a[15],b[15],resnw);
				sf <= resnw;
				zf <= reszw;
			end
		`DEC_REG:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				w <= 1'b1;
				res <= alu_o;
				pf <= pres;
				af <= carry   (1'b1,a[3],b[3],alu_o[3]);
				vf <= overflow(1'b1,a[15],b[15],resnw);
				sf <= resnw;
				zf <= reszw;
			end
//		`IMUL:
//			begin
//				state <= IFETCH;
//				wrregs <= 1'b1;
//				w <= 1'b1;
//				rrr <= 3'd0;
//				res <= alu_o;
//				if (w) begin
//					cf <= wp[31:16]!={16{resnw}};
//					vf <= wp[31:16]!={16{resnw}};
//					dx <= wp[31:16];
//				end
//				else begin
//					cf <= ah!={8{resnb}};
//					vf <= ah!={8{resnb}};
//				end
//			end


		//-----------------------------------------------------------------
		// Memory Operations
		//-----------------------------------------------------------------
			
		// registers not allowed on LEA
		// invalid opcode
		//
		`LEA:
			begin
				w <= 1'b1;
				res <= ea;
				if (mod==2'b11) begin
					int_num <= 8'h06;
					state <= INT;
				end
				else begin
					state <= IFETCH;
					wrregs <= 1'b1;
				end
			end
		`LDS:
			begin
				wrsregs <= 1'b1;
				res <= alu_o;
				rrr <= 3'd3;
				state <= IFETCH;
			end
		`LES:
			begin
				wrsregs <= 1'b1;
				res <= alu_o;
				rrr <= 3'd0;
				state <= IFETCH;
			end

		`MOV_RR8,`MOV_RR16,
		`MOV_MR,
		`MOV_M2AL,`MOV_M2AX,
		`MOV_I2AL,`MOV_I2DL,`MOV_I2CL,`MOV_I2BL,`MOV_I2AH,`MOV_I2DH,`MOV_I2CH,`MOV_I2BH,
		`MOV_I2AX,`MOV_I2DX,`MOV_I2CX,`MOV_I2BX,`MOV_I2SP,`MOV_I2BP,`MOV_I2SI,`MOV_I2DI:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				res <= alu_o;
			end
		`XCHG_MEM:
			begin
				wrregs <= 1'b1;
				if (mod==2'b11) rrr <= rm;
				res <= alu_o;
				b <= rrro;
				state <= mod==2'b11 ? IFETCH : XCHG_MEM;
			end
		`MOV_I8M,`MOV_I16M:
			begin
				res <= alu_o;
				state <= rrr==3'd0 ? STORE_DATA : INVALID_OPCODE;
			end

		`MOV_S2R:
			begin
				w <= 1'b1;
				rrr <= rm;
				res <= b;
				if (mod==2'b11) begin
					state <= IFETCH;
					wrregs <= 1'b1;
				end
				else
					state <= STORE_DATA;
			end
		`MOV_R2S:
			begin
				wrsregs <= 1'b1;
				res <= alu_o;
				state <= IFETCH;
			end

		`LODSB:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				w <= 1'b0;
				rrr <= 3'd0;
				res <= a[7:0];
				if ( df) si <= si_dec;
				if (!df) si <= si_inc;
			end
		`LODSW:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				w <= 1'b1;
				rrr <= 3'd0;
				res <= a;
				if ( df) si <= si - 16'd2;
				if (!df) si <= si + 16'd2;
			end

		8'hD0,8'hD1,8'hD2,8'hD3,8'hC0,8'hC1:
			begin
				state <= IFETCH;
				wrregs <= 1'b1;
				rrr <= rm;
				if (w)
					case(rrr)
					3'b000:	// ROL
						begin
							res <= shlo[15:0]|shlo[31:16];
							cf <= bmsb;
							vf <= bmsb^b[14];
						end
					3'b001:	// ROR
						begin
							res <= shruo[15:0]|shruo[31:16];
							cf <= b[0];
							vf <= cf^b[15];
						end
					3'b010:	// RCL
						begin
							res <= shlco[16:1]|shlco[32:17];
							cf <= b[15];
							vf <= b[15]^b[14];
						end
					3'b011:	// RCR
						begin
							res <= shrcuo[15:0]|shrcuo[31:16];
							cf <= b[0];
							vf <= cf^b[15];
						end
					3'b100:	// SHL
						begin
							res <= shlo[15:0];
							cf <= shlo[16];
							vf <= b[15]^b[14];
						end
					3'b101:	// SHR
						begin
							res <= shruo[31:16];
							cf <= shruo[15];
							vf <= b[15];
						end
					3'b111:	// SAR
						begin
							res <= shro;
							cf <= b[0];
							vf <= 1'b0;
						end
					endcase
				else
					case(rrr)
					3'b000:	// ROL
						begin
							res <= shlo8[7:0]|shlo8[15:8];
							cf <= b[7];
							vf <= b[7]^b[6];
						end
					3'b001:	// ROR
						begin
							res <= shruo8[15:8]|shruo8[7:0];
							cf <= b[0];
							vf <= cf^b[7];
						end
					3'b010:	// RCL
						begin
							res <= shlco8[8:1]|shlco8[16:9];
							cf <= b[7];
							vf <= b[7]^b[6];
						end
					3'b011:	// RCR
						begin
							res <= shrcuo8[15:8]|shrcuo8[7:0];
							cf <= b[0];
							vf <= cf^b[7];
						end
					3'b100:	// SHL
						begin
							res <= shlo8[7:0];
							cf <= shlo8[8];
							vf <= b[7]^b[6];
						end
					3'b101:	// SHR
						begin
							res <= shruo8[15:8];
							cf <= shruo8[7];
							vf <= b[7];
						end
					3'b111:	// SAR
						begin
							res <= shro8;
							cf <= b[0];
							vf <= 1'b0;
						end
					endcase
			end

		//-----------------------------------------------------------------
		//-----------------------------------------------------------------
		`GRPFF:
			begin
				case(rrr)
				3'b000:		// INC
					begin
						state <= IFETCH;
						wrregs <= 1'b1;
						af <= carry   (1'b0,a[3],b[3],alu_o[3]);
						vf <= overflow(1'b0,a[15],b[15],alu_o[15]);
						w <= 1'b1;
						res <= alu_o;
						rrr <= rm;
						pf <= pres;
						sf <= resnw;
						zf <= reszw;
					end
				3'b001:		// DEC
					begin
						state <= IFETCH;
						wrregs <= 1'b1;
						af <= carry   (1'b1,a[3],b[3],alu_o[3]);
						vf <= overflow(1'b1,a[15],b[15],alu_o[15]);
						w <= 1'b1;
						res <= alu_o;
						rrr <= rm;
						pf <= pres;
						sf <= resnw;
						zf <= reszw;
					end
				3'b010:	begin sp <= sp_dec; state <= CALL_IN; end
				// These two should not be reachable here, as they would
				// be trapped by the EACALC.
				3'b011:	state <= CALL_FIN;	// CALL FAR indirect
				3'b101:	// JMP FAR indirect
					begin
						ip <= offset;
						cs <= selector;
						state <= IFETCH;
					end
				3'b110:	begin sp <= sp_dec; state <= PUSH; end
				default:
					begin
						af <= carry   (1'b0,a[3],b[3],alu_o[3]);
						vf <= overflow(1'b0,a[15],b[15],alu_o[15]);
					end
				endcase
			end

		//-----------------------------------------------------------------
		//-----------------------------------------------------------------
		default:
			state <= IFETCH;
		endcase
	end

