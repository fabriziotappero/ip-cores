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
//  $Id: testbench.v,v 1.1.1.1 2002-03-26 07:25:03 rherveille Exp $
//
//  $Date: 2002-03-26 07:25:03 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $


`timescale 1ns/10ps

module testbench();

	parameter emargin = 1; // we allow a small error
	parameter debug = 0;
	parameter r_runlength = 1023;
	parameter g_runlength = 1023;
	parameter b_runlength = 1023;

	// variables
	reg clk;
	reg ena;

	reg  [9:0] r [7:0];
	reg  [9:0] g [7:0];
	reg  [9:0] b [7:0];

	wire [9:0] y, cr, cb;

	integer my, mcr, mcb;
	integer iy, icr, icb;


	//
	// module body
	//

	// hookup modules
	rgb2ycrcb dut (
		.clk(clk),
		.ena(ena),
		.r(r[0]),
		.g(g[0]),
		.b(b[0]),
		.y(y),
		.cr(cr),
		.cb(cb)
	);

	always #5 clk <= ~clk;

	initial
	begin
		clk = 0;
		ena = 1;
	
		r[0] = 0;
		g[0] = 0;
		b[0] = 0;

		$display ("\n *** Color Space Converter testbench started ***\n");
	end

	always
		while ( (r[0] <= r_runlength) && (g[0] <= g_runlength) && (b[0] <= b_runlength))
			begin
				@(posedge clk);

				b[0] <= #1 b[0] +1;
				if (b[0] == b_runlength)
				begin
					b[0] <= #1 0;

					g[0] <= #1 g[0] +1;
					if (g[0] == g_runlength)
					begin
						g[0] <= #1 0;

						r[0] <= #1 r[0] +1;
					end
				end

				if (debug)
					$display("r[0] = %d, g[0] = %d, b[0] = %d", r[0], g[0], b[0]);

				if ( (r[0]==r_runlength) && (g[0]==g_runlength) && (b[0]==b_runlength) )
					begin
						$display ("\n *** Color Space Converter testbench ended ***\n");
						$stop;
					end
			end


	integer n;
	always@(posedge clk)
	begin
		for (n = 0; n < 7; n = n +1)
		begin
			r[n +1] <= #1 r[n];
			g[n +1] <= #1 g[n];
			b[n +1] <= #1 b[n];
		end
	end

	always@(r[3] or g[3] or b[3])
	begin
		my  = (299 * r[3]) + (587 * g[3]) + (114 * b[3]);
		if (my < 0)
			my = 0;

		my = my /1000;
		if (my > 1024)
			my = 1024;

		mcr = (500 * r[3]) - (419 * g[3]) - ( 81 * b[3]);
		if (mcr < 0)
			mcr = 0;

		mcr = mcr /1000;
		if (mcr > 1024)
			mcr = 1024;

		mcb = (500 * b[3]) - (169 * r[3]) - (332 * g[3]);
		if (mcb < 0)
			mcb = 0;

		mcb = mcb /1000;
		if (mcb > 1024)
			mcb = 1024;
	end

	always@(posedge clk)
	begin

		// check results
		iy = y;
		if ( ( iy < my - emargin)  || (iy > my + emargin) )
			$display("Y-value error. Received %d, expected %d. R = %d, G = %d, B = %d", y, my, r[3], g[3], b[3]);

		icr = cr;
		if ( ( icr < mcr - emargin)  || (icr > mcr + emargin) )
			$display("Cr-value error. Received %d, expected %d. R = %d, G = %d, B = %d", cr, mcr, r[3], g[3], b[3]);

		icb = cb;
		if ( ( icb < mcb - emargin)  || (icb > mcb + emargin) )
			$display("Cb-value error. Received %d, expected %d. R = %d, G = %d, B = %d", cb, mcb, r[3], g[3], b[3]);
	end

endmodule

