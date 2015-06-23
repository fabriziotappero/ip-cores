//===================================================================
// Module Name : RsDecodeMul
// File Name   : RsDecodeMul.cpp
// Function    : RTL Decoder multiplier Module generation
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
FILE  *OutFileMul;


void RsDecodeMul(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   syndromeLength = TotalSize - DataSize;
   char *strRsDecodeMult;

   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeMult = (char *)calloc(lengthPath + 20,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeMult[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeMult[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeMult, "/rtl/RsDecodeMult.v");

   OutFileMul = fopen(strRsDecodeMult,"w");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileMul, "//===================================================================\n");
   fprintf(OutFileMul, "// Module Name : RsDecodeMult\n");
   fprintf(OutFileMul, "// File Name   : RsDecodeMult.v\n");
   fprintf(OutFileMul, "// Function    : Rs Decoder Multiplier Module\n");
   fprintf(OutFileMul, "// \n");
   fprintf(OutFileMul, "// Revision History:\n");
   fprintf(OutFileMul, "// Date          By           Version    Change Description\n");
   fprintf(OutFileMul, "//===================================================================\n");
   fprintf(OutFileMul, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileMul, "//\n");
   fprintf(OutFileMul, "//===================================================================\n");
   fprintf(OutFileMul, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileMul, "//\n\n\n");
   fprintf(OutFileMul, "module RsDecodeMult(\n");
   fprintf(OutFileMul, "   A, // input A\n");
   fprintf(OutFileMul, "   B, // input B\n");
   fprintf(OutFileMul, "   P  // output P = A*B in Galois Field\n");
   fprintf(OutFileMul, ");\n\n\n");

   fprintf(OutFileMul, "   input  [%d:0]   A; // input A\n", bitSymbol-1);
   fprintf(OutFileMul, "   input  [%d:0]   B; // input B\n", bitSymbol-1);
   fprintf(OutFileMul, "   output [%d:0]   P; // output P = A*B in Galois Field\n", bitSymbol-1);
   fprintf(OutFileMul, "\n\n\n");


   //------------------------------------------------------------------------
   // + instance M register
   //- 
   //------------------------------------------------------------------------
   fprintf(OutFileMul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileMul, "   // + M\n");
   fprintf(OutFileMul, "   //- \n");
   fprintf(OutFileMul, "   //------------------------------------------------------------------------\n");

   switch(bitSymbol){
      case (3):
         fprintf(OutFileMul, "   wire [4:0]   M;\n");
      break;
      case (4):
         fprintf(OutFileMul, "   wire [6:0]   M;\n");
      break;
      case (5):
         fprintf(OutFileMul, "   wire [8:0]   M;\n");
      break;
      case (6):
         fprintf(OutFileMul, "   wire [10:0]   M;\n");
      break;
      case (7):
         fprintf(OutFileMul, "   wire [12:0]   M;\n");
      break;
      case (8):
         fprintf(OutFileMul, "   wire [14:0]   M;\n");
      break;
      case (9):
         fprintf(OutFileMul, "   wire [16:0]   M;\n");
      break;
      case (10):
         fprintf(OutFileMul, "   wire [18:0]   M;\n");
      break;
      case (11):
         fprintf(OutFileMul, "   wire [20:0]   M;\n");
      break;
      case (12):
         fprintf(OutFileMul, "   wire [22:0]   M;\n");
      break;
      default:
         fprintf(OutFileMul, "   wire          M;\n");
      break;
   }

   fprintf(OutFileMul, "\n\n\n");

   //------------------------------------------------------------------------
   // + assign M for GF multiplication
   //- 
   //------------------------------------------------------------------------
   switch(bitSymbol){
      case (3):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[1] & B[2]) ^ (A[2] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[2] & B[2]);\n");
      break;
      case (4):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[2] & B[3]) ^ (A[3] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[3] & B[3]);\n");
      break;
      case (5):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[3] & B[4]) ^ (A[4] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[4] & B[4]);\n");
      break;
      case (6):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5]) ^ (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]) ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[1] & B[5]) ^ (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]) ^ (A[5] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[2] & B[5]) ^ (A[3] & B[4]) ^ (A[4] & B[3]) ^ (A[5] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[3] & B[5]) ^ (A[4] & B[4]) ^ (A[5] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[4] & B[5]) ^ (A[5] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[5] & B[5]);\n");
      break;
      case (7):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5]) ^ (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]) ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6]) ^ (A[1] & B[5]) ^ (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]) ^ (A[5] & B[1]) ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[1] & B[6]) ^ (A[2] & B[5]) ^ (A[3] & B[4]) ^ (A[4] & B[3]) ^ (A[5] & B[2]) ^ (A[6] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[2] & B[6]) ^ (A[3] & B[5]) ^ (A[4] & B[4]) ^ (A[5] & B[3]) ^ (A[6] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[3] & B[6]) ^ (A[4] & B[5]) ^ (A[5] & B[4]) ^ (A[6] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[4] & B[6]) ^ (A[5] & B[5]) ^ (A[6] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[5] & B[6]) ^ (A[6] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[6] & B[6]);\n");
      break;
      case (8):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5]) ^ (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]) ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6]) ^ (A[1] & B[5]) ^ (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]) ^ (A[5] & B[1]) ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[0] & B[7]) ^ (A[1] & B[6]) ^ (A[2] & B[5]) ^ (A[3] & B[4]) ^ (A[4] & B[3]) ^ (A[5] & B[2]) ^ (A[6] & B[1]) ^ (A[7] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[1] & B[7]) ^ (A[2] & B[6]) ^ (A[3] & B[5]) ^ (A[4] & B[4]) ^ (A[5] & B[3]) ^ (A[6] & B[2]) ^ (A[7] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[2] & B[7]) ^ (A[3] & B[6]) ^ (A[4] & B[5]) ^ (A[5] & B[4]) ^ (A[6] & B[3]) ^ (A[7] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[3] & B[7]) ^ (A[4] & B[6]) ^ (A[5] & B[5]) ^ (A[6] & B[4]) ^ (A[7] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[4] & B[7]) ^ (A[5] & B[6]) ^ (A[6] & B[5]) ^ (A[7] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[5] & B[7]) ^ (A[6] & B[6]) ^ (A[7] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[13] = (A[6] & B[7]) ^ (A[7] & B[6]);\n");
         fprintf(OutFileMul, "   assign M[14] = (A[7] & B[7]);\n");
      break;
      case (9):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5]) ^ (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]) ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6]) ^ (A[1] & B[5]) ^ (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]) ^ (A[5] & B[1]) ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[0] & B[7]) ^ (A[1] & B[6]) ^ (A[2] & B[5]) ^ (A[3] & B[4]) ^ (A[4] & B[3]) ^ (A[5] & B[2]) ^ (A[6] & B[1]) ^ (A[7] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[1] & B[7]) ^ (A[2] & B[6]) ^ (A[3] & B[5]) ^ (A[4] & B[4]) ^ (A[5] & B[3]) ^ (A[6] & B[2]) ^ (A[7] & B[1]) ^ (A[0] & B[8]) ^ (A[8] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[2] & B[7]) ^ (A[3] & B[6]) ^ (A[4] & B[5]) ^ (A[5] & B[4]) ^ (A[6] & B[3]) ^ (A[7] & B[2]) ^ (A[1] & B[8]) ^ (A[8] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[3] & B[7]) ^ (A[4] & B[6]) ^ (A[5] & B[5]) ^ (A[6] & B[4]) ^ (A[7] & B[3]) ^ (A[2] & B[8]) ^ (A[8] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[4] & B[7]) ^ (A[5] & B[6]) ^ (A[6] & B[5]) ^ (A[7] & B[4]) ^ (A[3] & B[8]) ^ (A[8] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[5] & B[7]) ^ (A[6] & B[6]) ^ (A[7] & B[5]) ^ (A[4] & B[8]) ^ (A[8] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[13] = (A[6] & B[7]) ^ (A[7] & B[6]) ^ (A[5] & B[8]) ^ (A[8] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[14] = (A[7] & B[7]) ^ (A[6] & B[8]) ^ (A[8] & B[6]);\n");
         fprintf(OutFileMul, "   assign M[15] = (A[8] & B[7]) ^ (A[7] & B[8]);\n");
         fprintf(OutFileMul, "   assign M[16] = (A[8] & B[8]);\n");
      break;
      case (10):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1]) ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2]) ^ (A[1] & B[1]) ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3]) ^ (A[1] & B[2]) ^ (A[2] & B[1]) ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4]) ^ (A[1] & B[3]) ^ (A[2] & B[2]) ^ (A[3] & B[1]) ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5]) ^ (A[1] & B[4]) ^ (A[2] & B[3]) ^ (A[3] & B[2]) ^ (A[4] & B[1]) ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6]) ^ (A[1] & B[5]) ^ (A[2] & B[4]) ^ (A[3] & B[3]) ^ (A[4] & B[2]) ^ (A[5] & B[1]) ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[0] & B[7]) ^ (A[1] & B[6]) ^ (A[2] & B[5]) ^ (A[3] & B[4]) ^ (A[4] & B[3]) ^ (A[5] & B[2]) ^ (A[6] & B[1]) ^ (A[7] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[1] & B[7]) ^ (A[2] & B[6]) ^ (A[3] & B[5]) ^ (A[4] & B[4]) ^ (A[5] & B[3]) ^ (A[6] & B[2]) ^ (A[7] & B[1]) ^ (A[0] & B[8]) ^ (A[8] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[2] & B[7]) ^ (A[3] & B[6]) ^ (A[4] & B[5]) ^ (A[5] & B[4]) ^ (A[6] & B[3]) ^ (A[7] & B[2]) ^ (A[1] & B[8]) ^ (A[8] & B[1]) ^ (A[0] & B[9]) ^ (A[9] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[3] & B[7]) ^ (A[4] & B[6]) ^ (A[5] & B[5]) ^ (A[6] & B[4]) ^ (A[7] & B[3]) ^ (A[2] & B[8]) ^ (A[8] & B[2]) ^ (A[1] & B[9]) ^ (A[9] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[4] & B[7]) ^ (A[5] & B[6]) ^ (A[6] & B[5]) ^ (A[7] & B[4]) ^ (A[3] & B[8]) ^ (A[8] & B[3]) ^ (A[2] & B[9]) ^ (A[9] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[5] & B[7]) ^ (A[6] & B[6]) ^ (A[7] & B[5]) ^ (A[4] & B[8]) ^ (A[8] & B[4]) ^ (A[3] & B[9]) ^ (A[9] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[13] = (A[6] & B[7]) ^ (A[7] & B[6]) ^ (A[5] & B[8]) ^ (A[8] & B[5]) ^ (A[4] & B[9]) ^ (A[9] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[14] = (A[7] & B[7]) ^ (A[6] & B[8]) ^ (A[8] & B[6]) ^ (A[5] & B[9]) ^ (A[9] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[15] = (A[8] & B[7]) ^ (A[7] & B[8]) ^ (A[6] & B[9]) ^ (A[9] & B[6]);\n");
         fprintf(OutFileMul, "   assign M[16] = (A[8] & B[8]) ^ (A[7] & B[9]) ^ (A[9] & B[7]);\n");
         fprintf(OutFileMul, "   assign M[17] = (A[8] & B[9]) ^ (A[9] & B[8]);\n");
         fprintf(OutFileMul, "   assign M[18] = (A[9] & B[9]);\n");
      break;
      case (11):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1])  ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2])  ^ (A[1] & B[1])  ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3])  ^ (A[1] & B[2])  ^ (A[2] & B[1])  ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4])  ^ (A[1] & B[3])  ^ (A[2] & B[2])  ^ (A[3] & B[1])  ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5])  ^ (A[1] & B[4])  ^ (A[2] & B[3])  ^ (A[3] & B[2])  ^ (A[4] & B[1])  ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6])  ^ (A[1] & B[5])  ^ (A[2] & B[4])  ^ (A[3] & B[3])  ^ (A[4] & B[2])  ^ (A[5] & B[1])  ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[0] & B[7])  ^ (A[1] & B[6])  ^ (A[2] & B[5])  ^ (A[3] & B[4])  ^ (A[4] & B[3])  ^ (A[5] & B[2])  ^ (A[6] & B[1])  ^ (A[7] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[1] & B[7])  ^ (A[2] & B[6])  ^ (A[3] & B[5])  ^ (A[4] & B[4])  ^ (A[5] & B[3])  ^ (A[6] & B[2])  ^ (A[7] & B[1])  ^ (A[0] & B[8])  ^ (A[8] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[2] & B[7])  ^ (A[3] & B[6])  ^ (A[4] & B[5])  ^ (A[5] & B[4])  ^ (A[6] & B[3])  ^ (A[7] & B[2])  ^ (A[1] & B[8])  ^ (A[8] & B[1])  ^ (A[0] & B[9])  ^ (A[9] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[3] & B[7])  ^ (A[4] & B[6])  ^ (A[5] & B[5])  ^ (A[6] & B[4])  ^ (A[7] & B[3])  ^ (A[2] & B[8])  ^ (A[8] & B[2])  ^ (A[1] & B[9])  ^ (A[9] & B[1])  ^ (A[0] & B[10]) ^ (A[10] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[4] & B[7])  ^ (A[5] & B[6])  ^ (A[6] & B[5])  ^ (A[7] & B[4])  ^ (A[3] & B[8])  ^ (A[8] & B[3])  ^ (A[2] & B[9])  ^ (A[9] & B[2])  ^ (A[1] & B[10]) ^ (A[10] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[5] & B[7])  ^ (A[6] & B[6])  ^ (A[7] & B[5])  ^ (A[4] & B[8])  ^ (A[8] & B[4])  ^ (A[3] & B[9])  ^ (A[9] & B[3])  ^ (A[2] & B[10]) ^ (A[10] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[13] = (A[6] & B[7])  ^ (A[7] & B[6])  ^ (A[5] & B[8])  ^ (A[8] & B[5])  ^ (A[4] & B[9])  ^ (A[9] & B[4])  ^ (A[3] & B[10]) ^ (A[10] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[14] = (A[7] & B[7])  ^ (A[6] & B[8])  ^ (A[8] & B[6])  ^ (A[5] & B[9])  ^ (A[9] & B[5])  ^ (A[4] & B[10]) ^ (A[10] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[15] = (A[8] & B[7])  ^ (A[7] & B[8])  ^ (A[6] & B[9])  ^ (A[9] & B[6])  ^ (A[5] & B[10]) ^ (A[10] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[16] = (A[8] & B[8])  ^ (A[7] & B[9])  ^ (A[9] & B[7])  ^ (A[6] & B[10]) ^ (A[10] & B[6]);\n");
         fprintf(OutFileMul, "   assign M[17] = (A[8] & B[9])  ^ (A[9] & B[8])  ^ (A[7] & B[10]) ^ (A[10] & B[7]);\n");
         fprintf(OutFileMul, "   assign M[18] = (A[9] & B[9])  ^ (A[8] & B[10]) ^ (A[10] & B[8]);\n");
         fprintf(OutFileMul, "   assign M[19] = (A[9] & B[10]) ^ (A[10] & B[9]);\n");
         fprintf(OutFileMul, "   assign M[20] = (A[10] & B[10]);\n");
      break;
      case (12):
         fprintf(OutFileMul, "   assign M[0]  = (A[0] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[1]  = (A[0] & B[1])   ^ (A[1] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[2]  = (A[0] & B[2])   ^ (A[1] & B[1])  ^ (A[2] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[3]  = (A[0] & B[3])   ^ (A[1] & B[2])  ^ (A[2] & B[1])  ^ (A[3] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[4]  = (A[0] & B[4])   ^ (A[1] & B[3])  ^ (A[2] & B[2])  ^ (A[3] & B[1])  ^ (A[4] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[5]  = (A[0] & B[5])   ^ (A[1] & B[4])  ^ (A[2] & B[3])  ^ (A[3] & B[2])  ^ (A[4] & B[1])  ^ (A[5] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[6]  = (A[0] & B[6])   ^ (A[1] & B[5])  ^ (A[2] & B[4])  ^ (A[3] & B[3])  ^ (A[4] & B[2])  ^ (A[5] & B[1])  ^ (A[6] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[7]  = (A[0] & B[7])   ^ (A[1] & B[6])  ^ (A[2] & B[5])  ^ (A[3] & B[4])  ^ (A[4] & B[3])  ^ (A[5] & B[2])  ^ (A[6] & B[1])  ^ (A[7] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[8]  = (A[1] & B[7])   ^ (A[2] & B[6])  ^ (A[3] & B[5])  ^ (A[4] & B[4])  ^ (A[5] & B[3])  ^ (A[6] & B[2])  ^ (A[7] & B[1])  ^ (A[0] & B[8])  ^ (A[8] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[9]  = (A[2] & B[7])   ^ (A[3] & B[6])  ^ (A[4] & B[5])  ^ (A[5] & B[4])  ^ (A[6] & B[3])  ^ (A[7] & B[2])  ^ (A[1] & B[8])  ^ (A[8] & B[1])  ^ (A[0] & B[9])  ^ (A[9] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[10] = (A[3] & B[7])   ^ (A[4] & B[6])  ^ (A[5] & B[5])  ^ (A[6] & B[4])  ^ (A[7] & B[3])  ^ (A[2] & B[8])  ^ (A[8] & B[2])  ^ (A[1] & B[9])  ^ (A[9] & B[1])  ^ (A[0] & B[10]) ^ (A[10] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[11] = (A[4] & B[7])   ^ (A[5] & B[6])  ^ (A[6] & B[5])  ^ (A[7] & B[4])  ^ (A[3] & B[8])  ^ (A[8] & B[3])  ^ (A[2] & B[9])  ^ (A[9] & B[2])  ^ (A[1] & B[10]) ^ (A[10] & B[1]) ^ (A[0] & B[11]) ^ (A[11] & B[0]);\n");
         fprintf(OutFileMul, "   assign M[12] = (A[5] & B[7])   ^ (A[6] & B[6])  ^ (A[7] & B[5])  ^ (A[4] & B[8])  ^ (A[8] & B[4])  ^ (A[3] & B[9])  ^ (A[9] & B[3])  ^ (A[2] & B[10]) ^ (A[10] & B[2]) ^ (A[1] & B[11]) ^ (A[11] & B[1]);\n");
         fprintf(OutFileMul, "   assign M[13] = (A[6] & B[7])   ^ (A[7] & B[6])  ^ (A[5] & B[8])  ^ (A[8] & B[5])  ^ (A[4] & B[9])  ^ (A[9] & B[4])  ^ (A[3] & B[10]) ^ (A[10] & B[3]) ^ (A[2] & B[11]) ^ (A[11] & B[2]);\n");
         fprintf(OutFileMul, "   assign M[14] = (A[7] & B[7])   ^ (A[6] & B[8])  ^ (A[8] & B[6])  ^ (A[5] & B[9])  ^ (A[9] & B[5])  ^ (A[4] & B[10]) ^ (A[10] & B[4]) ^ (A[3] & B[11]) ^ (A[11] & B[3]);\n");
         fprintf(OutFileMul, "   assign M[15] = (A[8] & B[7])   ^ (A[7] & B[8])  ^ (A[6] & B[9])  ^ (A[9] & B[6])  ^ (A[5] & B[10]) ^ (A[10] & B[5]) ^ (A[4] & B[11]) ^ (A[11] & B[4]);\n");
         fprintf(OutFileMul, "   assign M[16] = (A[8] & B[8])   ^ (A[7] & B[9])  ^ (A[9] & B[7])  ^ (A[6] & B[10]) ^ (A[10] & B[6]) ^ (A[5] & B[11]) ^ (A[11] & B[5]);\n");
         fprintf(OutFileMul, "   assign M[17] = (A[8] & B[9])   ^ (A[9] & B[8])  ^ (A[7] & B[10]) ^ (A[10] & B[7]) ^ (A[6] & B[11]) ^ (A[11] & B[6]);\n");
         fprintf(OutFileMul, "   assign M[18] = (A[9] & B[9])   ^ (A[8] & B[10]) ^ (A[10] & B[8]) ^ (A[7] & B[11]) ^ (A[11] & B[7]);\n");
         fprintf(OutFileMul, "   assign M[19] = (A[9] & B[10])  ^ (A[10] & B[9]) ^ (A[8] & B[11]) ^ (A[11] & B[8]);\n");
         fprintf(OutFileMul, "   assign M[20] = (A[10] & B[10]) ^ (A[9] & B[11]) ^ (A[11] & B[9]);\n");
         fprintf(OutFileMul, "   assign M[21] = (A[10] & B[11]) ^ (A[11] & B[10]);\n");
         fprintf(OutFileMul, "   assign M[22] = A[11] & B[11];\n");
      break;
      default:
         fprintf(OutFileMul, "   assign M[0] = 0;\n");
      break;
   }


   //------------------------------------------------------------------------
   // + P
   //- 
   //------------------------------------------------------------------------
   fprintf(OutFileMul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileMul, "   // + P\n");
   fprintf(OutFileMul, "   //- \n");
   fprintf(OutFileMul, "   //------------------------------------------------------------------------\n");


switch(bitSymbol){
   case (3):
      //------------------------------------------------------------------------
      // bitSymbol = 3, Primpoly = 11
      //------------------------------------------------------------------------
      if (PrimPoly == 11) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[3] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[3] ^ M[4] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[4] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 3, Primpoly = 13
      //------------------------------------------------------------------------
      if (PrimPoly == 13) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[3] ^ M[4] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[4] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[3] ^ M[4] ;\n");
      }
   break;
   case (4):
      //------------------------------------------------------------------------
      // bitSymbol = 4, Primpoly = 19
      //------------------------------------------------------------------------
      if (PrimPoly == 19) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[4] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[4] ^ M[5] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[5] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[6] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 4, Primpoly = 25
      //------------------------------------------------------------------------
      if (PrimPoly == 25) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[4] ^ M[5] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[5] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[4] ^ M[5] ^ M[6] ;\n");
      }
   break;

   case (5):
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 37
      //------------------------------------------------------------------------
      if (PrimPoly == 37) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 41
      //------------------------------------------------------------------------
      if (PrimPoly == 41) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[6] ^ M[8] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 47
      //------------------------------------------------------------------------
      if (PrimPoly == 47) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[5] ^ M[6] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[5] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[5] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[6] ^ M[7] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 55
      //------------------------------------------------------------------------
      if (PrimPoly == 55) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[6] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[5] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[5] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[5] ^ M[6] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 59
      //------------------------------------------------------------------------
      if (PrimPoly == 59) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[6] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[5] ^ M[6] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[5] ^ M[7] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 61
      //------------------------------------------------------------------------
      if (PrimPoly == 61) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[5] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[5] ^ M[6] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[5] ^ M[8] ;\n");
      }
   break;

   case (6):
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 67
      //------------------------------------------------------------------------
      if (PrimPoly == 67) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 91
      //------------------------------------------------------------------------
      if (PrimPoly == 91) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[6] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[6] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 97
      //------------------------------------------------------------------------
      if (PrimPoly == 97) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[6] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 103
      //------------------------------------------------------------------------
      if (PrimPoly == 103) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ^ M[7] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[6] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[6] ^ M[7] ^ M[8] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 109
      //------------------------------------------------------------------------
      if (PrimPoly == 109) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[6] ^ M[7] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[6] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[6] ^ M[7] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 115
      //------------------------------------------------------------------------
      if (PrimPoly == 115) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[6] ^ M[7] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[6] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[6] ^ M[7] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[6] ^ M[8] ^ M[9] ^ M[10] ;\n");
      }
   break;


   case (7):
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 131
      //------------------------------------------------------------------------
      if (PrimPoly == 131) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 137
      //------------------------------------------------------------------------
      if (PrimPoly == 137) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 143
      //------------------------------------------------------------------------
      if (PrimPoly == 143) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 145
      //------------------------------------------------------------------------
      if (PrimPoly == 145) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 157
      //------------------------------------------------------------------------
      if (PrimPoly == 157) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 167
      //------------------------------------------------------------------------
      if (PrimPoly == 167) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[8] ^ M[10] ^ M[11] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 171
      //------------------------------------------------------------------------
      if (PrimPoly == 171) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[8] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 185
      //------------------------------------------------------------------------
      if (PrimPoly == 185) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[9] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[8] ^ M[9] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 191
      //------------------------------------------------------------------------
      if (PrimPoly == 191) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[8] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[8] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 193
      //------------------------------------------------------------------------
      if (PrimPoly == 193) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 203
      //------------------------------------------------------------------------
      if (PrimPoly == 203) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[8] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[8] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 211
      //------------------------------------------------------------------------
      if (PrimPoly == 211) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[8] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[8] ^ M[10] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 213
      //------------------------------------------------------------------------
      if (PrimPoly == 213) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[8] ^ M[10] ^ M[11] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 229
      //------------------------------------------------------------------------
      if (PrimPoly == 229) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[9] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 239
      //------------------------------------------------------------------------
      if (PrimPoly == 239) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[8] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[9] ^ M[11] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 241
      //------------------------------------------------------------------------
      if (PrimPoly == 241) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[9] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[10] ^ M[11] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 247
      //------------------------------------------------------------------------
      if (PrimPoly == 247) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[7] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[9] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[10] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 253
      //------------------------------------------------------------------------
      if (PrimPoly == 253) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[7] ^ M[8] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[8] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[7] ^ M[8] ^ M[9] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[7] ^ M[9] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[7] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[7] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[7] ^ M[12] ;\n");
      }
   break;


   case (8):
      if (PrimPoly == 285) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8] ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8] ^ M[9] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[8] ^ M[9] ^ M[10] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[9] ^ M[10] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[11] ^ M[12] ^ M[13];\n");
      }
      if (PrimPoly == 299) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8] ^ M[9] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[9] ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8] ^ M[10];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
      }
      if (PrimPoly == 301) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8] ^ M[11] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8] ^ M[10] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8] ^ M[9]  ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9] ^ M[10] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8] ^ M[10] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[9] ^ M[11] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[10] ^ M[12];\n");
      }
      if (PrimPoly == 333) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8]  ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[10] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9]  ^ M[11] ^ M[12];\n");
      }
      if (PrimPoly == 351) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8] ^ M[10] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8] ^ M[9]  ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[8] ^ M[9];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[9] ^ M[10];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8] ^ M[11] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9] ^ M[12] ^ M[14];\n");
      }
      if (PrimPoly == 355) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8]  ^ M[9]  ^ M[10] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[10] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9]  ^ M[10] ^ M[11];\n");
      }
      if (PrimPoly == 357) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[11] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[9]  ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[10] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[10] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
      }
      if (PrimPoly == 361) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[10] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8]  ^ M[10] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[11] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
      }
      if (PrimPoly == 369) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8] ^ M[10] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[8]  ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[9]  ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[9]  ^ M[10] ^ M[14];\n");
      }
      if (PrimPoly == 391) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8]  ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[10] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[12];\n");
      }
      if (PrimPoly == 397) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[9]  ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8]  ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[10] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[11] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11];\n");
      }
      if (PrimPoly == 425) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[9]  ^ M[11];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[9]  ^ M[10] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[9]  ^ M[11] ^ M[12];\n");
      }
      if (PrimPoly == 451) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8]  ^ M[10] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[9]  ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[10] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[11] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[10] ^ M[11] ^ M[13];\n");
      }
      if (PrimPoly == 463) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8]  ^ M[10] ^ M[11] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[8]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[10] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[9]  ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
      }
      if (PrimPoly == 487) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[12] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[8]  ^ M[10] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[9]  ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[10] ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[9]  ^ M[11] ^ M[12] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[10];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[11] ^ M[12] ^ M[13] ^ M[14];\n");
      }
      if (PrimPoly == 501) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[8]  ^ M[9]  ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[10] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[13];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[8]  ^ M[9]  ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[8]  ^ M[10] ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[8]  ^ M[11] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[8]  ^ M[12];\n");
      }
   break;


   case (9):
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 529
      //------------------------------------------------------------------------
      if (PrimPoly == 529) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[9]  ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[10] ^ M[15];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[11] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[12];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[13] ^ M[14];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[10] ^ M[14] ^ M[15];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[11] ^ M[15] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[12] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[8] = M[8] ^ M[13];\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 539
      //------------------------------------------------------------------------
      if (PrimPoly == 539) {
         fprintf(OutFileMul, "   assign P[0] = M[0] ^ M[9]  ^ M[14] ^ M[15];\n");
         fprintf(OutFileMul, "   assign P[1] = M[1] ^ M[9]  ^ M[10] ^ M[14] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[2] = M[2] ^ M[10] ^ M[11] ^ M[15];\n");
         fprintf(OutFileMul, "   assign P[3] = M[3] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[4] = M[4] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[5] = M[5] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15];\n");
         fprintf(OutFileMul, "   assign P[6] = M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[7] = M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16];\n");
         fprintf(OutFileMul, "   assign P[8] = M[8] ^ M[13] ^ M[14] ^ M[16];\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 545
      //------------------------------------------------------------------------
      if (PrimPoly == 545) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[13]  ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 557
      //------------------------------------------------------------------------
      if (PrimPoly == 557) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 563
      //------------------------------------------------------------------------
      if (PrimPoly == 563) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 601
      //------------------------------------------------------------------------
      if (PrimPoly == 601) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ;\n");
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 607
      //------------------------------------------------------------------------
      if (PrimPoly == 607) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 617
      //------------------------------------------------------------------------
      if (PrimPoly == 617) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 623
      //------------------------------------------------------------------------
      if (PrimPoly == 623) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 631
      //------------------------------------------------------------------------
      if (PrimPoly == 631) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 637
      //------------------------------------------------------------------------
      if (PrimPoly == 637) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 647
      //------------------------------------------------------------------------
      if (PrimPoly == 647) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 661
      //------------------------------------------------------------------------
      if (PrimPoly == 661) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 675
      //------------------------------------------------------------------------
      if (PrimPoly == 675) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[14] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 677
      //------------------------------------------------------------------------
      if (PrimPoly == 677) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 687
      //------------------------------------------------------------------------
      if (PrimPoly == 687) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 695
      //------------------------------------------------------------------------
      if (PrimPoly == 695) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 701
      //------------------------------------------------------------------------
      if (PrimPoly == 701) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 719
      //------------------------------------------------------------------------
      if (PrimPoly == 719) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 721
      //------------------------------------------------------------------------
      if (PrimPoly == 721) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 731
      //------------------------------------------------------------------------
      if (PrimPoly == 731) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 757
      //------------------------------------------------------------------------
      if (PrimPoly == 757) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 761
      //------------------------------------------------------------------------
      if (PrimPoly == 761) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 787
      //------------------------------------------------------------------------
      if (PrimPoly == 787) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ;\n");
      }


      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 789
      //------------------------------------------------------------------------
      if (PrimPoly == 789) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }

      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 799
      //------------------------------------------------------------------------
      if (PrimPoly == 799) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
      }


      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 803
      //------------------------------------------------------------------------
      if (PrimPoly == 803) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 817
      //------------------------------------------------------------------------
      if (PrimPoly == 817) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 827
      //------------------------------------------------------------------------
      if (PrimPoly == 827) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 847
      //------------------------------------------------------------------------
      if (PrimPoly == 847) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 859
      //------------------------------------------------------------------------
      if (PrimPoly == 859) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 865
      //------------------------------------------------------------------------
      if (PrimPoly == 865) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 875
      //------------------------------------------------------------------------
      if (PrimPoly == 875) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[15] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 877
      //------------------------------------------------------------------------
      if (PrimPoly == 877) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 883
      //------------------------------------------------------------------------
      if (PrimPoly == 883) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 895
      //------------------------------------------------------------------------
      if (PrimPoly == 895) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[10] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 901
      //------------------------------------------------------------------------
      if (PrimPoly == 901) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 911
      //------------------------------------------------------------------------
      if (PrimPoly == 911) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[11] ^ M[12] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 949
      //------------------------------------------------------------------------
      if (PrimPoly == 949) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 953
      //------------------------------------------------------------------------
      if (PrimPoly == 953) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 967
      //------------------------------------------------------------------------
      if (PrimPoly == 967) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[12] ^ M[13] ^ M[15] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 971
      //------------------------------------------------------------------------
      if (PrimPoly == 971) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 973
      //------------------------------------------------------------------------
      if (PrimPoly == 973) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 981
      //------------------------------------------------------------------------
      if (PrimPoly == 981) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[12] ^ M[16] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 985
      //------------------------------------------------------------------------
      if (PrimPoly == 985) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[12] ^ M[14] ^ M[15] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 995
      //------------------------------------------------------------------------
      if (PrimPoly == 995) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 1001
      //------------------------------------------------------------------------
      if (PrimPoly == 1001) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[13] ^ M[16] ;\n");
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 1019
      //------------------------------------------------------------------------
      if (PrimPoly == 1019) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[9]  ^ M[10] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[9]  ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[9]  ^ M[10] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[9]  ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[9]  ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[9]  ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[9]  ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[9]  ^ M[15] ;\n");
      }
   break;

   
  //------------------------------------------------------------------------
   // bitSymbol = 10
   //------------------------------------------------------------------------
   case (10):
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1033
      //------------------------------------------------------------------------
      if (PrimPoly == 1033) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1051
      //------------------------------------------------------------------------
      if (PrimPoly == 1051) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[18] ;\n");
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1063
      //------------------------------------------------------------------------
      if (PrimPoly == 1063) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1069
      //------------------------------------------------------------------------
      if (PrimPoly == 1069) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1125
      //------------------------------------------------------------------------
      if (PrimPoly == 1125) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1135
      //------------------------------------------------------------------------
      if (PrimPoly == 1135) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1153
      //------------------------------------------------------------------------
      if (PrimPoly == 1153) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1163
      //------------------------------------------------------------------------
      if (PrimPoly == 1163) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1221
      //------------------------------------------------------------------------
      if (PrimPoly == 1221) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1239
      //------------------------------------------------------------------------
      if (PrimPoly == 1239) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1255
      //------------------------------------------------------------------------
      if (PrimPoly == 1255) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1267
      //------------------------------------------------------------------------
      if (PrimPoly == 1267) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1279
      //------------------------------------------------------------------------
      if (PrimPoly == 1279) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1293
      //------------------------------------------------------------------------
      if (PrimPoly == 1293) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1305
      //------------------------------------------------------------------------
      if (PrimPoly == 1305) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1315
      //------------------------------------------------------------------------
      if (PrimPoly == 1315) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1329
      //------------------------------------------------------------------------
      if (PrimPoly == 1329) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1341
      //------------------------------------------------------------------------
      if (PrimPoly == 1341) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1347
      //------------------------------------------------------------------------
      if (PrimPoly == 1347) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1367
      //------------------------------------------------------------------------
      if (PrimPoly == 1367) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1387
      //------------------------------------------------------------------------
      if (PrimPoly == 1387) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1413
      //------------------------------------------------------------------------
      if (PrimPoly == 1413) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1423
      //------------------------------------------------------------------------
      if (PrimPoly == 1423) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1431
      //------------------------------------------------------------------------
      if (PrimPoly == 1431) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1441
      //------------------------------------------------------------------------
      if (PrimPoly == 1441) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1479
      //------------------------------------------------------------------------
      if (PrimPoly == 1479) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1509
      //------------------------------------------------------------------------
      if (PrimPoly == 1509) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1527
      //------------------------------------------------------------------------
      if (PrimPoly == 1527) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1531
      //------------------------------------------------------------------------
      if (PrimPoly == 1531) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1555
      //------------------------------------------------------------------------
      if (PrimPoly == 1555) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1557
      //------------------------------------------------------------------------
      if (PrimPoly == 1557) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1573
      //------------------------------------------------------------------------
      if (PrimPoly == 1573) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1591
      //------------------------------------------------------------------------
      if (PrimPoly == 1591) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1603
      //------------------------------------------------------------------------
      if (PrimPoly == 1603) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1615
      //------------------------------------------------------------------------
      if (PrimPoly == 1615) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1627
      //------------------------------------------------------------------------
      if (PrimPoly == 1627) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1657
      //------------------------------------------------------------------------
      if (PrimPoly == 1657) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1663
      //------------------------------------------------------------------------
      if (PrimPoly == 1663) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1673
      //------------------------------------------------------------------------
      if (PrimPoly == 1673) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1717
      //------------------------------------------------------------------------
      if (PrimPoly == 1717) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1729
      //------------------------------------------------------------------------
      if (PrimPoly == 1729) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1747
      //------------------------------------------------------------------------
      if (PrimPoly == 1747) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1759
      //------------------------------------------------------------------------
      if (PrimPoly == 1759) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1789
      //------------------------------------------------------------------------
      if (PrimPoly == 1789) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1815
      //------------------------------------------------------------------------
      if (PrimPoly == 1815) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1821
      //------------------------------------------------------------------------
      if (PrimPoly == 1821) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1825
      //------------------------------------------------------------------------
      if (PrimPoly == 1825) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1849
      //------------------------------------------------------------------------
      if (PrimPoly == 1849) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1863
      //------------------------------------------------------------------------
      if (PrimPoly == 1863) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1869
      //------------------------------------------------------------------------
      if (PrimPoly == 1869) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1877
      //------------------------------------------------------------------------
      if (PrimPoly == 1877) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1881
      //------------------------------------------------------------------------
      if (PrimPoly == 1881) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1891
      //------------------------------------------------------------------------
      if (PrimPoly == 1891) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1917
      //------------------------------------------------------------------------
      if (PrimPoly == 1917) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1933
      //------------------------------------------------------------------------
      if (PrimPoly == 1933) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1939
      //------------------------------------------------------------------------
      if (PrimPoly == 1939) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1969
      //------------------------------------------------------------------------
      if (PrimPoly == 1969) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2011
      //------------------------------------------------------------------------
      if (PrimPoly == 2011) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2035
      //------------------------------------------------------------------------
      if (PrimPoly == 2035) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[10] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2041
      //------------------------------------------------------------------------
      if (PrimPoly == 2041) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[10] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[10] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[10] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[10] ^ M[17] ^ M[18] ;\n");
      }
   break;


   case(11):
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2053
      //------------------------------------------------------------------------
      if (PrimPoly == 2053) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2071
      //------------------------------------------------------------------------
      if (PrimPoly == 2071) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2091
      //------------------------------------------------------------------------
      if (PrimPoly == 2091) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2093
      //------------------------------------------------------------------------
      if (PrimPoly == 2093) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2119
      //------------------------------------------------------------------------
      if (PrimPoly == 2119) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2147
      //------------------------------------------------------------------------
      if (PrimPoly == 2147) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2149
      //------------------------------------------------------------------------
      if (PrimPoly == 2149) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2161
      //------------------------------------------------------------------------
      if (PrimPoly == 2161) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2171
      //------------------------------------------------------------------------
      if (PrimPoly == 2171) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2189
      //------------------------------------------------------------------------
      if (PrimPoly == 2189) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2197
      //------------------------------------------------------------------------
      if (PrimPoly == 2197) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2207
      //------------------------------------------------------------------------
      if (PrimPoly == 2207) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2217
      //------------------------------------------------------------------------
      if (PrimPoly == 2217) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2225
      //------------------------------------------------------------------------
      if (PrimPoly == 2225) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2255
      //------------------------------------------------------------------------
      if (PrimPoly == 2255) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2257
      //------------------------------------------------------------------------
      if (PrimPoly == 2257) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2273
      //------------------------------------------------------------------------
      if (PrimPoly == 2273) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2279
      //------------------------------------------------------------------------
      if (PrimPoly == 2279) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2283
      //------------------------------------------------------------------------
      if (PrimPoly == 2283) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2293
      //------------------------------------------------------------------------
      if (PrimPoly == 2293) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2317
      //------------------------------------------------------------------------
      if (PrimPoly == 2317) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2323
      //------------------------------------------------------------------------
      if (PrimPoly == 2323) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2341
      //------------------------------------------------------------------------
      if (PrimPoly == 2341) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2345
      //------------------------------------------------------------------------
      if (PrimPoly == 2345) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2363
      //------------------------------------------------------------------------
      if (PrimPoly == 2363) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2365
      //------------------------------------------------------------------------
      if (PrimPoly == 2365) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2373
      //------------------------------------------------------------------------
      if (PrimPoly == 2373) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2377
      //------------------------------------------------------------------------
      if (PrimPoly == 2377) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2385
      //------------------------------------------------------------------------
      if (PrimPoly == 2385) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2395
      //------------------------------------------------------------------------
      if (PrimPoly == 2395) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2419
      //------------------------------------------------------------------------
      if (PrimPoly == 2419) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2421
      //------------------------------------------------------------------------
      if (PrimPoly == 2421) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2431
      //------------------------------------------------------------------------
      if (PrimPoly == 2431) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2435
      //------------------------------------------------------------------------
      if (PrimPoly == 2435) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2447
      //------------------------------------------------------------------------
      if (PrimPoly == 2447) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2475
      //------------------------------------------------------------------------
      if (PrimPoly == 2475) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2477
      //------------------------------------------------------------------------
      if (PrimPoly == 2477) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2489
      //------------------------------------------------------------------------
      if (PrimPoly == 2489) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2503
      //------------------------------------------------------------------------
      if (PrimPoly == 2503) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2521
      //------------------------------------------------------------------------
      if (PrimPoly == 2521) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2533
      //------------------------------------------------------------------------
      if (PrimPoly == 2533) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2551
      //------------------------------------------------------------------------
      if (PrimPoly == 2551) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2561
      //------------------------------------------------------------------------
      if (PrimPoly == 2561) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2567
      //------------------------------------------------------------------------
      if (PrimPoly == 2567) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2579
      //------------------------------------------------------------------------
      if (PrimPoly == 2579) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2581
      //------------------------------------------------------------------------
      if (PrimPoly == 2581) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2601
      //------------------------------------------------------------------------
      if (PrimPoly == 2601) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2633
      //------------------------------------------------------------------------
      if (PrimPoly == 2633) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2657
      //------------------------------------------------------------------------
      if (PrimPoly == 2657) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2669
      //------------------------------------------------------------------------
      if (PrimPoly == 2669) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2681
      //------------------------------------------------------------------------
      if (PrimPoly == 2681) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2687
      //------------------------------------------------------------------------
      if (PrimPoly == 2687) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2693
      //------------------------------------------------------------------------
      if (PrimPoly == 2693) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2705
      //------------------------------------------------------------------------
      if (PrimPoly == 2705) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2717
      //------------------------------------------------------------------------
      if (PrimPoly == 2717) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2727
      //------------------------------------------------------------------------
      if (PrimPoly == 2727) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2731
      //------------------------------------------------------------------------
      if (PrimPoly == 2731) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2739
      //------------------------------------------------------------------------
      if (PrimPoly == 2739) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2741
      //------------------------------------------------------------------------
      if (PrimPoly == 2741) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2773
      //------------------------------------------------------------------------
      if (PrimPoly == 2773) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2783
      //------------------------------------------------------------------------
      if (PrimPoly == 2783) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2793
      //------------------------------------------------------------------------
      if (PrimPoly == 2793) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2799
      //------------------------------------------------------------------------
      if (PrimPoly == 2799) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2801
      //------------------------------------------------------------------------
      if (PrimPoly == 2801) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2811
      //------------------------------------------------------------------------
      if (PrimPoly == 2811) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2819
      //------------------------------------------------------------------------
      if (PrimPoly == 2819) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2825
      //------------------------------------------------------------------------
      if (PrimPoly == 2825) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2833
      //------------------------------------------------------------------------
      if (PrimPoly == 2833) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2867
      //------------------------------------------------------------------------
      if (PrimPoly == 2867) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2879
      //------------------------------------------------------------------------
      if (PrimPoly == 2879) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2881
      //------------------------------------------------------------------------
      if (PrimPoly == 2881) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2891
      //------------------------------------------------------------------------
      if (PrimPoly == 2891) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2905
      //------------------------------------------------------------------------
      if (PrimPoly == 2905) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2911
      //------------------------------------------------------------------------
      if (PrimPoly == 2911) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2917
      //------------------------------------------------------------------------
      if (PrimPoly == 2917) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2927
      //------------------------------------------------------------------------
      if (PrimPoly == 2927) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2941
      //------------------------------------------------------------------------
      if (PrimPoly == 2941) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2951
      //------------------------------------------------------------------------
      if (PrimPoly == 2951) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2955
      //------------------------------------------------------------------------
      if (PrimPoly == 2955) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2963
      //------------------------------------------------------------------------
      if (PrimPoly == 2963) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2965
      //------------------------------------------------------------------------
      if (PrimPoly == 2965) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2991
      //------------------------------------------------------------------------
      if (PrimPoly == 2991) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2999
      //------------------------------------------------------------------------
      if (PrimPoly == 2999) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3005
      //------------------------------------------------------------------------
      if (PrimPoly == 3005) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3017
      //------------------------------------------------------------------------
      if (PrimPoly == 3017) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3035
      //------------------------------------------------------------------------
      if (PrimPoly == 3035) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3037
      //------------------------------------------------------------------------
      if (PrimPoly == 3037) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3047
      //------------------------------------------------------------------------
      if (PrimPoly == 3047) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3053
      //------------------------------------------------------------------------
      if (PrimPoly == 3053) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3083
      //------------------------------------------------------------------------
      if (PrimPoly == 3083) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3085
      //------------------------------------------------------------------------
      if (PrimPoly == 3085) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3097
      //------------------------------------------------------------------------
      if (PrimPoly == 3097) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3103
      //------------------------------------------------------------------------
      if (PrimPoly == 3103) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3159
      //------------------------------------------------------------------------
      if (PrimPoly == 3159) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3169
      //------------------------------------------------------------------------
      if (PrimPoly == 3169) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3179
      //------------------------------------------------------------------------
      if (PrimPoly == 3179) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3187
      //------------------------------------------------------------------------
      if (PrimPoly == 3187) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3205
      //------------------------------------------------------------------------
      if (PrimPoly == 3205) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3209
      //------------------------------------------------------------------------
      if (PrimPoly == 3209) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3223
      //------------------------------------------------------------------------
      if (PrimPoly == 3223) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3227
      //------------------------------------------------------------------------
      if (PrimPoly == 3227) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3229
      //------------------------------------------------------------------------
      if (PrimPoly == 3229) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3251
      //------------------------------------------------------------------------
      if (PrimPoly == 3251) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3263
      //------------------------------------------------------------------------
      if (PrimPoly == 3263) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3271
      //------------------------------------------------------------------------
      if (PrimPoly == 3271) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3277
      //------------------------------------------------------------------------
      if (PrimPoly == 3277) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3283
      //------------------------------------------------------------------------
      if (PrimPoly == 3283) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3285
      //------------------------------------------------------------------------
      if (PrimPoly == 3285) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3299
      //------------------------------------------------------------------------
      if (PrimPoly == 3299) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3305
      //------------------------------------------------------------------------
      if (PrimPoly == 3305) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3319
      //------------------------------------------------------------------------
      if (PrimPoly == 3319) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3331
      //------------------------------------------------------------------------
      if (PrimPoly == 3331) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3343
      //------------------------------------------------------------------------
      if (PrimPoly == 3343) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3357
      //------------------------------------------------------------------------
      if (PrimPoly == 3357) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3367
      //------------------------------------------------------------------------
      if (PrimPoly == 3367) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3373
      //------------------------------------------------------------------------
      if (PrimPoly == 3373) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3393
      //------------------------------------------------------------------------
      if (PrimPoly == 3393) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3399
      //------------------------------------------------------------------------
      if (PrimPoly == 3399) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3413
      //------------------------------------------------------------------------
      if (PrimPoly == 3413) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3417
      //------------------------------------------------------------------------
      if (PrimPoly == 3417) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3427
      //------------------------------------------------------------------------
      if (PrimPoly == 3427) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3439
      //------------------------------------------------------------------------
      if (PrimPoly == 3439) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3441
      //------------------------------------------------------------------------
      if (PrimPoly == 3441) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3475
      //------------------------------------------------------------------------
      if (PrimPoly == 3475) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3487
      //------------------------------------------------------------------------
      if (PrimPoly == 3487) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3497
      //------------------------------------------------------------------------
      if (PrimPoly == 3497) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3515
      //------------------------------------------------------------------------
      if (PrimPoly == 3515) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3517
      //------------------------------------------------------------------------
      if (PrimPoly == 3517) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3529
      //------------------------------------------------------------------------
      if (PrimPoly == 3529) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3543
      //------------------------------------------------------------------------
      if (PrimPoly == 3543) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3547
      //------------------------------------------------------------------------
      if (PrimPoly == 3547) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3553
      //------------------------------------------------------------------------
      if (PrimPoly == 3553) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3559
      //------------------------------------------------------------------------
      if (PrimPoly == 3559) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3573
      //------------------------------------------------------------------------
      if (PrimPoly == 3573) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3589
      //------------------------------------------------------------------------
      if (PrimPoly == 3589) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3613
      //------------------------------------------------------------------------
      if (PrimPoly == 3613) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3617
      //------------------------------------------------------------------------
      if (PrimPoly == 3617) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3623
      //------------------------------------------------------------------------
      if (PrimPoly == 3623) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3627
      //------------------------------------------------------------------------
      if (PrimPoly == 3627) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3635
      //------------------------------------------------------------------------
      if (PrimPoly == 3635) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3641
      //------------------------------------------------------------------------
      if (PrimPoly == 3641) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3655
      //------------------------------------------------------------------------
      if (PrimPoly == 3655) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3659
      //------------------------------------------------------------------------
      if (PrimPoly == 3659) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3669
      //------------------------------------------------------------------------
      if (PrimPoly == 3669) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3679
      //------------------------------------------------------------------------
      if (PrimPoly == 3679) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3697
      //------------------------------------------------------------------------
      if (PrimPoly == 3697) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3707
      //------------------------------------------------------------------------
      if (PrimPoly == 3707) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3709
      //------------------------------------------------------------------------
      if (PrimPoly == 3709) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3713
      //------------------------------------------------------------------------
      if (PrimPoly == 3713) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3731
      //------------------------------------------------------------------------
      if (PrimPoly == 3731) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3743
      //------------------------------------------------------------------------
      if (PrimPoly == 3743) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3747
      //------------------------------------------------------------------------
      if (PrimPoly == 3747) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3771
      //------------------------------------------------------------------------
      if (PrimPoly == 3771) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3791
      //------------------------------------------------------------------------
      if (PrimPoly == 3791) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3805
      //------------------------------------------------------------------------
      if (PrimPoly == 3805) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3827
      //------------------------------------------------------------------------
      if (PrimPoly == 3827) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3833
      //------------------------------------------------------------------------
      if (PrimPoly == 3833) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3851
      //------------------------------------------------------------------------
      if (PrimPoly == 3851) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3865
      //------------------------------------------------------------------------
      if (PrimPoly == 3865) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3889
      //------------------------------------------------------------------------
      if (PrimPoly == 3889) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3895
      //------------------------------------------------------------------------
      if (PrimPoly == 3895) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3933
      //------------------------------------------------------------------------
      if (PrimPoly == 3933) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3947
      //------------------------------------------------------------------------
      if (PrimPoly == 3947) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3949
      //------------------------------------------------------------------------
      if (PrimPoly == 3949) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3957
      //------------------------------------------------------------------------
      if (PrimPoly == 3957) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3971
      //------------------------------------------------------------------------
      if (PrimPoly == 3971) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[16] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3985
      //------------------------------------------------------------------------
      if (PrimPoly == 3985) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3991
      //------------------------------------------------------------------------
      if (PrimPoly == 3991) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3995
      //------------------------------------------------------------------------
      if (PrimPoly == 3995) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[13] ^ M[14] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4007
      //------------------------------------------------------------------------
      if (PrimPoly == 4007) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4013
      //------------------------------------------------------------------------
      if (PrimPoly == 4013) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4021
      //------------------------------------------------------------------------
      if (PrimPoly == 4021) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4045
      //------------------------------------------------------------------------
      if (PrimPoly == 4045) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4051
      //------------------------------------------------------------------------
      if (PrimPoly == 4051) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[11] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[15] ^ M[16] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[16] ^ M[19] ^ M[20] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4069
      //------------------------------------------------------------------------
      if (PrimPoly == 4069) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[17] ^ M[18] ^ M[19] ;\n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4073
      //------------------------------------------------------------------------
      if (PrimPoly == 4073) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[11] ^ M[12] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[11] ^ M[16] ^ M[17] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[11] ^ M[17] ^ M[20] ;\n");
      }
   break;


   case(12):
/*      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4179
      //------------------------------------------------------------------------
      if (PrimPoly == 4179) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[18] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ;\n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ;\n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ;\n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ;\n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ;\n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[17] ^ M[22] ;\n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[18] ;\n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[19] ;\n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[17] ^ M[20] ;\n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[18] ^ M[21] ;\n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[17] ^ M[19] ^ M[22] ;\n");
      }*/
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4179
      //------------------------------------------------------------------------
      if (PrimPoly == 4179) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[17] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4201
      //------------------------------------------------------------------------
      if (PrimPoly == 4201) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[17] ^ M[18] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4219
      //------------------------------------------------------------------------
      if (PrimPoly == 4219) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4221
      //------------------------------------------------------------------------
      if (PrimPoly == 4221) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4249
      //------------------------------------------------------------------------
      if (PrimPoly == 4249) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4305
      //------------------------------------------------------------------------
      if (PrimPoly == 4305) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4331
      //------------------------------------------------------------------------
      if (PrimPoly == 4331) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4359
      //------------------------------------------------------------------------
      if (PrimPoly == 4359) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4383
      //------------------------------------------------------------------------
      if (PrimPoly == 4383) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4387
      //------------------------------------------------------------------------
      if (PrimPoly == 4387) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4411
      //------------------------------------------------------------------------
      if (PrimPoly == 4411) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4431
      //------------------------------------------------------------------------
      if (PrimPoly == 4431) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4439
      //------------------------------------------------------------------------
      if (PrimPoly == 4439) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4449
      //------------------------------------------------------------------------
      if (PrimPoly == 4449) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4459
      //------------------------------------------------------------------------
      if (PrimPoly == 4459) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4485
      //------------------------------------------------------------------------
      if (PrimPoly == 4485) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[16] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4531
      //------------------------------------------------------------------------
      if (PrimPoly == 4531) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4569
      //------------------------------------------------------------------------
      if (PrimPoly == 4569) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4575
      //------------------------------------------------------------------------
      if (PrimPoly == 4575) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4621
      //------------------------------------------------------------------------
      if (PrimPoly == 4621) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[17] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4663
      //------------------------------------------------------------------------
      if (PrimPoly == 4663) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4669
      //------------------------------------------------------------------------
      if (PrimPoly == 4669) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4711
      //------------------------------------------------------------------------
      if (PrimPoly == 4711) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4723
      //------------------------------------------------------------------------
      if (PrimPoly == 4723) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4735
      //------------------------------------------------------------------------
      if (PrimPoly == 4735) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4793
      //------------------------------------------------------------------------
      if (PrimPoly == 4793) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4801
      //------------------------------------------------------------------------
      if (PrimPoly == 4801) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4811
      //------------------------------------------------------------------------
      if (PrimPoly == 4811) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[16] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4879
      //------------------------------------------------------------------------
      if (PrimPoly == 4879) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4893
      //------------------------------------------------------------------------
      if (PrimPoly == 4893) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4897
      //------------------------------------------------------------------------
      if (PrimPoly == 4897) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4921
      //------------------------------------------------------------------------
      if (PrimPoly == 4921) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4927
      //------------------------------------------------------------------------
      if (PrimPoly == 4927) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4941
      //------------------------------------------------------------------------
      if (PrimPoly == 4941) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4977
      //------------------------------------------------------------------------
      if (PrimPoly == 4977) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5017
      //------------------------------------------------------------------------
      if (PrimPoly == 5017) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5027
      //------------------------------------------------------------------------
      if (PrimPoly == 5027) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[15] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5033
      //------------------------------------------------------------------------
      if (PrimPoly == 5033) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5127
      //------------------------------------------------------------------------
      if (PrimPoly == 5127) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5169
      //------------------------------------------------------------------------
      if (PrimPoly == 5169) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5175
      //------------------------------------------------------------------------
      if (PrimPoly == 5175) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5199
      //------------------------------------------------------------------------
      if (PrimPoly == 5199) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5213
      //------------------------------------------------------------------------
      if (PrimPoly == 5213) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5223
      //------------------------------------------------------------------------
      if (PrimPoly == 5223) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5237
      //------------------------------------------------------------------------
      if (PrimPoly == 5237) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5287
      //------------------------------------------------------------------------
      if (PrimPoly == 5287) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5293
      //------------------------------------------------------------------------
      if (PrimPoly == 5293) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5331
      //------------------------------------------------------------------------
      if (PrimPoly == 5331) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5391
      //------------------------------------------------------------------------
      if (PrimPoly == 5391) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5405
      //------------------------------------------------------------------------
      if (PrimPoly == 5405) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[17] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5453
      //------------------------------------------------------------------------
      if (PrimPoly == 5453) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5523
      //------------------------------------------------------------------------
      if (PrimPoly == 5523) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5573
      //------------------------------------------------------------------------
      if (PrimPoly == 5573) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5591
      //------------------------------------------------------------------------
      if (PrimPoly == 5591) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5597
      //------------------------------------------------------------------------
      if (PrimPoly == 5597) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[16] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5611
      //------------------------------------------------------------------------
      if (PrimPoly == 5611) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5641
      //------------------------------------------------------------------------
      if (PrimPoly == 5641) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5703
      //------------------------------------------------------------------------
      if (PrimPoly == 5703) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5717
      //------------------------------------------------------------------------
      if (PrimPoly == 5717) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5721
      //------------------------------------------------------------------------
      if (PrimPoly == 5721) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5797
      //------------------------------------------------------------------------
      if (PrimPoly == 5797) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5821
      //------------------------------------------------------------------------
      if (PrimPoly == 5821) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5909
      //------------------------------------------------------------------------
      if (PrimPoly == 5909) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5913
      //------------------------------------------------------------------------
      if (PrimPoly == 5913) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5955
      //------------------------------------------------------------------------
      if (PrimPoly == 5955) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5957
      //------------------------------------------------------------------------
      if (PrimPoly == 5957) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6005
      //------------------------------------------------------------------------
      if (PrimPoly == 6005) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6025
      //------------------------------------------------------------------------
      if (PrimPoly == 6025) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6061
      //------------------------------------------------------------------------
      if (PrimPoly == 6061) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6067
      //------------------------------------------------------------------------
      if (PrimPoly == 6067) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6079
      //------------------------------------------------------------------------
      if (PrimPoly == 6079) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6081
      //------------------------------------------------------------------------
      if (PrimPoly == 6081) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6231
      //------------------------------------------------------------------------
      if (PrimPoly == 6231) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6237
      //------------------------------------------------------------------------
      if (PrimPoly == 6237) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6289
      //------------------------------------------------------------------------
      if (PrimPoly == 6289) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6295
      //------------------------------------------------------------------------
      if (PrimPoly == 6295) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6329
      //------------------------------------------------------------------------
      if (PrimPoly == 6329) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6383
      //------------------------------------------------------------------------
      if (PrimPoly == 6383) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6427
      //------------------------------------------------------------------------
      if (PrimPoly == 6427) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6453
      //------------------------------------------------------------------------
      if (PrimPoly == 6453) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6465
      //------------------------------------------------------------------------
      if (PrimPoly == 6465) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6501
      //------------------------------------------------------------------------
      if (PrimPoly == 6501) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6523
      //------------------------------------------------------------------------
      if (PrimPoly == 6523) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6539
      //------------------------------------------------------------------------
      if (PrimPoly == 6539) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6577
      //------------------------------------------------------------------------
      if (PrimPoly == 6577) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6589
      //------------------------------------------------------------------------
      if (PrimPoly == 6589) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6601
      //------------------------------------------------------------------------
      if (PrimPoly == 6601) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6607
      //------------------------------------------------------------------------
      if (PrimPoly == 6607) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6631
      //------------------------------------------------------------------------
      if (PrimPoly == 6631) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6683
      //------------------------------------------------------------------------
      if (PrimPoly == 6683) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6699
      //------------------------------------------------------------------------
      if (PrimPoly == 6699) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6707
      //------------------------------------------------------------------------
      if (PrimPoly == 6707) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6761
      //------------------------------------------------------------------------
      if (PrimPoly == 6761) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6795
      //------------------------------------------------------------------------
      if (PrimPoly == 6795) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6865
      //------------------------------------------------------------------------
      if (PrimPoly == 6865) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6881
      //------------------------------------------------------------------------
      if (PrimPoly == 6881) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6901
      //------------------------------------------------------------------------
      if (PrimPoly == 6901) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6923
      //------------------------------------------------------------------------
      if (PrimPoly == 6923) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6931
      //------------------------------------------------------------------------
      if (PrimPoly == 6931) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6943
      //------------------------------------------------------------------------
      if (PrimPoly == 6943) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6999
      //------------------------------------------------------------------------
      if (PrimPoly == 6999) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7057
      //------------------------------------------------------------------------
      if (PrimPoly == 7057) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7079
      //------------------------------------------------------------------------
      if (PrimPoly == 7079) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7103
      //------------------------------------------------------------------------
      if (PrimPoly == 7103) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7105
      //------------------------------------------------------------------------
      if (PrimPoly == 7105) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7123
      //------------------------------------------------------------------------
      if (PrimPoly == 7123) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7173
      //------------------------------------------------------------------------
      if (PrimPoly == 7173) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7185
      //------------------------------------------------------------------------
      if (PrimPoly == 7185) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7191
      //------------------------------------------------------------------------
      if (PrimPoly == 7191) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7207
      //------------------------------------------------------------------------
      if (PrimPoly == 7207) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7245
      //------------------------------------------------------------------------
      if (PrimPoly == 7245) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7303
      //------------------------------------------------------------------------
      if (PrimPoly == 7303) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7327
      //------------------------------------------------------------------------
      if (PrimPoly == 7327) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[17] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7333
      //------------------------------------------------------------------------
      if (PrimPoly == 7333) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7355
      //------------------------------------------------------------------------
      if (PrimPoly == 7355) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7365
      //------------------------------------------------------------------------
      if (PrimPoly == 7365) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7369
      //------------------------------------------------------------------------
      if (PrimPoly == 7369) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7375
      //------------------------------------------------------------------------
      if (PrimPoly == 7375) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7411
      //------------------------------------------------------------------------
      if (PrimPoly == 7411) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7431
      //------------------------------------------------------------------------
      if (PrimPoly == 7431) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7459
      //------------------------------------------------------------------------
      if (PrimPoly == 7459) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7491
      //------------------------------------------------------------------------
      if (PrimPoly == 7491) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7505
      //------------------------------------------------------------------------
      if (PrimPoly == 7505) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7515
      //------------------------------------------------------------------------
      if (PrimPoly == 7515) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7541
      //------------------------------------------------------------------------
      if (PrimPoly == 7541) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7557
      //------------------------------------------------------------------------
      if (PrimPoly == 7557) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[16] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7561
      //------------------------------------------------------------------------
      if (PrimPoly == 7561) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7701
      //------------------------------------------------------------------------
      if (PrimPoly == 7701) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7705
      //------------------------------------------------------------------------
      if (PrimPoly == 7705) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[16] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7727
      //------------------------------------------------------------------------
      if (PrimPoly == 7727) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7749
      //------------------------------------------------------------------------
      if (PrimPoly == 7749) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7761
      //------------------------------------------------------------------------
      if (PrimPoly == 7761) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7783
      //------------------------------------------------------------------------
      if (PrimPoly == 7783) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[15] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[16] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7795
      //------------------------------------------------------------------------
      if (PrimPoly == 7795) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[14] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7823
      //------------------------------------------------------------------------
      if (PrimPoly == 7823) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[17] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7907
      //------------------------------------------------------------------------
      if (PrimPoly == 7907) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[13] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[15] ^ M[17] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7953
      //------------------------------------------------------------------------
      if (PrimPoly == 7953) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[15] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7963
      //------------------------------------------------------------------------
      if (PrimPoly == 7963) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[16] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[17] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7975
      //------------------------------------------------------------------------
      if (PrimPoly == 7975) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[14] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[17] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[16] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[20] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8049
      //------------------------------------------------------------------------
      if (PrimPoly == 8049) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[15] ^ M[16] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[13] ^ M[16] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[15] ^ M[17] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[13] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[13] ^ M[14] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[16] ^ M[18] ^ M[20] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8089
      //------------------------------------------------------------------------
      if (PrimPoly == 8089) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[14] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[15] ^ M[17] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[16] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8123
      //------------------------------------------------------------------------
      if (PrimPoly == 8123) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[12] ^ M[14] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[13] ^ M[15] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[14] ^ M[16] ^ M[18] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[15] ^ M[16] ^ M[19] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[17] ^ M[19] ^ M[21] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8125
      //------------------------------------------------------------------------
      if (PrimPoly == 8125) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[12] ^ M[13] ^ M[14] ^ M[15] ^ M[18] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[14] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[12] ^ M[15] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[12] ^ M[16] ^ M[17] ^ M[19] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[13] ^ M[17] ^ M[18] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[13] ^ M[14] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[14] ^ M[15] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[15] ^ M[16] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[16] ^ M[17] ^ M[18] ^ M[19] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[17] ^ M[19] ^ M[22] ; \n");
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8137
      //------------------------------------------------------------------------
      if (PrimPoly == 8137) {
         fprintf(OutFileMul, "   assign P[0] =  M[0] ^ M[12] ^ M[13] ^ M[19] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[1] =  M[1] ^ M[13] ^ M[14] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[2] =  M[2] ^ M[14] ^ M[15] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[3] =  M[3] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[19] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[4] =  M[4] ^ M[13] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[5] =  M[5] ^ M[14] ^ M[15] ^ M[17] ^ M[18] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[6] =  M[6] ^ M[12] ^ M[13] ^ M[15] ^ M[16] ^ M[18] ^ M[20] ^ M[21] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[7] =  M[7] ^ M[12] ^ M[14] ^ M[16] ^ M[17] ^ M[20] ^ M[22] ; \n");
         fprintf(OutFileMul, "   assign P[8] =  M[8] ^ M[12] ^ M[15] ^ M[17] ^ M[18] ^ M[19] ^ M[20] ; \n");
         fprintf(OutFileMul, "   assign P[9] =  M[9] ^ M[12] ^ M[16] ^ M[18] ; \n");
         fprintf(OutFileMul, "   assign P[10] =  M[10] ^ M[12] ^ M[17] ^ M[20] ^ M[21] ; \n");
         fprintf(OutFileMul, "   assign P[11] =  M[11] ^ M[12] ^ M[18] ^ M[19] ^ M[20] ^ M[22] ; \n");
      } 
   break;
   default:
         fprintf(OutFileMul, "   assign P[0] =  0;\n");
   break;
}


   fprintf(OutFileMul, "\n\n");
   fprintf(OutFileMul, "endmodule\n");

  //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileMul);



  //---------------------------------------------------------------
  // automatically convert Dos mode To Unix mode
  //---------------------------------------------------------------
  char ch;
  char temp[MAX_PATH]="\0";

  //Open the file for reading in binarymode.
  ifstream fp_read(strRsDecodeMult, ios_base::in | ios_base::binary);
  sprintf(temp, "%s.temp", strRsDecodeMult);
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
  remove(strRsDecodeMult);
  //Rename the temporary file to the input file.
  rename(temp, strRsDecodeMult);
  //Delete the temporary file.
  remove(temp);


  //---------------------------------------------------------------
  // clean string
  //---------------------------------------------------------------
  free(strRsDecodeMult);


}
