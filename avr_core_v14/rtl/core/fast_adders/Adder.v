//****************************************************************************************************
// Adder for ALU
// Designed by Ruslan Lepetenok
// Version 0.2
// Modified 14.09.2006
// Modified 18.08.12 -> Verilog LINT
//****************************************************************************************************

`timescale 1 ns / 1 ns

module Adder(
              A, 
	      B, 
	      CI, 
	      S, 
	      CO
	      );
	      
   parameter AdderType = 1;
   
   input [15:0]    A;
   input [15:0]    B;
   input           CI;
   output [15:0]   S;
   output          CO;
   
   
   generate
      if (AdderType == 1)
      begin : AdderType1Gen
         
         CLA16B1x16S CLA16B1x16S_Inst(.A(A), .B(B), .CI(CI), .S(S), .CO(CO));
      end
   endgenerate
   
   generate
      if (AdderType == 2)
      begin : AdderType2Gen
         
         CLA16B2x8S CLA16B2x8S_Inst(.A(A), .B(B), .CI(CI), .S(S), .CO(CO));
      end
   endgenerate
   
   generate
      if (AdderType == 3)
      begin : AdderType3Gen
         
         CLA16B4x4S CLA16B4x4S_Inst(.A(A), .B(B), .CI(CI), .S(S), .CO(CO));
      end
   endgenerate
   
   generate
      if (AdderType == 0)
      begin : AdderType0Gen
         
         StandAdder #(.AdderWidth(16)) StandAdder_Inst(.A(A), .B(B), .CI(CI), .S(S), .CO(CO));
      end
   endgenerate
   
endmodule

