//===================================================================
// Module Name : RsDecodeErasure
// File Name   : RsDecodeErasure.v
// Function    : Rs Decoder Erasure polynomial calculation Module
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//


module RsDecodeErasure(
   CLK,          // system clock
   RESET,        // system reset
   enable,       // enable signal
   sync,         // sync signal
   erasureIn,    // erasure input
   epsilon_0,    // epsilon polynom 0
   epsilon_1,    // epsilon polynom 1
   epsilon_2,    // epsilon polynom 2
   epsilon_3,    // epsilon polynom 3
   epsilon_4,    // epsilon polynom 4
   epsilon_5,    // epsilon polynom 5
   epsilon_6,    // epsilon polynom 6
   epsilon_7,    // epsilon polynom 7
   epsilon_8,    // epsilon polynom 8
   epsilon_9,    // epsilon polynom 9
   epsilon_10,   // epsilon polynom 10
   epsilon_11,   // epsilon polynom 11
   epsilon_12,   // epsilon polynom 12
   epsilon_13,   // epsilon polynom 13
   epsilon_14,   // epsilon polynom 14
   epsilon_15,   // epsilon polynom 15
   epsilon_16,   // epsilon polynom 16
   epsilon_17,   // epsilon polynom 17
   epsilon_18,   // epsilon polynom 18
   epsilon_19,   // epsilon polynom 19
   epsilon_20,   // epsilon polynom 20
   epsilon_21,   // epsilon polynom 21
   epsilon_22,   // epsilon polynom 22
   numErasure,   // erasure amount
   fail,         // decoder failure signal
   done          // done signal
);


   input          CLK;           // system clock
   input          RESET;         // system reset
   input          enable;        // enable signal
   input          sync;          // sync signal
   input          erasureIn;     // erasure input
   output [7:0]   epsilon_0;     // syndrome polynom 0
   output [7:0]   epsilon_1;     // syndrome polynom 1
   output [7:0]   epsilon_2;     // syndrome polynom 2
   output [7:0]   epsilon_3;     // syndrome polynom 3
   output [7:0]   epsilon_4;     // syndrome polynom 4
   output [7:0]   epsilon_5;     // syndrome polynom 5
   output [7:0]   epsilon_6;     // syndrome polynom 6
   output [7:0]   epsilon_7;     // syndrome polynom 7
   output [7:0]   epsilon_8;     // syndrome polynom 8
   output [7:0]   epsilon_9;     // syndrome polynom 9
   output [7:0]   epsilon_10;    // syndrome polynom 10
   output [7:0]   epsilon_11;    // syndrome polynom 11
   output [7:0]   epsilon_12;    // syndrome polynom 12
   output [7:0]   epsilon_13;    // syndrome polynom 13
   output [7:0]   epsilon_14;    // syndrome polynom 14
   output [7:0]   epsilon_15;    // syndrome polynom 15
   output [7:0]   epsilon_16;    // syndrome polynom 16
   output [7:0]   epsilon_17;    // syndrome polynom 17
   output [7:0]   epsilon_18;    // syndrome polynom 18
   output [7:0]   epsilon_19;    // syndrome polynom 19
   output [7:0]   epsilon_20;    // syndrome polynom 20
   output [7:0]   epsilon_21;    // syndrome polynom 21
   output [7:0]   epsilon_22;    // syndrome polynom 22
   output [4:0]   numErasure;    // erasure amount
   output         fail;          // decoder failure signal
   output         done;          // done signal
   //------------------------------------------------------------------
   // - parameters
   //------------------------------------------------------------------
   parameter erasureInitialPower = 8'd2;



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
   // + erasureCount
   //- Erasure Counter
   //------------------------------------------------------------------------
   reg    [7:0]   erasureCount;
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         erasureCount [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            if (erasureIn == 1'b1) begin
               erasureCount [7:0] <= 8'd1;
            end
            else begin
               erasureCount [7:0] <= 8'd0;
            end
         end
         else if (erasureIn == 1'b1) begin
            erasureCount [7:0] <= erasureCount [7:0] + 8'd1;
         end
      end
   end


   //------------------------------------------------------------------------
   // + fail
   //- If Erasure amount > 22 -> fail is ON
   //------------------------------------------------------------------------
   reg         fail;
   always @(erasureCount) begin
      if (erasureCount [7:0]> 8'd22) begin
         fail = 1'b1;
      end
      else begin
         fail = 1'b0;
      end
   end


   //------------------------------------------------------------------------
   // Erasure Polynominal Generator
   //------------------------------------------------------------------------
   reg    [7:0]    powerReg;
   wire    [7:0]   powerNew;
   wire    [7:0]   powerInitialNew;

   assign powerInitialNew [0] = erasureInitialPower[7];
   assign powerInitialNew [1] = erasureInitialPower[0];
   assign powerInitialNew [2] = erasureInitialPower[1] ^ erasureInitialPower[7];
   assign powerInitialNew [3] = erasureInitialPower[2] ^ erasureInitialPower[7];
   assign powerInitialNew [4] = erasureInitialPower[3] ^ erasureInitialPower[7];
   assign powerInitialNew [5] = erasureInitialPower[4];
   assign powerInitialNew [6] = erasureInitialPower[5];
   assign powerInitialNew [7] = erasureInitialPower[6];
   assign powerNew [0] = powerReg[7];
   assign powerNew [1] = powerReg[0];
   assign powerNew [2] = powerReg[1] ^ powerReg[7];
   assign powerNew [3] = powerReg[2] ^ powerReg[7];
   assign powerNew [4] = powerReg[3] ^ powerReg[7];
   assign powerNew [5] = powerReg[4];
   assign powerNew [6] = powerReg[5];
   assign powerNew [7] = powerReg[6];


   //------------------------------------------------------------------
   // + powerReg
   //------------------------------------------------------------------
   always @(posedge CLK or negedge RESET) begin
      if (~RESET) begin
         powerReg [7:0] <= 8'd0;
      end
      else if (enable == 1'b1) begin
         if (sync == 1'b1) begin
            powerReg[7:0] <= powerInitialNew[7:0];
         end
         else begin
            powerReg[7:0] <= powerNew[7:0];
         end
      end
   end


   //------------------------------------------------------------------------
   // + product_0,..., product_22
   //- Erasure Polynominal Generator
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
   wire [7:0]   product_22;

   reg  [7:0]    epsilonReg_0;
   reg  [7:0]    epsilonReg_1;
   reg  [7:0]    epsilonReg_2;
   reg  [7:0]    epsilonReg_3;
   reg  [7:0]    epsilonReg_4;
   reg  [7:0]    epsilonReg_5;
   reg  [7:0]    epsilonReg_6;
   reg  [7:0]    epsilonReg_7;
   reg  [7:0]    epsilonReg_8;
   reg  [7:0]    epsilonReg_9;
   reg  [7:0]    epsilonReg_10;
   reg  [7:0]    epsilonReg_11;
   reg  [7:0]    epsilonReg_12;
   reg  [7:0]    epsilonReg_13;
   reg  [7:0]    epsilonReg_14;
   reg  [7:0]    epsilonReg_15;
   reg  [7:0]    epsilonReg_16;
   reg  [7:0]    epsilonReg_17;
   reg  [7:0]    epsilonReg_18;
   reg  [7:0]    epsilonReg_19;
   reg  [7:0]    epsilonReg_20;
   reg  [7:0]    epsilonReg_21;
   reg  [7:0]    epsilonReg_22;


   RsDecodeMult   RsDecodeMult_0 (.A(powerReg[7:0]), .B(epsilonReg_0[7:0]), .P(product_0[7:0]));
   RsDecodeMult   RsDecodeMult_1 (.A(powerReg[7:0]), .B(epsilonReg_1[7:0]), .P(product_1[7:0]));
   RsDecodeMult   RsDecodeMult_2 (.A(powerReg[7:0]), .B(epsilonReg_2[7:0]), .P(product_2[7:0]));
   RsDecodeMult   RsDecodeMult_3 (.A(powerReg[7:0]), .B(epsilonReg_3[7:0]), .P(product_3[7:0]));
   RsDecodeMult   RsDecodeMult_4 (.A(powerReg[7:0]), .B(epsilonReg_4[7:0]), .P(product_4[7:0]));
   RsDecodeMult   RsDecodeMult_5 (.A(powerReg[7:0]), .B(epsilonReg_5[7:0]), .P(product_5[7:0]));
   RsDecodeMult   RsDecodeMult_6 (.A(powerReg[7:0]), .B(epsilonReg_6[7:0]), .P(product_6[7:0]));
   RsDecodeMult   RsDecodeMult_7 (.A(powerReg[7:0]), .B(epsilonReg_7[7:0]), .P(product_7[7:0]));
   RsDecodeMult   RsDecodeMult_8 (.A(powerReg[7:0]), .B(epsilonReg_8[7:0]), .P(product_8[7:0]));
   RsDecodeMult   RsDecodeMult_9 (.A(powerReg[7:0]), .B(epsilonReg_9[7:0]), .P(product_9[7:0]));
   RsDecodeMult   RsDecodeMult_10 (.A(powerReg[7:0]), .B(epsilonReg_10[7:0]), .P(product_10[7:0]));
   RsDecodeMult   RsDecodeMult_11 (.A(powerReg[7:0]), .B(epsilonReg_11[7:0]), .P(product_11[7:0]));
   RsDecodeMult   RsDecodeMult_12 (.A(powerReg[7:0]), .B(epsilonReg_12[7:0]), .P(product_12[7:0]));
   RsDecodeMult   RsDecodeMult_13 (.A(powerReg[7:0]), .B(epsilonReg_13[7:0]), .P(product_13[7:0]));
   RsDecodeMult   RsDecodeMult_14 (.A(powerReg[7:0]), .B(epsilonReg_14[7:0]), .P(product_14[7:0]));
   RsDecodeMult   RsDecodeMult_15 (.A(powerReg[7:0]), .B(epsilonReg_15[7:0]), .P(product_15[7:0]));
   RsDecodeMult   RsDecodeMult_16 (.A(powerReg[7:0]), .B(epsilonReg_16[7:0]), .P(product_16[7:0]));
   RsDecodeMult   RsDecodeMult_17 (.A(powerReg[7:0]), .B(epsilonReg_17[7:0]), .P(product_17[7:0]));
   RsDecodeMult   RsDecodeMult_18 (.A(powerReg[7:0]), .B(epsilonReg_18[7:0]), .P(product_18[7:0]));
   RsDecodeMult   RsDecodeMult_19 (.A(powerReg[7:0]), .B(epsilonReg_19[7:0]), .P(product_19[7:0]));
   RsDecodeMult   RsDecodeMult_20 (.A(powerReg[7:0]), .B(epsilonReg_20[7:0]), .P(product_20[7:0]));
   RsDecodeMult   RsDecodeMult_21 (.A(powerReg[7:0]), .B(epsilonReg_21[7:0]), .P(product_21[7:0]));
   RsDecodeMult   RsDecodeMult_22 (.A(powerReg[7:0]), .B(epsilonReg_22[7:0]), .P(product_22[7:0]));



   //------------------------------------------------------------------------
   // + epsilonReg_0,..., epsilonReg_21
   //------------------------------------------------------------------------
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
            if (erasureIn == 1'b1) begin
               epsilonReg_0 [7:0]   <= erasureInitialPower[7:0];
               epsilonReg_1 [7:0]   <= 8'd1;
               epsilonReg_2 [7:0]   <= 8'd0;
               epsilonReg_3 [7:0]   <= 8'd0;
               epsilonReg_4 [7:0]   <= 8'd0;
               epsilonReg_5 [7:0]   <= 8'd0;
               epsilonReg_6 [7:0]   <= 8'd0;
               epsilonReg_7 [7:0]   <= 8'd0;
               epsilonReg_8 [7:0]   <= 8'd0;
               epsilonReg_9 [7:0]   <= 8'd0;
               epsilonReg_10 [7:0]  <= 8'd0;
               epsilonReg_11 [7:0]  <= 8'd0;
               epsilonReg_12 [7:0]  <= 8'd0;
               epsilonReg_13 [7:0]  <= 8'd0;
               epsilonReg_14 [7:0]  <= 8'd0;
               epsilonReg_15 [7:0]  <= 8'd0;
               epsilonReg_16 [7:0]  <= 8'd0;
               epsilonReg_17 [7:0]  <= 8'd0;
               epsilonReg_18 [7:0]  <= 8'd0;
               epsilonReg_19 [7:0]  <= 8'd0;
               epsilonReg_20 [7:0]  <= 8'd0;
               epsilonReg_21 [7:0]  <= 8'd0;
               epsilonReg_22 [7:0]  <= 8'd0;
            end
            else begin
               epsilonReg_0 [7:0]  <= 8'd1;
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
         end
         else if (erasureIn == 1'b1) begin
            epsilonReg_0 [7:0]  <= product_0[7:0];
            epsilonReg_1 [7:0]  <= epsilonReg_0 [7:0] ^ product_1[7:0];
            epsilonReg_2 [7:0]  <= epsilonReg_1 [7:0] ^ product_2[7:0];
            epsilonReg_3 [7:0]  <= epsilonReg_2 [7:0] ^ product_3[7:0];
            epsilonReg_4 [7:0]  <= epsilonReg_3 [7:0] ^ product_4[7:0];
            epsilonReg_5 [7:0]  <= epsilonReg_4 [7:0] ^ product_5[7:0];
            epsilonReg_6 [7:0]  <= epsilonReg_5 [7:0] ^ product_6[7:0];
            epsilonReg_7 [7:0]  <= epsilonReg_6 [7:0] ^ product_7[7:0];
            epsilonReg_8 [7:0]  <= epsilonReg_7 [7:0] ^ product_8[7:0];
            epsilonReg_9 [7:0]  <= epsilonReg_8 [7:0] ^ product_9[7:0];
            epsilonReg_10 [7:0] <= epsilonReg_9 [7:0] ^ product_10[7:0];
            epsilonReg_11 [7:0] <= epsilonReg_10 [7:0] ^ product_11[7:0];
            epsilonReg_12 [7:0] <= epsilonReg_11 [7:0] ^ product_12[7:0];
            epsilonReg_13 [7:0] <= epsilonReg_12 [7:0] ^ product_13[7:0];
            epsilonReg_14 [7:0] <= epsilonReg_13 [7:0] ^ product_14[7:0];
            epsilonReg_15 [7:0] <= epsilonReg_14 [7:0] ^ product_15[7:0];
            epsilonReg_16 [7:0] <= epsilonReg_15 [7:0] ^ product_16[7:0];
            epsilonReg_17 [7:0] <= epsilonReg_16 [7:0] ^ product_17[7:0];
            epsilonReg_18 [7:0] <= epsilonReg_17 [7:0] ^ product_18[7:0];
            epsilonReg_19 [7:0] <= epsilonReg_18 [7:0] ^ product_19[7:0];
            epsilonReg_20 [7:0] <= epsilonReg_19 [7:0] ^ product_20[7:0];
            epsilonReg_21 [7:0] <= epsilonReg_20 [7:0] ^ product_21[7:0];
            epsilonReg_22 [7:0] <= epsilonReg_21 [7:0] ^ product_22[7:0];
         end
      end
   end



   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   assign epsilon_0 [7:0]   = epsilonReg_0[7:0];
   assign epsilon_1 [7:0]   = epsilonReg_1[7:0];
   assign epsilon_2 [7:0]   = epsilonReg_2[7:0];
   assign epsilon_3 [7:0]   = epsilonReg_3[7:0];
   assign epsilon_4 [7:0]   = epsilonReg_4[7:0];
   assign epsilon_5 [7:0]   = epsilonReg_5[7:0];
   assign epsilon_6 [7:0]   = epsilonReg_6[7:0];
   assign epsilon_7 [7:0]   = epsilonReg_7[7:0];
   assign epsilon_8 [7:0]   = epsilonReg_8[7:0];
   assign epsilon_9 [7:0]   = epsilonReg_9[7:0];
   assign epsilon_10 [7:0]  = epsilonReg_10[7:0];
   assign epsilon_11 [7:0]  = epsilonReg_11[7:0];
   assign epsilon_12 [7:0]  = epsilonReg_12[7:0];
   assign epsilon_13 [7:0]  = epsilonReg_13[7:0];
   assign epsilon_14 [7:0]  = epsilonReg_14[7:0];
   assign epsilon_15 [7:0]  = epsilonReg_15[7:0];
   assign epsilon_16 [7:0]  = epsilonReg_16[7:0];
   assign epsilon_17 [7:0]  = epsilonReg_17[7:0];
   assign epsilon_18 [7:0]  = epsilonReg_18[7:0];
   assign epsilon_19 [7:0]  = epsilonReg_19[7:0];
   assign epsilon_20 [7:0]  = epsilonReg_20[7:0];
   assign epsilon_21 [7:0]  = epsilonReg_21[7:0];
   assign epsilon_22 [7:0]  = epsilonReg_22[7:0];

   assign numErasure   = erasureCount[4:0];

endmodule
