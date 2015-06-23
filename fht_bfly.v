/**********************************************************************
 * File  : fht_8x8_core.v
 * Author: Ivan Rezki
 * email : irezki@gmail.com
 * Topic : RTL Core
 * 		  2-Dimensional Fast Hartley Transform
 *
 * Function: Fast Hartley Transform ButterFly Unit
 *
 * RIGHT TO USE: This code example, or any portion thereof, may be
 * used and distributed without restriction, provided that this entire
 * comment block is included with the example.
 *
 * DISCLAIMER: THIS CODE EXAMPLE IS PROVIDED "AS IS" WITHOUT WARRANTY
 * OF ANY KIND, EITHER EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED
 * TO WARRANTIES OF MERCHANTABILITY, FITNESS OR CORRECTNESS. IN NO
 * EVENT SHALL THE AUTHOR OR AUTHORS BE LIABLE FOR ANY DAMAGES,
 * INCLUDING INCIDENTAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF THE
 * USE OF THIS CODE.
 **********************************************************************/

module fht_bfly(
	rstn,
	clk,
	valid,
	a,
	b,
	c,
	d
);

parameter N = 8;

input			rstn;
input			clk;

input			valid;

input	[N-1:0]	a; // input
input	[N-1:0]	b; // input

output	[N  :0]	c; // additive output
output	[N  :0]	d; // subtractive output

reg [N-1:0] a_FF;
always @(posedge clk)
if		(!rstn)	a_FF <= #1 0;
else if (valid)	a_FF <= #1 a;

reg [N-1:0] b_FF;
always @(posedge clk)
if		(!rstn) b_FF <= #1 0;
else if (valid)	b_FF <= #1 b;

assign c = rca_N(a_FF,b_FF);
assign d = rca_N(a_FF,twos_complement(b_FF));

// +--------------------------------------------------+ \\
// +----------- Function's Description Part ----------+ \\
// +--------------------------------------------------+ \\
// Full Adder
	function [1:0] full_adder;
	input a, b, ci;
	reg co, s;
	begin
		s  = (a ^ b ^ ci);
		co = (a & b) | (ci & (a ^ b));
		full_adder = {co,s};
	end
	endfunction

// Half Adder, i.e. without carry in
	function [1:0] half_adder;
	input a, b;
	reg co, s;
	begin
		s  = (a ^ b);
		co = (a & b);
		half_adder = {co,s};
	end
	endfunction

// Ripple Carry Adder - rca
// Input  vector = N     bits
// Output vector = N + 1 bits
	function [N:0] rca_N;

//	parameter N = 8;
	input [N-1:0] a;
	input [N-1:0] b;
	
	reg [N-1:0] co,sum;
		
		begin : RCA // RIPPLE_CARRY_ADDER
        	integer i;
        	//for (i = 0; i <= N; i = i + 1)
        	for (i = 0; i < N; i = i + 1)
            	if (i == 0)
					{co[i],sum[i]} = half_adder(a[i],b[i]);
				else
					{co[i],sum[i]} = full_adder(a[i],b[i],co[i-1]);

		rca_N[N-1:0] = sum;
		// MSB is a sign bit
		rca_N[N] = (a[N-1]==b[N-1]) ? co[N-1] : sum[N-1];
		end
	endfunction


	function [N-1:0] twos_complement;
	input [N-1:0] a;
  	reg [N-1:0] ainv;
  	reg [N:0] plus1;
	begin
		ainv  = ~a;
		plus1 = rca_N(ainv,{{N-1{1'b0}},1'b1});
	
		// pragma coverage block = off
		// synopsys translate_off
		// The only problem is absolute minumum negative value
		if (a == {1'b1, {N-1{1'b0}}})
			$display("--->>> 2's complement ERROR - absolute minimum negative value: %0b\n\t %m",a);
		// synopsys translate_on
		// pragma coverage block = on
		
		twos_complement = plus1[N-1:0];
	end
	endfunction

endmodule

// Update Log:
// 27 Jul. 2011
// added pragmas for coverage
