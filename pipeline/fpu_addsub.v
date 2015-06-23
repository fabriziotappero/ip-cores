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

// fpu_op, add = 0, subtract = 1
// rmode = 00 (nearest), 01 (to zero), 10 (+ infinity), 11 (- infinity)

`timescale 1ns / 100ps

module fpu_addsub( clk, rst, enable, fpu_op, rmode, opa, opb, out, ready);
input		clk;
input		rst;
input		enable;
input		fpu_op;
input		[1:0] rmode;
input		[63:0]	opa, opb;
output		[63:0]	out;
output		ready;



reg 	[63:0]	outfp, out;
reg		[1:0] rm_1, rm_2, rm_3, rm_4, rm_5, rm_6, rm_7, rm_8, rm_9;
reg		[1:0] rm_10, rm_11, rm_12, rm_13, rm_14, rm_15, rm_16;
reg   	sign, sign_a, sign_b, fpu_op_1, fpu_op_2, fpu_op_3, fpu_op_final;
reg		fpuf_2, fpuf_3, fpuf_4, fpuf_5, fpuf_6, fpuf_7, fpuf_8, fpuf_9, fpuf_10;
reg		fpuf_11, fpuf_12, fpuf_13, fpuf_14, fpuf_15, fpuf_16;
reg		fpuf_17, fpuf_18, fpuf_19, fpuf_20, fpuf_21;
reg		sign_a2, sign_a3, sign_b2, sign_b3, sign_2, sign_3, sign_4, sign_5, sign_6; 
reg		sign_7, sign_8, sign_9, sign_10, sign_11, sign_12; 
reg		sign_13, sign_14, sign_15, sign_16, sign_17, sign_18, sign_19; 
reg   	[10:0] exponent_a, exponent_b, expa_2, expb_2, expa_3, expb_3;
reg   	[51:0] mantissa_a, mantissa_b, mana_2, mana_3, manb_2, manb_3;
reg		expa_et_inf, expb_et_inf, input_is_inf, in_inf2, in_inf3, in_inf4, in_inf5;
reg		in_inf6, in_inf7, in_inf8, in_inf9, in_inf10, in_inf11, in_inf12, in_inf13;
reg   	in_inf14, in_inf15, in_inf16, in_inf17, in_inf18, in_inf19, in_inf20; 
reg		in_inf21, expa_gt_expb, expa_et_expb, mana_gtet_manb, a_gtet_b;
reg   	[10:0] exponent_small, exponent_large, expl_2, expl_3, expl_4;
reg   	[10:0] expl_5, expl_6, expl_7, expl_8, expl_9, expl_10, expl_11;
reg   	[51:0] mantissa_small, mantissa_large;
reg   	[51:0] mantissa_small_2, mantissa_large_2;
reg   	[51:0] mantissa_small_3, mantissa_large_3;
reg		exp_small_et0, exp_large_et0, exp_small_et0_2, exp_large_et0_2;
reg 	[10:0] exponent_diff, exponent_diff_2, exponent_diff_3;
reg		[107:0] bits_shifted_out, bits_shifted_out_2; 
reg		bits_shifted;
reg  	[55:0] large_add, large_add_2, large_add_3, small_add;
reg		[55:0] small_shift, small_shift_2, small_shift_3, small_shift_4;
reg  	[55:0] large_add_4, large_add_5;
reg   	small_shift_nonzero;
reg		small_is_nonzero, small_is_nonzero_2, small_is_nonzero_3; 
reg   	small_fraction_enable;
wire    [55:0] small_shift_LSB = { 55'b0, 1'b1 };
reg   	[55:0] sum, sum_2, sum_3, sum_4, sum_5;
reg   	[55:0] sum_6, sum_7, sum_8, sum_9, sum_10, sum_11;
reg   	sum_overflow, sumround_overflow, sum_lsb, sum_lsb_2; 
reg   	[10:0] exponent_add, exp_add_2, exponent_sub, exp_sub_2;
reg   	[10:0] exp_sub_3, exp_sub_4, exp_sub_5, exp_sub_6, exp_sub_7;
reg   	[10:0] exp_sub_8, exp_add_3, exp_add_4, exp_add_5, exp_add_6;
reg   	[10:0] exp_add_7, exp_add_8, exp_add_9;
reg 	[5:0] 	diff_shift, diff_shift_2;
reg		[55:0] diff, diff_2, diff_3, diff_4, diff_5;  
reg		[55:0] diff_6, diff_7, diff_8, diff_9, diff_10, diff_11;
reg		diffshift_gt_exponent, diffshift_et_55, diffround_overflow;
reg		round_nearest_mode, round_posinf_mode, round_neginf_mode;
reg		round_nearest_trigger, round_nearest_exception;
reg		round_nearest_enable, round_posinf_trigger, round_posinf_enable;
reg		round_neginf_trigger, round_neginf_enable, round_enable;
reg 	ready, count_ready, count_ready_0;
reg		[4:0] count;

always @(posedge clk) 
	begin
		if (rst) begin
			fpu_op_1 <= 0; fpu_op_final <= 0; fpu_op_2 <= 0;
			fpu_op_3 <= 0; fpuf_2 <= 0; fpuf_3 <= 0; fpuf_4 <= 0;
			fpuf_5 <= 0; fpuf_6 <= 0; fpuf_7 <= 0; fpuf_8 <= 0; fpuf_9 <= 0; 
			fpuf_10 <= 0; fpuf_11 <= 0; fpuf_12 <= 0; fpuf_13 <= 0; fpuf_14 <= 0;  
			fpuf_15 <= 0; fpuf_16 <= 0; fpuf_17 <= 0; fpuf_18 <= 0; fpuf_19 <= 0;
			fpuf_20 <= 0; fpuf_21 <= 0; 
			rm_1 <= 0; rm_2 <= 0; rm_3 <= 0; rm_4 <= 0; rm_5 <= 0; 
			rm_6 <= 0; rm_7 <= 0; rm_8 <= 0; rm_9 <= 0; rm_10 <= 0; rm_11 <= 0; 
			rm_12 <= 0; rm_13 <= 0; rm_14 <= 0; rm_15 <= 0; rm_16 <= 0; sign_a <= 0; 
			sign_b <= 0; sign_a2 <= 0; sign_b2 <= 0; sign_a3 <= 0; sign_b3 <= 0; 
			exponent_a <= 0; exponent_b <= 0; expa_2 <= 0; expa_3 <= 0;
			expb_2 <= 0; expb_3 <= 0; mantissa_a <= 0; mantissa_b <= 0; mana_2 <= 0; mana_3 <= 0;
			manb_2 <= 0; manb_3 <= 0; expa_et_inf <= 0; expb_et_inf <= 0;
			input_is_inf <= 0; in_inf2 <= 0; in_inf3 <= 0; in_inf4 <= 0; in_inf5 <= 0; 
			in_inf6 <= 0; in_inf7 <= 0; in_inf8 <= 0; in_inf9 <= 0; in_inf10 <= 0;
			in_inf11 <= 0; in_inf12 <= 0; in_inf13 <= 0; in_inf14 <= 0; in_inf15 <= 0;
			in_inf16 <= 0; in_inf17 <= 0; in_inf18 <= 0; in_inf19 <= 0; in_inf20 <= 0;
			in_inf21 <= 0; expa_gt_expb <= 0; expa_et_expb <= 0; mana_gtet_manb <= 0;
   			a_gtet_b <= 0; sign <= 0; sign_2 <= 0; sign_3 <= 0; sign_4 <= 0; sign_5 <= 0;
   			sign_6 <= 0; sign_7 <= 0; sign_8 <= 0; sign_9 <= 0;
   			sign_10 <= 0; sign_11 <= 0; sign_12 <= 0; sign_13 <= 0; sign_14 <= 0;
   			sign_15 <= 0; sign_16 <= 0; sign_17 <= 0; sign_18 <= 0; sign_19 <= 0;
			exponent_small  <= 0; exponent_large  <= 0; expl_2 <= 0;
			expl_3 <= 0; expl_4 <= 0; expl_5 <= 0; expl_6 <= 0; expl_7 <= 0;
			expl_8 <= 0; expl_9 <= 0; expl_10 <= 0; expl_11 <= 0;
			exp_small_et0 <= 0; exp_large_et0 <= 0;
   			exp_small_et0_2 <= 0; exp_large_et0_2 <= 0;
			mantissa_small  <= 0; mantissa_large  <= 0;
			mantissa_small_2 <= 0; mantissa_large_2 <= 0;
			mantissa_small_3 <= 0; mantissa_large_3 <= 0;
			exponent_diff <= 0; exponent_diff_2 <= 0; exponent_diff_3 <= 0;
			bits_shifted_out <= 0;
			bits_shifted_out_2 <= 0; bits_shifted <= 0;
			large_add <= 0; large_add_2 <= 0;
			large_add_3 <= 0; large_add_4 <= 0; large_add_5 <= 0; small_add <= 0;
			small_shift <= 0; small_shift_2 <= 0; small_shift_3 <= 0; 
			small_shift_4 <= 0; small_shift_nonzero <= 0;
			small_is_nonzero <= 0; small_is_nonzero_2 <= 0; small_is_nonzero_3 <= 0;
			small_fraction_enable <= 0;
			sum <= 0; sum_2 <= 0; sum_overflow <= 0; sum_3 <= 0; sum_4 <= 0;
			sum_5 <= 0; sum_6 <= 0; sum_7 <= 0; sum_8 <= 0; sum_9 <= 0; sum_10 <= 0; 
			sum_11 <= 0; sumround_overflow <= 0;	sum_lsb <= 0; sum_lsb_2 <= 0;
			exponent_add <= 0; exp_add_2 <= 0; exp_add_3 <= 0;  exp_add_4 <= 0; 
			exp_add_5 <= 0;  exp_add_6 <= 0; exp_add_7 <= 0; exp_add_8 <= 0;
			exp_add_9 <= 0; diff_shift_2 <= 0; diff <= 0;
			diffshift_gt_exponent <= 0; diffshift_et_55 <= 0; diff_2 <= 0;
			diff_3 <= 0; diff_4 <= 0; diff_5 <= 0; diff_6 <= 0; diff_7 <= 0; diff_8 <= 0;
			diff_9 <= 0; diff_10 <= 0; 
			diff_11 <= 0; diffround_overflow <= 0; exponent_sub <= 0; 
			exp_sub_2 <= 0; exp_sub_3 <= 0; exp_sub_4 <= 0; exp_sub_5 <= 0;
			exp_sub_6 <= 0; exp_sub_7 <= 0; exp_sub_8 <= 0; outfp <= 0; 
			round_nearest_mode <= 0; round_posinf_mode <= 0; round_neginf_mode <= 0; round_nearest_trigger <= 0; 
			round_nearest_exception <= 0; round_nearest_enable <= 0; round_posinf_trigger <= 0; round_posinf_enable <= 0;
			round_neginf_trigger <= 0; round_neginf_enable <= 0; round_enable <= 0;
		end
		else if (enable) begin
			fpu_op_1 <= fpu_op; fpu_op_final <= fpu_op_1 ^ (sign_a ^ sign_b);
			fpuf_2 <= fpu_op_final; fpuf_3 <= fpuf_2; fpuf_4 <= fpuf_3;
			fpuf_5 <= fpuf_4; fpuf_6 <= fpuf_5; fpuf_7 <= fpuf_6; fpuf_8 <= fpuf_7; 
			fpuf_9 <= fpuf_8; fpuf_10 <= fpuf_9; fpuf_11 <= fpuf_10; fpuf_12 <= fpuf_11; 
			fpuf_13 <= fpuf_12; fpuf_14 <= fpuf_13; fpuf_15 <= fpuf_14; 
			fpuf_16 <= fpuf_15; fpuf_17 <= fpuf_16; fpuf_18 <= fpuf_17;
			fpuf_19 <= fpuf_18; fpuf_20 <= fpuf_19; fpuf_21 <= fpuf_20;
			fpu_op_2 <= fpu_op_1; fpu_op_3 <= fpu_op_2;
			rm_1 <= rmode; rm_2 <= rm_1; rm_3 <= rm_2; rm_4 <= rm_3; 
			rm_5 <= rm_4; rm_6 <= rm_5; rm_7 <= rm_6; rm_8 <= rm_7; rm_9 <= rm_8; 
			rm_10 <= rm_9; rm_11 <= rm_10; rm_12 <= rm_11; rm_13 <= rm_12; 
			rm_14 <= rm_13; rm_15 <= rm_14; rm_16 <= rm_15;
			sign_a <= opa[63]; sign_b <= opb[63]; sign_a2 <= sign_a;
			sign_b2 <= sign_b; sign_a3 <= sign_a2; sign_b3 <= sign_b2;
			exponent_a <= opa[62:52]; expa_2 <= exponent_a; expa_3 <= expa_2;
			exponent_b <= opb[62:52]; expb_2 <= exponent_b; expb_3 <= expb_2;
			mantissa_a <= opa[51:0]; mana_2 <= mantissa_a; mana_3 <= mana_2;
			mantissa_b <= opb[51:0]; manb_2 <= mantissa_b; manb_3 <= manb_2;
			expa_et_inf <= exponent_a == 2047;
			expb_et_inf <= exponent_b == 2047;
			input_is_inf <= expa_et_inf | expb_et_inf; in_inf2 <= input_is_inf;
			in_inf3 <= in_inf2; in_inf4 <= in_inf3; in_inf5 <= in_inf4; in_inf6 <= in_inf5;
			in_inf7 <= in_inf6; in_inf8 <= in_inf7; in_inf9 <= in_inf8; in_inf10 <= in_inf9;
			in_inf11 <= in_inf10; in_inf12 <= in_inf11; in_inf13 <= in_inf12; 
			in_inf14 <= in_inf13; in_inf15 <= in_inf14; in_inf16 <= in_inf15;
			in_inf17 <= in_inf16; in_inf18 <= in_inf17; in_inf19 <= in_inf18;
			in_inf20 <= in_inf19; in_inf21 <= in_inf20;
			expa_gt_expb <= exponent_a > exponent_b;
			expa_et_expb <= exponent_a == exponent_b;
			mana_gtet_manb <= mantissa_a >= mantissa_b;
   			a_gtet_b <= expa_gt_expb | (expa_et_expb & mana_gtet_manb);
   			sign <= a_gtet_b ? sign_a3 :!sign_b3 ^ (fpu_op_3 == 0);
   			sign_2 <= sign; sign_3 <= sign_2; sign_4 <= sign_3; sign_5 <= sign_4;
   			sign_6 <= sign_5; sign_7 <= sign_6; sign_8 <= sign_7; sign_9 <= sign_8;
   			sign_10 <= sign_9; sign_11 <= sign_10; sign_12 <= sign_11;
   			sign_13 <= sign_12; sign_14 <= sign_13; sign_15 <= sign_14;
   			sign_16 <= sign_15; sign_17 <= sign_16; sign_18 <= sign_17;
   			sign_19 <= sign_18;
   			exponent_small  <= a_gtet_b ? expb_3 : expa_3;
   			exponent_large  <= a_gtet_b ? expa_3 : expb_3; 
   			expl_2 <= exponent_large; expl_3 <= expl_2; expl_4 <= expl_3;
   			expl_5 <= expl_4; expl_6 <= expl_5; expl_7 <= expl_6; expl_8 <= expl_7;
   			expl_9 <= expl_8; expl_10 <= expl_9; expl_11 <= expl_10;
   			exp_small_et0 <= exponent_small == 0;
   			exp_large_et0 <= exponent_large == 0;
   			exp_small_et0_2 <= exp_small_et0;
   			exp_large_et0_2 <= exp_large_et0;
  			mantissa_small  <= a_gtet_b ? manb_3 : mana_3;
   			mantissa_large  <= a_gtet_b ? mana_3 : manb_3;
   			mantissa_small_2 <= mantissa_small;
   			mantissa_large_2 <= mantissa_large;
   			mantissa_small_3 <= exp_small_et0 ? 0 : mantissa_small_2;
   			mantissa_large_3 <= exp_large_et0 ? 0 : mantissa_large_2;
			exponent_diff <= exponent_large - exponent_small;
			exponent_diff_2 <= exponent_diff;
			exponent_diff_3 <= exponent_diff_2;
			bits_shifted_out <= exp_small_et0 ? 108'b0 : { 1'b1, mantissa_small_2, 55'b0 };
			bits_shifted_out_2 <= bits_shifted_out >> exponent_diff_2;
			bits_shifted <= |bits_shifted_out_2[52:0];
			large_add <= { 1'b0, !exp_large_et0_2, mantissa_large_3, 2'b0};
			large_add_2 <= large_add; large_add_3 <= large_add_2;
			large_add_4 <= large_add_3; large_add_5 <= large_add_4;
			small_add <= { 1'b0, !exp_small_et0_2, mantissa_small_3, 2'b0};
			small_shift <= small_add >> exponent_diff_3; 
			small_shift_2 <= { small_shift[55:1], (bits_shifted | small_shift[0]) }; 
			small_shift_3 <= small_shift_2; 
			small_fraction_enable <= small_is_nonzero_3 & !small_shift_nonzero;
			small_shift_4 <= small_fraction_enable ? small_shift_LSB : small_shift_3;
			small_shift_nonzero <= |small_shift[54:0];
			small_is_nonzero <= !exp_small_et0_2;
			small_is_nonzero_2 <= small_is_nonzero; small_is_nonzero_3 <= small_is_nonzero_2;
			sum <= large_add_5 + small_shift_4;
			sum_overflow <= sum[55];
			sum_2 <= sum; sum_lsb <= sum[0]; 
			sum_3 <= sum_overflow ? sum_2 >> 1 : sum_2; sum_lsb_2 <= sum_lsb;
			sum_4 <= { sum_3[55:1], sum_lsb_2 | sum_3[0] };
			sum_5 <= sum_4; sum_6 <= sum_5; sum_7 <= sum_6; sum_8 <= sum_7;
			exponent_add <= sum_overflow ? expl_10 + 1: expl_10;
			exp_add_2 <= exponent_add; 
			diff_shift_2 <= diff_shift;
			diff <= large_add_5 - small_shift_4; diff_2 <= diff; diff_3 <= diff_2;
			diffshift_gt_exponent <= diff_shift > expl_10;
			diffshift_et_55 <= diff_shift_2 == 55; 
			diff_4 <= diffshift_gt_exponent ? diff_3 << expl_11 : diff_3 << diff_shift_2;
			diff_5 <= diff_4; diff_6 <= diff_5; diff_7 <= diff_6; diff_8 <= diff_7;
			exponent_sub <= diffshift_gt_exponent ? 0 : (expl_11 - diff_shift_2);
			exp_sub_2 <= diffshift_et_55 ? 0 : exponent_sub;
			round_nearest_mode <= rm_16 == 2'b00;
			round_posinf_mode <= rm_16 == 2'b10;
			round_neginf_mode <= rm_16 == 2'b11;
			round_nearest_trigger <= fpuf_15 ? diff_5[1] : sum_5[1];
			round_nearest_exception <= fpuf_15 ? !diff_5[0] & !diff_5[2] : !sum_5[0] & !sum_5[2];
			round_nearest_enable <= round_nearest_mode & round_nearest_trigger & !round_nearest_exception;
			round_posinf_trigger <= fpuf_15 ? |diff_5[1:0] & !sign_13 : |sum_5[1:0] & !sign_13;
			round_posinf_enable <= round_posinf_mode & round_posinf_trigger;
			round_neginf_trigger <= fpuf_15 ? |diff_5[1:0] & sign_13 : |sum_5[1:0] & sign_13;
			round_neginf_enable <= round_neginf_mode & round_neginf_trigger;
			round_enable <= round_posinf_enable | round_neginf_enable | round_nearest_enable;
			sum_9 <= round_enable ? sum_8 + 4 : sum_8;
			sumround_overflow <= sum_9[55]; sum_10 <= sum_9;
			sum_11 <= sumround_overflow ? sum_10 >> 1 : sum_10;
			diff_9 <= round_enable ? diff_8 + 4 : diff_8;
			diffround_overflow <= diff_9[55]; diff_10 <= diff_9;
			diff_11 <= diffround_overflow ? diff_10 >> 1 : diff_10;
			exp_add_3 <= exp_add_2; exp_add_4 <= exp_add_3; exp_add_5 <= exp_add_4;
			exp_add_6 <= exp_add_5; exp_add_7 <= exp_add_6; exp_add_8 <= exp_add_7;
			exp_add_9 <= sumround_overflow ? exp_add_8 + 1 : exp_add_8;
			exp_sub_3 <= exp_sub_2; exp_sub_4 <= exp_sub_3; exp_sub_5 <= exp_sub_4;
			exp_sub_6 <= exp_sub_5; exp_sub_7 <= exp_sub_6; 
			exp_sub_8 <= diffround_overflow ? exp_sub_7 + 1 : exp_sub_7;
			outfp <= fpuf_21 ? {sign_19, exp_sub_8, diff_11[53:2]} : {sign_19, exp_add_9, sum_11[53:2]};
			end
	end


		
always @(posedge clk)
   casex(diff[54:0])	
    55'b1??????????????????????????????????????????????????????: diff_shift <=  0;
	55'b01?????????????????????????????????????????????????????: diff_shift <=  1;
	55'b001????????????????????????????????????????????????????: diff_shift <=  2;
	55'b0001???????????????????????????????????????????????????: diff_shift <=  3;
	55'b00001??????????????????????????????????????????????????: diff_shift <=  4;
	55'b000001?????????????????????????????????????????????????: diff_shift <=  5;
	55'b0000001????????????????????????????????????????????????: diff_shift <=  6;
	55'b00000001???????????????????????????????????????????????: diff_shift <=  7;
	55'b000000001??????????????????????????????????????????????: diff_shift <=  8;
	55'b0000000001?????????????????????????????????????????????: diff_shift <=  9;
	55'b00000000001????????????????????????????????????????????: diff_shift <=  10;
	55'b000000000001???????????????????????????????????????????: diff_shift <=  11;
	55'b0000000000001??????????????????????????????????????????: diff_shift <=  12;
	55'b00000000000001?????????????????????????????????????????: diff_shift <=  13;
	55'b000000000000001????????????????????????????????????????: diff_shift <=  14;
	55'b0000000000000001???????????????????????????????????????: diff_shift <=  15;
	55'b00000000000000001??????????????????????????????????????: diff_shift <=  16;
	55'b000000000000000001?????????????????????????????????????: diff_shift <=  17;
	55'b0000000000000000001????????????????????????????????????: diff_shift <=  18;
	55'b00000000000000000001???????????????????????????????????: diff_shift <=  19;
	55'b000000000000000000001??????????????????????????????????: diff_shift <=  20;
	55'b0000000000000000000001?????????????????????????????????: diff_shift <=  21;
	55'b00000000000000000000001????????????????????????????????: diff_shift <=  22;
	55'b000000000000000000000001???????????????????????????????: diff_shift <=  23;
	55'b0000000000000000000000001??????????????????????????????: diff_shift <=  24;
	55'b00000000000000000000000001?????????????????????????????: diff_shift <=  25;
	55'b000000000000000000000000001????????????????????????????: diff_shift <=  26;
	55'b0000000000000000000000000001???????????????????????????: diff_shift <=  27;
	55'b00000000000000000000000000001??????????????????????????: diff_shift <=  28;
	55'b000000000000000000000000000001?????????????????????????: diff_shift <=  29;
	55'b0000000000000000000000000000001????????????????????????: diff_shift <=  30;
	55'b00000000000000000000000000000001???????????????????????: diff_shift <=  31;
	55'b000000000000000000000000000000001??????????????????????: diff_shift <=  32;
	55'b0000000000000000000000000000000001?????????????????????: diff_shift <=  33;
	55'b00000000000000000000000000000000001????????????????????: diff_shift <=  34;
	55'b000000000000000000000000000000000001???????????????????: diff_shift <=  35;
	55'b0000000000000000000000000000000000001??????????????????: diff_shift <=  36;
	55'b00000000000000000000000000000000000001?????????????????: diff_shift <=  37;
	55'b000000000000000000000000000000000000001????????????????: diff_shift <=  38;
	55'b0000000000000000000000000000000000000001???????????????: diff_shift <=  39;
	55'b00000000000000000000000000000000000000001??????????????: diff_shift <=  40;
	55'b000000000000000000000000000000000000000001?????????????: diff_shift <=  41;
	55'b0000000000000000000000000000000000000000001????????????: diff_shift <=  42;
	55'b00000000000000000000000000000000000000000001???????????: diff_shift <=  43;
	55'b000000000000000000000000000000000000000000001??????????: diff_shift <=  44;
	55'b0000000000000000000000000000000000000000000001?????????: diff_shift <=  45;
	55'b00000000000000000000000000000000000000000000001????????: diff_shift <=  46;
	55'b000000000000000000000000000000000000000000000001???????: diff_shift <=  47;
	55'b0000000000000000000000000000000000000000000000001??????: diff_shift <=  48;
    55'b00000000000000000000000000000000000000000000000001?????: diff_shift <=  49;
	55'b000000000000000000000000000000000000000000000000001????: diff_shift <=  50;
	55'b0000000000000000000000000000000000000000000000000001???: diff_shift <=  51;
	55'b00000000000000000000000000000000000000000000000000001??: diff_shift <=  52;
	55'b000000000000000000000000000000000000000000000000000001?: diff_shift <=  53;
	55'b0000000000000000000000000000000000000000000000000000001: diff_shift <=  54;
	55'b0000000000000000000000000000000000000000000000000000000: diff_shift <=  55;
	endcase	

	
always @(posedge clk) 
begin
	if (rst) begin
		ready <= 0;
		count_ready_0 <= 0;
		count_ready  <= 0;
	end
	else if (enable) begin
		ready <= count_ready;
		count_ready_0 <= count == 21;
		count_ready <= count == 22;
	end
end

always @(posedge clk) 
begin
	if (rst) 
		count <= 0;
	else if (enable & !count_ready_0 & !count_ready) 
		count <= count + 1;
end

always @(posedge clk) 
begin
	if (rst) 
		out <= 0;
	else if (enable & count_ready) 
		out <= in_inf21 ? { outfp[63], 11'b11111111111, 52'b0 } : outfp;
end
endmodule
