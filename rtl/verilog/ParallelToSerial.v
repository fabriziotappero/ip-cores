/* ============================================================================
	2006,2007,2011  Robert T Finch
	robfinch@<remove>sympatico.ca

	ParallelToSerial.v
		Parallel to serial data converter (shift register).

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


	Webpack 9.1i xc3s1000-4ft256	
	LUTs / slices / MHz
	block rams

============================================================================ */

module ParallelToSerial(rst, clk, ce, ld, qin, d, qh);
	parameter WID=8;
	input rst;			// reset
	input clk;			// clock
	input ce;			// clock enable
	input ld;			// load
	input qin;			// serial shifting input
	input [WID:1] d;	// data to load
	output qh;			// serial output

	reg [WID:1] q;

	always @(posedge clk)
		if (rst)
			q <= 0;
		else if (ce) begin
			if (ld)
				q <= d;
			else
				q <= {q[WID-1:1],qin};
		end

	assign qh = q[WID];

endmodule
