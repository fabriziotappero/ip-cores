/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  ALU                                                        ////
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
//  $Id: alu.v,v 1.3 2002-10-01 12:44:24 rudi Exp $
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

module alu(s1, s2, mask, out, op, c_in, c, dc, z);
input  [7:0]	s1, s2, mask;
output [7:0]	out;
input  [3:0]	op;
input		c_in;
output		c, dc, z;

parameter	ALU_ADD		= 4'h0,
		ALU_SUB 	= 4'h1,
		ALU_INC 	= 4'h2,
		ALU_DEC 	= 4'h3,

		ALU_AND 	= 4'h4,
		ALU_CLR 	= 4'h5,
		ALU_NOT 	= 4'h6,
		ALU_IOR 	= 4'h7,
		ALU_MOV 	= 4'h8,
		ALU_MOVW	= 4'h9,
		ALU_RLF 	= 4'ha,
		ALU_RRF 	= 4'hb,
		ALU_SWP 	= 4'hc,
		ALU_XOR 	= 4'hd,
		ALU_BCF 	= 4'he,
		ALU_BSF 	= 4'hf;

wire  [7:0]	out;
wire		co, bo;
wire		c;
wire		z;
wire [5:0]	tmp_add;
wire		borrow_dc;

wire [7:0]	add_sub_out;
wire 		add_sub_sel;
wire [7:0]	s2_a;
wire [8:0]	rlf_out, rrf_out;
wire [7:0]	out_next1, out_next2, out_next3;

/*
reg		cout;
reg  [7:0]	out_t;
always @(op or s1 or s2 or mask or c_in)
   begin
   	cout = 0;
	  case(op)	// synopsys full_case parallel_case
	   ALU_ADD:	{cout, out_t} = s1 + s2;
	   ALU_AND:	out_t = s1 & s2;
	   ALU_CLR:	out_t = 8'h00;
	   ALU_NOT:	out_t = ~s1;
	   ALU_DEC:	out_t = s1 - 1;
	   ALU_INC:	out_t = s1 + 1;
	   ALU_IOR:	out_t = s1 | s2;
	   ALU_MOV:	out_t = s1;
	   ALU_MOVW:	out_t = s2;
	   ALU_RLF:	{cout, out_t} = {s1[7:0], c_in};
	   ALU_RRF:	{cout, out_t} = {s1[0], c_in, s1[7:1]};
	   ALU_SUB:	{cout, out_t} = s1 - s2;
	   ALU_SWP:	out_t = {s1[3:0], s1[7:4]};
	   ALU_XOR:	out_t = s1 ^ s2;
	   ALU_BCF:	out_t = s1 & ~mask;
	   ALU_BSF:	out_t = s1 | mask;
	  endcase
   end
*/

assign  rlf_out = {s1[7:0], c_in};
assign  rrf_out = {s1[0], c_in, s1[7:1]};

assign	add_sub_sel = (op[3:2]==2'b0);

mux4_8 u2( .sel(op[3:2]), .in0(add_sub_out), .in1(out_next1), .in2(out_next2),    .in3(out_next3),    .out(out) );
mux4_8 u3( .sel(op[1:0]), .in0(s1 & s2),     .in1(8'h00),     .in2(~s1),          .in3(s1 | s2),      .out(out_next1) );
mux4_8 u4( .sel(op[1:0]), .in0(s1),          .in1(s2),        .in2(rlf_out[7:0]), .in3(rrf_out[7:0]), .out(out_next2) );
mux4_8 u5( .sel(op[1:0]), .in0({s1[3:0], s1[7:4]}), .in1(s1^s2), .in2(s1 & ~mask), .in3(s1 | mask), .out(out_next3) );

mux2_8 u0( .sel(op[1]), .in0(s2), .in1(8'h01), .out(s2_a) );

add_sub8_co u1( .sub(op[0]), .opa(s1), .opb(s2_a), .out(add_sub_out), .co(co) );

// C bit generation
assign c = add_sub_sel ? co : op[0] ? rrf_out[8] : rlf_out[8];

// Z Bit generation
assign z = (out==8'h0);

// DC Bit geberation
// This section is really bad, but not in the critical path,
// so I leave it alone for now ....
assign borrow_dc = s1[3:0] >= s2[3:0];
assign tmp_add = s1[3:0] + s2[3:0];
assign dc = (op==ALU_SUB) ? borrow_dc : tmp_add[4];

endmodule
