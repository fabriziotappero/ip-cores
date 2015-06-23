/* ===============================================================
	(C) 2006  Robert Finch
	All rights reserved.
	rob@birdcomputer.ca

	i2f.v
		- convert integer to floating point
		- parameterized width
		- IEEE 754 representation

	This source code is free for use and modification for
	non-commercial or evaluation purposes, provided this
	copyright statement and disclaimer remains present in
	the file.

	If the code is modified, please state the origin and
	note that the code has been modified.

	NO WARRANTY.
	THIS Work, IS PROVIDEDED "AS IS" WITH NO WARRANTIES OF
	ANY KIND, WHETHER EXPRESS OR IMPLIED. The user must assume
	the entire risk of using the Work.

	IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE FOR
	ANY INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES
	WHATSOEVER RELATING TO THE USE OF THIS WORK, OR YOUR
	RELATIONSHIP WITH THE AUTHOR.

	IN ADDITION, IN NO EVENT DOES THE AUTHOR AUTHORIZE YOU
	TO USE THE WORK IN APPLICATIONS OR SYSTEMS WHERE THE
	WORK'S FAILURE TO PERFORM CAN REASONABLY BE EXPECTED
	TO RESULT IN A SIGNIFICANT PHYSICAL INJURY, OR IN LOSS
	OF LIFE. ANY SUCH USE BY YOU IS ENTIRELY AT YOUR OWN RISK,
	AND YOU AGREE TO HOLD THE AUTHOR AND CONTRIBUTORS HARMLESS
	FROM ANY CLAIMS OR LOSSES RELATING TO SUCH UNAUTHORIZED
	USE.

	- pipelinable
	- single stage latency

	Ref: Spartan3-4
	267 LUTs / 167 slices / 20? ns  (32 bits)
=============================================================== */

module i2f
#(	parameter WID = 32)
(
	input clk,
	input ce,
	input [1:0] rm,			// rounding mode
	input [WID-1:0] i,		// integer input
	output [WID-1:0] o		// float output
);
localparam MSB = WID-1;
localparam EMSB = WID==80 ? 14 :
                  WID==64 ? 10 :
				  WID==52 ? 10 :
				  WID==48 ? 10 :
				  WID==44 ? 10 :
				  WID==42 ? 10 :
				  WID==40 ?  9 :
				  WID==32 ?  7 :
				  WID==24 ?  6 : 4;
localparam FMSB = WID==80 ? 63 :
                  WID==64 ? 51 :
				  WID==52 ? 39 :
				  WID==48 ? 35 :
				  WID==44 ? 31 :
				  WID==42 ? 29 :
				  WID==40 ? 28 :
				  WID==32 ? 22 :
				  WID==24 ? 15 : 9;

wire [EMSB:0] zeroXp = {EMSB{1'b1}};

wire iz;			// zero input ?
wire [MSB:0] imag;	// get magnitude of i
wire [MSB:0] imag1 = i[MSB] ? -i : i;
wire [6:0] lz;		// count the leading zeros in the number
wire [EMSB:0] wd;	// compute number of whole digits
wire so;			// copy the sign of the input (easy)
wire [1:0] rmd;

delay1 #(2)   u0 (.clk(clk), .ce(ce), .i(rm),     .o(rmd) );
delay1 #(1)   u1 (.clk(clk), .ce(ce), .i(i==0),   .o(iz) );
delay1 #(WID) u2 (.clk(clk), .ce(ce), .i(imag1),  .o(imag) );
delay1 #(1)   u3 (.clk(clk), .ce(ce), .i(i[MSB]), .o(so) );
generate 
if (WID==64) begin
cntlz64Reg    u4 (.clk(clk), .ce(ce), .i(imag1), .o(lz) );
end else begin
cntlz32Reg    u4 (.clk(clk), .ce(ce), .i(imag1), .o(lz) );
assign lz[6]=1'b0;
end
endgenerate

assign wd = zeroXp - 1 + WID - lz;	// constant except for lz

wire [EMSB:0] xo = iz ? 0 : wd;
wire [MSB:0] simag = imag << lz;		// left align number

wire g =  simag[EMSB+2];	// guard bit (lsb)
wire r =  simag[EMSB+1];	// rounding bit
wire s = |simag[EMSB:0];	// "sticky" bit
reg rnd;

// Compute the round bit
always @(rmd,g,r,s,so)
	case (rmd)
	2'd0:	rnd = (g & r) | (r & s);	// round to nearest even
	2'd1:	rnd = 0;					// round to zero (truncate)
	2'd2:	rnd = (r | s) & !so;		// round towards +infinity
	2'd3:	rnd = (r | s) & so;			// round towards -infinity
	endcase

// "hide" the leading one bit = MSB-1
// round the result
wire [FMSB:0] mo = simag[MSB-1:EMSB+1]+rnd;

assign o = {so,xo,mo};

endmodule


module i2f_tb();

reg clk;
reg [7:0] cnt;
wire [31:0] fo;
reg [31:0] i;
initial begin
clk = 1'b0;
cnt = 0;
end
always #10 clk=!clk;

always @(posedge clk)
	cnt = cnt + 1;

always @(cnt)
case(cnt)
8'd0:	i <= 32'd0;
8'd1:	i <= 32'd16777226;
endcase

i2f #(32) u1 (.clk(clk), .ce(1), .rm(2'd0), .i(i), .o(fo) );

endmodule
