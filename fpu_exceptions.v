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

module fpu_exceptions( clk, rst, enable, rmode, opa, opb, in_except,
exponent_in, mantissa_in, fpu_op, out, ex_enable, underflow, overflow, 
inexact, exception, invalid);
input		clk;
input		rst;
input		enable;
input	[1:0]	rmode;
input	[63:0]	opa;
input	[63:0]	opb;
input	[63:0]	in_except;
input	[11:0]	exponent_in;
input	[1:0]	mantissa_in;
input	[2:0]	fpu_op;
output	[63:0]	out;
output		ex_enable;
output		underflow;
output		overflow;
output		inexact;
output		exception;
output		invalid;

reg		[63:0]	out;
reg		ex_enable;
reg		underflow;
reg		overflow;
reg		inexact;
reg		exception;
reg		invalid;

reg		in_et_zero;
reg		opa_et_zero;
reg		opb_et_zero;
reg		input_et_zero;
reg		add;
reg		subtract;
reg		multiply;
reg		divide;
reg		opa_QNaN;
reg		opb_QNaN;
reg		opa_SNaN;
reg		opb_SNaN;
reg		opa_pos_inf;
reg		opb_pos_inf;
reg		opa_neg_inf;
reg		opb_neg_inf;
reg		opa_inf;
reg		opb_inf;
reg		NaN_input;
reg		SNaN_input;
reg		a_NaN;
reg		div_by_0;
reg		div_0_by_0;
reg		div_inf_by_inf;
reg		div_by_inf;
reg		mul_0_by_inf;
reg		mul_inf;
reg		div_inf;
reg		add_inf;
reg		sub_inf;
reg		addsub_inf_invalid;
reg		addsub_inf;
reg		out_inf_trigger;
reg		out_pos_inf;
reg		out_neg_inf;
reg		round_nearest;
reg		round_to_zero;
reg		round_to_pos_inf;
reg		round_to_neg_inf;
reg		inf_round_down_trigger;
reg		mul_uf;
reg		div_uf;								
reg		underflow_trigger;			
reg		invalid_trigger;
reg		overflow_trigger;
reg		inexact_trigger;
reg	 	except_trigger;
reg		enable_trigger;
reg		NaN_out_trigger;
reg		SNaN_trigger;


wire	[10:0]  exp_2047 = 11'b11111111111;
wire	[10:0]  exp_2046 = 11'b11111111110;
reg		[62:0] NaN_output_0; 
reg		[62:0] NaN_output; 
wire	[51:0]  mantissa_max = 52'b1111111111111111111111111111111111111111111111111111;
reg		[62:0]	inf_round_down;
reg		[62:0]	out_inf;
reg		[63:0]	out_0;
reg		[63:0]	out_1;
reg		[63:0]	out_2;

always @(posedge clk)
begin
	if (rst) begin
		in_et_zero <=    0;
		opa_et_zero <=   0;
		opb_et_zero <=   0;
		input_et_zero <= 0;
		add 	<= 	0;
		subtract <= 0;
		multiply <= 0;
		divide 	<= 	0;
		opa_QNaN <= 0;
		opb_QNaN <= 0;
		opa_SNaN <= 0;
		opb_SNaN <= 0;
		opa_pos_inf <= 0;
		opb_pos_inf <= 0;
		opa_neg_inf <= 0;
		opb_neg_inf <= 0; 
		opa_inf <= 0;
		opb_inf <= 0;
		NaN_input <= 0; 
		SNaN_input <= 0;
		a_NaN <= 0;
		div_by_0 <= 0;
		div_0_by_0 <= 0;
		div_inf_by_inf <= 0;
		div_by_inf <= 0;
		mul_0_by_inf <= 0;
		mul_inf <= 0;
		div_inf <= 0;
		add_inf <= 0;
		sub_inf <= 0;
		addsub_inf_invalid <= 0;
		addsub_inf <= 0;
		out_inf_trigger <= 0;
		out_pos_inf <= 0;
		out_neg_inf <= 0;
		round_nearest <= 0;
		round_to_zero <= 0;
		round_to_pos_inf <= 0;
		round_to_neg_inf <= 0;
		inf_round_down_trigger <= 0;
		mul_uf <= 0;
		div_uf <= 0;															
		underflow_trigger <= 0;		
		invalid_trigger <= 0;
		overflow_trigger <= 0;
		inexact_trigger <= 0;
		except_trigger <= 0;
		enable_trigger <= 0;
		NaN_out_trigger <= 0;
		SNaN_trigger <= 0;
		NaN_output_0 <= 0;
		NaN_output <= 0;
		inf_round_down <= 0;
		out_inf <= 0;
		out_0 <= 0;
		out_1 <= 0;
		out_2 <= 0;
		end
	else if (enable) begin
		in_et_zero <= !(|in_except[62:0]);
		opa_et_zero <= !(|opa[62:0]);
		opb_et_zero <= !(|opb[62:0]);
		input_et_zero <= !(|in_except[62:0]);	
		add 	<= 	fpu_op == 3'b000;
		subtract <= 	fpu_op == 3'b001;
		multiply <= 	fpu_op == 3'b010;
		divide 	<= 	fpu_op == 3'b011;
		opa_QNaN <= (opa[62:52] == 2047) & |opa[51:0] & opa[51];
		opb_QNaN <= (opb[62:52] == 2047) & |opb[51:0] & opb[51];
		opa_SNaN <= (opa[62:52] == 2047) & |opa[51:0] & !opa[51];
		opb_SNaN <= (opb[62:52] == 2047) & |opb[51:0] & !opb[51];
		opa_pos_inf <= !opa[63] & (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_pos_inf <= !opb[63] & (opb[62:52] == 2047) & !(|opb[51:0]);
		opa_neg_inf <= opa[63] & (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_neg_inf <= opb[63] & (opb[62:52] == 2047) & !(|opb[51:0]);
		opa_inf <= (opa[62:52] == 2047) & !(|opa[51:0]);
		opb_inf <= (opb[62:52] == 2047) & !(|opb[51:0]);
		NaN_input <= opa_QNaN | opb_QNaN | opa_SNaN | opb_SNaN;
		SNaN_input <= opa_SNaN | opb_SNaN;
		a_NaN <= opa_QNaN | opa_SNaN;
		div_by_0 <= divide & opb_et_zero & !opa_et_zero;
		div_0_by_0 <= divide & opb_et_zero & opa_et_zero;
		div_inf_by_inf <= divide & opa_inf & opb_inf;
		div_by_inf <= divide & !opa_inf & opb_inf;
		mul_0_by_inf <= multiply & ((opa_inf & opb_et_zero) | (opa_et_zero & opb_inf));
		mul_inf <= multiply & (opa_inf | opb_inf) & !mul_0_by_inf;
		div_inf <= divide & opa_inf & !opb_inf;
		add_inf <= (add & (opa_inf | opb_inf));
		sub_inf <= (subtract & (opa_inf | opb_inf));
		addsub_inf_invalid <= (add & opa_pos_inf & opb_neg_inf) | (add & opa_neg_inf & opb_pos_inf) | 
					(subtract & opa_pos_inf & opb_pos_inf) | (subtract & opa_neg_inf & opb_neg_inf);
		addsub_inf <= (add_inf | sub_inf) & !addsub_inf_invalid;
		out_inf_trigger <= addsub_inf | mul_inf | div_inf | div_by_0 | (exponent_in > 2046);
		out_pos_inf <= out_inf_trigger & !in_except[63];
		out_neg_inf <= out_inf_trigger & in_except[63];
		round_nearest <= (rmode == 2'b00);
		round_to_zero <= (rmode == 2'b01);
		round_to_pos_inf <= (rmode == 2'b10);
		round_to_neg_inf <= (rmode == 2'b11);
		inf_round_down_trigger <= (out_pos_inf & round_to_neg_inf) | 
								(out_neg_inf & round_to_pos_inf) |
								(out_inf_trigger & round_to_zero);
		mul_uf <= multiply & !opa_et_zero & !opb_et_zero & in_et_zero;
		div_uf <= divide & !opa_et_zero & in_et_zero;																
		underflow_trigger <= div_by_inf | mul_uf | div_uf;								
		invalid_trigger <= SNaN_input | addsub_inf_invalid | mul_0_by_inf |
						div_0_by_0 | div_inf_by_inf;
		overflow_trigger <= out_inf_trigger & !NaN_input;
		inexact_trigger <= (|mantissa_in[1:0] | out_inf_trigger | underflow_trigger) &
						!NaN_input;
		except_trigger <= invalid_trigger | overflow_trigger | underflow_trigger |
						inexact_trigger;
		enable_trigger <= except_trigger | out_inf_trigger | NaN_input;	
		NaN_out_trigger <= NaN_input | invalid_trigger;
		SNaN_trigger <= invalid_trigger & !SNaN_input;
		NaN_output_0 <= a_NaN ? { exp_2047, 1'b1, opa[50:0]} : { exp_2047, 1'b1, opb[50:0]};
		NaN_output <= SNaN_trigger ? { exp_2047, 2'b01, opa[49:0]} : NaN_output_0;
		inf_round_down <= { exp_2046, mantissa_max };
		out_inf <= inf_round_down_trigger ? inf_round_down : { exp_2047, 52'b0 };
		out_0 <= underflow_trigger ? { in_except[63], 63'b0 } : in_except;
		out_1 <= out_inf_trigger ? { in_except[63], out_inf } : out_0;
		out_2 <= NaN_out_trigger ? { in_except[63], NaN_output} : out_1;
		end
end 

always @(posedge clk)
begin
	if (rst) begin
		ex_enable <= 0;
		underflow <= 0;
		overflow <= 0;	   
		inexact <= 0;
		exception <= 0;
		invalid <= 0;
		out <= 0;
		end
	else if (enable) begin
		ex_enable <= enable_trigger;
		underflow <= underflow_trigger;
		overflow <= overflow_trigger;	   
		inexact <= inexact_trigger;
		exception <= except_trigger;
		invalid <= invalid_trigger;
		out <= out_2;
		end
end 
    
endmodule
