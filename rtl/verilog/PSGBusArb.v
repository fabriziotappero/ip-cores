/* ===============================================================
	(C) 2007  Robert Finch
	All rights reserved.

	PSGBusArb.v

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

		Arbitrates access to the system bus among up to eight
	wave table channels for the bcSid. This arbitrator is part
	of a tree that ends up looking like a single arbitration
	request to the system.

	Spartan3
	19 LUTs / 11 slices
=============================================================== */

module PSGBusArb(rst, clk, ce, ack,
	req0, req1, req2, req3, req4, req5, req6, req7,
	sel0, sel1, sel2, sel3, sel4, sel5, sel6, sel7, seln);
input rst;		// reset
input clk;		// clock (eg 100MHz)
input ce;		// clock enable (eg 25MHz)
input ack;		// bus transfer completed
input req0;		// requester 0 wants the bus
input req1;		// requester 1 wants the bus
input req2;		// ...
input req3;
input req4;
input req5;
input req6;
input req7;
output sel0;	// requester 0 granted the bus
reg sel0;
output sel1;
reg sel1;
output sel2;
reg sel2;
output sel3;
reg sel3;
output sel4;
reg sel4;
output sel5;
reg sel5;
output sel6;
reg sel6;
output sel7;
reg sel7;
output [2:0] seln;	// who has the bus
reg [2:0] seln;

always @(posedge clk) begin
	if (rst) begin
		sel0 <= 1'b0;
		sel1 <= 1'b0;
		sel2 <= 1'b0;
		sel3 <= 1'b0;
		sel4 <= 1'b0;
		sel5 <= 1'b0;
		sel6 <= 1'b0;
		sel7 <= 1'b0;
		seln <= 3'd0;
	end
	else begin
		if (ce&ack) begin
			if (req0) begin
				sel0 <= 1'b1;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd0;
			end
			else if (req1) begin
				sel1 <= 1'b1;
				sel0 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd1;
			end
			else if (req2) begin
				sel2 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd2;
			end
			else if (req3) begin
				sel3 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd3;
			end
			else if (req4) begin
				sel4 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd4;
			end
			else if (req5) begin
				sel5 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel6 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd5;
			end
			else if (req6) begin
				sel6 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel7 <= 1'b0;
				seln <= 3'd6;
			end
			else if (req7) begin
				sel7 <= 1'b1;
				sel0 <= 1'b0;
				sel1 <= 1'b0;
				sel2 <= 1'b0;
				sel3 <= 1'b0;
				sel4 <= 1'b0;
				sel5 <= 1'b0;
				sel6 <= 1'b0;
				seln <= 3'd7;
			end
			// otherwise, hold onto last owner
			else begin
				sel0 <= sel0;
				sel1 <= sel1;
				sel2 <= sel2;
				sel3 <= sel3;
				sel4 <= sel4;
				sel5 <= sel5;
				sel6 <= sel6;
				sel7 <= sel7;
				seln <= seln;
			end
		end
	end
end

endmodule
