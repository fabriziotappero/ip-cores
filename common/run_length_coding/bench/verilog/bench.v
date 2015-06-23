/////////////////////////////////////////////////////////////////////
////                                                             ////
////  JPEG Run-Length testbench                                  ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
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
//  $Id: bench.v,v 1.1.1.1 2002-03-26 07:25:12 rherveille Exp $
//
//  $Date: 2002-03-26 07:25:12 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $


`timescale 1ns/10ps

module bench();

	//
	// variables
	//

	reg        clk;
	reg [11:0] din;
	reg        go;
	reg        rst;

	wire [ 3:0] rlen, size;
	wire [11:0] amp;
	wire        den;

	//
	// module body
	//

	// hookup rle
	jpeg_rle dut(
		.clk(clk),
		.rst(rst),
		.ena(1'b1),
		.go(go),
		.din(din),
		.rlen(rlen),
		.size(size),
		.amp(amp),
		.den(den)
	);

	always #5 clk <= !clk;

	initial
	begin
		clk = 0;
		go  = 1'b0;

		// reset system
		rst = 0;
		#26; // wait a while
		rst = 1;

		//send sample block through rle encoder

		@(posedge clk);

		din <= 15;
		go  <= 1'b1;
		@(posedge clk);

		din <= 0;
		go  <= 1'b0;
		@(posedge clk);

		din <= -2;
		@(posedge clk);

		din <= -1;
		repeat(3)@(posedge clk);

		din <= 0;
		repeat(2)@(posedge clk);

		din <= -1;
		@(posedge clk);

		din <= 0;
		repeat(64-9)@(posedge clk);

		// wait a while
		repeat(20)@(posedge clk);

		$stop;

	end
endmodule




