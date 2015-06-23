/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Testbench for Color Space converters                       ////
////                                                             ////
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
//  $Id: testbench.v,v 1.1.1.1 2002-03-26 07:25:07 rherveille Exp $
//
//  $Date: 2002-03-26 07:25:07 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $


`timescale 1ns/10ps

module testbench();

	parameter emargin = 1; // we allow a small (rounding) error
	parameter debug = 0;
	parameter y_runlength = 1023;
	parameter cr_runlength = 1023;
	parameter cb_runlength = 1023;

	// variables
	reg clk;
	reg ena;

	reg  [9:0] y [3:0];
	reg  [9:0] cr [3:0];
	reg  [9:0] cb [3:0];

	wire [9:0] r, g, b;

	integer yc, crc, cbc;

	integer mr, mg, mb;
	integer ir, ig, ib;

	//
	// module body
	//

	// hookup modules
	ycrcb2rgb dut (
		.clk(clk),
		.ena(ena),
		.y(y[0]),
		.cr(cr[0]),
		.cb(cb[0]),
		.r(r),
		.g(g),
		.b(b)
	);

	always #5 clk <= ~clk;

	initial
	begin
		clk = 0;
		ena = 1;
	
		y[0]  = 0;
		cr[0] = 0;
		cb[0] = 0;

		$display ("\n *** Color Space Converter testbench started ***\n");

		for (cbc = 0; cbc <= cb_runlength; cbc = cbc +1)
		for (crc = 0; crc <= cr_runlength; crc = crc +1)
		for (yc  = 0; yc  <= y_runlength;  yc  = yc  +1)
		begin
			@(posedge clk);
			#1;

			y[0]  = yc;
			cr[0] = crc;
			cb[0] = cbc;

			if (debug)
				$display("y[0] = %d, cr[0] = %d, cb[0] = %d", y[0], cr[0], cb[0]);
		end

			$display ("\n *** Color Space Converter testbench ended ***\n");
			$stop;
	end


	integer n;
	always@(posedge clk)
	begin
		for (n = 0; n < 3; n = n +1)
		begin
			y[n +1]  <= #1 y[n];
			cr[n +1] <= #1 cr[n];
			cb[n +1] <= #1 cb[n];
		end
	end

	always@(y[3] or cr[3] or cb[3])
	begin
		mr  = (y[3] * 1000) + (1403 * cr[3]);
		if (mr < 0)
			mr = 0;

		mr = mr /1000;
		if (mr > 1023)
			mr = 1023;

		mg = (y[3] * 1000) - ( (344 * cb[3]) + (714 * cr[3]) );
		if (mg < 0)
			mg = 0;

		mg = mg /1000;
		if (mg > 1023)
			mg = 1023;

		mb = (y[3] * 1000) + (1770 * cb[3]);
		if (mb < 0)
			mb = 0;

		mb = mb /1000;
		if (mb > 1023)
			mb = 1023;
	end

	always@(posedge clk)
	begin
		// check RGB results
		ir = r;
		if ( ( ir < mr - emargin) || (ir > mr + emargin) )
			$display("R-value error. Received %d, expected %d. Y = %d, Cr = %d, Cb = %d", ir, mr, y[3], cr[3], cb[3]);

		ig = g;
		if ( ( ig < mg - emargin) || (ig > mg + emargin) )
			$display("G-value error. Received %d, expected %d. Y = %d, Cr = %d, Cb = %d", ig, mg, y[3], cr[3], cb[3]);

		ib = b;
		if ( ( ib < mb - emargin) || (ib > mb + emargin) )
			$display("B-value error. Received %d, expected %d. Y = %d, Cr = %d, Cb = %d", ib, mb, y[3], cr[3], cb[3]);
	end

endmodule




