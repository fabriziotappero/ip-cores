/* ============================================================================
	(C) 2007  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	bcPSGMasterVolumeControl.v 
		Controls the PSG's output volume.

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

module PSGMasterVolumeControl(rst_i, clk_i, i, volume, o);
input rst_i;
input clk_i;
input [15:0] i;
input [3:0] volume;
output [15:0] o;
reg [15:0] o;

// Multiply 16x4 bits
wire [19:0] v1 = volume[0] ? i : 20'd0;
wire [19:0] v2 = volume[1] ? {i,1'b0} + v1: v1;
wire [19:0] v3 = volume[2] ? {i,2'b0} + v2: v2;
wire [19:0] vo = volume[3] ? {i,3'b0} + v3: v3;

always @(posedge clk_i)
	if (rst_i)
		o <= 16'b0;		// Force the output volume to zero on reset
	else
		o <= vo[15:0];

endmodule

