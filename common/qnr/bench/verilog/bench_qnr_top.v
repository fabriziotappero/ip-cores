/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Quantization and Rounding unit Testbench                   ////
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
//  $Id: bench_qnr_top.v,v 1.1.1.1 2002-03-26 07:25:12 rherveille Exp $
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

module bench_qnr_top();

	//
	// internal wires
	//
	reg clk;
	reg rst;

	reg dstrb;
	reg [11:0] din;
	wire den;
	wire [10:0] dout;

	reg [ 7:0] qnt_val;

	integer z, d;

	integer err_cnt;

	//
	// QNR unit
	//

	jpeg_qnr #(12) dut (
		.clk(clk),
		.ena(1'b1),
		.rst(rst),
		.dstrb(dstrb),
		.din(din),
		.qnt_val(qnt_val),
		.qnt_cnt(),
		.dout(dout),
		.douten(den)
	);


	// hookup value checker
	chk_val checker(
		.clk(clk),
		.ena(1'b1),
		.den(den),
		.din(dout)
	);

	//
	// testbench body
	//

	// generate clock
	always #2.5 clk <= ~clk;

	// initial statements
	initial
	begin

		clk = 0; // start with low-level clock
		rst = 0; // reset system
		dstrb = 1'b0;

		rst = #17 1'b1;

		// wait a while
		repeat(20) @(posedge clk);

		// present dstrb
		dstrb = #1 1'b1;
		@(posedge clk)
		dstrb = #1 1'b0;

		for(z = -(1<<11); z < (1<<11); z = z +1)
		for(d = 1; d <= 255; d = d +1)
		begin
			din     = #1 z;
			qnt_val = #1 d;

			@(posedge clk);
		end

	end


endmodule


module chk_val(clk, ena, den, din);

	parameter verbose = 0;

	//
	// inputs
	//
	input clk;
	input ena;
	input den;

	input [10:0] din;

	//
	// variables
	//
	integer z, d, q, err_cnt;
	reg [11:0] tmp;
	reg [10:0] tmp2;

	//
	// module body
	//
	initial
	begin
		$display("\n*");
		$display("* JPEG Quantizer & Rounder Testbench");
		$display("*\n");
		err_cnt = 0;

		// wait for go signal
		$display("waiting for 'den' signal ...");
		while (den !== 1'b1) @(posedge clk);

		// wait 1 clock cycle
		@(posedge clk)


		$display("Verifying quantization & rouding unit");
		for(z = -(1<<11); z < (1<<11); z = z +1)
		for(d = 1; d <= 255; d = d +1)
		begin
			if (verbose)
				$display("Z = %d, D = %d", z, d);

			q = z / d;

			tmp = q;

			if (tmp[0])
				tmp2 = (tmp >> 1) + 1;
			else
				tmp2 = (tmp >> 1);

			if (din !== tmp2)
			begin
				$display("Data compare error, received %d, expected %d (%d). Z = %d, D = %d", 
					din, tmp2, q/2, z, d);

				err_cnt = err_cnt +1;
			end

			@(posedge clk);
		end
	
		$display("\n*");
		$display("* JPEG Quantizer & Rounder Testbench Ended");
		$display("*\n");

		$display("Total errors: %d", err_cnt);
		$stop;
	end

endmodule




