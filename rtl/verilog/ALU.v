// ============================================================================
//  ALU
//  - perform datapath operations
//
//
//  (C) 2009-2013  Robert Finch
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
// ============================================================================
//
function carry;
	input op;
	input a;
	input b;
	input s;

	begin
		carry = op ? (~a&b)|(s&~a)|(s&b) : (a&b)|(a&~s)|(b&~s);
	end

endfunction

function overflow;
	input op;
	input a;
	input b;
	input s;

	begin
		overflow = (op ^ s ^ b) & (~op ^ a ^ b);
	end

endfunction

reg [15:0] alu_o;
reg [15:0] a;
reg [15:0] b;
wire amsb = w ? a[15] : a[7];
wire bmsb = w ? b[15] : b[7];
wire [15:0] as = {!a[15],a[14:0]};
wire [15:0] bs = {!b[15],b[14:0]};
wire signed [15:0] sa = a;
wire signed [15:0] sb = b;
wire signed [7:0] als = a[7:0];
wire signed [7:0] bls = b[7:0];
wire signed [15:0] p = als * bls;
wire signed [31:0] wp = sa * sb;
wire [15:0] p16 = a[7:0] * b[7:0];
wire [31:0] p32 = a * b;

// Compute AL/10
// - multiply by 1/10 = 26/256
wire [15:0] al26 = {al,4'b0} + {al,3'b0} + {al,1'b0};	// * 26
wire [7:0] aldv10 = al26[15:8];	// 256

wire [15:0] cmp_o = a - b;
wire eq  = a == b;
wire ltu = a < b;
wire lt  = as < bs;

wire [31:0] shlo = {16'h0000,b} << shftamt;
wire [31:0] shruo = {b,16'h0000} >> shftamt;
wire [15:0] shro = ~(~b >> shftamt);
wire [32:0] shlco = {16'h0000,b,cf} << shftamt;
wire [32:0] shrcuo = {cf,b,16'h0000} >> shftamt;

wire [15:0] shlo8 = {8'h00,b[7:0]} << shftamt;
wire [15:0] shruo8 = {b[7:0],8'h00} >> shftamt;
wire [ 7:0] shro8 = ~(~b[7:0] >> shftamt);
wire [16:0] shlco8 = {8'h00,b,cf} << shftamt;
wire [16:0] shrcuo8 = {cf,b[7:0],8'h00} >> shftamt;

wire div16_done;
wire div32_done;
wire [15:0] q16;
wire [7:0] r16;
wire [31:0] q32;
wire [15:0] r32;
wire [31:0] negdxax = -{dx,ax};

divr2 #(16) udiv1
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ld(ld_div16),
	.su(TTT[0]),
	.ri(1'b0),
	.a(ax),
	.b(b[7:0]),
	.i(8'h00),
	.q(q16),
	.r(r16),
	.divByZero(),
	.done(div16_done)
);


divr2 #(32) udiv2
(
	.rst(rst_i),
	.clk(clk_i),
	.ce(1'b1),
	.ld(ld_div32),
	.su(TTT[0]),
	.ri(1'b0),
	.a({dx,ax}),
	.b(b),
	.i(16'h0000),
	.q(q32),
	.r(r32),
	.divByZero(),
	.done(div32_done)
);


always @*	//(ir or ir2 or a or b or cf or af or al or ah or aldv10 or TTT)
	begin
		casex(ir)
		`MOV_M2AL,`MOV_M2AX,`LDS,`LES:
			alu_o <= a;
		`MOV_MR,`MOV_R2S,
		`MOV_RR8,`MOV_RR16,
		`MOV_I8M,`MOV_I16M,
		`MOV_I2AL,`MOV_I2DL,`MOV_I2CL,`MOV_I2BL,`MOV_I2AH,`MOV_I2DH,`MOV_I2CH,`MOV_I2BH,
		`MOV_I2AX,`MOV_I2DX,`MOV_I2CX,`MOV_I2BX,`MOV_I2SP,`MOV_I2BP,`MOV_I2SI,`MOV_I2DI:
			alu_o <= b;
		`XCHG_MEM:
			alu_o <= b;
		`ADD,`ADD_ALI8,`ADD_AXI16: alu_o <= a + b;
		`SUB,`SUB_ALI8,`SUB_AXI16: alu_o <= a - b;
		`ADC,`ADC_ALI8,`ADC_AXI16: alu_o <= a + b + cf;
		`SBB,`SBB_ALI8,`SBB_AXI16: alu_o <= a - b - cf;
		`AND,`AND_ALI8,`AND_AXI16: alu_o <= a & b;
		`TEST,`TEST_ALI8,`TEST_AXI16: alu_o <= a & b;
		`OR, `OR_ALI8, `OR_AXI16:  alu_o <= a | b;
		`XOR,`XOR_ALI8,`XOR_AXI16: alu_o <= a ^ b;
		`CMP,`CMP_ALI8,`CMP_AXI16: alu_o <= a - b;
		`SCASB,`SCASW,`CMPSB,`CMPSW: alu_o <= a - b;
		`INC_REG: alu_o <= a + 16'd1;
		`DEC_REG: alu_o <= a - 16'd1;
//		`IMUL: alu_o <= w ? p : wp[15:0];
		`ALU_I2R8:
			case(TTT)
			3'd0:	alu_o <= a + b;			// ADD
			3'd1:	alu_o <= a | b;			// OR
			3'd2:	alu_o <= a + b + cf;	// ADC
			3'd3:	alu_o <= a - b - cf;	// SBB
			3'd4:	alu_o <= a & b;			// AND
			3'd5:	alu_o <= a - b;			// SUB
			3'd6:	alu_o <= a ^ b;			// XOR
			default:	alu_o <= 16'h0000;
			endcase
		// ToDo: fix sign extension / extra immediate byte ?
		`ALU_I2R16:
			case(TTT)
			3'd0:	alu_o <= a + b;			// ADD
			3'd1:	alu_o <= a | b;			// OR
			3'd2:	alu_o <= a + b + cf;	// ADC
			3'd3:	alu_o <= a - b - cf;	// SBB
			3'd4:	alu_o <= a & b;			// AND
			3'd5:	alu_o <= a - b;			// SUB
			3'd6:	alu_o <= a ^ b;			// XOR
			default:	alu_o <= 16'h0000;
			endcase
		8'hF6,8'hF7:
			begin
			case(TTT)
			3'd0:	alu_o <= a & b;			// TEST
			3'd2:	alu_o <= ~b;			// NOT
			3'd3:	alu_o <= -b;			// NEG
			3'd4:	alu_o <= w ? p32[15:0] : p16;		// MUL
			3'd5:	alu_o <= w ? wp[15:0] : p[15:0];	// IMUL
			3'd6:	alu_o <= 16'h0000;		// DIV
			3'd7:	alu_o <= 16'h0000;		// IDIV
			default:	alu_o <= 16'h0000;
			endcase
			end
		`AAA:
			if (al[3:0]>4'h9 || af) begin
				alu_o[3:0] <= al[3:0] + 4'd6;
				alu_o[7:4] <= 4'h0;
				alu_o[15:8] <= ah + 8'd1;
			end
			else
				alu_o <= ax;
		`AAS:
			if (al[3:0]>4'h9 || af) begin
				alu_o[3:0] <= al[3:0] - 4'd6;
				alu_o[7:4] <= 4'h0;
				alu_o[15:8] <= ah - 8'd1;
			end
			else
				alu_o <= ax;
// ToDo: fix +1 carry
		`DAA:
			begin
				alu_o <= 16'h0000;
				if (al[3:0]>4'h9 || af) begin
					alu_o[3:0] <= al[3:0] + 4'd6;
				end
				if (al[7:4]>4'h9 || cf) begin
					alu_o[7:4] <= al[7:4] + 4'd6;
				end
			end
// ToDo: fix +1 carry
		`DAS:
			begin
				alu_o <= 16'h0000;
				if (al[3:0]>4'h9 || af) begin
					alu_o[3:0] <= al[3:0] - 4'd6;
				end
				if (al[7:4]>4'h9 || cf) begin
					alu_o[7:4] <= al[7:4] - 4'd6;
				end
			end

		`MORE1:
			casex(ir2)
			`AAM:
				begin
					alu_o[ 7:0] <= al - aldv10;
					alu_o[15:8] <= aldv10;
				end
			default:
				alu_o <= 16'h0000;
			endcase
		`MORE2:
			casex(ir2)
			`AAD:
				begin
					alu_o[ 7:0] <= {ah,3'b0} + {ah,1'b0} + al;
					alu_o[15:8] <= 8'h00;
				end
			default:
				alu_o <= 16'h0000;
			endcase
		default: alu_o <= 16'h0000;
		endcase
	end

assign pres = ~^alu_o[7:0];
assign reszw = alu_o==16'h0000;
assign reszb = alu_o[7:0]==8'h00;
assign resnb = alu_o[7];
assign resnw = alu_o[15];

assign resz = w ? reszw : reszb;
assign resn = w ? resnw : resnb;

