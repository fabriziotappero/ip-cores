`timescale 1 ns / 1 ns

//**********************************************************************************************
// Adder
// Version 0.2
// Modified 10.01.2007
// Designed by Ruslan Lepetenok
//**********************************************************************************************

module StandAdder(A, B, CI, S, CO);
   parameter               AdderWidth = 16;
   input [AdderWidth-1:0]  A;
   input [AdderWidth-1:0]  B;
   input                   CI;
   output [AdderWidth-1:0] S;
   output                  CO;
   
   wire [AdderWidth-1+1:0] TmpRes;
   
   assign TmpRes = (({1'b0, A}) + ({1'b0, B})) + CI;
   assign S = TmpRes[AdderWidth-1:0];
   assign CO = TmpRes[AdderWidth-1+1];
   
endmodule
