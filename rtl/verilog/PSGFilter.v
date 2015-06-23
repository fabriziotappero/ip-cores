/* ============================================================================
	(C) 2007  Robert Finch
	All rights reserved.

	PSGFilter.v
	Version 1.1

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


        16-tap digital filter

    Currently this filter is only partially tested. The author believes that
    the approach used is valid however.
	The author opted to include the filter because it is part of the design,
	and even this untested component can provide an idea of the resource
	requirements, and device capabilities.
		This is a "how one might approach the problem" example, at least
	until the author is sure the filter is working correctly.
        
	Time division multiplexing is used to implement this filter in order to
	reduce the resource requirement. This should be okay because it is being
	used to filter audio signals. The effective operating frequency of the
	filter depends on the 'cnt' supplied (eg 1MHz)

	Spartan3
	Webpack 9.1i xc3s1000-4ft256
	158 LUTs / 88 slices / 73.865MHz
	1 MULT
============================================================================ */

module PSGFilter(rst, clk, cnt, wr, adr, din, i, o);
parameter pTaps = 16;
input rst;
input clk;
input [7:0] cnt;
input wr;
input [3:0] adr;
input [12:0] din;
input [14:0] i;
output [14:0] o;
reg [14:0] o;

reg [30:0] acc;                 // accumulator
reg [14:0] tap [0:pTaps-1];     // tap registers
integer n;

// coefficient memory
reg [11:0] coeff [0:pTaps-1];   // magnitude of coefficient
reg [pTaps-1:0] sgn;            // sign of coefficient


// update coefficient memory
always @(posedge clk)
    if (wr) begin
        coeff[adr] <= din[11:0];
        sgn[adr] <= din[12];
    end

// shift taps
// Note: infer a dsr by NOT resetting the registers
always @(posedge clk)
    if (cnt==8'd0) begin
        tap[0] <= i;
        for (n = 1; n < pTaps; n = n + 1)
        	tap[n] <= tap[n-1];
    end

wire [26:0] mult = coeff[cnt[3:0]] * tap[cnt[3:0]];

always @(posedge clk)
    if (rst)
        acc <= 0;
    else if (cnt==8'd0)
        acc <= sgn[cnt[3:0]] ? 0 - mult : 0 + mult;
    else if (cnt < pTaps)
        acc <= sgn[cnt[3:0]] ? acc - mult : acc + mult;

always @(posedge clk)
    if (rst)
        o <= 0;
    else if (cnt==8'd0)
        o <= acc[30:16];

endmodule

