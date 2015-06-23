/////////////////////////////////////////////////////////////////////
////                                                             ////
////  OpenCores54 DSP, ALU                                       ////
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
// Xilinx Virtex-E WC: 617 CLB slices @ 58MHz
//
											 
//  CVS Log														     
//																     
//  $Id: oc54_alu.v,v 1.1.1.1 2002-04-10 09:34:40 rherveille Exp $														     
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
`include "oc54_alu_defines.v"

module oc54_alu (
	clk, ena, inst,
	seli, doublet,
	a, b, s, t, cb,
	bp_a, bp_b,	bp_ar, bp_br,
	c16, sxm, ci, tci, 
	co, tco,
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
input  [ 6:0] inst;              // instruction
input  [ 1:0] seli;              // input selection
input         doublet;           // {T, T}
input  [39:0] a, b, s;           // accumulators + shifter inputs
input  [15:0] t, cb;             // TREG + c-bus input
input  [39:0] bp_ar, bp_br;      // bypass a register, bypass b register
input         bp_a, bp_b;        // bypass select
input         c16, sxm;          // dual-mode, sign-extend-mode, 
input         ci, tci;           // carry in, tc-in
output        co, tco;           // carry out, overflow, zero, tc-out
output [39:0] result;

reg        co, tco;
reg [39:0] result;

//
// variables
//
reg [39:0] iresult;
reg        itco, ico;
reg [39:0] x;

wire [39:0] y;

reg dc16, dci, dtci;

reg [6:0] dinst;


//
// module body
//

//
// generate input selection, barrel-shifter has 1cycle delay
//
always@(posedge clk)
	if (ena)
		case(seli) // synopsis full_case parallel_case
			2'b00 : 
				if (doublet)
					x <= #1 { {39-31{1'b0}}, t, t}; // is this correct ??
				else
					x <= #1 { {39-15{sxm ? t[15] : 1'b0}}, t};
			2'b01 : x <= #1 bp_a ? bp_ar : a;
			2'b10 : x <= #1 bp_b ? bp_br : b;
			2'b11 : x <= #1 { {39-15{sxm ? cb[15] : 1'b0}}, cb}; 
		endcase

assign y = s; // second input from barrel-shifter

//
// delay control signals
//
always@(posedge clk)
	if (ena)
		begin
			dc16   <= #1 c16;
			dci    <= #1 ci;
			dtci   <= #1 tci;
			dinst  <= #1 inst;
		end

//
// generate ALU
//
always@(dinst or x or y or dc16 or dtci or dci)
begin

	ico     = dci;
	itco    = dtci;
	iresult = x;

	case(dinst) // synopsis full_case parallel_case
		//
		// Arithmetic instructions
		//
		`ABS : // absolute value
			begin
				if (x[39])
					iresult = (~x) + 1'b1;
				else
					iresult = x;

					ico     = ~|(iresult);
			end

		`ADD : // ALSO ADDC, ADDS. For ADD, ADDS ci = 1'b0;
			begin
				iresult = x + y + dci;
				ico     = iresult[32];
			end

		`MAX : // ALSO MIN. MAX: x==accA, y==accB, MIN: x==accB, y ==accA
			begin
					ico     = (x > y);
					iresult = (x > y) ? x : y;
			end

		`NEG :
			begin
					iresult = (~x) + 1'b1;
					ico     = ~|(iresult);
			end

		`SUB : // ALSO SUBB, SUBS. For SUB, SUBS ci = 1'b1;
			begin
				iresult = x - y - ~dci;
				ico     = iresult[32];
			end

		`SUBC : // subtract conditional (for division)
			begin
				// FIXME: Is this correct ?? How does SUBC affect the carry bit ?
				iresult = x - y;
				ico     = iresult[32];

				if ( iresult > 0 )
//					iresult = (iresult << 1) + 1'b1;
					iresult = ({x[38:0], 1'b0}) + 1'b1;
				else
//					iresult = x << 1;
					iresult = {x[38:0], 1'b0};
			end
					

		//
		// Dual Precision Arithmetic instructions
		//
		`DADD :
			if (dc16)  // dual add          result_hi/lo = x_hi/lo + y_hi/lo
				begin
					iresult[39:16] = x[31:16] + y[31:16];
					iresult[15: 0] = x[15: 0] + y[15: 0]; 
				end
			else      // 32bit add         result = x + y
					{ico, iresult} = x + y;
				
		`DSUB :
			if (dc16) // dual subtract     result_hi/lo = x_hi/lo - y_hi/lo
				begin
					iresult[39:16] = x[31:16] - y[31:16];
					iresult[15: 0] = x[15: 0] - y[15: 0]; 
				end
			else     // 32bit subtract    result = x - y
				begin
					iresult = x - y;
					ico     = iresult[32];
				end

		`DRSUB : // ALSO DSUBT: make sure x = {T, T}
			if (dc16)	// dual reverse sub. result_hi/lo = y_hi/lo - x_hi/lo
				begin
					iresult[39:16] = y[31:16] - x[31:16];
					iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else     // 32bit reverse sub.result = y - x
				begin
					iresult = y - x;
					ico     = iresult[32];
				end

		`DSUBADD : // DSADT: make  sure x = {T, T}
			if (dc16)
				begin
						iresult[39:16] = y[31:16] - x[31:16];
						iresult[15: 0] = y[15: 0] + x[15: 0]; 
				end
			else
				begin
					iresult = y - x;
					ico     = iresult[32];
				end
	
		`DADDSUB : // DADST: make sure x = {T, T}
			if (dc16)
				begin
						iresult[39:16] = y[31:16] + x[31:16];
						iresult[15: 0] = y[15: 0] - x[15: 0]; 
				end
			else
				begin
					iresult = x + y;
					ico     = iresult[32];
				end
				
		//
		// logical instructions
		//
		`NOT : // CMPL
					iresult = ~x;

		`AND :
					iresult = x & y;

		`OR :
					iresult = x | y;

		`XOR :
					iresult = x ^ y;

		//
		// shift instructions
		//
		`ROL :
			begin
					iresult[39:32] = 8'h0;
					iresult[31: 0] = {x[30:0], dci};
					ico            = x[31];
			end

		`ROLTC :
			begin
					iresult[39:32] = 8'h0;
					iresult[31: 0] = {x[30:0], dtci};
					ico            = x[31];
			end

		`ROR :
			begin
					iresult[39:32] = 8'h0;
					iresult[31: 0] = {dci, x[31:1]};
					ico            = x[0];
			end

		`SHFT_CMP :
			if (x[31] & x[30])
				begin
//					iresult = x << 1;
					iresult = {x[38:0], 1'b0};
					itco    = 1'b0;
				end
			else
				begin
					iresult = x;
					itco    = 1'b1;
				end

		//
		// bit test and compare instructions
		//
		`BITF :
					itco = ~|( x[15:0] & y[15:0] );

		`BTST : // BIT, BITT y=Smem, x=imm or T
					itco = y[ ~x[3:0] ]; // maybe do ~x at a higher level ??

		`CMP_EQ	: // ALSO CMPM. for CMPM [39:16]==0
					itco = ~|(x ^ y);
		`CMP_LT :
					itco = x < y;
		`CMP_GT :
					itco = x > y;
		`CMP_NEQ :
					itco = |(x ^ y);

		//
		// NOP
		//
		default :
			begin
				ico     = dci;
				itco    = dtci;
				iresult = x;
			end
	endcase				
end


//
// generate registers
//

// result
always@(posedge clk)
	if (ena)
		result <= #1 iresult;

// tco, co
always@(posedge clk)
	if (ena)
		begin
			tco <= #1 itco;
			co  <= #1 ico;
		end

endmodule


