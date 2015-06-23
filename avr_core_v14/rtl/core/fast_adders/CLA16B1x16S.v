`timescale 1 ns / 1 ns

//**********************************************************************************************
// 16-bit carry look-ahead adder for ARM (built using 16-bit CLA sections)
// Version 0.1
// Modified 13.09.2006
// Designed by Ruslan Lepetenok
//**********************************************************************************************

module CLA16B1x16S(A, B, CI, S, CO);
   input [15:0]  A;
   input [15:0]  B;
   input         CI;
   output [15:0] S;
   output        CO;
   
   
   
   CLA16B CLA16B_Inst(.a_in(A[15:0]), .b_in(B[15:0]), .c_in(CI), .s_out(S[15:0]), .c_out(CO));
   
endmodule
