//	MODULE  : my_LUT2.v
//	AUTHOR  : Stephan Neuhold
//	VERSION : v1.00
//
//	REVISION HISTORY:
//	-----------------
//	No revisions
//
//	FUNCTION DESCRIPTION:
//	---------------------
//	This module instantiates a simple LUT2
//	primitive and initialises the contents
//	to 9 creating an XOR function.

`timescale 1 ns / 1 ns

module my_LUT2(	I0,
						I1,
						O);

	input		I0;
	input		I1;
	output	O;

LUT2	#(4'h9)	my_LUT2_inst(
	.I0(I0),
	.I1(I1),
	.O(O)
	);

endmodule
