/* ============================================================================
	(C) 2007  Robert Finch
	All rights reserved.

	bcPSGNoteOutMux.v
	Version 1.0

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

	
	Selects from one of five waveforms for output. Selected waveform
	outputs are anded together. This is approximately how the
	original SID worked.

	Spartan3
	Webpack 9.1i xc3s1000-4ft256
	36 LUTs / 21 slices / 11ns
============================================================================ */

module PSGNoteOutMux(s, a, b, c, d, e, o);
parameter WID = 12;
input [4:0] s;
input [WID-1:0] a,b,c,d,e;
output [WID-1:0] o;

wire [WID-1:0] o1,o2,o3,o4,o5;

assign o1 = s[4] ? e : {WID{1'b1}};
assign o2 = s[3] ? d : {WID{1'b1}};
assign o3 = s[2] ? c : {WID{1'b1}};
assign o4 = s[1] ? b : {WID{1'b1}};
assign o5 = s[0] ? a : {WID{1'b1}};

assign o = o1 & o2 & o3 & o4 & o5;

endmodule


