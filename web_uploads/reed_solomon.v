/////////////////////////////////////////////////////////////////////
////                                                             ////
////  High Speed Reed Solomon Encoder                            ////
////                                                             ////
////                                                             ////
////  Author: Rajesh Pathak                                      ////
////          rajesh_99@opencores.org                            ////
////                                                             ////
////                                                             ////
////  Downloaded from: http://www.opencores.org                  ////
////                                                             ////
/////////////////////////////////////////////////////////////////////
////                                                             ////
//// Copyright (C) 2003 Rajesh Pathak                            ////
////                         rajesh_99@netzero.net               ////
////                         Exponentiation Technology           ////
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



module rs_encode(datain, valid, gin0, gin1, gin2, gin3, gin4, gin5, gin6, gin7, gin8, 
gin9, gin10, gin11, gin12, gin13, gin14, gin15, q0, q1, q2, q3, q4, q5, q6, q7, 
q8, q9, q10, q11, q12, q13, q14, q15, rst, clkin);
input clkin;
input valid;
input rst;
input [7:0] datain;
output [7:0] q0;
output [7:0] q1;
output [7:0] q2;
output [7:0] q3;
wire [7:0] m3, m4, m5, m6, m7, m8, m9, m10, m11, m12, m13, m14, m15;
wire [7:0] m2;
wire [7:0] m1;
wire [7:0] m0;
wire [7:0] z0;
wire [7:0] z1;
wire [7:0] z2;
wire [7:0] z3, z4, z5, z6, z7, z8, z9, z10, z11, z12, z13, z14, z15;
input [7:0] gin0, gin1, gin2, gin3, gin4, gin5, gin6, gin7, gin8, gin9, gin10, 
gin11, gin12, gin13, gin14, gin15;
wire [7:0]  bb, fback;
wire clk;
output [7:0] q4, q5, q6, q7, q8, q9, q10, q11, q12, q13, q14, q15;

assign clk = clkin&valid;

FF b0(z0, q0, rst, clk);
FF b1(z1, q1, rst, clk);
FF b2(z2, q2, rst, clk);
FF b3(z3, q3, rst, clk);

FF b4(z4, q4, rst, clk);
FF b5(z5, q5, rst, clk);
FF b6(z6, q6, rst, clk);
FF b7(z7, q7, rst, clk);

FF b8(z8, q8, rst, clk);
FF b9(z9, q9, rst, clk);
FF b10(z10, q10, rst, clk);
FF b11(z11, q11, rst, clk);

FF b12(z12, q12, rst, clk);
FF b13(z13, q13, rst, clk);
FF b14(z14, q14, rst, clk);
FF b15(z15, q15, rst, clk);

assign bb = 8'b00000000;
GFADD a0(bb, m0, z0); 
GFADD a1(q0, m1, z1);
GFADD a2(q1, m2, z2);
GFADD a3(q2, m3, z3);
GFADD a4(q3, m4, z4);
GFADD a5(q4, m5, z5);
GFADD a6(q5, m6, z6);
GFADD a7(q6, m7, z7);
GFADD a8(q7, m8, z8);
GFADD a9(q8, m9, z9);
GFADD a10(q9, m10, z10);
GFADD a11(q10, m11, z11);
GFADD a12(q11, m12, z12);
GFADD a13(q12, m13, z13);
GFADD a14(q13, m14, z14);
GFADD a15(q14, m15, z15);



assign fback = q15^datain;

GFMUL8 u0(fback, gin0, m0);
GFMUL8 u1(fback, gin1, m1);
GFMUL8 u2(fback, gin2, m2);
GFMUL8 u3(fback, gin3, m3);

GFMUL8 u4(fback, gin4, m4);
GFMUL8 u5(fback, gin5, m5);
GFMUL8 u6(fback, gin6, m6);
GFMUL8 u7(fback, gin7, m7);

GFMUL8 u8(fback, gin8, m8);
GFMUL8 u9(fback, gin9, m9);
GFMUL8 u10(fback, gin10, m10);
GFMUL8 u11(fback, gin11, m11);

GFMUL8 u12(fback, gin12, m12);
GFMUL8 u13(fback, gin13, m13);
GFMUL8 u14(fback, gin14, m14);
GFMUL8 u15(fback, gin15, m15);

endmodule

module GFADD(in1, in2, out);
input [7:0] in1;
input [7:0] in2;
output [7:0] out;
assign out = in1^in2;
endmodule


module FF(d, q, rst, clk);
input [7:0] d;
input  clk;
output  [7:0] q;
reg [7:0] out;
input rst;

always @(posedge clk or negedge rst)
if(~rst) out <= 8'b00000000; else
 begin
 out <= #1 d;
 end
 assign q = out;
 endmodule

module GFMUL8(a, b, z);
input [7:0] a;
input [7:0] b;
output [7:0] z;
assign z[0] = b[0]&a[0]^b[1]&a[7]^b[2]&a[6]^b[3]&a[5]^b[4]&a[4]^b[5]&a[3]^b[5]&a[7]^b[6]&a[2]^b[6]&a[6]^b[6]&a[7]^b[7]&a[1]^b[7]&a[5]^b[7]&a[6]^b[7]&a[7];
assign z[1] = b[0]&a[1]^b[1]&a[0]^b[2]&a[7]^b[3]&a[6]^b[4]&a[5]^b[5]&a[4]^b[6]&a[3]^b[6]&a[7]^b[7]&a[2]^b[7]&a[6]^b[7]&a[7];
assign z[2] = b[0]&a[2]^b[1]&a[1]^b[1]&a[7]^b[2]&a[0]^b[2]&a[6]^b[3]&a[5]^b[3]&a[7]^b[4]&a[4]^b[4]&a[6]^b[5]&a[3]^b[5]&a[5]^b[5]&a[7]^b[6]&a[2]^b[6]&a[4]^b[6]&a[6]^b[6]&a[7]^b[7]&a[1]^b[7]&a[3]^b[7]&a[5]^b[7]&a[6];
assign z[3] = b[0]&a[3]^b[1]&a[2]^b[1]&a[7]^b[2]&a[1]^b[2]&a[6]^b[2]&a[7]^b[3]&a[0]^b[3]&a[5]^b[3]&a[6]^b[4]&a[4]^b[4]&a[5]^b[4]&a[7]^b[5]&a[3]^b[5]&a[4]^b[5]&a[6]^b[5]&a[7]^b[6]&a[2]^b[6]&a[3]^b[6]&a[5]^b[6]&a[6]^b[7]&a[1]^b[7]&a[2]^b[7]&a[4]^b[7]&a[5];
assign z[4] = b[0]&a[4]^b[1]&a[3]^b[1]&a[7]^b[2]&a[2]^b[2]&a[6]^b[2]&a[7]^b[3]&a[1]^b[3]&a[5]^b[3]&a[6]^b[3]&a[7]^b[4]&a[0]^b[4]&a[4]^b[4]&a[5]^b[4]&a[6]^b[5]&a[3]^b[5]&a[4]^b[5]&a[5]^b[6]&a[2]^b[6]&a[3]^b[6]&a[4]^b[7]&a[1]^b[7]&a[2]^b[7]&a[3]^b[7]&a[7];
assign z[5] = b[0]&a[5]^b[1]&a[4]^b[2]&a[3]^b[2]&a[7]^b[3]&a[2]^b[3]&a[6]^b[3]&a[7]^b[4]&a[1]^b[4]&a[5]^b[4]&a[6]^b[4]&a[7]^b[5]&a[0]^b[5]&a[4]^b[5]&a[5]^b[5]&a[6]^b[6]&a[3]^b[6]&a[4]^b[6]&a[5]^b[7]&a[2]^b[7]&a[3]^b[7]&a[4];
assign z[6] = b[0]&a[6]^b[1]&a[5]^b[2]&a[4]^b[3]&a[3]^b[3]&a[7]^b[4]&a[2]^b[4]&a[6]^b[4]&a[7]^b[5]&a[1]^b[5]&a[5]^b[5]&a[6]^b[5]&a[7]^b[6]&a[0]^b[6]&a[4]^b[6]&a[5]^b[6]&a[6]^b[7]&a[3]^b[7]&a[4]^b[7]&a[5];
assign z[7] = b[0]&a[7]^b[1]&a[6]^b[2]&a[5]^b[3]&a[4]^b[4]&a[3]^b[4]&a[7]^b[5]&a[2]^b[5]&a[6]^b[5]&a[7]^b[6]&a[1]^b[6]&a[5]^b[6]&a[6]^b[6]&a[7]^b[7]&a[0]^b[7]&a[4]^b[7]&a[5]^b[7]&a[6];
endmodule

