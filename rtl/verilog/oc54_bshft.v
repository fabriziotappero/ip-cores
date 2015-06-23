/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, Barrel Shifter                            ////
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
// Xilinx Virtex-E WC: 348 CLB slices @ 68MHz
//
												 
//  CVS Log														     
//																     
//  $Id: oc54_bshft.v,v 1.1.1.1 2002-04-10 09:34:40 rherveille Exp $														     
//																     
//  $Date: 2002-04-10 09:34:40 $														 
//  $Revision: 1.1.1.1 $													 
//  $Author: rherveille $													     
//  $Locker:  $													     
//  $State: Exp $														 
//																     
// Change History:												     
//               $Log: not supported by cvs2svn $											 
																
`include "timescale.v"

module oc54_bshft (
	clk, ena, 
	a, b, cb, db,
	bp_a, bp_b, bp_ar, bp_br,
	l_na, sxm, seli, selo,
	t, asm, imm,
	result, co
	);

//
// parameters
//

//
// inputs & outputs
//
input         clk;
input         ena;
input  [39:0] a, b;           // accumulator
input  [15:0] cb, db;         // memory data inputs
input  [39:0] bp_ar, bp_br;   // bypass a register, bypass b register
input         bp_a, bp_b;     // bypass select
input         sxm;            // sign extend mode
input         l_na;           // logical/not arithmetic shift
input  [ 1:0] seli;           // select operand (input)
input  [ 1:0] selo;           // select operator
input  [ 5:0] t;              // TREG, 6lsbs
input  [ 4:0] asm;            // asm bits
input  [ 4:0] imm;            // 5bit immediate value
output [39:0] result;
output        co;             // carry out output

reg [39:0] result;
reg        co;

//
// variables
//

reg [ 5:0] shift_cnt;
reg [39:0] operand;

//
// module body
//


//
// generate shift count
//
always@(selo or t or asm or imm)
	case (selo) // synopsis full_case parallel_case
		2'b00: shift_cnt = t;
		2'b01: shift_cnt = {asm[4], asm};
		2'b10: shift_cnt = {imm[4], imm};
		2'b11: shift_cnt = {imm[4:3], imm[3:0]};
	endcase

//
// generate operand
//
always@(seli or bp_a or a or bp_ar or bp_b or b or bp_br or cb or db)
	case (seli) // synopsis full_case parallel_case
		2'b00 : operand = bp_b ? bp_br : b;
		2'b01 : operand = bp_a ? bp_ar : a;
		2'b10 : operand = db;       // 16bit operand databus
		2'b11 : operand = {cb, db}; // 32bit operand
	endcase

//
// generate shifter
//
always@(posedge clk)
	if (ena)
		if (l_na) // logical shift
			if (shift_cnt[5])
				begin
					result[39:32] <= #1 8'h0;
					result[31: 0] <= #1 operand[31:0] >> (~shift_cnt[4:0] +1'h1);
					co            <= #1 operand[ ~shift_cnt[4:0] ];
				end
			else if ( ~|shift_cnt[4:0] )
				begin
					result <= #1 operand;
					co     <= #1 1'b0;
				end
			else
				begin
					result[39:32] <= #1 8'h0;
					result[31: 0] <= #1 operand[31:0] << shift_cnt[4:0];
					co            <= #1 operand[ 5'h1f - shift_cnt[4:0] ];
				end
		else      // arithmetic shift
			if (shift_cnt[5])
				begin
					if (sxm)
						result <= #1 { {16{operand[39]}} ,operand} >> (~shift_cnt[4:0] +1'h1);
					else
						result <= #1 operand >> (~shift_cnt[4:0] +1'h1);
					co     <= #1 operand[ ~shift_cnt[4:0] ];
				end
			else
				begin
					result <= #1 operand << shift_cnt[4:0];
					co     <= #1 operand[ 6'h27 - shift_cnt[4:0] ];
				end

endmodule



