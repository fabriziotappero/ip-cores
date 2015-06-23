//                              -*- Mode: Verilog -*-
// Filename        : oks8_decoder.v
// Description     : OKS8 Decoder & Controller with Microcode
// Author          : Jian Li
// Created On      : Sat Jan 07 09:09:49 2006
// Last Modified By: .
// Last Modified On: .
// Update Count    : 0
// Status          : Unknown, Use with caution!

/*
 * Copyright (C) 2006 to Jian Li
 * Contact: kongzilee@yahoo.com.cn
 * 
 * This source file may be used and distributed without restriction
 * provided that this copyright statement is not removed from the file
 * and that any derivative works contain the original copyright notice
 * and the associated disclaimer.
 * 
 * THIS SOFTWARE IS PROVIDE "AS IS" AND WITHOUT ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
 * MERCHANTIBILITY AND FITNESS FOR A PARTICULAR PURPOSE. IN NO EVENT
 * SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
 * INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
 * BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 * LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
 * ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

`include "oks8_defines.v"

//////////////////////////////////////////////////////

module oks8_decoder (/*AUTOARG*/
  // Inputs
  clk_i, rst_i, op_i, en_i,
  // Outputs
  dp_o,
  fin_o,
  dx_den,
  dx_alu,
  dx_sts,
  dx_r1, dx_r1_t,
  dx_r2, dx_r2_t,
  dx_r3
  );

// Inputs
input clk_i, rst_i, en_i;
input [7:0] op_i;

// Outputs
output [1:0] dp_o;
output fin_o;
output dx_den;
output [3:0] dx_alu;
output [1:0] dx_sts;
output [7:0] dx_r1;
output [2:0] dx_r1_t;
output [7:0] dx_r2;
output [2:0] dx_r2_t;
output [15:0] dx_r3;

// =====================================================================
// REGISTER/WIRE DECLARATIONS
// =====================================================================
wire [1:0] next;
reg [1:0] nextf;
reg state;
wire fin_o;

reg [7:0] op, r1, r2;
reg [15:0] r3;

wire [3:0] r1_p, r2_p, x_p;
wire [7:0] r2_im;

// OPCODE FLAGS
wire f_idle,	// 1 byte
	f_stop,
	f_di,
	f_ei,
	f_ret,
	f_iret,
	f_rcf,
	f_scf,
	f_ccf,
	f_nop,
	f_inc_rE,

	f_dec,		// 2 bytes
	f_rlc,
	f_inc,
	f_jp_2,
	f_pop,
	f_com,
	f_push,
	f_rl,
	f_clr,
	f_rrc,
	f_sra,
	f_rr,
	
	f_add_2,
	f_adc_2,
	f_sub_2,
	f_sbc_2,
	f_or_2,
	f_and_2,
	f_tcm_2,
	f_tm_2,
	f_cp_2,
	f_xor_2,

	f_ldc_C3,
	f_ldc_D3,
	f_ld_C7,
	f_ld_D7,
	f_ldcx,
	f_call_F4,
	f_ld_r8,
	f_ld_r9,
	f_ld_rC,
	f_jr_ccB,

	f_add_3,	// 3 bytes
	f_adc_3,
	f_sub_3,
	f_sbc_3,
	f_or_3,
	f_and_3,
	f_tcm_3,
	f_tm_3,
	f_cp_3,
	f_xor_3,
	
	f_ld_87,
	f_ld_97,
	f_ld_D6,
	f_ld_E4,
	f_ld_E5,
	f_ld_E6,
	f_ldc_E7,
	f_ld_F5,
	f_call_F6,
	f_ldc_F7,
	f_jp_ccD,

	f_ldc_A7,	// 4 bytes
	f_ldc_B7,

	f_op_0,		// OPCODE = X0/X1
	f_op_1,		// OPCODE = X2/X3
	f_op_2;		// OPCODE = X4/X5/X6

assign f_op_0	= (op[3:1] == 3'b000);
assign f_op_1	= (op[3:1] == 3'b001);
assign f_op_2	= (op[3:2] == 2'b01 && op[1:0] != 2'b11);

// =====================================================================
// CONTROL FLAGS
// Flags depending on OPCODE. Only 1 Flag will be active.
// =====================================================================
assign f_idle	= (op == 8'h6F);
assign f_stop	= (op == 8'h7F);
assign f_di		= (op == 8'h8F);
assign f_ei		= (op == 8'h9F);
assign f_ret	= (op == 8'hAF);
assign f_iret	= (op == 8'hBF);
assign f_rcf	= (op == 8'hCF);
assign f_scf	= (op == 8'hDF);
assign f_ccf	= (op == 8'hEF);
assign f_nop	= (op == 8'hFF);
assign f_inc_rE	= (op[3:0] == 4'hE);

assign f_dec	= (op[7:4] == 4'h0 && f_op_0);
assign f_rlc	= (op[7:4] == 4'h1 && f_op_0);
assign f_inc	= (op[7:4] == 4'h2 && f_op_0);
assign f_jp_2	= (op == 8'h30);
assign f_pop	= (op[7:4] == 4'h5 && f_op_0);
assign f_com	= (op[7:4] == 4'h6 && f_op_0);
assign f_push	= (op[7:4] == 4'h7 && f_op_0);
assign f_rl		= (op[7:4] == 4'h9 && f_op_0);
assign f_clr	= (op[7:4] == 4'hB && f_op_0);
assign f_rrc	= (op[7:4] == 4'hC && f_op_0);
assign f_sra	= (op[7:4] == 4'hD && f_op_0);
assign f_rr 	= (op[7:4] == 4'hE && f_op_0);

assign f_add_2	= (op[7:4] == 4'h0 && f_op_1);
assign f_adc_2	= (op[7:4] == 4'h1 && f_op_1);
assign f_sub_2	= (op[7:4] == 4'h2 && f_op_1);
assign f_sbc_2	= (op[7:4] == 4'h3 && f_op_1);
assign f_or_2	= (op[7:4] == 4'h4 && f_op_1);
assign f_and_2	= (op[7:4] == 4'h5 && f_op_1);
assign f_tcm_2	= (op[7:4] == 4'h6 && f_op_1);
assign f_tm_2	= (op[7:4] == 4'h7 && f_op_1);
assign f_cp_2	= (op[7:4] == 4'hA && f_op_1);
assign f_xor_2	= (op[7:4] == 4'hB && f_op_1);

assign f_ldc_C3	= (op == 8'hC3);
assign f_ldc_D3	= (op == 8'hD3);
assign f_ld_C7	= (op == 8'hC7);
assign f_ld_D7	= (op == 8'hD7);
assign f_ldcx	= (op[7:4] == 4'hE && f_op_1);
assign f_call_F4	= (op == 8'hF4);
assign f_ld_r8	= (op[3:0] == 4'h8);
assign f_ld_r9	= (op[3:0] == 4'h9);
assign f_ld_rC	= (op[3:0] == 4'hC);
assign f_jr_ccB	= (op[3:0] == 4'hB);

assign f_add_3	= (op[7:4] == 4'h0 && f_op_2);
assign f_adc_3	= (op[7:4] == 4'h1 && f_op_2);
assign f_sub_3	= (op[7:4] == 4'h2 && f_op_2);
assign f_sbc_3	= (op[7:4] == 4'h3 && f_op_2);
assign f_or_3	= (op[7:4] == 4'h4 && f_op_2);
assign f_and_3	= (op[7:4] == 4'h5 && f_op_2);
assign f_tcm_3	= (op[7:4] == 4'h6 && f_op_2);
assign f_tm_3	= (op[7:4] == 4'h7 && f_op_2);
assign f_cp_3	= (op[7:4] == 4'hA && f_op_2);
assign f_xor_3	= (op[7:4] == 4'hB && f_op_2);

assign f_ld_87	= (op == 8'h87);
assign f_ld_97	= (op == 8'h97);
assign f_ld_D6	= (op == 8'hD6);
assign f_ld_E4	= (op == 8'hE4);
assign f_ld_E5	= (op == 8'hE5);
assign f_ld_E6	= (op == 8'hE6);
assign f_ldc_E7	= (op == 8'hE7);
assign f_ld_F5	= (op == 8'hF5);
assign f_call_F6	= (op == 8'hF6);
assign f_ldc_F7	= (op == 8'hF7);
assign f_jp_ccD	= (op[3:0] == 4'hD);

assign f_ldc_A7	= (op == 8'hA7);
assign f_ldc_B7	= (op == 8'hB7);

assign next = (f_ldc_A7 | f_ldc_B7) ? 4 : (
	f_add_3 | f_adc_3 | f_sub_3 | f_sbc_3 | f_or_3 | f_and_3 |
	f_tcm_3 | f_tm_3 | f_cp_3 | f_xor_3 | f_ld_87 | f_ld_97 |
	f_ld_D6 | f_ld_E4 | f_ld_E5 | f_ld_E6 | f_ldc_E7 | f_ld_F5 |
	f_call_F6 | f_ldc_F7 | f_jp_ccD) ? 3 : (
	f_dec | f_rlc | f_inc | f_jp_2 | f_pop | f_com | f_push | f_rl | f_clr |
	f_rrc | f_sra | f_rr | f_add_2 | f_adc_2 | f_sub_2 | f_sbc_2 | f_or_2 |
	f_and_2 | f_tcm_2 | f_tm_2 | f_cp_2 | f_xor_2 | f_ldc_C3 | f_ldc_D3 |
	f_ld_C7 | f_ld_D7 | f_ldcx | f_call_F4 | f_ld_r8 | f_ld_r9 | f_ld_rC |
	f_jr_ccB) ? 2 : 1;

// =====================================================================
// SYSTEM INTERFACE
// Indicate here is finish.
// =====================================================================
assign fin_o = (en_i) && (next == nextf);

// =====================================================================
// POWER INTERFACE
// CONTROL SIGNALS FOR POWER INTERFACE
// =====================================================================
assign dp_o[1] = f_stop;
assign dp_o[0] = f_idle | f_stop;

// =====================================================================
// EXECUTE INTERFACE
// CONTROL SIGNALS FOR THE EXECUTE INTERFACE
// =====================================================================
   
//
// OPERAND CONTROL -> EXEC
// Determines where the SRC and DST operands come from
// Determines where to store the DST operand.
//
assign dx_r1_t = (f_jp_ccD) ? `DST_DA :
(	f_dec | f_rlc | f_inc | f_pop | f_com |
	f_rl | f_clr | f_rrc | f_sra | f_rr) ? ((op[0] == 0) ? `DST_R : `DST_IR) :
(	f_add_2 | f_adc_2 | f_sub_2 | f_sbc_2 | f_or_2 | f_and_2 |
	f_xor_2 | f_add_3 | f_adc_3 | f_sub_3 | f_sbc_3 | f_or_3 | f_and_3 |
	f_xor_3 | f_inc_rE | f_ld_rC | f_ld_r8 | f_ld_C7 | f_ld_87 |
	f_ldc_A7 | f_ldc_C3 | f_ldc_E7 | f_ldcx | f_ld_r9 | f_ld_E4 | f_ld_E5 | f_ld_E6) ? `DST_R :
(	f_cp_2 | f_tcm_2 | f_tm_2 | f_cp_3 | f_tcm_3 | f_tm_3 | f_rcf | f_scf | f_ccf | f_ei | f_di) ? `DST_R2 :
(	f_ld_F5 | f_ld_D7 | f_ld_D6 | f_ld_97) ? `DST_IR :
(	f_ldc_D3 | f_ldc_F7 | f_jp_2) ? `DST_IRR :
(	f_ldc_B7) ? ((dx_r1[3:1] == 3'b000) ? `DST_DA : `DST_IRR) :
(	f_push) ? `DST_PUSH : (f_call_F4 | f_call_F6) ? `DST_CALL : `DST_NON;

assign dx_r2_t = 
(	f_add_2 | f_adc_2 | f_sub_2 | f_sbc_2 | f_or_2 | f_and_2 | f_tcm_2 | f_tm_2 |
	f_cp_2 | f_xor_2 | f_push) ? ((op[0]) ? `SRC_IR : `SRC_R) :
(	f_add_3 | f_adc_3 | f_sub_3 | f_sbc_3 | f_or_3 | f_and_3 |
	f_tcm_3 | f_tm_3 | f_cp_3 | f_xor_3) ? 
	((op[2] & op[1]) ? `SRC_IM : ((op[0]) ? `SRC_IR : `SRC_R)) :
(	f_ld_E5 | f_ld_87 | f_ld_C7 | f_nop) ? `SRC_IR :
(	f_ld_97 | f_ld_D7  | f_ld_r9 | f_ldc_D3 |
	f_ldc_F7 | f_ldc_B7 | f_ld_E4 | f_ld_F5 | f_ld_r8) ? `SRC_R :
(	f_ldc_C3 | f_ldc_E7 | f_ldcx) ? `SRC_IRR :
(	f_ldc_A7) ? ((dx_r2[3:1] == 3'b000) ? `SRC_IRR : `SRC_DA) :
(	f_call_F4) ? `SRC_IRR :  (f_call_F6) ? `SRC_DA :
(	f_ret) ? `SRC_RET : (f_pop) ? `SRC_POP : (f_iret) ? `SRC_IRET : `SRC_IM;

//
// Determines the content of SRC, DST, x, XS, XL etc.
//
assign dx_r1 = (r1_p[1:0] == 2'b00) ? ((f_rcf | f_scf | f_ccf) ? `V_FLAGS :
	(f_di | f_ei) ? `V_SYM :
	((r1_p[2] == 0) ? {4'hC, op[3:0]} : {4'hC, op[7:4]})) : r1;

assign r2_im = (f_rcf) ? 8'h7F : (f_scf | f_ccf) ? 8'h80 :
	(f_dec | f_inc | f_com) ? 8'hFF : (f_jp_2) ? 8'h08 :
	(f_ei) ? 8'h04 : (f_di) ? 8'hFB : 8'h00;

assign dx_r2 = (r2_p[1:0] == 2'b00) ?
	(r2_p[3] ? {4'hC, op[7:4]} : r2_im) : r2;

assign dx_r3 = (f_ldcx) ? ((op[0]) ? 16'h0001 : 16'hFFFF) : r3;

//
// Determines access external data memory
//
assign dx_den = (f_ldc_C3 | f_ldc_E7 | f_ldcx | f_ldc_A7) ? dx_r2[0] :
	(f_ldc_D3 | f_ldc_F7 | f_ldc_B7) ? dx_r1[0] : 1'b0;

//
// STATUS AFFECTED -> EXEC
// Tell EXEC to affect changes to the STATUS flags or not.
//
assign dx_sts = (dx_alu[3] || (dx_alu == `ALU_SRA)) ?
	((f_dec | f_inc | f_inc_rE) ? `STS_ZSV : `STS_ALL) :
	(dx_alu[2] && !(op[3:0] == 4'hF)) ? `STS_ZS0 : `STS_NON;

// 
// ALU OP -> EXEC
// Determines the exact Operation to perform
//
assign dx_alu = (f_adc_2 | f_adc_3) ? `ALU_ADC :
	(f_add_2 | f_add_3 | f_dec) ? `ALU_ADD :
	(f_and_2 | f_and_3 | f_clr | f_di | f_rcf | f_tm_2 | f_tm_3) ? `ALU_AND :
	(f_jp_2 | f_jp_ccD | f_jr_ccB) ? `ALU_JP :
	(f_ldcx) ? `ALU_LDCX :
	(f_or_2 | f_or_3 | f_ei | f_scf) ? `ALU_IOR :
	(f_rl) ? `ALU_RL : (f_rlc) ? `ALU_RLC :
	(f_rr) ? `ALU_RR : (f_rrc) ? `ALU_RRC :
	(f_sbc_2 | f_sbc_3) ? `ALU_SBC : (f_sra) ? `ALU_SRA :
	(f_sub_2 | f_sub_3 | f_inc | f_inc_rE | f_cp_2 | f_cp_3) ? `ALU_SUB :
	(f_tcm_2 | f_tcm_3) ? `ALU_TCM :
	(f_xor_2 | f_xor_3 | f_ccf | f_com) ? `ALU_XOR : `ALU_NON;


// =====================================================================
// INTERNAL FLAGS
// Determines the position of SRC and DST operands
// =====================================================================
assign r1_p = (f_dec | f_rlc | f_inc | f_jp_2 | f_pop | f_com | f_rl |
	f_clr | f_rrc | f_sra | f_rr | f_ld_r9 | f_ld_E6 | f_ld_D6 | f_jr_ccB) ? 4'b0001 :	// 8, 1
(	f_add_3 | f_adc_3 | f_sub_3 | f_sbc_3 | f_or_3 | f_and_3 |
	f_tcm_3 | f_tm_3 | f_cp_3 | f_xor_3) ? ((op[1]) ? 4'b0001 : 4'b0010) :	// 8, 1 or 2
(	f_add_2 | f_adc_2 | f_sub_2 | f_sbc_2 | f_or_2 | f_and_2 |
	f_tcm_2 | f_tm_2 | f_cp_2 | f_xor_2 | f_ld_C7 | f_ld_D7 | f_ld_87 |
	f_ldc_C3 | f_ldc_E7 | f_ldc_A7 | f_ldcx) ? 4'b1101 :	// 4h, 1
(	f_ld_E4 | f_ld_E5 | f_ld_F5) ? 4'b0010 :		// 8, 2
(	f_ld_97 | f_ldc_D3 | f_ldc_F7 | f_ldc_B7) ? 4'b1001 :	// 4l, 1
	4'b1100;

assign r2_p = (f_push | f_ld_rC | f_ld_r8 | f_ld_E4 | f_ld_E5 |
	f_ld_F5 | f_call_F4) ? 4'b0001 :	// 8, 1
(	f_add_3 | f_adc_3 | f_sub_3 | f_sbc_3 | f_or_3 | f_and_3 |
	f_tcm_3 | f_tm_3 | f_cp_3 | f_xor_3) ? ((op[1]) ? 4'b0010 : 4'b0001) :	// 8, 1 or 2
(	f_add_2 | f_adc_2 | f_sub_2 | f_sbc_2 | f_or_2 | f_and_2 |
	f_tcm_2 | f_tm_2 | f_cp_2 | f_xor_2 | f_ld_C7 | f_ld_D7 | f_ld_87 |
	f_ldc_C3 | f_ldc_E7 | f_ldc_A7 | f_ldcx) ? 4'b1001 :		// 4l, 1
(	f_ld_97) ? 4'b1101:		// 4h, 1
(	f_ld_r9 | f_jp_ccD | f_jr_ccB) ? 4'b1100 :		// 4h, 0
(	f_ld_E6 | f_ld_D6) ? 4'b0010 :		// 8, 2
	4'b0000;

//
// Determines the position of x, XS, XL etc.
//
assign x_p = (f_call_F6 | f_jp_ccD) ? 4'b0110 : 4'bZZZZ;	// such as: 6D 01 53
assign x_p = (f_ld_87 | f_ld_97 | f_ldc_E7 | f_ldc_F7) ? 4'b0010 : 4'bZZZZ;
assign x_p = (f_ldc_A7 | f_ldc_B7) ? 4'b1110 : 4'bZZZZ;		// such as: A7 00 04 11
assign x_p = (f_ldc_C3 | f_ldc_D3) ? 4'b0000 : 4'bZZZZ;

///////////////////////////////////////////////////////

always @(posedge en_i)
begin
  r1 <= 8'h00;
  r2 <= 8'h00;
  r3 <= 16'h0000;
end

always @(posedge clk_i)
begin
  if (rst_i || (!en_i)) begin
	nextf <= 2'b01;
	state <= 0;
  end else
  if (!state)
  begin
	op <= op_i;
	nextf <= 2'b01;
	state <= 1;
  end
  else
  begin
	if (r1_p[1:0] == nextf) begin
	  if (r1_p[3] == 0)
		r1 <= op_i;
	  else begin
		if (r1_p[2] == 0)
		  r1 <= {4'hC, op_i[3:0]};
		else
		  r1 <= {4'hC, op_i[7:4]};
	  end
	end
	
	if (r2_p[1:0] == nextf) begin
	  if (r2_p[3] == 0)
		r2 <= op_i;
	  else begin
		if (r2_p[2] == 0)
		  r2 <= {4'hC, op_i[3:0]};
		else
		  r2 <= {4'hC, op_i[7:4]};
	  end
	end
	
	if (x_p[1:0] == nextf) begin
	  r3[7:0] <= op_i;
	end
	if (x_p[3:2] == nextf) begin
	  r3[15:8] <= op_i;
	end
	
	nextf <= nextf + 1'b1;

  end

end	 // always @(posedge clk_i)

endmodule	// oks8_decoder

