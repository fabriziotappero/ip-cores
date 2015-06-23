/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Double precision)                     ////
////                                                             ////
////  Author: David Lundgren                                     ////
////          davidklun@gmail.com                                ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2009 David Lundgren                           ////
////                  davidklun@gmail.com                        ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

// rmode = 00 (nearest), 01 (to zero), 10 (+ infinity), 11 (- infinity)

`timescale 1ns / 100ps

module fpu_mul( clk, rst, enable, rmode, opa, opb, ready, outfp);
input		clk;
input		rst;
input		enable;
input	[1:0]	rmode;
input	[63:0]	opa, opb;
output		ready; 
output  [63:0] outfp;


reg  	product_shift;
reg		[1:0] rm_1, rm_2, rm_3, rm_4, rm_5, rm_6, rm_7, rm_8, rm_9;
reg		[1:0] rm_10, rm_11, rm_12, rm_13, rm_14, rm_15;
reg   	sign, sign_1, sign_2, sign_3, sign_4, sign_5, sign_6, sign_7, sign_8;
reg   	sign_9, sign_10, sign_11, sign_12, sign_13, sign_14, sign_15, sign_16, sign_17;
reg	 	sign_18, sign_19, sign_20;
reg   [51:0] mantissa_a1, mantissa_a2;
reg   [51:0] mantissa_b1, mantissa_b2;
reg   [10:0] exponent_a;
reg   [10:0] exponent_b;
reg 	ready, count_ready, count_ready_0;
reg		[4:0] count;
reg		a_is_zero, b_is_zero, a_is_inf, b_is_inf, in_inf_1, in_inf_2; 
reg		in_zero_1;
reg   [11:0] exponent_terms_1, exponent_terms_2, exponent_terms_3, exponent_terms_4;
reg   [11:0] exponent_terms_5, exponent_terms_6, exponent_terms_7;
reg   [11:0] exponent_terms_8, exponent_terms_9;
reg    	exponent_gt_expoffset;
reg   [11:0] exponent_1;
wire   [11:0] exponent = 0;
reg   [11:0] exponent_2, exponent_2_0, exponent_2_1;
reg   	exponent_gt_prodshift, exponent_is_infinity;
reg   [11:0] exponent_3, exponent_4;
reg  	set_mantissa_zero, set_mz_1;
reg   [52:0] mul_a, mul_a1, mul_a2, mul_a3, mul_a4, mul_a5, mul_a6, mul_a7, mul_a8;
reg   [52:0] mul_b, mul_b1, mul_b2, mul_b3, mul_b4, mul_b5, mul_b6, mul_b7, mul_b8;
reg		[40:0] product_a;
reg		[16:0] product_a_2, product_a_3, product_a_4, product_a_5, product_a_6;
reg		[16:0] product_a_7, product_a_8, product_a_9, product_a_10;
reg		[40:0] product_b;
reg		[40:0] product_c;
reg		[25:0] product_d;
reg		[33:0] product_e;
reg		[33:0] product_f;
reg		[35:0] product_g;
reg		[28:0] product_h;
reg		[28:0] product_i;
reg		[30:0] product_j;
reg		[41:0] sum_0;
reg		[6:0] sum_0_2, sum_0_3, sum_0_4, sum_0_5, sum_0_6, sum_0_7, sum_0_8, sum_0_9;
reg		[35:0] sum_1; 
reg		[9:0] sum_1_2, sum_1_3, sum_1_4, sum_1_5, sum_1_6, sum_1_7, sum_1_8;
reg		[41:0] sum_2;
reg		[6:0] sum_2_2, sum_2_3, sum_2_4, sum_2_5, sum_2_6, sum_2_7;
reg		[35:0] sum_3;
reg		[36:0] sum_4;
reg		[9:0] sum_4_2, sum_4_3, sum_4_4, sum_4_5;
reg		[27:0] sum_5;
reg		[6:0] sum_5_2, sum_5_3, sum_5_4;
reg		[29:0] sum_6;
reg		[36:0] sum_7;
reg		[16:0] sum_7_2;
reg		[30:0] sum_8;
reg   	[105:0] product;
reg   	[105:0] product_1;
reg   	[52:0] product_2, product_3;
reg  	[53:0] product_4, product_5, product_6, product_7; 
reg		product_overflow;
reg  	[11:0] exponent_5, exponent_6, exponent_7, exponent_8, exponent_9;		
reg		round_nearest_mode, round_posinf_mode, round_neginf_mode;
reg		round_nearest_trigger, round_nearest_exception;
reg		round_nearest_enable, round_posinf_trigger, round_posinf_enable;
reg		round_neginf_trigger, round_neginf_enable, round_enable;
wire  	[63:0] outfp = { sign, exponent_9[10:0], product_7[51:0]};

always @(posedge clk) 
begin
	if (rst) begin
		sign <= 0; sign_1 <= 0; sign_2 <= 0; sign_3 <= 0; sign_4 <= 0;
		sign_5 <= 0; sign_6 <= 0; sign_7 <= 0; sign_8 <= 0; sign_9 <= 0;
		sign_10 <= 0; sign_11 <= 0; sign_12 <= 0; sign_13 <= 0; 
		sign_14 <= 0; sign_15 <= 0; sign_16 <= 0; sign_17 <= 0; sign_18 <= 0; sign_19 <= 0; 
		sign_20 <= 0; mantissa_a1 <= 0; mantissa_b1 <= 0; mantissa_a2 <= 0; mantissa_b2 <= 0;
		exponent_a <= 0; exponent_b <= 0; rm_1 <= 0; rm_2 <= 0; rm_3 <= 0; rm_4 <= 0; rm_5 <= 0; 
		rm_6 <= 0; rm_7 <= 0; rm_8 <= 0; rm_9 <= 0; rm_10 <= 0; rm_11 <= 0; 
		rm_12 <= 0; rm_13 <= 0; rm_14 <= 0; rm_15 <= 0; 
		a_is_zero <= 0; b_is_zero <= 0; a_is_inf <= 0; b_is_inf <= 0; in_inf_1 <= 0; in_inf_2 <= 0;
		in_zero_1 <= 0; exponent_terms_1 <= 0; exponent_terms_2 <= 0; exponent_terms_3 <= 0;
		exponent_terms_4 <= 0; exponent_terms_5 <= 0; exponent_terms_6 <= 0; exponent_terms_7 <= 0; 
		exponent_terms_8 <= 0; exponent_terms_9 <= 0; exponent_gt_expoffset <= 0; exponent_1 <= 0; 
		exponent_2_0 <= 0; exponent_2_1 <= 0; exponent_2 <= 0; exponent_gt_prodshift <= 0;
		exponent_is_infinity <= 0; exponent_3 <= 0; exponent_4 <= 0;
		set_mantissa_zero <= 0; set_mz_1 <= 0; mul_a <= 0; mul_b <= 0; mul_a1 <= 0; mul_b1 <= 0;  
		mul_a2 <= 0; mul_b2 <= 0; mul_a3 <= 0; mul_b3 <= 0; mul_a4 <= 0; mul_b4 <= 0;  mul_a5 <= 0; 
		mul_b5 <= 0; mul_a6 <= 0; mul_b6 <= 0; mul_a7 <= 0; mul_b7 <= 0;  mul_a8 <= 0; mul_b8 <= 0;
		product_a <= 0; product_a_2 <= 0; product_a_3 <= 0; product_a_4 <= 0; product_a_5 <= 0;
		product_a_6 <= 0; product_a_7 <= 0; product_a_8 <= 0; product_a_9 <= 0; product_a_10 <= 0;
		product_b <= 0; product_c <= 0; product_d <= 0; product_e <= 0; product_f <= 0;
		product_g <= 0; product_h <= 0; product_i <= 0; product_j <= 0;
		sum_0 <= 0; sum_0_2 <= 0; sum_0_3 <= 0; sum_0_4 <= 0; sum_0_5 <= 0; sum_0_6 <= 0; 
		sum_0_7 <= 0; sum_0_8 <= 0; sum_0_9 <= 0; sum_1 <= 0; sum_1_2 <= 0; sum_1_3 <= 0; sum_1_4 <= 0; 
		sum_1_5 <= 0; sum_1_6 <= 0; sum_1_7 <= 0; sum_1_8 <= 0; sum_2 <= 0; sum_2_2 <= 0; sum_2_3 <= 0; 
		sum_2_4 <= 0; sum_2_5 <= 0; sum_2_6 <= 0; sum_2_7 <= 0; sum_3 <= 0; sum_4 <= 0; sum_4_2 <= 0; 
		sum_4_3 <= 0; sum_4_4 <= 0; sum_4_5 <= 0; sum_5 <= 0; sum_5_2 <= 0; sum_5_3 <= 0; sum_5_4 <= 0;
		sum_6 <= 0; sum_7 <= 0; sum_7_2 <= 0; sum_8 <= 0; product <= 0; product_1 <= 0; product_2 <= 0; 
		product_3 <= 0; product_4 <= 0; product_5 <= 0; product_overflow <= 0; product_6 <= 0; 
		exponent_5 <= 0; exponent_6 <= 0; exponent_7 <= 0; exponent_8 <= 0; product_shift <= 0;
		product_7 <= 0; exponent_9 <= 0;
		round_nearest_mode <= 0; round_posinf_mode <= 0; round_neginf_mode <= 0; round_nearest_trigger <= 0; 
		round_nearest_exception <= 0; round_nearest_enable <= 0; round_posinf_trigger <= 0; round_posinf_enable <= 0;
		round_neginf_trigger <= 0; round_neginf_enable <= 0; round_enable <= 0;
	end
	else if (enable) begin
		sign_1 <= opa[63] ^ opb[63]; sign_2 <= sign_1; sign_3 <= sign_2; sign_4 <= sign_3;
		sign_5 <= sign_4; sign_6 <= sign_5; sign_7 <= sign_6; sign_8 <= sign_7; sign_9 <= sign_8;
		sign_10 <= sign_9; sign_11 <= sign_10; sign_12 <= sign_11; sign_13 <= sign_12;
		sign_14 <= sign_13; sign_15 <= sign_14; sign_16 <= sign_15; sign_17 <= sign_16; 
		sign_18 <= sign_17; sign_19 <= sign_18; sign_20 <= sign_19; sign <= sign_20;
		mantissa_a1 <= opa[51:0]; mantissa_b1 <= opb[51:0]; mantissa_a2 <= mantissa_a1;
		mantissa_b2 <= mantissa_b1; exponent_a <= opa[62:52]; exponent_b <= opb[62:52];
		rm_1 <= rmode; rm_2 <= rm_1; rm_3 <= rm_2; rm_4 <= rm_3; 
		rm_5 <= rm_4; rm_6 <= rm_5; rm_7 <= rm_6; rm_8 <= rm_7; rm_9 <= rm_8; 
		rm_10 <= rm_9; rm_11 <= rm_10; rm_12 <= rm_11; rm_13 <= rm_12; rm_14 <= rm_13;
		rm_15 <= rm_14; 
		a_is_zero <= !(|exponent_a); b_is_zero <= !(|exponent_b);
		a_is_inf <= exponent_a == 2047; b_is_inf <= exponent_b == 2047;
		in_inf_1 <= a_is_inf | b_is_inf; in_inf_2 <= in_inf_1;
		in_zero_1 <= a_is_zero | b_is_zero;
		exponent_terms_1 <= exponent_a + exponent_b;
		exponent_terms_2 <= exponent_terms_1;
		exponent_terms_3 <= in_zero_1 ? 12'b0 : exponent_terms_2;
		exponent_terms_4 <= in_inf_2 ? 12'b110000000000 : exponent_terms_3;
		exponent_terms_5 <= exponent_terms_4; exponent_terms_6 <= exponent_terms_5;
		exponent_terms_7 <= exponent_terms_6; exponent_terms_8 <= exponent_terms_7;
		exponent_terms_9 <= exponent_terms_8;
		exponent_gt_expoffset <= exponent_terms_9 > 1022;
		exponent_1 <= exponent_terms_9 - 1022; 
		exponent_2_0 <= exponent_gt_expoffset ? exponent_1 : exponent;
		exponent_2_1 <= exponent_2_0;
		exponent_2 <= exponent_2_1; 
		exponent_is_infinity <= (exponent_3 > 2046) & exponent_gt_prodshift;
		exponent_3 <= exponent_2 - product_shift;
		exponent_gt_prodshift <= exponent_2 >= product_shift;
		exponent_4 <= exponent_gt_prodshift ? exponent_3 : exponent;
		exponent_5 <= exponent_is_infinity ? 12'b011111111111 : exponent_4;
		set_mantissa_zero <= exponent_4 == 0 | exponent_is_infinity;
		set_mz_1 <= set_mantissa_zero;
		exponent_6 <= exponent_5;
		mul_a <= { !a_is_zero, mantissa_a2 }; mul_b <= { !b_is_zero, mantissa_b2 };
		mul_a1 <= mul_a; mul_b1 <= mul_b;
		mul_a2 <= mul_a1; mul_b2 <= mul_b1; mul_a3 <= mul_a2; mul_b3 <= mul_b2;
		mul_a4 <= mul_a3; mul_b4 <= mul_b3; mul_a5 <= mul_a4; mul_b5 <= mul_b4;
		mul_a6 <= mul_a5; mul_b6 <= mul_b5; mul_a7 <= mul_a6; mul_b7 <= mul_b6;
		mul_a8 <= mul_a7; mul_b8 <= mul_b7; 
		product_a <= mul_a[23:0] * mul_b[16:0]; product_a_2 <= product_a[16:0];
		product_a_3 <= product_a_2; product_a_4 <= product_a_3; product_a_5 <= product_a_4;
		product_a_6 <= product_a_5; product_a_7 <= product_a_6; product_a_8 <= product_a_7;
		product_a_9 <= product_a_8; product_a_10 <= product_a_9;
		product_b <= mul_a[23:0] * mul_b[33:17];
		product_c <= mul_a2[23:0] * mul_b2[50:34];
		product_d <= mul_a5[23:0] * mul_b5[52:51];
		product_e <= mul_a1[40:24] * mul_b1[16:0];
		product_f <= mul_a4[40:24] * mul_b4[33:17];
		product_g <= mul_a7[40:24] * mul_b7[52:34];
		product_h <= mul_a3[52:41] * mul_b3[16:0];
		product_i <= mul_a6[52:41] * mul_b6[33:17];
		product_j <= mul_a8[52:41] * mul_b8[52:34];
		sum_0 <= product_a[40:17] + product_b; sum_0_2 <= sum_0[6:0]; sum_0_3 <= sum_0_2;
		sum_0_4 <= sum_0_3; sum_0_5 <= sum_0_4; sum_0_6 <= sum_0_5; sum_0_7 <= sum_0_6;
		sum_0_8 <= sum_0_7; sum_0_9 <= sum_0_8; 
		sum_1 <= sum_0[41:7] + product_e; sum_1_2 <= sum_1[9:0]; sum_1_3 <= sum_1_2;
		sum_1_4 <= sum_1_3; sum_1_5 <= sum_1_4; sum_1_6 <= sum_1_5; sum_1_7 <= sum_1_6;
		sum_1_8 <= sum_1_7; 
		sum_2 <= sum_1[35:10] + product_c; sum_2_2 <= sum_2[6:0]; sum_2_3 <= sum_2_2;
		sum_2_4 <= sum_2_3; sum_2_5 <= sum_2_4; sum_2_6 <= sum_2_5; sum_2_7 <= sum_2_6;
		sum_3 <= sum_2[41:7] + product_h;
		sum_4 <= sum_3 + product_f; sum_4_2 <= sum_4[9:0]; sum_4_3 <= sum_4_2; 
		sum_4_4 <= sum_4_3; sum_4_5 <= sum_4_4; 
		sum_5 <= sum_4[36:10] + product_d; sum_5_2 <= sum_5[6:0]; 
		sum_5_3 <= sum_5_2; sum_5_4 <= sum_5_3;
		sum_6 <= sum_5[27:7] + product_i;
		sum_7 <= sum_6 + product_g; sum_7_2 <= sum_7[16:0];
		sum_8 <= sum_7[36:17] + product_j;
		product <= { sum_8, sum_7_2[16:0], sum_5_4[6:0], sum_4_5[9:0], sum_2_7[6:0],
					sum_1_8[9:0], sum_0_9[6:0], product_a_10[16:0] };
		product_1 <= product << product_shift;
		product_2 <= product_1[105:53]; product_3 <= product_2;
		product_4 <= set_mantissa_zero ? 54'b0 : { 1'b0, product_3};
		product_shift <= !sum_8[30]; 
		round_nearest_mode <= rm_15 == 2'b00;
		round_posinf_mode <= rm_15 == 2'b10;
		round_neginf_mode <= rm_15 == 2'b11;
		round_nearest_trigger <= product_1[52];
		round_nearest_exception <= !(|product_1[51:0]) & (product_1[53] == 0);
		round_nearest_enable <= round_nearest_mode & round_nearest_trigger & !round_nearest_exception;
		round_posinf_trigger <= |product_1[52:0] & !sign_15;
		round_posinf_enable <= round_posinf_mode & round_posinf_trigger;
		round_neginf_trigger <= |product_1[52:0] & sign_15;
		round_neginf_enable <= round_neginf_mode & round_neginf_trigger;
		round_enable <= round_posinf_enable | round_neginf_enable | round_nearest_enable;
		product_5 <= round_enable & !set_mz_1 ? product_4 + 1 : product_4;
		product_overflow <= product_5[53];
		product_6 <= product_5;
		product_7 <= product_overflow ? product_6 >> 1 : product_6;
		exponent_7 <= exponent_6; exponent_8 <= exponent_7;
		exponent_9 <= product_overflow ? exponent_8 + 1 : exponent_8;  
	end
end

always @(posedge clk) 
begin
	if (rst) begin
		ready <= 0;
		count_ready_0 <= 0;
		count_ready  <= 0;
	end
	else if (enable) begin
		ready <= count_ready;
		count_ready_0 <= count == 18;
		count_ready <= count == 19;
	end
end

always @(posedge clk) 
begin
	if (rst) 
		count <= 0;
	else if (enable & !count_ready_0 & !count_ready) 
		count <= count + 1;
end

endmodule
