/* ============================================================================
	(C) 2007  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	bcPSGShaper.v 
		Shape the channels by applying the envelope to the tone generator
	output.


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
	
============================================================================ */

module PSGShaper(clk_i, ce, tgi, env, o);
input clk_i;		// clock
input ce;			// clock enable
input [11:0] tgi;	// tone generator input
input [7:0] env;	// envelop generator input
output [19:0] o;	// shaped output
reg [19:0] o;		// shaped output

// shape output according to envelope
always @(posedge clk_i)
	if (ce)
		o <= tgi * env;

endmodule
