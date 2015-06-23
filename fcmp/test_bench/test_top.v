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
wire	[3:0]	sum;
wire		inf, snan, qnan;
wire		div_by_zero;
wire		altb, blta, aeqb;
wire		unordered;

reg	[3:0]	exp;
reg	[31:0]	opa1;
reg	[31:0]	opb1;
reg	[2:0]	fpu_op;
reg	[3:0]	rmode;
reg		start;
reg	[75:0]	tmem[0:500000];
reg	[75:0]	tmp;
reg	[7:0]	oper;
reg	[7:0]	exc;
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
reg		fp_0fcmp;
reg		test_exc;
reg		show_prog;
event		error_event;

integer		error, vcount;

always #50 clk = ~clk;

initial
   begin
	$display ("\n\nFloating Point Compare Version 1.0\n\n");
	clk = 0;
	start = 0;

	error = 0;
	vcount = 0;

	show_prog = 0;

	test_exc = 1;
	test_sel   = 5'b11111;

	@(posedge clk);

	$display("\n\nTesting FP CMP Unit\n");

	if(test_sel[0])
	   begin
		$display("\nRunning Pat 0 Test ...\n");
		$readmemh ("../test_vectors/fcmp/fcmp_pat0.hex", tmem);
		run_test;
	   end
	
	if(test_sel[1])
	   begin
		$display("\nRunning Pat 1 Test ...\n");
		$readmemh ("../test_vectors/fcmp/fcmp_pat1.hex", tmem);
		run_test;
	   end
	
	if(test_sel[2])
	   begin
		$display("\nRunning Pat 2 Test ...\n");
		$readmemh ("../test_vectors/fcmp/fcmp_pat2.hex", tmem);
		run_test;
	   end
	
	if(test_sel[3])
	   begin
		$display("\nRunning Random Lg. Num Test ...\n");
		$readmemh ("../test_vectors/fcmp/fcmp_lg.hex", tmem);
		run_test;
	   end
	
	if(test_sel[4])
	   begin
		$display("\nRunning Random Sm. Num Test ...\n");
		$readmemh ("../test_vectors/fcmp/fcmp_sm.hex", tmem);
		run_test;
	   end

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
	opa = 32'h0;
	opb = 32'hx;

	@(posedge clk);
	#1;

	i=0;
	while( |opa !== 1'bx )
	   begin

		@(posedge clk);
		#1;
		start = 1;
		tmp   = tmem[i];

		exc   = tmp[75:68];
		opa   = tmp[67:36];
		opb   = tmp[35:04];

		exp   = exc==0 ? tmp[03:00] : 0;

		if(show_prog)	$write("Vector: %d\015",i);

		i= i+1;
	   end
	start = 0;

   	@(posedge clk);
	#1;
	opa = 32'hx;
	opb = 32'hx;
	fpu_rmode = 2'hx;

	@(posedge clk);
	#1;

	for(i=0;i<500000;i=i+1)		// Clear Memory
	   tmem[i] = 76'hxxxxxxxxxxxxxxxxx;

   end
endtask

always @(posedge clk)
   begin

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

		if(exc[5])
		   begin
		   	exc_err=1;
			$display("\nERROR: INE Exception: Expected: 0, Got 1\n");
		   end

		if(exc[3])
		   begin
		   	exc_err=1;
			$display("\nERROR: Overflow Exception: Expected: 0, Got 1\n");
		   end

		if(exc[4])
		   begin
		   	exc_err=1;
			$display("\nERROR: Underflow Exception: Expected: 0, Got 1\n");
		   end
	
		if(zero !== !(|opa[30:0]))
		   begin
		   	exc_err=1;
			$display("\nERROR: Zero Detection Failed. ZERO: %h, Sum: %h\n", zero, opa);
		   end
	

		if(inf !== (((opa[30:23] == 8'hff) & ((|opa[22:0]) == 1'b0)) | ((opb[30:23] == 8'hff) & ((|opb[22:0]) == 1'b0))) )
		   begin
		   	exc_err=1;
			$display("\nERROR: INF Detection Failed. INF: %h, Sum: %h\n", inf, sum);
		   end

		if(unordered !== ( ( &opa[30:23] & |opa[22:0]) | ( &opb[30:23] & |opb[22:0]) ) )
		   begin
		   	exc_err=1;
			$display("\nERROR: UNORDERED Detection Failed. SNAN: %h, OpA: %h, OpB: %h\n", snan, opa, opb);
		   end

	   end

	m0 = ( (|sum) !== 1'b1) & ( (|sum) !== 1'b0);		// result unknown (ERROR)
	m1 = (exp === sum) ;					// results are equal

	match = m1;

	if( (exc_err | !match | m0) & start )
	   begin
		$display("\n%t: ERROR: output mismatch. Expected %h, Got %h (%h)", $time, exp, sum, {opa, opb, exp} );
		$write("opa:\t");	disp_fp(opa);
		$write("opb:\t");	disp_fp(opb);
		$display("EXP:\t%b",exp);
		$display("GOT:\t%b",sum);
		$display("\n");

		error = error + 1;
	   end

	if(start)	vcount = vcount + 1;

	if(error > 10)
	   begin
		@(posedge clk);
	   	$display("\n\nFound to many errors, aborting ...\n\n");
		$display("Run %0d vecors, found %0d errors.\n\n",vcount, error);
		$finish;
	   end
   end

assign sum = {1'b0, altb, blta, aeqb};

fcmp u0(opa, opb, unordered, altb, blta, aeqb, inf, zero );

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


























