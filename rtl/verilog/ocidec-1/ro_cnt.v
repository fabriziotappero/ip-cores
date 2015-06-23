/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Run-Once counter                                           ////
////                                                             ////
////  Author: Richard Herveille                                  ////
////          richard@asics.ws                                   ////
////          www.asics.ws                                       ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2001, 2002 Richard Herveille                  ////
////                          richard@asics.ws                   ////
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
//  $Id: ro_cnt.v,v 1.2 2002-02-16 10:42:17 rherveille Exp $
//
//  $Date: 2002-02-16 10:42:17 $
//  $Revision: 1.2 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//


///////////////////////////
// run-once down-counter //
///////////////////////////

// counts D+1 cycles before generating 'DONE'

`include "timescale.v"

module ro_cnt (clk, nReset, rst, cnt_en, go, done, d, q);

	// parameter declaration
	parameter SIZE = 8;

	parameter UD = 1'b0;         // default count down
	parameter ID = {SIZE{1'b0}}; // initial data after reset

	// inputs & outputs
	input  clk;           // master clock
	input  nReset;        // asynchronous active low reset
	input  rst;           // synchronous active high reset
	input  cnt_en;        // count enable
	input  go;            // load counter and start sequence
	output done;          // done counting
	input  [SIZE-1:0] d;  // load counter value
	output [SIZE-1:0] q;  // current counter value

	// variable declarations
	reg rci;
	wire nld, rco;

	//
	// module body
	//

	always@(posedge clk or negedge nReset)
		if (~nReset)
			rci <= #1 1'b0;
		else if (rst)
			rci <= #1 1'b0;
		else //if (cnt_en)
			rci <= #1 go | (rci & !rco);

	assign nld = !go;

	// hookup counter
	ud_cnt #(SIZE, ID) cnt (.clk(clk), .nReset(nReset), .rst(rst), .cnt_en(cnt_en),
		.ud(UD), .nld(nld), .d(d), .q(q), .rci(rci), .rco(rco));


	// assign outputs

	assign done = rco;

endmodule



