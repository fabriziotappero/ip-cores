// ============================================================================
//  2008  Robert Finch
//
//  PSRAM power up delay timer
//  PSRAM requires a 150 us delay on power up before operation
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
//	Webpack 9.2i xc3s1200e-4fg320	
//	21 LUTs / 12 slices / 220.848MHz
//	20 FFs
//
// ============================================================================

module PSRAMCtrl_PudTimer(rst, clk, pud);
parameter pClkFreq = 60000000;				// 60 MHz
parameter tPWR = pClkFreq / 6667 + 1;		// 150 micro seconds
input rst;
input clk;
output pud;

reg [19:0] pudcnt;
assign pud = ~pudcnt[19];

always @(posedge clk)
	if (rst)
		pudcnt <= tPWR;
	else begin
		if (pudcnt[19]==1'b0)
			pudcnt <= pudcnt - 20'd1;
	end

endmodule
