/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Linear Feedback Shift Register                             ////
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

//
//  CVS Log
//
//  $Id: lfsr.v,v 1.1 2002-10-29 19:45:07 rherveille Exp $
//
//  $Date: 2002-10-29 19:45:07 $
//  $Revision: 1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $

`include "timescale.v"

module lfsr (clk, ena, nReset, rst, q);

	//
	// parameters
	//
	parameter [3:0] TAPS   = 8;                // number of flip-flops in LFSR

	//
	// inputs & outputs
	//
	input clk;                                 // master clock
	input ena;                                 // clock enable
	input nReset;                              // asynchronous active low reset
	input rst;                                 // synchronous active high reset

	output [TAPS:1] q;                         // LFSR output
	reg [TAPS:1] q;

	//
	// Module body
	//
	function lsb;
	   input [TAPS-1:0] q;

	   case (TAPS)
	       2: lsb = ~q[0];
	       3: lsb = q[3] ^ q[2];
	       4: lsb = q[4] ^ q[3];
	       5: lsb = q[5] ^ q[3];
	       6: lsb = q[6] ^ q[5];
	       7: lsb = q[7] ^ q[6];
	       8: lsb = q[8] ^ q[6] ^ q[5] ^ q[4];
	       9: lsb = q[9] ^ q[5];
	      10: lsb = q[10] ^ q[7];
	      11: lsb = q[11] ^ q[9];
	      12: lsb = q[12] ^ q[6] ^ q[4] ^ q[1];
	      13: lsb = q[13] ^ q[4] ^ q[3] ^ q[1];
	      14: lsb = q[14] ^ q[5] ^ q[3] ^ q[1];
	      15: lsb = q[15] ^ q[14];
	      16: lsb = q[16] ^ q[15] ^ q[13] ^ q[4];
	   endcase
	endfunction

	always @(posedge clk or negedge nReset)
	  if (~nReset)	q <= #1 0;
	  else if (rst)	q <= #1 0;
	  else if (ena)	q <= #1 {q[TAPS-1:1], lsb(q)};
endmodule

