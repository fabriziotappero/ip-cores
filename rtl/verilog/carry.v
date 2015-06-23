/* ============================================================================
	(C) 2005-2007  Robert T Finch
	All rights reserved.
	rob@birdcomputer.ca


	carry.v

	Verilog 1995

	You may use this source code for non-commercial or evaluation purposes,
	provided this copyright statement and disclaimer remains present in the
	file.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
	EXPRESS OR IMPLIED. The user must assume the entire risk of using the
	Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
	INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
	THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
	IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
	REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
	LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
	AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
	LOSSES RELATING TO SUCH UNAUTHORIZED USE.

	
	This module computes carry for add/subtract given two operands and the
	result. Assuming we don't know what the carry input is and there may
	have been one.
============================================================================ */

module carry(op, a, b, s, c);

	input op;	// 0=add,1=sub
	input a;
	input b;
	input s;	// sum
	output c;

	assign c = op? (~a&b)|(s&~a)|(s&b) : (a&b)|(a&~s)|(b&~s);

endmodule


