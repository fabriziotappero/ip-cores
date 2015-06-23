//===================================================================
// Module Name : RsSimBench
// File Name   : RsSimBench.cpp
// Function    : RTL Decoder Bench Module generation
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include<windows.h>
#include<fstream>
#include <string.h>
using namespace std;
FILE  *OutFileSimBench;


void RsSimBench(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int errorStats, int passFailFlag, int delayDataIn, int encDecMode, int ErasureOption, int BlockAmount, int encBlockAmount, int ErrorRate, int PowerErrorRate, int ErasureRate, int PowerErasureRate, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   int Words, benchInSize, benchOutSize;
   int encBenchInSize;
   int delay;
   int *euclideTab;
   char *strsimReedSolomon;

   syndromeLength = TotalSize - DataSize;

   euclideTab    =new int[(syndromeLength+1)];

   //------------------------------------------------------------------------
   //- Data files
   //------------------------------------------------------------------------
   Words = BlockAmount;

   benchOutSize = (Words * TotalSize) - 1;

   encBenchInSize = encBlockAmount * ((DataSize + (TotalSize-DataSize)*1)) - 1;


   //------------------------------------------------------------------------
   //- Euclide Length calculation
   //------------------------------------------------------------------------
   euclideTab [syndromeLength] = 3;
   euclideTab [syndromeLength-1] = 3;

   for(ii=(syndromeLength-2); ii>0; ii=ii-2){
      euclideTab [ii] = euclideTab   [ii+2] + 6;
      euclideTab [ii-1] = euclideTab [ii+1] + 6;
   }
   
   euclideTab [0] = euclideTab [2] + 6;


   if (euclideTab [0] > TotalSize) {
      benchInSize = (Words * euclideTab [0]) - 1;;
   }
   else {
      benchInSize = (Words * TotalSize) - 1;;
   }

  //---------------------------------------------------------------
  // delay variable calculation
  //---------------------------------------------------------------
   if (ErasureOption == 1) {
      delay = TotalSize + syndromeLength + 1 + euclideTab [0] + 5;
   }else{
      delay = TotalSize + euclideTab [0] + 5;
   }
   benchInSize = benchInSize + delay + 1;


  //---------------------------------------------------------------
  // open file
  //---------------------------------------------------------------
  strsimReedSolomon = (char *)calloc(lengthPath + 22,  sizeof(char));
  if (pathFlag == 0) { 
        strsimReedSolomon[0] = '.';
  }else{
     for(ii=0; ii<lengthPath; ii++){
        strsimReedSolomon[ii] = rootFolderPath[ii];
     }
  }
  strcat(strsimReedSolomon, "/sim/simReedSolomon.v");

  OutFileSimBench = fopen(strsimReedSolomon,"w");



  //---------------------------------------------------------------
  // Ports Declaration
  //---------------------------------------------------------------
   fprintf(OutFileSimBench, "//===================================================================\n");
   fprintf(OutFileSimBench, "// Module Name : simReedSolomon\n");
   fprintf(OutFileSimBench, "// File Name   : simReedSolomon.v\n");
   fprintf(OutFileSimBench, "// Function    : Rs bench Module\n");
   fprintf(OutFileSimBench, "// \n");
   fprintf(OutFileSimBench, "// Revision History:\n");
   fprintf(OutFileSimBench, "// Date          By           Version    Change Description\n");
   fprintf(OutFileSimBench, "//===================================================================\n");
   fprintf(OutFileSimBench, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileSimBench, "//\n");
   fprintf(OutFileSimBench, "//===================================================================\n");
   fprintf(OutFileSimBench, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileSimBench, "//\n\n\n");

   fprintf(OutFileSimBench, "module simReedSolomon;\n");
   fprintf(OutFileSimBench, "\n\n");


  //---------------------------------------------------------------
  // global Reg & wires declaration
  //---------------------------------------------------------------

   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   // global registers\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   reg          CLK;       // RSenc && RSdec system clock signal\n");
   fprintf(OutFileSimBench, "   reg          RESET;     // RSenc && RSdec system reset\n");
   fprintf(OutFileSimBench, "\n\n");


   //------------------------------------------------------------------------
   // RS decoder Reg & wires declaration
   //------------------------------------------------------------------------
   if ((encDecMode == 2) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   // RS decoder registers & wires\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg          rsdecEnable;        // RSdec system enable\n");
      fprintf(OutFileSimBench, "   reg          rsdecSync;          // RSdec sync signal\n");
      fprintf(OutFileSimBench, "   reg          rsdecErasureIn;     // RSdec erasure Input signal  \n");
      fprintf(OutFileSimBench, "   reg  [%d:0]   rsdecDataIn;        // Rsdec Data Input signal\n", bitSymbol-1);
      fprintf(OutFileSimBench, "\n\n");

      fprintf(OutFileSimBench, "   wire         rsdecOutStartPls;   // RSdec first decoded symbol trigger\n");
      fprintf(OutFileSimBench, "   wire         rsdecOutDone;       // RSdec last decoder symbol trigger\n");
      fprintf(OutFileSimBench, "   wire [%d:0]   rsdecOutData;       // RSdec output data signal\n", bitSymbol-1);


      if (errorStats == 1) { 
         fprintf(OutFileSimBench, "   wire [%d:0]   rsdecErrorNum;      // RSdec Error amount statistics\n", bitSymbol-1);
         fprintf(OutFileSimBench, "   wire [%d:0]   rsdecErasureNum;    // RSdec Erasure amount statistics\n", bitSymbol-1);
      }

      if (passFailFlag == 1){
         fprintf(OutFileSimBench, "   wire         rsdecFail;          // RSdec Pass/Fail output flag\n");
      }
      fprintf(OutFileSimBench, "   wire         rsdecOutEnable;     // RSdec output enable\n");

      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "   wire [%d:0]   rsdecDelayedData;   // RSdec delayed data\n", bitSymbol-1);
      }
      fprintf(OutFileSimBench, "\n\n");
   }

   //------------------------------------------------------------------------
   // RS encoder Reg & wires declaration
   //------------------------------------------------------------------------
   if ((encDecMode == 1) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   // RS encoder registers & wires\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg          rsencEnable;     // RSenc data enable input\n");
      fprintf(OutFileSimBench, "   reg          rsencStartPls;   // RSenc Start Pulse input\n");
      fprintf(OutFileSimBench, "   reg  [%d:0]   rsencDataIn;     // RSenc data in\n", (bitSymbol-1));
      fprintf(OutFileSimBench, "   wire [%d:0]   rsencDataOut;    // RSenc data out\n", (bitSymbol-1));
      fprintf(OutFileSimBench, "\n\n");
   }


   //------------------------------------------------------------------------
   // RS  Decoder Top module Instantiation
   //------------------------------------------------------------------------
   if ((encDecMode == 2) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //RS  Decoder Top module Instantiation\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   RsDecodeTop RsDecodeTop(\n");
      fprintf(OutFileSimBench, "      // Inputs\n");
      fprintf(OutFileSimBench, "      .CLK          (CLK),               // system clock\n");
      fprintf(OutFileSimBench, "      .RESET        (RESET),             // system reset\n");
      fprintf(OutFileSimBench, "      .enable       (rsdecEnable),       // RSdec enable in\n");
      fprintf(OutFileSimBench, "      .startPls     (rsdecSync),         // RSdec sync signal\n");
      if (ErasureOption == 1) {
         fprintf(OutFileSimBench, "      .erasureIn    (rsdecErasureIn),    // RSdec erasure in\n");
      }
      fprintf(OutFileSimBench, "      .dataIn       (rsdecDataIn),       // RSdec data in\n");
      fprintf(OutFileSimBench, "      // Outputs\n");
      fprintf(OutFileSimBench, "      .outEnable    (rsdecOutEnable),    // RSdec enable out\n");
      fprintf(OutFileSimBench, "      .outStartPls  (rsdecOutStartPls),  // RSdec start pulse out\n");
      fprintf(OutFileSimBench, "      .outDone      (rsdecOutDone),      // RSdec done out\n");

      if (errorStats == 1) { 
         fprintf(OutFileSimBench, "      .errorNum     (rsdecErrorNum),     // RSdec error number\n");
         if (ErasureOption == 1) {
            fprintf(OutFileSimBench, "      .erasureNum   (rsdecErasureNum),   // RSdec Erasure number\n");
         }
      }

      if (passFailFlag == 1){
         fprintf(OutFileSimBench, "      .fail         (rsdecFail),         // RSdec Pass/Fail flag\n");
      }
      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "      .delayedData  (rsdecDelayedData),  // RSdec delayed data\n");
      }
      fprintf(OutFileSimBench, "      .outData      (rsdecOutData)       // Rsdec data out\n");
      fprintf(OutFileSimBench, "   );\n");
      fprintf(OutFileSimBench, "\n\n");
   }


   //------------------------------------------------------------------------
   // Encoder Top module
   //------------------------------------------------------------------------
   if ((encDecMode == 1) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   // RS Encoder Top module Instantiation\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   RsEncodeTop RsEncodeTop(\n");
      fprintf(OutFileSimBench, "      // Inputs\n");
      fprintf(OutFileSimBench, "      .CLK      (CLK),           // system clock\n");
      fprintf(OutFileSimBench, "      .RESET    (RESET),         // system reset\n");
      fprintf(OutFileSimBench, "      .enable   (rsencEnable),   // RSenc enable signal\n");
      fprintf(OutFileSimBench, "      .startPls (rsencStartPls), // RSenc sync signal\n");
      fprintf(OutFileSimBench, "      // Outputs\n");
      fprintf(OutFileSimBench, "      .dataIn   (rsencDataIn),   // RSenc data in\n");
      fprintf(OutFileSimBench, "      .dataOut  (rsencDataOut)   // RSenc data out\n");
      fprintf(OutFileSimBench, "   );\n");
      fprintf(OutFileSimBench, "\n\n");
   }

   //------------------------------------------------------------------------
   // clock CLK generation
   //------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   // clock CLK generation\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   parameter period = 10;\n");
   fprintf(OutFileSimBench, "   always # (period) CLK =~CLK;\n");
   fprintf(OutFileSimBench, "\n\n");


   //------------------------------------------------------------------------
   // log file
   //------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   // log file\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   reg           simStart;\n");
   fprintf(OutFileSimBench, "   integer  handleA;\n");
   fprintf(OutFileSimBench, "   initial begin\n");
   fprintf(OutFileSimBench, "      handleA = $fopen(\"result.out\", \"w\");\n");
   fprintf(OutFileSimBench, "   end\n");
   fprintf(OutFileSimBench, "\n\n");



   //------------------------------------------------------------------------
   // RSdec Input && Output Data files
   //------------------------------------------------------------------------
   if ((encDecMode == 2) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- RSdec Input && Output Data files\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg  [23:0]   rsdecInputBank  [%d:0];\n", benchInSize);
      fprintf(OutFileSimBench, "   reg  [87:0]   rsdecOutputBank [%d:0];\n", benchOutSize);
      fprintf(OutFileSimBench, "\n");
//      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsDecIn_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d.hex\", rsdecInputBank);\n", DataSize, TotalSize, PrimPoly, ErasureOption,BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, bitSymbol,errorStats, passFailFlag, delayDataIn, encDecMode, encBlockAmount);
//      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsDecOut_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d.hex\", rsdecOutputBank);\n", DataSize, TotalSize, PrimPoly, ErasureOption,BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, bitSymbol,errorStats, passFailFlag, delayDataIn, encDecMode, encBlockAmount);
      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsDecIn.hex\", rsdecInputBank);\n");
      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsDecOut.hex\", rsdecOutputBank);\n");
      fprintf(OutFileSimBench, "\n\n");
   }


   //------------------------------------------------------------------------
   // RSenc Input && Output Data files
   //------------------------------------------------------------------------
   if ((encDecMode == 1) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- RSenc Input && Output Data files\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");

      if (bitSymbol < 9){
         fprintf(OutFileSimBench, "   reg  [15:0]   rsencInputBank  [%d:0];\n", encBenchInSize);
         fprintf(OutFileSimBench, "   reg  [7:0]   rsencOutputBank  [%d:0];\n", encBenchInSize);
      }else{
         fprintf(OutFileSimBench, "   reg  [19:0]   rsencInputBank  [%d:0];\n", encBenchInSize);
         fprintf(OutFileSimBench, "   reg  [11:0]   rsencOutputBank  [%d:0];\n", encBenchInSize);
      }
//      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsEncIn_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d.hex\", rsencInputBank);\n", DataSize, TotalSize, PrimPoly, ErasureOption,BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, bitSymbol,errorStats, passFailFlag, delayDataIn, encDecMode, encBlockAmount);
//      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsEncOut_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d_%d.hex\", rsencOutputBank);\n", DataSize, TotalSize, PrimPoly, ErasureOption,BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, bitSymbol,errorStats, passFailFlag, delayDataIn, encDecMode, encBlockAmount);
      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsEncIn.hex\", rsencInputBank);\n");
      fprintf(OutFileSimBench, "   initial $readmemh(\"./RsEncOut.hex\", rsencOutputBank);\n");
      fprintf(OutFileSimBench, "\n\n");
  }


   //--------------------------------------------------------------------------
   //- simStartFF
   //--------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   //- simStartFF1, simStartFF2, simStartFF3\n");
   fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   reg simStartFF1;\n");
   fprintf(OutFileSimBench, "   reg simStartFF2;\n");
   fprintf(OutFileSimBench, "   reg simStartFF3;\n");
   fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileSimBench, "      if (~RESET) begin\n");
   fprintf(OutFileSimBench, "         simStartFF1 <= 1'b0;\n");
   fprintf(OutFileSimBench, "         simStartFF2 <= 1'b0;\n");
   fprintf(OutFileSimBench, "         simStartFF3 <= 1'b0;\n");
   fprintf(OutFileSimBench, "      end\n");
   fprintf(OutFileSimBench, "      else begin\n");
   fprintf(OutFileSimBench, "         simStartFF1 <= simStart;\n");
   fprintf(OutFileSimBench, "         simStartFF2 <= simStartFF1;\n");
   fprintf(OutFileSimBench, "         simStartFF3 <= simStartFF2;\n");
   fprintf(OutFileSimBench, "      end\n");
   fprintf(OutFileSimBench, "   end\n");
   fprintf(OutFileSimBench, "\n\n");


   //------------------------------------------------------------------------
   //+ IBankIndex
   //------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   //+ IBankIndex\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   reg [31:0]  IBankIndex;\n");
   fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileSimBench, "      if (~RESET) begin\n");
   fprintf(OutFileSimBench, "         IBankIndex <= 32'd0;\n");
   fprintf(OutFileSimBench, "      end\n");
   fprintf(OutFileSimBench, "      else if (simStart == 1'b1) begin\n");
   fprintf(OutFileSimBench, "         IBankIndex <= IBankIndex + 32'd1;\n");
   fprintf(OutFileSimBench, "      end\n");
   fprintf(OutFileSimBench, "   end\n");
   fprintf(OutFileSimBench, "\n\n");


   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //-  RS DECODER test Bench
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   if ((encDecMode == 2) || (encDecMode == 3)){
      fprintf(OutFileSimBench, "//--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "//- RS Decoder Test Bench\n");
      fprintf(OutFileSimBench, "//--------------------------------------------------------------------------\n");


      //--------------------------------------------------------------------------
      //- rsdecInput
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- rsdecInput\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   wire  [23:0] rsdecInput;\n");
      fprintf(OutFileSimBench, "   assign rsdecInput = (IBankIndex < 32'd%d) ? rsdecInputBank [IBankIndex] : 24'd0;\n", benchInSize+1);
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsdecSync
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecSync\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecSync <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (simStart == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecSync <= rsdecInput[20];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsdecEnable
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecEnable\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecEnable <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (simStart == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecEnable <= rsdecInput[16];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsdecErasureIn
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecErasureIn\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecErasureIn <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecErasureIn <= rsdecInput[12];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsdecDataIn
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecDataIn\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecDataIn <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecDataIn <= rsdecInput[%d:0];\n", bitSymbol-1);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsdecOBankIndex
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecOBankIndex\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [31:0]  rsdecOBankIndex;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecOBankIndex <= 32'd0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecOBankIndex <= rsdecOBankIndex + 32'd1;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //- rsdecOutput
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- rsdecOutput\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   wire  [87:0] rsdecOutput;\n");
      fprintf(OutFileSimBench, "   assign rsdecOutput = (rsdecOBankIndex < 32'd%d) ? rsdecOutputBank [rsdecOBankIndex] : 48'd0;\n", benchOutSize+1);
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecExpNumError
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecExpNumError\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecExpNumError;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpNumError <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpNumError <= rsdecOutput[47:36];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecExpNumError <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecTheoricalNumError
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecTheoricalNumError\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecTheoricalNumError;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalNumError <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalNumError <= rsdecOutput[75:64];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalNumError <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecExpNumErasure
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecExpNumErasure\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecExpNumErasure;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpNumErasure <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");

      switch(bitSymbol)
      {
         case (3):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[26:24];\n");
         break;
         case (4):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[27:24];\n");
         break;
         case (5):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[28:24];\n");
         break;
         case (6):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[29:24];\n");
         break;
         case (7):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[30:24];\n");
         break;
         case (8):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[31:24];\n");
         break;
         case (9):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[32:24];\n");
         break;
         case (10):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[33:24];\n");
         break;
         case (11):
            fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[34:24];\n");
         break;
         case (12):
             fprintf(OutFileSimBench, "         rsdecExpNumErasure <= rsdecOutput[35:24];\n");
         break;
         default :
             fprintf(OutFileSimBench, "         rsdecExpNumErasure <= 0;\n");
         break;
      }
      
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecExpNumErasure <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");



      //--------------------------------------------------------------------------
      //+ rsdecTheoricalNumErasure
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecTheoricalNumErasure\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecTheoricalNumErasure;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");

         switch(bitSymbol)
         {
         case (3):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[54:52];\n");
         break;
         case (4):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[55:52];\n");
         break;
         case (5):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[56:52];\n");
         break;
         case (6):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[57:52];\n");
         break;
         case (7):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[58:52];\n");
         break;
         case (8):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[59:52];\n");
         break;
         case (9):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[60:52];\n");
         break;
         case (10):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[61:52];\n");
         break;
         case (11):
            fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[62:52];\n");
         break;
         case (12):
             fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= rsdecOutput[63:52];\n");
         break;
         default :
             fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= 0;\n");
         break;
         }

      
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalNumErasure <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecTheoricalSyndromeLength
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecTheoricalSyndromeLength\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecTheoricalSyndromeLength;\n", 12);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalSyndromeLength <= %d'd0;\n", 13);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalSyndromeLength <= {1'b0, rsdecOutput[87:76]};\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecTheoricalSyndromeLength <= %d'd0;\n", 13);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecExpFailFlag
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecExpFailFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg       rsdecExpFailFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpFailFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpFailFlag <= rsdecOutput[48];\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");


      //--------------------------------------------------------------------------
      //+ rsdecExpData
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecExpData\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsdecExpData;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpData <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsdecExpData <= rsdecOutput[%d:0];\n", bitSymbol-1);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecExpData <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsdecExpDelayedData
      //--------------------------------------------------------------------------
      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   //+ rsdecExpDelayedData\n");
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   reg [%d:0]   rsdecExpDelayedData;\n", bitSymbol-1);
         fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileSimBench, "      if (~RESET) begin\n");
         fprintf(OutFileSimBench, "         rsdecExpDelayedData <= %d'd0;\n", bitSymbol);
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else if (rsdecOutEnable == 1'b1) begin\n");
         fprintf(OutFileSimBench, "         rsdecExpDelayedData <= rsdecOutput[%d:12];\n", bitSymbol+11);
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else begin\n");
         fprintf(OutFileSimBench, "         rsdecExpDelayedData <= %d'd0;\n", bitSymbol);
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "   end\n");
         fprintf(OutFileSimBench, "\n\n");
      }


      //--------------------------------------------------------------------------
      //+ rsdecOutDataFF, rsdecOutEnableFF
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsdecOutDataFF, rsdecOutEnableFF\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0] rsdecOutDataFF;\n", bitSymbol -1);
      fprintf(OutFileSimBench, "   reg       rsdecOutEnableFF;\n");

      if (errorStats == 1) { 
         fprintf(OutFileSimBench, "   reg [%d:0]   rsdecErrorNumFF;\n", bitSymbol-1);
         fprintf(OutFileSimBench, "   reg [%d:0]   rsdecErasureNumFF;\n", bitSymbol-1);
      }

      if (passFailFlag == 1){
         fprintf(OutFileSimBench, "   reg         rsdecFailFF;\n");
      }



      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "   reg [%d:0] rsdecDelayedDataFF;\n", bitSymbol -1);
      }


      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsdecOutDataFF <= %d'd0;\n",bitSymbol );
      fprintf(OutFileSimBench, "         rsdecOutEnableFF <= 1'b0;\n");
      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "         rsdecDelayedDataFF <= %d'd0;\n",bitSymbol );
      }
      if (errorStats == 1) {
         fprintf(OutFileSimBench, "         rsdecErrorNumFF <= %d'd0;\n",bitSymbol );
         fprintf(OutFileSimBench, "         rsdecErasureNumFF <= %d'd0;\n",bitSymbol );
      }
      if (passFailFlag == 1){
         fprintf(OutFileSimBench, "         rsdecFailFF <= 1'b0;\n");
      }
      
      
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsdecOutDataFF <= rsdecOutData;\n");
      fprintf(OutFileSimBench, "         rsdecOutEnableFF <= rsdecOutEnable;\n");
      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "         rsdecDelayedDataFF <= rsdecDelayedData;\n");
      }
      if (errorStats == 1) {
         fprintf(OutFileSimBench, "         rsdecErrorNumFF <= rsdecErrorNum;\n");
         fprintf(OutFileSimBench, "         rsdecErasureNumFF <= rsdecErasureNum;\n");
      }
      if (passFailFlag == 1){
         fprintf(OutFileSimBench, "         rsdecFailFF <= rsdecFail;\n");
      }
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsDecDelayedDataFlag, rsDecNGDelayedDataFlag
      //--------------------------------------------------------------------------
      if (delayDataIn == 1){
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   //+ rsDecDelayedDataFlag, rsDecNGDelayedDataFlag\n");
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   reg   rsDecDelayedDataFlag;\n");
         fprintf(OutFileSimBench, "   reg   rsDecNGDelayedDataFlag;\n");
         fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileSimBench, "      if (~RESET) begin\n");
         fprintf(OutFileSimBench, "         rsDecDelayedDataFlag <= 1'b0;\n");
         fprintf(OutFileSimBench, "         rsDecNGDelayedDataFlag   <= 1'b0;\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
         fprintf(OutFileSimBench, "         if (rsdecDelayedDataFF == rsdecExpDelayedData) begin\n");
         fprintf(OutFileSimBench, "            rsDecDelayedDataFlag <= 1'b0;\n");
         fprintf(OutFileSimBench, "         end\n");
         fprintf(OutFileSimBench, "         else begin\n");
         fprintf(OutFileSimBench, "            rsDecDelayedDataFlag <= 1'b1;\n");
         fprintf(OutFileSimBench, "            rsDecNGDelayedDataFlag   <= 1'b1;\n");
         fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Decoder: Delayed Data Pin NG!!!!\");\n");
         fprintf(OutFileSimBench, "         end\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else begin\n");
         fprintf(OutFileSimBench, "         rsDecDelayedDataFlag <= 1'b0;\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "   end\n");
         fprintf(OutFileSimBench, "\n\n\n\n\n\n");
      }


      //--------------------------------------------------------------------------
      //+ rsDecDataFlag, rsDecNGDataFlag
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsDecDataFlag, rsDecNGDataFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   rsDecDataFlag;\n");
      fprintf(OutFileSimBench, "   reg   rsDecNGDataFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsDecDataFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         rsDecNGDataFlag   <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         if (rsdecOutDataFF == rsdecExpData) begin\n");
      fprintf(OutFileSimBench, "            rsDecDataFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "         else begin\n");
      fprintf(OutFileSimBench, "            rsDecDataFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "            rsDecNGDataFlag   <= 1'b1;\n");
      fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Decoder Data Out: NG!!!!\");\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsDecDataFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n\n");


      //--------------------------------------------------------------------------
      //+ rsDecErasureFlag, rsDecNGErasureFlag
      //--------------------------------------------------------------------------
if (errorStats == 1) { 
   if (ErasureOption == 1) {
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsDecErasureFlag, rsDecNGErasureFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   rsDecErasureFlag;\n");
      fprintf(OutFileSimBench, "   reg   rsDecNGErasureFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsDecErasureFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         rsDecNGErasureFlag   <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         if (rsdecErasureNumFF == rsdecExpNumErasure) begin\n");
      fprintf(OutFileSimBench, "            rsDecErasureFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "         else begin\n");
      fprintf(OutFileSimBench, "            rsDecErasureFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "            rsDecNGErasureFlag   <= 1'b1;\n");
      fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Decoder Erasure Pin: NG!!!!\");\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsDecErasureFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n\n");
   }


      //--------------------------------------------------------------------------
      //+ rsDecErrorFlag, rsDecNGErrorFlag
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsDecErrorFlag, rsDecNGErrorFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   rsDecErrorFlag;\n");
      fprintf(OutFileSimBench, "   reg   rsDecNGErrorFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsDecErrorFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         rsDecNGErrorFlag   <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         if (rsdecErrorNumFF == rsdecExpNumError) begin\n");
      fprintf(OutFileSimBench, "            rsDecErrorFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "         else begin\n");
      fprintf(OutFileSimBench, "            rsDecErrorFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "            rsDecNGErrorFlag   <= 1'b1;\n");
      fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Decoder Error Pin : NG!!!!\");\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsDecErrorFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n\n");
}



   if (passFailFlag == 1){
      //--------------------------------------------------------------------------
      //+ rsDecFailPinFlag, rsDecNGFailPinFlag
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsDecFailPinFlag, rsDecNGFailPinFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   rsDecFailPinFlag;\n");
      fprintf(OutFileSimBench, "   reg   rsDecNGFailPinFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsDecFailPinFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         rsDecNGFailPinFlag   <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         if (rsdecFailFF == rsdecExpFailFlag) begin\n");
      fprintf(OutFileSimBench, "            rsDecFailPinFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "         else begin\n");
      fprintf(OutFileSimBench, "            rsDecFailPinFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "            rsDecNGFailPinFlag   <= 1'b1;\n");
      fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Decoder Pass Fail Pin : NG!!!!\");\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsDecFailPinFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n\n");
   }


      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsDecCorrectionAmount\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   wire [12:0]  rsDecCorrectionAmount;\n");
      fprintf(OutFileSimBench, "   assign rsDecCorrectionAmount = rsdecTheoricalNumErasure + rsdecTheoricalNumError*2;\n\n\n");
   


   if (passFailFlag == 1){
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ passFailPinThFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   passFailPinThFlag;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         passFailPinThFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin\n");
      fprintf(OutFileSimBench, "            if (rsdecFailFF==1'b1) begin\n");
      fprintf(OutFileSimBench, "               passFailPinThFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "               $fdisplay(handleA,\"Reed Solomon Decoder Pass Fail Pin : Th NG!!!!\");\n");
      fprintf(OutFileSimBench, "            end\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
   }
   
   
   if (errorStats == 1) { 
      if (ErasureOption == 1) {
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   //+ ErasurePinThFlag\n");
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   reg   ErasurePinThFlag;\n");
         fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileSimBench, "      if (~RESET) begin\n");
         fprintf(OutFileSimBench, "         ErasurePinThFlag <= 1'b0;\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
         fprintf(OutFileSimBench, "         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin\n");
         fprintf(OutFileSimBench, "            if (rsdecErasureNumFF != rsdecTheoricalNumErasure) begin\n");
         fprintf(OutFileSimBench, "               ErasurePinThFlag <= 1'b1;\n");
         fprintf(OutFileSimBench, "               $fdisplay(handleA,\"Reed Solomon Decoder Erasure Pin : Th NG!!!!\");\n");
         fprintf(OutFileSimBench, "            end\n");
         fprintf(OutFileSimBench, "         end\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "   end\n");
      }
      
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   //+ ErrorPinThFlag\n");
         fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
         fprintf(OutFileSimBench, "   reg   ErrorPinThFlag;\n");
         fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileSimBench, "      if (~RESET) begin\n");
         fprintf(OutFileSimBench, "         ErrorPinThFlag <= 1'b0;\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "      else if (rsdecOutEnableFF == 1'b1) begin\n");
         fprintf(OutFileSimBench, "         if (rsDecCorrectionAmount <=  rsdecTheoricalSyndromeLength) begin\n");
         fprintf(OutFileSimBench, "            if (rsdecErrorNumFF != rsdecTheoricalNumError) begin\n");
         fprintf(OutFileSimBench, "               ErrorPinThFlag <= 1'b1;\n");
         fprintf(OutFileSimBench, "               $fdisplay(handleA,\"Reed Solomon Decoder Error Pin : Th NG!!!!\");\n");
         fprintf(OutFileSimBench, "            end\n");
         fprintf(OutFileSimBench, "         end\n");
         fprintf(OutFileSimBench, "      end\n");
         fprintf(OutFileSimBench, "   end\n");
   }
      
      
   }

   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //-  RS ENCODER test Bench
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   //--------------------------------------------------------------------------
   if ((encDecMode == 1) || (encDecMode == 3)){

      fprintf(OutFileSimBench, "//--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "//- RS Encoder Test Bench\n");
      fprintf(OutFileSimBench, "//--------------------------------------------------------------------------\n");

      //--------------------------------------------------------------------------
      //- rsencInput
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- rsencInput\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      if (bitSymbol < 9){
         fprintf(OutFileSimBench, "   wire  [15:0] rsencInput;\n");
         fprintf(OutFileSimBench, "   assign rsencInput = (IBankIndex < 32'd%d) ? rsencInputBank [IBankIndex] : 16'd0;\n", encBenchInSize+1);
      }else{
         fprintf(OutFileSimBench, "   wire  [19:0] rsencInput;\n");
         fprintf(OutFileSimBench, "   assign rsencInput = (IBankIndex < 32'd%d) ? rsencInputBank [IBankIndex] : 20'd0;\n", encBenchInSize+1);
      }
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsencStartPls
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsencStartPls\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsencStartPls <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (simStart == 1'b1) begin\n");
      if (bitSymbol < 9){
         fprintf(OutFileSimBench, "         rsencStartPls <= rsencInput[12];\n");
      }else{
         fprintf(OutFileSimBench, "         rsencStartPls <= rsencInput[16];\n");
      }
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsencEnable
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsencEnable\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsencEnable <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      if (bitSymbol < 9){
         fprintf(OutFileSimBench, "         rsencEnable <= rsencInput[8];\n");
      }else{
         fprintf(OutFileSimBench, "         rsencEnable <= rsencInput[12];\n");
      }
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsencDataIn
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsencDataIn\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsencDataIn <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsencDataIn <= rsencInput[%d:0];\n", bitSymbol-1);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //------------------------------------------------------------------------
      //+ rsencOBankIndex
      //------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsencOBankIndex\n");
      fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [31:0]  rsencOBankIndex;\n");
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsencOBankIndex <= 32'd0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (simStartFF2 == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsencOBankIndex <= rsencOBankIndex + 32'd1;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //- rsencOutput
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //- rsencOutput\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      if (bitSymbol < 9){
         fprintf(OutFileSimBench, "   wire  [7:0] rsencOutput;\n");
         fprintf(OutFileSimBench, "   assign rsencOutput = (rsencOBankIndex < 32'd%d) ? rsencOutputBank [rsencOBankIndex] : 8'd0;\n", encBenchInSize+1);
      }else{
         fprintf(OutFileSimBench, "   wire  [11:0] rsencOutput;\n");
         fprintf(OutFileSimBench, "   assign rsencOutput = (rsencOBankIndex < 32'd%d) ? rsencOutputBank [rsencOBankIndex] : 12'd0;\n", encBenchInSize+1);
      }
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsencExpData
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsencExpData\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg [%d:0]   rsencExpData;\n", bitSymbol-1);
      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsencExpData <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if (simStartFF2 == 1'b1) begin\n");
      fprintf(OutFileSimBench, "         rsencExpData <= rsencOutput[%d:0];\n", bitSymbol-1);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsencExpData <= %d'd0;\n", bitSymbol);
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
      fprintf(OutFileSimBench, "\n\n");


      //--------------------------------------------------------------------------
      //+ rsEncPassFailFlag, rsEncFailFlag
      //--------------------------------------------------------------------------
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   //+ rsEncPassFailFlag, rsEncFailFlag\n");
      fprintf(OutFileSimBench, "   //--------------------------------------------------------------------------\n");
      fprintf(OutFileSimBench, "   reg   rsEncPassFailFlag;\n");
      fprintf(OutFileSimBench, "   reg   rsEncFailFlag;\n");

      fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileSimBench, "      if (~RESET) begin\n");
      fprintf(OutFileSimBench, "         rsEncPassFailFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         rsEncFailFlag   <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else if ((simStartFF3 == 1'b1) && (rsencOBankIndex < 32'd%d)) begin\n", encBenchInSize+2);
      fprintf(OutFileSimBench, "         if (rsencDataOut == rsencExpData) begin\n");
      fprintf(OutFileSimBench, "            rsEncPassFailFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "         else begin\n");
      fprintf(OutFileSimBench, "            rsEncPassFailFlag <= 1'b1;\n");
      fprintf(OutFileSimBench, "            rsEncFailFlag   <= 1'b1;\n");
      fprintf(OutFileSimBench, "            $fdisplay(handleA,\"Reed Solomon Encoder: NG!!!!\");\n");
      fprintf(OutFileSimBench, "         end\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "      else begin\n");
      fprintf(OutFileSimBench, "         rsEncPassFailFlag <= 1'b0;\n");
      fprintf(OutFileSimBench, "      end\n");
      fprintf(OutFileSimBench, "   end\n");
   }


   //------------------------------------------------------------------------
   // + simOver
   //------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   // + simOver\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   reg simOver;\n");

   fprintf(OutFileSimBench, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileSimBench, "      if (~RESET) begin\n");
   fprintf(OutFileSimBench, "         simOver <= 1'b0;\n");
   fprintf(OutFileSimBench, "      end\n");
   switch (encDecMode){
      case(1):
         fprintf(OutFileSimBench, "      else if (rsencOBankIndex > 32'd%d) begin\n", encBenchInSize+2);
      break;
      case(2):
         fprintf(OutFileSimBench, "      else if (rsdecOBankIndex > 32'd%d) begin\n", benchOutSize);
      break;
      case(3):
         fprintf(OutFileSimBench, "      else if ((rsencOBankIndex > 32'd%d) && (rsdecOBankIndex > 32'd%d)) begin\n", encBenchInSize+2, benchOutSize);
      break;
   }


   fprintf(OutFileSimBench, "         simOver <= 1'b1;\n");
   fprintf(OutFileSimBench, "         $fclose(handleA);\n");
   fprintf(OutFileSimBench, "         $finish;\n");
   fprintf(OutFileSimBench, "      end\n");
   fprintf(OutFileSimBench, "   end\n");



   //------------------------------------------------------------------------
   //-  TIMING
   //------------------------------------------------------------------------
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   //-  TIMING\n");
   fprintf(OutFileSimBench, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileSimBench, "   initial begin\n");
   fprintf(OutFileSimBench, "      simStart = 1'b0;\n");
   fprintf(OutFileSimBench, "      CLK = 0;\n");
   fprintf(OutFileSimBench, "      RESET = 1;\n");
   fprintf(OutFileSimBench, "      #(period*2)	RESET = 0;\n");
   fprintf(OutFileSimBench, "      #(period*2)	RESET = 1;\n");
   fprintf(OutFileSimBench, "      #(period*20) simStart = 1'b1;\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");
   fprintf(OutFileSimBench, "      #(period*99999999);\n");


   fprintf(OutFileSimBench, "   end\n");
   fprintf(OutFileSimBench, "endmodule\n");


  //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileSimBench);

  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] euclideTab;


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
//	ifstream fp_read("simReedSolomon.v", ios_base::in | ios_base::binary);
   ifstream fp_read(strsimReedSolomon, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strsimReedSolomon);


	//Create a temporary file for writing in the binary mode. This
	//file will be created in the same directory as the input file.
	ofstream fp_write(temp, ios_base::out | ios_base::trunc | ios_base::binary);

	while(fp_read.eof() != true)
	{
		fp_read.get(ch);
		//Check for CR (carriage return)
		if((int)ch == 0x0D)
			continue;
		if (!fp_read.eof())fp_write.put(ch);
	}

	fp_read.close();
	fp_write.close();
   //Delete the existing input file.
   remove(strsimReedSolomon);
   //Rename the temporary file to the input file.
   rename(temp, strsimReedSolomon);


	//Delete the temporary file.
	remove(temp);   


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strsimReedSolomon);


}
