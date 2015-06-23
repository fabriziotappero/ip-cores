//===================================================================
// Module Name : RsDecodeSyndrome
// File Name   : RsDecodeSyndrome.v
// Function    : Rs Decoder syndrome calculation
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeSyndrome(
   CLK,           // system clock
   RESET,         // system reset
   enable,        // enable signal
   sync,          // sync signal
   dataIn,        // data input
   syndrome_0,    // syndrome polynom 0
   syndrome_1,    // syndrome polynom 1
   syndrome_2,    // syndrome polynom 2
   syndrome_3,    // syndrome polynom 3
   syndrome_4,    // syndrome polynom 4
   syndrome_5,    // syndrome polynom 5
   syndrome_6,    // syndrome polynom 6
   syndrome_7,    // syndrome polynom 7
   syndrome_8,    // syndrome polynom 8
   syndrome_9,    // syndrome polynom 9
   syndrome_10,   // syndrome polynom 10
   syndrome_11,   // syndrome polynom 11
   syndrome_12,   // syndrome polynom 12
   syndrome_13,   // syndrome polynom 13
   syndrome_14,   // syndrome polynom 14
   syndrome_15,   // syndrome polynom 15
   syndrome_16,   // syndrome polynom 16
   syndrome_17,   // syndrome polynom 17
   syndrome_18,   // syndrome polynom 18
   syndrome_19,   // syndrome polynom 19
   syndrome_20,   // syndrome polynom 20
   syndrome_21,   // syndrome polynom 21
   done           // done signal
);


   input          CLK;           // system clock
   input          RESET;         // system reset
   input          enable;        // enable signal
   input          sync;          // sync signal
   input  [7:0]   dataIn;        // data input
   output [7:0]   syndrome_0;    // syndrome polynom 0
   output [7:0]   syndrome_1;    // syndrome polynom 1
   output [7:0]   syndrome_2;    // syndrome polynom 2
   output [7:0]   syndrome_3;    // syndrome polynom 3
   output [7:0]   syndrome_4;    // syndrome polynom 4
   output [7:0]   syndrome_5;    // syndrome polynom 5
   output [7:0]   syndrome_6;    // syndrome polynom 6
   output [7:0]   syndrome_7;    // syndrome polynom 7
   output [7:0]   syndrome_8;    // syndrome polynom 8
   output [7:0]   syndrome_9;    // syndrome polynom 9
   output [7:0]   syndrome_10;   // syndrome polynom 10
   output [7:0]   syndrome_11;   // syndrome polynom 11
   output [7:0]   syndrome_12;   // syndrome polynom 12
   output [7:0]   syndrome_13;   // syndrome polynom 13
   output [7:0]   syndrome_14;   // syndrome polynom 14
   output [7:0]   syndrome_15;   // syndrome polynom 15
   output [7:0]   syndrome_16;   // syndrome polynom 16
   output [7:0]   syndrome_17;   // syndrome polynom 17
   output [7:0]   syndrome_18;   // syndrome polynom 18
   output [7:0]   syndrome_19;   // syndrome polynom 19
   output [7:0]   syndrome_20;   // syndrome polynom 20
   output [7:0]   syndrome_21;   // syndrome polynom 21
   output         done;          // done signal


   //------------------------------------------------------------------------
   // + count
   //- Counter
   //------------------------------------------------------------------------
   reg    [7:0]   count;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         count [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            count[7:0] <= 8'd1;
         end
         else if ( (count[7:0] ==8'd0) || (count[7:0] ==8'd255)) begin
            count[7:0] <= 8'd0;
         end
         else begin
            count[7:0] <= count[7:0] + 8'd1;
         end
      end
   end



   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   reg         done;
   always @(count) begin
      if (count ==8'd255) begin
         done = 1'b1;
      end
      else begin
         done = 1'b0;
      end
   end


   //------------------------------------------------------------------------
   // + product_0,..., product_21
   //- Syndrome Generator
   //------------------------------------------------------------------------
   wire [7:0]   product_0;
   wire [7:0]   product_1;
   wire [7:0]   product_2;
   wire [7:0]   product_3;
   wire [7:0]   product_4;
   wire [7:0]   product_5;
   wire [7:0]   product_6;
   wire [7:0]   product_7;
   wire [7:0]   product_8;
   wire [7:0]   product_9;
   wire [7:0]   product_10;
   wire [7:0]   product_11;
   wire [7:0]   product_12;
   wire [7:0]   product_13;
   wire [7:0]   product_14;
   wire [7:0]   product_15;
   wire [7:0]   product_16;
   wire [7:0]   product_17;
   wire [7:0]   product_18;
   wire [7:0]   product_19;
   wire [7:0]   product_20;
   wire [7:0]   product_21;

   reg  [7:0]    reg_0;
   reg  [7:0]    reg_1;
   reg  [7:0]    reg_2;
   reg  [7:0]    reg_3;
   reg  [7:0]    reg_4;
   reg  [7:0]    reg_5;
   reg  [7:0]    reg_6;
   reg  [7:0]    reg_7;
   reg  [7:0]    reg_8;
   reg  [7:0]    reg_9;
   reg  [7:0]    reg_10;
   reg  [7:0]    reg_11;
   reg  [7:0]    reg_12;
   reg  [7:0]    reg_13;
   reg  [7:0]    reg_14;
   reg  [7:0]    reg_15;
   reg  [7:0]    reg_16;
   reg  [7:0]    reg_17;
   reg  [7:0]    reg_18;
   reg  [7:0]    reg_19;
   reg  [7:0]    reg_20;
   reg  [7:0]    reg_21;

   assign product_0 [0] = reg_0[0];
   assign product_0 [1] = reg_0[1];
   assign product_0 [2] = reg_0[2];
   assign product_0 [3] = reg_0[3];
   assign product_0 [4] = reg_0[4];
   assign product_0 [5] = reg_0[5];
   assign product_0 [6] = reg_0[6];
   assign product_0 [7] = reg_0[7];
   assign product_1 [0] = reg_1[7];
   assign product_1 [1] = reg_1[0];
   assign product_1 [2] = reg_1[1] ^ reg_1[7];
   assign product_1 [3] = reg_1[2] ^ reg_1[7];
   assign product_1 [4] = reg_1[3] ^ reg_1[7];
   assign product_1 [5] = reg_1[4];
   assign product_1 [6] = reg_1[5];
   assign product_1 [7] = reg_1[6];
   assign product_2 [0] = reg_2[6];
   assign product_2 [1] = reg_2[7];
   assign product_2 [2] = reg_2[0] ^ reg_2[6];
   assign product_2 [3] = reg_2[1] ^ reg_2[6] ^ reg_2[7];
   assign product_2 [4] = reg_2[2] ^ reg_2[6] ^ reg_2[7];
   assign product_2 [5] = reg_2[3] ^ reg_2[7];
   assign product_2 [6] = reg_2[4];
   assign product_2 [7] = reg_2[5];
   assign product_3 [0] = reg_3[5];
   assign product_3 [1] = reg_3[6];
   assign product_3 [2] = reg_3[5] ^ reg_3[7];
   assign product_3 [3] = reg_3[0] ^ reg_3[5] ^ reg_3[6];
   assign product_3 [4] = reg_3[1] ^ reg_3[5] ^ reg_3[6] ^ reg_3[7];
   assign product_3 [5] = reg_3[2] ^ reg_3[6] ^ reg_3[7];
   assign product_3 [6] = reg_3[3] ^ reg_3[7];
   assign product_3 [7] = reg_3[4];
   assign product_4 [0] = reg_4[4];
   assign product_4 [1] = reg_4[5];
   assign product_4 [2] = reg_4[4] ^ reg_4[6];
   assign product_4 [3] = reg_4[4] ^ reg_4[5] ^ reg_4[7];
   assign product_4 [4] = reg_4[0] ^ reg_4[4] ^ reg_4[5] ^ reg_4[6];
   assign product_4 [5] = reg_4[1] ^ reg_4[5] ^ reg_4[6] ^ reg_4[7];
   assign product_4 [6] = reg_4[2] ^ reg_4[6] ^ reg_4[7];
   assign product_4 [7] = reg_4[3] ^ reg_4[7];
   assign product_5 [0] = reg_5[3] ^ reg_5[7];
   assign product_5 [1] = reg_5[4];
   assign product_5 [2] = reg_5[3] ^ reg_5[5] ^ reg_5[7];
   assign product_5 [3] = reg_5[3] ^ reg_5[4] ^ reg_5[6] ^ reg_5[7];
   assign product_5 [4] = reg_5[3] ^ reg_5[4] ^ reg_5[5];
   assign product_5 [5] = reg_5[0] ^ reg_5[4] ^ reg_5[5] ^ reg_5[6];
   assign product_5 [6] = reg_5[1] ^ reg_5[5] ^ reg_5[6] ^ reg_5[7];
   assign product_5 [7] = reg_5[2] ^ reg_5[6] ^ reg_5[7];
   assign product_6 [0] = reg_6[2] ^ reg_6[6] ^ reg_6[7];
   assign product_6 [1] = reg_6[3] ^ reg_6[7];
   assign product_6 [2] = reg_6[2] ^ reg_6[4] ^ reg_6[6] ^ reg_6[7];
   assign product_6 [3] = reg_6[2] ^ reg_6[3] ^ reg_6[5] ^ reg_6[6];
   assign product_6 [4] = reg_6[2] ^ reg_6[3] ^ reg_6[4];
   assign product_6 [5] = reg_6[3] ^ reg_6[4] ^ reg_6[5];
   assign product_6 [6] = reg_6[0] ^ reg_6[4] ^ reg_6[5] ^ reg_6[6];
   assign product_6 [7] = reg_6[1] ^ reg_6[5] ^ reg_6[6] ^ reg_6[7];
   assign product_7 [0] = reg_7[1] ^ reg_7[5] ^ reg_7[6] ^ reg_7[7];
   assign product_7 [1] = reg_7[2] ^ reg_7[6] ^ reg_7[7];
   assign product_7 [2] = reg_7[1] ^ reg_7[3] ^ reg_7[5] ^ reg_7[6];
   assign product_7 [3] = reg_7[1] ^ reg_7[2] ^ reg_7[4] ^ reg_7[5];
   assign product_7 [4] = reg_7[1] ^ reg_7[2] ^ reg_7[3] ^ reg_7[7];
   assign product_7 [5] = reg_7[2] ^ reg_7[3] ^ reg_7[4];
   assign product_7 [6] = reg_7[3] ^ reg_7[4] ^ reg_7[5];
   assign product_7 [7] = reg_7[0] ^ reg_7[4] ^ reg_7[5] ^ reg_7[6];
   assign product_8 [0] = reg_8[0] ^ reg_8[4] ^ reg_8[5] ^ reg_8[6];
   assign product_8 [1] = reg_8[1] ^ reg_8[5] ^ reg_8[6] ^ reg_8[7];
   assign product_8 [2] = reg_8[0] ^ reg_8[2] ^ reg_8[4] ^ reg_8[5] ^ reg_8[7];
   assign product_8 [3] = reg_8[0] ^ reg_8[1] ^ reg_8[3] ^ reg_8[4];
   assign product_8 [4] = reg_8[0] ^ reg_8[1] ^ reg_8[2] ^ reg_8[6];
   assign product_8 [5] = reg_8[1] ^ reg_8[2] ^ reg_8[3] ^ reg_8[7];
   assign product_8 [6] = reg_8[2] ^ reg_8[3] ^ reg_8[4];
   assign product_8 [7] = reg_8[3] ^ reg_8[4] ^ reg_8[5];
   assign product_9 [0] = reg_9[3] ^ reg_9[4] ^ reg_9[5];
   assign product_9 [1] = reg_9[0] ^ reg_9[4] ^ reg_9[5] ^ reg_9[6];
   assign product_9 [2] = reg_9[1] ^ reg_9[3] ^ reg_9[4] ^ reg_9[6] ^ reg_9[7];
   assign product_9 [3] = reg_9[0] ^ reg_9[2] ^ reg_9[3] ^ reg_9[7];
   assign product_9 [4] = reg_9[0] ^ reg_9[1] ^ reg_9[5];
   assign product_9 [5] = reg_9[0] ^ reg_9[1] ^ reg_9[2] ^ reg_9[6];
   assign product_9 [6] = reg_9[1] ^ reg_9[2] ^ reg_9[3] ^ reg_9[7];
   assign product_9 [7] = reg_9[2] ^ reg_9[3] ^ reg_9[4];
   assign product_10 [0] = reg_10[2] ^ reg_10[3] ^ reg_10[4];
   assign product_10 [1] = reg_10[3] ^ reg_10[4] ^ reg_10[5];
   assign product_10 [2] = reg_10[0] ^ reg_10[2] ^ reg_10[3] ^ reg_10[5] ^ reg_10[6];
   assign product_10 [3] = reg_10[1] ^ reg_10[2] ^ reg_10[6] ^ reg_10[7];
   assign product_10 [4] = reg_10[0] ^ reg_10[4] ^ reg_10[7];
   assign product_10 [5] = reg_10[0] ^ reg_10[1] ^ reg_10[5];
   assign product_10 [6] = reg_10[0] ^ reg_10[1] ^ reg_10[2] ^ reg_10[6];
   assign product_10 [7] = reg_10[1] ^ reg_10[2] ^ reg_10[3] ^ reg_10[7];
   assign product_11 [0] = reg_11[1] ^ reg_11[2] ^ reg_11[3] ^ reg_11[7];
   assign product_11 [1] = reg_11[2] ^ reg_11[3] ^ reg_11[4];
   assign product_11 [2] = reg_11[1] ^ reg_11[2] ^ reg_11[4] ^ reg_11[5] ^ reg_11[7];
   assign product_11 [3] = reg_11[0] ^ reg_11[1] ^ reg_11[5] ^ reg_11[6] ^ reg_11[7];
   assign product_11 [4] = reg_11[3] ^ reg_11[6];
   assign product_11 [5] = reg_11[0] ^ reg_11[4] ^ reg_11[7];
   assign product_11 [6] = reg_11[0] ^ reg_11[1] ^ reg_11[5];
   assign product_11 [7] = reg_11[0] ^ reg_11[1] ^ reg_11[2] ^ reg_11[6];
   assign product_12 [0] = reg_12[0] ^ reg_12[1] ^ reg_12[2] ^ reg_12[6];
   assign product_12 [1] = reg_12[1] ^ reg_12[2] ^ reg_12[3] ^ reg_12[7];
   assign product_12 [2] = reg_12[0] ^ reg_12[1] ^ reg_12[3] ^ reg_12[4] ^ reg_12[6];
   assign product_12 [3] = reg_12[0] ^ reg_12[4] ^ reg_12[5] ^ reg_12[6] ^ reg_12[7];
   assign product_12 [4] = reg_12[2] ^ reg_12[5] ^ reg_12[7];
   assign product_12 [5] = reg_12[3] ^ reg_12[6];
   assign product_12 [6] = reg_12[0] ^ reg_12[4] ^ reg_12[7];
   assign product_12 [7] = reg_12[0] ^ reg_12[1] ^ reg_12[5];
   assign product_13 [0] = reg_13[0] ^ reg_13[1] ^ reg_13[5];
   assign product_13 [1] = reg_13[0] ^ reg_13[1] ^ reg_13[2] ^ reg_13[6];
   assign product_13 [2] = reg_13[0] ^ reg_13[2] ^ reg_13[3] ^ reg_13[5] ^ reg_13[7];
   assign product_13 [3] = reg_13[3] ^ reg_13[4] ^ reg_13[5] ^ reg_13[6];
   assign product_13 [4] = reg_13[1] ^ reg_13[4] ^ reg_13[6] ^ reg_13[7];
   assign product_13 [5] = reg_13[2] ^ reg_13[5] ^ reg_13[7];
   assign product_13 [6] = reg_13[3] ^ reg_13[6];
   assign product_13 [7] = reg_13[0] ^ reg_13[4] ^ reg_13[7];
   assign product_14 [0] = reg_14[0] ^ reg_14[4] ^ reg_14[7];
   assign product_14 [1] = reg_14[0] ^ reg_14[1] ^ reg_14[5];
   assign product_14 [2] = reg_14[1] ^ reg_14[2] ^ reg_14[4] ^ reg_14[6] ^ reg_14[7];
   assign product_14 [3] = reg_14[2] ^ reg_14[3] ^ reg_14[4] ^ reg_14[5];
   assign product_14 [4] = reg_14[0] ^ reg_14[3] ^ reg_14[5] ^ reg_14[6] ^ reg_14[7];
   assign product_14 [5] = reg_14[1] ^ reg_14[4] ^ reg_14[6] ^ reg_14[7];
   assign product_14 [6] = reg_14[2] ^ reg_14[5] ^ reg_14[7];
   assign product_14 [7] = reg_14[3] ^ reg_14[6];
   assign product_15 [0] = reg_15[3] ^ reg_15[6];
   assign product_15 [1] = reg_15[0] ^ reg_15[4] ^ reg_15[7];
   assign product_15 [2] = reg_15[0] ^ reg_15[1] ^ reg_15[3] ^ reg_15[5] ^ reg_15[6];
   assign product_15 [3] = reg_15[1] ^ reg_15[2] ^ reg_15[3] ^ reg_15[4] ^ reg_15[7];
   assign product_15 [4] = reg_15[2] ^ reg_15[4] ^ reg_15[5] ^ reg_15[6];
   assign product_15 [5] = reg_15[0] ^ reg_15[3] ^ reg_15[5] ^ reg_15[6] ^ reg_15[7];
   assign product_15 [6] = reg_15[1] ^ reg_15[4] ^ reg_15[6] ^ reg_15[7];
   assign product_15 [7] = reg_15[2] ^ reg_15[5] ^ reg_15[7];
   assign product_16 [0] = reg_16[2] ^ reg_16[5] ^ reg_16[7];
   assign product_16 [1] = reg_16[3] ^ reg_16[6];
   assign product_16 [2] = reg_16[0] ^ reg_16[2] ^ reg_16[4] ^ reg_16[5];
   assign product_16 [3] = reg_16[0] ^ reg_16[1] ^ reg_16[2] ^ reg_16[3] ^ reg_16[6] ^ reg_16[7];
   assign product_16 [4] = reg_16[1] ^ reg_16[3] ^ reg_16[4] ^ reg_16[5];
   assign product_16 [5] = reg_16[2] ^ reg_16[4] ^ reg_16[5] ^ reg_16[6];
   assign product_16 [6] = reg_16[0] ^ reg_16[3] ^ reg_16[5] ^ reg_16[6] ^ reg_16[7];
   assign product_16 [7] = reg_16[1] ^ reg_16[4] ^ reg_16[6] ^ reg_16[7];
   assign product_17 [0] = reg_17[1] ^ reg_17[4] ^ reg_17[6] ^ reg_17[7];
   assign product_17 [1] = reg_17[2] ^ reg_17[5] ^ reg_17[7];
   assign product_17 [2] = reg_17[1] ^ reg_17[3] ^ reg_17[4] ^ reg_17[7];
   assign product_17 [3] = reg_17[0] ^ reg_17[1] ^ reg_17[2] ^ reg_17[5] ^ reg_17[6] ^ reg_17[7];
   assign product_17 [4] = reg_17[0] ^ reg_17[2] ^ reg_17[3] ^ reg_17[4];
   assign product_17 [5] = reg_17[1] ^ reg_17[3] ^ reg_17[4] ^ reg_17[5];
   assign product_17 [6] = reg_17[2] ^ reg_17[4] ^ reg_17[5] ^ reg_17[6];
   assign product_17 [7] = reg_17[0] ^ reg_17[3] ^ reg_17[5] ^ reg_17[6] ^ reg_17[7];
   assign product_18 [0] = reg_18[0] ^ reg_18[3] ^ reg_18[5] ^ reg_18[6] ^ reg_18[7];
   assign product_18 [1] = reg_18[1] ^ reg_18[4] ^ reg_18[6] ^ reg_18[7];
   assign product_18 [2] = reg_18[0] ^ reg_18[2] ^ reg_18[3] ^ reg_18[6];
   assign product_18 [3] = reg_18[0] ^ reg_18[1] ^ reg_18[4] ^ reg_18[5] ^ reg_18[6];
   assign product_18 [4] = reg_18[1] ^ reg_18[2] ^ reg_18[3];
   assign product_18 [5] = reg_18[0] ^ reg_18[2] ^ reg_18[3] ^ reg_18[4];
   assign product_18 [6] = reg_18[1] ^ reg_18[3] ^ reg_18[4] ^ reg_18[5];
   assign product_18 [7] = reg_18[2] ^ reg_18[4] ^ reg_18[5] ^ reg_18[6];
   assign product_19 [0] = reg_19[2] ^ reg_19[4] ^ reg_19[5] ^ reg_19[6];
   assign product_19 [1] = reg_19[0] ^ reg_19[3] ^ reg_19[5] ^ reg_19[6] ^ reg_19[7];
   assign product_19 [2] = reg_19[1] ^ reg_19[2] ^ reg_19[5] ^ reg_19[7];
   assign product_19 [3] = reg_19[0] ^ reg_19[3] ^ reg_19[4] ^ reg_19[5];
   assign product_19 [4] = reg_19[0] ^ reg_19[1] ^ reg_19[2];
   assign product_19 [5] = reg_19[1] ^ reg_19[2] ^ reg_19[3];
   assign product_19 [6] = reg_19[0] ^ reg_19[2] ^ reg_19[3] ^ reg_19[4];
   assign product_19 [7] = reg_19[1] ^ reg_19[3] ^ reg_19[4] ^ reg_19[5];
   assign product_20 [0] = reg_20[1] ^ reg_20[3] ^ reg_20[4] ^ reg_20[5];
   assign product_20 [1] = reg_20[2] ^ reg_20[4] ^ reg_20[5] ^ reg_20[6];
   assign product_20 [2] = reg_20[0] ^ reg_20[1] ^ reg_20[4] ^ reg_20[6] ^ reg_20[7];
   assign product_20 [3] = reg_20[2] ^ reg_20[3] ^ reg_20[4] ^ reg_20[7];
   assign product_20 [4] = reg_20[0] ^ reg_20[1];
   assign product_20 [5] = reg_20[0] ^ reg_20[1] ^ reg_20[2];
   assign product_20 [6] = reg_20[1] ^ reg_20[2] ^ reg_20[3];
   assign product_20 [7] = reg_20[0] ^ reg_20[2] ^ reg_20[3] ^ reg_20[4];
   assign product_21 [0] = reg_21[0] ^ reg_21[2] ^ reg_21[3] ^ reg_21[4];
   assign product_21 [1] = reg_21[1] ^ reg_21[3] ^ reg_21[4] ^ reg_21[5];
   assign product_21 [2] = reg_21[0] ^ reg_21[3] ^ reg_21[5] ^ reg_21[6];
   assign product_21 [3] = reg_21[1] ^ reg_21[2] ^ reg_21[3] ^ reg_21[6] ^ reg_21[7];
   assign product_21 [4] = reg_21[0] ^ reg_21[7];
   assign product_21 [5] = reg_21[0] ^ reg_21[1];
   assign product_21 [6] = reg_21[0] ^ reg_21[1] ^ reg_21[2];
   assign product_21 [7] = reg_21[1] ^ reg_21[2] ^ reg_21[3];



   //------------------------------------------------------------------------
   // + REG_0,..., REG_21
   //------------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         reg_0 [7:0]  <= 8'd0;
         reg_1 [7:0]  <= 8'd0;
         reg_2 [7:0]  <= 8'd0;
         reg_3 [7:0]  <= 8'd0;
         reg_4 [7:0]  <= 8'd0;
         reg_5 [7:0]  <= 8'd0;
         reg_6 [7:0]  <= 8'd0;
         reg_7 [7:0]  <= 8'd0;
         reg_8 [7:0]  <= 8'd0;
         reg_9 [7:0]  <= 8'd0;
         reg_10 [7:0] <= 8'd0;
         reg_11 [7:0] <= 8'd0;
         reg_12 [7:0] <= 8'd0;
         reg_13 [7:0] <= 8'd0;
         reg_14 [7:0] <= 8'd0;
         reg_15 [7:0] <= 8'd0;
         reg_16 [7:0] <= 8'd0;
         reg_17 [7:0] <= 8'd0;
         reg_18 [7:0] <= 8'd0;
         reg_19 [7:0] <= 8'd0;
         reg_20 [7:0] <= 8'd0;
         reg_21 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            reg_0 [7:0]  <= dataIn[7:0];
            reg_1 [7:0]  <= dataIn[7:0];
            reg_2 [7:0]  <= dataIn[7:0];
            reg_3 [7:0]  <= dataIn[7:0];
            reg_4 [7:0]  <= dataIn[7:0];
            reg_5 [7:0]  <= dataIn[7:0];
            reg_6 [7:0]  <= dataIn[7:0];
            reg_7 [7:0]  <= dataIn[7:0];
            reg_8 [7:0]  <= dataIn[7:0];
            reg_9 [7:0]  <= dataIn[7:0];
            reg_10 [7:0] <= dataIn[7:0];
            reg_11 [7:0] <= dataIn[7:0];
            reg_12 [7:0] <= dataIn[7:0];
            reg_13 [7:0] <= dataIn[7:0];
            reg_14 [7:0] <= dataIn[7:0];
            reg_15 [7:0] <= dataIn[7:0];
            reg_16 [7:0] <= dataIn[7:0];
            reg_17 [7:0] <= dataIn[7:0];
            reg_18 [7:0] <= dataIn[7:0];
            reg_19 [7:0] <= dataIn[7:0];
            reg_20 [7:0] <= dataIn[7:0];
            reg_21 [7:0] <= dataIn[7:0];
         end
         else begin
            reg_0 [7:0]  <= dataIn [7:0] ^ product_0[7:0];
            reg_1 [7:0]  <= dataIn [7:0] ^ product_1[7:0];
            reg_2 [7:0]  <= dataIn [7:0] ^ product_2[7:0];
            reg_3 [7:0]  <= dataIn [7:0] ^ product_3[7:0];
            reg_4 [7:0]  <= dataIn [7:0] ^ product_4[7:0];
            reg_5 [7:0]  <= dataIn [7:0] ^ product_5[7:0];
            reg_6 [7:0]  <= dataIn [7:0] ^ product_6[7:0];
            reg_7 [7:0]  <= dataIn [7:0] ^ product_7[7:0];
            reg_8 [7:0]  <= dataIn [7:0] ^ product_8[7:0];
            reg_9 [7:0]  <= dataIn [7:0] ^ product_9[7:0];
            reg_10 [7:0] <= dataIn [7:0] ^ product_10[7:0];
            reg_11 [7:0] <= dataIn [7:0] ^ product_11[7:0];
            reg_12 [7:0] <= dataIn [7:0] ^ product_12[7:0];
            reg_13 [7:0] <= dataIn [7:0] ^ product_13[7:0];
            reg_14 [7:0] <= dataIn [7:0] ^ product_14[7:0];
            reg_15 [7:0] <= dataIn [7:0] ^ product_15[7:0];
            reg_16 [7:0] <= dataIn [7:0] ^ product_16[7:0];
            reg_17 [7:0] <= dataIn [7:0] ^ product_17[7:0];
            reg_18 [7:0] <= dataIn [7:0] ^ product_18[7:0];
            reg_19 [7:0] <= dataIn [7:0] ^ product_19[7:0];
            reg_20 [7:0] <= dataIn [7:0] ^ product_20[7:0];
            reg_21 [7:0] <= dataIn [7:0] ^ product_21[7:0];
         end
      end
   end



   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   assign   syndrome_0[7:0]  = reg_0[7:0];
   assign   syndrome_1[7:0]  = reg_1[7:0];
   assign   syndrome_2[7:0]  = reg_2[7:0];
   assign   syndrome_3[7:0]  = reg_3[7:0];
   assign   syndrome_4[7:0]  = reg_4[7:0];
   assign   syndrome_5[7:0]  = reg_5[7:0];
   assign   syndrome_6[7:0]  = reg_6[7:0];
   assign   syndrome_7[7:0]  = reg_7[7:0];
   assign   syndrome_8[7:0]  = reg_8[7:0];
   assign   syndrome_9[7:0]  = reg_9[7:0];
   assign   syndrome_10[7:0] = reg_10[7:0];
   assign   syndrome_11[7:0] = reg_11[7:0];
   assign   syndrome_12[7:0] = reg_12[7:0];
   assign   syndrome_13[7:0] = reg_13[7:0];
   assign   syndrome_14[7:0] = reg_14[7:0];
   assign   syndrome_15[7:0] = reg_15[7:0];
   assign   syndrome_16[7:0] = reg_16[7:0];
   assign   syndrome_17[7:0] = reg_17[7:0];
   assign   syndrome_18[7:0] = reg_18[7:0];
   assign   syndrome_19[7:0] = reg_19[7:0];
   assign   syndrome_20[7:0] = reg_20[7:0];
   assign   syndrome_21[7:0] = reg_21[7:0];

endmodule
