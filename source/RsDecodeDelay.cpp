//===================================================================
// Module Name : RsDecodeDelay
// File Name   : RsDecodeDelay.cpp
// Function    : RTL Decoder Delay Module generation
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

FILE  *OutFileDelay;


void RsDecodeDelay(int DataSize, int TotalSize, int PrimPoly, int ErasureOption, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {

   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   syndromeLength = TotalSize - DataSize;

   int ii;
   int Delay;
   int *euclideTab;
   char *strRsDecodeDelay;

   euclideTab    =new int[(syndromeLength+1)];


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeDelay = (char *)calloc(lengthPath + 21,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeDelay[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeDelay[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeDelay, "/rtl/RsDecodeDelay.v");

   OutFileDelay = fopen(strRsDecodeDelay,"w");




   //---------------------------------------------------------------
   // write Header File
   //---------------------------------------------------------------
   fprintf(OutFileDelay, "//===================================================================\n");
   fprintf(OutFileDelay, "// Module Name : RsDecodeDelay\n");
   fprintf(OutFileDelay, "// File Name   : RsDecodeDelay.v\n");
   fprintf(OutFileDelay, "// Function    : Rs DpRam Memory controller Module\n");
   fprintf(OutFileDelay, "// \n");
   fprintf(OutFileDelay, "// Revision History:\n");
   fprintf(OutFileDelay, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDelay, "//===================================================================\n");
   fprintf(OutFileDelay, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDelay, "//\n");
   fprintf(OutFileDelay, "//===================================================================\n");
   fprintf(OutFileDelay, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDelay, "//\n\n\n");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDelay, "module RsDecodeDelay(\n");
   fprintf(OutFileDelay, "   CLK,      // system clock\n");
   fprintf(OutFileDelay, "   RESET,    // system reset\n");
   fprintf(OutFileDelay, "   enable,   // enable signal\n");
   fprintf(OutFileDelay, "   dataIn,   // data input\n");
   fprintf(OutFileDelay, "   dataOut   // data output\n");
   fprintf(OutFileDelay, ");\n");
   fprintf(OutFileDelay, "\n");


   //---------------------------------------------------------------
   // I/O instantiation
   //---------------------------------------------------------------
   fprintf(OutFileDelay, "   input          CLK;       // system clock\n");
   fprintf(OutFileDelay, "   input          RESET;     // system reset\n");
   fprintf(OutFileDelay, "   input          enable;    // enable signal\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDelay, "   input  [%d:0]   dataIn;    // data input\n", bitSymbol);
      fprintf(OutFileDelay, "   output [%d:0]   dataOut;   // data output\n", bitSymbol);
   } else {
      fprintf(OutFileDelay, "   input  [%d:0]   dataIn;    // data input\n", bitSymbol-1);
      fprintf(OutFileDelay, "   output [%d:0]   dataOut;   // data output\n", bitSymbol-1);
   }

   fprintf(OutFileDelay, "\n\n\n");


   //------------------------------------------------------------------------
   //- euclideTab calculation
   //------------------------------------------------------------------------
   euclideTab [syndromeLength] = 3;
   euclideTab [syndromeLength-1] = 3;

   for(ii=(syndromeLength-2); ii>0; ii=ii-2){
      euclideTab [ii] = euclideTab   [ii+2] + 6;
      euclideTab [ii-1] = euclideTab [ii+1] + 6;
   }

   euclideTab [0] = euclideTab [2] + 6;

   if (ErasureOption == 1) {
      Delay = TotalSize + syndromeLength + 1 + euclideTab [0] + 5;
   }else{
      Delay = TotalSize + euclideTab [0] + 5;
   }


   //------------------------------------------------------------------------
   //- registers
   //------------------------------------------------------------------------
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   //- registers\n");
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");

   if (Delay < 4) {
      fprintf(OutFileDelay, "   reg  [1:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [1:0]   readPointer;\n");
   }
   else if (Delay < 8) {
      fprintf(OutFileDelay, "   reg  [2:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [2:0]   readPointer;\n");
   }
   else if (Delay < 16) {
      fprintf(OutFileDelay, "   reg  [3:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [3:0]   readPointer;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDelay, "   reg  [4:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [4:0]   readPointer;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDelay, "   reg  [5:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [5:0]   readPointer;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDelay, "   reg  [6:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [6:0]   readPointer;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDelay, "   reg  [7:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [7:0]   readPointer;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDelay, "   reg  [8:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [8:0]   readPointer;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDelay, "   reg  [9:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [9:0]   readPointer;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDelay, "   reg  [10:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [10:0]   readPointer;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDelay, "   reg  [11:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [11:0]   readPointer;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDelay, "   reg  [12:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [12:0]   readPointer;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDelay, "   reg  [13:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [13:0]   readPointer;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDelay, "   reg  [14:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [14:0]   readPointer;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDelay, "   reg  [15:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [15:0]   readPointer;\n");
   }
   else {
      fprintf(OutFileDelay, "   reg  [16:0]   writePointer;\n");
      fprintf(OutFileDelay, "   reg  [16:0]   readPointer;\n");
   }


   if (ErasureOption == 1) {
      fprintf(OutFileDelay, "   wire [%d:0]   dpramRdData;\n", bitSymbol);
   } else {
      fprintf(OutFileDelay, "   wire [%d:0]   dpramRdData;\n", bitSymbol-1);
   }
   fprintf(OutFileDelay, "\n\n\n");


   //------------------------------------------------------------------------
   //- RAM memory instantiation
   //------------------------------------------------------------------------
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   //- RAM memory instantiation\n");
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   RsDecodeDpRam RsDecodeDpRam(\n");
   fprintf(OutFileDelay, "      // Outputs\n");
   fprintf(OutFileDelay, "      .q(dpramRdData),\n");
   fprintf(OutFileDelay, "      // Inputs\n");
   fprintf(OutFileDelay, "      .clock(CLK),\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDelay, "      .data(dataIn [%d:0]),\n", bitSymbol);
   } else {
      fprintf(OutFileDelay, "      .data(dataIn [%d:0]),\n", bitSymbol-1);
   }
   fprintf(OutFileDelay, "      .rdaddress(readPointer),\n");
   fprintf(OutFileDelay, "      .rden(enable),\n");
   fprintf(OutFileDelay, "      .wraddress(writePointer),\n");
   fprintf(OutFileDelay, "      .wren(enable)\n");
   fprintf(OutFileDelay, "   );\n");
   fprintf(OutFileDelay, "\n\n\n");


   //------------------------------------------------------------------------
   //- dataOut
   //------------------------------------------------------------------------
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   //+ dataOut\n");
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDelay, "   assign dataOut[%d:0] = dpramRdData;\n", bitSymbol);
   } else {
      fprintf(OutFileDelay, "   assign dataOut[%d:0] = dpramRdData;\n", bitSymbol-1);
   }
   fprintf(OutFileDelay, "\n\n\n");


   //------------------------------------------------------------------------
   //- Write Pointer
   //------------------------------------------------------------------------
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   //- Write Pointer\n");
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDelay, "      if (~RESET) begin\n");

   if (Delay < 4) {
      fprintf(OutFileDelay, "         writePointer   <= 2'd%d;\n", (Delay-1));
   }
   else if (Delay < 8) {
      fprintf(OutFileDelay, "         writePointer   <= 3'd%d;\n", (Delay-1));
   }
   else if (Delay < 16) {
      fprintf(OutFileDelay, "         writePointer   <= 4'd%d;\n", (Delay-1));
   }
   else if (Delay < 32) {
      fprintf(OutFileDelay, "         writePointer   <= 5'd%d;\n", (Delay-1));
   }
   else if (Delay < 64) {
      fprintf(OutFileDelay, "         writePointer   <= 6'd%d;\n", (Delay-1));
   }
   else if (Delay < 128) {
      fprintf(OutFileDelay, "         writePointer   <= 7'd%d;\n", (Delay-1));
   }
   else if (Delay < 256) {
      fprintf(OutFileDelay, "         writePointer   <= 8'd%d;\n", (Delay-1));
   }
   else if (Delay < 512) {
      fprintf(OutFileDelay, "         writePointer   <= 9'd%d;\n", (Delay-1));
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDelay, "         writePointer   <= 10'd%d;\n", (Delay-1));
    }
   else if  (Delay < 2048) {
      fprintf(OutFileDelay, "         writePointer   <= 11'd%d;\n", (Delay-1));
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDelay, "         writePointer   <= 12'd%d;\n", (Delay-1));
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDelay, "         writePointer   <= 13'd%d;\n", (Delay-1));
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDelay, "         writePointer   <= 14'd%d;\n", (Delay-1));
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDelay, "         writePointer   <= 14'd%d;\n", (Delay-1));
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDelay, "         writePointer   <= 15'd%d;\n", (Delay-1));
   }
   else {
      fprintf(OutFileDelay, "         writePointer   <= 16'd%d;\n", (Delay-1));
   }
   fprintf(OutFileDelay, "      end\n");
   fprintf(OutFileDelay, "      else if (enable == 1'b1) begin\n");


   if (Delay < 4) {
      fprintf(OutFileDelay, "         if (writePointer == 2'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 2'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 2'd1;\n");
   }
   else if (Delay < 8) {
      fprintf(OutFileDelay, "         if (writePointer == 3'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 3'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 3'd1;\n");
   }
   else if (Delay < 16) {
      fprintf(OutFileDelay, "         if (writePointer == 4'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 4'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 4'd1;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDelay, "         if (writePointer == 5'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 5'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 5'd1;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDelay, "         if (writePointer == 6'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 6'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 6'd1;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDelay, "         if (writePointer == 7'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 7'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 7'd1;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDelay, "         if (writePointer == 8'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 8'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 8'd1;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDelay, "         if (writePointer == 9'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 9'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 9'd1;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDelay, "         if (writePointer == 10'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 10'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 10'd1;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDelay, "         if (writePointer == 11'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 11'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 11'd1;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDelay, "         if (writePointer == 12'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 12'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 12'd1;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDelay, "         if (writePointer == 13'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 13'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 13'd1;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDelay, "         if (writePointer == 14'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 14'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 14'd1;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDelay, "         if (writePointer == 15'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 15'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 15'd1;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDelay, "         if (writePointer == 16'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 16'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 16'd1;\n");
   }
   else {
      fprintf(OutFileDelay, "         if (writePointer == 17'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            writePointer <= 17'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            writePointer <= writePointer + 17'd1;\n");
   }

   fprintf(OutFileDelay, "         end\n");
   fprintf(OutFileDelay, "      end\n");
   fprintf(OutFileDelay, "   end\n");
   fprintf(OutFileDelay, "\n\n\n");


   //------------------------------------------------------------------------
   //- Read Pointer
   //------------------------------------------------------------------------
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   //- Read Pointer\n");
   fprintf(OutFileDelay, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDelay, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDelay, "      if (~RESET) begin\n");

   if (Delay < 4) {
      fprintf(OutFileDelay, "         readPointer  [1:0] <= 2'd0;\n");
   }
   else if (Delay < 8) {
      fprintf(OutFileDelay, "         readPointer  [2:0] <= 3'd0;\n");
   }
   else if (Delay < 16) {
      fprintf(OutFileDelay, "         readPointer  [3:0] <= 4'd0;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDelay, "         readPointer  [4:0] <= 5'd0;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDelay, "         readPointer  [5:0] <= 6'd0;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDelay, "         readPointer  [6:0] <= 7'd0;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDelay, "         readPointer  [7:0] <= 8'd0;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDelay, "         readPointer  [8:0] <= 9'd0;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDelay, "         readPointer  [9:0] <= 10'd0;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDelay, "         readPointer  [10:0] <= 11'd0;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDelay, "         readPointer  [11:0] <= 12'd0;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDelay, "         readPointer  [12:0] <= 13'd0;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDelay, "         readPointer  [13:0] <= 14'd0;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDelay, "         readPointer  [14:0] <= 15'd0;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDelay, "         readPointer  [15:0] <= 16'd0;\n");
   }
   else {
      fprintf(OutFileDelay, "         readPointer  [16:0] <= 17'd0;\n");
   }

   fprintf(OutFileDelay, "      end \n");
   fprintf(OutFileDelay, "      else if (enable == 1'b1) begin\n");

   if (Delay < 4) {
      fprintf(OutFileDelay, "         if (readPointer == 2'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 2'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 2'd1;\n");
   }
   else if (Delay < 8) {
      fprintf(OutFileDelay, "         if (readPointer == 3'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 3'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 3'd1;\n");
   }
   else if (Delay < 16) {
      fprintf(OutFileDelay, "         if (readPointer == 4'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 4'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 4'd1;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDelay, "         if (readPointer == 5'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 5'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 5'd1;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDelay, "         if (readPointer == 6'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 6'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 6'd1;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDelay, "         if (readPointer == 7'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 7'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 7'd1;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDelay, "         if (readPointer == 8'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 8'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 8'd1;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDelay, "         if (readPointer == 9'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 9'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 9'd1;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDelay, "         if (readPointer == 10'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 10'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 10'd1;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDelay, "         if (readPointer == 11'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 11'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 11'd1;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDelay, "         if (readPointer == 12'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 12'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 12'd1;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDelay, "         if (readPointer == 13'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 13'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 13'd1;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDelay, "         if (readPointer == 14'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 14'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 14'd1;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDelay, "         if (readPointer == 15'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 15'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 15'd1;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDelay, "         if (readPointer == 16'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 16'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 16'd1;\n");
   }
   else {
      fprintf(OutFileDelay, "         if (readPointer == 17'd%d) begin\n", (Delay-1));
      fprintf(OutFileDelay, "            readPointer <= 17'd0;\n");
      fprintf(OutFileDelay, "         end\n");
      fprintf(OutFileDelay, "         else begin\n");
      fprintf(OutFileDelay, "            readPointer <= readPointer + 17'd1;\n");
   }

   fprintf(OutFileDelay, "         end\n");
   fprintf(OutFileDelay, "      end\n");
   fprintf(OutFileDelay, "   end\n");
   fprintf(OutFileDelay, "\n\n\n");
   fprintf(OutFileDelay, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileDelay);


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
	ifstream fp_read(strRsDecodeDelay, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeDelay);
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
	remove(strRsDecodeDelay);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeDelay);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeDelay);


}
