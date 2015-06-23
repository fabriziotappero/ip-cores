//===================================================================
// Module Name : RsEncodeTop
// File Name   : RsEncodeTop.v
// Function    : Rs Encoder Top Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsEncodeTop(
   CLK,        // system clock
   RESET,      // system reset
   enable,     // rs encoder enable signal
   startPls,   // rs encoder sync signal
   dataIn,     // rs encoder data in
   dataOut     // rs encoder data out
);


   input          CLK;        // system clock
   input          RESET;      // system reset
   input          enable;     // rs encoder enable signal
   input          startPls;   // rs encoder sync signal
   input  [7:0]   dataIn;     // rs encoder data in
   output [7:0]   dataOut;    // rs encoder data out



   //---------------------------------------------------------------
   //- registers
   //---------------------------------------------------------------
   reg  [7:0]   count;
   reg          dataValid;
   reg  [7:0]   feedbackReg;
   wire [7:0]   mult_0;
   wire [7:0]   mult_1;
   wire [7:0]   mult_2;
   wire [7:0]   mult_3;
   wire [7:0]   mult_4;
   wire [7:0]   mult_5;
   wire [7:0]   mult_6;
   wire [7:0]   mult_7;
   wire [7:0]   mult_8;
   wire [7:0]   mult_9;
   wire [7:0]   mult_10;
   wire [7:0]   mult_11;
   wire [7:0]   mult_12;
   wire [7:0]   mult_13;
   wire [7:0]   mult_14;
   wire [7:0]   mult_15;
   wire [7:0]   mult_16;
   wire [7:0]   mult_17;
   wire [7:0]   mult_18;
   wire [7:0]   mult_19;
   wire [7:0]   mult_20;
   wire [7:0]   mult_21;
   reg  [7:0]   syndromeReg_0;
   reg  [7:0]   syndromeReg_1;
   reg  [7:0]   syndromeReg_2;
   reg  [7:0]   syndromeReg_3;
   reg  [7:0]   syndromeReg_4;
   reg  [7:0]   syndromeReg_5;
   reg  [7:0]   syndromeReg_6;
   reg  [7:0]   syndromeReg_7;
   reg  [7:0]   syndromeReg_8;
   reg  [7:0]   syndromeReg_9;
   reg  [7:0]   syndromeReg_10;
   reg  [7:0]   syndromeReg_11;
   reg  [7:0]   syndromeReg_12;
   reg  [7:0]   syndromeReg_13;
   reg  [7:0]   syndromeReg_14;
   reg  [7:0]   syndromeReg_15;
   reg  [7:0]   syndromeReg_16;
   reg  [7:0]   syndromeReg_17;
   reg  [7:0]   syndromeReg_18;
   reg  [7:0]   syndromeReg_19;
   reg  [7:0]   syndromeReg_20;
   reg  [7:0]   syndromeReg_21;
   reg  [7:0]   dataReg;
   reg  [7:0]   syndromeRegFF;
   reg  [7:0]   wireOut;



   //---------------------------------------------------------------
   //- count
   //---------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         count [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (startPls == 1'b1) begin
            count[7:0] <= 8'd1;
         end
         else if ((count[7:0] ==8'd0) || (count[7:0] ==8'd255)) begin
            count[7:0] <= 8'd0;
         end
         else begin
            count[7:0] <= count[7:0] + 8'd1;
         end
      end
   end



   //---------------------------------------------------------------
   //- dataValid
   //---------------------------------------------------------------
   always @(count or startPls) begin
      if (startPls == 1'b1 || (count[7:0] < 8'd233)) begin
         dataValid = 1'b1;
      end
      else begin
         dataValid = 1'b0;
      end
   end




   //---------------------------------------------------------------
   //- Multipliers
   //---------------------------------------------------------------
   assign mult_9[0] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_9[1] =  feedbackReg[1] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_9[2] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_9[3] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_9[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[6];
   assign mult_9[5] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_9[6] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_9[7] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_15[0] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_15[1] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[5];
   assign mult_15[2] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_15[3] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_15[4] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_15[5] =  feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_15[6] =  feedbackReg[2] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_15[7] =  feedbackReg[3] ^ feedbackReg[6];
   assign mult_12[0] =  feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_12[1] =  feedbackReg[4] ^ feedbackReg[6];
   assign mult_12[2] =  feedbackReg[3];
   assign mult_12[3] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_12[4] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_12[5] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_12[6] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_12[7] =  feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_10[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_10[1] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[7];
   assign mult_10[2] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_10[3] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_10[4] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_10[5] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_10[6] =  feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_10[7] =  feedbackReg[0] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_6[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_6[1] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_6[2] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_6[3] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_6[4] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_6[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_6[6] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_6[7] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_17[0] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_17[1] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_17[2] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_17[3] =  feedbackReg[3] ^ feedbackReg[4];
   assign mult_17[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_17[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4];
   assign mult_17[6] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5];
   assign mult_17[7] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_7[0] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[6];
   assign mult_7[1] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_7[2] =  feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_7[3] =  feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_7[4] =  feedbackReg[2] ^ feedbackReg[7];
   assign mult_7[5] =  feedbackReg[3];
   assign mult_7[6] =  feedbackReg[0] ^ feedbackReg[4];
   assign mult_7[7] =  feedbackReg[1] ^ feedbackReg[5];
   assign mult_2[0] =  feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_2[1] =  feedbackReg[0] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_2[2] =  feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_2[3] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_2[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_2[5] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_2[6] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_2[7] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_14[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_14[1] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_14[2] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_14[3] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_14[4] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_14[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_14[6] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_14[7] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_4[0] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_4[1] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5];
   assign mult_4[2] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_4[3] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3];
   assign mult_4[4] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_4[5] =  feedbackReg[1] ^ feedbackReg[4];
   assign mult_4[6] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[5];
   assign mult_4[7] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[6];
   assign mult_3[0] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_3[1] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_3[2] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_3[3] =  feedbackReg[2] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_3[4] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_3[5] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_3[6] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_3[7] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_1[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_1[1] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_1[2] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_1[3] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_1[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_1[5] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_1[6] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_1[7] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_20[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_20[1] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_20[2] =  feedbackReg[2] ^ feedbackReg[4];
   assign mult_20[3] =  feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_20[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_20[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_20[6] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_20[7] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_8[0] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_8[1] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_8[2] =  feedbackReg[1] ^ feedbackReg[3];
   assign mult_8[3] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_8[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5];
   assign mult_8[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_8[6] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_8[7] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_11[0] =  feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_11[1] =  feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_11[2] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_11[3] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[4];
   assign mult_11[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_11[5] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_11[6] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_11[7] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_21[0] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_21[1] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_21[2] =  feedbackReg[5];
   assign mult_21[3] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_21[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_21[5] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_21[6] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_21[7] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_5[0] =  feedbackReg[2] ^ feedbackReg[4];
   assign mult_5[1] =  feedbackReg[0] ^ feedbackReg[3] ^ feedbackReg[5];
   assign mult_5[2] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[6];
   assign mult_5[3] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_5[4] =  feedbackReg[0] ^ feedbackReg[5];
   assign mult_5[5] =  feedbackReg[1] ^ feedbackReg[6];
   assign mult_5[6] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[7];
   assign mult_5[7] =  feedbackReg[1] ^ feedbackReg[3];
   assign mult_13[0] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[7];
   assign mult_13[1] =  feedbackReg[1] ^ feedbackReg[3];
   assign mult_13[2] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_13[3] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_13[4] =  feedbackReg[3] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_13[5] =  feedbackReg[4] ^ feedbackReg[7];
   assign mult_13[6] =  feedbackReg[0] ^ feedbackReg[5];
   assign mult_13[7] =  feedbackReg[1] ^ feedbackReg[6];
   assign mult_16[0] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_16[1] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_16[2] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2];
   assign mult_16[3] =  feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_16[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_16[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_16[6] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_16[7] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_0[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_0[1] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_0[2] =  feedbackReg[0] ^ feedbackReg[1];
   assign mult_0[3] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_0[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3];
   assign mult_0[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_0[6] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_0[7] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_18[0] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_18[1] =  feedbackReg[2] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_18[2] =  feedbackReg[1] ^ feedbackReg[4] ^ feedbackReg[7];
   assign mult_18[3] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_18[4] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_18[5] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[7];
   assign mult_18[6] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4];
   assign mult_18[7] =  feedbackReg[0] ^ feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5];
   assign mult_19[0] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[5] ^ feedbackReg[6];
   assign mult_19[1] =  feedbackReg[0] ^ feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_19[2] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5] ^ feedbackReg[6] ^ feedbackReg[7];
   assign mult_19[3] =  feedbackReg[1] ^ feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];
   assign mult_19[4] =  feedbackReg[1] ^ feedbackReg[2] ^ feedbackReg[4];
   assign mult_19[5] =  feedbackReg[2] ^ feedbackReg[3] ^ feedbackReg[5];
   assign mult_19[6] =  feedbackReg[3] ^ feedbackReg[4] ^ feedbackReg[6];
   assign mult_19[7] =  feedbackReg[0] ^ feedbackReg[4] ^ feedbackReg[5] ^ feedbackReg[7];



   //---------------------------------------------------------------
   //- syndromeReg
   //---------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         syndromeReg_0 [7:0]  <= 8'd0;
         syndromeReg_1 [7:0]  <= 8'd0;
         syndromeReg_2 [7:0]  <= 8'd0;
         syndromeReg_3 [7:0]  <= 8'd0;
         syndromeReg_4 [7:0]  <= 8'd0;
         syndromeReg_5 [7:0]  <= 8'd0;
         syndromeReg_6 [7:0]  <= 8'd0;
         syndromeReg_7 [7:0]  <= 8'd0;
         syndromeReg_8 [7:0]  <= 8'd0;
         syndromeReg_9 [7:0]  <= 8'd0;
         syndromeReg_10 [7:0] <= 8'd0;
         syndromeReg_11 [7:0] <= 8'd0;
         syndromeReg_12 [7:0] <= 8'd0;
         syndromeReg_13 [7:0] <= 8'd0;
         syndromeReg_14 [7:0] <= 8'd0;
         syndromeReg_15 [7:0] <= 8'd0;
         syndromeReg_16 [7:0] <= 8'd0;
         syndromeReg_17 [7:0] <= 8'd0;
         syndromeReg_18 [7:0] <= 8'd0;
         syndromeReg_19 [7:0] <= 8'd0;
         syndromeReg_20 [7:0] <= 8'd0;
         syndromeReg_21 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (startPls == 1'b1) begin
            syndromeReg_0 [7:0]  <= mult_0 [7:0];
            syndromeReg_1 [7:0]  <= mult_1 [7:0];
            syndromeReg_2 [7:0]  <= mult_2 [7:0];
            syndromeReg_3 [7:0]  <= mult_3 [7:0];
            syndromeReg_4 [7:0]  <= mult_4 [7:0];
            syndromeReg_5 [7:0]  <= mult_5 [7:0];
            syndromeReg_6 [7:0]  <= mult_6 [7:0];
            syndromeReg_7 [7:0]  <= mult_7 [7:0];
            syndromeReg_8 [7:0]  <= mult_8 [7:0];
            syndromeReg_9 [7:0]  <= mult_9 [7:0];
            syndromeReg_10 [7:0] <= mult_10 [7:0];
            syndromeReg_11 [7:0] <= mult_11 [7:0];
            syndromeReg_12 [7:0] <= mult_12 [7:0];
            syndromeReg_13 [7:0] <= mult_13 [7:0];
            syndromeReg_14 [7:0] <= mult_14 [7:0];
            syndromeReg_15 [7:0] <= mult_15 [7:0];
            syndromeReg_16 [7:0] <= mult_16 [7:0];
            syndromeReg_17 [7:0] <= mult_17 [7:0];
            syndromeReg_18 [7:0] <= mult_18 [7:0];
            syndromeReg_19 [7:0] <= mult_19 [7:0];
            syndromeReg_20 [7:0] <= mult_20 [7:0];
            syndromeReg_21 [7:0] <= mult_21 [7:0];
         end
         else begin
            syndromeReg_0 [7:0]  <= mult_0 [7:0];
            syndromeReg_1 [7:0]  <= (syndromeReg_0 [7:0] ^ mult_1 [7:0]);
            syndromeReg_2 [7:0]  <= (syndromeReg_1 [7:0] ^ mult_2 [7:0]);
            syndromeReg_3 [7:0]  <= (syndromeReg_2 [7:0] ^ mult_3 [7:0]);
            syndromeReg_4 [7:0]  <= (syndromeReg_3 [7:0] ^ mult_4 [7:0]);
            syndromeReg_5 [7:0]  <= (syndromeReg_4 [7:0] ^ mult_5 [7:0]);
            syndromeReg_6 [7:0]  <= (syndromeReg_5 [7:0] ^ mult_6 [7:0]);
            syndromeReg_7 [7:0]  <= (syndromeReg_6 [7:0] ^ mult_7 [7:0]);
            syndromeReg_8 [7:0]  <= (syndromeReg_7 [7:0] ^ mult_8 [7:0]);
            syndromeReg_9 [7:0]  <= (syndromeReg_8 [7:0] ^ mult_9 [7:0]);
            syndromeReg_10 [7:0] <= (syndromeReg_9 [7:0] ^ mult_10 [7:0]);
            syndromeReg_11 [7:0] <= (syndromeReg_10 [7:0] ^ mult_11 [7:0]);
            syndromeReg_12 [7:0] <= (syndromeReg_11 [7:0] ^ mult_12 [7:0]);
            syndromeReg_13 [7:0] <= (syndromeReg_12 [7:0] ^ mult_13 [7:0]);
            syndromeReg_14 [7:0] <= (syndromeReg_13 [7:0] ^ mult_14 [7:0]);
            syndromeReg_15 [7:0] <= (syndromeReg_14 [7:0] ^ mult_15 [7:0]);
            syndromeReg_16 [7:0] <= (syndromeReg_15 [7:0] ^ mult_16 [7:0]);
            syndromeReg_17 [7:0] <= (syndromeReg_16 [7:0] ^ mult_17 [7:0]);
            syndromeReg_18 [7:0] <= (syndromeReg_17 [7:0] ^ mult_18 [7:0]);
            syndromeReg_19 [7:0] <= (syndromeReg_18 [7:0] ^ mult_19 [7:0]);
            syndromeReg_20 [7:0] <= (syndromeReg_19 [7:0] ^ mult_20 [7:0]);
            syndromeReg_21 [7:0] <= (syndromeReg_20 [7:0] ^ mult_21 [7:0]);
         end
      end
   end



   //---------------------------------------------------------------
   //- feedbackReg
   //---------------------------------------------------------------
   always @( startPls, dataValid, dataIn, syndromeReg_21 ) begin
      if (startPls == 1'b1) begin
         feedbackReg[7:0] = dataIn[7:0];
      end
      else if (dataValid == 1'b1) begin
         feedbackReg [7:0] = dataIn[7:0] ^  syndromeReg_21 [7:0];
      end
      else begin
         feedbackReg [7:0] =  8'd0;
      end
   end



   //---------------------------------------------------------------
   //- dataReg syndromeRegFF
   //---------------------------------------------------------------
   always @(posedge CLK, negedge RESET) begin
      if (~RESET) begin
         dataReg [7:0] <= 8'd0;
         syndromeRegFF  [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         dataReg [7:0] <=  dataIn [7:0];
         syndromeRegFF  [7:0] <=  syndromeReg_21 [7:0];
      end
   end



   //---------------------------------------------------------------
   //- wireOut
   //---------------------------------------------------------------
   always @( count, dataReg, syndromeRegFF) begin
      if (count [7:0]<= 8'd233) begin
         wireOut[7:0] = dataReg[7:0];
      end
      else begin
         wireOut[7:0] = syndromeRegFF[7:0];
      end
   end



   //---------------------------------------------------------------
   //- dataOutInner
   //---------------------------------------------------------------
   reg [7:0]   dataOutInner;
   always @(posedge CLK, negedge RESET) begin
      if (~RESET) begin
         dataOutInner <= 8'd0;
      end
      else begin
         dataOutInner <= wireOut;
      end
   end



   //---------------------------------------------------------------
   //- Output ports
   //---------------------------------------------------------------
   assign dataOut = dataOutInner;



endmodule
