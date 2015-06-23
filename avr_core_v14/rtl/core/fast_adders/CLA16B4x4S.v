`timescale 1 ns / 1 ns

//**********************************************************************************************
// 16-bit carry look-ahead adder for AVR (built using 4-bit CLA sections)
// Version 0.1
// Modified 13.09.2006
// Designed by Ruslan Lepetenok
//**********************************************************************************************

module CLA16B4x4S(A, B, CI, S, CO);
   input [15:0]  A;
   input [15:0]  B;
   input         CI;
   output [15:0] S;
   output        CO;
   
   wire [2:0]    InternalCarry;
   
   
   CLA4B AdderB0to3_Inst(.a_in(A[3:0]), .b_in(B[3:0]), .c_in(CI), .s_out(S[3:0]), .c_out(InternalCarry[0]));
   
   
   CLA4B AdderB4to7_Inst(.a_in(A[7:4]), .b_in(B[7:4]), .c_in(InternalCarry[0]), .s_out(S[7:4]), .c_out(InternalCarry[1]));
   
   
   CLA4B AdderB8to11_Inst(.a_in(A[11:8]), .b_in(B[11:8]), .c_in(InternalCarry[1]), .s_out(S[11:8]), .c_out(InternalCarry[2]));
   
   
   CLA4B AdderB12to15_Inst(.a_in(A[15:12]), .b_in(B[15:12]), .c_in(InternalCarry[2]), .s_out(S[15:12]), .c_out(CO));
   
endmodule

