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
/* FPU Operations (fpu_op):
========================
0 = add
1 = sub
2 = mul
3 = div

Rounding Modes (rmode):
=======================
0 = round_nearest_even
1 = round_to_zero
2 = round_up
3 = round_down  */

module fpu( clk, rst, enable, rmode, fpu_op, opa, opb, out, ready, underflow,
overflow, inexact, exception, invalid);
input		clk;
input		rst;
input		enable;
input	[1:0]	rmode;
input	[2:0]	fpu_op;
input	[63:0]	opa, opb;
output	[63:0]	out;
output		ready;
output		underflow;
output		overflow;
output		inexact;
output		exception;
output		invalid;
	
reg [63:0]	opa_reg;
reg [63:0]	opb_reg;
reg [2:0]	fpu_op_reg;
reg [1:0]	rmode_reg;
reg			enable_reg;
reg			enable_reg_1; // high for one clock cycle
reg			enable_reg_2; // high for one clock cycle		 
reg			enable_reg_3; // high for two clock cycles
reg			op_enable;	  
reg [63:0]	out;
reg [6:0] 	count_cycles;
reg [6:0]	count_ready;
wire		count_busy = (count_ready <= count_cycles);
reg			ready;
reg			ready_0;
reg			ready_1;
reg		underflow;
reg		overflow;
reg		inexact;
reg		exception;
reg		invalid;
wire		underflow_0;
wire		overflow_0;
wire		inexact_0;
wire		exception_0;
wire		invalid_0;

wire	add_enable_0 = (fpu_op_reg == 3'b000) & !(opa_reg[63] ^ opb_reg[63]);
wire	add_enable_1 = (fpu_op_reg == 3'b001) & (opa_reg[63] ^ opb_reg[63]);
reg		add_enable; 
wire	sub_enable_0 = (fpu_op_reg == 3'b000) & (opa_reg[63] ^ opb_reg[63]);
wire	sub_enable_1 = (fpu_op_reg == 3'b001) & !(opa_reg[63] ^ opb_reg[63]);
reg		sub_enable; 
reg		mul_enable; 
reg		div_enable; 
wire	[55:0]	sum_out;
wire	[55:0]	diff_out;
reg		[55:0]	addsub_out;
wire	[55:0]	mul_out;
wire	[55:0]	div_out;
reg		[55:0]	mantissa_round;
wire	[10:0] 	exp_add_out;
wire	[10:0] 	exp_sub_out;
wire	[11:0] 	exp_mul_out;
wire	[11:0] 	exp_div_out;
reg		[11:0] 	exponent_round;
reg		[11:0] 	exp_addsub;
wire	[11:0]	exponent_post_round;
wire	add_sign;
wire	sub_sign;
wire	mul_sign;
wire	div_sign;
reg		addsub_sign;
reg		sign_round;
wire	[63:0]	out_round;
wire	[63:0]	out_except;

fpu_add u1(
	.clk(clk),.rst(rst),.enable(add_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(add_sign),.sum_2(sum_out),.exponent_2(exp_add_out));

fpu_sub u2(
	.clk(clk),.rst(rst),.enable(sub_enable),.opa(opa_reg),.opb(opb_reg),
	.fpu_op(fpu_op_reg),.sign(sub_sign),.diff_2(diff_out),
	.exponent_2(exp_sub_out));

fpu_mul u3(
	.clk(clk),.rst(rst),.enable(mul_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(mul_sign),.product_7(mul_out),.exponent_5(exp_mul_out));	

fpu_div u4(
	.clk(clk),.rst(rst),.enable(div_enable),.opa(opa_reg),.opb(opb_reg),
	.sign(div_sign),.mantissa_7(div_out),.exponent_out(exp_div_out));	

fpu_round u5(.clk(clk),.rst(rst),.enable(op_enable),	.round_mode(rmode_reg),
	.sign_term(sign_round),.mantissa_term(mantissa_round), .exponent_term(exponent_round),
	.round_out(out_round),.exponent_final(exponent_post_round));		
	
fpu_exceptions u6(.clk(clk),.rst(rst),.enable(op_enable),.rmode(rmode_reg),
	.opa(opa_reg),.opb(opb_reg),
	.in_except(out_round), .exponent_in(exponent_post_round),
	.mantissa_in(mantissa_round[1:0]),.fpu_op(fpu_op_reg),.out(out_except),
	.ex_enable(except_enable),.underflow(underflow_0),.overflow(overflow_0),
	.inexact(inexact_0),.exception(exception_0),.invalid(invalid_0));
		
	
always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		mantissa_round <= addsub_out;
	3'b001:		mantissa_round <= addsub_out;
	3'b010:		mantissa_round <= mul_out;
	3'b011:		mantissa_round <= div_out;
	default:	mantissa_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		exponent_round <= exp_addsub;
	3'b001:		exponent_round <= exp_addsub;
	3'b010:		exponent_round <= exp_mul_out;
	3'b011:		exponent_round <= exp_div_out;
	default:	exponent_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		sign_round <= addsub_sign;
	3'b001:		sign_round <= addsub_sign;
	3'b010:		sign_round <= mul_sign;
	3'b011:		sign_round <= div_sign;
	default:	sign_round <= 0;
	endcase
end

always @(posedge clk)
begin
	case (fpu_op_reg)
	3'b000:		count_cycles <= 20;
	3'b001:		count_cycles <= 21;
	3'b010:		count_cycles <= 24;
	3'b011:		count_cycles <= 71; 
	default:	count_cycles <= 0;
	endcase
end

always @(posedge clk)
begin
	if (rst) begin
		add_enable <= 0;
		sub_enable <= 0;
		mul_enable <= 0;
		div_enable <= 0;
		addsub_out <= 0;
		addsub_sign <= 0;
		exp_addsub <= 0;
		end
	else begin
		add_enable <= (add_enable_0 | add_enable_1) & op_enable;
		sub_enable <= (sub_enable_0 | sub_enable_1) & op_enable;
		mul_enable <= (fpu_op_reg == 3'b010) & op_enable;
		div_enable <= (fpu_op_reg == 3'b011) & op_enable & enable_reg_3;
			// div_enable needs to be high for two clock cycles
		addsub_out <= add_enable ? sum_out : diff_out;
		addsub_sign <= add_enable ? add_sign : sub_sign;
		exp_addsub <= add_enable ? { 1'b0, exp_add_out} : { 1'b0, exp_sub_out};
		end
end 

always @ (posedge clk)
begin
	if (rst)
		count_ready <= 0;
	else if (enable_reg_1) 
		count_ready <= 0;
	else if (count_busy)
		count_ready <= count_ready + 1; 
end

always @(posedge clk)
begin
	if (rst) begin
		enable_reg <= 0;
		enable_reg_1 <= 0;
		enable_reg_2 <= 0;	   
		enable_reg_3 <= 0;
		end
	else begin
		enable_reg <= enable;
		enable_reg_1 <= enable & !enable_reg;
		enable_reg_2 <= enable_reg_1;  
		enable_reg_3 <= enable_reg_1 | enable_reg_2;
		end
end 
		
always @(posedge clk) 
begin
	if (rst) begin
		opa_reg <= 0;
		opb_reg <= 0;
		fpu_op_reg <= 0; 
		rmode_reg <= 0;
		op_enable <= 0;
		end
	else if (enable_reg_1) begin
		opa_reg <= opa;
		opb_reg <= opb;
		fpu_op_reg <= fpu_op; 
		rmode_reg <= rmode;
		op_enable <= 1;
		end
end

always @(posedge clk)
begin
	if (rst) begin
		ready_0 <= 0;
		ready_1 <= 0;
		ready <= 0;	   
		end
	else if (enable_reg_1) begin
		ready_0 <= 0;
		ready_1 <= 0;
		ready <= 0;	 
		end
	else begin
		ready_0 <= !count_busy;
		ready_1 <= ready_0;
		ready <= ready_1;  
		end
end 

always @(posedge clk)
begin
	if (rst) begin
		underflow <= 0;
		overflow <= 0;
		inexact <= 0;
		exception <= 0;
		invalid <= 0;	   	 
		out <= 0;
		end
	else if (ready_1) begin
		underflow <= underflow_0;
		overflow <= overflow_0;
		inexact <= inexact_0;
		exception <= exception_0;
		invalid <= invalid_0; 	
		out <= except_enable ? out_except : out_round;
		end
end 
endmodule
