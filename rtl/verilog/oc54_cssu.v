/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, Compare Select and Store Unit (CSSU)      ////
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
				
//
// NOTE: Read the pipeline information for the CMPS instruction
//

//
// Xilinx Virtex-E WC: 41 CLB slices @ 130MHz
//
									 
//  CVS Log														     
//																     
//  $Id: oc54_cssu.v,v 1.1.1.1 2002-04-10 09:34:41 rherveille Exp $														     
//																     
//  $Date: 2002-04-10 09:34:41 $														 
//  $Revision: 1.1.1.1 $													 
//  $Author: rherveille $													     
//  $Locker:  $													     
//  $State: Exp $														 
//																     
// Change History:												     
//               $Log: not supported by cvs2svn $											 
																
`include "timescale.v"

module oc54_cssu (
	clk, ena,
	sel_acc, is_cssu,
	a, b, s,
	tco,
	trn, result
	);

//
// parameters
//

//
// inputs & outputs
//
input         clk;
input         ena;
input         sel_acc;           // select input
input         is_cssu;           // is this a cssu operation ?
input  [39:0] a, b, s;           // accumulators, shifter input
output        tco;               // tc-out
output [15:0] trn, result;

reg        tco;
reg [15:0] trn, result;

//
// variables
//

wire [31:0] acc;      // selected accumulator
wire        acc_cmp;  // acc[31;16]>acc[15:0] ??
//
// module body
//

//
// generate input selection
//

// input selection
assign acc = sel_acc ? b[31:0] : a[31:0];

assign acc_cmp = acc[31:16] > acc[15:0];

// result
always@(posedge clk)
	if (ena)
	begin
		if (is_cssu)
			if (acc_cmp)
				result <= #1 acc[31:16];
			else
				result <= #1 acc[15:0];
		else
			result <= #1 s[15:0];

		if (is_cssu)
			trn <= #1 {trn[14:0], ~acc_cmp};

		tco <= #1 ~acc_cmp;
	end
endmodule


