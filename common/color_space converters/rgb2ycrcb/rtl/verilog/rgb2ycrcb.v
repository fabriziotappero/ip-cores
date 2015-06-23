/////////////////////////////////////////////////////////////////////
////                                                             ////
////  RGB to YCrCb Color Space converter                         ////
////                                                             ////
////  Converts RGB values to YCrCB (YUV) values                  ////
////  Y  = 0.299R + 0.587G + 0.114B                              ////
////  Cr = 0.713(R - Y)                                          ////
////  Cb = 0.565(B - Y)                                          ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001 Richard Herveille                        ////
////                    richard@asics.ws                         ////
////                                                             ////
//// This source file may be used and distributed without        ////
//// restriction provided that this copyright statement is not   ////
//// removed from the file and that any derivative work contains ////
//// the original copyright notice and the associated disclaimer.////
////                                                             ////
////     THIS SOFTWARE IS PROVIDED ``AS IS'' AND WITHOUT ANY     ////
//// EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED   ////
//// TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS   ////
//// FOR A PARTICULAR PURPOSE. IN NO EVENT SHALL THE AUTHOR      ////
//// OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,         ////
//// INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES    ////
//// (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE   ////
//// GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR        ////
//// BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF  ////
//// LIABILITY, WHETHER IN  CONTRACT, STRICT LIABILITY, OR TORT  ////
//// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT  ////
//// OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE         ////
//// POSSIBILITY OF SUCH DAMAGE.                                 ////
////                                                             ////
/////////////////////////////////////////////////////////////////////

//  CVS Log
//
//  $Id: rgb2ycrcb.v,v 1.1.1.1 2002-03-26 07:25:01 rherveille Exp $
//
//  $Date: 2002-03-26 07:25:01 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $


`timescale 1ns/10ps

module rgb2ycrcb(clk, ena, r, g, b, y, cr, cb);
	//
	// inputs & outputs
	//
	input        clk;
	input        ena;
	input  [9:0] r, g, b;

	output [9:0] y, cr, cb;
	reg [9:0] y, cr, cb;


	//
	// variables
	//
	reg [21:0] y1, cr1, cb1;

	//
	// module body
	//


	// step 1: Calculate Y, Cr, Cb
	//
	// Use N.M format for multiplication:
	// Y  = 0.299 * R.000 + 0.587 * G.000 + 0.114 * B.000
	// Y  = 0x132 * R + 0x259 * G + 0x074 * B
	//
	// Cr = 0.713(R - Y)
	// Cr = 0.500 * R.000 + -0.419 * G.000 - 0.0813 * B.000
	// Cr = (R >> 1) - 0x1AD * G - 0x053 * B
	//
	// Cb = 0.565(B - Y)
	// Cb = -0.169 * R.000 + -0.332 * G.000 + 0.500 * B.000
	// Cb = (B >> 1) - 0x0AD * R - 0x153 * G	


	// calculate Y
	reg [19:0] yr, yg, yb;

	always@(posedge clk)
		if (ena)
		begin
			yr <= #1 10'h132 * r;
			yg <= #1 10'h259 * g;		
			yb <= #1 10'h074 * b;

			y1 <= #1 yr + yg + yb;
		end

	// calculate Cr
	reg [19:0] crr, crg, crb;

	always@(posedge clk)
		if (ena)
		begin
			crr <= #1 r << 9;
			crg <= #1 10'h1ad * g;		
			crb <= #1 10'h053 * b;

			cr1 <= #1 crr - crg - crb;
		end

	// calculate Cb
	reg [19:0] cbr, cbg, cbb;

	always@(posedge clk)
		if (ena)
		begin
			cbr <= #1 10'h0ad * r;
			cbg <= #1 10'h153 * g;		
			cbb <= #1 b << 9;

			cb1 <= #1 cbb - cbr - cbg;
		end

	//
	// step2: check boundaries
	//
	always@(posedge clk)
		if (ena)
		begin
			// check Y
			y <= #1 (y1[19:10] & {10{!y1[21]}}) | {10{(!y1[21] && y1[20])}};

			// check Cr
			cr <= #1 (cr1[19:10] & {10{!cr1[21]}}) | {10{(!cr1[21] && cr1[20])}};

			// check Cb
			cb <= #1 (cb1[19:10] & {10{!cb1[21]}}) | {10{(!cb1[21] && cb1[20])}};
		end
endmodule







