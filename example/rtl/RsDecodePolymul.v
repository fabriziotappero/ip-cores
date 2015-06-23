//===================================================================
// Module Name : RsDecodePolymul
// File Name   : RsDecodePolymul.v
// Function    : Rs Decoder polymul calculation Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodePolymul(
   CLK,              // system clock
   RESET,            // system reset
   enable,           // enable signal
   sync,             // sync signal
   syndromeIn_0,     // syndrome polynom 0
   syndromeIn_1,     // syndrome polynom 1
   syndromeIn_2,     // syndrome polynom 2
   syndromeIn_3,     // syndrome polynom 3
   syndromeIn_4,     // syndrome polynom 4
   syndromeIn_5,     // syndrome polynom 5
   syndromeIn_6,     // syndrome polynom 6
   syndromeIn_7,     // syndrome polynom 7
   syndromeIn_8,     // syndrome polynom 8
   syndromeIn_9,     // syndrome polynom 9
   syndromeIn_10,    // syndrome polynom 10
   syndromeIn_11,    // syndrome polynom 11
   syndromeIn_12,    // syndrome polynom 12
   syndromeIn_13,    // syndrome polynom 13
   syndromeIn_14,    // syndrome polynom 14
   syndromeIn_15,    // syndrome polynom 15
   syndromeIn_16,    // syndrome polynom 16
   syndromeIn_17,    // syndrome polynom 17
   syndromeIn_18,    // syndrome polynom 18
   syndromeIn_19,    // syndrome polynom 19
   syndromeIn_20,    // syndrome polynom 20
   syndromeIn_21,    // syndrome polynom 21
   epsilon_0,        // epsilon polynom 0
   epsilon_1,        // epsilon polynom 1
   epsilon_2,        // epsilon polynom 2
   epsilon_3,        // epsilon polynom 3
   epsilon_4,        // epsilon polynom 4
   epsilon_5,        // epsilon polynom 5
   epsilon_6,        // epsilon polynom 6
   epsilon_7,        // epsilon polynom 7
   epsilon_8,        // epsilon polynom 8
   epsilon_9,        // epsilon polynom 9
   epsilon_10,       // epsilon polynom 10
   epsilon_11,       // epsilon polynom 11
   epsilon_12,       // epsilon polynom 12
   epsilon_13,       // epsilon polynom 13
   epsilon_14,       // epsilon polynom 14
   epsilon_15,       // epsilon polynom 15
   epsilon_16,       // epsilon polynom 16
   epsilon_17,       // epsilon polynom 17
   epsilon_18,       // epsilon polynom 18
   epsilon_19,       // epsilon polynom 19
   epsilon_20,       // epsilon polynom 20
   epsilon_21,       // epsilon polynom 21
   epsilon_22,       // epsilon polynom 22
   syndromeOut_0,    // modified syndrome polynom 0
   syndromeOut_1,    // modified syndrome polynom 1
   syndromeOut_2,    // modified syndrome polynom 2
   syndromeOut_3,    // modified syndrome polynom 3
   syndromeOut_4,    // modified syndrome polynom 4
   syndromeOut_5,    // modified syndrome polynom 5
   syndromeOut_6,    // modified syndrome polynom 6
   syndromeOut_7,    // modified syndrome polynom 7
   syndromeOut_8,    // modified syndrome polynom 8
   syndromeOut_9,    // modified syndrome polynom 9
   syndromeOut_10,   // modified syndrome polynom 10
   syndromeOut_11,   // modified syndrome polynom 11
   syndromeOut_12,   // modified syndrome polynom 12
   syndromeOut_13,   // modified syndrome polynom 13
   syndromeOut_14,   // modified syndrome polynom 14
   syndromeOut_15,   // modified syndrome polynom 15
   syndromeOut_16,   // modified syndrome polynom 16
   syndromeOut_17,   // modified syndrome polynom 17
   syndromeOut_18,   // modified syndrome polynom 18
   syndromeOut_19,   // modified syndrome polynom 19
   syndromeOut_20,   // modified syndrome polynom 20
   syndromeOut_21,   // modified syndrome polynom 21
   done              // done signal
);


   input          CLK;              // system clock
   input          RESET;            // system reset
   input          enable;           // enable signal
   input          sync;             // sync signal
   input  [7:0]   syndromeIn_0;     // syndrome polynom 0
   input  [7:0]   syndromeIn_1;     // syndrome polynom 1
   input  [7:0]   syndromeIn_2;     // syndrome polynom 2
   input  [7:0]   syndromeIn_3;     // syndrome polynom 3
   input  [7:0]   syndromeIn_4;     // syndrome polynom 4
   input  [7:0]   syndromeIn_5;     // syndrome polynom 5
   input  [7:0]   syndromeIn_6;     // syndrome polynom 6
   input  [7:0]   syndromeIn_7;     // syndrome polynom 7
   input  [7:0]   syndromeIn_8;     // syndrome polynom 8
   input  [7:0]   syndromeIn_9;     // syndrome polynom 9
   input  [7:0]   syndromeIn_10;    // syndrome polynom 10
   input  [7:0]   syndromeIn_11;    // syndrome polynom 11
   input  [7:0]   syndromeIn_12;    // syndrome polynom 12
   input  [7:0]   syndromeIn_13;    // syndrome polynom 13
   input  [7:0]   syndromeIn_14;    // syndrome polynom 14
   input  [7:0]   syndromeIn_15;    // syndrome polynom 15
   input  [7:0]   syndromeIn_16;    // syndrome polynom 16
   input  [7:0]   syndromeIn_17;    // syndrome polynom 17
   input  [7:0]   syndromeIn_18;    // syndrome polynom 18
   input  [7:0]   syndromeIn_19;    // syndrome polynom 19
   input  [7:0]   syndromeIn_20;    // syndrome polynom 20
   input  [7:0]   syndromeIn_21;    // syndrome polynom 21
   input  [7:0]   epsilon_0;        // epsilon polynom 0
   input  [7:0]   epsilon_1;        // epsilon polynom 1
   input  [7:0]   epsilon_2;        // epsilon polynom 2
   input  [7:0]   epsilon_3;        // epsilon polynom 3
   input  [7:0]   epsilon_4;        // epsilon polynom 4
   input  [7:0]   epsilon_5;        // epsilon polynom 5
   input  [7:0]   epsilon_6;        // epsilon polynom 6
   input  [7:0]   epsilon_7;        // epsilon polynom 7
   input  [7:0]   epsilon_8;        // epsilon polynom 8
   input  [7:0]   epsilon_9;        // epsilon polynom 9
   input  [7:0]   epsilon_10;       // epsilon polynom 10
   input  [7:0]   epsilon_11;       // epsilon polynom 11
   input  [7:0]   epsilon_12;       // epsilon polynom 12
   input  [7:0]   epsilon_13;       // epsilon polynom 13
   input  [7:0]   epsilon_14;       // epsilon polynom 14
   input  [7:0]   epsilon_15;       // epsilon polynom 15
   input  [7:0]   epsilon_16;       // epsilon polynom 16
   input  [7:0]   epsilon_17;       // epsilon polynom 17
   input  [7:0]   epsilon_18;       // epsilon polynom 18
   input  [7:0]   epsilon_19;       // epsilon polynom 19
   input  [7:0]   epsilon_20;       // epsilon polynom 20
   input  [7:0]   epsilon_21;       // epsilon polynom 21
   input  [7:0]   epsilon_22;       // epsilon polynom 22

   output [7:0]   syndromeOut_0;    // modified syndrome polynom 0
   output [7:0]   syndromeOut_1;    // modified syndrome polynom 1
   output [7:0]   syndromeOut_2;    // modified syndrome polynom 2
   output [7:0]   syndromeOut_3;    // modified syndrome polynom 3
   output [7:0]   syndromeOut_4;    // modified syndrome polynom 4
   output [7:0]   syndromeOut_5;    // modified syndrome polynom 5
   output [7:0]   syndromeOut_6;    // modified syndrome polynom 6
   output [7:0]   syndromeOut_7;    // modified syndrome polynom 7
   output [7:0]   syndromeOut_8;    // modified syndrome polynom 8
   output [7:0]   syndromeOut_9;    // modified syndrome polynom 9
   output [7:0]   syndromeOut_10;   // modified syndrome polynom 10
   output [7:0]   syndromeOut_11;   // modified syndrome polynom 11
   output [7:0]   syndromeOut_12;   // modified syndrome polynom 12
   output [7:0]   syndromeOut_13;   // modified syndrome polynom 13
   output [7:0]   syndromeOut_14;   // modified syndrome polynom 14
   output [7:0]   syndromeOut_15;   // modified syndrome polynom 15
   output [7:0]   syndromeOut_16;   // modified syndrome polynom 16
   output [7:0]   syndromeOut_17;   // modified syndrome polynom 17
   output [7:0]   syndromeOut_18;   // modified syndrome polynom 18
   output [7:0]   syndromeOut_19;   // modified syndrome polynom 19
   output [7:0]   syndromeOut_20;   // modified syndrome polynom 20
   output [7:0]   syndromeOut_21;   // modified syndrome polynom 21
   output         done;             // done signal





   //------------------------------------------------------------------------
   // + count
   //- Counter
   //------------------------------------------------------------------------
   reg    [4:0]   count;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         count [4:0] <= 5'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            count[4:0] <= 5'd1;
         end
         else if ((count[4:0] ==5'd0) || (count[4:0] ==5'd23)) begin
            count[4:0] <= 5'd0;
         end
         else begin
            count[4:0] <= count[4:0] + 5'd1;
         end
      end
   end


   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   reg         done;
   always @(count) begin
      if (count[4:0] == 5'd23) begin
         done = 1'b1;
      end
      else begin
         done = 1'b0;
      end
   end


   //------------------------------------------------------------------------
   // + syndromeReg_0,..., syndromeReg_21
   //------------------------------------------------------------------------
   reg [7:0]   syndromeReg_0;
   reg [7:0]   syndromeReg_1;
   reg [7:0]   syndromeReg_2;
   reg [7:0]   syndromeReg_3;
   reg [7:0]   syndromeReg_4;
   reg [7:0]   syndromeReg_5;
   reg [7:0]   syndromeReg_6;
   reg [7:0]   syndromeReg_7;
   reg [7:0]   syndromeReg_8;
   reg [7:0]   syndromeReg_9;
   reg [7:0]   syndromeReg_10;
   reg [7:0]   syndromeReg_11;
   reg [7:0]   syndromeReg_12;
   reg [7:0]   syndromeReg_13;
   reg [7:0]   syndromeReg_14;
   reg [7:0]   syndromeReg_15;
   reg [7:0]   syndromeReg_16;
   reg [7:0]   syndromeReg_17;
   reg [7:0]   syndromeReg_18;
   reg [7:0]   syndromeReg_19;
   reg [7:0]   syndromeReg_20;
   reg [7:0]   syndromeReg_21;


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
      else if ((enable == 1'b1) && (sync == 1'b1)) begin
         syndromeReg_0 [7:0]  <= syndromeIn_0 [7:0];
         syndromeReg_1 [7:0]  <= syndromeIn_1 [7:0];
         syndromeReg_2 [7:0]  <= syndromeIn_2 [7:0];
         syndromeReg_3 [7:0]  <= syndromeIn_3 [7:0];
         syndromeReg_4 [7:0]  <= syndromeIn_4 [7:0];
         syndromeReg_5 [7:0]  <= syndromeIn_5 [7:0];
         syndromeReg_6 [7:0]  <= syndromeIn_6 [7:0];
         syndromeReg_7 [7:0]  <= syndromeIn_7 [7:0];
         syndromeReg_8 [7:0]  <= syndromeIn_8 [7:0];
         syndromeReg_9 [7:0]  <= syndromeIn_9 [7:0];
         syndromeReg_10 [7:0] <= syndromeIn_10 [7:0];
         syndromeReg_11 [7:0] <= syndromeIn_11 [7:0];
         syndromeReg_12 [7:0] <= syndromeIn_12 [7:0];
         syndromeReg_13 [7:0] <= syndromeIn_13 [7:0];
         syndromeReg_14 [7:0] <= syndromeIn_14 [7:0];
         syndromeReg_15 [7:0] <= syndromeIn_15 [7:0];
         syndromeReg_16 [7:0] <= syndromeIn_16 [7:0];
         syndromeReg_17 [7:0] <= syndromeIn_17 [7:0];
         syndromeReg_18 [7:0] <= syndromeIn_18 [7:0];
         syndromeReg_19 [7:0] <= syndromeIn_19 [7:0];
         syndromeReg_20 [7:0] <= syndromeIn_20 [7:0];
         syndromeReg_21 [7:0] <= syndromeIn_21 [7:0];
      end
   end
   //------------------------------------------------------------------------
   // + epsilonReg_0,..., epsilonReg_22
   //------------------------------------------------------------------------
   reg [7:0]   epsilonReg_0;
   reg [7:0]   epsilonReg_1;
   reg [7:0]   epsilonReg_2;
   reg [7:0]   epsilonReg_3;
   reg [7:0]   epsilonReg_4;
   reg [7:0]   epsilonReg_5;
   reg [7:0]   epsilonReg_6;
   reg [7:0]   epsilonReg_7;
   reg [7:0]   epsilonReg_8;
   reg [7:0]   epsilonReg_9;
   reg [7:0]   epsilonReg_10;
   reg [7:0]   epsilonReg_11;
   reg [7:0]   epsilonReg_12;
   reg [7:0]   epsilonReg_13;
   reg [7:0]   epsilonReg_14;
   reg [7:0]   epsilonReg_15;
   reg [7:0]   epsilonReg_16;
   reg [7:0]   epsilonReg_17;
   reg [7:0]   epsilonReg_18;
   reg [7:0]   epsilonReg_19;
   reg [7:0]   epsilonReg_20;
   reg [7:0]   epsilonReg_21;
   reg [7:0]   epsilonReg_22;

   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         epsilonReg_0 [7:0]  <= 8'd0;
         epsilonReg_1 [7:0]  <= 8'd0;
         epsilonReg_2 [7:0]  <= 8'd0;
         epsilonReg_3 [7:0]  <= 8'd0;
         epsilonReg_4 [7:0]  <= 8'd0;
         epsilonReg_5 [7:0]  <= 8'd0;
         epsilonReg_6 [7:0]  <= 8'd0;
         epsilonReg_7 [7:0]  <= 8'd0;
         epsilonReg_8 [7:0]  <= 8'd0;
         epsilonReg_9 [7:0]  <= 8'd0;
         epsilonReg_10 [7:0] <= 8'd0;
         epsilonReg_11 [7:0] <= 8'd0;
         epsilonReg_12 [7:0] <= 8'd0;
         epsilonReg_13 [7:0] <= 8'd0;
         epsilonReg_14 [7:0] <= 8'd0;
         epsilonReg_15 [7:0] <= 8'd0;
         epsilonReg_16 [7:0] <= 8'd0;
         epsilonReg_17 [7:0] <= 8'd0;
         epsilonReg_18 [7:0] <= 8'd0;
         epsilonReg_19 [7:0] <= 8'd0;
         epsilonReg_20 [7:0] <= 8'd0;
         epsilonReg_21 [7:0] <= 8'd0;
         epsilonReg_22 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            epsilonReg_0 [7:0]  <= 8'd0;
            epsilonReg_1 [7:0]  <= epsilon_0[7:0];
            epsilonReg_2 [7:0]  <= epsilon_1[7:0];
            epsilonReg_3 [7:0]  <= epsilon_2[7:0];
            epsilonReg_4 [7:0]  <= epsilon_3[7:0];
            epsilonReg_5 [7:0]  <= epsilon_4[7:0];
            epsilonReg_6 [7:0]  <= epsilon_5[7:0];
            epsilonReg_7 [7:0]  <= epsilon_6[7:0];
            epsilonReg_8 [7:0]  <= epsilon_7[7:0];
            epsilonReg_9 [7:0]  <= epsilon_8[7:0];
            epsilonReg_10 [7:0] <= epsilon_9[7:0];
            epsilonReg_11 [7:0] <= epsilon_10[7:0];
            epsilonReg_12 [7:0] <= epsilon_11[7:0];
            epsilonReg_13 [7:0] <= epsilon_12[7:0];
            epsilonReg_14 [7:0] <= epsilon_13[7:0];
            epsilonReg_15 [7:0] <= epsilon_14[7:0];
            epsilonReg_16 [7:0] <= epsilon_15[7:0];
            epsilonReg_17 [7:0] <= epsilon_16[7:0];
            epsilonReg_18 [7:0] <= epsilon_17[7:0];
            epsilonReg_19 [7:0] <= epsilon_18[7:0];
            epsilonReg_20 [7:0] <= epsilon_19[7:0];
            epsilonReg_21 [7:0] <= epsilon_20[7:0];
            epsilonReg_22 [7:0] <= epsilon_21[7:0];
         end
         else begin
            epsilonReg_0 [7:0]  <= 8'd0;
            epsilonReg_1 [7:0]  <= epsilonReg_0[7:0];
            epsilonReg_2 [7:0]  <= epsilonReg_1[7:0];
            epsilonReg_3 [7:0]  <= epsilonReg_2[7:0];
            epsilonReg_4 [7:0]  <= epsilonReg_3[7:0];
            epsilonReg_5 [7:0]  <= epsilonReg_4[7:0];
            epsilonReg_6 [7:0]  <= epsilonReg_5[7:0];
            epsilonReg_7 [7:0]  <= epsilonReg_6[7:0];
            epsilonReg_8 [7:0]  <= epsilonReg_7[7:0];
            epsilonReg_9 [7:0]  <= epsilonReg_8[7:0];
            epsilonReg_10 [7:0] <= epsilonReg_9[7:0];
            epsilonReg_11 [7:0] <= epsilonReg_10[7:0];
            epsilonReg_12 [7:0] <= epsilonReg_11[7:0];
            epsilonReg_13 [7:0] <= epsilonReg_12[7:0];
            epsilonReg_14 [7:0] <= epsilonReg_13[7:0];
            epsilonReg_15 [7:0] <= epsilonReg_14[7:0];
            epsilonReg_16 [7:0] <= epsilonReg_15[7:0];
            epsilonReg_17 [7:0] <= epsilonReg_16[7:0];
            epsilonReg_18 [7:0] <= epsilonReg_17[7:0];
            epsilonReg_19 [7:0] <= epsilonReg_18[7:0];
            epsilonReg_20 [7:0] <= epsilonReg_19[7:0];
            epsilonReg_21 [7:0] <= epsilonReg_20[7:0];
            epsilonReg_22 [7:0] <= epsilonReg_21[7:0];
         end
      end
   end


    //------------------------------------------------------------------------
    // + epsilonMsb
    //------------------------------------------------------------------------
    reg [7:0]   epsilonMsb;

   always @(sync or epsilon_22 or epsilonReg_22 ) begin
      if (sync == 1'b1) begin
         epsilonMsb [7:0] = epsilon_22 [7:0];
      end
      else begin
         epsilonMsb [7:0] = epsilonReg_22 [7:0];
      end
   end


   //------------------------------------------------------------------------
   // + product_0,..., product_21
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


    RsDecodeMult  RsDecodeMult_0  (  .A(epsilonMsb[7:0]), .B(syndromeReg_0[7:0]), .P(product_0[7:0]));
    RsDecodeMult  RsDecodeMult_1  (  .A(epsilonMsb[7:0]), .B(syndromeReg_1[7:0]), .P(product_1[7:0]));
    RsDecodeMult  RsDecodeMult_2  (  .A(epsilonMsb[7:0]), .B(syndromeReg_2[7:0]), .P(product_2[7:0]));
    RsDecodeMult  RsDecodeMult_3  (  .A(epsilonMsb[7:0]), .B(syndromeReg_3[7:0]), .P(product_3[7:0]));
    RsDecodeMult  RsDecodeMult_4  (  .A(epsilonMsb[7:0]), .B(syndromeReg_4[7:0]), .P(product_4[7:0]));
    RsDecodeMult  RsDecodeMult_5  (  .A(epsilonMsb[7:0]), .B(syndromeReg_5[7:0]), .P(product_5[7:0]));
    RsDecodeMult  RsDecodeMult_6  (  .A(epsilonMsb[7:0]), .B(syndromeReg_6[7:0]), .P(product_6[7:0]));
    RsDecodeMult  RsDecodeMult_7  (  .A(epsilonMsb[7:0]), .B(syndromeReg_7[7:0]), .P(product_7[7:0]));
    RsDecodeMult  RsDecodeMult_8  (  .A(epsilonMsb[7:0]), .B(syndromeReg_8[7:0]), .P(product_8[7:0]));
    RsDecodeMult  RsDecodeMult_9  (  .A(epsilonMsb[7:0]), .B(syndromeReg_9[7:0]), .P(product_9[7:0]));
    RsDecodeMult  RsDecodeMult_10 (  .A(epsilonMsb[7:0]), .B(syndromeReg_10[7:0]), .P(product_10[7:0]));
    RsDecodeMult  RsDecodeMult_11 (  .A(epsilonMsb[7:0]), .B(syndromeReg_11[7:0]), .P(product_11[7:0]));
    RsDecodeMult  RsDecodeMult_12 (  .A(epsilonMsb[7:0]), .B(syndromeReg_12[7:0]), .P(product_12[7:0]));
    RsDecodeMult  RsDecodeMult_13 (  .A(epsilonMsb[7:0]), .B(syndromeReg_13[7:0]), .P(product_13[7:0]));
    RsDecodeMult  RsDecodeMult_14 (  .A(epsilonMsb[7:0]), .B(syndromeReg_14[7:0]), .P(product_14[7:0]));
    RsDecodeMult  RsDecodeMult_15 (  .A(epsilonMsb[7:0]), .B(syndromeReg_15[7:0]), .P(product_15[7:0]));
    RsDecodeMult  RsDecodeMult_16 (  .A(epsilonMsb[7:0]), .B(syndromeReg_16[7:0]), .P(product_16[7:0]));
    RsDecodeMult  RsDecodeMult_17 (  .A(epsilonMsb[7:0]), .B(syndromeReg_17[7:0]), .P(product_17[7:0]));
    RsDecodeMult  RsDecodeMult_18 (  .A(epsilonMsb[7:0]), .B(syndromeReg_18[7:0]), .P(product_18[7:0]));
    RsDecodeMult  RsDecodeMult_19 (  .A(epsilonMsb[7:0]), .B(syndromeReg_19[7:0]), .P(product_19[7:0]));
    RsDecodeMult  RsDecodeMult_20 (  .A(epsilonMsb[7:0]), .B(syndromeReg_20[7:0]), .P(product_20[7:0]));
    RsDecodeMult  RsDecodeMult_21 (  .A(epsilonMsb[7:0]), .B(syndromeReg_21[7:0]), .P(product_21[7:0]));



   //------------------------------------------------------------------------
   // + sumReg_0,..., sumReg_21
   //------------------------------------------------------------------------
   reg [7:0]   sumReg_0;
   reg [7:0]   sumReg_1;
   reg [7:0]   sumReg_2;
   reg [7:0]   sumReg_3;
   reg [7:0]   sumReg_4;
   reg [7:0]   sumReg_5;
   reg [7:0]   sumReg_6;
   reg [7:0]   sumReg_7;
   reg [7:0]   sumReg_8;
   reg [7:0]   sumReg_9;
   reg [7:0]   sumReg_10;
   reg [7:0]   sumReg_11;
   reg [7:0]   sumReg_12;
   reg [7:0]   sumReg_13;
   reg [7:0]   sumReg_14;
   reg [7:0]   sumReg_15;
   reg [7:0]   sumReg_16;
   reg [7:0]   sumReg_17;
   reg [7:0]   sumReg_18;
   reg [7:0]   sumReg_19;
   reg [7:0]   sumReg_20;
   reg [7:0]   sumReg_21;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         sumReg_0 [7:0]  <= 8'd0;
         sumReg_1 [7:0]  <= 8'd0;
         sumReg_2 [7:0]  <= 8'd0;
         sumReg_3 [7:0]  <= 8'd0;
         sumReg_4 [7:0]  <= 8'd0;
         sumReg_5 [7:0]  <= 8'd0;
         sumReg_6 [7:0]  <= 8'd0;
         sumReg_7 [7:0]  <= 8'd0;
         sumReg_8 [7:0]  <= 8'd0;
         sumReg_9 [7:0]  <= 8'd0;
         sumReg_10 [7:0] <= 8'd0;
         sumReg_11 [7:0] <= 8'd0;
         sumReg_12 [7:0] <= 8'd0;
         sumReg_13 [7:0] <= 8'd0;
         sumReg_14 [7:0] <= 8'd0;
         sumReg_15 [7:0] <= 8'd0;
         sumReg_16 [7:0] <= 8'd0;
         sumReg_17 [7:0] <= 8'd0;
         sumReg_18 [7:0] <= 8'd0;
         sumReg_19 [7:0] <= 8'd0;
         sumReg_20 [7:0] <= 8'd0;
         sumReg_21 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            if (epsilon_22[7:0] != 8'd0) begin
               sumReg_0 [7:0]  <= syndromeIn_0 [7:0];
               sumReg_1 [7:0]  <= syndromeIn_1 [7:0];
               sumReg_2 [7:0]  <= syndromeIn_2 [7:0];
               sumReg_3 [7:0]  <= syndromeIn_3 [7:0];
               sumReg_4 [7:0]  <= syndromeIn_4 [7:0];
               sumReg_5 [7:0]  <= syndromeIn_5 [7:0];
               sumReg_6 [7:0]  <= syndromeIn_6 [7:0];
               sumReg_7 [7:0]  <= syndromeIn_7 [7:0];
               sumReg_8 [7:0]  <= syndromeIn_8 [7:0];
               sumReg_9 [7:0]  <= syndromeIn_9 [7:0];
               sumReg_10 [7:0] <= syndromeIn_10 [7:0];
               sumReg_11 [7:0] <= syndromeIn_11 [7:0];
               sumReg_12 [7:0] <= syndromeIn_12 [7:0];
               sumReg_13 [7:0] <= syndromeIn_13 [7:0];
               sumReg_14 [7:0] <= syndromeIn_14 [7:0];
               sumReg_15 [7:0] <= syndromeIn_15 [7:0];
               sumReg_16 [7:0] <= syndromeIn_16 [7:0];
               sumReg_17 [7:0] <= syndromeIn_17 [7:0];
               sumReg_18 [7:0] <= syndromeIn_18 [7:0];
               sumReg_19 [7:0] <= syndromeIn_19 [7:0];
               sumReg_20 [7:0] <= syndromeIn_20 [7:0];
               sumReg_21 [7:0] <= syndromeIn_21 [7:0];
            end
            else begin
               sumReg_0 [7:0]  <= 8'd0;
               sumReg_1 [7:0]  <= 8'd0;
               sumReg_2 [7:0]  <= 8'd0;
               sumReg_3 [7:0]  <= 8'd0;
               sumReg_4 [7:0]  <= 8'd0;
               sumReg_5 [7:0]  <= 8'd0;
               sumReg_6 [7:0]  <= 8'd0;
               sumReg_7 [7:0]  <= 8'd0;
               sumReg_8 [7:0]  <= 8'd0;
               sumReg_9 [7:0]  <= 8'd0;
               sumReg_10 [7:0] <= 8'd0;
               sumReg_11 [7:0] <= 8'd0;
               sumReg_12 [7:0] <= 8'd0;
               sumReg_13 [7:0] <= 8'd0;
               sumReg_14 [7:0] <= 8'd0;
               sumReg_15 [7:0] <= 8'd0;
               sumReg_16 [7:0] <= 8'd0;
               sumReg_17 [7:0] <= 8'd0;
               sumReg_18 [7:0] <= 8'd0;
               sumReg_19 [7:0] <= 8'd0;
               sumReg_20 [7:0] <= 8'd0;
               sumReg_21 [7:0] <= 8'd0;
            end
         end
         else begin
            sumReg_0 [7:0]  <= product_0 [7:0];
            sumReg_1  [7:0] <= sumReg_0  [7:0] ^ product_1  [7:0];
            sumReg_2  [7:0] <= sumReg_1  [7:0] ^ product_2  [7:0];
            sumReg_3  [7:0] <= sumReg_2  [7:0] ^ product_3  [7:0];
            sumReg_4  [7:0] <= sumReg_3  [7:0] ^ product_4  [7:0];
            sumReg_5  [7:0] <= sumReg_4  [7:0] ^ product_5  [7:0];
            sumReg_6  [7:0] <= sumReg_5  [7:0] ^ product_6  [7:0];
            sumReg_7  [7:0] <= sumReg_6  [7:0] ^ product_7  [7:0];
            sumReg_8  [7:0] <= sumReg_7  [7:0] ^ product_8  [7:0];
            sumReg_9  [7:0] <= sumReg_8  [7:0] ^ product_9  [7:0];
            sumReg_10 [7:0] <= sumReg_9 [7:0] ^ product_10 [7:0];
            sumReg_11 [7:0] <= sumReg_10 [7:0] ^ product_11 [7:0];
            sumReg_12 [7:0] <= sumReg_11 [7:0] ^ product_12 [7:0];
            sumReg_13 [7:0] <= sumReg_12 [7:0] ^ product_13 [7:0];
            sumReg_14 [7:0] <= sumReg_13 [7:0] ^ product_14 [7:0];
            sumReg_15 [7:0] <= sumReg_14 [7:0] ^ product_15 [7:0];
            sumReg_16 [7:0] <= sumReg_15 [7:0] ^ product_16 [7:0];
            sumReg_17 [7:0] <= sumReg_16 [7:0] ^ product_17 [7:0];
            sumReg_18 [7:0] <= sumReg_17 [7:0] ^ product_18 [7:0];
            sumReg_19 [7:0] <= sumReg_18 [7:0] ^ product_19 [7:0];
            sumReg_20 [7:0] <= sumReg_19 [7:0] ^ product_20 [7:0];
            sumReg_21 [7:0] <= sumReg_20 [7:0] ^ product_21 [7:0];
         end
      end
   end



   //------------------------------------------------------------------------
   // Output signals
   //------------------------------------------------------------------------
   assign   syndromeOut_0  [7:0] = sumReg_0 [7:0];
   assign   syndromeOut_1  [7:0] = sumReg_1 [7:0];
   assign   syndromeOut_2  [7:0] = sumReg_2 [7:0];
   assign   syndromeOut_3  [7:0] = sumReg_3 [7:0];
   assign   syndromeOut_4  [7:0] = sumReg_4 [7:0];
   assign   syndromeOut_5  [7:0] = sumReg_5 [7:0];
   assign   syndromeOut_6  [7:0] = sumReg_6 [7:0];
   assign   syndromeOut_7  [7:0] = sumReg_7 [7:0];
   assign   syndromeOut_8  [7:0] = sumReg_8 [7:0];
   assign   syndromeOut_9  [7:0] = sumReg_9 [7:0];
   assign   syndromeOut_10 [7:0] = sumReg_10 [7:0];
   assign   syndromeOut_11 [7:0] = sumReg_11 [7:0];
   assign   syndromeOut_12 [7:0] = sumReg_12 [7:0];
   assign   syndromeOut_13 [7:0] = sumReg_13 [7:0];
   assign   syndromeOut_14 [7:0] = sumReg_14 [7:0];
   assign   syndromeOut_15 [7:0] = sumReg_15 [7:0];
   assign   syndromeOut_16 [7:0] = sumReg_16 [7:0];
   assign   syndromeOut_17 [7:0] = sumReg_17 [7:0];
   assign   syndromeOut_18 [7:0] = sumReg_18 [7:0];
   assign   syndromeOut_19 [7:0] = sumReg_19 [7:0];
   assign   syndromeOut_20 [7:0] = sumReg_20 [7:0];
   assign   syndromeOut_21 [7:0] = sumReg_21 [7:0];


endmodule
