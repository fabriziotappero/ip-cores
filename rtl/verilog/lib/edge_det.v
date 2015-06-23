/* ============================================================================
	2007  Robert Finch
	rob@birdcomputer.ca

	edge_det.v

    This source code is available for evaluation and validation purposes
    only. This copyright statement and disclaimer must remain present in
    the file.


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


    Notes:

	Edge detector
	This little core detects an edge (positive, negative, and
	either) in the input signal.

   	Verilog 1995
	Webpack 9.2 xc3S1000-4ft256
	3 LUTs / 2 slices / 9.1ns
============================================================================ */

module edge_det(rst, clk, ce, i, pe, ne, ee);
	input rst;		// reset
	input clk;		// clock
	input ce;		// clock enable
	input i;		// input signal
	output pe;		// positive transition detected
	output ne;		// negative transition detected
	output ee;		// either edge (positive or negative) transition detected

	reg ed;
	always @(posedge clk)
		if (rst)
			ed <= 1'b0;
		else if (ce)
			ed <= i;

	assign pe = ~ed & i;	// positive: was low and is now high
	assign ne = ed & ~i;	// negative: was high and is now low
	assign ee = ed ^ i;		// either: signal is now opposite to what it was
		
endmodule
