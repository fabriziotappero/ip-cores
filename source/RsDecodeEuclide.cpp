//===================================================================
// Module Name : RsDecodeEuclide
// File Name   : RsDecodeEuclide.cpp
// Function    : RTL Decoder Euclide Module generation
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

FILE  *OutFileEuclide;


void RsDecodeEuclide(int DataSize, int TotalSize, int PrimPoly, int ErasureOption, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   int indexErasure;
   int *euclideTab;
   int startPointer;
   int endPointer;
   char *strRsDecodeEuclide;

   syndromeLength = TotalSize - DataSize;

   euclideTab = new int[(syndromeLength+1)];


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


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeEuclide = (char *)calloc(lengthPath + 23,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeEuclide[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeEuclide[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeEuclide, "/rtl/RsDecodeEuclide.v");

   OutFileEuclide = fopen(strRsDecodeEuclide,"w");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileEuclide, "//===================================================================\n");
   fprintf(OutFileEuclide, "// Module Name : RsDecodeEuclide\n");
   fprintf(OutFileEuclide, "// File Name   : RsDecodeEuclide.v\n");
   fprintf(OutFileEuclide, "// Function    : Rs Decoder Euclide algorithm Module\n");
   fprintf(OutFileEuclide, "// \n");
   fprintf(OutFileEuclide, "// Revision History:\n");
   fprintf(OutFileEuclide, "// Date          By           Version    Change Description\n");
   fprintf(OutFileEuclide, "//===================================================================\n");
   fprintf(OutFileEuclide, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileEuclide, "//\n");
   fprintf(OutFileEuclide, "//===================================================================\n");
   fprintf(OutFileEuclide, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileEuclide, "//\n\n\n");

   fprintf(OutFileEuclide, "module RsDecodeEuclide(\n");
   fprintf(OutFileEuclide, "   CLK,           // system clock\n");
   fprintf(OutFileEuclide, "   RESET,         // system reset\n");
   fprintf(OutFileEuclide, "   enable,        // enable signal\n");
   fprintf(OutFileEuclide, "   sync,          // sync signal\n");

   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   syndrome_%d,    // syndrome polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileEuclide, "   syndrome_%d,   // syndrome polynom %d\n", ii, ii);
      }
   }

   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "   numErasure,    // erasure amount\n");
   }

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   lambda_%d,      // lambda polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileEuclide, "   lambda_%d,     // lambda polynom %d\n", ii, ii);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   lambda_%d,      // lambda polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileEuclide, "   lambda_%d,     // lambda polynom %d\n", ii, ii);
      }
   }


/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   omega_%d,       // omega polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileEuclide, "   omega_%d,      // omega polynom %d\n", ii, ii);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   omega_%d,       // omega polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileEuclide, "   omega_%d,      // omega polynom %d\n", ii, ii);
      }
   }


   fprintf(OutFileEuclide, "   numShifted,    // shift amount\n");
   fprintf(OutFileEuclide, "   done           // done signal\n");
   fprintf(OutFileEuclide, ");\n\n\n");

   fprintf(OutFileEuclide, "   input          CLK;           // system clock\n");
   fprintf(OutFileEuclide, "   input          RESET;         // system reset\n");
   fprintf(OutFileEuclide, "   input          enable;        // enable signal\n");
   fprintf(OutFileEuclide, "   input          sync;          // sync signal\n");

   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   input  [%d:0]   syndrome_%d;    // syndrome polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileEuclide, "   input  [%d:0]   syndrome_%d;   // syndrome polynom %d\n", bitSymbol-1, ii, ii);
      }
   }


   //---------------------------------------------------------------
   // index erasure calculation
   //---------------------------------------------------------------
   if (syndromeLength > 2047) {
      indexErasure = 11;
   }
   else if (syndromeLength > 1023) {
      indexErasure = 10;
   }
   else if (syndromeLength > 511) {
      indexErasure = 9;
   }
   else if (syndromeLength > 255) {
      indexErasure = 8;
   }
   else if (syndromeLength > 127) {
      indexErasure = 7;
   }
   else if  (syndromeLength > 63) {
      indexErasure = 6;
   }
   else if  (syndromeLength > 31) {
      indexErasure = 5;
   }
   else if  (syndromeLength > 15) {
      indexErasure = 4;
   }
   else if  (syndromeLength > 7) {
      indexErasure = 3;
   }
   else if  (syndromeLength > 3) {
      indexErasure = 2;
   }
   else {
      indexErasure = 1;
   }


   //---------------------------------------------------------------
   // numErasure input declaration
   //---------------------------------------------------------------
   if (ErasureOption == 1) {
      if (syndromeLength > 2047) {
         fprintf(OutFileEuclide, "   input  [11:0]   numErasure;    // erasure amount\n");
      }
      else if (syndromeLength > 1023) {
         fprintf(OutFileEuclide, "   input  [10:0]   numErasure;    // erasure amount\n");
      }
      else if (syndromeLength > 511) {
         fprintf(OutFileEuclide, "   input  [9:0]   numErasure;    // erasure amount\n");
      }
      else if (syndromeLength > 255) {
         fprintf(OutFileEuclide, "   input  [8:0]   numErasure;    // erasure amount\n");
      }
      else if (syndromeLength > 127) {
         fprintf(OutFileEuclide, "   input  [7:0]   numErasure;    // erasure amount\n");
      }
      else if  (syndromeLength > 63) {
         fprintf(OutFileEuclide, "   input  [6:0]   numErasure;    // erasure amount\n");
      }
      else if  (syndromeLength > 31) {
         fprintf(OutFileEuclide, "   input  [5:0]   numErasure;    // erasure amount\n");
      }
      else if  (syndromeLength > 15) {
         fprintf(OutFileEuclide, "   input  [4:0]   numErasure;    // erasure amount\n");
      }
      else if  (syndromeLength > 7) {
         fprintf(OutFileEuclide, "   input  [3:0]   numErasure;    // erasure amount\n");
      }
      else if  (syndromeLength > 3) {
         fprintf(OutFileEuclide, "   input  [2:0]   numErasure;    // erasure amount\n");
      }
      else {
         fprintf(OutFileEuclide, "   input  [1:0]   numErasure;    // erasure amount\n");
      }
   }

   fprintf(OutFileEuclide, "\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   output [%d:0]   lambda_%d;       // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileEuclide, "   output [%d:0]   lambda_%d;      // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   output [%d:0]   lambda_%d;       // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileEuclide, "   output [%d:0]   lambda_%d;      // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }
   }

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   output [%d:0]   omega_%d;        // omega polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileEuclide, "   output [%d:0]   omega_%d;       // omega polynom %d\n", bitSymbol-1, ii, ii);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEuclide, "   output [%d:0]   omega_%d;        // omega polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileEuclide, "   output [%d:0]   omega_%d;       // omega polynom %d\n", bitSymbol-1, ii, ii);
      }
   }


   fprintf(OutFileEuclide, "   output [%d:0]   numShifted;     // shift amount\n", indexErasure);
   fprintf(OutFileEuclide, "   output         done;           // done signal\n\n\n");
   fprintf(OutFileEuclide, "\n\n\n");


   //------------------------------------------------------------------------
   // -registers
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // -registers\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileEuclide, "   reg [%d:0]   omegaBkp_%d;\n", bitSymbol-1, ii);
   }
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileEuclide, "   reg [%d:0]   lambdaBkp_%d;\n", bitSymbol-1, ii);
   }
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileEuclide, "   reg [%d:0]   lambdaInner_%d;\n", bitSymbol-1, ii);
   }
//   for(ii=0; ii<(syndromeLength-1); ii++){
   for(ii=0; ii<endPointer-1; ii++){
      fprintf(OutFileEuclide, "   reg [%d:0]   lambdaXorReg_%d;\n", bitSymbol-1, ii);
   }
   for(ii=0; ii<(syndromeLength-1); ii++){
      fprintf(OutFileEuclide, "   wire [%d:0]   omegaMultqNew_%d;\n", bitSymbol-1, ii);
   }
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileEuclide, "   wire [%d:0]   lambdaMultqNew_%d;\n", bitSymbol-1, ii);
   }

   fprintf(OutFileEuclide, "   reg  [%d:0]   offset;\n", indexErasure);
   fprintf(OutFileEuclide, "   reg  [%d:0]   numShiftedReg;\n", indexErasure);
   fprintf(OutFileEuclide, "\n\n\n");


   //------------------------------------------------------------------------
   // + phase
   // Counters
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + phase\n");
   fprintf(OutFileEuclide, "   // Counters\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   reg     [1:0]   phase;\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         phase [1:0] <= 2'd0;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileEuclide, "            phase [1:0] <= 2'd1;\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (phase [1:0] == 2'd2) begin\n");
   fprintf(OutFileEuclide, "            phase [1:0] <= 2'd0;\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else begin\n");
   fprintf(OutFileEuclide, "            phase [1:0] <= phase [1:0] + 2'd1;\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n\n");


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


   //------------------------------------------------------------------------
   // + count
   //- Counter
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + count\n");
   fprintf(OutFileEuclide, "   //- Counter\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");

   if (euclideTab [0] > 4095) {
      fprintf(OutFileEuclide, "   reg     [12:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [12:0] <= 13'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [12:0] <= 13'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [12:0]==13'd0) ||  (count [12:0]==13'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [12:0] <= 13'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [12:0] <=  count [12:0] + 13'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   if (euclideTab [0] > 2047) {
      fprintf(OutFileEuclide, "   reg     [11:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [11:0] <= 12'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [11:0] <= 12'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [11:0]==12'd0) ||  (count [11:0]==12'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [11:0] <= 12'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [11:0] <=  count [11:0] + 12'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 1023) {
      fprintf(OutFileEuclide, "   reg     [10:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [10:0] <= 11'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [10:0] <= 11'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [10:0]==11'd0) ||  (count [10:0]==11'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [10:0] <= 11'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [10:0] <=  count [10:0] + 11'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 511) {
      fprintf(OutFileEuclide, "   reg     [9:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [9:0] <= 10'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [9:0] <= 10'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [9:0]==10'd0) ||  (count [9:0]==10'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [9:0] <= 10'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [9:0] <=  count [9:0] + 10'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");      
   }
   else if (euclideTab [0] > 255) {
      fprintf(OutFileEuclide, "   reg     [8:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [8:0] <= 9'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [8:0] <= 9'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [8:0]==9'd0) ||  (count [8:0]==9'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [8:0] <= 9'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [8:0] <=  count [8:0] + 9'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 127) {
      fprintf(OutFileEuclide, "   reg     [7:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [7:0] <= 8'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [7:0] <= 8'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [7:0]==8'd0) ||  (count [7:0]==8'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [7:0] <= 8'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [7:0] <=  count [7:0] + 8'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 63) {
      fprintf(OutFileEuclide, "   reg     [6:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [6:0] <= 7'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [6:0] <= 7'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [6:0]==7'd0) ||  (count [6:0]==7'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [6:0] <= 7'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [6:0] <=  count [6:0] + 7'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 31) {
      fprintf(OutFileEuclide, "   reg     [5:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [5:0] <= 6'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [5:0] <= 6'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [5:0]==6'd0) ||  (count [5:0]==6'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [5:0] <= 6'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [5:0] <=  count [5:0] + 6'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 15) {
      fprintf(OutFileEuclide, "   reg     [4:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [4:0] <= 5'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [4:0] <= 5'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [4:0]==5'd0) ||  (count [4:0]==5'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [4:0] <= 5'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [4:0] <=  count [4:0] + 5'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 7) {
      fprintf(OutFileEuclide, "   reg     [3:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [3:0] <= 4'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [3:0] <= 4'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [3:0]==4'd0) ||  (count [3:0]==4'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [3:0] <= 4'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [3:0] <=  count [3:0] + 4'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else if (euclideTab [0] > 3) {
      fprintf(OutFileEuclide, "   reg     [2:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [2:0] <= 3'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [2:0] <= 3'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [2:0]==3'd0) ||  (count [2:0]==3'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [2:0] <= 3'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [2:0] <=  count [2:0] + 3'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }
   else {
      fprintf(OutFileEuclide, "   reg     [1:0]   count;\n");
      fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileEuclide, "      if (~RESET) begin\n");
      fprintf(OutFileEuclide, "         count [1:0] <= 2'd0;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileEuclide, "            count [1:0] <= 2'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else if ( (count [1:0]==2'd0) ||  (count [1:0]==2'd%d) ) begin\n", euclideTab [0] );
      fprintf(OutFileEuclide, "            count [1:0] <= 2'd0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            count [1:0] <=  count [1:0] + 2'd1;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "   end\n");
   }

   fprintf(OutFileEuclide, "\n\n\n");


   //------------------------------------------------------------------
   // + skip
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + skip\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileEuclide, "   reg [%d:0]   omegaInner_%d;\n", bitSymbol-1, ii);
   }
   fprintf(OutFileEuclide, "   reg         skip;\n");
   fprintf(OutFileEuclide, "\n");

   fprintf(OutFileEuclide, "   always @(omegaInner_%d) begin\n", (syndromeLength-1));
   fprintf(OutFileEuclide, "      if (omegaInner_%d [%d:0] == %d'd0) begin\n",(syndromeLength-1), bitSymbol-1, bitSymbol);
   fprintf(OutFileEuclide, "         skip   = 1'b1;\n");
   fprintf(OutFileEuclide, "      end else begin\n");
   fprintf(OutFileEuclide, "         skip   = 1'b0;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + done\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   reg         done;\n");
   fprintf(OutFileEuclide, "   always @(count) begin\n");

   if (euclideTab [0] > 4095) {
      fprintf(OutFileEuclide, "      if (count[12:0] == 13'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 2047) {
      fprintf(OutFileEuclide, "      if (count[11:0] == 12'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 1023) {
      fprintf(OutFileEuclide, "      if (count[10:0] == 11'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 511) {
      fprintf(OutFileEuclide, "      if (count[9:0] == 10'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 255) {
      fprintf(OutFileEuclide, "      if (count[8:0] == 9'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 127) {
      fprintf(OutFileEuclide, "      if (count[7:0] == 8'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 63) {
      fprintf(OutFileEuclide, "      if (count[6:0] == 7'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 31) {
      fprintf(OutFileEuclide, "      if (count[5:0] == 6'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 15) {
      fprintf(OutFileEuclide, "      if (count[4:0] == 5'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 7) {
      fprintf(OutFileEuclide, "      if (count[3:0] == 4'd%d) begin\n", euclideTab [0]);
   }
   else if (euclideTab [0] > 3) {
      fprintf(OutFileEuclide, "      if (count[2:0] == 3'd%d) begin\n", euclideTab [0]);
   }
   else {
      fprintf(OutFileEuclide, "      if (count[1:0] == 2'd%d) begin\n", euclideTab [0]);
   }

   fprintf(OutFileEuclide, "         done = 1'b1;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else begin\n");
   fprintf(OutFileEuclide, "         done = 1'b0;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + euclideSteps
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
      fprintf(OutFileEuclide, "   // + euclideSteps\n");
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");

      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "   reg     [12:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 13'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");

//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
//            fprintf(OutFileEuclide, "            euclideSteps[12:0] =  13'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[12:0] <=  13'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[12:0] = 13'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[12:0] <= 13'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }

      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "   reg     [11:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 12'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
//            fprintf(OutFileEuclide, "            euclideSteps[11:0] =  12'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[11:0] <=  12'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[11:0] = 12'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[11:0] <= 12'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "   reg     [10:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 11'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
//            fprintf(OutFileEuclide, "            euclideSteps[10:0] =  11'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[10:0] <=  11'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[10:0] = 11'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[10:0] <= 11'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "   reg     [9:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 10'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
//            fprintf(OutFileEuclide, "            euclideSteps[9:0] =  10'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[9:0] <=  10'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[9:0] = 10'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[9:0] <= 10'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "   reg     [8:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 9'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
//            fprintf(OutFileEuclide, "            euclideSteps[8:0] =  9'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[8:0] <=  9'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[8:0] = 9'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[8:0] <= 9'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "   reg     [7:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 8'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[7:0] =  8'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[7:0] <=  8'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[7:0] = 8'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[7:0] <= 8'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "   reg     [6:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 7'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[6:0] =  7'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[6:0] <=  7'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[6:0] = 7'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[6:0] <= 7'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "   reg     [5:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 6'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[5:0] =  6'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[5:0] <=  6'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[5:0] = 6'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[5:0] <= 6'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "   reg     [4:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 5'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[4:0] =  5'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[4:0] <=  5'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[4:0] = 5'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[4:0] <= 5'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "   reg     [3:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 4'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[3:0] =  4'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[3:0] <=  4'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[3:0] = 4'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[3:0] <= 4'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "   reg     [2:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 3'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[2:0] =  3'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[2:0] <=  3'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[2:0] = 3'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[2:0] <= 3'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else {
         fprintf(OutFileEuclide, "   reg     [1:0]   euclideSteps;\n");
//         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
         fprintf(OutFileEuclide, "      if (~RESET) begin\n");
         fprintf(OutFileEuclide, "         euclideSteps <= 2'd0;\n");
         fprintf(OutFileEuclide, "      end\n");
         fprintf(OutFileEuclide, "      else if (sync) begin\n");
//         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
//            fprintf(OutFileEuclide, "            euclideSteps[1:0] =  2'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "            euclideSteps[1:0] <=  2'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
//         fprintf(OutFileEuclide, "            euclideSteps[1:0] = 2'd0;\n");
         fprintf(OutFileEuclide, "            euclideSteps[1:0] <= 2'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      fprintf(OutFileEuclide, "      endcase\n");
      fprintf(OutFileEuclide, "     end\n");
/*      fprintf(OutFileEuclide, "     else begin\n");
      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "        euclideSteps[12:0] = euclideSteps[12:0];\n");
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "        euclideSteps[11:0] = euclideSteps[11:0];\n");
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "        euclideSteps[10:0] = euclideSteps[10:0];\n");
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "        euclideSteps[9:0]  = euclideSteps[9:0];\n");
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "        euclideSteps[8:0]  = euclideSteps[8:0];\n");
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "        euclideSteps[7:0]  = euclideSteps[7:0];\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "        euclideSteps[6:0]  = euclideSteps[6:0];\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "        euclideSteps[5:0]  = euclideSteps[5:0];\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "        euclideSteps[4:0]  = euclideSteps[4:0];\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "        euclideSteps[3:0]  = euclideSteps[3:0];\n");
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "        euclideSteps[2:0]  = euclideSteps[2:0];\n");
      }
      else {
         fprintf(OutFileEuclide, "        euclideSteps[1:0]  = euclideSteps[1:0];\n");
      }

      fprintf(OutFileEuclide, "     end\n");*/





      fprintf(OutFileEuclide, "   end\n");
      fprintf(OutFileEuclide, "\n\n");
   }      
/*   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
      fprintf(OutFileEuclide, "   // + euclideSteps\n");
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");

      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "   reg     [12:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[12:0] =  13'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[12:0] = 13'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "   reg     [11:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[11:0] =  12'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[11:0] = 12'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "   reg     [10:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[10:0] =  11'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[10:0] = 11'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "   reg     [9:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[9:0] =  10'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[9:0] = 10'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "   reg     [8:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[8:0] =  9'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[8:0] = 9'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "   reg     [7:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[7:0] =  8'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[7:0] = 8'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "   reg     [6:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[6:0] =  7'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[6:0] = 7'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "   reg     [5:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[5:0] =  6'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[5:0] = 6'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "   reg     [4:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[4:0] =  5'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[4:0] = 5'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "   reg     [3:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[3:0] =  4'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[3:0] = 4'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "   reg     [2:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[2:0] =  3'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[2:0] = 3'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else {
         fprintf(OutFileEuclide, "   reg     [1:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(sync or numErasure) begin\n");
         fprintf(OutFileEuclide, "     if (sync) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[1:0] =  2'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[1:0] = 2'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      fprintf(OutFileEuclide, "      endcase\n");
      fprintf(OutFileEuclide, "     end\n");
      fprintf(OutFileEuclide, "     else begin\n");
      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "        euclideSteps[12:0] = euclideSteps[12:0];\n");
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "        euclideSteps[11:0] = euclideSteps[11:0];\n");
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "        euclideSteps[10:0] = euclideSteps[10:0];\n");
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "        euclideSteps[9:0]  = euclideSteps[9:0];\n");
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "        euclideSteps[8:0]  = euclideSteps[8:0];\n");
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "        euclideSteps[7:0]  = euclideSteps[7:0];\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "        euclideSteps[6:0]  = euclideSteps[6:0];\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "        euclideSteps[5:0]  = euclideSteps[5:0];\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "        euclideSteps[4:0]  = euclideSteps[4:0];\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "        euclideSteps[3:0]  = euclideSteps[3:0];\n");
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "        euclideSteps[2:0]  = euclideSteps[2:0];\n");
      }
      else {
         fprintf(OutFileEuclide, "        euclideSteps[1:0]  = euclideSteps[1:0];\n");
      }

      fprintf(OutFileEuclide, "     end\n");





      fprintf(OutFileEuclide, "   end\n");
      fprintf(OutFileEuclide, "\n\n");
   }   */
   
/*   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
      fprintf(OutFileEuclide, "   // + euclideSteps\n");
      fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");

      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "   reg     [12:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[12:0] =  13'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[12:0] = 13'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "   reg     [11:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[11:0] =  12'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[11:0] = 12'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "   reg     [10:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[10:0] =  11'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[10:0] = 11'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "   reg     [9:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[9:0] =  10'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[9:0] = 10'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "   reg     [8:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1),ii);
            fprintf(OutFileEuclide, "            euclideSteps[8:0] =  9'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[8:0] = 9'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "   reg     [7:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[7:0] =  8'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[7:0] = 8'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "   reg     [6:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[6:0] =  7'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[6:0] = 7'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "   reg     [5:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[5:0] =  6'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[5:0] = 6'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "   reg     [4:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[4:0] =  5'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[4:0] = 5'd0;\n");
         fprintf(OutFileEuclide, "         end\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "   reg     [3:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[3:0] =  4'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[3:0] = 4'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "   reg     [2:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[2:0] =  3'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[2:0] = 3'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      else {
         fprintf(OutFileEuclide, "   reg     [1:0]   euclideSteps;\n");
         fprintf(OutFileEuclide, "   always @(numErasure ) begin\n");
         fprintf(OutFileEuclide, "      case (numErasure[%d:0])\n", indexErasure);
         for(ii=0; ii<(syndromeLength+1); ii++){
            fprintf(OutFileEuclide, "         %d'd%d: begin\n", (indexErasure+1), ii);
            fprintf(OutFileEuclide, "            euclideSteps[1:0] =  2'd%d; // step: %d\n", euclideTab[ii], ii);
            fprintf(OutFileEuclide, "         end\n");
         }
         fprintf(OutFileEuclide, "         default: begin\n");
         fprintf(OutFileEuclide, "            euclideSteps[1:0] = 2'd0;\n");
         fprintf(OutFileEuclide, "         end\n");   
      }
      fprintf(OutFileEuclide, "      endcase\n");
      fprintf(OutFileEuclide, "   end\n");
      fprintf(OutFileEuclide, "\n\n");
   }*/


   //------------------------------------------------------------------
   // + enable_E
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + enable_E\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   reg          enable_E;\n");

   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "   always @(sync or count or enable or numErasure or euclideSteps) begin\n");
   } else {
//      fprintf(OutFileEuclide, "   always @(sync or count or enable) begin\n");
      fprintf(OutFileEuclide, "   always @(enable) begin\n");
   }


   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "      if (numErasure[%d:0] <= %d'd%d) begin\n", indexErasure, indexErasure+1, syndromeLength);
   }

   if (ErasureOption == 1) {
      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[12:0] <= euclideSteps[12:0])) begin\n");
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[11:0] <= euclideSteps[11:0])) begin\n");
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[10:0] <= euclideSteps[10:0])) begin\n");
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[9:0] <= euclideSteps[9:0])) begin\n");
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[8:0] <= euclideSteps[8:0])) begin\n");
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[7:0] <= euclideSteps[7:0])) begin\n");
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[6:0] <= euclideSteps[6:0])) begin\n");
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[5:0] <= euclideSteps[5:0])) begin\n");
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[4:0] <= euclideSteps[4:0])) begin\n");
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[3:0] <= euclideSteps[3:0])) begin\n");
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[2:0] <= euclideSteps[2:0])) begin\n");
      }
      else {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[1:0] <= euclideSteps[1:0])) begin\n");
      }
   }/*else {
      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[12:0] <= 13'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[11:0] <= 12'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[10:0] <= 11'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[9:0] <= 10'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[8:0] <= 9'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[7:0] <= 8'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[6:0] <= 7'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[5:0] <= 6'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[4:0] <= 5'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[3:0] <= 4'd%d)) begin\n", euclideTab[0]);
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[2:0] <= 3'd%d)) begin\n", euclideTab[0]);
      }
      else {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[1:0] <= 2'd%d)) begin\n", euclideTab[0]);
      }
   }*/

   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "            enable_E   = enable;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            enable_E   = 1'b0;\n");
      fprintf(OutFileEuclide, "         end\n");
   }else{
/*      fprintf(OutFileEuclide, "         enable_E   = enable;\n");
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else begin\n");
      fprintf(OutFileEuclide, "         enable_E   = 1'b0;\n");
      fprintf(OutFileEuclide, "      end\n");*/
      fprintf(OutFileEuclide, "      enable_E   = enable;\n");      
   }
   if (ErasureOption == 1) {
      fprintf(OutFileEuclide, "      end\n");
      fprintf(OutFileEuclide, "      else begin\n");
      if (euclideTab [0] > 4095) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[12:0] <= 13'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 2047) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[11:0] <= 12'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 1023) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[10:0] <= 11'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 511) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[9:0] <= 10'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 255) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[8:0] <= 9'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 127) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[7:0] <= 8'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 63) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[6:0] <= 7'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 31) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[5:0] <= 6'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 15) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[4:0] <= 5'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 7) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[3:0] <= 4'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else if (euclideTab [0] > 3) {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[2:0] <= 3'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      else {
         fprintf(OutFileEuclide, "         if ((sync == 1'b1) || (count[1:0] <= 2'd3)) begin\n", euclideTab[(syndromeLength)]);
      }
      fprintf(OutFileEuclide, "            enable_E   = enable;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "         else begin\n");
      fprintf(OutFileEuclide, "            enable_E   = 1'b0;\n");
      fprintf(OutFileEuclide, "         end\n");
      fprintf(OutFileEuclide, "      end\n");
   }
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   // Get Partial Q
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // Get Partial Q\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   wire   [%d:0]   omegaInv;\n",bitSymbol-1);
   fprintf(OutFileEuclide, "   reg    [%d:0]   omegaInvReg;\n",bitSymbol-1);
   fprintf(OutFileEuclide, "   wire   [%d:0]   qNew;\n",bitSymbol-1);
   fprintf(OutFileEuclide, "   reg    [%d:0]   qNewReg;\n",bitSymbol-1);
   fprintf(OutFileEuclide, "   reg    [%d:0]   omegaBkpReg;\n\n",bitSymbol-1);
   fprintf(OutFileEuclide, "   RsDecodeInv RsDecodeInv_Q (.B(omegaInner_%d[%d:0]), .R(omegaInv[%d:0]));\n", (syndromeLength-1),bitSymbol-1,bitSymbol-1);
   fprintf(OutFileEuclide, "   RsDecodeMult RsDecodeMult_Q (.A(omegaBkpReg[%d:0]), .B(omegaInvReg[%d:0]), .P(qNew[%d:0]) );\n",bitSymbol-1,bitSymbol-1,bitSymbol-1);
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + omegaInvReg
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + omegaInvReg\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
//   fprintf(OutFileEuclide, "   always @(posedge CLK) begin\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         omegaInvReg   <= %d'd0;\n", bitSymbol);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         omegaInvReg   <= omegaInv;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + omegaBkpReg
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + omegaBkpReg\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
//   fprintf(OutFileEuclide, "   always @(posedge CLK) begin\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         omegaBkpReg   <= %d'd0;\n", bitSymbol);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         omegaBkpReg   <= omegaBkp_%d[%d:0];\n", (syndromeLength-1),bitSymbol-1);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + qNewReg
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + qNewReg\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
//   fprintf(OutFileEuclide, "   always @(posedge CLK) begin\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         qNewReg   <= %d'd0;\n", bitSymbol);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         qNewReg   <= qNew;\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   // + omegaMultqNew_0,..., omegaMultqNew_18
   //- QT = qNewReg * T_REG
   //- Multipliers
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + omegaMultqNew_0,..., omegaMultqNew_18\n");
   fprintf(OutFileEuclide, "   //- QT = qNewReg * omegaInner\n");
   fprintf(OutFileEuclide, "   //- Multipliers\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   for(ii=0; ii<(syndromeLength-1); ii++){
      fprintf(OutFileEuclide, "   RsDecodeMult   RsDecodeMult_PDIV%d (.A(qNewReg[%d:0]), .B(omegaInner_%d[%d:0]), .P(omegaMultqNew_%d[%d:0]) );\n", ii,bitSymbol-1, ii,bitSymbol-1, ii,bitSymbol-1);
   }
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   // + lambdaMultqNew_0, ..., QA_19
   //- QA22 = qNewReg * A22_REG
   //- Multipliers
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + lambdaMultqNew_0, ..., QA_19\n");
   fprintf(OutFileEuclide, "   //- QA22 = qNewReg * lambdaInner\n");
   fprintf(OutFileEuclide, "   //- Multipliers\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileEuclide, "   RsDecodeMult   RsDecodeMult_PMUL%d (.A(qNewReg[%d:0]), .B(lambdaInner_%d[%d:0]), .P(lambdaMultqNew_%d[%d:0]) );\n", ii,bitSymbol-1, ii,bitSymbol-1, ii,bitSymbol-1);
   }
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   // + omegaBkp_0, ..., omegaBkp_19
   //- Registers
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + omegaBkp_0, ..., omegaBkp_19\n");
   fprintf(OutFileEuclide, "   //- Registers\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "      always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "         if (~RESET) begin\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            omegaBkp_%d [%d:0]   <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "            omegaBkp_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "            if (sync == 1'b1) begin\n");
   for(ii=0; ii<(syndromeLength-1); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "                omegaBkp_%d [%d:0]   <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "                omegaBkp_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "                omegaBkp_%d[%d:0]   <= %d'd1;\n", (syndromeLength-1),bitSymbol-1,bitSymbol);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else if (phase[1:0] == 2'b00) begin\n");
   fprintf(OutFileEuclide, "               if ((skip== 1'b0) && (offset == %d'd0)) begin\n", indexErasure+1);

   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "                  omegaBkp_%d [%d:0]   <= omegaInner_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "                  omegaBkp_%d [%d:0]  <= omegaInner_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "               end\n");
   fprintf(OutFileEuclide, "               else if (skip== 1'b0) begin\n");
   fprintf(OutFileEuclide, "                  omegaBkp_0 [%d:0]   <= %d'd0;\n",bitSymbol-1,bitSymbol);
   for(ii=1; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "                  omegaBkp_%d [%d:0]   <= omegaMultqNew_%d[%d:0] ^ omegaBkp_%d[%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, (ii-1),bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "                  omegaBkp_%d [%d:0]  <= omegaMultqNew_%d[%d:0] ^ omegaBkp_%d[%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, (ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "               end\n");
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + omegaInner register
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // +omegaInner\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "         omegaInner_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "         omegaInner_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            omegaInner_%d [%d:0]  <= syndrome_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "            omegaInner_%d [%d:0] <= syndrome_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (phase == 2'b00) begin\n");
   fprintf(OutFileEuclide, "            if ((skip == 1'b0) && (offset == %d'd0)) begin\n", indexErasure+1);
   fprintf(OutFileEuclide, "               omegaInner_0 [%d:0]  <= %d'd0;\n",bitSymbol-1,bitSymbol);
   for(ii=1; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "               omegaInner_%d [%d:0]  <= omegaMultqNew_%d [%d:0] ^ omegaBkp_%d [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, (ii-1),bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "               omegaInner_%d [%d:0] <= omegaMultqNew_%d [%d:0] ^ omegaBkp_%d [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, (ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else if (skip == 1'b1) begin\n");
   fprintf(OutFileEuclide, "               omegaInner_0 [%d:0]  <= %d'd0;\n",bitSymbol-1,bitSymbol);
   for(ii=1; ii<syndromeLength; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "               omegaInner_%d [%d:0]  <= omegaInner_%d [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "               omegaInner_%d [%d:0] <= omegaInner_%d [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + lambdaBkp_0,..,lambdaBkp_xxx registers
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + lambdaBkp_0,..,lambdaBkp_%d\n", syndromeLength-1);
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "         lambdaBkp_%d [%d:0]   <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "         lambdaBkp_%d [%d:0]  <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            lambdaBkp_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "            lambdaBkp_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if ((phase == 2'b00) && (skip == 1'b0) && (offset == %d'd0)) begin\n", indexErasure+1);
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            lambdaBkp_%d [%d:0]  <= lambdaInner_%d[%d:0];\n", ii,bitSymbol-1 , ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "            lambdaBkp_%d [%d:0] <= lambdaInner_%d[%d:0];\n", ii,bitSymbol-1 , ii,bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + lambdaInner_0, lambdaInner_xxx
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + lambdaInner_0, lambdaInner_%d\n", syndromeLength-1);
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "         lambdaInner_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "         lambdaInner_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileEuclide, "            lambdaInner_0 [%d:0]  <= %d'd1;\n",bitSymbol-1,bitSymbol);
//   for(ii=1; ii<syndromeLength; ii++){
   for(ii=1; ii<endPointer; ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            lambdaInner_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "            lambdaInner_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if ((phase[1:0] == 2'b00) && (skip == 1'b0) && (offset== %d'd0)) begin\n", indexErasure+1);
   fprintf(OutFileEuclide, "            lambdaInner_0 [%d:0]  <= lambdaBkp_0 [%d:0] ^ lambdaMultqNew_0 [%d:0];\n",bitSymbol-1,bitSymbol-1,bitSymbol-1);
//   for(ii=1; ii<syndromeLength; ii++){
   for(ii=1; ii<endPointer; ii++){
      if (ii<10){
      fprintf(OutFileEuclide, "            lambdaInner_%d [%d:0]  <= lambdaBkp_%d [%d:0] ^ lambdaMultqNew_%d [%d:0] ^ lambdaXorReg_%d [%d:0];\n", ii,bitSymbol-1 ,ii ,bitSymbol-1, ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }else{
      fprintf(OutFileEuclide, "            lambdaInner_%d [%d:0] <= lambdaBkp_%d [%d:0] ^ lambdaMultqNew_%d [%d:0] ^ lambdaXorReg_%d [%d:0];\n", ii,bitSymbol-1 ,ii,bitSymbol-1 , ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + lambdaXorReg_0,..., lambdaXorReg_xxx
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + lambdaXorReg_0,..., lambdaXorReg_%d\n", syndromeLength);
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
//   for(ii=0; ii<(syndromeLength-1); ii++){
   for(ii=0; ii<(endPointer-1); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "         lambdaXorReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "         lambdaXorReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
//   for(ii=0; ii<(syndromeLength-1); ii++){
   for(ii=0; ii<(endPointer-1); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "            lambdaXorReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "            lambdaXorReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (phase == 2'b00) begin\n");
   fprintf(OutFileEuclide, "            if ((skip == 1'b0) && (offset == %d'd0)) begin\n", indexErasure+1);

//   for(ii=0; ii<(syndromeLength-1); ii++){
   for(ii=0; ii<(endPointer-1); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "               lambdaXorReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }else{
         fprintf(OutFileEuclide, "               lambdaXorReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1 ,bitSymbol);
      }
   }
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else if (skip == 1'b0) begin\n");
   fprintf(OutFileEuclide, "               lambdaXorReg_0 [%d:0]  <= lambdaMultqNew_0 [%d:0];\n",bitSymbol-1,bitSymbol-1);
//   for(ii=1; ii<(syndromeLength-1); ii++){
   for(ii=1; ii<(endPointer-1); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "               lambdaXorReg_%d [%d:0]  <= lambdaMultqNew_%d [%d:0] ^ lambdaXorReg_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "               lambdaXorReg_%d [%d:0] <= lambdaMultqNew_%d [%d:0] ^ lambdaXorReg_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1, (ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + offset
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + offset\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         offset [%d:0] <= %d'd0;\n", indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileEuclide, "            offset [%d:0] <= %d'd1;\n", indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (phase [1:0] == 2'b00) begin\n");
   fprintf(OutFileEuclide, "            if ((skip == 1'b0) && (offset[%d:0]==%d'd0)) begin\n", indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "               offset [%d:0] <= %d'd1;\n", indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else if (skip == 1'b1) begin\n");
   fprintf(OutFileEuclide, "               offset [%d:0] <= offset [%d:0] + %d'd1;\n", indexErasure, indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else begin\n");
   fprintf(OutFileEuclide, "               offset [%d:0] <= offset [%d:0] - %d'd1;\n", indexErasure, indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------
   // + numShiftedReg
   //------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   // + numShiftedReg\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEuclide, "      if (~RESET) begin\n");
   fprintf(OutFileEuclide, "         numShiftedReg   [%d:0] <= %d'd0;\n", indexErasure, indexErasure+1);
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "      else if (enable_E == 1'b1) begin\n");
   fprintf(OutFileEuclide, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileEuclide, "            numShiftedReg   <= %d'd0;\n", indexErasure+1);
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "         else if (phase == 2'd0) begin\n");
   fprintf(OutFileEuclide, "            if ((skip == 1'b0) && (offset == %d'd0)) begin\n", indexErasure+1);
   fprintf(OutFileEuclide, "               numShiftedReg   <= numShiftedReg + %d'd1;\n", indexErasure+1);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "            else if (skip == 1'b1) begin\n");
   fprintf(OutFileEuclide, "               numShiftedReg   <= numShiftedReg + %d'd1;\n", indexErasure+1);
   fprintf(OutFileEuclide, "            end\n");
   fprintf(OutFileEuclide, "         end\n");
   fprintf(OutFileEuclide, "      end\n");
   fprintf(OutFileEuclide, "   end\n");
   fprintf(OutFileEuclide, "\n\n");


   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileEuclide, "   //- OutputPorts\n");
   fprintf(OutFileEuclide, "   //------------------------------------------------------------------------\n");




/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "   assign lambda_%d [%d:0]  = lambdaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "   assign lambda_%d [%d:0] = lambdaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
*/


for(ii=0; ii<(endPointer); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "   assign lambda_%d [%d:0]  = lambdaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "   assign lambda_%d [%d:0] = lambdaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }


   fprintf(OutFileEuclide, "\n");


/*   for(ii=0; ii<(syndromeLength); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "   assign omega_%d [%d:0]  = omegaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "   assign omega_%d [%d:0] = omegaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
*/
   for(ii=startPointer; ii<(syndromeLength); ii++){
      if (ii<10){
         fprintf(OutFileEuclide, "   assign omega_%d [%d:0]  = omegaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFileEuclide, "   assign omega_%d [%d:0] = omegaInner_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }



   fprintf(OutFileEuclide, "   assign numShifted     = numShiftedReg;\n");
   fprintf(OutFileEuclide, "\n\n");
   fprintf(OutFileEuclide, "endmodule\n");


   //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileEuclide);


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
	ifstream fp_read(strRsDecodeEuclide, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeEuclide);
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
	remove(strRsDecodeEuclide);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeEuclide);
	//Delete the temporary file.
	remove(temp);


   
   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeEuclide);


}
