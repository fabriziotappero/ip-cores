// ============================================================================
//  down_counter.v
//  - counts down
//
//
//	2010  Robert Finch
//	pfingh>remove<@birdcomputer.ca
//
//
//  This source code is available for evaluation and validation purposes
//  only. This copyright statement and disclaimer must remain present in
//  the file.
//
//
//	NO WARRANTY.
//  THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF ANY KIND, WHETHER
//  EXPRESS OR IMPLIED. The user must assume the entire risk of using the
//  Work.
//
//  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR ANY
//  INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES WHATSOEVER RELATING TO
//  THE USE OF THIS WORK, OR YOUR RELATIONSHIP WITH THE AUTHOR.
//
//  IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU TO USE THE WORK
//  IN APPLICATIONS OR SYSTEMS WHERE THE WORK'S FAILURE TO PERFORM CAN
//  REASONABLY BE EXPECTED TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN
//  LOSS OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK, AND YOU
//  AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS FROM ANY CLAIMS OR
//  LOSSES RELATING TO SUCH UNAUTHORIZED USE.
//
//
//	Verilog 1995
// ============================================================================

module down_counter(rst, clk, ce, ld, d, q, z);
parameter WID=8;
input rst;
input clk;
input ce;
input ld;
input [WID:1] d;
output [WID:1] q;
reg [WID:1] q;
output z;

always @(posedge clk)
	if (rst)
		q <= 0;
	else if (ce) begin
		if (ld)
			q <= d;
		else
			q <= q + {WID{1'b1}};
	end

assign z = q == 0;

endmodule
