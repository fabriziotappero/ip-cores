/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, MAC                                       ////
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
// Xilinx Virtex-E WC: 296 CLB slices @ 64MHz
//
									 
//  CVS Log														     
//																     
//  $Id: oc54_mac.v,v 1.1.1.1 2002-04-10 09:34:41 rherveille Exp $														     
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

module oc54_mac (
	clk, ena, 
	a, b, t, p, c, d,
	sel_xm, sel_ym, sel_ya,
	bp_a, bp_b, bp_ar, bp_br,
	xm_s, ym_s,
	ovm, frct, smul, add_sub,
	result
	);

//
// parameters
//

//
// inputs & outputs
//
input         clk;
input         ena;
input  [15:0] t, p, c, d;               // TREG, p-bus, c-bus, d-bus inputs
input  [39:0] a, b;                     // accumulator inputs
input  [ 1:0] sel_xm, sel_ym, sel_ya;   // input selects
input  [39:0] bp_ar, bp_br;             // bypass accumulator a / b
input         bp_a, bp_b;               // bypass selects
input         xm_s, ym_s;               // sign extend xm, ym
input         ovm, frct, smul, add_sub;
output [39:0] result;

reg [39:0] result;

//
// variables
//
reg  [16:0] xm, ym;              // multiplier inputs
reg  [39:0] ya;                  // adder Y-input

reg  [33:0] mult_res;            // multiplier result
wire [33:0] imult_res;           // actual multiplier
reg  [39:0] iresult;             // mac-result

/////////////////
// module body //
/////////////////

//
// generate input selection
//

// xm
always@(posedge clk)
	if (ena)
		case(sel_xm) // synopsis full_case parallel_case
			2'b00 : xm <= #1 {xm_s ? t[15] : 1'b0, t};
			2'b01 : xm <= #1 {xm_s ? d[15] : 1'b0, d};
			2'b10 : xm <= #1 bp_a ? bp_ar[32:16] : a[32:16];
			2'b11 : xm <= #1 17'h0;
		endcase

// ym
always@(posedge clk)
	if (ena)
		case(sel_ym) // synopsis full_case parallel_case
			2'b00 : ym <= #1 {ym_s ? p[15] : 1'b0, p};
			2'b01 : ym <= #1 bp_a ? bp_ar[32:16] : a[32:16];
			2'b10 : ym <= #1 {ym_s ? d[15] : 1'b0, d};
			2'b11 : ym <= #1 {ym_s ? c[15] : 1'b0, c};
		endcase

// ya
always@(posedge clk)
	if (ena)
		casex(sel_ya) // synopsis full_case parallel_case
			2'b00 : ya <= #1 bp_a ? bp_ar : a;
			2'b01 : ya <= #1 bp_b ? bp_br : b;
			2'b1? : ya <= #1 40'h0;
		endcase

//
// generate multiplier
//
assign imult_res = (xm * ym); // actual multiplier

always@(xm or ym or smul or ovm or frct or imult_res)
	if (smul && ovm && frct && (xm[15:0] == 16'h8000) && (ym[15:0] == 16'h8000) )
		mult_res = 34'h7ff_ffff;
	else if (frct)
		mult_res = {imult_res[32:0], 1'b0}; // (imult_res << 1)
	else
		mult_res = imult_res;

//
// generate mac-unit
//
always@(mult_res or ya or add_sub)
	if (add_sub)
		iresult = mult_res + ya;
	else
		iresult = mult_res - ya;

//
// generate registers
//

// result
always@(posedge clk)
	if (ena)
		result <= #1 iresult;

endmodule


