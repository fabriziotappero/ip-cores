//===================================================================
// Module Name : RsDecodeShiftOmega
// File Name   : RsDecodeShiftOmega.v
// Function    : Rs Decoder Shift Omega Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeShiftOmega(
   omega_0,           // omega polynom 0
   omega_1,           // omega polynom 1
   omega_2,           // omega polynom 2
   omega_3,           // omega polynom 3
   omega_4,           // omega polynom 4
   omega_5,           // omega polynom 5
   omega_6,           // omega polynom 6
   omega_7,           // omega polynom 7
   omega_8,           // omega polynom 8
   omega_9,           // omega polynom 9
   omega_10,          // omega polynom 10
   omega_11,          // omega polynom 11
   omega_12,          // omega polynom 12
   omega_13,          // omega polynom 13
   omega_14,          // omega polynom 14
   omega_15,          // omega polynom 15
   omega_16,          // omega polynom 16
   omega_17,          // omega polynom 17
   omega_18,          // omega polynom 18
   omega_19,          // omega polynom 19
   omega_20,          // omega polynom 20
   omega_21,          // omega polynom 21
   omegaShifted_0,    // omega shifted polynom 0
   omegaShifted_1,    // omega shifted polynom 1
   omegaShifted_2,    // omega shifted polynom 2
   omegaShifted_3,    // omega shifted polynom 3
   omegaShifted_4,    // omega shifted polynom 4
   omegaShifted_5,    // omega shifted polynom 5
   omegaShifted_6,    // omega shifted polynom 6
   omegaShifted_7,    // omega shifted polynom 7
   omegaShifted_8,    // omega shifted polynom 8
   omegaShifted_9,    // omega shifted polynom 9
   omegaShifted_10,   // omega shifted polynom 10
   omegaShifted_11,   // omega shifted polynom 11
   omegaShifted_12,   // omega shifted polynom 12
   omegaShifted_13,   // omega shifted polynom 13
   omegaShifted_14,   // omega shifted polynom 14
   omegaShifted_15,   // omega shifted polynom 15
   omegaShifted_16,   // omega shifted polynom 16
   omegaShifted_17,   // omega shifted polynom 17
   omegaShifted_18,   // omega shifted polynom 18
   omegaShifted_19,   // omega shifted polynom 19
   omegaShifted_20,   // omega shifted polynom 20
   omegaShifted_21,   // omega shifted polynom 21
   numShifted         // shift amount
);


   input [7:0] omega_0;            // omega polynom 0
   input [7:0] omega_1;            // omega polynom 1
   input [7:0] omega_2;            // omega polynom 2
   input [7:0] omega_3;            // omega polynom 3
   input [7:0] omega_4;            // omega polynom 4
   input [7:0] omega_5;            // omega polynom 5
   input [7:0] omega_6;            // omega polynom 6
   input [7:0] omega_7;            // omega polynom 7
   input [7:0] omega_8;            // omega polynom 8
   input [7:0] omega_9;            // omega polynom 9
   input [7:0] omega_10;           // omega polynom 10
   input [7:0] omega_11;           // omega polynom 11
   input [7:0] omega_12;           // omega polynom 12
   input [7:0] omega_13;           // omega polynom 13
   input [7:0] omega_14;           // omega polynom 14
   input [7:0] omega_15;           // omega polynom 15
   input [7:0] omega_16;           // omega polynom 16
   input [7:0] omega_17;           // omega polynom 17
   input [7:0] omega_18;           // omega polynom 18
   input [7:0] omega_19;           // omega polynom 19
   input [7:0] omega_20;           // omega polynom 20
   input [7:0] omega_21;           // omega polynom 21
   input [4:0] numShifted;         // shift amount

   output [7:0] omegaShifted_0;    // omega shifted polynom 0
   output [7:0] omegaShifted_1;    // omega shifted polynom 1
   output [7:0] omegaShifted_2;    // omega shifted polynom 2
   output [7:0] omegaShifted_3;    // omega shifted polynom 3
   output [7:0] omegaShifted_4;    // omega shifted polynom 4
   output [7:0] omegaShifted_5;    // omega shifted polynom 5
   output [7:0] omegaShifted_6;    // omega shifted polynom 6
   output [7:0] omegaShifted_7;    // omega shifted polynom 7
   output [7:0] omegaShifted_8;    // omega shifted polynom 8
   output [7:0] omegaShifted_9;    // omega shifted polynom 9
   output [7:0] omegaShifted_10;   // omega shifted polynom 10
   output [7:0] omegaShifted_11;   // omega shifted polynom 11
   output [7:0] omegaShifted_12;   // omega shifted polynom 12
   output [7:0] omegaShifted_13;   // omega shifted polynom 13
   output [7:0] omegaShifted_14;   // omega shifted polynom 14
   output [7:0] omegaShifted_15;   // omega shifted polynom 15
   output [7:0] omegaShifted_16;   // omega shifted polynom 16
   output [7:0] omegaShifted_17;   // omega shifted polynom 17
   output [7:0] omegaShifted_18;   // omega shifted polynom 18
   output [7:0] omegaShifted_19;   // omega shifted polynom 19
   output [7:0] omegaShifted_20;   // omega shifted polynom 20
   output [7:0] omegaShifted_21;   // omega shifted polynom 21



   //------------------------------------------------------------------------
   //+ omegaShifted_0,..., omegaShifted_21
   //- omegaShifted registers
   //------------------------------------------------------------------------
   reg [7:0]   omegaShiftedInner_0;
   reg [7:0]   omegaShiftedInner_1;
   reg [7:0]   omegaShiftedInner_2;
   reg [7:0]   omegaShiftedInner_3;
   reg [7:0]   omegaShiftedInner_4;
   reg [7:0]   omegaShiftedInner_5;
   reg [7:0]   omegaShiftedInner_6;
   reg [7:0]   omegaShiftedInner_7;
   reg [7:0]   omegaShiftedInner_8;
   reg [7:0]   omegaShiftedInner_9;
   reg [7:0]   omegaShiftedInner_10;
   reg [7:0]   omegaShiftedInner_11;
   reg [7:0]   omegaShiftedInner_12;
   reg [7:0]   omegaShiftedInner_13;
   reg [7:0]   omegaShiftedInner_14;
   reg [7:0]   omegaShiftedInner_15;
   reg [7:0]   omegaShiftedInner_16;
   reg [7:0]   omegaShiftedInner_17;
   reg [7:0]   omegaShiftedInner_18;
   reg [7:0]   omegaShiftedInner_19;
   reg [7:0]   omegaShiftedInner_20;
   reg [7:0]   omegaShiftedInner_21;


   always @ (numShifted or omega_0 or omega_1 or omega_2 or omega_3 or omega_4 or omega_5 or omega_6 or omega_7 or omega_8 or omega_9 or omega_10 or omega_11 or omega_12 or omega_13 or omega_14 or omega_15 or omega_16 or omega_17 or omega_18 or omega_19 or omega_20 or omega_21 ) begin
      case (numShifted)
         (5'd0): begin
            omegaShiftedInner_0 [7:0]  = omega_0 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_1 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_2 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_3 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_4 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_10 [7:0] = omega_10 [7:0];
            omegaShiftedInner_11 [7:0] = omega_11 [7:0];
            omegaShiftedInner_12 [7:0] = omega_12 [7:0];
            omegaShiftedInner_13 [7:0] = omega_13 [7:0];
            omegaShiftedInner_14 [7:0] = omega_14 [7:0];
            omegaShiftedInner_15 [7:0] = omega_15 [7:0];
            omegaShiftedInner_16 [7:0] = omega_16 [7:0];
            omegaShiftedInner_17 [7:0] = omega_17 [7:0];
            omegaShiftedInner_18 [7:0] = omega_18 [7:0];
            omegaShiftedInner_19 [7:0] = omega_19 [7:0];
            omegaShiftedInner_20 [7:0] = omega_20 [7:0];
            omegaShiftedInner_21 [7:0] = omega_21 [7:0];
         end
         (5'd1): begin
            omegaShiftedInner_0 [7:0]  = omega_1 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_2 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_3 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_4 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_10 [7:0] = omega_11 [7:0];
            omegaShiftedInner_11 [7:0] = omega_12 [7:0];
            omegaShiftedInner_12 [7:0] = omega_13 [7:0];
            omegaShiftedInner_13 [7:0] = omega_14 [7:0];
            omegaShiftedInner_14 [7:0] = omega_15 [7:0];
            omegaShiftedInner_15 [7:0] = omega_16 [7:0];
            omegaShiftedInner_16 [7:0] = omega_17 [7:0];
            omegaShiftedInner_17 [7:0] = omega_18 [7:0];
            omegaShiftedInner_18 [7:0] = omega_19 [7:0];
            omegaShiftedInner_19 [7:0] = omega_20 [7:0];
            omegaShiftedInner_20 [7:0] = omega_21 [7:0];
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd2): begin
            omegaShiftedInner_0 [7:0]  = omega_2 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_3 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_4 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_10 [7:0] = omega_12 [7:0];
            omegaShiftedInner_11 [7:0] = omega_13 [7:0];
            omegaShiftedInner_12 [7:0] = omega_14 [7:0];
            omegaShiftedInner_13 [7:0] = omega_15 [7:0];
            omegaShiftedInner_14 [7:0] = omega_16 [7:0];
            omegaShiftedInner_15 [7:0] = omega_17 [7:0];
            omegaShiftedInner_16 [7:0] = omega_18 [7:0];
            omegaShiftedInner_17 [7:0] = omega_19 [7:0];
            omegaShiftedInner_18 [7:0] = omega_20 [7:0];
            omegaShiftedInner_19 [7:0] = omega_21 [7:0];
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd3): begin
            omegaShiftedInner_0 [7:0]  = omega_3 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_4 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_10 [7:0] = omega_13 [7:0];
            omegaShiftedInner_11 [7:0] = omega_14 [7:0];
            omegaShiftedInner_12 [7:0] = omega_15 [7:0];
            omegaShiftedInner_13 [7:0] = omega_16 [7:0];
            omegaShiftedInner_14 [7:0] = omega_17 [7:0];
            omegaShiftedInner_15 [7:0] = omega_18 [7:0];
            omegaShiftedInner_16 [7:0] = omega_19 [7:0];
            omegaShiftedInner_17 [7:0] = omega_20 [7:0];
            omegaShiftedInner_18 [7:0] = omega_21 [7:0];
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd4): begin
            omegaShiftedInner_0 [7:0]  = omega_4 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_10 [7:0] = omega_14 [7:0];
            omegaShiftedInner_11 [7:0] = omega_15 [7:0];
            omegaShiftedInner_12 [7:0] = omega_16 [7:0];
            omegaShiftedInner_13 [7:0] = omega_17 [7:0];
            omegaShiftedInner_14 [7:0] = omega_18 [7:0];
            omegaShiftedInner_15 [7:0] = omega_19 [7:0];
            omegaShiftedInner_16 [7:0] = omega_20 [7:0];
            omegaShiftedInner_17 [7:0] = omega_21 [7:0];
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd5): begin
            omegaShiftedInner_0 [7:0]  = omega_5 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_10 [7:0] = omega_15 [7:0];
            omegaShiftedInner_11 [7:0] = omega_16 [7:0];
            omegaShiftedInner_12 [7:0] = omega_17 [7:0];
            omegaShiftedInner_13 [7:0] = omega_18 [7:0];
            omegaShiftedInner_14 [7:0] = omega_19 [7:0];
            omegaShiftedInner_15 [7:0] = omega_20 [7:0];
            omegaShiftedInner_16 [7:0] = omega_21 [7:0];
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd6): begin
            omegaShiftedInner_0 [7:0]  = omega_6 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_10 [7:0] = omega_16 [7:0];
            omegaShiftedInner_11 [7:0] = omega_17 [7:0];
            omegaShiftedInner_12 [7:0] = omega_18 [7:0];
            omegaShiftedInner_13 [7:0] = omega_19 [7:0];
            omegaShiftedInner_14 [7:0] = omega_20 [7:0];
            omegaShiftedInner_15 [7:0] = omega_21 [7:0];
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd7): begin
            omegaShiftedInner_0 [7:0]  = omega_7 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_10 [7:0] = omega_17 [7:0];
            omegaShiftedInner_11 [7:0] = omega_18 [7:0];
            omegaShiftedInner_12 [7:0] = omega_19 [7:0];
            omegaShiftedInner_13 [7:0] = omega_20 [7:0];
            omegaShiftedInner_14 [7:0] = omega_21 [7:0];
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd8): begin
            omegaShiftedInner_0 [7:0]  = omega_8 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_10 [7:0] = omega_18 [7:0];
            omegaShiftedInner_11 [7:0] = omega_19 [7:0];
            omegaShiftedInner_12 [7:0] = omega_20 [7:0];
            omegaShiftedInner_13 [7:0] = omega_21 [7:0];
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd9): begin
            omegaShiftedInner_0 [7:0]  = omega_9 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_10 [7:0] = omega_19 [7:0];
            omegaShiftedInner_11 [7:0] = omega_20 [7:0];
            omegaShiftedInner_12 [7:0] = omega_21 [7:0];
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd10): begin
            omegaShiftedInner_0 [7:0]  = omega_10 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_10 [7:0] = omega_20 [7:0];
            omegaShiftedInner_11 [7:0] = omega_21 [7:0];
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd11): begin
            omegaShiftedInner_0 [7:0]  = omega_11 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_10 [7:0] = omega_21 [7:0];
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd12): begin
            omegaShiftedInner_0 [7:0]  = omega_12 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_9 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd13): begin
            omegaShiftedInner_0 [7:0]  = omega_13 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_8 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd14): begin
            omegaShiftedInner_0 [7:0]  = omega_14 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_7 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd15): begin
            omegaShiftedInner_0 [7:0]  = omega_15 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_6 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd16): begin
            omegaShiftedInner_0 [7:0]  = omega_16 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_5 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd17): begin
            omegaShiftedInner_0 [7:0]  = omega_17 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_4 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd18): begin
            omegaShiftedInner_0 [7:0]  = omega_18 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_3 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_4 [7:0]  = 8'd0;
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd19): begin
            omegaShiftedInner_0 [7:0]  = omega_19 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_2 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_3 [7:0]  = 8'd0;
            omegaShiftedInner_4 [7:0]  = 8'd0;
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd20): begin
            omegaShiftedInner_0 [7:0]  = omega_20 [7:0];
            omegaShiftedInner_1 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_2 [7:0]  = 8'd0;
            omegaShiftedInner_3 [7:0]  = 8'd0;
            omegaShiftedInner_4 [7:0]  = 8'd0;
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         (5'd21): begin
            omegaShiftedInner_0 [7:0]  = omega_21 [7:0];
            omegaShiftedInner_1 [7:0]  = 8'd0;
            omegaShiftedInner_2 [7:0]  = 8'd0;
            omegaShiftedInner_3 [7:0]  = 8'd0;
            omegaShiftedInner_4 [7:0]  = 8'd0;
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
         default: begin
            omegaShiftedInner_0 [7:0]  = 8'd0;
            omegaShiftedInner_1 [7:0]  = 8'd0;
            omegaShiftedInner_2 [7:0]  = 8'd0;
            omegaShiftedInner_3 [7:0]  = 8'd0;
            omegaShiftedInner_4 [7:0]  = 8'd0;
            omegaShiftedInner_5 [7:0]  = 8'd0;
            omegaShiftedInner_6 [7:0]  = 8'd0;
            omegaShiftedInner_7 [7:0]  = 8'd0;
            omegaShiftedInner_8 [7:0]  = 8'd0;
            omegaShiftedInner_9 [7:0]  = 8'd0;
            omegaShiftedInner_10 [7:0] = 8'd0;
            omegaShiftedInner_11 [7:0] = 8'd0;
            omegaShiftedInner_12 [7:0] = 8'd0;
            omegaShiftedInner_13 [7:0] = 8'd0;
            omegaShiftedInner_14 [7:0] = 8'd0;
            omegaShiftedInner_15 [7:0] = 8'd0;
            omegaShiftedInner_16 [7:0] = 8'd0;
            omegaShiftedInner_17 [7:0] = 8'd0;
            omegaShiftedInner_18 [7:0] = 8'd0;
            omegaShiftedInner_19 [7:0] = 8'd0;
            omegaShiftedInner_20 [7:0] = 8'd0;
            omegaShiftedInner_21 [7:0] = 8'd0;
         end
        endcase
    end



   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   assign omegaShifted_0   = omegaShiftedInner_0;
   assign omegaShifted_1   = omegaShiftedInner_1;
   assign omegaShifted_2   = omegaShiftedInner_2;
   assign omegaShifted_3   = omegaShiftedInner_3;
   assign omegaShifted_4   = omegaShiftedInner_4;
   assign omegaShifted_5   = omegaShiftedInner_5;
   assign omegaShifted_6   = omegaShiftedInner_6;
   assign omegaShifted_7   = omegaShiftedInner_7;
   assign omegaShifted_8   = omegaShiftedInner_8;
   assign omegaShifted_9   = omegaShiftedInner_9;
   assign omegaShifted_10  = omegaShiftedInner_10;
   assign omegaShifted_11  = omegaShiftedInner_11;
   assign omegaShifted_12  = omegaShiftedInner_12;
   assign omegaShifted_13  = omegaShiftedInner_13;
   assign omegaShifted_14  = omegaShiftedInner_14;
   assign omegaShifted_15  = omegaShiftedInner_15;
   assign omegaShifted_16  = omegaShiftedInner_16;
   assign omegaShifted_17  = omegaShiftedInner_17;
   assign omegaShifted_18  = omegaShiftedInner_18;
   assign omegaShifted_19  = omegaShiftedInner_19;
   assign omegaShifted_20  = omegaShiftedInner_20;
   assign omegaShifted_21  = omegaShiftedInner_21;



endmodule
