/* 
 * (c) 2013 Alejandro Paz
 *
 *
 * An alu core
 *
 * ADD, ADC, DAA, SUB, SBC, COM, NEG, CMP, ASR, ASL, ROR, ROL, RCR, RCL
 *
 *
 *
 */
`include "defs.v"


module alu(
	input wire clk_in,
	input wire [15:0] a_in,
	input wire [15:0] b_in,
	input wire [7:0] CCR, /* condition code register */
	input wire [4:0] opcode_in, /* ALU opcode */
	input wire sz_in, /* size, low 8 bit, high 16 bit */
	output reg [15:0] q_out, /* ALU result */
	output reg [7:0] CCRo
	);

wire [7:0] ccr8_out, q8_out;
wire [15:0] q16_out;
wire [3:0] ccr16_out;
wire [15:0] q16_mul;
reg [15:0] ra_in, rb_in;
reg [4:0] rop_in;
    
mul8x8 mulu(clk_in, a_in[7:0], b_in[7:0], q16_mul);
alu8 alu8(clk_in, ra_in[7:0], rb_in[7:0], CCR, rop_in, q8_out, ccr8_out);
alu16 alu16(clk_in, ra_in, rb_in, CCR, rop_in, q16_mul, q16_out, ccr16_out);

always @(posedge clk_in)
	begin
		ra_in <= a_in;
		rb_in <= b_in;
		rop_in <= opcode_in;
	end

always @(*)
	begin
		if (sz_in)
			begin
				q_out = q16_out;
				CCRo = { CCR[7:4], ccr16_out };
			end
		else
			begin
				q_out = { 8'h0, q8_out };
				CCRo = ccr8_out;
			end
	end
	

endmodule
/**
 * Simple 3 functions logic
 *
 */
module logic8(
	input wire [7:0] a_in,
	input wire [7:0] b_in,
	input wire [1:0] opcode_in, /* ALU opcode */
	output reg [7:0] q_out /* ALU result */
	);

always @(*)
	begin
		case (opcode_in)
			2'b00: q_out = b_in;
			2'b01: q_out = a_in & b_in;
			2'b10: q_out = a_in | b_in;
			2'b11: q_out = a_in ^ b_in;
		endcase
	end

endmodule

/**
 * Simple ADD/SUB module
 *
 */
module arith8(
	input wire [7:0] a_in,
	input wire [7:0] b_in,
	input wire carry_in, /* condition code register */
	input wire half_c_in,
	input wire [1:0] opcode_in, /* ALU opcode */
	output reg [7:0] q_out, /* ALU result */
	output reg carry_out, 
	output reg overflow_out,
	output reg half_c_out
	);

wire carry;
assign carry = opcode_in[1] ? carry_in:1'b0;
always @(*)
	begin
		case (opcode_in[0])
			1'b0: { carry_out, q_out } = { 1'b0, a_in } + { 1'b0, b_in } + { 8'h0, carry }; // ADD/ADC
			1'b1: { carry_out, q_out } = { 1'b0, a_in } - { 1'b0, b_in } - { 8'h0, carry }; // SUB/SBC
		endcase
	end

always @(*)
	begin
		case (opcode_in[0])
			1'b0: overflow_out = (a_in[7] & b_in[7] & (~q_out[7])) | ((~a_in[7]) & (~b_in[7]) & q_out[7]);
			1'b1: overflow_out = (a_in[7] & (~b_in[7]) & (~q_out[7])) | ((~a_in[7]) & b_in[7] & q_out[7]);
		endcase
	end

always @(*)
	begin
		case (opcode_in[0])
			1'b0: half_c_out = (a_in[4] ^ b_in[4] ^ q_out[4]);
			1'b1: half_c_out = half_c_in;
		endcase
	end

endmodule

/**
 * Simple ADD/SUB module
 *
 */
module arith16(
	input wire [15:0] a_in,
	input wire [15:0] b_in,
	input wire carry_in, /* condition code register */
	input wire [1:0] opcode_in, /* ALU opcode */
	output reg [15:0] q_out, /* ALU result */
	output reg carry_out, 
	output reg overflow_out
	);
always @(*)
	begin
		case (opcode_in)
			2'b00: { carry_out, q_out } = { 1'b0, a_in } + { 1'b0, b_in }; // ADD
			2'b01: { carry_out, q_out } = { 1'b0, a_in } - { 1'b0, b_in }; // SUB
			2'b10: { carry_out, q_out } = { 1'b0, a_in } + { 1'b0, b_in } + { 8'h0, carry_in }; // ADC
			2'b11: { carry_out, q_out } = { 1'b0, a_in } - { 1'b0, b_in } - { 8'h0, carry_in }; // SBC
		endcase
	end

always @(*)
	begin
		case (opcode_in)
			2'b00, 2'b10: overflow_out = (a_in[15] & b_in[15] & (~q_out[15])) | ((~a_in[15]) & (~b_in[15]) & q_out[15]);
			2'b01, 2'b11: overflow_out = (a_in[15] & (~b_in[15]) & (~q_out[15])) | ((~a_in[15]) & b_in[15] & q_out[15]);
		endcase
	end

endmodule

module shift8(
	input wire [7:0] a_in,
	input wire [7:0] b_in,
	input wire carry_in, /* condition code register */
	input wire overflow_in, /* condition code register */
	input wire [2:0] opcode_in, /* ALU opcode */
	output reg [7:0] q_out, /* ALU result */
	output wire carry_out,
	output reg overflow_out
	);

always @(*)
	begin
		q_out = { a_in[7], a_in[7:1] }; // ASR
		case (opcode_in)
			3'b000: q_out = { 1'b0, a_in[7:1] }; // LSR
			3'b001: q_out = { a_in[6:0], 1'b0 }; // LSL
			3'b010: q_out = { carry_in, a_in[7:1] }; // ROR
			3'b011: q_out = { a_in[6:0], carry_in }; // ROL
			3'b100: q_out = { a_in[7], a_in[7:1] }; // ASR
		endcase
	end

always @(*)
	begin
		overflow_out = overflow_in;
		case (opcode_in)
			3'b000: overflow_out = overflow_in; // LSR
			3'b001: overflow_out = a_in[7] ^ a_in[6]; // LSL
			3'b010: overflow_out = overflow_in; // ROR
			3'b011: overflow_out = a_in[7] ^ a_in[6]; // ROL
			3'b100: overflow_out = overflow_in; // ASR
		endcase
	end

assign carry_out = opcode_in[0] ? a_in[7]:a_in[0];

endmodule


module alu8(
	input wire clk_in,
	input wire [7:0] a_in,
	input wire [7:0] b_in,
	input wire [7:0] CCR, /* condition code register */
	input wire [4:0] opcode_in, /* ALU opcode */
	output reg [7:0] q_out, /* ALU result */
	output reg [7:0] CCRo
	);

wire c_in, n_in, v_in, z_in, h_in;
assign c_in = CCR[0]; /* carry flag */
assign n_in = CCR[3]; /* neg flag */
assign v_in = CCR[1]; /* overflow flag */
assign z_in = CCR[2]; /* zero flag */
assign h_in = CCR[5]; /* halb-carry flag */

wire [7:0] com8_r, neg8_r, daa_p0_r;
wire [3:0] daa8h_r;

wire [7:0] com8_w, neg8_w;

wire ccom8_r, cneg8_r, cdaa8_r;

wire vcom8_r, vneg8_r;

assign com8_w = ~a_in[7:0];
assign neg8_w = 8'h0 - a_in[7:0];
		// COM
assign com8_r = com8_w;
assign ccom8_r = com8_w != 8'h0 ? 1'b1:1'b0;
assign vcom8_r = 1'b0;
		// NEG
assign neg8_r = neg8_w;
assign cneg8_r = neg8_w[7] | neg8_w[6] | neg8_w[5] | neg8_w[4] | neg8_w[3] | neg8_w[2] | neg8_w[1] | neg8_w[0];
assign vneg8_r = neg8_w[7] & (~neg8_w[6]) & (~neg8_w[5]) & (~neg8_w[4]) & (~neg8_w[3]) & (~neg8_w[2]) & (~neg8_w[1]) & (~neg8_w[0]);

reg c8, h8, v8;
reg [7:0] q8;
		
wire [7:0] logic_q, arith_q, shift_q;
wire arith_c, arith_v, arith_h;
wire shift_c, shift_v;

reg [7:0] alu8_b_in;

always @(*)
	begin
        alu8_b_in = b_in[7:0];
        case (opcode_in)
            `INC, `DEC: alu8_b_in = 8'h01;
            `CLR: alu8_b_in = 8'h0;
        endcase
    end
    logic8 l8(a_in, b_in, opcode_in[1:0], logic_q);
arith8 a8(a_in, alu8_b_in, c_in, h_in, opcode_in[1:0], arith_q, arith_c, arith_v, arith_h);
shift8 s8(a_in, b_in, c_in, v_in, opcode_in[2:0], shift_q, shift_c, shift_v);
		// DAA
assign daa_p0_r = ((a_in[3:0] > 4'h9) | h_in ) ? a_in[7:0] + 8'h6:a_in[7:0];
assign { cdaa8_r, daa8h_r } = ((daa_p0_r[7:4] > 9) || (c_in == 1'b1)) ? { 1'b0, daa_p0_r[7:4] } + 5'h6:{ 1'b0, daa_p0_r[7:4] };

always @(*)
	begin
		q8 = 8'h0;
		c8 = c_in;
		h8 = h_in;
		v8 = v_in;
		case (opcode_in)
			`SEXT:
				begin
					q8 = a_in[7] ? 8'hff:8'h00;
				end
			`ADD, `ADC, `SUB, `SBC:
				begin
					q8 = arith_q;
					c8 = arith_c;
					v8 = arith_v;
					h8 = arith_h;
				end
			`DEC, `INC:
				begin
					q8 = arith_q;
					v8 = arith_v;
				end
			`COM:
				begin
					q8 = com8_r;
					c8 = com8_r;
					v8 = vcom8_r;
				end
			`NEG:
				begin
					q8 = neg8_r;
					c8 = cneg8_r;
					v8 = vneg8_r;
				end
			`LSR, `LSL, `ROL, `ROR,`ASR:
				begin
					q8 = shift_q;
					c8 = shift_c;
					v8 = shift_v;
				end
			`AND, `OR, `EOR, `LD:
				begin
					q8 = logic_q;
					v8 = 1'b0;
					end
			`TST:
				begin
					q8 = a_in;
					v8 = 1'b0;
					end
			`DAA:
				begin // V is undefined, so we don't touch it
					q8 = { daa8h_r, daa_p0_r[3:0] };
					c8 = cdaa8_r;
				end
			`ST:
				begin
					q8 = a_in[7:0];
				end
		endcase
	end
/*
reg [7:0] regq8;
// register before second mux 
always @(posedge clk_in)
	begin
		regq8 <= q8;
	end
*/
always @(*)
	begin
		q_out[7:0] = q8; //regq8;
        //          e, f   h    i       n      z            v   c
		CCRo = { CCR[7:6], h8, CCR[4], q8[7], (q8 == 8'h0), v8, c8 };
	end

initial
	begin
	end
endmodule

/* ALU for 16 bit operations */
module alu16(
	input wire clk_in,
	input wire [15:0] a_in,
	input wire [15:0] b_in,
	input wire [7:0] CCR, /* condition code register */
	input wire [4:0] opcode_in, /* ALU opcode */
	input wire [15:0] q_mul_in,
	output reg [15:0] q_out, /* ALU result */
	output reg [3:0] CCRo
	);

wire c_in, n_in, v_in, z_in;
assign c_in = CCR[0]; /* carry flag */
assign n_in = CCR[3]; /* neg flag */
assign v_in = CCR[1]; /* overflow flag */
assign z_in = CCR[2]; /* zero flag */

`ifdef HD6309
wire [15:0] com16_r, neg16_r;
wire [15:0] asr16_r, shr16_r, shl16_r, ror16_r, rol16_r, and16_r, or16_r, eor16_r;

wire [15:0] com16_w, neg16_w;
wire [15:0] asr16_w, shr16_w, shl16_w, ror16_w, rol16_w, and16_w, or16_w, eor16_w;

wire ccom16_r, cneg16_r;
wire casr16_r, cshr16_r, cshl16_r, cror16_r, crol16_r, cand16_r;

wire vadd16_r, vadc16_r, vsub16_r, vsbc16_r, vcom16_r, vneg16_r;
wire vasr16_r, vshr16_r, vshl16_r, vror16_r, vrol16_r, vand16_r;

assign com16_w = ~a_in[15:0];
assign neg16_w = 16'h0 - a_in[15:0];
assign asr16_w = { a_in[15], a_in[15:1] };
assign shr16_w = { 1'b0, a_in[15:1] };
assign shl16_w = { a_in[14:0], 1'b0 };
assign ror16_w = { c_in, a_in[15:1] };
assign rol16_w = { a_in[14:0], c_in };
assign and16_w = a_in[15:0] & b_in[15:0];
assign or16_w = a_in[15:0] | b_in[15:0];
assign eor16_w = a_in[15:0] ^ b_in[15:0];

// COM
assign com16_r = com16_w;
assign ccom16_r = com16_w != 16'h0 ? 1'b1:1'b0;
assign vcom16_r = 1'b0;
		// NEG
assign neg16_r = neg16_w;
assign vneg16_r = neg16_w[15] & (~neg16_w[14]) & (~neg16_w[13]) & (~neg16_w[12]) & (~neg16_w[11]) & (~neg16_w[10]) & (~neg16_w[9]) & (~neg16_w[8]) & (~neg16_w[7]) & (~neg16_w[6]) & (~neg16_w[5]) & (~neg16_w[4]) & (~neg16_w[3]) & (~neg16_w[2]) & (~neg16_w[1]) & (~neg16_w[0]);
assign cneg16_r = neg16_w[15] | neg16_w[14] | neg16_w[13] | neg16_w[12] | neg16_w[11] | neg16_w[10] | neg16_w[9] & neg16_w[8] | neg16_w[7] | neg16_w[6] | neg16_w[5] | neg16_w[4] | neg16_w[3] | neg16_w[2] | neg16_w[1] | neg16_w[0];
		// ASR
assign asr16_r = asr16_w;
assign casr16_r = a_in[0];
assign vasr16_r = a_in[0] ^ asr16_w[15];
		// SHR
assign shr16_r = shr16_w;
assign cshr16_r = a_in[0];
assign vshr16_r = a_in[0] ^ shr16_w[15];
		// SHL
assign shl16_r = shl16_w;
assign cshl16_r = a_in[15];
assign vshl16_r = a_in[15] ^ shl16_w[15];
		// ROR
assign ror16_r = ror16_w;
assign cror16_r = a_in[0];
assign vror16_r = a_in[0] ^ ror16_w[15];
		// ROL
assign rol16_r = rol16_w;
assign crol16_r = a_in[15];
assign vrol16_r = a_in[15] ^ rol16_w[15];
		// AND
assign and16_r = and16_w;
assign cand16_r = c_in;
assign vand16_r = 1'b0;
		// OR
assign or16_r = or16_w;
		// EOR
assign eor16_r = eor16_w;
`endif

reg c16, n16, v16, z16;
reg [15:0] q16;
		
wire [15:0] arith_q;
wire arith_c, arith_v;

arith16 a16(a_in, b_in, c_in, opcode_in[1:0], arith_q, arith_c, arith_v);

always @(*)
	begin
		q16 = 16'h0;
		c16 = c_in;
		v16 = v_in;
		case (opcode_in)
			`ADD, `ADC, `SUB, `SBC:
				begin
					q16 = arith_q;
					c16 = arith_c;
					v16 = arith_v;
				end
`ifdef HD6309
			`COM:
				begin
					q16 = com16_r;
					c16 = ccom16_r;
					v16 = vcom16_r;
				end
			`NEG:
				begin
					q16 = neg16_r;
					c16 = cneg16_r;
					v16 = vneg16_r;
				end
			`ASR:
				begin
					q16 = asr16_r;
					c16 = casr16_r;
					v16 = vasr16_r;
				end
			`LSR:
				begin
					q16 = shr16_r;
					c16 = cshr16_r;
					v16 = vshr16_r;
				end
			`LSL:
				begin
					q16 = shl16_r;
					c16 = cshl16_r;
					v16 = vshl16_r;
				end
			`ROR:
				begin
					q16 = ror16_r;
					c16 = cror16_r;
					v16 = vror16_r;
				end
			`ROL:
				begin
					q16 = rol16_r;
					c16 = crol16_r;
					v16 = vrol16_r;
				end
			`AND:
				begin
					q16 = and16_r;
					c16 = cand16_r;
					v16 = vand16_r;
					end
			`OR:
				begin
					q16 = or16_r;
					c16 = cand16_r;
					v16 = vand16_r;
				end
			`EOR:
				begin
					q16 = eor16_r;
					c16 = cand16_r;
					v16 = vand16_r;
				end
`endif
			`MUL:
				begin
					q16 = q_mul_in;
					c16 = q_mul_in[7];
				end
			`LD:
				begin
					v16 = 0;
					q16 = b_in[15:0];
				end
			`ST:
				begin
					q16 = a_in[15:0];
				end
			`SEXT: // sign extend
				begin
					q16 = { b_in[7] ? 8'hff:8'h00, b_in[7:0] };
				end
			`LEA:
				begin
					q16 = a_in[15:0];
				end			
		endcase
	end

reg reg_n_in, reg_z_in;
/* register before second mux */
always @(posedge clk_in)
	begin
		reg_n_in <= n_in;
		reg_z_in <= z_in;
	end

/* Negative & zero flags */	
always @(*)
	begin
		n16 = q16[15];
		z16 = q16 == 16'h0;
		case (opcode_in)
			`ADD:
				begin
				end
			`ADC:
				begin
				end
			`SUB: // for CMP no register result is written back
				begin
				end
			`SBC:
				begin
				end
			`COM:
				begin
				end
			`NEG:
				begin
				end
			`ASR:
				begin
				end
			`LSR:
				begin
				end
			`LSL:
				begin
				end
			`ROR:
				begin
				end
			`ROL:
				begin
				end
			`AND:
				begin
				end
			`OR:
				begin
				end
			`EOR:
				begin
				end
			`MUL:
				begin
					n16 = reg_n_in;
				end
			`LD:
				begin
				end
			`ST:
				begin
				end
			`SEXT: // sign extend
				begin
					n16 = reg_n_in;
					z16 = reg_z_in;
				end
			`LEA: // only Z will be affected
				begin
					n16 = reg_n_in;
				end
		endcase
	end


always @(*)
	begin
		q_out = q16;
		CCRo = { n16, z16, v16, c16 };
	end

endmodule

module mul8x8(
	input wire clk_in,
	input wire [7:0] a,
	input wire [7:0] b,
	output wire [15:0] q
	);

reg [15:0] pipe0, pipe1;//, pipe2, pipe3;
assign q = pipe1;

always @(posedge clk_in)
	begin
		pipe0 <= (a[0] ? {8'h0, b}:16'h0) + (a[1] ? { 7'h0, b, 1'h0}:16'h0) + 
		         (a[2] ? {6'h0, b, 2'h0}:16'h0) + (a[3] ? { 5'h0, b, 3'h0}:16'h0);
		pipe1 <= (a[4] ? {4'h0, b, 4'h0}:16'h0) + (a[5] ? { 3'h0, b, 5'h0}:16'h0) + 
		         (a[6] ? {2'h0, b, 6'h0}:16'h0) + (a[7] ? { 1'h0, b, 7'h0}:16'h0) + pipe0;
		/*
		pipe0 <= (a[0] ? {8'h0, b}:16'h0) + (a[1] ? { 7'h0, b, 1'h0}:16'h0);
		pipe1 <= (a[2] ? {6'h0, b, 2'h0}:16'h0) + (a[3] ? { 5'h0, b, 3'h0}:16'h0) + pipe0;
		pipe2 <= (a[4] ? {4'h0, b, 4'h0}:16'h0) + (a[5] ? { 3'h0, b, 5'h0}:16'h0) + pipe1;
		pipe3 <= (a[6] ? {2'h0, b, 6'h0}:16'h0) + (a[7] ? { 1'h0, b, 7'h0}:16'h0) + pipe2;
		*/
	end
	
endmodule
