//===================================================================
// Module Name : RsGfMultiplier
// File Name   : RsGfMultiplier.cpp
// Function    : RS Decoder GF multiplier
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//
//#include <stdio.h>
//#include <stdlib.h>
//#include <cstdio>
//#include <cstdlib>

#include <stdio.h>
#include <stdlib.h>


#include <ctime>
void RsGfMultiplier(int *ppTab, int *ttTab, int *bbTab, int PrimPoly, int bitSymbol) {

   int mmTabSize = (bitSymbol*2) -1;


   int *mmTab;
   mmTab    = new int[mmTabSize];

   switch(bitSymbol)
      {
      case (3):
         //------------------------------------------------------------------------
         // bitSymbol = 3
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]);
         mmTab[4] = (ttTab[2] & bbTab[2]);
      break;


      case (4):
         //------------------------------------------------------------------------
         // bitSymbol = 4
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4] = (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]);
         mmTab[5] = (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]);
         mmTab[6] = (ttTab[3] & bbTab[3]);
      break;


      case (5):
         //------------------------------------------------------------------------
         // bitSymbol = 5
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4] = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5] = (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]);
         mmTab[6] = (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]);
         mmTab[7] = (ttTab[3] & bbTab[4]) ^ (ttTab[4] & bbTab[3]);
         mmTab[8] = (ttTab[4] & bbTab[4]);
      break;


      case (6):
         //------------------------------------------------------------------------
         // bitSymbol = 6
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4] = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5] = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6] = (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]);
         mmTab[7] = (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4]) ^ (ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]);
         mmTab[8] = (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]);
         mmTab[9] = (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]);
         mmTab[10] = (ttTab[5] & bbTab[5]);
      break;


      case (7):
         //------------------------------------------------------------------------
         // bitSymbol = 7
         //------------------------------------------------------------------------
         mmTab[0]  = (ttTab[0] & bbTab[0]);
         mmTab[1]  = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2]  = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3]  = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4]  = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5]  = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6]  = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7]  = (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4]) ^ (ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]);
         mmTab[8]  = (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]);
         mmTab[9]  = (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]);
         mmTab[10] = (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]);
         mmTab[11] = (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]);
         mmTab[12] = (ttTab[6] & bbTab[6]);
      break;


      case (8):
         //------------------------------------------------------------------------
         // bitSymbol = 8
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4] = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5] = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6] = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7] = ((ttTab[0] & bbTab[7]) ^ (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4])) ^ ((ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]) ^ (ttTab[7] & bbTab[0]));
         mmTab[8] = (ttTab[1] & bbTab[7]) ^ (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]) ^ (ttTab[7] & bbTab[1]);
         mmTab[9] = (ttTab[2] & bbTab[7]) ^ (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]) ^ (ttTab[7] & bbTab[2]);
         mmTab[10] = (ttTab[3] & bbTab[7]) ^ (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]) ^ (ttTab[7] & bbTab[3]);
         mmTab[11] = (ttTab[4] & bbTab[7]) ^ (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]) ^ (ttTab[7] & bbTab[4]);
         mmTab[12] = (ttTab[5] & bbTab[7]) ^ (ttTab[6] & bbTab[6]) ^ (ttTab[7] & bbTab[5]);
         mmTab[13] = (ttTab[6] & bbTab[7]) ^ (ttTab[7] & bbTab[6]);
         mmTab[14] = ttTab[7] & bbTab[7];
      break;


      case (9):
         //------------------------------------------------------------------------
         // bitSymbol = 9
         //------------------------------------------------------------------------
         mmTab[0] = ttTab[0] & bbTab[0];
         mmTab[1] = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2] = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3] = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4] = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5] = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6] = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7] = ((ttTab[0] & bbTab[7]) ^ (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4])) ^ ((ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]) ^ (ttTab[7] & bbTab[0]));
         mmTab[8] = (ttTab[1] & bbTab[7]) ^ (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]) ^ (ttTab[7] & bbTab[1]) ^ (ttTab[0] & bbTab[8]) ^ (ttTab[8] & bbTab[0]);
         mmTab[9] = (ttTab[2] & bbTab[7]) ^ (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]) ^ (ttTab[7] & bbTab[2]) ^ (ttTab[1] & bbTab[8]) ^ (ttTab[8] & bbTab[1]);
         mmTab[10] = (ttTab[3] & bbTab[7]) ^ (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]) ^ (ttTab[7] & bbTab[3]) ^ (ttTab[2] & bbTab[8]) ^ (ttTab[8] & bbTab[2]);
         mmTab[11] = (ttTab[4] & bbTab[7]) ^ (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]) ^ (ttTab[7] & bbTab[4]) ^ (ttTab[3] & bbTab[8]) ^ (ttTab[8] & bbTab[3]);
         mmTab[12] = (ttTab[5] & bbTab[7]) ^ (ttTab[6] & bbTab[6]) ^ (ttTab[7] & bbTab[5]) ^ (ttTab[4] & bbTab[8]) ^ (ttTab[8] & bbTab[4]);
         mmTab[13] = (ttTab[6] & bbTab[7]) ^ (ttTab[7] & bbTab[6]) ^ (ttTab[5] & bbTab[8]) ^ (ttTab[8] & bbTab[5]);
         mmTab[14] = (ttTab[7] & bbTab[7]) ^ (ttTab[8] & bbTab[6]) ^ (ttTab[6] & bbTab[8]);
         mmTab[15] = (ttTab[7] & bbTab[8]) ^ (ttTab[8] & bbTab[7]);
         mmTab[16] = ttTab[8] & bbTab[8];
      break;


      case (10):
         //------------------------------------------------------------------------
         // bitSymbol = 10
         //------------------------------------------------------------------------
         mmTab[0]  = ttTab[0] & bbTab[0];
         mmTab[1]  = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2]  = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3]  = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4]  = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5]  = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6]  = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7]  = ((ttTab[0] & bbTab[7]) ^ (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4])) ^ ((ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]) ^ (ttTab[7] & bbTab[0]));
         mmTab[8]  = (ttTab[1] & bbTab[7]) ^ (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]) ^ (ttTab[7] & bbTab[1]) ^ (ttTab[0] & bbTab[8]) ^ (ttTab[8] & bbTab[0]);
         mmTab[9]  = (ttTab[2] & bbTab[7]) ^ (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]) ^ (ttTab[7] & bbTab[2]) ^ (ttTab[1] & bbTab[8]) ^ (ttTab[8] & bbTab[1]) ^ (ttTab[9] & bbTab[0]) ^ (ttTab[0] & bbTab[9]);
         mmTab[10] = (ttTab[3] & bbTab[7]) ^ (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]) ^ (ttTab[7] & bbTab[3]) ^ (ttTab[2] & bbTab[8]) ^ (ttTab[8] & bbTab[2]) ^ (ttTab[9] & bbTab[1]) ^ (ttTab[1] & bbTab[9]);
         mmTab[11] = (ttTab[4] & bbTab[7]) ^ (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]) ^ (ttTab[7] & bbTab[4]) ^ (ttTab[3] & bbTab[8]) ^ (ttTab[8] & bbTab[3]) ^ (ttTab[9] & bbTab[2]) ^ (ttTab[2] & bbTab[9]);
         mmTab[12] = (ttTab[5] & bbTab[7]) ^ (ttTab[6] & bbTab[6]) ^ (ttTab[7] & bbTab[5]) ^ (ttTab[4] & bbTab[8]) ^ (ttTab[8] & bbTab[4]) ^ (ttTab[9] & bbTab[3]) ^ (ttTab[3] & bbTab[9]);
         mmTab[13] = (ttTab[6] & bbTab[7]) ^ (ttTab[7] & bbTab[6]) ^ (ttTab[5] & bbTab[8]) ^ (ttTab[8] & bbTab[5]) ^ (ttTab[9] & bbTab[4]) ^ (ttTab[4] & bbTab[9]);
         mmTab[14] = (ttTab[7] & bbTab[7]) ^ (ttTab[8] & bbTab[6]) ^ (ttTab[6] & bbTab[8]) ^ (ttTab[9] & bbTab[5]) ^ (ttTab[5] & bbTab[9]);
         mmTab[15] = (ttTab[7] & bbTab[8]) ^ (ttTab[8] & bbTab[7]) ^ (ttTab[9] & bbTab[6]) ^ (ttTab[6] & bbTab[9]);
         mmTab[16] = ttTab[8] & bbTab[8]  ^ (ttTab[9] & bbTab[7]) ^ (ttTab[7] & bbTab[9]);
         mmTab[17] = (ttTab[9] & bbTab[8]) ^ (ttTab[8] & bbTab[9]);
         mmTab[18] = ttTab[9] & bbTab[9];
      break;


      case (11):
         //------------------------------------------------------------------------
         // bitSymbol = 11
         //------------------------------------------------------------------------
         mmTab[0]  = ttTab[0] & bbTab[0];
         mmTab[1]  = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2]  = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3]  = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4]  = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5]  = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6]  = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7]  = ((ttTab[0] & bbTab[7]) ^ (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4])) ^ ((ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]) ^ (ttTab[7] & bbTab[0]));
         mmTab[8]  = (ttTab[1] & bbTab[7]) ^ (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]) ^ (ttTab[7] & bbTab[1]) ^ (ttTab[0] & bbTab[8]) ^ (ttTab[8] & bbTab[0]);
         mmTab[9]  = (ttTab[2] & bbTab[7]) ^ (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]) ^ (ttTab[7] & bbTab[2]) ^ (ttTab[1] & bbTab[8]) ^ (ttTab[8] & bbTab[1]) ^ (ttTab[9] & bbTab[0]) ^ (ttTab[0] & bbTab[9]);
         mmTab[10] = (ttTab[3] & bbTab[7]) ^ (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]) ^ (ttTab[7] & bbTab[3]) ^ (ttTab[2] & bbTab[8]) ^ (ttTab[8] & bbTab[2]) ^ (ttTab[9] & bbTab[1]) ^ (ttTab[1] & bbTab[9]) ^ (ttTab[10] & bbTab[0]) ^ (ttTab[0] & bbTab[10]);
         mmTab[11] = (ttTab[4] & bbTab[7]) ^ (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]) ^ (ttTab[7] & bbTab[4]) ^ (ttTab[3] & bbTab[8]) ^ (ttTab[8] & bbTab[3]) ^ (ttTab[9] & bbTab[2]) ^ (ttTab[2] & bbTab[9]) ^ (ttTab[10] & bbTab[1]) ^ (ttTab[1] & bbTab[10]);
         mmTab[12] = (ttTab[5] & bbTab[7]) ^ (ttTab[6] & bbTab[6]) ^ (ttTab[7] & bbTab[5]) ^ (ttTab[4] & bbTab[8]) ^ (ttTab[8] & bbTab[4]) ^ (ttTab[9] & bbTab[3]) ^ (ttTab[3] & bbTab[9]) ^ (ttTab[10] & bbTab[2]) ^ (ttTab[2] & bbTab[10]);
         mmTab[13] = (ttTab[6] & bbTab[7]) ^ (ttTab[7] & bbTab[6]) ^ (ttTab[5] & bbTab[8]) ^ (ttTab[8] & bbTab[5]) ^ (ttTab[9] & bbTab[4]) ^ (ttTab[4] & bbTab[9]) ^ (ttTab[10] & bbTab[3]) ^ (ttTab[3] & bbTab[10]);
         mmTab[14] = (ttTab[7] & bbTab[7]) ^ (ttTab[8] & bbTab[6]) ^ (ttTab[6] & bbTab[8]) ^ (ttTab[9] & bbTab[5]) ^ (ttTab[5] & bbTab[9]) ^ (ttTab[10] & bbTab[4]) ^ (ttTab[4] & bbTab[10]);
         mmTab[15] = (ttTab[7] & bbTab[8]) ^ (ttTab[8] & bbTab[7]) ^ (ttTab[9] & bbTab[6]) ^ (ttTab[6] & bbTab[9]) ^ (ttTab[10] & bbTab[5]) ^ (ttTab[5] & bbTab[10]);
         mmTab[16] = ttTab[8] & bbTab[8]  ^ (ttTab[9] & bbTab[7]) ^ (ttTab[7] & bbTab[9]) ^ (ttTab[10] & bbTab[6]) ^ (ttTab[6] & bbTab[10]);
         mmTab[17] = (ttTab[9] & bbTab[8]) ^ (ttTab[8] & bbTab[9])  ^ (ttTab[10] & bbTab[7]) ^ (ttTab[7] & bbTab[10]);
         mmTab[18] = ttTab[9] & bbTab[9] ^ (ttTab[10] & bbTab[8]) ^ (ttTab[8] & bbTab[10]);
         mmTab[19] = (ttTab[10] & bbTab[9]) ^ (ttTab[9] & bbTab[10]);
         mmTab[20] = ttTab[10] & bbTab[10];
      break;


      case (12):
         //------------------------------------------------------------------------
         // bitSymbol = 12
         //------------------------------------------------------------------------
         mmTab[0]  = ttTab[0] & bbTab[0];
         mmTab[1]  = (ttTab[0] & bbTab[1]) ^ (ttTab[1] & bbTab[0]);
         mmTab[2]  = (ttTab[0] & bbTab[2]) ^ (ttTab[1] & bbTab[1]) ^ (ttTab[2] & bbTab[0]);
         mmTab[3]  = (ttTab[0] & bbTab[3]) ^ (ttTab[1] & bbTab[2]) ^ (ttTab[2] & bbTab[1]) ^ (ttTab[3] & bbTab[0]);
         mmTab[4]  = (ttTab[0] & bbTab[4]) ^ (ttTab[1] & bbTab[3]) ^ (ttTab[2] & bbTab[2]) ^ (ttTab[3] & bbTab[1]) ^ (ttTab[4] & bbTab[0]);
         mmTab[5]  = (ttTab[0] & bbTab[5]) ^ (ttTab[1] & bbTab[4]) ^ (ttTab[2] & bbTab[3]) ^ (ttTab[3] & bbTab[2]) ^ (ttTab[4] & bbTab[1]) ^ (ttTab[5] & bbTab[0]);
         mmTab[6]  = (ttTab[0] & bbTab[6]) ^ (ttTab[1] & bbTab[5]) ^ (ttTab[2] & bbTab[4]) ^ (ttTab[3] & bbTab[3]) ^ (ttTab[4] & bbTab[2]) ^ (ttTab[5] & bbTab[1]) ^ (ttTab[6] & bbTab[0]);
         mmTab[7]  = ((ttTab[0] & bbTab[7]) ^ (ttTab[1] & bbTab[6]) ^ (ttTab[2] & bbTab[5]) ^ (ttTab[3] & bbTab[4])) ^ ((ttTab[4] & bbTab[3]) ^ (ttTab[5] & bbTab[2]) ^ (ttTab[6] & bbTab[1]) ^ (ttTab[7] & bbTab[0]));
         mmTab[8]  = (ttTab[1] & bbTab[7]) ^ (ttTab[2] & bbTab[6]) ^ (ttTab[3] & bbTab[5]) ^ (ttTab[4] & bbTab[4]) ^ (ttTab[5] & bbTab[3]) ^ (ttTab[6] & bbTab[2]) ^ (ttTab[7] & bbTab[1]) ^ (ttTab[0] & bbTab[8]) ^ (ttTab[8] & bbTab[0]);
         mmTab[9]  = (ttTab[2] & bbTab[7]) ^ (ttTab[3] & bbTab[6]) ^ (ttTab[4] & bbTab[5]) ^ (ttTab[5] & bbTab[4]) ^ (ttTab[6] & bbTab[3]) ^ (ttTab[7] & bbTab[2]) ^ (ttTab[1] & bbTab[8]) ^ (ttTab[8] & bbTab[1]) ^ (ttTab[9] & bbTab[0]) ^ (ttTab[0] & bbTab[9]);
         mmTab[10] = (ttTab[3] & bbTab[7]) ^ (ttTab[4] & bbTab[6]) ^ (ttTab[5] & bbTab[5]) ^ (ttTab[6] & bbTab[4]) ^ (ttTab[7] & bbTab[3]) ^ (ttTab[2] & bbTab[8]) ^ (ttTab[8] & bbTab[2]) ^ (ttTab[9] & bbTab[1]) ^ (ttTab[1] & bbTab[9]) ^ (ttTab[10] & bbTab[0]) ^ (ttTab[0] & bbTab[10]);
         mmTab[11] = (ttTab[4] & bbTab[7]) ^ (ttTab[5] & bbTab[6]) ^ (ttTab[6] & bbTab[5]) ^ (ttTab[7] & bbTab[4]) ^ (ttTab[3] & bbTab[8]) ^ (ttTab[8] & bbTab[3]) ^ (ttTab[9] & bbTab[2]) ^ (ttTab[2] & bbTab[9]) ^ (ttTab[10] & bbTab[1]) ^ (ttTab[1] & bbTab[10]) ^ (ttTab[11] & bbTab[0]) ^ (ttTab[0] & bbTab[11]);
         mmTab[12] = (ttTab[5] & bbTab[7]) ^ (ttTab[6] & bbTab[6]) ^ (ttTab[7] & bbTab[5]) ^ (ttTab[4] & bbTab[8]) ^ (ttTab[8] & bbTab[4]) ^ (ttTab[9] & bbTab[3]) ^ (ttTab[3] & bbTab[9]) ^ (ttTab[10] & bbTab[2]) ^ (ttTab[2] & bbTab[10]) ^ (ttTab[11] & bbTab[1]) ^ (ttTab[1] & bbTab[11]);
         mmTab[13] = (ttTab[6] & bbTab[7]) ^ (ttTab[7] & bbTab[6]) ^ (ttTab[5] & bbTab[8]) ^ (ttTab[8] & bbTab[5]) ^ (ttTab[9] & bbTab[4]) ^ (ttTab[4] & bbTab[9]) ^ (ttTab[10] & bbTab[3]) ^ (ttTab[3] & bbTab[10]) ^ (ttTab[11] & bbTab[2]) ^ (ttTab[2] & bbTab[11]);
         mmTab[14] = (ttTab[7] & bbTab[7]) ^ (ttTab[8] & bbTab[6]) ^ (ttTab[6] & bbTab[8]) ^ (ttTab[9] & bbTab[5]) ^ (ttTab[5] & bbTab[9]) ^ (ttTab[10] & bbTab[4]) ^ (ttTab[4] & bbTab[10]) ^ (ttTab[11] & bbTab[3]) ^ (ttTab[3] & bbTab[11]);
         mmTab[15] = (ttTab[7] & bbTab[8]) ^ (ttTab[8] & bbTab[7]) ^ (ttTab[9] & bbTab[6]) ^ (ttTab[6] & bbTab[9]) ^ (ttTab[10] & bbTab[5]) ^ (ttTab[5] & bbTab[10]) ^ (ttTab[11] & bbTab[4]) ^ (ttTab[4] & bbTab[11]);
         mmTab[16] = ttTab[8] & bbTab[8]  ^ (ttTab[9] & bbTab[7]) ^ (ttTab[7] & bbTab[9]) ^ (ttTab[10] & bbTab[6]) ^ (ttTab[6] & bbTab[10]) ^ (ttTab[11] & bbTab[5]) ^ (ttTab[5] & bbTab[11]);
         mmTab[17] = (ttTab[9] & bbTab[8]) ^ (ttTab[8] & bbTab[9])  ^ (ttTab[10] & bbTab[7]) ^ (ttTab[7] & bbTab[10]) ^ (ttTab[11] & bbTab[6]) ^ (ttTab[6] & bbTab[11]);
         mmTab[18] = ttTab[9] & bbTab[9] ^ (ttTab[10] & bbTab[8]) ^ (ttTab[8] & bbTab[10]) ^ (ttTab[11] & bbTab[7]) ^ (ttTab[7] & bbTab[11]);
         mmTab[19] = (ttTab[10] & bbTab[9]) ^ (ttTab[9] & bbTab[10]) ^ (ttTab[11] & bbTab[8]) ^ (ttTab[8] & bbTab[11]);
         mmTab[20] = ttTab[10] & bbTab[10] ^ (ttTab[11] & bbTab[9]) ^ (ttTab[9] & bbTab[11]);
         mmTab[21] = (ttTab[11] & bbTab[10]) ^ (ttTab[10] & bbTab[11]);
         mmTab[22] = ttTab[11] & bbTab[11];
      break;


      default:
         mmTab[0] = 0;
      break;

   }





switch(bitSymbol){
   case (3):
      //------------------------------------------------------------------------
      // bitSymbol = 3, Primpoly = 11
      //------------------------------------------------------------------------
      if (PrimPoly == 11) {
         ppTab[0] =  mmTab[0] ^ mmTab[3] ;
         ppTab[1] =  mmTab[1] ^ mmTab[3] ^ mmTab[4] ;
         ppTab[2] =  mmTab[2] ^ mmTab[4] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 3, Primpoly = 13
      //------------------------------------------------------------------------
      if (PrimPoly == 13) {
         ppTab[0] =  mmTab[0] ^ mmTab[3] ^ mmTab[4] ;
         ppTab[1] =  mmTab[1] ^ mmTab[4] ;
         ppTab[2] =  mmTab[2] ^ mmTab[3] ^ mmTab[4] ;
      }
   break;
   case (4):
      //------------------------------------------------------------------------
      // bitSymbol = 4, Primpoly = 19
      //------------------------------------------------------------------------
      if (PrimPoly == 19) {
         ppTab[0] =  mmTab[0] ^ mmTab[4] ;
         ppTab[1] =  mmTab[1] ^ mmTab[4] ^ mmTab[5] ;
         ppTab[2] =  mmTab[2] ^ mmTab[5] ^ mmTab[6] ;
         ppTab[3] =  mmTab[3] ^ mmTab[6] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 4, Primpoly = 25
      //------------------------------------------------------------------------
      if (PrimPoly == 25) {
         ppTab[0] =  mmTab[0] ^ mmTab[4] ^ mmTab[5] ^ mmTab[6] ;
         ppTab[1] =  mmTab[1] ^ mmTab[5] ^ mmTab[6] ;
         ppTab[2] =  mmTab[2] ^ mmTab[6] ;
         ppTab[3] =  mmTab[3] ^ mmTab[4] ^ mmTab[5] ^ mmTab[6] ;
      }
   break;
   case (5):
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 37
      //------------------------------------------------------------------------
      if (PrimPoly == 37) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[8] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ;
         ppTab[2] =  mmTab[2] ^ mmTab[5] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[3] =  mmTab[3] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[7] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 41
      //------------------------------------------------------------------------
      if (PrimPoly == 41) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[7] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[2] =  mmTab[2] ^ mmTab[7] ;
         ppTab[3] =  mmTab[3] ^ mmTab[5] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[6] ^ mmTab[8] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 47
      //------------------------------------------------------------------------
      if (PrimPoly == 47) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[1] =  mmTab[1] ^ mmTab[5] ^ mmTab[6] ^ mmTab[7] ;
         ppTab[2] =  mmTab[2] ^ mmTab[5] ^ mmTab[6] ;
         ppTab[3] =  mmTab[3] ^ mmTab[5] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[6] ^ mmTab[7] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 55
      //------------------------------------------------------------------------
      if (PrimPoly == 55) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[6] ^ mmTab[7] ;
         ppTab[1] =  mmTab[1] ^ mmTab[5] ^ mmTab[8] ;
         ppTab[2] =  mmTab[2] ^ mmTab[5] ^ mmTab[7] ;
         ppTab[3] =  mmTab[3] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[5] ^ mmTab[6] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 59
      //------------------------------------------------------------------------
      if (PrimPoly == 59) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[1] =  mmTab[1] ^ mmTab[5] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[2] =  mmTab[2] ^ mmTab[6] ^ mmTab[8] ;
         ppTab[3] =  mmTab[3] ^ mmTab[5] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[5] ^ mmTab[7] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 5, Primpoly = 61
      //------------------------------------------------------------------------
      if (PrimPoly == 61) {
         ppTab[0] =  mmTab[0] ^ mmTab[5] ^ mmTab[6] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[7] ;
         ppTab[2] =  mmTab[2] ^ mmTab[5] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[3] =  mmTab[3] ^ mmTab[5] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[4] =  mmTab[4] ^ mmTab[5] ^ mmTab[8] ;
      }
   break;
   case (6):
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 67
      //------------------------------------------------------------------------
      if (PrimPoly == 67) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[7] ;
         ppTab[2] =  mmTab[2] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[3] =  mmTab[3] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 91
      //------------------------------------------------------------------------
      if (PrimPoly == 91) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[2] =  mmTab[2] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[3] =  mmTab[3] ^ mmTab[6] ;
         ppTab[4] =  mmTab[4] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[5] =  mmTab[5] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 97
      //------------------------------------------------------------------------
      if (PrimPoly == 97) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[1] =  mmTab[1] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[2] =  mmTab[2] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ;
         ppTab[5] =  mmTab[5] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 103
      //------------------------------------------------------------------------
      if (PrimPoly == 103) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[10] ;
         ppTab[2] =  mmTab[2] ^ mmTab[6] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[3] =  mmTab[3] ^ mmTab[7] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[4] =  mmTab[4] ^ mmTab[8] ^ mmTab[10] ;
         ppTab[5] =  mmTab[5] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 109
      //------------------------------------------------------------------------
      if (PrimPoly == 109) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ^ mmTab[7] ^ mmTab[8] ;
         ppTab[1] =  mmTab[1] ^ mmTab[7] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[2] =  mmTab[2] ^ mmTab[6] ^ mmTab[7] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[3] =  mmTab[3] ^ mmTab[6] ^ mmTab[10] ;
         ppTab[4] =  mmTab[4] ^ mmTab[7] ;
         ppTab[5] =  mmTab[5] ^ mmTab[6] ^ mmTab[7] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 6, Primpoly = 115
      //------------------------------------------------------------------------
      if (PrimPoly == 115) {
         ppTab[0] =  mmTab[0] ^ mmTab[6] ^ mmTab[7] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[1] =  mmTab[1] ^ mmTab[6] ^ mmTab[8] ^ mmTab[9] ;
         ppTab[2] =  mmTab[2] ^ mmTab[7] ^ mmTab[9] ^ mmTab[10] ;
         ppTab[3] =  mmTab[3] ^ mmTab[8] ^ mmTab[10] ;
         ppTab[4] =  mmTab[4] ^ mmTab[6] ^ mmTab[7] ^ mmTab[10] ;
         ppTab[5] =  mmTab[5] ^ mmTab[6] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ;
      }
   break;
   case (7):
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 131
      //------------------------------------------------------------------------
      if (PrimPoly == 131) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[8] ;
         ppTab[2] =  mmTab[2] ^mmTab[8] ^mmTab[9] ;
         ppTab[3] =  mmTab[3] ^mmTab[9] ^mmTab[10] ;
         ppTab[4] =  mmTab[4] ^mmTab[10] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 137
      //------------------------------------------------------------------------
      if (PrimPoly == 137) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[11] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[9] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[10] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[9] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[10] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 143
      //------------------------------------------------------------------------
      if (PrimPoly == 143) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[8] ^mmTab[11] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 145
      //------------------------------------------------------------------------
      if (PrimPoly == 145) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[10] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[11] ;
         ppTab[2] =  mmTab[2] ^mmTab[9] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[10] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[10] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[9] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 157
      //------------------------------------------------------------------------
      if (PrimPoly == 157) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[8] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 167
      //------------------------------------------------------------------------
      if (PrimPoly == 167) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ^mmTab[10] ;
         ppTab[3] =  mmTab[3] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[8] ^mmTab[10] ^mmTab[11] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 171
      //------------------------------------------------------------------------
      if (PrimPoly == 171) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[9] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ;
         ppTab[2] =  mmTab[2] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[8] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 185
      //------------------------------------------------------------------------
      if (PrimPoly == 185) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[9] ^mmTab[10] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[10] ^mmTab[11] ;
         ppTab[2] =  mmTab[2] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[9] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[9] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[8] ;
         ppTab[6] =  mmTab[6] ^mmTab[8] ^mmTab[9] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 191
      //------------------------------------------------------------------------
      if (PrimPoly == 191) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[11] ;
         ppTab[6] =  mmTab[6] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 193
      //------------------------------------------------------------------------
      if (PrimPoly == 193) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 203
      //------------------------------------------------------------------------
      if (PrimPoly == 203) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[8] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 211
      //------------------------------------------------------------------------
      if (PrimPoly == 211) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[9] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 213
      //------------------------------------------------------------------------
      if (PrimPoly == 213) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[11] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 229
      //------------------------------------------------------------------------
      if (PrimPoly == 229) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ;
         ppTab[3] =  mmTab[3] ^mmTab[8] ^mmTab[9] ^mmTab[10] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[8] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 239
      //------------------------------------------------------------------------
      if (PrimPoly == 239) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[10] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[11] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[10] ;
         ppTab[4] =  mmTab[4] ^mmTab[8] ^mmTab[11] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 241
      //------------------------------------------------------------------------
      if (PrimPoly == 241) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[9] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[9] ^mmTab[10] ;
         ppTab[3] =  mmTab[3] ^mmTab[10] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[10] ^mmTab[11] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 247
      //------------------------------------------------------------------------
      if (PrimPoly == 247) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ^mmTab[11] ;
         ppTab[1] =  mmTab[1] ^mmTab[7] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[3] =  mmTab[3] ^mmTab[8] ^mmTab[11] ^mmTab[12] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[10] ^mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 7, Primpoly = 253
      //------------------------------------------------------------------------
      if (PrimPoly == 253) {
         ppTab[0] =  mmTab[0] ^mmTab[7] ^mmTab[8] ;
         ppTab[1] =  mmTab[1] ^mmTab[8] ^mmTab[9] ;
         ppTab[2] =  mmTab[2] ^mmTab[7] ^mmTab[8] ^mmTab[9] ^mmTab[10] ;
         ppTab[3] =  mmTab[3] ^mmTab[7] ^mmTab[9] ^mmTab[10] ^mmTab[11] ;
         ppTab[4] =  mmTab[4] ^mmTab[7] ^mmTab[10] ^mmTab[11] ^mmTab[12] ;
         ppTab[5] =  mmTab[5] ^mmTab[7] ^mmTab[11] ^mmTab[12] ;
         ppTab[6] =  mmTab[6] ^mmTab[7] ^mmTab[12] ;
      }
   break;
   case (8):
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 285
      //------------------------------------------------------------------------
      if (PrimPoly == 285) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[9] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[8] ^ mmTab[9] ^ mmTab[11] ^ mmTab[12];
         ppTab[4]	= mmTab[4] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[9] ^ mmTab[10] ^ mmTab[11];
         ppTab[6]	= mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[7]	= mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 299
      //------------------------------------------------------------------------
      if (PrimPoly == 299) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[8] ^ mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[2]	= mmTab[2] ^ mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8] ^ mmTab[10];
         ppTab[4]	= mmTab[4] ^ mmTab[9] ^ mmTab[11];
         ppTab[5]	= mmTab[5] ^ mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 301
      //------------------------------------------------------------------------
      if (PrimPoly == 301) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[11] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[9] ^ mmTab[12] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8] ^ mmTab[10] ^ mmTab[11];
         ppTab[3]	= mmTab[3] ^ mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13];
         ppTab[4]	= mmTab[4] ^ mmTab[9] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[8] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[9] ^ mmTab[11] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[10] ^ mmTab[12];   
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 333
      //------------------------------------------------------------------------
      if (PrimPoly == 333) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[13] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11];
         ppTab[7]	= mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 351
      //------------------------------------------------------------------------
      if (PrimPoly == 351) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[10] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[8] ^ mmTab[9];
         ppTab[5]	= mmTab[5] ^ mmTab[9] ^ mmTab[10];
         ppTab[6]	= mmTab[6] ^ mmTab[8] ^ mmTab[11] ^ mmTab[13];
         ppTab[7]	= mmTab[7] ^ mmTab[9] ^ mmTab[12] ^ mmTab[14];   
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 355
      //------------------------------------------------------------------------
      if (PrimPoly == 355) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[1]	= mmTab[1] ^ mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13];
         ppTab[2]	= mmTab[2] ^ mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[4]	= mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[5]	= mmTab[5] ^ mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[8] ^ mmTab[9] ^ mmTab[10] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[9] ^ mmTab[10] ^ mmTab[11];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 357
      //------------------------------------------------------------------------
      if (PrimPoly == 357) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[10] ^ mmTab[13];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[12];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 361
      //------------------------------------------------------------------------
      if (PrimPoly == 361) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 369
      //------------------------------------------------------------------------
      if (PrimPoly == 369) {
         ppTab[0]	= mmTab[0] ^ mmTab[8] ^ mmTab[10] ^ mmTab[11];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12];
         ppTab[2]	= mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14];   
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 391
      //------------------------------------------------------------------------
      if (PrimPoly == 391) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[8]  ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[12] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 397
      //------------------------------------------------------------------------
      if (PrimPoly == 397) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13];
         ppTab[5]	= mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[11] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11];   
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 425
      //------------------------------------------------------------------------
      if (PrimPoly == 425) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11];
         ppTab[6]	= mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 451
      //------------------------------------------------------------------------
      if (PrimPoly == 451) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13];
         ppTab[4]	= mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[12] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13];   
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 463
      //------------------------------------------------------------------------
      if (PrimPoly == 463) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 487
      //------------------------------------------------------------------------
      if (PrimPoly == 487) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[12];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[3]	= mmTab[3] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13];
         ppTab[4]	= mmTab[4] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[10];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 8, Primpoly = 501
      //------------------------------------------------------------------------
      if (PrimPoly == 501) {
         ppTab[0]	= mmTab[0] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[13];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14];
         ppTab[2]	= mmTab[2] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13];
         ppTab[3]	= mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14];
         ppTab[4]	= mmTab[4] ^ mmTab[8]  ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[5]	= mmTab[5] ^ mmTab[8]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12];
         ppTab[6]	= mmTab[6] ^ mmTab[8]  ^ mmTab[11] ^ mmTab[12];
         ppTab[7]	= mmTab[7] ^ mmTab[8]  ^ mmTab[12];
      }
   break;
   
   
   
   //------------------------------------------------------------------------
   // bitSymbol = 9
   //------------------------------------------------------------------------
   case (9):
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 529
      //------------------------------------------------------------------------
      if (PrimPoly == 529) {
         ppTab[0]	= mmTab[0] ^ mmTab[9]  ^ mmTab[14];
         ppTab[1]	= mmTab[1] ^ mmTab[10] ^ mmTab[15];
         ppTab[2]	= mmTab[2] ^ mmTab[11] ^ mmTab[16];
         ppTab[3]	= mmTab[3] ^ mmTab[12];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14];
         ppTab[5]	= mmTab[5] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15];
         ppTab[6]	= mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16];
         ppTab[7]	= mmTab[7] ^ mmTab[12] ^ mmTab[16];
         ppTab[8]	= mmTab[8] ^ mmTab[13];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 539
      //------------------------------------------------------------------------
      if (PrimPoly == 539) {
         ppTab[0]	= mmTab[0] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[15];
         ppTab[1]	= mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[16];
         ppTab[2]	= mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15];
         ppTab[3]	= mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16];
         ppTab[4]	= mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16];
         ppTab[5]	= mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15];
         ppTab[6]	= mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16];
         ppTab[7]	= mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16];
         ppTab[8]	= mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16];
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 545
      //------------------------------------------------------------------------
      if (PrimPoly == 545) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[13]  ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 557
      //------------------------------------------------------------------------
      if (PrimPoly == 557) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 563
      //------------------------------------------------------------------------
      if (PrimPoly == 563) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 601
      //------------------------------------------------------------------------
      if (PrimPoly == 601) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ;
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 607
      //------------------------------------------------------------------------
      if (PrimPoly == 607) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 617
      //------------------------------------------------------------------------
      if (PrimPoly == 617) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 623
      //------------------------------------------------------------------------
      if (PrimPoly == 623) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 631
      //------------------------------------------------------------------------
      if (PrimPoly == 631) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 637
      //------------------------------------------------------------------------
      if (PrimPoly == 637) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 647
      //------------------------------------------------------------------------
      if (PrimPoly == 647) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 661
      //------------------------------------------------------------------------
      if (PrimPoly == 661) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 675
      //------------------------------------------------------------------------
      if (PrimPoly == 675) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[14] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 677
      //------------------------------------------------------------------------
      if (PrimPoly == 677) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 687
      //------------------------------------------------------------------------
      if (PrimPoly == 687) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 695
      //------------------------------------------------------------------------
      if (PrimPoly == 695) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[12] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 701
      //------------------------------------------------------------------------
      if (PrimPoly == 701) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 719
      //------------------------------------------------------------------------
      if (PrimPoly == 719) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 721
      //------------------------------------------------------------------------
      if (PrimPoly == 721) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[12] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 731
      //------------------------------------------------------------------------
      if (PrimPoly == 731) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 757
      //------------------------------------------------------------------------
      if (PrimPoly == 757) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 761
      //------------------------------------------------------------------------
      if (PrimPoly == 761) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 787
      //------------------------------------------------------------------------
      if (PrimPoly == 787) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
      }


      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 789
      //------------------------------------------------------------------------
      if (PrimPoly == 789) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }

      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 799
      //------------------------------------------------------------------------
      if (PrimPoly == 799) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
      }


      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 803
      //------------------------------------------------------------------------
      if (PrimPoly == 803) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 817
      //------------------------------------------------------------------------
      if (PrimPoly == 817) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 827
      //------------------------------------------------------------------------
      if (PrimPoly == 827) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 847
      //------------------------------------------------------------------------
      if (PrimPoly == 847) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 859
      //------------------------------------------------------------------------
      if (PrimPoly == 859) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 865
      //------------------------------------------------------------------------
      if (PrimPoly == 865) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[13] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 875
      //------------------------------------------------------------------------
      if (PrimPoly == 875) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[13] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 877
      //------------------------------------------------------------------------
      if (PrimPoly == 877) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 883
      //------------------------------------------------------------------------
      if (PrimPoly == 883) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 895
      //------------------------------------------------------------------------
      if (PrimPoly == 895) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 901
      //------------------------------------------------------------------------
      if (PrimPoly == 901) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 911
      //------------------------------------------------------------------------
      if (PrimPoly == 911) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 949
      //------------------------------------------------------------------------
      if (PrimPoly == 949) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 953
      //------------------------------------------------------------------------
      if (PrimPoly == 953) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 967
      //------------------------------------------------------------------------
      if (PrimPoly == 967) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 971
      //------------------------------------------------------------------------
      if (PrimPoly == 971) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 973
      //------------------------------------------------------------------------
      if (PrimPoly == 973) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 981
      //------------------------------------------------------------------------
      if (PrimPoly == 981) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[16] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 985
      //------------------------------------------------------------------------
      if (PrimPoly == 985) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 995
      //------------------------------------------------------------------------
      if (PrimPoly == 995) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      
      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 1001
      //------------------------------------------------------------------------
      if (PrimPoly == 1001) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[16] ;
      }

      //------------------------------------------------------------------------
      // bitSymbol = 9, Primpoly = 1019
      //------------------------------------------------------------------------
      if (PrimPoly == 1019) {
         ppTab[0] =  mmTab[0] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ;
         ppTab[3] =  mmTab[3] ^ mmTab[9]  ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[9]  ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[9]  ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[9]  ^ mmTab[13] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[9]  ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[9]  ^ mmTab[15] ;
      }
   break;




   case (10):
   //------------------------------------------------------------------------
   // bitSymbol = 10
   //------------------------------------------------------------------------
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1033
      //------------------------------------------------------------------------
      if (PrimPoly == 1033) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1051
      //------------------------------------------------------------------------
      if (PrimPoly == 1051) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
      }
      
      
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1063
      //------------------------------------------------------------------------
      if (PrimPoly == 1063) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1069
      //------------------------------------------------------------------------
      if (PrimPoly == 1069) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1125
      //------------------------------------------------------------------------
      if (PrimPoly == 1125) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1135
      //------------------------------------------------------------------------
      if (PrimPoly == 1135) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1153
      //------------------------------------------------------------------------
      if (PrimPoly == 1153) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1163
      //------------------------------------------------------------------------
      if (PrimPoly == 1163) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1221
      //------------------------------------------------------------------------
      if (PrimPoly == 1221) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1239
      //------------------------------------------------------------------------
      if (PrimPoly == 1239) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1255
      //------------------------------------------------------------------------
      if (PrimPoly == 1255) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1267
      //------------------------------------------------------------------------
      if (PrimPoly == 1267) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1279
      //------------------------------------------------------------------------
      if (PrimPoly == 1279) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1293
      //------------------------------------------------------------------------
      if (PrimPoly == 1293) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1305
      //------------------------------------------------------------------------
      if (PrimPoly == 1305) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1315
      //------------------------------------------------------------------------
      if (PrimPoly == 1315) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1329
      //------------------------------------------------------------------------
      if (PrimPoly == 1329) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1341
      //------------------------------------------------------------------------
      if (PrimPoly == 1341) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1347
      //------------------------------------------------------------------------
      if (PrimPoly == 1347) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1367
      //------------------------------------------------------------------------
      if (PrimPoly == 1367) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1387
      //------------------------------------------------------------------------
      if (PrimPoly == 1387) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1413
      //------------------------------------------------------------------------
      if (PrimPoly == 1413) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1423
      //------------------------------------------------------------------------
      if (PrimPoly == 1423) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1431
      //------------------------------------------------------------------------
      if (PrimPoly == 1431) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1441
      //------------------------------------------------------------------------
      if (PrimPoly == 1441) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1479
      //------------------------------------------------------------------------
      if (PrimPoly == 1479) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1509
      //------------------------------------------------------------------------
      if (PrimPoly == 1509) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1527
      //------------------------------------------------------------------------
      if (PrimPoly == 1527) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1531
      //------------------------------------------------------------------------
      if (PrimPoly == 1531) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1555
      //------------------------------------------------------------------------
      if (PrimPoly == 1555) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1557
      //------------------------------------------------------------------------
      if (PrimPoly == 1557) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1573
      //------------------------------------------------------------------------
      if (PrimPoly == 1573) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1591
      //------------------------------------------------------------------------
      if (PrimPoly == 1591) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1603
      //------------------------------------------------------------------------
      if (PrimPoly == 1603) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1615
      //------------------------------------------------------------------------
      if (PrimPoly == 1615) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1627
      //------------------------------------------------------------------------
      if (PrimPoly == 1627) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1657
      //------------------------------------------------------------------------
      if (PrimPoly == 1657) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1663
      //------------------------------------------------------------------------
      if (PrimPoly == 1663) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1673
      //------------------------------------------------------------------------
      if (PrimPoly == 1673) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1717
      //------------------------------------------------------------------------
      if (PrimPoly == 1717) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1729
      //------------------------------------------------------------------------
      if (PrimPoly == 1729) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1747
      //------------------------------------------------------------------------
      if (PrimPoly == 1747) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1759
      //------------------------------------------------------------------------
      if (PrimPoly == 1759) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1789
      //------------------------------------------------------------------------
      if (PrimPoly == 1789) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1815
      //------------------------------------------------------------------------
      if (PrimPoly == 1815) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1821
      //------------------------------------------------------------------------
      if (PrimPoly == 1821) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1825
      //------------------------------------------------------------------------
      if (PrimPoly == 1825) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1849
      //------------------------------------------------------------------------
      if (PrimPoly == 1849) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1863
      //------------------------------------------------------------------------
      if (PrimPoly == 1863) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1869
      //------------------------------------------------------------------------
      if (PrimPoly == 1869) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1877
      //------------------------------------------------------------------------
      if (PrimPoly == 1877) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1881
      //------------------------------------------------------------------------
      if (PrimPoly == 1881) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1891
      //------------------------------------------------------------------------
      if (PrimPoly == 1891) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1917
      //------------------------------------------------------------------------
      if (PrimPoly == 1917) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1933
      //------------------------------------------------------------------------
      if (PrimPoly == 1933) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1939
      //------------------------------------------------------------------------
      if (PrimPoly == 1939) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 1969
      //------------------------------------------------------------------------
      if (PrimPoly == 1969) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2011
      //------------------------------------------------------------------------
      if (PrimPoly == 2011) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2035
      //------------------------------------------------------------------------
      if (PrimPoly == 2035) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[10] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 10, Primpoly = 2041
      //------------------------------------------------------------------------
      if (PrimPoly == 2041) {
         ppTab[0] =  mmTab[0] ^ mmTab[10] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[3] =  mmTab[3] ^ mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[10] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[10] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[10] ^ mmTab[17] ^ mmTab[18] ;
      }
   break;

   case (11):
   //------------------------------------------------------------------------
   // bitSymbol = 11
   //------------------------------------------------------------------------
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2053
      //------------------------------------------------------------------------
      if (PrimPoly == 2053) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2071
      //------------------------------------------------------------------------
      if (PrimPoly == 2071) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2091
      //------------------------------------------------------------------------
      if (PrimPoly == 2091) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2093
      //------------------------------------------------------------------------
      if (PrimPoly == 2093) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2119
      //------------------------------------------------------------------------
      if (PrimPoly == 2119) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2147
      //------------------------------------------------------------------------
      if (PrimPoly == 2147) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2149
      //------------------------------------------------------------------------
      if (PrimPoly == 2149) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2161
      //------------------------------------------------------------------------
      if (PrimPoly == 2161) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2171
      //------------------------------------------------------------------------
      if (PrimPoly == 2171) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2189
      //------------------------------------------------------------------------
      if (PrimPoly == 2189) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2197
      //------------------------------------------------------------------------
      if (PrimPoly == 2197) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2207
      //------------------------------------------------------------------------
      if (PrimPoly == 2207) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2217
      //------------------------------------------------------------------------
      if (PrimPoly == 2217) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2225
      //------------------------------------------------------------------------
      if (PrimPoly == 2225) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2255
      //------------------------------------------------------------------------
      if (PrimPoly == 2255) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2257
      //------------------------------------------------------------------------
      if (PrimPoly == 2257) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2273
      //------------------------------------------------------------------------
      if (PrimPoly == 2273) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2279
      //------------------------------------------------------------------------
      if (PrimPoly == 2279) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2283
      //------------------------------------------------------------------------
      if (PrimPoly == 2283) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2293
      //------------------------------------------------------------------------
      if (PrimPoly == 2293) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2317
      //------------------------------------------------------------------------
      if (PrimPoly == 2317) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2323
      //------------------------------------------------------------------------
      if (PrimPoly == 2323) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2341
      //------------------------------------------------------------------------
      if (PrimPoly == 2341) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2345
      //------------------------------------------------------------------------
      if (PrimPoly == 2345) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2363
      //------------------------------------------------------------------------
      if (PrimPoly == 2363) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2365
      //------------------------------------------------------------------------
      if (PrimPoly == 2365) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2373
      //------------------------------------------------------------------------
      if (PrimPoly == 2373) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2377
      //------------------------------------------------------------------------
      if (PrimPoly == 2377) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2385
      //------------------------------------------------------------------------
      if (PrimPoly == 2385) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2395
      //------------------------------------------------------------------------
      if (PrimPoly == 2395) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2419
      //------------------------------------------------------------------------
      if (PrimPoly == 2419) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2421
      //------------------------------------------------------------------------
      if (PrimPoly == 2421) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2431
      //------------------------------------------------------------------------
      if (PrimPoly == 2431) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2435
      //------------------------------------------------------------------------
      if (PrimPoly == 2435) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2447
      //------------------------------------------------------------------------
      if (PrimPoly == 2447) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2475
      //------------------------------------------------------------------------
      if (PrimPoly == 2475) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2477
      //------------------------------------------------------------------------
      if (PrimPoly == 2477) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2489
      //------------------------------------------------------------------------
      if (PrimPoly == 2489) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2503
      //------------------------------------------------------------------------
      if (PrimPoly == 2503) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2521
      //------------------------------------------------------------------------
      if (PrimPoly == 2521) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2533
      //------------------------------------------------------------------------
      if (PrimPoly == 2533) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2551
      //------------------------------------------------------------------------
      if (PrimPoly == 2551) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2561
      //------------------------------------------------------------------------
      if (PrimPoly == 2561) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2567
      //------------------------------------------------------------------------
      if (PrimPoly == 2567) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2579
      //------------------------------------------------------------------------
      if (PrimPoly == 2579) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2581
      //------------------------------------------------------------------------
      if (PrimPoly == 2581) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2601
      //------------------------------------------------------------------------
      if (PrimPoly == 2601) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2633
      //------------------------------------------------------------------------
      if (PrimPoly == 2633) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2657
      //------------------------------------------------------------------------
      if (PrimPoly == 2657) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2669
      //------------------------------------------------------------------------
      if (PrimPoly == 2669) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2681
      //------------------------------------------------------------------------
      if (PrimPoly == 2681) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2687
      //------------------------------------------------------------------------
      if (PrimPoly == 2687) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2693
      //------------------------------------------------------------------------
      if (PrimPoly == 2693) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2705
      //------------------------------------------------------------------------
      if (PrimPoly == 2705) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2717
      //------------------------------------------------------------------------
      if (PrimPoly == 2717) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2727
      //------------------------------------------------------------------------
      if (PrimPoly == 2727) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2731
      //------------------------------------------------------------------------
      if (PrimPoly == 2731) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2739
      //------------------------------------------------------------------------
      if (PrimPoly == 2739) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2741
      //------------------------------------------------------------------------
      if (PrimPoly == 2741) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2773
      //------------------------------------------------------------------------
      if (PrimPoly == 2773) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2783
      //------------------------------------------------------------------------
      if (PrimPoly == 2783) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2793
      //------------------------------------------------------------------------
      if (PrimPoly == 2793) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2799
      //------------------------------------------------------------------------
      if (PrimPoly == 2799) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2801
      //------------------------------------------------------------------------
      if (PrimPoly == 2801) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2811
      //------------------------------------------------------------------------
      if (PrimPoly == 2811) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2819
      //------------------------------------------------------------------------
      if (PrimPoly == 2819) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2825
      //------------------------------------------------------------------------
      if (PrimPoly == 2825) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2833
      //------------------------------------------------------------------------
      if (PrimPoly == 2833) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2867
      //------------------------------------------------------------------------
      if (PrimPoly == 2867) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2879
      //------------------------------------------------------------------------
      if (PrimPoly == 2879) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2881
      //------------------------------------------------------------------------
      if (PrimPoly == 2881) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2891
      //------------------------------------------------------------------------
      if (PrimPoly == 2891) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2905
      //------------------------------------------------------------------------
      if (PrimPoly == 2905) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2911
      //------------------------------------------------------------------------
      if (PrimPoly == 2911) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2917
      //------------------------------------------------------------------------
      if (PrimPoly == 2917) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2927
      //------------------------------------------------------------------------
      if (PrimPoly == 2927) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2941
      //------------------------------------------------------------------------
      if (PrimPoly == 2941) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2951
      //------------------------------------------------------------------------
      if (PrimPoly == 2951) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2955
      //------------------------------------------------------------------------
      if (PrimPoly == 2955) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2963
      //------------------------------------------------------------------------
      if (PrimPoly == 2963) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2965
      //------------------------------------------------------------------------
      if (PrimPoly == 2965) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2991
      //------------------------------------------------------------------------
      if (PrimPoly == 2991) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 2999
      //------------------------------------------------------------------------
      if (PrimPoly == 2999) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3005
      //------------------------------------------------------------------------
      if (PrimPoly == 3005) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3017
      //------------------------------------------------------------------------
      if (PrimPoly == 3017) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3035
      //------------------------------------------------------------------------
      if (PrimPoly == 3035) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3037
      //------------------------------------------------------------------------
      if (PrimPoly == 3037) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3047
      //------------------------------------------------------------------------
      if (PrimPoly == 3047) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3053
      //------------------------------------------------------------------------
      if (PrimPoly == 3053) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3083
      //------------------------------------------------------------------------
      if (PrimPoly == 3083) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3085
      //------------------------------------------------------------------------
      if (PrimPoly == 3085) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3097
      //------------------------------------------------------------------------
      if (PrimPoly == 3097) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3103
      //------------------------------------------------------------------------
      if (PrimPoly == 3103) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3159
      //------------------------------------------------------------------------
      if (PrimPoly == 3159) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3169
      //------------------------------------------------------------------------
      if (PrimPoly == 3169) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3179
      //------------------------------------------------------------------------
      if (PrimPoly == 3179) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3187
      //------------------------------------------------------------------------
      if (PrimPoly == 3187) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3205
      //------------------------------------------------------------------------
      if (PrimPoly == 3205) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3209
      //------------------------------------------------------------------------
      if (PrimPoly == 3209) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3223
      //------------------------------------------------------------------------
      if (PrimPoly == 3223) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3227
      //------------------------------------------------------------------------
      if (PrimPoly == 3227) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3229
      //------------------------------------------------------------------------
      if (PrimPoly == 3229) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3251
      //------------------------------------------------------------------------
      if (PrimPoly == 3251) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3263
      //------------------------------------------------------------------------
      if (PrimPoly == 3263) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3271
      //------------------------------------------------------------------------
      if (PrimPoly == 3271) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3277
      //------------------------------------------------------------------------
      if (PrimPoly == 3277) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3283
      //------------------------------------------------------------------------
      if (PrimPoly == 3283) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3285
      //------------------------------------------------------------------------
      if (PrimPoly == 3285) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3299
      //------------------------------------------------------------------------
      if (PrimPoly == 3299) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3305
      //------------------------------------------------------------------------
      if (PrimPoly == 3305) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3319
      //------------------------------------------------------------------------
      if (PrimPoly == 3319) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3331
      //------------------------------------------------------------------------
      if (PrimPoly == 3331) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3343
      //------------------------------------------------------------------------
      if (PrimPoly == 3343) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3357
      //------------------------------------------------------------------------
      if (PrimPoly == 3357) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3367
      //------------------------------------------------------------------------
      if (PrimPoly == 3367) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3373
      //------------------------------------------------------------------------
      if (PrimPoly == 3373) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3393
      //------------------------------------------------------------------------
      if (PrimPoly == 3393) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3399
      //------------------------------------------------------------------------
      if (PrimPoly == 3399) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3413
      //------------------------------------------------------------------------
      if (PrimPoly == 3413) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3417
      //------------------------------------------------------------------------
      if (PrimPoly == 3417) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3427
      //------------------------------------------------------------------------
      if (PrimPoly == 3427) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3439
      //------------------------------------------------------------------------
      if (PrimPoly == 3439) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3441
      //------------------------------------------------------------------------
      if (PrimPoly == 3441) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3475
      //------------------------------------------------------------------------
      if (PrimPoly == 3475) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3487
      //------------------------------------------------------------------------
      if (PrimPoly == 3487) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3497
      //------------------------------------------------------------------------
      if (PrimPoly == 3497) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3515
      //------------------------------------------------------------------------
      if (PrimPoly == 3515) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3517
      //------------------------------------------------------------------------
      if (PrimPoly == 3517) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3529
      //------------------------------------------------------------------------
      if (PrimPoly == 3529) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3543
      //------------------------------------------------------------------------
      if (PrimPoly == 3543) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3547
      //------------------------------------------------------------------------
      if (PrimPoly == 3547) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3553
      //------------------------------------------------------------------------
      if (PrimPoly == 3553) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3559
      //------------------------------------------------------------------------
      if (PrimPoly == 3559) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3573
      //------------------------------------------------------------------------
      if (PrimPoly == 3573) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3589
      //------------------------------------------------------------------------
      if (PrimPoly == 3589) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3613
      //------------------------------------------------------------------------
      if (PrimPoly == 3613) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3617
      //------------------------------------------------------------------------
      if (PrimPoly == 3617) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3623
      //------------------------------------------------------------------------
      if (PrimPoly == 3623) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3627
      //------------------------------------------------------------------------
      if (PrimPoly == 3627) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3635
      //------------------------------------------------------------------------
      if (PrimPoly == 3635) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3641
      //------------------------------------------------------------------------
      if (PrimPoly == 3641) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3655
      //------------------------------------------------------------------------
      if (PrimPoly == 3655) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3659
      //------------------------------------------------------------------------
      if (PrimPoly == 3659) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3669
      //------------------------------------------------------------------------
      if (PrimPoly == 3669) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3679
      //------------------------------------------------------------------------
      if (PrimPoly == 3679) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3697
      //------------------------------------------------------------------------
      if (PrimPoly == 3697) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3707
      //------------------------------------------------------------------------
      if (PrimPoly == 3707) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3709
      //------------------------------------------------------------------------
      if (PrimPoly == 3709) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3713
      //------------------------------------------------------------------------
      if (PrimPoly == 3713) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3731
      //------------------------------------------------------------------------
      if (PrimPoly == 3731) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3743
      //------------------------------------------------------------------------
      if (PrimPoly == 3743) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3747
      //------------------------------------------------------------------------
      if (PrimPoly == 3747) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3771
      //------------------------------------------------------------------------
      if (PrimPoly == 3771) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3791
      //------------------------------------------------------------------------
      if (PrimPoly == 3791) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3805
      //------------------------------------------------------------------------
      if (PrimPoly == 3805) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3827
      //------------------------------------------------------------------------
      if (PrimPoly == 3827) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3833
      //------------------------------------------------------------------------
      if (PrimPoly == 3833) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3851
      //------------------------------------------------------------------------
      if (PrimPoly == 3851) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3865
      //------------------------------------------------------------------------
      if (PrimPoly == 3865) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3889
      //------------------------------------------------------------------------
      if (PrimPoly == 3889) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3895
      //------------------------------------------------------------------------
      if (PrimPoly == 3895) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3933
      //------------------------------------------------------------------------
      if (PrimPoly == 3933) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3947
      //------------------------------------------------------------------------
      if (PrimPoly == 3947) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3949
      //------------------------------------------------------------------------
      if (PrimPoly == 3949) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3957
      //------------------------------------------------------------------------
      if (PrimPoly == 3957) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3971
      //------------------------------------------------------------------------
      if (PrimPoly == 3971) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3985
      //------------------------------------------------------------------------
      if (PrimPoly == 3985) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3991
      //------------------------------------------------------------------------
      if (PrimPoly == 3991) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 3995
      //------------------------------------------------------------------------
      if (PrimPoly == 3995) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4007
      //------------------------------------------------------------------------
      if (PrimPoly == 4007) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4013
      //------------------------------------------------------------------------
      if (PrimPoly == 4013) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4021
      //------------------------------------------------------------------------
      if (PrimPoly == 4021) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4045
      //------------------------------------------------------------------------
      if (PrimPoly == 4045) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4051
      //------------------------------------------------------------------------
      if (PrimPoly == 4051) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4069
      //------------------------------------------------------------------------
      if (PrimPoly == 4069) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 11, Primpoly = 4073
      //------------------------------------------------------------------------
      if (PrimPoly == 4073) {
         ppTab[0] =  mmTab[0] ^ mmTab[11] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[11] ^ mmTab[17] ^ mmTab[20] ;
      }
   break;

   case (12):
   //------------------------------------------------------------------------
   // bitSymbol = 12
   //------------------------------------------------------------------------
/*      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4179
      //------------------------------------------------------------------------
      if (PrimPoly == 4179) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
      }*/
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4179
      //------------------------------------------------------------------------
      if (PrimPoly == 4179) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4201
      //------------------------------------------------------------------------
      if (PrimPoly == 4201) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4219
      //------------------------------------------------------------------------
      if (PrimPoly == 4219) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4221
      //------------------------------------------------------------------------
      if (PrimPoly == 4221) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4249
      //------------------------------------------------------------------------
      if (PrimPoly == 4249) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4305
      //------------------------------------------------------------------------
      if (PrimPoly == 4305) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4331
      //------------------------------------------------------------------------
      if (PrimPoly == 4331) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4359
      //------------------------------------------------------------------------
      if (PrimPoly == 4359) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4383
      //------------------------------------------------------------------------
      if (PrimPoly == 4383) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4387
      //------------------------------------------------------------------------
      if (PrimPoly == 4387) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4411
      //------------------------------------------------------------------------
      if (PrimPoly == 4411) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4431
      //------------------------------------------------------------------------
      if (PrimPoly == 4431) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4439
      //------------------------------------------------------------------------
      if (PrimPoly == 4439) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4449
      //------------------------------------------------------------------------
      if (PrimPoly == 4449) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4459
      //------------------------------------------------------------------------
      if (PrimPoly == 4459) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4485
      //------------------------------------------------------------------------
      if (PrimPoly == 4485) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4531
      //------------------------------------------------------------------------
      if (PrimPoly == 4531) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4569
      //------------------------------------------------------------------------
      if (PrimPoly == 4569) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4575
      //------------------------------------------------------------------------
      if (PrimPoly == 4575) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4621
      //------------------------------------------------------------------------
      if (PrimPoly == 4621) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4663
      //------------------------------------------------------------------------
      if (PrimPoly == 4663) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4669
      //------------------------------------------------------------------------
      if (PrimPoly == 4669) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4711
      //------------------------------------------------------------------------
      if (PrimPoly == 4711) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4723
      //------------------------------------------------------------------------
      if (PrimPoly == 4723) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4735
      //------------------------------------------------------------------------
      if (PrimPoly == 4735) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4793
      //------------------------------------------------------------------------
      if (PrimPoly == 4793) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4801
      //------------------------------------------------------------------------
      if (PrimPoly == 4801) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4811
      //------------------------------------------------------------------------
      if (PrimPoly == 4811) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4879
      //------------------------------------------------------------------------
      if (PrimPoly == 4879) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4893
      //------------------------------------------------------------------------
      if (PrimPoly == 4893) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4897
      //------------------------------------------------------------------------
      if (PrimPoly == 4897) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4921
      //------------------------------------------------------------------------
      if (PrimPoly == 4921) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4927
      //------------------------------------------------------------------------
      if (PrimPoly == 4927) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4941
      //------------------------------------------------------------------------
      if (PrimPoly == 4941) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 4977
      //------------------------------------------------------------------------
      if (PrimPoly == 4977) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5017
      //------------------------------------------------------------------------
      if (PrimPoly == 5017) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5027
      //------------------------------------------------------------------------
      if (PrimPoly == 5027) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5033
      //------------------------------------------------------------------------
      if (PrimPoly == 5033) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5127
      //------------------------------------------------------------------------
      if (PrimPoly == 5127) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5169
      //------------------------------------------------------------------------
      if (PrimPoly == 5169) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5175
      //------------------------------------------------------------------------
      if (PrimPoly == 5175) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5199
      //------------------------------------------------------------------------
      if (PrimPoly == 5199) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5213
      //------------------------------------------------------------------------
      if (PrimPoly == 5213) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5223
      //------------------------------------------------------------------------
      if (PrimPoly == 5223) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5237
      //------------------------------------------------------------------------
      if (PrimPoly == 5237) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5287
      //------------------------------------------------------------------------
      if (PrimPoly == 5287) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5293
      //------------------------------------------------------------------------
      if (PrimPoly == 5293) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5331
      //------------------------------------------------------------------------
      if (PrimPoly == 5331) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5391
      //------------------------------------------------------------------------
      if (PrimPoly == 5391) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5405
      //------------------------------------------------------------------------
      if (PrimPoly == 5405) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5453
      //------------------------------------------------------------------------
      if (PrimPoly == 5453) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5523
      //------------------------------------------------------------------------
      if (PrimPoly == 5523) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5573
      //------------------------------------------------------------------------
      if (PrimPoly == 5573) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5591
      //------------------------------------------------------------------------
      if (PrimPoly == 5591) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5597
      //------------------------------------------------------------------------
      if (PrimPoly == 5597) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5611
      //------------------------------------------------------------------------
      if (PrimPoly == 5611) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5641
      //------------------------------------------------------------------------
      if (PrimPoly == 5641) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5703
      //------------------------------------------------------------------------
      if (PrimPoly == 5703) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5717
      //------------------------------------------------------------------------
      if (PrimPoly == 5717) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5721
      //------------------------------------------------------------------------
      if (PrimPoly == 5721) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5797
      //------------------------------------------------------------------------
      if (PrimPoly == 5797) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5821
      //------------------------------------------------------------------------
      if (PrimPoly == 5821) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5909
      //------------------------------------------------------------------------
      if (PrimPoly == 5909) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5913
      //------------------------------------------------------------------------
      if (PrimPoly == 5913) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5955
      //------------------------------------------------------------------------
      if (PrimPoly == 5955) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 5957
      //------------------------------------------------------------------------
      if (PrimPoly == 5957) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6005
      //------------------------------------------------------------------------
      if (PrimPoly == 6005) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6025
      //------------------------------------------------------------------------
      if (PrimPoly == 6025) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6061
      //------------------------------------------------------------------------
      if (PrimPoly == 6061) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6067
      //------------------------------------------------------------------------
      if (PrimPoly == 6067) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6079
      //------------------------------------------------------------------------
      if (PrimPoly == 6079) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6081
      //------------------------------------------------------------------------
      if (PrimPoly == 6081) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6231
      //------------------------------------------------------------------------
      if (PrimPoly == 6231) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6237
      //------------------------------------------------------------------------
      if (PrimPoly == 6237) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6289
      //------------------------------------------------------------------------
      if (PrimPoly == 6289) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6295
      //------------------------------------------------------------------------
      if (PrimPoly == 6295) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6329
      //------------------------------------------------------------------------
      if (PrimPoly == 6329) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6383
      //------------------------------------------------------------------------
      if (PrimPoly == 6383) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6427
      //------------------------------------------------------------------------
      if (PrimPoly == 6427) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6453
      //------------------------------------------------------------------------
      if (PrimPoly == 6453) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6465
      //------------------------------------------------------------------------
      if (PrimPoly == 6465) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6501
      //------------------------------------------------------------------------
      if (PrimPoly == 6501) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6523
      //------------------------------------------------------------------------
      if (PrimPoly == 6523) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6539
      //------------------------------------------------------------------------
      if (PrimPoly == 6539) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6577
      //------------------------------------------------------------------------
      if (PrimPoly == 6577) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6589
      //------------------------------------------------------------------------
      if (PrimPoly == 6589) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6601
      //------------------------------------------------------------------------
      if (PrimPoly == 6601) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6607
      //------------------------------------------------------------------------
      if (PrimPoly == 6607) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6631
      //------------------------------------------------------------------------
      if (PrimPoly == 6631) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6683
      //------------------------------------------------------------------------
      if (PrimPoly == 6683) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6699
      //------------------------------------------------------------------------
      if (PrimPoly == 6699) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6707
      //------------------------------------------------------------------------
      if (PrimPoly == 6707) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6761
      //------------------------------------------------------------------------
      if (PrimPoly == 6761) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6795
      //------------------------------------------------------------------------
      if (PrimPoly == 6795) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6865
      //------------------------------------------------------------------------
      if (PrimPoly == 6865) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6881
      //------------------------------------------------------------------------
      if (PrimPoly == 6881) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6901
      //------------------------------------------------------------------------
      if (PrimPoly == 6901) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6923
      //------------------------------------------------------------------------
      if (PrimPoly == 6923) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6931
      //------------------------------------------------------------------------
      if (PrimPoly == 6931) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6943
      //------------------------------------------------------------------------
      if (PrimPoly == 6943) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 6999
      //------------------------------------------------------------------------
      if (PrimPoly == 6999) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7057
      //------------------------------------------------------------------------
      if (PrimPoly == 7057) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7079
      //------------------------------------------------------------------------
      if (PrimPoly == 7079) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7103
      //------------------------------------------------------------------------
      if (PrimPoly == 7103) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7105
      //------------------------------------------------------------------------
      if (PrimPoly == 7105) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7123
      //------------------------------------------------------------------------
      if (PrimPoly == 7123) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7173
      //------------------------------------------------------------------------
      if (PrimPoly == 7173) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7185
      //------------------------------------------------------------------------
      if (PrimPoly == 7185) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7191
      //------------------------------------------------------------------------
      if (PrimPoly == 7191) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7207
      //------------------------------------------------------------------------
      if (PrimPoly == 7207) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7245
      //------------------------------------------------------------------------
      if (PrimPoly == 7245) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[9] =  mmTab[9] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7303
      //------------------------------------------------------------------------
      if (PrimPoly == 7303) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7327
      //------------------------------------------------------------------------
      if (PrimPoly == 7327) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[17] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7333
      //------------------------------------------------------------------------
      if (PrimPoly == 7333) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7355
      //------------------------------------------------------------------------
      if (PrimPoly == 7355) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7365
      //------------------------------------------------------------------------
      if (PrimPoly == 7365) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7369
      //------------------------------------------------------------------------
      if (PrimPoly == 7369) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7375
      //------------------------------------------------------------------------
      if (PrimPoly == 7375) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7411
      //------------------------------------------------------------------------
      if (PrimPoly == 7411) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7431
      //------------------------------------------------------------------------
      if (PrimPoly == 7431) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7459
      //------------------------------------------------------------------------
      if (PrimPoly == 7459) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7491
      //------------------------------------------------------------------------
      if (PrimPoly == 7491) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7505
      //------------------------------------------------------------------------
      if (PrimPoly == 7505) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7515
      //------------------------------------------------------------------------
      if (PrimPoly == 7515) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7541
      //------------------------------------------------------------------------
      if (PrimPoly == 7541) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7557
      //------------------------------------------------------------------------
      if (PrimPoly == 7557) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7561
      //------------------------------------------------------------------------
      if (PrimPoly == 7561) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7701
      //------------------------------------------------------------------------
      if (PrimPoly == 7701) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7705
      //------------------------------------------------------------------------
      if (PrimPoly == 7705) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7727
      //------------------------------------------------------------------------
      if (PrimPoly == 7727) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7749
      //------------------------------------------------------------------------
      if (PrimPoly == 7749) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7761
      //------------------------------------------------------------------------
      if (PrimPoly == 7761) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7783
      //------------------------------------------------------------------------
      if (PrimPoly == 7783) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[15] ^ mmTab[20] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7795
      //------------------------------------------------------------------------
      if (PrimPoly == 7795) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[14] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7823
      //------------------------------------------------------------------------
      if (PrimPoly == 7823) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7907
      //------------------------------------------------------------------------
      if (PrimPoly == 7907) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[3] =  mmTab[3] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[8] =  mmTab[8] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7953
      //------------------------------------------------------------------------
      if (PrimPoly == 7953) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7963
      //------------------------------------------------------------------------
      if (PrimPoly == 7963) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[21] ;
         ppTab[7] =  mmTab[7] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 7975
      //------------------------------------------------------------------------
      if (PrimPoly == 7975) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[14] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8049
      //------------------------------------------------------------------------
      if (PrimPoly == 8049) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[3] =  mmTab[3] ^ mmTab[15] ^ mmTab[16] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[13] ^ mmTab[16] ^ mmTab[19] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[13] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8089
      //------------------------------------------------------------------------
      if (PrimPoly == 8089) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ;
         ppTab[6] =  mmTab[6] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[22] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8123
      //------------------------------------------------------------------------
      if (PrimPoly == 8123) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[1] =  mmTab[1] ^ mmTab[12] ^ mmTab[14] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[13] ^ mmTab[15] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[18] ^ mmTab[21] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[21] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8125
      //------------------------------------------------------------------------
      if (PrimPoly == 8125) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[2] =  mmTab[2] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[4] =  mmTab[4] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[5] =  mmTab[5] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[13] ^ mmTab[17] ^ mmTab[18] ^ mmTab[20] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[13] ^ mmTab[14] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[14] ^ mmTab[15] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[16] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[17] ^ mmTab[19] ^ mmTab[22] ;
      }
      //------------------------------------------------------------------------
      // bitSymbol = 12, Primpoly = 8137
      //------------------------------------------------------------------------
      if (PrimPoly == 8137) {
         ppTab[0] =  mmTab[0] ^ mmTab[12] ^ mmTab[13] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[1] =  mmTab[1] ^ mmTab[13] ^ mmTab[14] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[2] =  mmTab[2] ^ mmTab[14] ^ mmTab[15] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[3] =  mmTab[3] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[19] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[4] =  mmTab[4] ^ mmTab[13] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[5] =  mmTab[5] ^ mmTab[14] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[6] =  mmTab[6] ^ mmTab[12] ^ mmTab[13] ^ mmTab[15] ^ mmTab[16] ^ mmTab[18] ^ mmTab[20] ^ mmTab[21] ^ mmTab[22] ;
         ppTab[7] =  mmTab[7] ^ mmTab[12] ^ mmTab[14] ^ mmTab[16] ^ mmTab[17] ^ mmTab[20] ^ mmTab[22] ;
         ppTab[8] =  mmTab[8] ^ mmTab[12] ^ mmTab[15] ^ mmTab[17] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ;
         ppTab[9] =  mmTab[9] ^ mmTab[12] ^ mmTab[16] ^ mmTab[18] ;
         ppTab[10] =  mmTab[10] ^ mmTab[12] ^ mmTab[17] ^ mmTab[20] ^ mmTab[21] ;
         ppTab[11] =  mmTab[11] ^ mmTab[12] ^ mmTab[18] ^ mmTab[19] ^ mmTab[20] ^ mmTab[22] ;
      }  
   break;



   default:
      ppTab[0] = 0;
   break;
   }




  delete [] mmTab;





}
