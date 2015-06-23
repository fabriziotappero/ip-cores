/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, accumulator                               ////
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
// Xilinx Virtex-E WC: 96 CLB slices @ 51MHz
//
									 
//  CVS Log														     
//																     
//  $Id: oc54_acc.v,v 1.1.1.1 2002-04-10 09:34:39 rherveille Exp $														     
//																     
//  $Date: 2002-04-10 09:34:39 $														 
//  $Revision: 1.1.1.1 $													 
//  $Author: rherveille $													     
//  $Locker:  $													     
//  $State: Exp $														 
//																     
// Change History:												     
//               $Log: not supported by cvs2svn $											 
																
`include "timescale.v"

module oc54_acc (
	clk, ena,
	seli, we,
	a, b, alu, mac,
	ovm, rnd,
	zf, ovf,
	result, bp_result
	);

//
// parameters
//

//
// inputs & outputs
//
input         clk;
input         ena;
input  [ 1:0] seli;              // select input
input         we;                // write enable
input  [39:0] a, b, alu, mac;    // accumulators, alu, mac input
input         ovm, rnd;          // overflow mode, saturate, round
output        ovf, zf;           // carry out, overflow, zero, tc-out
output [39:0] result;            // accumulator register output
output [39:0] bp_result;         // accumulator register bypass output

reg        ovf, zf;
reg [39:0] result;

//
// variables
//
reg  [39: 0] sel_r, iresult; // select results, final result
wire         iovf;

//
// module body
//

//
// generate input selection
//

// input selection & MAC-rounding
always@(seli or a or b or alu or mac or rnd)
	case(seli) // synopsis full_case parallel_case
		2'b00: sel_r = a;
		2'b01: sel_r = b;
		2'b10: sel_r = alu;
		2'b11: sel_r = rnd ? (mac + 16'h8000) & 40'hff_ffff_0000 : mac;
	endcase

// overflow detection
// no overflow when:
// 1) all guard bits are set (valid negative number)
// 2) no guard bits are set (valid positive number)
assign iovf = !( &sel_r[39:32] | &(~sel_r[39:32]) );

// saturation
always@(iovf or ovm or sel_r)
	if (ovm & iovf)
		if (sel_r[39]) // negate overflow
			iresult <= #1 40'hff_8000_0000;
		else             // positive overflow
			iresult <= #1 40'h00_7fff_ffff;
	else
			iresult <= #1 sel_r;

//
// generate registers
//

// generate bypass output
assign bp_result = iresult;

// result
always@(posedge clk)
	if (ena & we)
		result <= #1 iresult;

// ovf, zf
always@(posedge clk)
	if (ena & we)
		begin
			ovf <= #1 iovf;
			zf  <= #1 ~|iresult;
		end

endmodule

