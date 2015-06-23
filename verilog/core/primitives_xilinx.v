/////////////////////////////////////////////////////////////////////
////                                                             ////
////  Mini-RISC-1                                                ////
////  Prescaler and Wachdog Counter                              ////
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
//  $Id: primitives_xilinx.v,v 1.3 2002-10-01 12:44:24 rudi Exp $
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

// LIB_TAG
// synopsys translate_off
`include "XilinxCoreLib/C_ADDSUB_V1_0.v"
`include "XilinxCoreLib/C_MUX_BUS_V1_0.v"
`include "XilinxCoreLib/C_COMPARE_V1_0.v"
`include "XilinxCoreLib/C_MUX_BIT_V1_0.v"
`include "XilinxCoreLib/C_MEM_DP_BLOCK_V1_0.v"
`include "XilinxCoreLib/C_REG_FD_V1_0.v"
// synopsys translate_on
// LIB_TAG_END


// Mux 4:1 8 bits wide
module mux4_8(sel, in0, in1, in2, in3, out);
input	[1:0]	sel;
input	[7:0]	in0, in1, in2, in3;
output	[7:0]	out;

// INST_TAG
xilinx_mux4_8 u0 (
	.MA0(in0[0]),
	.MA1(in0[1]),
	.MA2(in0[2]),
	.MA3(in0[3]),
	.MA4(in0[4]),
	.MA5(in0[5]),
	.MA6(in0[6]),
	.MA7(in0[7]),

	.MB0(in1[0]),
	.MB1(in1[1]),
	.MB2(in1[2]),
	.MB3(in1[3]),
	.MB4(in1[4]),
	.MB5(in1[5]),
	.MB6(in1[6]),
	.MB7(in1[7]),

	.MC0(in2[0]),
	.MC1(in2[1]),
	.MC2(in2[2]),
	.MC3(in2[3]),
	.MC4(in2[4]),
	.MC5(in2[5]),
	.MC6(in2[6]),
	.MC7(in2[7]),

	.MD0(in3[0]),
	.MD1(in3[1]),
	.MD2(in3[2]),
	.MD3(in3[3]),
	.MD4(in3[4]),
	.MD5(in3[5]),
	.MD6(in3[6]),
	.MD7(in3[7]),

	.S0(sel[0]),
	.S1(sel[1]),

	.O0(out[0]),
	.O1(out[1]),
	.O2(out[2]),
	.O3(out[3]),
	.O4(out[4]),
	.O5(out[5]),
	.O6(out[6]),
	.O7(out[7])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_mux4_8 (MA,MB,MC,MD,S,O);	// synthesis black_box
input [7:0] MA;
input [7:0] MB;
input [7:0] MC;
input [7:0] MD;
input [1:0] S;
output [7:0] O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BUS_V1_0 #(
		"00000000",
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		4,
		0,
		2,
		"00000000",
		0,
		1,
		8)
	inst (
		.MA(MA),
		.MB(MB),
		.MC(MC),
		.MD(MD),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// 8 bit comparator
module cmp8_eq(a,b,eq);
input	[7:0]	a,b;
output		eq;

// INST_TAG
xilinx_cmp8_eq u0 (
	.A0(a[0]),
	.A1(a[1]),
	.A2(a[2]),
	.A3(a[3]),
	.A4(a[4]),
	.A5(a[5]),
	.A6(a[6]),
	.A7(a[7]),

	.B0(b[0]),
	.B1(b[1]),
	.B2(b[2]),
	.B3(b[3]),
	.B4(b[4]),
	.B5(b[5]),
	.B6(b[6]),
	.B7(b[7]),

	.A_EQ_B(eq)	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_cmp8_eq (A,B,A_EQ_B);	// synthesis black_box
input [7 : 0] A;
input [7 : 0] B;
output A_EQ_B;

// synopsys translate_off
// synthesis translate_off
	C_COMPARE_V1_0 #(
		"0",
		0,
		"0",
		1,
		1,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		8)
	inst (
		.A(A),
		.B(B),
		.A_EQ_B(A_EQ_B));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// MUX 2:1 7 bits wide
module mux2_7(sel, in0, in1, out);
input		sel;
input	[6:0]	in0, in1;
output	[6:0]	out;

// INST_TAG
xilinx_mux2_7 u0 (
	.MA0(in0[0]),
	.MA1(in0[1]),
	.MA2(in0[2]),
	.MA3(in0[3]),
	.MA4(in0[4]),
	.MA5(in0[5]),
	.MA6(in0[6]),

	.MB0(in1[0]),
	.MB1(in1[1]),
	.MB2(in1[2]),
	.MB3(in1[3]),
	.MB4(in1[4]),
	.MB5(in1[5]),
	.MB6(in1[6]),

	.S0(sel),

	.O0(out[0]),
	.O1(out[1]),
	.O2(out[2]),
	.O3(out[3]),
	.O4(out[4]),
	.O5(out[5]),
	.O6(out[6])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_mux2_7 (MA,MB,S,O);	// synthesis black_box
input [6 : 0] MA;
input [6 : 0] MB;
input [0 : 0] S;
output [6 : 0] O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BUS_V1_0 #(
		"0000000",
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		2,
		0,
		1,
		"0000000",
		0,
		1,
		7)
	inst (
		.MA(MA),
		.MB(MB),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/


// Mux 8:1 1 bit wide
module mux8_1( sel, in, out);
input	[2:0]	sel;
input	[7:0]	in;
output		out;

// INST_TAG
xilinx_mux8_1 u0 (
	.M0(in[0]),
	.M1(in[1]),
	.M2(in[2]),
	.M3(in[3]),
	.M4(in[4]),
	.M5(in[5]),
	.M6(in[6]),
	.M7(in[7]),

	.S0(sel[0]),
	.S1(sel[1]),
	.S2(sel[2]),


	.O(out));
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_mux8_1 (M,S,O);	// synthesis black_box
input [7 : 0] M;
input [2 : 0] S;
output O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BIT_V1_0 #(
		"0",
		1,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		8,
		3,
		"0",
		0,
		1)
	inst (
		.M(M),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// Mux 2:1 8 bits wide
module mux2_8(sel, in0, in1, out);
input		sel;
input	[7:0]	in0, in1;
output	[7:0]	out;

// INST_TAG
xilinx_mux2_8 u0(
	.MA0(in0[0]),
	.MA1(in0[1]),
	.MA2(in0[2]),
	.MA3(in0[3]),
	.MA4(in0[4]),
	.MA5(in0[5]),
	.MA6(in0[6]),
	.MA7(in0[7]),

	.MB0(in1[0]),
	.MB1(in1[1]),
	.MB2(in1[2]),
	.MB3(in1[3]),
	.MB4(in1[4]),
	.MB5(in1[5]),
	.MB6(in1[6]),
	.MB7(in1[7]),

	.S0(sel),

	.O0(out[0]),
	.O1(out[1]),
	.O2(out[2]),
	.O3(out[3]),
	.O4(out[4]),
	.O5(out[5]),
	.O6(out[6]),
	.O7(out[7])	);
// INST_TAG_END

endmodule


/*
// MOD_TAG
module xilinx_mux2_8 (MA, MB, S, O);	// synthesis black_box
input [7 : 0] MA;
input [7 : 0] MB;
input [0 : 0] S;
output [7 : 0] O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BUS_V1_0 #(
		"00000000",
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		2,
		0,
		1,
		"00000000",
		0,
		1,
		8)
	inst (
		.MA(MA),
		.MB(MB),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// Mux 8:1 8 bits wide
module mux8_8(sel, in0, in1, in2, in3, in4, in5, in6, in7, out);
input	[2:0]	sel;
input	[7:0]	in0, in1, in2, in3, in4, in5, in6, in7;
output	[7:0]	out;

// INST_TAG
xilinx_mux8_8 u0 (
	.MA0(in0[0]),
	.MA1(in0[1]),
	.MA2(in0[2]),
	.MA3(in0[3]),
	.MA4(in0[4]),
	.MA5(in0[5]),
	.MA6(in0[6]),
	.MA7(in0[7]),

	.MB0(in1[0]),
	.MB1(in1[1]),
	.MB2(in1[2]),
	.MB3(in1[3]),
	.MB4(in1[4]),
	.MB5(in1[5]),
	.MB6(in1[6]),
	.MB7(in1[7]),

	.MC0(in2[0]),
	.MC1(in2[1]),
	.MC2(in2[2]),
	.MC3(in2[3]),
	.MC4(in2[4]),
	.MC5(in2[5]),
	.MC6(in2[6]),
	.MC7(in2[7]),

	.MD0(in3[0]),
	.MD1(in3[1]),
	.MD2(in3[2]),
	.MD3(in3[3]),
	.MD4(in3[4]),
	.MD5(in3[5]),
	.MD6(in3[6]),
	.MD7(in3[7]),

	.ME0(in4[0]),
	.ME1(in4[1]),
	.ME2(in4[2]),
	.ME3(in4[3]),
	.ME4(in4[4]),
	.ME5(in4[5]),
	.ME6(in4[6]),
	.ME7(in4[7]),

	.MF0(in5[0]),
	.MF1(in5[1]),
	.MF2(in5[2]),
	.MF3(in5[3]),
	.MF4(in5[4]),
	.MF5(in5[5]),
	.MF6(in5[6]),
	.MF7(in5[7]),

	.MG0(in6[0]),
	.MG1(in6[1]),
	.MG2(in6[2]),
	.MG3(in6[3]),
	.MG4(in6[4]),
	.MG5(in6[5]),
	.MG6(in6[6]),
	.MG7(in6[7]),

	.MH0(in7[0]),
	.MH1(in7[1]),
	.MH2(in7[2]),
	.MH3(in7[3]),
	.MH4(in7[4]),
	.MH5(in7[5]),
	.MH6(in7[6]),
	.MH7(in7[7]),

	.S0(sel[0]),
	.S1(sel[1]),
	.S2(sel[2]),

	.O0(out[0]),
	.O1(out[1]),
	.O2(out[2]),
	.O3(out[3]),
	.O4(out[4]),
	.O5(out[5]),
	.O6(out[6]),
	.O7(out[7])	);

// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_mux8_8 (MA,MB,MC,MD,ME,MF,MG,MH,S,O);	// synthesis black_box
input [7 : 0] MA;
input [7 : 0] MB;
input [7 : 0] MC;
input [7 : 0] MD;
input [7 : 0] ME;
input [7 : 0] MF;
input [7 : 0] MG;
input [7 : 0] MH;
input [2 : 0] S;
output [7 : 0] O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BUS_V1_0 #(
		"00000000",
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		8,
		0,
		3,
		"00000000",
		0,
		1,
		8)
	inst (
		.MA(MA),
		.MB(MB),
		.MC(MC),
		.MD(MD),
		.ME(ME),
		.MF(MF),
		.MG(MG),
		.MH(MH),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// Mux 2:1 11 bits wide
module mux2_11(sel, in0, in1, out);
input		sel;
input	[10:0]	in0, in1;
output	[10:0]	out;

// INST_TAG
xilinx_mux2_11 u0 (
	.MA0(in0[0]),
	.MA1(in0[1]),
	.MA2(in0[2]),
	.MA3(in0[3]),
	.MA4(in0[4]),
	.MA5(in0[5]),
	.MA6(in0[6]),
	.MA7(in0[7]),
	.MA8(in0[8]),
	.MA9(in0[9]),
	.MA10(in0[10]),

	.MB0(in1[0]),
	.MB1(in1[1]),
	.MB2(in1[2]),
	.MB3(in1[3]),
	.MB4(in1[4]),
	.MB5(in1[5]),
	.MB6(in1[6]),
	.MB7(in1[7]),
	.MB8(in1[8]),
	.MB9(in1[9]),
	.MB10(in1[10]),

	.S0(sel),

	.O0(out[0]),
	.O1(out[1]),
	.O2(out[2]),
	.O3(out[3]),
	.O4(out[4]),
	.O5(out[5]),
	.O6(out[6]),
	.O7(out[7]),
	.O8(out[8]),
	.O9(out[9]),
	.O10(out[10])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_mux2_11 (MA,MB,S,O);	// synthesis black_box
input [10 : 0] MA;
input [10 : 0] MB;
input [0 : 0] S;
output [10 : 0] O;

// synopsys translate_off
// synthesis translate_off
	C_MUX_BUS_V1_0 #(
		"00000000000",
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		2,
		0,
		1,
		"00000000000",
		0,
		1,
		11)
	inst (
		.MA(MA),
		.MB(MB),
		.S(S),
		.O(O));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/


// 8bit Add/Sub with carry/borrow out
module add_sub8_co(sub, opa, opb, out, co);
input		sub;
input	[7:0]	opa, opb;
output	[7:0]	out;
output		co;

wire	add;
assign	add = ~sub;

// INST_TAG
xilinx_add_sub8_co u0 (
	.A0(opa[0]),
	.A1(opa[1]),
	.A2(opa[2]),
	.A3(opa[3]),
	.A4(opa[4]),
	.A5(opa[5]),
	.A6(opa[6]),
	.A7(opa[7]),

	.B0(opb[0]),
	.B1(opb[1]),
	.B2(opb[2]),
	.B3(opb[3]),
	.B4(opb[4]),
	.B5(opb[5]),
	.B6(opb[6]),
	.B7(opb[7]),

	.C_OUT(co),
	.ADD(add),

	.S0(out[0]),
	.S1(out[1]),
	.S2(out[2]),
	.S3(out[3]),
	.S4(out[4]),
	.S5(out[5]),
	.S6(out[6]),
	.S7(out[7])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_add_sub8_co (A,B,C_OUT,ADD,S);	// synthesis black_box
input [7 : 0] A;
input [7 : 0] B;
output C_OUT;
input ADD;
output [7 : 0] S;

// synopsys translate_off
// synthesis translate_off
	C_ADDSUB_V1_0 #(
		2,
		"0000",
		1,
		8,
		0,
		0,
		0,
		1,
		"0",
		8,
		1,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		7,
		0,
		8,
		1,
		"0",
		0,
		1)
	inst (
		.A(A),
		.B(B),
		.C_OUT(C_OUT),
		.ADD(ADD),
		.S(S));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// 11 bit incrementer
module inc11(in, out);
input	[10:0]	in;
output	[10:0]	out;

// INST_TAG
xilinx_inc11 u0 (
	.A0(in[0]),
	.A1(in[1]),
	.A2(in[2]),
	.A3(in[3]),
	.A4(in[4]),
	.A5(in[5]),
	.A6(in[6]),
	.A7(in[7]),
	.A8(in[8]),
	.A9(in[9]),
	.A10(in[10]),

	.S0(out[0]),
	.S1(out[1]),
	.S2(out[2]),
	.S3(out[3]),
	.S4(out[4]),
	.S5(out[5]),
	.S6(out[6]),
	.S7(out[7]),
	.S8(out[8]),
	.S9(out[9]),
	.S10(out[10])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_inc11 (A,S);	// synthesis black_box
input [10 : 0] A;
output [10 : 0] S;

// synopsys translate_off
// synthesis translate_off
	C_ADDSUB_V1_0 #(
		0,
		"0000",
		1,
		11,
		0,
		0,
		1,
		1,
		"0001",
		11,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		10,
		0,
		11,
		1,
		"0",
		0,
		1)
	inst (
		.A(A),
		.S(S));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/

// 8 bit incrementer
module inc8(in, out);
input	[7:0]	in;
output	[7:0]	out;

// INST_TAG
xilinx_inc8 u0 (
	.A0(in[0]),
	.A1(in[1]),
	.A2(in[2]),
	.A3(in[3]),
	.A4(in[4]),
	.A5(in[5]),
	.A6(in[6]),
	.A7(in[7]),

	.S0(out[0]),
	.S1(out[1]),
	.S2(out[2]),
	.S3(out[3]),
	.S4(out[4]),
	.S5(out[5]),
	.S6(out[6]),
	.S7(out[7])	);
// INST_TAG_END

endmodule

/*
// MOD_TAG
module xilinx_inc8 (A,S);	// synthesis black_box
input [7 : 0] A;
output [7 : 0] S;

// synopsys translate_off
// synthesis translate_off
	C_ADDSUB_V1_0 #(
		0,
		"0000",
		1,
		8,
		0,
		0,
		1,
		1,
		"0001",
		8,
		1,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		0,
		1,
		0,
		0,
		0,
		7,
		0,
		8,
		1,
		"0",
		0,
		1)
	inst (
		.A(A),
		.S(S));
// synthesis translate_on
// synopsys translate_on
endmodule
// MOD_TAG_END
*/


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


// Synchrounous SRAM
// 128 bytes by 8 bits
// 1 read port, 1 write port
// FOR XILINX VERTEX SERIES
module ssram_128x8(clk, rd_addr, rd_data, we, wr_addr, wr_data);
input		clk;
input	[6:0]	rd_addr;
output	[7:0]	rd_data;
input		we;
input	[6:0]	wr_addr;
input	[7:0]	wr_data;

wire	[7:0]	tmp;


// Alternatively RAMs can be instantiated directly
RAMB4_S8_S8 u0(
	.DOA(	rd_data	),
	.ADDRA(	{2'b0, rd_addr}	),
	.DIA(	8'h00	),
	.ENA(	1'b1	),
	.CLKA(	clk	),
	.WEA(	1'b0	),
	.RSTA(	1'b0	),
	.DOB(	tmp	),
	.ADDRB(	{2'b0, wr_addr}	),
	.DIB(	wr_data	),
	.ENB(	1'b1	),
	.CLKB(	clk	),
	.WEB(	we	),
	.RSTB(	1'b0	)	);


endmodule



// This block is the global Set/Rest for Xilinx VIrtex Serries
// Connect it up as described in Xilinx documentation
// Leave it out for Non Xilinx implementations
module glbl(rst);
input	rst;

wire	GSR;

assign	GSR = rst;

endmodule


