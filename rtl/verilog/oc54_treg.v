/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, Temporary Register (TREG)                 ////
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
//  $Id: oc54_treg.v,v 1.1.1.1 2002-04-10 09:34:41 rherveille Exp $														     
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

module oc54_treg (
	clk, ena,
	seli, we, 
	exp, d,
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
input         seli;              // select input
input         we;                // store result
input  [ 5:0] exp;               // exponent encoder input
input  [15:0] d;                 // DB input
output [15:0] result;

reg [15:0] result;

//
// variables
//

//
// module body
//

//
// generate input selection
//

// result
always@(posedge clk)
	if (ena)
		if (we)
			result <= #1 seli ? {10'h0, exp} : d;
endmodule
