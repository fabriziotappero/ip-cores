/////////////////////////////////////////////////////////////////////
////                                                             ////
////  FPU                                                        ////
////  Floating Point Unit (Single precision)                     ////
////                                                             ////
////  TEST BENCH                                                 ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000 Rudolf Usselmann                         ////
////                    rudi@asics.ws                            ////
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

module test;

reg		clk;
reg	[31:0]	opa;
reg	[31:0]	opb;
wire	[31:0]	sum;
wire		inf, snan, qnan;
wire		div_by_zero;

reg	[31:0]	exp, exp1, exp2, exp3, exp4;
reg	[31:0]	opa1, opa2, opa3, opa4;
reg	[31:0]	opb1, opb2, opb3, opb4;
reg	[2:0]	fpu_op, fpu_op1, fpu_op2, fpu_op3, fpu_op4, fpu_op5;
reg	[3:0]	rmode, rmode1, rmode2, rmode3, rmode4, rmode5;
reg		start, s1, s2, s3, s4;
reg	[115:0]	tmem[0:500000];
reg	[115:0]	tmp;
reg	[7:0]	oper;
reg	[7:0]	exc, exc1, exc2, exc3, exc4;
integer		i;
wire		ine;
reg		match;
wire		overflow, underflow;
wire		zero;
reg		exc_err;
reg		m0, m1, m2;
reg	[1:0]	fpu_rmode;
reg	[3:0]	test_rmode;
reg	[4:0]	test_sel;
reg		fp_fasu;
reg		fp_mul;
reg		fp_div;
reg		fp_combo;
reg		fp_i2f;
reg		fp_f2i;
reg		test_exc;
reg		show_prog;
event		error_event;

integer		error, vcount;

always #50 clk = ~clk;

initial
   begin
	$display ("\n\nFloating Point Unit Version 1.5\n\n");
	clk = 0;
	start = 0;
	s1 = 0;
	s2 = 0;
	s3 = 0;
	s4 = 0;
	error = 0;
	vcount = 0;

	show_prog = 0;

	fp_combo = 0;
	fp_fasu  = 0;
	fp_mul   = 0;
	fp_div   = 0;
	fp_i2f   = 1;
	fp_f2i   = 1;

	test_exc = 1;
	test_sel   = 5'b01111;
	test_rmode = 4'b1111;

	//test_sel   = 5'b00110;
	//test_rmode = 4'b01110;

	fp_combo = 1;
	fp_fasu  = 1;
	fp_mul   = 1;
	fp_div   = 1;
	fp_i2f   = 1;
	fp_f2i   = 1;

	test_sel   = 5'b11111;
	test_rmode = 4'b1111;

	@(posedge clk);

`include "test_bench/sel_test.vh"

	repeat (4)	@(posedge clk);
	$display("\n\n");

	$display("\n\nAll test Done !\n\n");
	$display("Run %0d vecors, found %0d errors.\n\n",vcount, error);

	$finish;
   end


task run_test;
begin
	@(posedge clk);
	#1;
	opa = 32'hx;
	opb = 32'hx;
	fpu_rmode = 2'hx;
	fpu_op = 3'hx;

	repeat(4) @(posedge clk);
	#1;

	oper = 1;
	i=0;
	while( |oper == 1'b1 )
	   begin

		@(posedge clk);
		#1;
		start = 1;
		tmp   = tmem[i];
		rmode = tmp[115:112];
		exc   = tmp[111:104];
		oper  = tmp[103:96];
		opa   = tmp[95:64];
		opb   = tmp[63:32];
		exp   = tmp[31:00];

		// FPU rounding mode
		//  0:	float_round_nearest_even
		//  1:	float_round_down
		//  2:	float_round_up
		//  3:	float_round_to_zero
	
		case(rmode)
		  0: fpu_rmode = 0;
		  1: fpu_rmode = 3;
		  2: fpu_rmode = 2;
		  3: fpu_rmode = 1;
		  default: fpu_rmode=2'hx;
		endcase

		// oper	fpu operation
		//   1   add
		//   2   sub
		//   4   mul
		//   8   div
		//   ...

		case(oper)
		   8'b00000001:	fpu_op=3'b000;	// Add
		   8'b00000010:	fpu_op=3'b001;	// Sub
		   8'b00000100:	fpu_op=3'b010;	// Mul
		   8'b00001000:	fpu_op=3'b011;	// Div
		   8'b00010000:	fpu_op=3'b100;	// i2f
		   8'b00100000:	fpu_op=3'b101;	// f2i
		   8'b01000000:	fpu_op=3'b110;	// rem
		   default: fpu_op=3'bx;
		endcase

		if(show_prog)	$write("Vector: %d\015",i);

		//if(oper==1)	$write("+");
		//else
		//if(oper==2)	$write("-");
		//else
		//if(oper==4)	$write("*");
		//else
		//if(oper==8)	$write("/");
		//else		$write("Unknown Operation (%d)",oper);

		i= i+1;
	   end
	start = 0;

   	@(posedge clk);
	#1;
	opa = 32'hx;
	opb = 32'hx;
	fpu_rmode = 2'hx;
	fpu_op = 2'hx;

	repeat(4) @(posedge clk);
	#1;

	for(i=0;i<500000;i=i+1)		// Clear Memory
	   tmem[i] = 112'hxxxxxxxxxxxxxxxxx;

   end
endtask

always @(posedge clk)
   begin
   	s1 <= #1 start;
   	s2 <= #1 s1;
   	s3 <= #1 s2;
   	s4 <= #1 s3;
	exp1 <= #1 exp;
	exp2 <= #1 exp1;
	exp3 <= #1 exp2;
	exp4 <= #1 exp3;
	opa1 <= #1 opa;
	opa2 <= #1 opa1;
	opa3 <= #1 opa2;
	opa4 <= #1 opa3;
	opb1 <= #1 opb;
	opb2 <= #1 opb1;
	opb3 <= #1 opb2;
	opb4 <= #1 opb3;
	fpu_op1 <= #1 fpu_op;
	fpu_op2 <= #1 fpu_op1;
	fpu_op3 <= #1 fpu_op2;
	fpu_op4 <= #1 fpu_op3;
	fpu_op5 <= #1 fpu_op4;
	rmode1 <= #1 rmode;
	rmode2 <= #1 rmode1;
	rmode3 <= #1 rmode2;
	rmode4 <= #1 rmode3;
	rmode5 <= #1 rmode4;
	exc1 <= #1 exc;
	exc2 <= #1 exc1;
	exc3 <= #1 exc2;
	exc4 <= #1 exc3;

	#3;
	
	//	Floating Point Exceptions ( exc4 )
	//	-------------------------
	//	float_flag_invalid   =  1,
	//	float_flag_divbyzero =  4,
	//	float_flag_overflow  =  8,
	//	float_flag_underflow = 16,
	//	float_flag_inexact   = 32

   	exc_err=0;

	if(test_exc)
	   begin

		if(div_by_zero !== exc4[2])
		   begin
		   	exc_err=1;
			$display("\nERROR: DIV_BY_ZERO Exception: Expected: %h, Got %h\n",exc4[2],div_by_zero);
		   end


		if(ine !== exc4[5])
		   begin
		   	exc_err=1;
			$display("\nERROR: INE Exception: Expected: %h, Got %h\n",exc4[5],ine);
		   end

		if(overflow !== exc4[3])
		   begin
		   	exc_err=1;
			$display("\nERROR: Overflow Exception Expected: %h, Got %h\n",exc4[3],overflow);
		   end
	

		if(underflow !== exc4[4])
		   begin
		   	exc_err=1;
			$display("\nERROR: Underflow Exception Expected: %h, Got %h\n",exc4[4],underflow);
		   end
	

		if(zero !== !(|sum[30:0]))
		   begin
		   	exc_err=1;
			$display("\nERROR: Zero Detection Failed. ZERO: %h, Sum: %h\n", zero, sum);
		   end
	
		if(inf !== ( (sum[30:23] == 8'hff) & ((|sum[22:0]) == 1'b0) ) )
		   begin
		   	exc_err=1;
			$display("\nERROR: INF Detection Failed. INF: %h, Sum: %h\n", inf, sum);
		   end
	

		if(qnan !== ( &sum[30:23]  & |sum[22:0] )  & !(fpu_op4==5)   )
		   begin
		   	exc_err=1;
			$display("\nERROR: QNAN Detection Failed. QNAN: %h, Sum: %h\n", qnan, sum);
		   end


		if(snan !== ( ( &opa4[30:23] & !opa4[22] & |opa4[21:0]) | ( &opb4[30:23] & !opb4[22] & |opb4[21:0]) ) )
		   begin
		   	exc_err=1;
			$display("\nERROR: SNAN Detection Failed. SNAN: %h, OpA: %h, OpB: %h\n", snan, opa4, opb4);
		   end

	   end


	m0 = ( (|sum) !== 1'b1) & ( (|sum) !== 1'b0);		// result unknown (ERROR)
	//m0 = ( (|sum) === 1'bx) & 0;
	m1 = (exp4 === sum);					// results are equal

	// NAN   *** Ignore Fraction Detail ***
	m2 =    (sum[31] == exp4[31]) &
		(sum[30:23] == 8'hff)  & (exp4[30:23] == 8'hff) &
		(sum[22] == exp4[22]) &
		( (|sum[22:0]) == 1'b1) & ((|exp4[22:0]) == 1'b1);

	match = m1 | m2;

	if( (exc_err | !match | m0) & s4 )
	   begin
		-> error_event;
		#0.6;
		$display("\n%t: ERROR: output mismatch. Expected %h, Got %h (%h)", $time, exp4, sum, {opa4, opb4, exp4} );
		$write("opa:\t");	disp_fp(opa4);
		$display("opa:\t%h",opa4[30:0]);
		case(fpu_op4)
		   0: $display("\t+");
		   1: $display("\t-");
		   2: $display("\t*");
		   3: $display("\t/");
		   default: $display("\t Unknown Operation ");
		endcase
		$write("opb:\t");	disp_fp(opb4);
		$write("EXP:\t");	disp_fp(exp4);
		$write("GOT:\t");	disp_fp(sum);
		
$display("\nThis rmode: %h fpop: %h; Previous: rmode: %h fpop: %h; Next: rmode: %h fpop: %h\n",
rmode4, fpu_op4, rmode5, fpu_op5, rmode3, fpu_op3);

		$display("\n");
		error = error + 1;
	   end

	if(s4)	vcount = vcount + 1;

	if(error > 10)
	   begin
		@(posedge clk);
	   	$display("\n\nFound to many errors, aborting ...\n\n");
		$display("Run %0d vecors, found %0d errors.\n\n",vcount, error);
		$finish;
	   end
   end


fpu u0(clk, fpu_rmode, fpu_op, opa, opb, sum, inf, snan, qnan, ine, overflow, underflow, zero, div_by_zero);


task disp_fp;
input [31:0]	fp;

reg 	[63:0]	x;
reg	[7:0]	exp;

   begin

	exp = fp[30:23];
	if(exp==8'h7f)	$write("(%h %h ( 00 ) %h) ",fp[31], exp, fp[22:0]);
	else
	if(exp>8'h7f)	$write("(%h %h (+%d ) %h) ",fp[31], exp, exp-8'h7f, fp[22:0]);
	else		$write("(%h %h (-%d ) %h) ",fp[31], exp, 8'h7f-exp, fp[22:0]);
	
	
	x[51:0] = {fp[22:0], 29'h0};
	x[63] = fp[31];
	x[62] = fp[30];
	x[61:59] = {fp[29], fp[29], fp[29]};
	x[58:52] = fp[29:23];
	
	$display("\t%f",$bitstoreal(x));
   end

endtask

endmodule


























