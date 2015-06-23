/* ============================================================================
	(C) 2007  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	PSGChannelSummer.v 
		Sums the channel outputs.

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
	
	Spartan3
	1255 LUTs / 975 slices / 56MHz
============================================================================ */

module PSGChannelSummer(clk_i, cnt, outctrl, tmc_i, o);
input clk_i;			// master clock
input [7:0] cnt;		// select counter
input [3:0] outctrl;	// channel output enable control
input [19:0] tmc_i;		// time-multiplexed channel input
output [21:0] o;		// summed output
reg [21:0] o;

// channel select signal
wire [1:0] sel = cnt[1:0];

always @(posedge clk_i)
	if (cnt==8'd0)
		o <= 22'd0 + (tmc_i & {20{outctrl[sel]}});
	else if (cnt < 8'd4)
		o <= o + (tmc_i & {20{outctrl[sel]}});

endmodule
