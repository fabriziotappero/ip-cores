//===================================================================
// Module Name : RsDecodeTop
// File Name   : RsDecodeTop.v
// Function    : Rs Decoder Top Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeTop(
   // Inputs
   CLK,            // system clock
   RESET,          // system reset
   enable,         // system enable
   startPls,       // sync signal
   erasureIn,      // erasure input
   dataIn,         // data input
   // Outputs
   outEnable,      // data out valid signal
   outStartPls,    // first decoded symbol trigger
   outDone,        // last symbol decoded trigger
   errorNum,       // number of errors corrected
   erasureNum,     // number of erasure corrected
   fail,           // decoding failure signal
   delayedData,    // decoding failure signal
   outData         // data output
);


   input          CLK;            // system clock
   input          RESET;          // system reset
   input          enable;         // system enable
   input          startPls;       // sync signal
   input          erasureIn;      // erasure input
   input  [7:0]   dataIn;         // data input
   output         outEnable;      // data out valid signal
   output         outStartPls;    // first decoded symbol trigger
   output         outDone;        // last symbol decoded trigger
   output [7:0]   errorNum;       // number of errors corrected
   output [7:0]   erasureNum;     // number of erasure corrected
   output         fail;           // decoding failure signal
   output [7:0]   delayedData;    // delayed input data
   output [7:0]   outData;        // data output



   //------------------------------------------------------------------------
   // + dataInCheck
   //- assign to 0 if Erasure
   //------------------------------------------------------------------------
   wire [7:0]   dataInCheck;

   assign dataInCheck = (erasureIn == 1'b0) ? dataIn : 8'd0;



    //------------------------------------------------------------------
    // + syndrome_0,...,syndrome_21
    // + doneSyndrome
    //- RS Syndrome calculation
    //------------------------------------------------------------------
    wire [7:0]   syndrome_0;
    wire [7:0]   syndrome_1;
    wire [7:0]   syndrome_2;
    wire [7:0]   syndrome_3;
    wire [7:0]   syndrome_4;
    wire [7:0]   syndrome_5;
    wire [7:0]   syndrome_6;
    wire [7:0]   syndrome_7;
    wire [7:0]   syndrome_8;
    wire [7:0]   syndrome_9;
    wire [7:0]   syndrome_10;
    wire [7:0]   syndrome_11;
    wire [7:0]   syndrome_12;
    wire [7:0]   syndrome_13;
    wire [7:0]   syndrome_14;
    wire [7:0]   syndrome_15;
    wire [7:0]   syndrome_16;
    wire [7:0]   syndrome_17;
    wire [7:0]   syndrome_18;
    wire [7:0]   syndrome_19;
    wire [7:0]   syndrome_20;
    wire [7:0]   syndrome_21;
    wire         doneSyndrome;


   RsDecodeSyndrome RsDecodeSyndrome(
      // Inputs
      .CLK           (CLK),
      .RESET         (RESET),
      .enable        (enable),
      .sync          (startPls),
      .dataIn        (dataInCheck),
      // Outputs
      .syndrome_0    (syndrome_0),
      .syndrome_1    (syndrome_1),
      .syndrome_2    (syndrome_2),
      .syndrome_3    (syndrome_3),
      .syndrome_4    (syndrome_4),
      .syndrome_5    (syndrome_5),
      .syndrome_6    (syndrome_6),
      .syndrome_7    (syndrome_7),
      .syndrome_8    (syndrome_8),
      .syndrome_9    (syndrome_9),
      .syndrome_10   (syndrome_10),
      .syndrome_11   (syndrome_11),
      .syndrome_12   (syndrome_12),
      .syndrome_13   (syndrome_13),
      .syndrome_14   (syndrome_14),
      .syndrome_15   (syndrome_15),
      .syndrome_16   (syndrome_16),
      .syndrome_17   (syndrome_17),
      .syndrome_18   (syndrome_18),
      .syndrome_19   (syndrome_19),
      .syndrome_20   (syndrome_20),
      .syndrome_21   (syndrome_21),
      .done          (doneSyndrome)
   );



   //------------------------------------------------------------------
   // + epsilon_0,..., epsilon_22
   // + degreeEpsilon, failErasure, doneErasure
   //- RS Erasure calculation
   //------------------------------------------------------------------
   wire [7:0]   epsilon_0;
   wire [7:0]   epsilon_1;
   wire [7:0]   epsilon_2;
   wire [7:0]   epsilon_3;
   wire [7:0]   epsilon_4;
   wire [7:0]   epsilon_5;
   wire [7:0]   epsilon_6;
   wire [7:0]   epsilon_7;
   wire [7:0]   epsilon_8;
   wire [7:0]   epsilon_9;
   wire [7:0]   epsilon_10;
   wire [7:0]   epsilon_11;
   wire [7:0]   epsilon_12;
   wire [7:0]   epsilon_13;
   wire [7:0]   epsilon_14;
   wire [7:0]   epsilon_15;
   wire [7:0]   epsilon_16;
   wire [7:0]   epsilon_17;
   wire [7:0]   epsilon_18;
   wire [7:0]   epsilon_19;
   wire [7:0]   epsilon_20;
   wire [7:0]   epsilon_21;
   wire [7:0]   epsilon_22;
   wire [4:0]   degreeEpsilon;
   wire         failErasure;
   wire         doneErasure;


   RsDecodeErasure RsDecodeErasure(
      // Inputs
      .CLK          (CLK),
      .RESET        (RESET),
      .enable       (enable),
      .sync         (startPls),
      .erasureIn    (erasureIn),
      // Outputs
      .epsilon_0    (epsilon_0),
      .epsilon_1    (epsilon_1),
      .epsilon_2    (epsilon_2),
      .epsilon_3    (epsilon_3),
      .epsilon_4    (epsilon_4),
      .epsilon_5    (epsilon_5),
      .epsilon_6    (epsilon_6),
      .epsilon_7    (epsilon_7),
      .epsilon_8    (epsilon_8),
      .epsilon_9    (epsilon_9),
      .epsilon_10   (epsilon_10),
      .epsilon_11   (epsilon_11),
      .epsilon_12   (epsilon_12),
      .epsilon_13   (epsilon_13),
      .epsilon_14   (epsilon_14),
      .epsilon_15   (epsilon_15),
      .epsilon_16   (epsilon_16),
      .epsilon_17   (epsilon_17),
      .epsilon_18   (epsilon_18),
      .epsilon_19   (epsilon_19),
      .epsilon_20   (epsilon_20),
      .epsilon_21   (epsilon_21),
      .epsilon_22   (epsilon_22),
      .numErasure   (degreeEpsilon),
      .fail         (failErasure),
      .done         (doneErasure)
   );



   //------------------------------------------------------------------
   // + polymulSyndrome_0,..., polymulSyndrome_21
   // + donePolymul
   //- RS Polymul calculation
   //------------------------------------------------------------------
    wire [7:0]   polymulSyndrome_0;
    wire [7:0]   polymulSyndrome_1;
    wire [7:0]   polymulSyndrome_2;
    wire [7:0]   polymulSyndrome_3;
    wire [7:0]   polymulSyndrome_4;
    wire [7:0]   polymulSyndrome_5;
    wire [7:0]   polymulSyndrome_6;
    wire [7:0]   polymulSyndrome_7;
    wire [7:0]   polymulSyndrome_8;
    wire [7:0]   polymulSyndrome_9;
    wire [7:0]   polymulSyndrome_10;
    wire [7:0]   polymulSyndrome_11;
    wire [7:0]   polymulSyndrome_12;
    wire [7:0]   polymulSyndrome_13;
    wire [7:0]   polymulSyndrome_14;
    wire [7:0]   polymulSyndrome_15;
    wire [7:0]   polymulSyndrome_16;
    wire [7:0]   polymulSyndrome_17;
    wire [7:0]   polymulSyndrome_18;
    wire [7:0]   polymulSyndrome_19;
    wire [7:0]   polymulSyndrome_20;
    wire [7:0]   polymulSyndrome_21;
    wire         donePolymul;


   RsDecodePolymul RsDecodePolymul(
      // Inputs
      .CLK              (CLK),
      .RESET            (RESET),
      .enable           (enable),
      .sync             (doneSyndrome),
      .syndromeIn_0     (syndrome_0),
      .syndromeIn_1     (syndrome_1),
      .syndromeIn_2     (syndrome_2),
      .syndromeIn_3     (syndrome_3),
      .syndromeIn_4     (syndrome_4),
      .syndromeIn_5     (syndrome_5),
      .syndromeIn_6     (syndrome_6),
      .syndromeIn_7     (syndrome_7),
      .syndromeIn_8     (syndrome_8),
      .syndromeIn_9     (syndrome_9),
      .syndromeIn_10    (syndrome_10),
      .syndromeIn_11    (syndrome_11),
      .syndromeIn_12    (syndrome_12),
      .syndromeIn_13    (syndrome_13),
      .syndromeIn_14    (syndrome_14),
      .syndromeIn_15    (syndrome_15),
      .syndromeIn_16    (syndrome_16),
      .syndromeIn_17    (syndrome_17),
      .syndromeIn_18    (syndrome_18),
      .syndromeIn_19    (syndrome_19),
      .syndromeIn_20    (syndrome_20),
      .syndromeIn_21    (syndrome_21),
      .epsilon_0        (epsilon_0),
      .epsilon_1        (epsilon_1),
      .epsilon_2        (epsilon_2),
      .epsilon_3        (epsilon_3),
      .epsilon_4        (epsilon_4),
      .epsilon_5        (epsilon_5),
      .epsilon_6        (epsilon_6),
      .epsilon_7        (epsilon_7),
      .epsilon_8        (epsilon_8),
      .epsilon_9        (epsilon_9),
      .epsilon_10       (epsilon_10),
      .epsilon_11       (epsilon_11),
      .epsilon_12       (epsilon_12),
      .epsilon_13       (epsilon_13),
      .epsilon_14       (epsilon_14),
      .epsilon_15       (epsilon_15),
      .epsilon_16       (epsilon_16),
      .epsilon_17       (epsilon_17),
      .epsilon_18       (epsilon_18),
      .epsilon_19       (epsilon_19),
      .epsilon_20       (epsilon_20),
      .epsilon_21       (epsilon_21),
      .epsilon_22       (epsilon_22),
      // Outputs
      .syndromeOut_0    (polymulSyndrome_0),
      .syndromeOut_1    (polymulSyndrome_1),
      .syndromeOut_2    (polymulSyndrome_2),
      .syndromeOut_3    (polymulSyndrome_3),
      .syndromeOut_4    (polymulSyndrome_4),
      .syndromeOut_5    (polymulSyndrome_5),
      .syndromeOut_6    (polymulSyndrome_6),
      .syndromeOut_7    (polymulSyndrome_7),
      .syndromeOut_8    (polymulSyndrome_8),
      .syndromeOut_9    (polymulSyndrome_9),
      .syndromeOut_10   (polymulSyndrome_10),
      .syndromeOut_11   (polymulSyndrome_11),
      .syndromeOut_12   (polymulSyndrome_12),
      .syndromeOut_13   (polymulSyndrome_13),
      .syndromeOut_14   (polymulSyndrome_14),
      .syndromeOut_15   (polymulSyndrome_15),
      .syndromeOut_16   (polymulSyndrome_16),
      .syndromeOut_17   (polymulSyndrome_17),
      .syndromeOut_18   (polymulSyndrome_18),
      .syndromeOut_19   (polymulSyndrome_19),
      .syndromeOut_20   (polymulSyndrome_20),
      .syndromeOut_21   (polymulSyndrome_21),
      .done             (donePolymul)
   );



   //------------------------------------------------------------------
   // + lambda_0,..., lambda_21
   // + omega_0,..., omega_21
   // + numShifted, doneEuclide
   //- RS EUCLIDE
   //------------------------------------------------------------------
   wire [7:0]   lambda_0;
   wire [7:0]   lambda_1;
   wire [7:0]   lambda_2;
   wire [7:0]   lambda_3;
   wire [7:0]   lambda_4;
   wire [7:0]   lambda_5;
   wire [7:0]   lambda_6;
   wire [7:0]   lambda_7;
   wire [7:0]   lambda_8;
   wire [7:0]   lambda_9;
   wire [7:0]   lambda_10;
   wire [7:0]   lambda_11;
   wire [7:0]   lambda_12;
   wire [7:0]   lambda_13;
   wire [7:0]   lambda_14;
   wire [7:0]   lambda_15;
   wire [7:0]   lambda_16;
   wire [7:0]   lambda_17;
   wire [7:0]   lambda_18;
   wire [7:0]   lambda_19;
   wire [7:0]   lambda_20;
   wire [7:0]   lambda_21;
   wire [7:0]   omega_0;
   wire [7:0]   omega_1;
   wire [7:0]   omega_2;
   wire [7:0]   omega_3;
   wire [7:0]   omega_4;
   wire [7:0]   omega_5;
   wire [7:0]   omega_6;
   wire [7:0]   omega_7;
   wire [7:0]   omega_8;
   wire [7:0]   omega_9;
   wire [7:0]   omega_10;
   wire [7:0]   omega_11;
   wire [7:0]   omega_12;
   wire [7:0]   omega_13;
   wire [7:0]   omega_14;
   wire [7:0]   omega_15;
   wire [7:0]   omega_16;
   wire [7:0]   omega_17;
   wire [7:0]   omega_18;
   wire [7:0]   omega_19;
   wire [7:0]   omega_20;
   wire [7:0]   omega_21;
   wire         doneEuclide;
   wire [4:0]   numShifted;
   reg  [4:0]   degreeEpsilonReg;


   RsDecodeEuclide  RsDecodeEuclide(
      // Inputs
      .CLK           (CLK),
      .RESET         (RESET),
      .enable        (enable),
      .sync          (donePolymul),
      .syndrome_0    (polymulSyndrome_0),
      .syndrome_1    (polymulSyndrome_1),
      .syndrome_2    (polymulSyndrome_2),
      .syndrome_3    (polymulSyndrome_3),
      .syndrome_4    (polymulSyndrome_4),
      .syndrome_5    (polymulSyndrome_5),
      .syndrome_6    (polymulSyndrome_6),
      .syndrome_7    (polymulSyndrome_7),
      .syndrome_8    (polymulSyndrome_8),
      .syndrome_9    (polymulSyndrome_9),
      .syndrome_10   (polymulSyndrome_10),
      .syndrome_11   (polymulSyndrome_11),
      .syndrome_12   (polymulSyndrome_12),
      .syndrome_13   (polymulSyndrome_13),
      .syndrome_14   (polymulSyndrome_14),
      .syndrome_15   (polymulSyndrome_15),
      .syndrome_16   (polymulSyndrome_16),
      .syndrome_17   (polymulSyndrome_17),
      .syndrome_18   (polymulSyndrome_18),
      .syndrome_19   (polymulSyndrome_19),
      .syndrome_20   (polymulSyndrome_20),
      .syndrome_21   (polymulSyndrome_21),
      .numErasure    (degreeEpsilonReg),
      // Outputs
      .lambda_0      (lambda_0),
      .lambda_1      (lambda_1),
      .lambda_2      (lambda_2),
      .lambda_3      (lambda_3),
      .lambda_4      (lambda_4),
      .lambda_5      (lambda_5),
      .lambda_6      (lambda_6),
      .lambda_7      (lambda_7),
      .lambda_8      (lambda_8),
      .lambda_9      (lambda_9),
      .lambda_10     (lambda_10),
      .lambda_11     (lambda_11),
      .lambda_12     (lambda_12),
      .lambda_13     (lambda_13),
      .lambda_14     (lambda_14),
      .lambda_15     (lambda_15),
      .lambda_16     (lambda_16),
      .lambda_17     (lambda_17),
      .lambda_18     (lambda_18),
      .lambda_19     (lambda_19),
      .lambda_20     (lambda_20),
      .lambda_21     (lambda_21),
      .omega_0       (omega_0),
      .omega_1       (omega_1),
      .omega_2       (omega_2),
      .omega_3       (omega_3),
      .omega_4       (omega_4),
      .omega_5       (omega_5),
      .omega_6       (omega_6),
      .omega_7       (omega_7),
      .omega_8       (omega_8),
      .omega_9       (omega_9),
      .omega_10      (omega_10),
      .omega_11      (omega_11),
      .omega_12      (omega_12),
      .omega_13      (omega_13),
      .omega_14      (omega_14),
      .omega_15      (omega_15),
      .omega_16      (omega_16),
      .omega_17      (omega_17),
      .omega_18      (omega_18),
      .omega_19      (omega_19),
      .omega_20      (omega_20),
      .omega_21      (omega_21),
      .numShifted    (numShifted),
      .done          (doneEuclide)
   );



   //------------------------------------------------------------------
   // + epsilonReg_0, ..., epsilonReg_22
   //-
   //------------------------------------------------------------------
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
      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin
         epsilonReg_0 [7:0]  <= epsilon_0 [7:0];
         epsilonReg_1 [7:0]  <= epsilon_1 [7:0];
         epsilonReg_2 [7:0]  <= epsilon_2 [7:0];
         epsilonReg_3 [7:0]  <= epsilon_3 [7:0];
         epsilonReg_4 [7:0]  <= epsilon_4 [7:0];
         epsilonReg_5 [7:0]  <= epsilon_5 [7:0];
         epsilonReg_6 [7:0]  <= epsilon_6 [7:0];
         epsilonReg_7 [7:0]  <= epsilon_7 [7:0];
         epsilonReg_8 [7:0]  <= epsilon_8 [7:0];
         epsilonReg_9 [7:0]  <= epsilon_9 [7:0];
         epsilonReg_10 [7:0] <= epsilon_10 [7:0];
         epsilonReg_11 [7:0] <= epsilon_11 [7:0];
         epsilonReg_12 [7:0] <= epsilon_12 [7:0];
         epsilonReg_13 [7:0] <= epsilon_13 [7:0];
         epsilonReg_14 [7:0] <= epsilon_14 [7:0];
         epsilonReg_15 [7:0] <= epsilon_15 [7:0];
         epsilonReg_16 [7:0] <= epsilon_16 [7:0];
         epsilonReg_17 [7:0] <= epsilon_17 [7:0];
         epsilonReg_18 [7:0] <= epsilon_18 [7:0];
         epsilonReg_19 [7:0] <= epsilon_19 [7:0];
         epsilonReg_20 [7:0] <= epsilon_20 [7:0];
         epsilonReg_21 [7:0] <= epsilon_21 [7:0];
         epsilonReg_22 [7:0] <= epsilon_22 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + epsilonReg2_0,..., epsilonReg2_22
   //-
   //------------------------------------------------------------------
   reg [7:0]   epsilonReg2_0;
   reg [7:0]   epsilonReg2_1;
   reg [7:0]   epsilonReg2_2;
   reg [7:0]   epsilonReg2_3;
   reg [7:0]   epsilonReg2_4;
   reg [7:0]   epsilonReg2_5;
   reg [7:0]   epsilonReg2_6;
   reg [7:0]   epsilonReg2_7;
   reg [7:0]   epsilonReg2_8;
   reg [7:0]   epsilonReg2_9;
   reg [7:0]   epsilonReg2_10;
   reg [7:0]   epsilonReg2_11;
   reg [7:0]   epsilonReg2_12;
   reg [7:0]   epsilonReg2_13;
   reg [7:0]   epsilonReg2_14;
   reg [7:0]   epsilonReg2_15;
   reg [7:0]   epsilonReg2_16;
   reg [7:0]   epsilonReg2_17;
   reg [7:0]   epsilonReg2_18;
   reg [7:0]   epsilonReg2_19;
   reg [7:0]   epsilonReg2_20;
   reg [7:0]   epsilonReg2_21;
   reg [7:0]   epsilonReg2_22;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         epsilonReg2_0 [7:0]  <= 8'd0;
         epsilonReg2_1 [7:0]  <= 8'd0;
         epsilonReg2_2 [7:0]  <= 8'd0;
         epsilonReg2_3 [7:0]  <= 8'd0;
         epsilonReg2_4 [7:0]  <= 8'd0;
         epsilonReg2_5 [7:0]  <= 8'd0;
         epsilonReg2_6 [7:0]  <= 8'd0;
         epsilonReg2_7 [7:0]  <= 8'd0;
         epsilonReg2_8 [7:0]  <= 8'd0;
         epsilonReg2_9 [7:0]  <= 8'd0;
         epsilonReg2_10 [7:0] <= 8'd0;
         epsilonReg2_11 [7:0] <= 8'd0;
         epsilonReg2_12 [7:0] <= 8'd0;
         epsilonReg2_13 [7:0] <= 8'd0;
         epsilonReg2_14 [7:0] <= 8'd0;
         epsilonReg2_15 [7:0] <= 8'd0;
         epsilonReg2_16 [7:0] <= 8'd0;
         epsilonReg2_17 [7:0] <= 8'd0;
         epsilonReg2_18 [7:0] <= 8'd0;
         epsilonReg2_19 [7:0] <= 8'd0;
         epsilonReg2_20 [7:0] <= 8'd0;
         epsilonReg2_21 [7:0] <= 8'd0;
         epsilonReg2_22 [7:0] <= 8'd0;
      end
      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin
         epsilonReg2_0 [7:0]  <= epsilonReg_0 [7:0];
         epsilonReg2_1 [7:0]  <= epsilonReg_1 [7:0];
         epsilonReg2_2 [7:0]  <= epsilonReg_2 [7:0];
         epsilonReg2_3 [7:0]  <= epsilonReg_3 [7:0];
         epsilonReg2_4 [7:0]  <= epsilonReg_4 [7:0];
         epsilonReg2_5 [7:0]  <= epsilonReg_5 [7:0];
         epsilonReg2_6 [7:0]  <= epsilonReg_6 [7:0];
         epsilonReg2_7 [7:0]  <= epsilonReg_7 [7:0];
         epsilonReg2_8 [7:0]  <= epsilonReg_8 [7:0];
         epsilonReg2_9 [7:0]  <= epsilonReg_9 [7:0];
         epsilonReg2_10 [7:0] <= epsilonReg_10 [7:0];
         epsilonReg2_11 [7:0] <= epsilonReg_11 [7:0];
         epsilonReg2_12 [7:0] <= epsilonReg_12 [7:0];
         epsilonReg2_13 [7:0] <= epsilonReg_13 [7:0];
         epsilonReg2_14 [7:0] <= epsilonReg_14 [7:0];
         epsilonReg2_15 [7:0] <= epsilonReg_15 [7:0];
         epsilonReg2_16 [7:0] <= epsilonReg_16 [7:0];
         epsilonReg2_17 [7:0] <= epsilonReg_17 [7:0];
         epsilonReg2_18 [7:0] <= epsilonReg_18 [7:0];
         epsilonReg2_19 [7:0] <= epsilonReg_19 [7:0];
         epsilonReg2_20 [7:0] <= epsilonReg_20 [7:0];
         epsilonReg2_21 [7:0] <= epsilonReg_21 [7:0];
         epsilonReg2_22 [7:0] <= epsilonReg_22 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + epsilonReg3_0, ..., epsilonReg3_22
   //-
   //------------------------------------------------------------------
   reg [7:0]   epsilonReg3_0;
   reg [7:0]   epsilonReg3_1;
   reg [7:0]   epsilonReg3_2;
   reg [7:0]   epsilonReg3_3;
   reg [7:0]   epsilonReg3_4;
   reg [7:0]   epsilonReg3_5;
   reg [7:0]   epsilonReg3_6;
   reg [7:0]   epsilonReg3_7;
   reg [7:0]   epsilonReg3_8;
   reg [7:0]   epsilonReg3_9;
   reg [7:0]   epsilonReg3_10;
   reg [7:0]   epsilonReg3_11;
   reg [7:0]   epsilonReg3_12;
   reg [7:0]   epsilonReg3_13;
   reg [7:0]   epsilonReg3_14;
   reg [7:0]   epsilonReg3_15;
   reg [7:0]   epsilonReg3_16;
   reg [7:0]   epsilonReg3_17;
   reg [7:0]   epsilonReg3_18;
   reg [7:0]   epsilonReg3_19;
   reg [7:0]   epsilonReg3_20;
   reg [7:0]   epsilonReg3_21;
   reg [7:0]   epsilonReg3_22;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         epsilonReg3_0 [7:0]  <= 8'd0;
         epsilonReg3_1 [7:0]  <= 8'd0;
         epsilonReg3_2 [7:0]  <= 8'd0;
         epsilonReg3_3 [7:0]  <= 8'd0;
         epsilonReg3_4 [7:0]  <= 8'd0;
         epsilonReg3_5 [7:0]  <= 8'd0;
         epsilonReg3_6 [7:0]  <= 8'd0;
         epsilonReg3_7 [7:0]  <= 8'd0;
         epsilonReg3_8 [7:0]  <= 8'd0;
         epsilonReg3_9 [7:0]  <= 8'd0;
         epsilonReg3_10 [7:0] <= 8'd0;
         epsilonReg3_11 [7:0] <= 8'd0;
         epsilonReg3_12 [7:0] <= 8'd0;
         epsilonReg3_13 [7:0] <= 8'd0;
         epsilonReg3_14 [7:0] <= 8'd0;
         epsilonReg3_15 [7:0] <= 8'd0;
         epsilonReg3_16 [7:0] <= 8'd0;
         epsilonReg3_17 [7:0] <= 8'd0;
         epsilonReg3_18 [7:0] <= 8'd0;
         epsilonReg3_19 [7:0] <= 8'd0;
         epsilonReg3_20 [7:0] <= 8'd0;
         epsilonReg3_21 [7:0] <= 8'd0;
         epsilonReg3_22 [7:0] <= 8'd0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         epsilonReg3_0 [7:0]  <= epsilonReg2_0 [7:0];
         epsilonReg3_1 [7:0]  <= epsilonReg2_1 [7:0];
         epsilonReg3_2 [7:0]  <= epsilonReg2_2 [7:0];
         epsilonReg3_3 [7:0]  <= epsilonReg2_3 [7:0];
         epsilonReg3_4 [7:0]  <= epsilonReg2_4 [7:0];
         epsilonReg3_5 [7:0]  <= epsilonReg2_5 [7:0];
         epsilonReg3_6 [7:0]  <= epsilonReg2_6 [7:0];
         epsilonReg3_7 [7:0]  <= epsilonReg2_7 [7:0];
         epsilonReg3_8 [7:0]  <= epsilonReg2_8 [7:0];
         epsilonReg3_9 [7:0]  <= epsilonReg2_9 [7:0];
         epsilonReg3_10 [7:0] <= epsilonReg2_10 [7:0];
         epsilonReg3_11 [7:0] <= epsilonReg2_11 [7:0];
         epsilonReg3_12 [7:0] <= epsilonReg2_12 [7:0];
         epsilonReg3_13 [7:0] <= epsilonReg2_13 [7:0];
         epsilonReg3_14 [7:0] <= epsilonReg2_14 [7:0];
         epsilonReg3_15 [7:0] <= epsilonReg2_15 [7:0];
         epsilonReg3_16 [7:0] <= epsilonReg2_16 [7:0];
         epsilonReg3_17 [7:0] <= epsilonReg2_17 [7:0];
         epsilonReg3_18 [7:0] <= epsilonReg2_18 [7:0];
         epsilonReg3_19 [7:0] <= epsilonReg2_19 [7:0];
         epsilonReg3_20 [7:0] <= epsilonReg2_20 [7:0];
         epsilonReg3_21 [7:0] <= epsilonReg2_21 [7:0];
         epsilonReg3_22 [7:0] <= epsilonReg2_22 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + degreeEpsilonReg
   //-
   //------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeEpsilonReg   [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin
         degreeEpsilonReg   <= degreeEpsilon;
      end
   end



   //------------------------------------------------------------------
   // + degreeEpsilonReg2
   //-
   //------------------------------------------------------------------
   reg    [4:0]   degreeEpsilonReg2;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeEpsilonReg2   [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin
         degreeEpsilonReg2   <= degreeEpsilonReg;
      end
   end



   //------------------------------------------------------------------
   // + degreeEpsilonReg3
   //-
   //------------------------------------------------------------------
   reg    [4:0]   degreeEpsilonReg3;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeEpsilonReg3   [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         degreeEpsilonReg3   <= degreeEpsilonReg2;
      end
   end



   reg          doneShiftReg;
   //------------------------------------------------------------------
   // + degreeEpsilonReg4
   //-
   //------------------------------------------------------------------
   reg    [4:0]   degreeEpsilonReg4;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeEpsilonReg4   [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin
         degreeEpsilonReg4   <= degreeEpsilonReg3;
      end
   end



   wire         doneChien;
   //------------------------------------------------------------------
   // + degreeEpsilonReg5
   //-
   //------------------------------------------------------------------
   reg    [4:0]   degreeEpsilonReg5;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeEpsilonReg5 [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneChien == 1'b1)) begin
         degreeEpsilonReg5   <= degreeEpsilonReg4;
      end
   end



   reg [2:0]   doneReg;
   //------------------------------------------------------------------
   // + numErasureReg
   //-
   //------------------------------------------------------------------
   reg [4:0]   numErasureReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         numErasureReg   <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin
         numErasureReg   <= degreeEpsilonReg5;
      end
   end



   //------------------------------------------------------------------------
   // + doneShift
   //------------------------------------------------------------------------
   reg          doneShift;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         doneShift <= 1'b0;
      end
      else if (enable == 1'b1) begin
         doneShift <= doneEuclide;
      end
   end



   //------------------------------------------------------------------
   // + numShiftedReg
   //------------------------------------------------------------------
   reg [4:0]   numShiftedReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         numShiftedReg <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         numShiftedReg <= numShifted;
      end
   end



   //------------------------------------------------------------------
   // + lambdaReg_0,..., lambdaReg_21
   //------------------------------------------------------------------
   reg [7:0]   lambdaReg_0;
   reg [7:0]   lambdaReg_1;
   reg [7:0]   lambdaReg_2;
   reg [7:0]   lambdaReg_3;
   reg [7:0]   lambdaReg_4;
   reg [7:0]   lambdaReg_5;
   reg [7:0]   lambdaReg_6;
   reg [7:0]   lambdaReg_7;
   reg [7:0]   lambdaReg_8;
   reg [7:0]   lambdaReg_9;
   reg [7:0]   lambdaReg_10;
   reg [7:0]   lambdaReg_11;
   reg [7:0]   lambdaReg_12;
   reg [7:0]   lambdaReg_13;
   reg [7:0]   lambdaReg_14;
   reg [7:0]   lambdaReg_15;
   reg [7:0]   lambdaReg_16;
   reg [7:0]   lambdaReg_17;
   reg [7:0]   lambdaReg_18;
   reg [7:0]   lambdaReg_19;
   reg [7:0]   lambdaReg_20;
   reg [7:0]   lambdaReg_21;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         lambdaReg_0 [7:0]  <= 8'd0;
         lambdaReg_1 [7:0]  <= 8'd0;
         lambdaReg_2 [7:0]  <= 8'd0;
         lambdaReg_3 [7:0]  <= 8'd0;
         lambdaReg_4 [7:0]  <= 8'd0;
         lambdaReg_5 [7:0]  <= 8'd0;
         lambdaReg_6 [7:0]  <= 8'd0;
         lambdaReg_7 [7:0]  <= 8'd0;
         lambdaReg_8 [7:0]  <= 8'd0;
         lambdaReg_9 [7:0]  <= 8'd0;
         lambdaReg_10 [7:0] <= 8'd0;
         lambdaReg_11 [7:0] <= 8'd0;
         lambdaReg_12 [7:0] <= 8'd0;
         lambdaReg_13 [7:0] <= 8'd0;
         lambdaReg_14 [7:0] <= 8'd0;
         lambdaReg_15 [7:0] <= 8'd0;
         lambdaReg_16 [7:0] <= 8'd0;
         lambdaReg_17 [7:0] <= 8'd0;
         lambdaReg_18 [7:0] <= 8'd0;
         lambdaReg_19 [7:0] <= 8'd0;
         lambdaReg_20 [7:0] <= 8'd0;
         lambdaReg_21 [7:0] <= 8'd0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         lambdaReg_0 [7:0]  <= lambda_0 [7:0];
         lambdaReg_1 [7:0]  <= lambda_1 [7:0];
         lambdaReg_2 [7:0]  <= lambda_2 [7:0];
         lambdaReg_3 [7:0]  <= lambda_3 [7:0];
         lambdaReg_4 [7:0]  <= lambda_4 [7:0];
         lambdaReg_5 [7:0]  <= lambda_5 [7:0];
         lambdaReg_6 [7:0]  <= lambda_6 [7:0];
         lambdaReg_7 [7:0]  <= lambda_7 [7:0];
         lambdaReg_8 [7:0]  <= lambda_8 [7:0];
         lambdaReg_9 [7:0]  <= lambda_9 [7:0];
         lambdaReg_10 [7:0] <= lambda_10 [7:0];
         lambdaReg_11 [7:0] <= lambda_11 [7:0];
         lambdaReg_12 [7:0] <= lambda_12 [7:0];
         lambdaReg_13 [7:0] <= lambda_13 [7:0];
         lambdaReg_14 [7:0] <= lambda_14 [7:0];
         lambdaReg_15 [7:0] <= lambda_15 [7:0];
         lambdaReg_16 [7:0] <= lambda_16 [7:0];
         lambdaReg_17 [7:0] <= lambda_17 [7:0];
         lambdaReg_18 [7:0] <= lambda_18 [7:0];
         lambdaReg_19 [7:0] <= lambda_19 [7:0];
         lambdaReg_20 [7:0] <= lambda_20 [7:0];
         lambdaReg_21 [7:0] <= lambda_21 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + omegaReg_0,..., omegaReg_21
   //------------------------------------------------------------------
   reg [7:0]   omegaReg_0;
   reg [7:0]   omegaReg_1;
   reg [7:0]   omegaReg_2;
   reg [7:0]   omegaReg_3;
   reg [7:0]   omegaReg_4;
   reg [7:0]   omegaReg_5;
   reg [7:0]   omegaReg_6;
   reg [7:0]   omegaReg_7;
   reg [7:0]   omegaReg_8;
   reg [7:0]   omegaReg_9;
   reg [7:0]   omegaReg_10;
   reg [7:0]   omegaReg_11;
   reg [7:0]   omegaReg_12;
   reg [7:0]   omegaReg_13;
   reg [7:0]   omegaReg_14;
   reg [7:0]   omegaReg_15;
   reg [7:0]   omegaReg_16;
   reg [7:0]   omegaReg_17;
   reg [7:0]   omegaReg_18;
   reg [7:0]   omegaReg_19;
   reg [7:0]   omegaReg_20;
   reg [7:0]   omegaReg_21;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         omegaReg_0 [7:0]  <= 8'd0;
         omegaReg_1 [7:0]  <= 8'd0;
         omegaReg_2 [7:0]  <= 8'd0;
         omegaReg_3 [7:0]  <= 8'd0;
         omegaReg_4 [7:0]  <= 8'd0;
         omegaReg_5 [7:0]  <= 8'd0;
         omegaReg_6 [7:0]  <= 8'd0;
         omegaReg_7 [7:0]  <= 8'd0;
         omegaReg_8 [7:0]  <= 8'd0;
         omegaReg_9 [7:0]  <= 8'd0;
         omegaReg_10 [7:0] <= 8'd0;
         omegaReg_11 [7:0] <= 8'd0;
         omegaReg_12 [7:0] <= 8'd0;
         omegaReg_13 [7:0] <= 8'd0;
         omegaReg_14 [7:0] <= 8'd0;
         omegaReg_15 [7:0] <= 8'd0;
         omegaReg_16 [7:0] <= 8'd0;
         omegaReg_17 [7:0] <= 8'd0;
         omegaReg_18 [7:0] <= 8'd0;
         omegaReg_19 [7:0] <= 8'd0;
         omegaReg_20 [7:0] <= 8'd0;
         omegaReg_21 [7:0] <= 8'd0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         omegaReg_0 [7:0]  <= omega_0 [7:0];
         omegaReg_1 [7:0]  <= omega_1 [7:0];
         omegaReg_2 [7:0]  <= omega_2 [7:0];
         omegaReg_3 [7:0]  <= omega_3 [7:0];
         omegaReg_4 [7:0]  <= omega_4 [7:0];
         omegaReg_5 [7:0]  <= omega_5 [7:0];
         omegaReg_6 [7:0]  <= omega_6 [7:0];
         omegaReg_7 [7:0]  <= omega_7 [7:0];
         omegaReg_8 [7:0]  <= omega_8 [7:0];
         omegaReg_9 [7:0]  <= omega_9 [7:0];
         omegaReg_10 [7:0] <= omega_10 [7:0];
         omegaReg_11 [7:0] <= omega_11 [7:0];
         omegaReg_12 [7:0] <= omega_12 [7:0];
         omegaReg_13 [7:0] <= omega_13 [7:0];
         omegaReg_14 [7:0] <= omega_14 [7:0];
         omegaReg_15 [7:0] <= omega_15 [7:0];
         omegaReg_16 [7:0] <= omega_16 [7:0];
         omegaReg_17 [7:0] <= omega_17 [7:0];
         omegaReg_18 [7:0] <= omega_18 [7:0];
         omegaReg_19 [7:0] <= omega_19 [7:0];
         omegaReg_20 [7:0] <= omega_20 [7:0];
         omegaReg_21 [7:0] <= omega_21 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + omegaShifted_0, ..., omegaShifted_21
   //- Rs Shift Omega
   //------------------------------------------------------------------
    wire [7:0]   omegaShifted_0;
    wire [7:0]   omegaShifted_1;
    wire [7:0]   omegaShifted_2;
    wire [7:0]   omegaShifted_3;
    wire [7:0]   omegaShifted_4;
    wire [7:0]   omegaShifted_5;
    wire [7:0]   omegaShifted_6;
    wire [7:0]   omegaShifted_7;
    wire [7:0]   omegaShifted_8;
    wire [7:0]   omegaShifted_9;
    wire [7:0]   omegaShifted_10;
    wire [7:0]   omegaShifted_11;
    wire [7:0]   omegaShifted_12;
    wire [7:0]   omegaShifted_13;
    wire [7:0]   omegaShifted_14;
    wire [7:0]   omegaShifted_15;
    wire [7:0]   omegaShifted_16;
    wire [7:0]   omegaShifted_17;
    wire [7:0]   omegaShifted_18;
    wire [7:0]   omegaShifted_19;
    wire [7:0]   omegaShifted_20;
    wire [7:0]   omegaShifted_21;


   RsDecodeShiftOmega RsDecodeShiftOmega(
      // Inputs
      .omega_0           (omegaReg_0),
      .omega_1           (omegaReg_1),
      .omega_2           (omegaReg_2),
      .omega_3           (omegaReg_3),
      .omega_4           (omegaReg_4),
      .omega_5           (omegaReg_5),
      .omega_6           (omegaReg_6),
      .omega_7           (omegaReg_7),
      .omega_8           (omegaReg_8),
      .omega_9           (omegaReg_9),
      .omega_10          (omegaReg_10),
      .omega_11          (omegaReg_11),
      .omega_12          (omegaReg_12),
      .omega_13          (omegaReg_13),
      .omega_14          (omegaReg_14),
      .omega_15          (omegaReg_15),
      .omega_16          (omegaReg_16),
      .omega_17          (omegaReg_17),
      .omega_18          (omegaReg_18),
      .omega_19          (omegaReg_19),
      .omega_20          (omegaReg_20),
      .omega_21          (omegaReg_21),
      // Outputs
      .omegaShifted_0    (omegaShifted_0),
      .omegaShifted_1    (omegaShifted_1),
      .omegaShifted_2    (omegaShifted_2),
      .omegaShifted_3    (omegaShifted_3),
      .omegaShifted_4    (omegaShifted_4),
      .omegaShifted_5    (omegaShifted_5),
      .omegaShifted_6    (omegaShifted_6),
      .omegaShifted_7    (omegaShifted_7),
      .omegaShifted_8    (omegaShifted_8),
      .omegaShifted_9    (omegaShifted_9),
      .omegaShifted_10   (omegaShifted_10),
      .omegaShifted_11   (omegaShifted_11),
      .omegaShifted_12   (omegaShifted_12),
      .omegaShifted_13   (omegaShifted_13),
      .omegaShifted_14   (omegaShifted_14),
      .omegaShifted_15   (omegaShifted_15),
      .omegaShifted_16   (omegaShifted_16),
      .omegaShifted_17   (omegaShifted_17),
      .omegaShifted_18   (omegaShifted_18),
      .omegaShifted_19   (omegaShifted_19),
      .omegaShifted_20   (omegaShifted_20),
      .omegaShifted_21   (omegaShifted_21),
      // Inputs
      .numShifted        (numShiftedReg)
   );



   //------------------------------------------------------------------
   // + omegaShiftedReg_0,.., omegaShiftedReg_21
   //------------------------------------------------------------------
    reg [7:0]   omegaShiftedReg_0;
    reg [7:0]   omegaShiftedReg_1;
    reg [7:0]   omegaShiftedReg_2;
    reg [7:0]   omegaShiftedReg_3;
    reg [7:0]   omegaShiftedReg_4;
    reg [7:0]   omegaShiftedReg_5;
    reg [7:0]   omegaShiftedReg_6;
    reg [7:0]   omegaShiftedReg_7;
    reg [7:0]   omegaShiftedReg_8;
    reg [7:0]   omegaShiftedReg_9;
    reg [7:0]   omegaShiftedReg_10;
    reg [7:0]   omegaShiftedReg_11;
    reg [7:0]   omegaShiftedReg_12;
    reg [7:0]   omegaShiftedReg_13;
    reg [7:0]   omegaShiftedReg_14;
    reg [7:0]   omegaShiftedReg_15;
    reg [7:0]   omegaShiftedReg_16;
    reg [7:0]   omegaShiftedReg_17;
    reg [7:0]   omegaShiftedReg_18;
    reg [7:0]   omegaShiftedReg_19;
    reg [7:0]   omegaShiftedReg_20;
    reg [7:0]   omegaShiftedReg_21;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         omegaShiftedReg_0 [7:0]  <= 8'd0;
         omegaShiftedReg_1 [7:0]  <= 8'd0;
         omegaShiftedReg_2 [7:0]  <= 8'd0;
         omegaShiftedReg_3 [7:0]  <= 8'd0;
         omegaShiftedReg_4 [7:0]  <= 8'd0;
         omegaShiftedReg_5 [7:0]  <= 8'd0;
         omegaShiftedReg_6 [7:0]  <= 8'd0;
         omegaShiftedReg_7 [7:0]  <= 8'd0;
         omegaShiftedReg_8 [7:0]  <= 8'd0;
         omegaShiftedReg_9 [7:0]  <= 8'd0;
         omegaShiftedReg_10 [7:0] <= 8'd0;
         omegaShiftedReg_11 [7:0] <= 8'd0;
         omegaShiftedReg_12 [7:0] <= 8'd0;
         omegaShiftedReg_13 [7:0] <= 8'd0;
         omegaShiftedReg_14 [7:0] <= 8'd0;
         omegaShiftedReg_15 [7:0] <= 8'd0;
         omegaShiftedReg_16 [7:0] <= 8'd0;
         omegaShiftedReg_17 [7:0] <= 8'd0;
         omegaShiftedReg_18 [7:0] <= 8'd0;
         omegaShiftedReg_19 [7:0] <= 8'd0;
         omegaShiftedReg_20 [7:0] <= 8'd0;
         omegaShiftedReg_21 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         omegaShiftedReg_0 [7:0]  <= omegaShifted_0 [7:0];
         omegaShiftedReg_1 [7:0]  <= omegaShifted_1 [7:0];
         omegaShiftedReg_2 [7:0]  <= omegaShifted_2 [7:0];
         omegaShiftedReg_3 [7:0]  <= omegaShifted_3 [7:0];
         omegaShiftedReg_4 [7:0]  <= omegaShifted_4 [7:0];
         omegaShiftedReg_5 [7:0]  <= omegaShifted_5 [7:0];
         omegaShiftedReg_6 [7:0]  <= omegaShifted_6 [7:0];
         omegaShiftedReg_7 [7:0]  <= omegaShifted_7 [7:0];
         omegaShiftedReg_8 [7:0]  <= omegaShifted_8 [7:0];
         omegaShiftedReg_9 [7:0]  <= omegaShifted_9 [7:0];
         omegaShiftedReg_10 [7:0] <= omegaShifted_10 [7:0];
         omegaShiftedReg_11 [7:0] <= omegaShifted_11 [7:0];
         omegaShiftedReg_12 [7:0] <= omegaShifted_12 [7:0];
         omegaShiftedReg_13 [7:0] <= omegaShifted_13 [7:0];
         omegaShiftedReg_14 [7:0] <= omegaShifted_14 [7:0];
         omegaShiftedReg_15 [7:0] <= omegaShifted_15 [7:0];
         omegaShiftedReg_16 [7:0] <= omegaShifted_16 [7:0];
         omegaShiftedReg_17 [7:0] <= omegaShifted_17 [7:0];
         omegaShiftedReg_18 [7:0] <= omegaShifted_18 [7:0];
         omegaShiftedReg_19 [7:0] <= omegaShifted_19 [7:0];
         omegaShiftedReg_20 [7:0] <= omegaShifted_20 [7:0];
         omegaShiftedReg_21 [7:0] <= omegaShifted_21 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + degreeOmega
   //------------------------------------------------------------------
   wire   [4:0]   degreeOmega;


   RsDecodeDegree  RsDecodeDegree_1(
      // Inputs
      .polynom_0   (omegaShiftedReg_0),
      .polynom_1   (omegaShiftedReg_1),
      .polynom_2   (omegaShiftedReg_2),
      .polynom_3   (omegaShiftedReg_3),
      .polynom_4   (omegaShiftedReg_4),
      .polynom_5   (omegaShiftedReg_5),
      .polynom_6   (omegaShiftedReg_6),
      .polynom_7   (omegaShiftedReg_7),
      .polynom_8   (omegaShiftedReg_8),
      .polynom_9   (omegaShiftedReg_9),
      .polynom_10  (omegaShiftedReg_10),
      .polynom_11  (omegaShiftedReg_11),
      .polynom_12  (omegaShiftedReg_12),
      .polynom_13  (omegaShiftedReg_13),
      .polynom_14  (omegaShiftedReg_14),
      .polynom_15  (omegaShiftedReg_15),
      .polynom_16  (omegaShiftedReg_16),
      .polynom_17  (omegaShiftedReg_17),
      .polynom_18  (omegaShiftedReg_18),
      .polynom_19  (omegaShiftedReg_19),
      .polynom_20  (omegaShiftedReg_20),
      .polynom_21  (omegaShiftedReg_21),
      // Outputs
      .degree      (degreeOmega)
   );



   //------------------------------------------------------------------
   // + lambdaReg2_0,.., lambdaReg2_21
   //------------------------------------------------------------------
   reg [7:0]   lambdaReg2_0;
   reg [7:0]   lambdaReg2_1;
   reg [7:0]   lambdaReg2_2;
   reg [7:0]   lambdaReg2_3;
   reg [7:0]   lambdaReg2_4;
   reg [7:0]   lambdaReg2_5;
   reg [7:0]   lambdaReg2_6;
   reg [7:0]   lambdaReg2_7;
   reg [7:0]   lambdaReg2_8;
   reg [7:0]   lambdaReg2_9;
   reg [7:0]   lambdaReg2_10;
   reg [7:0]   lambdaReg2_11;
   reg [7:0]   lambdaReg2_12;
   reg [7:0]   lambdaReg2_13;
   reg [7:0]   lambdaReg2_14;
   reg [7:0]   lambdaReg2_15;
   reg [7:0]   lambdaReg2_16;
   reg [7:0]   lambdaReg2_17;
   reg [7:0]   lambdaReg2_18;
   reg [7:0]   lambdaReg2_19;
   reg [7:0]   lambdaReg2_20;
   reg [7:0]   lambdaReg2_21;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         lambdaReg2_0 [7:0]  <= 8'd0;
         lambdaReg2_1 [7:0]  <= 8'd0;
         lambdaReg2_2 [7:0]  <= 8'd0;
         lambdaReg2_3 [7:0]  <= 8'd0;
         lambdaReg2_4 [7:0]  <= 8'd0;
         lambdaReg2_5 [7:0]  <= 8'd0;
         lambdaReg2_6 [7:0]  <= 8'd0;
         lambdaReg2_7 [7:0]  <= 8'd0;
         lambdaReg2_8 [7:0]  <= 8'd0;
         lambdaReg2_9 [7:0]  <= 8'd0;
         lambdaReg2_10 [7:0] <= 8'd0;
         lambdaReg2_11 [7:0] <= 8'd0;
         lambdaReg2_12 [7:0] <= 8'd0;
         lambdaReg2_13 [7:0] <= 8'd0;
         lambdaReg2_14 [7:0] <= 8'd0;
         lambdaReg2_15 [7:0] <= 8'd0;
         lambdaReg2_16 [7:0] <= 8'd0;
         lambdaReg2_17 [7:0] <= 8'd0;
         lambdaReg2_18 [7:0] <= 8'd0;
         lambdaReg2_19 [7:0] <= 8'd0;
         lambdaReg2_20 [7:0] <= 8'd0;
         lambdaReg2_21 [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         lambdaReg2_0 [7:0]  <= lambdaReg_0 [7:0];
         lambdaReg2_1 [7:0]  <= lambdaReg_1 [7:0];
         lambdaReg2_2 [7:0]  <= lambdaReg_2 [7:0];
         lambdaReg2_3 [7:0]  <= lambdaReg_3 [7:0];
         lambdaReg2_4 [7:0]  <= lambdaReg_4 [7:0];
         lambdaReg2_5 [7:0]  <= lambdaReg_5 [7:0];
         lambdaReg2_6 [7:0]  <= lambdaReg_6 [7:0];
         lambdaReg2_7 [7:0]  <= lambdaReg_7 [7:0];
         lambdaReg2_8 [7:0]  <= lambdaReg_8 [7:0];
         lambdaReg2_9 [7:0]  <= lambdaReg_9 [7:0];
         lambdaReg2_10 [7:0] <= lambdaReg_10 [7:0];
         lambdaReg2_11 [7:0] <= lambdaReg_11 [7:0];
         lambdaReg2_12 [7:0] <= lambdaReg_12 [7:0];
         lambdaReg2_13 [7:0] <= lambdaReg_13 [7:0];
         lambdaReg2_14 [7:0] <= lambdaReg_14 [7:0];
         lambdaReg2_15 [7:0] <= lambdaReg_15 [7:0];
         lambdaReg2_16 [7:0] <= lambdaReg_16 [7:0];
         lambdaReg2_17 [7:0] <= lambdaReg_17 [7:0];
         lambdaReg2_18 [7:0] <= lambdaReg_18 [7:0];
         lambdaReg2_19 [7:0] <= lambdaReg_19 [7:0];
         lambdaReg2_20 [7:0] <= lambdaReg_20 [7:0];
         lambdaReg2_21 [7:0] <= lambdaReg_21 [7:0];
      end
   end



   //------------------------------------------------------------------
   // + degreeLambda
   //------------------------------------------------------------------
   wire [4:0]   degreeLambda;
   RsDecodeDegree  RsDecodeDegree_2(
      // Inputs
      .polynom_0   (lambdaReg2_0),
      .polynom_1   (lambdaReg2_1),
      .polynom_2   (lambdaReg2_2),
      .polynom_3   (lambdaReg2_3),
      .polynom_4   (lambdaReg2_4),
      .polynom_5   (lambdaReg2_5),
      .polynom_6   (lambdaReg2_6),
      .polynom_7   (lambdaReg2_7),
      .polynom_8   (lambdaReg2_8),
      .polynom_9   (lambdaReg2_9),
      .polynom_10  (lambdaReg2_10),
      .polynom_11  (lambdaReg2_11),
      .polynom_12  (lambdaReg2_12),
      .polynom_13  (lambdaReg2_13),
      .polynom_14  (lambdaReg2_14),
      .polynom_15  (lambdaReg2_15),
      .polynom_16  (lambdaReg2_16),
      .polynom_17  (lambdaReg2_17),
      .polynom_18  (lambdaReg2_18),
      .polynom_19  (lambdaReg2_19),
      .polynom_20  (lambdaReg2_20),
      .polynom_21  (lambdaReg2_21),
      // Outputs
      .degree      (degreeLambda)
   );



   //------------------------------------------------------------------
   // + degreeOmegaReg
   // + degreeLambdaReg
   //------------------------------------------------------------------
   reg [4:0]   degreeOmegaReg;
   reg [4:0]   degreeLambdaReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeOmegaReg  <= 5'd0;
         degreeLambdaReg <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin
         degreeOmegaReg  <= degreeOmega;
         degreeLambdaReg <= degreeLambda;
      end
   end



   //------------------------------------------------------------------
   // + doneShiftReg
   //------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         doneShiftReg <= 1'b0;
      end 
      else if (enable == 1'b1) begin
         doneShiftReg <= doneShift;
      end
   end



   //------------------------------------------------------------------
   // + 
   //- RS Chien Search Algorithm
   //------------------------------------------------------------------
   wire [4:0]   numErrorChien;
   wire [7:0]   error;
   wire         delayedErasureIn;


   RsDecodeChien RsDecodeChien(
      // Inputs
      .CLK            (CLK),
      .RESET          (RESET),
      .enable         (enable),
      .sync           (doneShiftReg),
      .erasureIn      (delayedErasureIn),
      .lambdaIn_0     (lambdaReg2_0),
      .lambdaIn_1     (lambdaReg2_1),
      .lambdaIn_2     (lambdaReg2_2),
      .lambdaIn_3     (lambdaReg2_3),
      .lambdaIn_4     (lambdaReg2_4),
      .lambdaIn_5     (lambdaReg2_5),
      .lambdaIn_6     (lambdaReg2_6),
      .lambdaIn_7     (lambdaReg2_7),
      .lambdaIn_8     (lambdaReg2_8),
      .lambdaIn_9     (lambdaReg2_9),
      .lambdaIn_10    (lambdaReg2_10),
      .lambdaIn_11    (lambdaReg2_11),
      .lambdaIn_12    (lambdaReg2_12),
      .lambdaIn_13    (lambdaReg2_13),
      .lambdaIn_14    (lambdaReg2_14),
      .lambdaIn_15    (lambdaReg2_15),
      .lambdaIn_16    (lambdaReg2_16),
      .lambdaIn_17    (lambdaReg2_17),
      .lambdaIn_18    (lambdaReg2_18),
      .lambdaIn_19    (lambdaReg2_19),
      .lambdaIn_20    (lambdaReg2_20),
      .lambdaIn_21    (lambdaReg2_21),
      .omegaIn_0      (omegaShiftedReg_0),
      .omegaIn_1      (omegaShiftedReg_1),
      .omegaIn_2      (omegaShiftedReg_2),
      .omegaIn_3      (omegaShiftedReg_3),
      .omegaIn_4      (omegaShiftedReg_4),
      .omegaIn_5      (omegaShiftedReg_5),
      .omegaIn_6      (omegaShiftedReg_6),
      .omegaIn_7      (omegaShiftedReg_7),
      .omegaIn_8      (omegaShiftedReg_8),
      .omegaIn_9      (omegaShiftedReg_9),
      .omegaIn_10     (omegaShiftedReg_10),
      .omegaIn_11     (omegaShiftedReg_11),
      .omegaIn_12     (omegaShiftedReg_12),
      .omegaIn_13     (omegaShiftedReg_13),
      .omegaIn_14     (omegaShiftedReg_14),
      .omegaIn_15     (omegaShiftedReg_15),
      .omegaIn_16     (omegaShiftedReg_16),
      .omegaIn_17     (omegaShiftedReg_17),
      .omegaIn_18     (omegaShiftedReg_18),
      .omegaIn_19     (omegaShiftedReg_19),
      .omegaIn_20     (omegaShiftedReg_20),
      .omegaIn_21     (omegaShiftedReg_21),
      .epsilonIn_0    (epsilonReg3_0),
      .epsilonIn_1    (epsilonReg3_1),
      .epsilonIn_2    (epsilonReg3_2),
      .epsilonIn_3    (epsilonReg3_3),
      .epsilonIn_4    (epsilonReg3_4),
      .epsilonIn_5    (epsilonReg3_5),
      .epsilonIn_6    (epsilonReg3_6),
      .epsilonIn_7    (epsilonReg3_7),
      .epsilonIn_8    (epsilonReg3_8),
      .epsilonIn_9    (epsilonReg3_9),
      .epsilonIn_10   (epsilonReg3_10),
      .epsilonIn_11   (epsilonReg3_11),
      .epsilonIn_12   (epsilonReg3_12),
      .epsilonIn_13   (epsilonReg3_13),
      .epsilonIn_14   (epsilonReg3_14),
      .epsilonIn_15   (epsilonReg3_15),
      .epsilonIn_16   (epsilonReg3_16),
      .epsilonIn_17   (epsilonReg3_17),
      .epsilonIn_18   (epsilonReg3_18),
      .epsilonIn_19   (epsilonReg3_19),
      .epsilonIn_20   (epsilonReg3_20),
      .epsilonIn_21   (epsilonReg3_21),
      .epsilonIn_22   (epsilonReg3_22),
      // Outputs
      .errorOut       (error),
      .numError       (numErrorChien),
      .done           (doneChien)
   );



   //------------------------------------------------------------------
   // + delayOut
   //- Rs Decode Delay
   //------------------------------------------------------------------
   wire [8:0]   delayOut;
   wire [8:0]   delayIn;


   RsDecodeDelay  RsDecodeDelay(
      // Inputs
      .CLK      (CLK),
      .RESET    (RESET),
      .enable   (enable),
      .dataIn   (delayIn),
      // Outputs
      .dataOut  (delayOut)
   );



   //------------------------------------------------------------------
   // + delayIn, delayedErasureIn, delayedDataIn
   //------------------------------------------------------------------
   wire [7:0]   delayedDataIn;
   assign   delayIn          = {erasureIn, dataInCheck};
   assign   delayedErasureIn = delayOut[8];
   assign   delayedDataIn    = delayOut[7:0];



   //------------------------------------------------------------------------
   // + OutputValidReg
   //------------------------------------------------------------------------
   reg         OutputValidReg;
   reg [3:0]   startReg;

   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         OutputValidReg   <= 1'b0;
      end
      else if (enable == 1'b1) begin
         if (startReg[1] == 1'b1) begin
            OutputValidReg   <= 1'b1;
         end
         else if (doneReg[0] == 1'b1) begin
            OutputValidReg   <= 1'b0;
         end
      end
   end



   //------------------------------------------------------------------
   // + startReg, doneReg
   //------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         startReg   [3:0] <= 4'd0;
         doneReg   [2:0]  <= 3'd0;
      end
      else if (enable == 1'b1) begin
         startReg [3:0] <= {doneShiftReg, startReg[3:1]};
         doneReg  [2:0] <= {doneChien, doneReg[2:1]};
      end
   end



   //------------------------------------------------------------------
   // + numErrorLambdaReg
   //------------------------------------------------------------------
   reg [4:0]   numErrorLambdaReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         numErrorLambdaReg   [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (startReg[1] == 1'b1)) begin
         numErrorLambdaReg   <= degreeLambdaReg;
      end
   end



   //------------------------------------------------------------------
   // + degreeErrorReg
   //------------------------------------------------------------------
   reg         degreeErrorReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         degreeErrorReg   <= 1'b0;
      end
      else if ((enable == 1'b1) && (startReg[1] == 1'b1)) begin
         if (({1'b0, degreeOmegaReg}) <= ({1'b0, degreeLambdaReg}) + ({1'b0, degreeEpsilonReg4})) begin
            degreeErrorReg   <= 1'b0;
         end
         else begin
            degreeErrorReg   <= 1'b1;
         end
      end
   end



   //------------------------------------------------------------------
   // + numErrorReg
   //------------------------------------------------------------------
   reg    [4:0]   numErrorReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         numErrorReg [4:0] <= 5'd0;
      end
      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin
         numErrorReg [4:0] <= numErrorChien[4:0];
      end
   end



   //------------------------------------------------------------------
   // + failErasureReg
   //-
   //------------------------------------------------------------------
   reg failErasureReg;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failErasureReg   <= 1'b0;
      end
      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin
         failErasureReg   <= failErasure;
      end
   end



   //------------------------------------------------------------------
   // + failErasureReg2
   //-
   //------------------------------------------------------------------
   reg failErasureReg2;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failErasureReg2   <= 1'b0;
      end
      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin
         failErasureReg2   <= failErasureReg;
      end
   end



   //------------------------------------------------------------------
   // + failErasureReg3
   //-
   //------------------------------------------------------------------
   reg failErasureReg3;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failErasureReg3   <= 1'b0;
      end
      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin
         failErasureReg3   <= failErasureReg2;
      end
   end



   //------------------------------------------------------------------
   // + failErasureReg4
   //-
   //------------------------------------------------------------------
   reg failErasureReg4;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failErasureReg4   <= 1'b0;
      end
      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin
         failErasureReg4   <= failErasureReg3;
      end
   end



   //------------------------------------------------------------------
   // + failErasureReg5
   //-
   //------------------------------------------------------------------
   reg failErasureReg5;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failErasureReg5   <= 1'b0;
      end
      else if ((enable == 1'b1) && (startReg[1]  == 1'b1)) begin
         failErasureReg5   <= failErasureReg4;
      end
   end



   //------------------------------------------------------------------
   // + failReg
   //------------------------------------------------------------------
   reg          failReg;

   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         failReg <= 1'b0;
      end
      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin
         if ((numErrorLambdaReg == numErrorChien) && (degreeErrorReg == 1'b0) && (failErasureReg5 == 1'b0)) begin
            failReg <= 1'b0;
         end
         else begin
            failReg <= 1'b1;
         end
      end
   end



   //------------------------------------------------------------------
   // + DataOutInner
   //------------------------------------------------------------------
   reg [7:0]   DataOutInner;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         DataOutInner <= 8'd0;
      end
      else begin
         DataOutInner <= delayedDataIn ^ error;
      end
   end



   //------------------------------------------------------------------
   // + DelayedDataOutInner
   //------------------------------------------------------------------
   reg [7:0]   DelayedDataOutInner;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         DelayedDataOutInner <= 8'd0;
      end
      else begin
         DelayedDataOutInner <= delayedDataIn;
      end
   end



   //------------------------------------------------------------------
   // - enableFF 
   //------------------------------------------------------------------
   reg       enableFF;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         enableFF <= 1'b0;
      end
      else begin
         enableFF <= enable;
      end
   end



   //------------------------------------------------------------------
   // - FF for Outputs 
   //------------------------------------------------------------------
   reg         startRegInner;
   reg         doneRegInner;
   reg [7:0]   numErrorRegInner;
   reg [7:0]   numErasureRegInner;
   reg         failRegInner;


   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         startRegInner       <= 1'b0;
         doneRegInner        <= 1'b0;
         numErrorRegInner    <= 8'd0;
         numErasureRegInner  <= 8'd0;
         failRegInner        <= 1'b0;
      end
      else begin
         startRegInner       <= startReg[0];
         doneRegInner        <= doneReg[0];
         numErrorRegInner    <= { 3'd0, numErrorReg[4:0]};
         numErasureRegInner  <= { 3'd0, numErasureReg[4:0]};
         failRegInner        <= failReg;
      end
   end



   //------------------------------------------------------------------
   // - OutputValidRegInner 
   //------------------------------------------------------------------
   reg         OutputValidRegInner;

   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         OutputValidRegInner <= 1'b0;
      end
      else if (enableFF == 1'b1) begin
         OutputValidRegInner <= OutputValidReg;
      end
      else begin
         OutputValidRegInner <= 1'b0;
      end
   end



   //------------------------------------------------------------------
   // - Output Ports
   //------------------------------------------------------------------
   assign   outEnable   = OutputValidRegInner;
   assign   outStartPls = startRegInner;
   assign   outDone     = doneRegInner;
   assign   outData     = DataOutInner;
   assign   errorNum    = numErrorRegInner;
   assign   erasureNum  = numErasureRegInner;
   assign   delayedData = DelayedDataOutInner;
   assign   fail        = failRegInner;


endmodule
