//===================================================================
// Module Name : RsDecodeTop
// File Name   : RsDecodeTop.cpp
// Function    : RTL Decoder Top Module generation
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
FILE  *OutFileTop;


void RsDecodeTop(int DataSize, int TotalSize, int PrimPoly, int ErasureOption, int bitSymbol, int errorStats, int passFailFlag, int delayDataIn, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int indexSyndrome;
   int startPointer;
   int endPointer;
   int shiftPointer;
   syndromeLength = TotalSize - DataSize;

   int ii;
   int degreeTemp;
   char *strRsDecodeTop;

   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeTop = (char *)calloc(lengthPath + 19,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeTop[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeTop[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeTop, "/rtl/RsDecodeTop.v");

   OutFileTop = fopen(strRsDecodeTop,"w");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileTop, "//===================================================================\n");
   fprintf(OutFileTop, "// Module Name : RsDecodeTop\n");
   fprintf(OutFileTop, "// File Name   : RsDecodeTop.v\n");
   fprintf(OutFileTop, "// Function    : Rs Decoder Top Module\n");
   fprintf(OutFileTop, "// \n");
   fprintf(OutFileTop, "// Revision History:\n");
   fprintf(OutFileTop, "// Date          By           Version    Change Description\n");
   fprintf(OutFileTop, "//===================================================================\n");
   fprintf(OutFileTop, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileTop, "//\n");
   fprintf(OutFileTop, "//===================================================================\n");
   fprintf(OutFileTop, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileTop, "//\n\n\n");


   fprintf(OutFileTop, "module RsDecodeTop(\n");
   fprintf(OutFileTop, "   // Inputs\n");
   fprintf(OutFileTop, "   CLK,            // system clock\n");
   fprintf(OutFileTop, "   RESET,          // system reset\n");
   fprintf(OutFileTop, "   enable,         // system enable\n");
   fprintf(OutFileTop, "   startPls,       // sync signal\n");
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   erasureIn,      // erasure input\n");
   }


   fprintf(OutFileTop, "   dataIn,         // data input\n");
   fprintf(OutFileTop, "   // Outputs\n");
   fprintf(OutFileTop, "   outEnable,      // data out valid signal\n");
   fprintf(OutFileTop, "   outStartPls,    // first decoded symbol trigger\n");
   fprintf(OutFileTop, "   outDone,        // last symbol decoded trigger\n");

   if (errorStats == 1) {
   fprintf(OutFileTop, "   errorNum,       // number of errors corrected\n");
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   erasureNum,     // number of erasure corrected\n");
      }
   }

   if (passFailFlag == 1){
      fprintf(OutFileTop, "   fail,           // decoding failure signal\n");
   }
   if (delayDataIn == 1){
      fprintf(OutFileTop, "   delayedData,    // decoding failure signal\n");
   }
   
   fprintf(OutFileTop, "   outData         // data output\n");
   fprintf(OutFileTop, ");\n\n\n");


   //---------------------------------------------------------------
   // I/O instantiation
   //---------------------------------------------------------------
   fprintf(OutFileTop, "   input          CLK;            // system clock\n");
   fprintf(OutFileTop, "   input          RESET;          // system reset\n");
   fprintf(OutFileTop, "   input          enable;         // system enable\n");
   fprintf(OutFileTop, "   input          startPls;       // sync signal\n");
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   input          erasureIn;      // erasure input\n");
   }

   fprintf(OutFileTop, "   input  [%d:0]   dataIn;         // data input\n", bitSymbol-1);
   fprintf(OutFileTop, "   output         outEnable;      // data out valid signal\n");
   fprintf(OutFileTop, "   output         outStartPls;    // first decoded symbol trigger\n");
   fprintf(OutFileTop, "   output         outDone;        // last symbol decoded trigger\n");

   if (errorStats == 1) {
      fprintf(OutFileTop, "   output [%d:0]   errorNum;       // number of errors corrected\n", bitSymbol-1);
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   output [%d:0]   erasureNum;     // number of erasure corrected\n", bitSymbol-1);
      }
   }


   if (passFailFlag == 1){
      fprintf(OutFileTop, "   output         fail;           // decoding failure signal\n");
   }
   if (delayDataIn == 1){
      fprintf(OutFileTop, "   output [%d:0]   delayedData;    // delayed input data\n", bitSymbol-1);
   }

   fprintf(OutFileTop, "   output [%d:0]   outData;        // data output\n", bitSymbol-1);


   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------------
   // + dataInCheck
   //- assign to 0 if Erasure
   //------------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + dataInCheck\n");
   fprintf(OutFileTop, "   //- assign to 0 if Erasure\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   wire [%d:0]   dataInCheck;\n\n", bitSymbol-1);

   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   assign dataInCheck = (erasureIn == 1'b0) ? dataIn : %d'd0;\n", bitSymbol);
   } else {
      fprintf(OutFileTop, "   assign dataInCheck = dataIn;\n");
   }
   fprintf(OutFileTop, "\n\n\n");



   //------------------------------------------------------------------
   // + syndrome_0,...,syndrome_xxx
   // + doneSyndrome
   //- RS Syndrome calculation
   //------------------------------------------------------------------
   fprintf(OutFileTop, "    //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "    // + syndrome_0,...,syndrome_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "    // + doneSyndrome\n");
   fprintf(OutFileTop, "    //- RS Syndrome calculation\n");
   fprintf(OutFileTop, "    //------------------------------------------------------------------\n");
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "    wire [%d:0]   syndrome_%d;\n", bitSymbol-1, ii);
   }
   fprintf(OutFileTop, "    wire         doneSyndrome;\n");
   fprintf(OutFileTop, "\n\n");


   fprintf(OutFileTop, "   RsDecodeSyndrome RsDecodeSyndrome(\n");
   fprintf(OutFileTop, "      // Inputs\n");
   fprintf(OutFileTop, "      .CLK           (CLK),\n");
   fprintf(OutFileTop, "      .RESET         (RESET),\n");
   fprintf(OutFileTop, "      .enable        (enable),\n");
   fprintf(OutFileTop, "      .sync          (startPls),\n");
   fprintf(OutFileTop, "      .dataIn        (dataInCheck),\n");
   fprintf(OutFileTop, "      // Outputs\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileTop, "      .syndrome_%d    (syndrome_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .syndrome_%d   (syndrome_%d),\n", ii, ii);
      }
   }
   fprintf(OutFileTop, "      .done          (doneSyndrome)\n");
   fprintf(OutFileTop, "   );\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // indexSyndrome calculation
   //------------------------------------------------------------------
   if (syndromeLength > 2047) {
      indexSyndrome = 11;
   }
   else if (syndromeLength > 1023) {
      indexSyndrome = 10;
   }
   else if (syndromeLength > 511) {
      indexSyndrome = 9;
   }
   else if (syndromeLength > 255) {
      indexSyndrome = 8;
   }
   else if (syndromeLength > 127) {
      indexSyndrome = 7;
   }
   else if  (syndromeLength > 63) {
      indexSyndrome = 6;
   }
   else if  (syndromeLength > 31) {
      indexSyndrome = 5;
   }
   else if  (syndromeLength > 15) {
      indexSyndrome = 4;
   }
   else if  (syndromeLength > 7) {
      indexSyndrome = 3;
   }
   else if  (syndromeLength > 3) {
      indexSyndrome = 2;
   }
   else {
      indexSyndrome = 1;
   }


   //------------------------------------------------------------------
   // + epsilon_0,..., epsilon_xxx
   // + degreeEpsilon, failErasure, doneErasure
   //- RS Erasure calculation
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + epsilon_0,..., epsilon_%d\n", syndromeLength);
      fprintf(OutFileTop, "   // + degreeEpsilon, failErasure, doneErasure\n");
      fprintf(OutFileTop, "   //- RS Erasure calculation\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         fprintf(OutFileTop, "   wire [%d:0]   epsilon_%d;\n", bitSymbol-1, ii);
      }

      fprintf(OutFileTop, "   wire [%d:0]   degreeEpsilon;\n", indexSyndrome);

      if (passFailFlag == 1){
         fprintf(OutFileTop, "   wire         failErasure;\n");
      }
      fprintf(OutFileTop, "   wire         doneErasure;\n");
   }
   fprintf(OutFileTop, "\n\n");


   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   RsDecodeErasure RsDecodeErasure(\n");
      fprintf(OutFileTop, "      // Inputs\n");
      fprintf(OutFileTop, "      .CLK          (CLK),\n");
      fprintf(OutFileTop, "      .RESET        (RESET),\n");
      fprintf(OutFileTop, "      .enable       (enable),\n");
      fprintf(OutFileTop, "      .sync         (startPls),\n");
      fprintf(OutFileTop, "      .erasureIn    (erasureIn),\n");
      fprintf(OutFileTop, "      // Outputs\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .epsilon_%d    (epsilon_%d),\n", ii ,ii);
         }else{
            fprintf(OutFileTop, "      .epsilon_%d   (epsilon_%d),\n", ii ,ii);
         }
      }
      fprintf(OutFileTop, "      .numErasure   (degreeEpsilon),\n");
      if (passFailFlag == 1){
         fprintf(OutFileTop, "      .fail         (failErasure),\n");
      }
      fprintf(OutFileTop, "      .done         (doneErasure)\n");
      fprintf(OutFileTop, "   );\n");
   }
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + polymulSyndrome_0,..., polymulSyndrome_xxx
   // + donePolymul
   //- RS Polymul calculation
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + polymulSyndrome_0,..., polymulSyndrome_%d\n",syndromeLength-1);
      fprintf(OutFileTop, "   // + donePolymul\n");
      fprintf(OutFileTop, "   //- RS Polymul calculation\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      for(ii=0; ii<syndromeLength; ii++){
         fprintf(OutFileTop, "    wire [%d:0]   polymulSyndrome_%d;\n",bitSymbol -1, ii);
      }
      fprintf(OutFileTop, "    wire         donePolymul;\n");
      fprintf(OutFileTop, "\n\n");
   }


   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   RsDecodePolymul RsDecodePolymul(\n");
      fprintf(OutFileTop, "      // Inputs\n");
      fprintf(OutFileTop, "      .CLK              (CLK),\n");
      fprintf(OutFileTop, "      .RESET            (RESET),\n");
      fprintf(OutFileTop, "      .enable           (enable),\n");
      fprintf(OutFileTop, "      .sync             (doneSyndrome),\n");
      for(ii=0; ii<syndromeLength; ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .syndromeIn_%d     (syndrome_%d),\n", ii ,ii);
         }else{
            fprintf(OutFileTop, "      .syndromeIn_%d    (syndrome_%d),\n", ii ,ii);
         }
      }
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .epsilon_%d        (epsilon_%d),\n", ii ,ii);
         }else{
            fprintf(OutFileTop, "      .epsilon_%d       (epsilon_%d),\n", ii ,ii);
         }
      }
      fprintf(OutFileTop, "      // Outputs\n");
      for(ii=0; ii<syndromeLength; ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .syndromeOut_%d    (polymulSyndrome_%d),\n", ii ,ii);
         }else{
            fprintf(OutFileTop, "      .syndromeOut_%d   (polymulSyndrome_%d),\n", ii ,ii);
         }
      }
      fprintf(OutFileTop, "      .done             (donePolymul)\n");
      fprintf(OutFileTop, "   );\n");
   }

   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + lambda_0,..., lambda_xxx
   // + omega_0,..., omega_xxx
   // + numShifted, doneEuclide
   //- RS EUCLIDE
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + lambda_0,..., lambda_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   // + omega_0,..., omega_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   // + numShifted, doneEuclide\n");
   fprintf(OutFileTop, "   //- RS EUCLIDE\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");


   if (ErasureOption == 0){
      startPointer = (syndromeLength/2);
   }else{
      startPointer = 0;
   }
   if (ErasureOption == 0){
      endPointer = (syndromeLength/2)+1;
   }else{
      endPointer = syndromeLength;
   }


/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   wire [%d:0]   lambda_%d;\n", bitSymbol-1, ii);
   }
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   wire [%d:0]   omega_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileTop, "   wire [%d:0]   lambda_%d;\n", bitSymbol-1, ii);
   }
   for(ii=startPointer; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   wire [%d:0]   omega_%d;\n", bitSymbol-1, ii);
   }


   fprintf(OutFileTop, "   wire         doneEuclide;\n");


   fprintf(OutFileTop, "   wire [%d:0]   numShifted;\n", indexSyndrome);
   if (ErasureOption == 1) {   
      fprintf(OutFileTop, "   reg  [%d:0]   degreeEpsilonReg;\n", indexSyndrome);
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   RsDecodeEuclide  RsDecodeEuclide(\n");
   fprintf(OutFileTop, "      // Inputs\n");
   fprintf(OutFileTop, "      .CLK           (CLK),\n");
   fprintf(OutFileTop, "      .RESET         (RESET),\n");
   fprintf(OutFileTop, "      .enable        (enable),\n");
   if (ErasureOption == 1) {   
      fprintf(OutFileTop, "      .sync          (donePolymul),\n");
   } else {
      fprintf(OutFileTop, "      .sync          (doneSyndrome),\n");
   }

   if (ErasureOption == 1) {
      for(ii=0; ii<syndromeLength; ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .syndrome_%d    (polymulSyndrome_%d),\n", ii, ii);
         }else{
            fprintf(OutFileTop, "      .syndrome_%d   (polymulSyndrome_%d),\n", ii, ii);
         }
      }
   }else{
      for(ii=0; ii<syndromeLength; ii++){
         if (ii<10){
            fprintf(OutFileTop, "      .syndrome_%d    (syndrome_%d),\n", ii, ii);
         }else{
            fprintf(OutFileTop, "      .syndrome_%d   (syndrome_%d),\n", ii, ii);
         }
      }
   }


   if (ErasureOption == 1) {   
      fprintf(OutFileTop, "      .numErasure    (degreeEpsilonReg),\n");
   }

   fprintf(OutFileTop, "      // Outputs\n");
/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileTop, "      .lambda_%d      (lambda_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .lambda_%d     (lambda_%d),\n", ii, ii);
      }
   }
   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileTop, "      .omega_%d       (omega_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omega_%d      (omega_%d),\n", ii, ii);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileTop, "      .lambda_%d      (lambda_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .lambda_%d     (lambda_%d),\n", ii, ii);
      }
   }
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileTop, "      .omega_%d       (omega_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omega_%d      (omega_%d),\n", ii, ii);
      }
   }
   fprintf(OutFileTop, "      .numShifted    (numShifted),\n");
   fprintf(OutFileTop, "      .done          (doneEuclide)\n");
   fprintf(OutFileTop, "   );\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + epsilonReg_0, ..., epsilonReg_xxx
   //-
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + epsilonReg_0, ..., epsilonReg_%d\n", syndromeLength);
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         fprintf(OutFileTop, "   reg [%d:0]   epsilonReg_%d;\n", bitSymbol-1, ii);
      }
      fprintf(OutFileTop, "\n\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10){
            fprintf(OutFileTop, "         epsilonReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }else{
            fprintf(OutFileTop, "         epsilonReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }
      }

      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin\n");

      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10){
            fprintf(OutFileTop, "         epsilonReg_%d [%d:0]  <= epsilon_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }else{
            fprintf(OutFileTop, "         epsilonReg_%d [%d:0] <= epsilon_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }
      }
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + epsilonReg2_0,..., epsilonReg2_xxx
   //-
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + epsilonReg2_0,..., epsilonReg2_%d\n", syndromeLength);
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         fprintf(OutFileTop, "   reg [%d:0]   epsilonReg2_%d;\n", bitSymbol-1, ii);
      }
      fprintf(OutFileTop, "\n\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10){
            fprintf(OutFileTop, "         epsilonReg2_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }else{
            fprintf(OutFileTop, "         epsilonReg2_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }
      }
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10){
            fprintf(OutFileTop, "         epsilonReg2_%d [%d:0]  <= epsilonReg_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }else{
            fprintf(OutFileTop, "         epsilonReg2_%d [%d:0] <= epsilonReg_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }
      }
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + epsilonReg3_0, ..., epsilonReg3_20
   //-
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + epsilonReg3_0, ..., epsilonReg3_%d\n", syndromeLength);
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         fprintf(OutFileTop, "   reg [%d:0]   epsilonReg3_%d;\n", bitSymbol-1, ii);
      }
      fprintf(OutFileTop, "\n\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10) {
            fprintf(OutFileTop, "         epsilonReg3_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }else{
            fprintf(OutFileTop, "         epsilonReg3_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
         }
      }

      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");

      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10) {
            fprintf(OutFileTop, "         epsilonReg3_%d [%d:0]  <= epsilonReg2_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }else{
            fprintf(OutFileTop, "         epsilonReg3_%d [%d:0] <= epsilonReg2_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
         }
      }
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + degreeEpsilonReg
   //-
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeEpsilonReg\n");
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg   <= degreeEpsilon;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + degreeEpsilonReg2
   //-
   //------------------------------------------------------------------
   if ((ErasureOption == 1) && ((passFailFlag==1) || (errorStats == 1))) { 
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeEpsilonReg2\n");
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg    [%d:0]   degreeEpsilonReg2;\n", indexSyndrome);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg2   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg2   <= degreeEpsilonReg;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + degreeEpsilonReg3
   //-
   //------------------------------------------------------------------
   if ((ErasureOption == 1) && ((passFailFlag==1) || (errorStats == 1))) { 
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeEpsilonReg3\n");
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg    [%d:0]   degreeEpsilonReg3;\n", indexSyndrome);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg3   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg3   <= degreeEpsilonReg2;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + degreeEpsilonReg4
   //-
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   reg          doneShiftReg;\n");

   if ((ErasureOption == 1) && ((passFailFlag==1) || (errorStats == 1))) { 
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeEpsilonReg4\n");
      fprintf(OutFileTop, "   //-\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg    [%d:0]   degreeEpsilonReg4;\n", indexSyndrome);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg4   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin\n");
      fprintf(OutFileTop, "         degreeEpsilonReg4   <= degreeEpsilonReg3;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + degreeEpsilonReg5
   //-
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   wire         doneChien;\n");

   if (errorStats == 1){
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + degreeEpsilonReg5\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg    [%d:0]   degreeEpsilonReg5;\n", indexSyndrome);
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         degreeEpsilonReg5 [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneChien == 1'b1)) begin\n");
         fprintf(OutFileTop, "         degreeEpsilonReg5   <= degreeEpsilonReg4;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");   
      }
   }

   //------------------------------------------------------------------
   // + numErasureReg
   //-
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   reg [2:0]   doneReg;\n");
   if (errorStats == 1){
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + numErasureReg\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg [%d:0]   numErasureReg;\n", indexSyndrome);
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         numErasureReg   <= %d'd0;\n", indexSyndrome+1);
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin\n");
         fprintf(OutFileTop, "         numErasureReg   <= degreeEpsilonReg5;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");
      }
   }


   //------------------------------------------------------------------------
   // + doneShift
   //------------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + doneShift\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg          doneShift;\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         doneShift <= 1'b0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileTop, "         doneShift <= doneEuclide;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + numShiftedReg
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + numShiftedReg\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg [%d:0]   numShiftedReg;\n", indexSyndrome);
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         numShiftedReg <= %d'd0;\n", indexSyndrome+1);
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");
   fprintf(OutFileTop, "         numShiftedReg <= numShifted;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + lambdaReg_0,..., lambdaReg_xxx
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + lambdaReg_0,..., lambdaReg_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   reg [%d:0]   lambdaReg_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileTop, "   reg [%d:0]   lambdaReg_%d;\n", bitSymbol-1, ii);
   }
   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }


   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0]  <= lambda_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0] <= lambda_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0]  <= lambda_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         lambdaReg_%d [%d:0] <= lambda_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }


   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + omegaReg_0,..., omegaReg_19
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + omegaReg_0,..., omegaReg_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   reg [%d:0]   omegaReg_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "   reg [%d:0]   omegaReg_%d;\n", bitSymbol-1, ii);
   }



   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         omegaReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         omegaReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         omegaReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         omegaReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }


   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         omegaReg_%d [%d:0]  <= omega_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         omegaReg_%d [%d:0] <= omega_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileTop, "         omegaReg_%d [%d:0]  <= omega_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         omegaReg_%d [%d:0] <= omega_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }


   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");

   //------------------------------------------------------------------
   // + omegaShifted_0, ..., omegaShifted_19
   //- Rs Shift Omega
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + omegaShifted_0, ..., omegaShifted_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   //- Rs Shift Omega\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileTop, "    wire [%d:0]   omegaShifted_%d;\n", bitSymbol-1, ii);
   }*/
   if (ErasureOption == 1) {
      shiftPointer = syndromeLength;
   }else{
      shiftPointer = (syndromeLength/2);
   }
   
   for(ii=0; ii<shiftPointer; ii++){
      fprintf(OutFileTop, "    wire [%d:0]   omegaShifted_%d;\n", bitSymbol-1, ii);
   }


   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   RsDecodeShiftOmega RsDecodeShiftOmega(\n");
   fprintf(OutFileTop, "      // Inputs\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10) {
         fprintf(OutFileTop, "      .omega_%d           (omegaReg_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omega_%d          (omegaReg_%d),\n", ii, ii);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii<10) {
         fprintf(OutFileTop, "      .omega_%d           (omegaReg_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omega_%d          (omegaReg_%d),\n", ii, ii);
      }
   }

//   fprintf(OutFileTop, "      .numShifted        (numShiftedReg),\n");
   fprintf(OutFileTop, "      // Outputs\n");

/*   for(ii=0; ii<(syndromeLength-1); ii++){
      if (ii<10) {
         fprintf(OutFileTop, "      .omegaShifted_%d    (omegaShifted_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omegaShifted_%d   (omegaShifted_%d),\n", ii, ii);
      }
   }
   fprintf(OutFileTop, "      .omegaShifted_%d   (omegaShifted_%d)\n", (syndromeLength-1), (syndromeLength-1));
   */
   for(ii=0; ii<shiftPointer; ii++){
      if (ii<10) {
         fprintf(OutFileTop, "      .omegaShifted_%d    (omegaShifted_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omegaShifted_%d   (omegaShifted_%d),\n", ii, ii);
      }
   }


   fprintf(OutFileTop, "      // Inputs\n");
   fprintf(OutFileTop, "      .numShifted        (numShiftedReg)\n");

   fprintf(OutFileTop, "   );\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + omegaShiftedReg_0,.., omegaShiftedReg_19
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + omegaShiftedReg_0,.., omegaShiftedReg_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");

/*   for(ii=0; ii<(syndromeLength); ii++){
      fprintf(OutFileTop, "    reg [%d:0]   omegaShiftedReg_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=0; ii<shiftPointer; ii++){
      fprintf(OutFileTop, "    reg [%d:0]   omegaShiftedReg_%d;\n", bitSymbol-1, ii);
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");

/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii<10) {
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }*/
   for(ii=0; ii<shiftPointer; ii++){
      if (ii<10) {
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");

/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii<10) {
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0]  <= omegaShifted_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0] <= omegaShifted_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }*/
   for(ii=0; ii<(shiftPointer); ii++){
      if (ii<10) {
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0]  <= omegaShifted_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         omegaShiftedReg_%d [%d:0] <= omegaShifted_%d [%d:0];\n", ii, bitSymbol-1, ii, bitSymbol-1);
      }
   }
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + degreeOmega
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeOmega\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");


   if ((syndromeLength/2) > 2047) {
      degreeTemp = 12;
   }
   else if ((syndromeLength/2) > 1023) {
      degreeTemp = 11;
   }
   else if ((syndromeLength/2) > 511) {
      degreeTemp = 10;
   }
   else if ((syndromeLength/2) > 255) {
      degreeTemp = 9;
   }
   else if ((syndromeLength/2) > 127) {
      degreeTemp = 8;
   }
   else if ((syndromeLength/2) > 63) {
      degreeTemp = 7;
   }
   else if ((syndromeLength/2) > 31) {
      degreeTemp = 6;
   }
   else if ((syndromeLength/2) > 15) {
      degreeTemp = 5;
   }
   else if ((syndromeLength/2) > 7) {
      degreeTemp = 4;
   }
   else if ((syndromeLength/2) > 3) {
      degreeTemp = 3;
   }
   else {
      degreeTemp = 2;
   }


   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   wire   [%d:0]   degreeOmega;\n", indexSyndrome);
   }else{
      fprintf(OutFileTop, "   wire   [%d:0]   degreeOmega;\n", degreeTemp-1);
   }
//      fprintf(OutFileTop, "   wire   [%d:0]   degreeOmega;\n", indexSyndrome);


      fprintf(OutFileTop, "\n\n");
      fprintf(OutFileTop, "   RsDecodeDegree  RsDecodeDegree_1(\n");
      fprintf(OutFileTop, "      // Inputs\n");

      for(ii=0; ii<(syndromeLength); ii++){
/*         if (ii<10){
            fprintf(OutFileTop, "      .polynom_%d   (omegaShiftedReg_%d),\n", ii, ii);
         }else{
            fprintf(OutFileTop, "      .polynom_%d  (omegaShiftedReg_%d),\n", ii, ii);
         }*/
         //// temp ////
         if (ii < (shiftPointer)) {
            if (ii<10){
               fprintf(OutFileTop, "      .polynom_%d   (omegaShiftedReg_%d),\n", ii, ii);
            }else{
               fprintf(OutFileTop, "      .polynom_%d  (omegaShiftedReg_%d),\n", ii, ii);
            }
         }else{
            if (ii ==  (shiftPointer)){
               fprintf(OutFileTop, "      .polynom_%d   (%d'd0),\n", ii, bitSymbol);
            }
         }
         //// temp ////
      }
      fprintf(OutFileTop, "      // Outputs\n");
      fprintf(OutFileTop, "      .degree      (degreeOmega)\n");
      fprintf(OutFileTop, "   );\n");
      fprintf(OutFileTop, "\n\n\n");
   }

   //------------------------------------------------------------------
   // + lambdaReg2_0,.., lambdaReg2_19
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + lambdaReg2_0,.., lambdaReg2_%d\n", syndromeLength-1);
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
/*   for(ii=0; ii<(syndromeLength); ii++){
      fprintf(OutFileTop, "   reg [%d:0]   lambdaReg2_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=0; ii<(endPointer); ii++){
      fprintf(OutFileTop, "   reg [%d:0]   lambdaReg2_%d;\n", bitSymbol-1, ii);
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");

/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }*/
   for(ii=0; ii<(endPointer); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }

   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");

/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0]  <= lambdaReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0] <= lambdaReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }*/
   for(ii=0; ii<(endPointer); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0]  <= lambdaReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileTop, "         lambdaReg2_%d [%d:0] <= lambdaReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }

   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + degreeLambda
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeLambda\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
//      fprintf(OutFileTop, "   wire [%d:0]   degreeLambda;\n", indexSyndrome);

      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   wire [%d:0]   degreeLambda;\n", indexSyndrome);
      }else{
         fprintf(OutFileTop, "   wire [%d:0]   degreeLambda;\n", degreeTemp-1);
      }



      fprintf(OutFileTop, "   RsDecodeDegree  RsDecodeDegree_2(\n");
      fprintf(OutFileTop, "      // Inputs\n");

      for(ii=0; ii<(syndromeLength); ii++){
/*         if (ii<10) {
            fprintf(OutFileTop, "      .polynom_%d   (lambdaReg2_%d),\n", ii, ii);
         }else{
            fprintf(OutFileTop, "      .polynom_%d  (lambdaReg2_%d),\n", ii, ii);
         }*/
         //// temp ////
         if (ii < endPointer) {
            if (ii<10) {
               fprintf(OutFileTop, "      .polynom_%d   (lambdaReg2_%d),\n", ii, ii);
            }else{
               fprintf(OutFileTop, "      .polynom_%d  (lambdaReg2_%d),\n", ii, ii);
            }
         }/*else{
            if (ii<10) {
               fprintf(OutFileTop, "      .polynom_%d   (%d'd0),\n", ii, bitSymbol);
            }else{
               fprintf(OutFileTop, "      .polynom_%d  (%d'd0),\n", ii, bitSymbol);
            }
         }*/
         //// temp ////
      }
      fprintf(OutFileTop, "      // Outputs\n");
      fprintf(OutFileTop, "      .degree      (degreeLambda)\n");
      fprintf(OutFileTop, "   );\n");
      fprintf(OutFileTop, "\n\n\n");
   }

   //------------------------------------------------------------------
   // + degreeOmegaReg
   // + degreeLambdaReg
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeOmegaReg\n");
      fprintf(OutFileTop, "   // + degreeLambdaReg\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");

      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   reg [%d:0]   degreeOmegaReg;\n", indexSyndrome);
         fprintf(OutFileTop, "   reg [%d:0]   degreeLambdaReg;\n", indexSyndrome);
      }else{
         fprintf(OutFileTop, "   reg [%d:0]   degreeOmegaReg;\n", degreeTemp-1);
         fprintf(OutFileTop, "   reg [%d:0]   degreeLambdaReg;\n", degreeTemp-1);
      }

//      fprintf(OutFileTop, "   reg [%d:0]   degreeOmegaReg;\n", indexSyndrome);
//      fprintf(OutFileTop, "   reg [%d:0]   degreeLambdaReg;\n", indexSyndrome);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");


//      fprintf(OutFileTop, "         degreeOmegaReg  <= %d'd0;\n", indexSyndrome+1);
//      fprintf(OutFileTop, "         degreeLambdaReg <= %d'd0;\n", indexSyndrome+1);
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         degreeOmegaReg  <= %d'd0;\n", indexSyndrome+1);
         fprintf(OutFileTop, "         degreeLambdaReg <= %d'd0;\n", indexSyndrome+1);
      }else{
         fprintf(OutFileTop, "         degreeOmegaReg  <= %d'd0;\n", degreeTemp);
         fprintf(OutFileTop, "         degreeLambdaReg <= %d'd0;\n", degreeTemp);
      }

      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin\n");
      fprintf(OutFileTop, "         degreeOmegaReg  <= degreeOmega;\n");
      fprintf(OutFileTop, "         degreeLambdaReg <= degreeLambda;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + doneShiftReg
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + doneShiftReg\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         doneShiftReg <= 1'b0;\n");
   fprintf(OutFileTop, "      end \n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileTop, "         doneShiftReg <= doneShift;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + 
   //- RS Chien Search Algorithm
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + \n");
   fprintf(OutFileTop, "   //- RS Chien Search Algorithm\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileTop, "   wire [%d:0]   numErrorChien;\n", indexSyndrome);
   }
   fprintf(OutFileTop, "   wire [%d:0]   error;\n", bitSymbol-1);

   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   wire         delayedErasureIn;\n");
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   RsDecodeChien RsDecodeChien(\n");
   fprintf(OutFileTop, "      // Inputs\n");
   fprintf(OutFileTop, "      .CLK            (CLK),\n");
   fprintf(OutFileTop, "      .RESET          (RESET),\n");
   fprintf(OutFileTop, "      .enable         (enable),\n");
   fprintf(OutFileTop, "      .sync           (doneShiftReg),\n");
   if (ErasureOption == 1) {
      fprintf(OutFileTop, "      .erasureIn      (delayedErasureIn),\n");
   }


/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "      .lambdaIn_%d     (lambdaReg2_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .lambdaIn_%d    (lambdaReg2_%d),\n", ii, ii);
      }
   }*/
   for(ii=0; ii<(endPointer); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "      .lambdaIn_%d     (lambdaReg2_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .lambdaIn_%d    (lambdaReg2_%d),\n", ii, ii);
      }
   }



/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "      .omegaIn_%d      (omegaShiftedReg_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omegaIn_%d     (omegaShiftedReg_%d),\n", ii, ii);
      }
   }*/
   for(ii=0; ii<(shiftPointer); ii++){
      if (ii < 10) {
         fprintf(OutFileTop, "      .omegaIn_%d      (omegaShiftedReg_%d),\n", ii, ii);
      }else{
         fprintf(OutFileTop, "      .omegaIn_%d     (omegaShiftedReg_%d),\n", ii, ii);
      }
   }


   if (ErasureOption == 1) {
      for(ii=0; ii<(syndromeLength+1); ii++){
         if (ii < 10) {
            fprintf(OutFileTop, "      .epsilonIn_%d    (epsilonReg3_%d),\n", ii, ii);
         }else{
            fprintf(OutFileTop, "      .epsilonIn_%d   (epsilonReg3_%d),\n", ii, ii);
         }
      }
   }

   fprintf(OutFileTop, "      // Outputs\n");
   fprintf(OutFileTop, "      .errorOut       (error),\n");
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileTop, "      .numError       (numErrorChien),\n");
   }
   fprintf(OutFileTop, "      .done           (doneChien)\n");
   fprintf(OutFileTop, "   );\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + delayOut
   //- Rs Decode Delay
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + delayOut\n");
   fprintf(OutFileTop, "   //- Rs Decode Delay\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");

   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   wire [%d:0]   delayOut;\n",bitSymbol);
      fprintf(OutFileTop, "   wire [%d:0]   delayIn;\n",bitSymbol);
   }else{
      fprintf(OutFileTop, "   wire [%d:0]   delayOut;\n", bitSymbol-1);
      fprintf(OutFileTop, "   wire [%d:0]   delayIn;\n", bitSymbol-1);
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   RsDecodeDelay  RsDecodeDelay(\n");
   fprintf(OutFileTop, "      // Inputs\n");
   fprintf(OutFileTop, "      .CLK      (CLK),\n");
   fprintf(OutFileTop, "      .RESET    (RESET),\n");
   fprintf(OutFileTop, "      .enable   (enable),\n");
   fprintf(OutFileTop, "      .dataIn   (delayIn),\n");
   fprintf(OutFileTop, "      // Outputs\n");
   fprintf(OutFileTop, "      .dataOut  (delayOut)\n");
   fprintf(OutFileTop, "   );\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + delayIn, delayedErasureIn, delayedDataIn
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + delayIn, delayedErasureIn, delayedDataIn\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   wire [%d:0]   delayedDataIn;\n", bitSymbol-1);

   if (ErasureOption == 1) {
      fprintf(OutFileTop, "   assign   delayIn          = {erasureIn, dataInCheck};\n");
      fprintf(OutFileTop, "   assign   delayedErasureIn = delayOut[%d];\n", bitSymbol);
   }else {
      fprintf(OutFileTop, "   assign   delayIn          = dataInCheck;\n");
   }


   fprintf(OutFileTop, "   assign   delayedDataIn    = delayOut[%d:0];\n", bitSymbol-1);
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------------
   // + OutputValidReg
   //------------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + OutputValidReg\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg         OutputValidReg;\n");
   fprintf(OutFileTop, "   reg [3:0]   startReg;\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         OutputValidReg   <= 1'b0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileTop, "         if (startReg[1] == 1'b1) begin\n");
   fprintf(OutFileTop, "            OutputValidReg   <= 1'b1;\n");
   fprintf(OutFileTop, "         end\n");
   fprintf(OutFileTop, "         else if (doneReg[0] == 1'b1) begin\n");
   fprintf(OutFileTop, "            OutputValidReg   <= 1'b0;\n");
   fprintf(OutFileTop, "         end\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // + startReg, doneReg
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + startReg, doneReg\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         startReg   [3:0] <= 4'd0;\n");
   fprintf(OutFileTop, "         doneReg   [2:0]  <= 3'd0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileTop, "         startReg [3:0] <= {doneShiftReg, startReg[3:1]};\n");
   fprintf(OutFileTop, "         doneReg  [2:0] <= {doneChien, doneReg[2:1]};\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");   



   //------------------------------------------------------------------
   // + numErrorLambdaReg
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + numErrorLambdaReg\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
//      fprintf(OutFileTop, "   reg [%d:0]   numErrorLambdaReg;\n", indexSyndrome);

      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   reg [%d:0]   numErrorLambdaReg;\n", indexSyndrome);
      }else{
         fprintf(OutFileTop, "   reg [%d:0]   numErrorLambdaReg;\n", degreeTemp-1);
      }


      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
//      fprintf(OutFileTop, "         numErrorLambdaReg   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         numErrorLambdaReg   [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      }else{
         fprintf(OutFileTop, "         numErrorLambdaReg   [%d:0] <= %d'd0;\n", degreeTemp-1, degreeTemp);
      }



      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (startReg[1] == 1'b1)) begin\n");
      fprintf(OutFileTop, "         numErrorLambdaReg   <= degreeLambdaReg;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");   
   }


   //------------------------------------------------------------------
   // + degreeErrorReg
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + degreeErrorReg\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg         degreeErrorReg;\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         degreeErrorReg   <= 1'b0;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (startReg[1] == 1'b1)) begin\n");
/*      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) <= ({1'b0, degreeLambdaReg}) + ({1'b0, degreeEpsilonReg4})) begin\n");
      }else {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) <= {1'b0, degreeLambdaReg}) begin\n");
      }*/
/*      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) < ({1'b0, degreeLambdaReg}) + ({1'b0, degreeEpsilonReg4})) begin\n");
      }else {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) < {1'b0, degreeLambdaReg}) begin\n");
      }*/
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) <= ({1'b0, degreeLambdaReg}) + ({1'b0, degreeEpsilonReg4})) begin\n");
      }else {
         fprintf(OutFileTop, "         if (({1'b0, degreeOmegaReg}) <= {1'b0, degreeLambdaReg}) begin\n");
      }
      fprintf(OutFileTop, "            degreeErrorReg   <= 1'b0;\n");
      fprintf(OutFileTop, "         end\n");
/*      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         else if ((degreeOmegaReg == %d'd0) && (degreeLambdaReg == %d'd0) && (degreeEpsilonReg4 == %d'd0)) begin\n", indexSyndrome+1, indexSyndrome+1, indexSyndrome+1);
      }else {
         fprintf(OutFileTop, "         else if ((degreeOmegaReg == %d'd0) && (degreeLambdaReg == %d'd0)) begin\n", indexSyndrome+1, indexSyndrome+1);
      }
      
      
      fprintf(OutFileTop, "            degreeErrorReg   <= 1'b0;\n");
      fprintf(OutFileTop, "         end\n");
      */
      fprintf(OutFileTop, "         else begin\n");
      fprintf(OutFileTop, "            degreeErrorReg   <= 1'b1;\n");
      fprintf(OutFileTop, "         end\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");   
   }

   //------------------------------------------------------------------
   // + numErrorReg
   //------------------------------------------------------------------
   if (errorStats == 1) {
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + numErrorReg\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
//      fprintf(OutFileTop, "   reg    [%d:0]   numErrorReg;\n",indexSyndrome-1);
      fprintf(OutFileTop, "   reg    [%d:0]   numErrorReg;\n",indexSyndrome);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         numErrorReg [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin\n");
      fprintf(OutFileTop, "         numErrorReg [%d:0] <= numErrorChien[%d:0];\n",indexSyndrome,indexSyndrome);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + failErasureReg
   //------------------------------------------------------------------
/*   if (passFailFlag == 1){
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg    [%d:0]   failErasureReg;\n", indexSyndrome);
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg [%d:0] <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && ((doneErasure == 1'b1) || (doneChien == 1'b1))) begin\n");
         fprintf(OutFileTop, "         failErasureReg [%d:0] <= {failErasure, failErasureReg[%d:1]};\n", indexSyndrome, indexSyndrome);
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");
      }
   }*/

   if (passFailFlag == 1){
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg failErasureReg;\n");
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg   <= 1'b0;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneErasure == 1'b1)) begin\n");
         fprintf(OutFileTop, "         failErasureReg   <= failErasure;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");
         
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg2\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg failErasureReg2;\n");
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg2   <= 1'b0;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (donePolymul == 1'b1)) begin\n");
         fprintf(OutFileTop, "         failErasureReg2   <= failErasureReg;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");

         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg3\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg failErasureReg3;\n");
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg3   <= 1'b0;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneEuclide == 1'b1)) begin\n");
         fprintf(OutFileTop, "         failErasureReg3   <= failErasureReg2;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");       

         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg4\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg failErasureReg4;\n");
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg4   <= 1'b0;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneShiftReg == 1'b1)) begin\n");
         fprintf(OutFileTop, "         failErasureReg4   <= failErasureReg3;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");       

         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   // + failErasureReg5\n");
         fprintf(OutFileTop, "   //-\n");
         fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
         fprintf(OutFileTop, "   reg failErasureReg5;\n");
         fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileTop, "      if (~RESET) begin\n");
         fprintf(OutFileTop, "         failErasureReg5   <= 1'b0;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "      else if ((enable == 1'b1) && (startReg[1]  == 1'b1)) begin\n");
         fprintf(OutFileTop, "         failErasureReg5   <= failErasureReg4;\n");
         fprintf(OutFileTop, "      end\n");
         fprintf(OutFileTop, "   end\n");
         fprintf(OutFileTop, "\n\n\n");       


      }
   }


   //------------------------------------------------------------------
   // + failReg
   //------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + failReg\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg          failReg;\n\n");
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         failReg <= 1'b0;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else if ((enable == 1'b1) && (doneReg[0] == 1'b1)) begin\n");
      if (ErasureOption == 1) {
//         fprintf(OutFileTop, "         if ((numErrorLambdaReg == numErrorChien) && (degreeErrorReg == 1'b0) && (failErasureReg[0] == 1'b0)) begin\n");
         fprintf(OutFileTop, "         if ((numErrorLambdaReg == numErrorChien) && (degreeErrorReg == 1'b0) && (failErasureReg5 == 1'b0)) begin\n");
      } else {
         if (indexSyndrome == (degreeTemp-1)) {
            fprintf(OutFileTop, "         if ((numErrorLambdaReg == numErrorChien) && (degreeErrorReg == 1'b0)) begin\n");
         }else{
            fprintf(OutFileTop, "         if (({%d'd0, numErrorLambdaReg} == numErrorChien) && (degreeErrorReg == 1'b0)) begin\n", indexSyndrome - (degreeTemp-1));
         }
      }
      fprintf(OutFileTop, "            failReg <= 1'b0;\n");
      fprintf(OutFileTop, "         end\n");
      fprintf(OutFileTop, "         else begin\n");
      fprintf(OutFileTop, "            failReg <= 1'b1;\n");
      fprintf(OutFileTop, "         end\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }



   //------------------------------------------------------------------
   // + DataOutInner
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // + DataOutInner\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg [%d:0]   DataOutInner;\n", bitSymbol-1);
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         DataOutInner <= %d'd0;\n", bitSymbol);
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else begin\n");
   fprintf(OutFileTop, "         DataOutInner <= delayedDataIn ^ error;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");



   //------------------------------------------------------------------
   // + DelayedDataOutInner
   //------------------------------------------------------------------
   if (delayDataIn == 1){
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   // + DelayedDataOutInner\n");
      fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
      fprintf(OutFileTop, "   reg [%d:0]   DelayedDataOutInner;\n", bitSymbol-1);
      fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileTop, "      if (~RESET) begin\n");
      fprintf(OutFileTop, "         DelayedDataOutInner <= %d'd0;\n", bitSymbol);
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "      else begin\n");
      fprintf(OutFileTop, "         DelayedDataOutInner <= delayedDataIn;\n");
      fprintf(OutFileTop, "      end\n");
      fprintf(OutFileTop, "   end\n");
      fprintf(OutFileTop, "\n\n\n");
   }


   //------------------------------------------------------------------
   //- enableFF
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // - enableFF \n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg       enableFF;\n");
   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         enableFF <= 1'b0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else begin\n");
   fprintf(OutFileTop, "         enableFF <= enable;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   //- FF for outputs
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // - FF for Outputs \n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg         startRegInner;\n");
   fprintf(OutFileTop, "   reg         doneRegInner;\n");
   
   if (errorStats == 1) {
      fprintf(OutFileTop, "   reg [%d:0]   numErrorRegInner;\n", bitSymbol-1);
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   reg [%d:0]   numErasureRegInner;\n", bitSymbol-1);
      }
   }


   if (passFailFlag == 1){
      fprintf(OutFileTop, "   reg         failRegInner;\n");
   }

   fprintf(OutFileTop, "\n\n");
   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         startRegInner       <= 1'b0;\n");
   fprintf(OutFileTop, "         doneRegInner        <= 1'b0;\n");

   if (errorStats == 1) {
      fprintf(OutFileTop, "         numErrorRegInner    <= %d'd0;\n", bitSymbol);
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "         numErasureRegInner  <= %d'd0;\n", bitSymbol);
      }
   }

   if (passFailFlag == 1){
      fprintf(OutFileTop, "         failRegInner        <= 1'b0;\n");
   }
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else begin\n");
   fprintf(OutFileTop, "         startRegInner       <= startReg[0];\n");
   fprintf(OutFileTop, "         doneRegInner        <= doneReg[0];\n");


   if (errorStats == 1) {
//      fprintf(OutFileTop, "         numErrorRegInner    <= { 1'd0, numErrorReg[%d:0]};\n", indexSyndrome-1);
/*      if (indexSyndrome < bitSymbol) { 
         fprintf(OutFileTop, "         numErrorRegInner    <= { %d'd0, numErrorReg[%d:0]};\n", bitSymbol-indexSyndrome, indexSyndrome-1);
      }else{
         fprintf(OutFileTop, "         numErrorRegInner    <= numErrorReg[%d:0];\n", indexSyndrome-1);
      }*/
      if ((indexSyndrome+1) < bitSymbol) { 
         fprintf(OutFileTop, "         numErrorRegInner    <= { %d'd0, numErrorReg[%d:0]};\n", bitSymbol-1-indexSyndrome, indexSyndrome);
      }else{
         fprintf(OutFileTop, "         numErrorRegInner    <= numErrorReg[%d:0];\n", indexSyndrome);
      }
      
      
      
      if (ErasureOption == 1) {
//         fprintf(OutFileTop, "         numErasureRegInner  <= numErasureReg[%d:0];\n", indexSyndrome);
         if ((indexSyndrome+1) < bitSymbol) { 
            fprintf(OutFileTop, "         numErasureRegInner  <= { %d'd0, numErasureReg[%d:0]};\n", bitSymbol-1-indexSyndrome, indexSyndrome);
         }else{
            fprintf(OutFileTop, "         numErasureRegInner  <= numErasureReg[%d:0];\n", indexSyndrome);
         }
      }
   }

   if (passFailFlag == 1){
      fprintf(OutFileTop, "         failRegInner        <= failReg;\n");
   }
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");



   //------------------------------------------------------------------
   //- OutputValidRegInner
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // - OutputValidRegInner \n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   reg         OutputValidRegInner;\n\n");

   fprintf(OutFileTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileTop, "      if (~RESET) begin\n");
   fprintf(OutFileTop, "         OutputValidRegInner <= 1'b0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else if (enableFF == 1'b1) begin\n");
   fprintf(OutFileTop, "         OutputValidRegInner <= OutputValidReg;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "      else begin\n");
   fprintf(OutFileTop, "         OutputValidRegInner <= 1'b0;\n");
   fprintf(OutFileTop, "      end\n");
   fprintf(OutFileTop, "   end\n");
   fprintf(OutFileTop, "\n\n\n");


   //------------------------------------------------------------------
   // - Output Ports
   //------------------------------------------------------------------
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   // - Output Ports\n");
   fprintf(OutFileTop, "   //------------------------------------------------------------------\n");
   fprintf(OutFileTop, "   assign   outEnable   = OutputValidRegInner;\n");
   fprintf(OutFileTop, "   assign   outStartPls = startRegInner;\n");
   fprintf(OutFileTop, "   assign   outDone     = doneRegInner;\n");
   fprintf(OutFileTop, "   assign   outData     = DataOutInner;\n");


   if (errorStats == 1) {
      fprintf(OutFileTop, "   assign   errorNum    = numErrorRegInner;\n");
      if (ErasureOption == 1) {
         fprintf(OutFileTop, "   assign   erasureNum  = numErasureRegInner;\n");
      }
   }

   if (delayDataIn == 1){
      fprintf(OutFileTop, "   assign   delayedData = DelayedDataOutInner;\n");
   }

   if (passFailFlag == 1){
      fprintf(OutFileTop, "   assign   fail        = failRegInner;\n");
   }
   fprintf(OutFileTop, "\n\n"); 
   fprintf(OutFileTop, "endmodule\n");



   //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileTop);


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeTop, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeTop);
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
	remove(strRsDecodeTop);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeTop);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeTop);


}
