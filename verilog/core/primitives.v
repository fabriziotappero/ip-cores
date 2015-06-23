/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  Primitives                                                 ////
////                                                             ////
////                                                             ////
////  Author: Rudolf Usselmann                                   ////
////          rudi@asics.ws                                      ////
////                                                             ////
////                                                             ////
////  D/L from: http://www.opencores.org/cores/minirisc/         ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2000-2002 Rudolf Usselmann                    ////
////                         www.asics.ws                        ////
////                         rudi@asics.ws                       ////
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
//  $Id: primitives.v,v 1.3 2002-10-01 12:44:24 rudi Exp $
//
//  $Date: 2002-10-01 12:44:24 $
//  $Revision: 1.3 $
//  $Author: rudi $
//  $Locker:  $
//  $State: Exp $
//
// Change History:
//               $Log: not supported by cvs2svn $
//               Revision 1.2  2002/09/27 15:35:40  rudi
//               Minor update to newer devices ...
//
//
//
//
//
//
//
//
//
//
//

`timescale 1ns / 10ps

// Mux 4:1 8 bits wide
module mux4_8(sel, in0, in1, in2, in3, out);
input	[1:0]	sel;
input	[7:0]	in0, in1, in2, in3;
output	[7:0]	out;

reg	[7:0]	out;

always @(sel or in0 or in1 or in2 or in3)
	case(sel)	// synopsys full_case parallel_case
	  0: out = in0;
	  1: out = in1;
	  2: out = in2;
	  3: out = in3;
	endcase

endmodule

// 8 bit comparator
module cmp8_eq(a,b,eq);
input	[7:0]	a,b;
output		eq;

assign eq = (a==b);

endmodule

// MUX 2:1 7 bits wide
module mux2_7(sel, in0, in1, out);
input		sel;
input	[6:0]	in0, in1;
output	[6:0]	out;

assign out = sel ? in1 : in0;

endmodule

// Mux 8:1 1 bit wide
module mux8_1( sel, in, out);
input	[2:0]	sel;
input	[7:0]	in;
output		out;

assign	out = in[sel];

endmodule

// Mux 2:1 8 bits wide
module mux2_8(sel, in0, in1, out);
input		sel;
input	[7:0]	in0, in1;
output	[7:0]	out;

assign out = sel ? in1 : in0;

endmodule

// Mux 8:1 8 bits wide
module mux8_8(sel, in0, in1, in2, in3, in4, in5, in6, in7, out);
input	[2:0]	sel;
input	[7:0]	in0, in1, in2, in3, in4, in5, in6, in7;
output	[7:0]	out;

reg	[7:0]	out;

always @(sel or in0 or in1 or in2 or in3 or in4 or in5 or in6 or in7)
	case(sel)	// synopsys full_case parallel_case
	   3'd0:	out = in0;
	   3'd1:	out = in1;
	   3'd2:	out = in2;
	   3'd3:	out = in3;
	   3'd4:	out = in4;
	   3'd5:	out = in5;
	   3'd6:	out = in6;
	   3'd7:	out = in7;
	endcase

endmodule

// Mux 2:1 11 bits wide
module mux2_11(sel, in0, in1, out);
input		sel;
input	[10:0]	in0, in1;
output	[10:0]	out;

assign out = sel ? in1 : in0;

endmodule


// 8bit Add/Sub with carry/borrow out
module add_sub8_co(sub, opa, opb, out, co);
input		sub;
input	[7:0]	opa, opb;
output	[7:0]	out;
output		co;

assign	{co, out} = sub ? (opa - opb) : (opa + opb);

endmodule

// 11 bit incrementer
module inc11(in, out);
input	[10:0]	in;
output	[10:0]	out;

assign out = in + 11'h1;

endmodule

// 8 bit incrementer
module inc8(in, out);
input	[7:0]	in;
output	[7:0]	out;

assign out = in + 8'h1;

endmodule

// A Basic Synchrounous FIFO (4 entries deep)
module sfifo4x11(clk, push, din, pop, dout);
input		clk;
input		push;
input	[10:0]	din;
input		pop;
output	[10:0]	dout;

reg	[10:0]	stack1, stack2, stack3, stack4;

assign dout = stack1;

always @(posedge clk)
   begin
	if(push)	// PUSH stack
	   begin
		stack4 <= #1 stack3;
		stack3 <= #1 stack2;
	   	stack2 <= #1 stack1;
		stack1 <= #1 din;
	   end
	if(pop)		// POP stack
	   begin
		stack1 <= #1 stack2;
		stack2 <= #1 stack3;
		stack3 <= #1 stack4;
	   end
   end

endmodule


