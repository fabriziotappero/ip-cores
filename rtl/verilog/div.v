/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Non-restoring singed dividor                               ////
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
//  $Id: div.v,v 1.1.1.1 2002-10-29 20:29:11 rherveille Exp $
//
//  $Date: 2002-10-29 20:29:11 $
//  $Revision: 1.1.1.1 $
//  $Author: rherveille $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//

`include "timescale.v"

module div(clk, ena, z, d, q, s);

	//
	// parameters
	//
	parameter z_width = 16;
	parameter d_width = z_width /2;

	//
	// inputs & outputs
	//
	input clk;               // system clock
	input ena;               // clock enable

	input  [z_width -1:0] z; // divident
	input  [d_width -1:0] d; // divisor
	output [z_width -1:0] q; // quotient
	output [z_width -1:0] s; // remainder

	//
	// functions
	//
	function sc;
	  input [z_width:0] si;
	  input [d_width:0] di;
	begin
	    sc = si[z_width] ~^ di[d_width];
	end
	endfunction

	function [z_width:0] gen_q;
	  input [z_width:0] q;
	  input             q0;
	begin
	    gen_q = {(q << 1), q0};
	end
	endfunction

	function [z_width:0] gen_s;
	  input [z_width:0] si;
	  input [z_width:0] di;
	  input             sel;
	begin
	    if(sel)
	      gen_s = {si[z_width-1:0], 1'b0} - di;
	    else
	      gen_s = {si[z_width-1:0], 1'b0} + di;
	end
	endfunction

	//
	// variables
	//
	reg [z_width:0] q_pipe  [z_width:0];
	reg [z_width:0] s_pipe  [z_width:0];
	reg [z_width:0] d_pipe  [z_width:0];
	reg [z_width:0] qb_pipe;

	//
	// perform parameter checks
	//
	// synopsys translate_off
	initial
	begin
	  if(d_width > z_width)
	    $display("div.v parameter error (d_width > z_width). Divisor width larger than divident width.");
	end
	// synopsys translate_on

	integer n;

	// generate divisor (d) pipe
	always @(d)
	  d_pipe[0] <= {d[d_width -1], d, {(z_width-d_width){1'b0}} };

	always @(posedge clk)
	  if(ena)
	    for(n=1; n < z_width; n=n+1)
	       d_pipe[n] <= #1 d_pipe[n-1];

	// generate sign comparator pipe
	always
	  begin
	    #1;
	    for(n=0; n < z_width; n=n+1)
	       qb_pipe[n] <= sc(s_pipe[n], d_pipe[n]);
	  end

	// generate internal remainder pipe
	always@(z)
		s_pipe[0] <= {z[z_width -1], z};

	always @(posedge clk)
	  if(ena)
	    for(n=1; n < z_width; n=n+1)
	       s_pipe[n] <= #1 gen_s(s_pipe[n-1], d_pipe[n-1], qb_pipe[n-1]);

	// generate quotient pipe
	always @(qb_pipe[0])
	  q_pipe[0] <= #1 { {(z_width){1'b0}}, qb_pipe[0]};

	always @(posedge clk)
	  if(ena)
	    for(n=1; n < z_width; n=n+1)
	       q_pipe[n] <= #1 {q_pipe[n-1], qb_pipe[n]};

	wire [z_width:0] last_q;
	assign last_q = q_pipe[z_width -1];

	always @(posedge clk)
	  if(ena)
	    q_pipe[z_width] <= #1 {!last_q[z_width-1], last_q[z_width-2:0], 1'b1};

	// assign outputs
	assign q = q_pipe[z_width];
	assign s = s_pipe[z_width];
endmodule


