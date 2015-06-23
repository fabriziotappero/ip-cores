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

`timescale 1ns / 100ps

module fpu_add( clk, rst, enable, opa, opb, sign, sum_2, exponent_2);
input		clk;
input		rst;
input		enable;
input	[63:0]	opa, opb;
output		sign;
output  [55:0]	sum_2;
output	[10:0]	exponent_2;

reg   sign;
reg   [10:0] exponent_a;
reg   [10:0] exponent_b;
reg   [51:0] mantissa_a;
reg   [51:0] mantissa_b;
reg   expa_gt_expb;
reg   [10:0] exponent_small;
reg   [10:0] exponent_large;
reg   [51:0] mantissa_small;
reg   [51:0] mantissa_large;
reg   small_is_denorm;
reg   large_is_denorm;
reg   large_norm_small_denorm;
reg   [10:0] exponent_diff;
reg   [55:0] large_add;
reg   [55:0] small_add;
reg   [55:0] small_shift;
wire   small_shift_nonzero = |small_shift[55:0];
wire	small_is_nonzero = (exponent_small > 0) | |mantissa_small[51:0]; 
wire   small_fraction_enable = small_is_nonzero & !small_shift_nonzero;
wire   [55:0] small_shift_2 = { 55'b0, 1'b1 };
reg   [55:0] small_shift_3;
reg   [55:0] sum;
wire   sum_overflow = sum[55]; // sum[55] will be 0 if there was no carry from adding the 2 numbers
reg   [55:0] sum_2;
reg   [10:0] exponent;
wire   sum_leading_one = sum_2[54]; // this is where the leading one resides, unless denorm
reg   denorm_to_norm;
reg   [10:0] exponent_2;

always @(posedge clk) 
	begin
		if (rst) begin
			sign <= 0;
			exponent_a <= 0;
			exponent_b <= 0;
			mantissa_a <= 0;
			mantissa_b <= 0;
			expa_gt_expb <= 0;
			exponent_small  <= 0;
			exponent_large  <= 0;
			mantissa_small  <= 0;
			mantissa_large  <= 0;
			small_is_denorm <= 0;
			large_is_denorm <= 0;
			large_norm_small_denorm <= 0;
			exponent_diff <= 0;
			large_add <= 0;
			small_add <= 0;
			small_shift <= 0;
			small_shift_3 <= 0;
			sum <= 0;
			sum_2 <= 0;
			exponent <= 0;
			denorm_to_norm <= 0;
			exponent_2 <= 0;
		end
		else if (enable) begin
			sign <= opa[63];
			exponent_a <= opa[62:52];
			exponent_b <= opb[62:52];
			mantissa_a <= opa[51:0];
			mantissa_b <= opb[51:0];
			expa_gt_expb <= exponent_a > exponent_b;
			exponent_small  <= expa_gt_expb ? exponent_b : exponent_a;
			exponent_large  <= expa_gt_expb ? exponent_a : exponent_b;
			mantissa_small  <= expa_gt_expb ? mantissa_b : mantissa_a;
			mantissa_large  <= expa_gt_expb ? mantissa_a : mantissa_b;
			small_is_denorm <= !(exponent_small > 0);
			large_is_denorm <= !(exponent_large > 0);
			large_norm_small_denorm <= (small_is_denorm && !large_is_denorm);
			exponent_diff <= exponent_large - exponent_small - large_norm_small_denorm;
			large_add <= { 1'b0, !large_is_denorm, mantissa_large, 2'b0 };
			small_add <= { 1'b0, !small_is_denorm, mantissa_small, 2'b0 };
			small_shift <= small_add >> exponent_diff;
			small_shift_3 <= small_fraction_enable ? small_shift_2 : small_shift;
			sum <= large_add + small_shift_3;
			sum_2 <= sum_overflow ? sum >> 1 : sum;
			exponent <= sum_overflow ? exponent_large + 1: exponent_large;
			denorm_to_norm <= sum_leading_one & large_is_denorm;
			exponent_2 <= denorm_to_norm ? exponent + 1 : exponent;
		end
	end

endmodule
