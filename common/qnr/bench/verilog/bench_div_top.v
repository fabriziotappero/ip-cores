/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Divider                   Testbench                        ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2002 Richard Herveille                        ////
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
//  $Id: bench_div_top.v,v 1.1.1.1 2002-03-26 07:25:12 rherveille Exp $
//
//  $Date: 2002-03-26 07:25:12 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

module bench_div_top();

	parameter z_width = 8;
	parameter d_width = z_width /2;

	parameter pipeline = 8;

	parameter show_div0 = 0;
	parameter show_ovf  = 0;

	//
	// internal wires
	//
	reg clk;

	integer z, d, n;
	integer dz [pipeline-1:0];
	integer dd [pipeline-1:0];
	reg [d_width -1:0] di;
	reg [z_width -1:0] zi;

	integer sr, qr;

	wire [d_width :0] s, q;
	wire div0, ovf;
	reg  [d_width :0] sc, qc;

	reg err_cnt;

	//
	// hookup division unit
	//
	div_su #(z_width) dut (
		.clk(clk),
		.ena(1'b1),
		.z(zi),
		.d(di),
		.q(q),
		.s(s),
		.div0(div0),
		.ovf(ovf)
	);

	always #2.5 clk <= ~clk;

	always@(posedge clk)
		for(n=1; n<=pipeline-1; n=n+1)
		begin
			dz[n] <= #1 dz[n-1];
			dd[n] <= #1 dd[n-1];
		end

	initial
	begin
		$display("*");
		$display("* Starting testbench");
		$display("*");
		err_cnt = 0;

		clk = 0; // start with low-level clock

		// wait a while
		@(posedge clk);

		// present data
		for(z=-(1<<(z_width -1)); z < 1<<(z_width -1); z=z+1)
		for(d=0; d< 1<<(z_width/2); d=d+1)
		begin
			zi <= z;
			di <= d;

			dz[0] <= z;
			dd[0] <= d;

			qr = dz[pipeline-1] / dd[pipeline-1];
			qc = qr;
			sr = dz[pipeline-1] - (dd[pipeline-1] * qc);
			sc = sr;

			if (!ovf)
				if ( (qc !== q) || (sc !== s) )
				begin
					$display("Result error (z/d=%d/%d). Received (q,s) = (%d,%d), expected (%d,%d)",
						dz[pipeline-1], dd[pipeline-1], q, s, qc, sc);

					err_cnt = err_cnt +1;
				end

			if (show_div0)
				if (div0)
						$display("Division by zero (z/d=%d/%d)", dz[pipeline-1], dd[pipeline-1]);

			if (show_ovf)
				if (ovf)
						$display("Overflow (z/d=%d/%d)", dz[pipeline-1], dd[pipeline-1]);

			@(posedge clk);
		end

		// wait a while
		repeat(20) @(posedge clk);

		$display("*");
		$display("* Testbench ended. Total errors = %d", err_cnt);
		$display("*");

		$stop;
	end

endmodule
