
`include "defines.v"

module divider(in, out, N, reset);

	input in;				// input clock
	input [`SIZE-1:0] N;	// the number to be divided by
	input reset;			// asynchronous reset
	output out;				// divided output clock
	
	wire out_odd;			// output of odd divider
	wire out_even;			// output of even divider
	wire not_zero;			// signal to find divide by 0 case
	wire enable_even;		// enable of even divider
	wire enable_odd;		// enable of odd divider

	assign not_zero = | N[`SIZE-1:1];

	assign out = (out_odd & N[0] & not_zero) | (out_even & !N[0]);
	//assign out = out_odd | out_even;
	assign enable_odd = N[0] & not_zero;
	assign enable_even = !N[0];

	// Even divider
	even even_0(in, out_even, N, reset, not_zero, enable_even);
	// Odd divider
	odd odd_0(in, out_odd, N, reset, enable_odd);
	
endmodule //divider
