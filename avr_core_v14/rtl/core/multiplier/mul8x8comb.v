//****************************************************************************************************
// 8x8 Combinatorial Multiplier for AVR core
// Designed by Ruslan Lepetenok
// Version 0.8
// Modified 10.01.2007
// Compatible with Synopsys
// Modified 18.08.12 (Verilog version) -> LINT
//****************************************************************************************************

`timescale 1 ns / 1 ns

module mul8x8comb(
                  rd_in, 
		  rr_in, 
		  p_sum_out, 
		  p_carry_out, 
		  muls, 
		  mulsu
		  );

   input [7:0]   rd_in;
   input [7:0]   rr_in;
   output [15:0] p_sum_out;
   output [15:0] p_carry_out;
   input         muls;
   input         mulsu;
   
   parameter     CDnCr = 1'b0;
   
   wire [7+1:0]  Rs9In;
   
   // Booth decoder signals
   wire [3:0]    ShiftPPLeft;
   wire [3:0]    NegPP;
   wire [3:0]    ClrPP;
   
   wire [15:0]   PartialProduct[4:0];		// Was 3
   
   wire [7+1:0]  PX;		// +X
   wire [7+1:0]  MX;		// -X
   
   // Carry save adders (CSA) signals
   wire [15:0]   CSA_AIn[4:0];
   wire [15:0]   CSA_BIn[4:0];
   wire [15:0]   CSA_CarryIn[4:0];
   wire [15:0]   CSA_SumOut[4:0];
   wire [15:0]   CSA_CarryOut[4:0];
   
   // Was added for compatibility with Synopsys DC
   wire [6:0]    PX_H_Vector;		// 15..9
   wire [6:0]    MX_H_Vector;		// 15..9
   // Was added for compatibility with Synopsys DC	
   
   assign PX_H_Vector = {7{PX[7+1]}};
   assign MX_H_Vector = {7{MX[7+1]}};
   
   assign Rs9In = {rr_in, 1'b0};
   
   generate		// 2X
    genvar        i;
     for (i = 0; i < 4; i = i + 1)
      begin : BoothDecoder
       assign ShiftPPLeft[i] = (Rs9In[i * 2 + 2:i * 2] == 3'b011 | Rs9In[i * 2 + 2:i * 2] == 3'b100) ? 1'b1 : 1'b0;
       assign NegPP[i] = (Rs9In[i * 2 + 2] == 1'b1) ? 1'b1 : 1'b0;		   // -X/-2X
       assign ClrPP[i] = (Rs9In[i * 2 + 2:i * 2] == 3'b000 | Rs9In[i * 2 + 2:i * 2] == 3'b111) ? 1'b1 : 1'b0; // Clear must have higher priority than	   Neg     
      end
   endgenerate
      
      assign PX = ((muls  || mulsu )) ? {rd_in[7], rd_in} :     // For the signed multiplication
                                        {1'b0, rd_in};		// For the unsigned multiplication
      
      assign MX = ((muls  || mulsu )) ? (~({rd_in[7], rd_in})) + 9'd1 :    // For the signed multiplication
                                        (~({1'b0, rd_in})) + 9'd1;	   // For the unsigned multiplication
      
      assign PartialProduct[0] = (ClrPP[0]) ? {16{1'b0}} : 		// +/-0
                                 (!ShiftPPLeft[0] && !NegPP[0]) ? {PX_H_Vector[6:0], PX} : 		// +X
                                 (!ShiftPPLeft[0] && NegPP[0]) ? {MX_H_Vector[6:0], MX} : 		// -X
                                 (ShiftPPLeft[0] && !NegPP[0]) ? {PX_H_Vector[6:0 + 1], PX, 1'b0} : 		// +2X
                                 (ShiftPPLeft[0] && NegPP[0]) ? {MX_H_Vector[6:0 + 1], MX, 1'b0} : 		// -2X
                                 {16{CDnCr}};
      
      assign PartialProduct[1] = (ClrPP[1]) ? {16{1'b0}} : 		// +/-0
                                 (!ShiftPPLeft[1] && !NegPP[1]) ? {PX_H_Vector[6:0 + 2], PX, 2'b00} : 		// +X
                                 (!ShiftPPLeft[1] && NegPP[1]) ? {MX_H_Vector[6:0 + 2], MX, 2'b00} : 		// -X
                                 (ShiftPPLeft[1] && !NegPP[1]) ? {PX_H_Vector[6:0 + 3], PX, 3'b000} : 		// +2X
                                 (ShiftPPLeft[1] && NegPP[1]) ? {MX_H_Vector[6:0 + 3], MX, 3'b000} : 		// -2X
                                 {16{CDnCr}};
      
      assign PartialProduct[2] = (ClrPP[2]) ? {16{1'b0}} : 		// +/-0
                                 (!ShiftPPLeft[2] && !NegPP[2]) ? {PX_H_Vector[6:0 + 4], PX, 4'b0000} : 		// +X
                                 (!ShiftPPLeft[2] && NegPP[2]) ? {MX_H_Vector[6:0 + 4], MX, 4'b0000} : 		// -X
                                 (ShiftPPLeft[2] && !NegPP[2]) ? {PX_H_Vector[6:0 + 5], PX, 5'b00000} : 		// +2X
                                 (ShiftPPLeft[2] && NegPP[2]) ? {MX_H_Vector[6:0 + 5], MX, 5'b00000} : 		// -2X
                                 {16{CDnCr}};
      
      assign PartialProduct[3] = (ClrPP[3]) ? {16{1'b0}} : 		// +/-0
                                 (!ShiftPPLeft[3] && !NegPP[3]) ? {PX_H_Vector[6:0 + 6], PX, 6'b000000} : 		// +X
                                 (!ShiftPPLeft[3] && NegPP[3]) ? {MX_H_Vector[6:0 + 6], MX, 6'b000000} : 		// -X
                                 (ShiftPPLeft[3] && !NegPP[3]) ? {PX, 7'b0000000} : 		// +2X 
                                 (ShiftPPLeft[3] && NegPP[3]) ? {MX, 7'b0000000} : 		// -2X 						 
                                 {16{1'b0}};
      
      assign PartialProduct[4] = ((((!muls && !mulsu) || mulsu) && Rs9In[7+1])) ? {PX[7+1 - 1:0], 8'b00000000} : 		// MUL/MULSU -> Unsigned multiplication
                                 {16{1'b0}};
      
      // mulsu muls
      //  0     0     MUL
      //  0     1     MULS 
      //  1	0     MULSU			 
      
      // Carry save adders
      
      // CSA stage 0
      assign CSA_AIn[0]     = PartialProduct[0];
      assign CSA_BIn[0]     = {16{1'b0}};
      assign CSA_CarryIn[0] = {16{1'b0}};
      
      // CSA stages 1 to 4(?) 
      generate
       genvar	     k;
       genvar	     j;
       for (k = 1; k <= 4; k = k + 1)
       begin : CSA_Connection
          assign CSA_AIn[k] = PartialProduct[k];
          assign CSA_BIn[k] = CSA_SumOut[k - 1];
          assign CSA_CarryIn[k] = {CSA_CarryOut[k - 1][14:0], 1'b0};
       end
       for (j = 0; j <= 4; j = j + 1)
        begin : CarrySaveAdders
         assign CSA_SumOut[j] = CSA_AIn[j] ^ CSA_BIn[j] ^ CSA_CarryIn[j];
         assign CSA_CarryOut[j] = (CSA_AIn[j] & CSA_BIn[j]) | ((CSA_AIn[j] | CSA_BIn[j]) & CSA_CarryIn[j]);
        end
       endgenerate
                   
            assign p_sum_out = CSA_SumOut[4];     // Conversion bug was fixed (Was [0])
            assign p_carry_out = CSA_CarryOut[4]; // Conversion bug was fixed (Was [0])
            
endmodule // mul8x8comb

