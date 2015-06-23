//===================================================================
// Module Name : RsMrefTab
// File Name   : RsMrefTab.cpp
// Function    : RS Mreference Table
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

#include <ctime>



void RsMrefTab(int *MrefTab, int bitSymbol)
{

   //---------------------------------------------------------------
   //- c++ variables
   //---------------------------------------------------------------
   int mmTabSize = (bitSymbol*2) -1;
   int ii;


   //------------------------------------------------------------------------
   // initialize MrefTab
   //------------------------------------------------------------------------
    for(ii=0; ii<mmTabSize*bitSymbol; ii++){
       MrefTab [ii] = 0;
    }



   //------------------------------------------------------------------------
   // MrefTab construction
   //------------------------------------------------------------------------
   switch (bitSymbol) {

      //------------------------------------------------------------------------
      // bitSymbol = 3
      //------------------------------------------------------------------------
      case (3):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         // M[4] class
         MrefTab [4*bitSymbol+2] = 3;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 4
      //------------------------------------------------------------------------
      case (4):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         // M[5] class
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         // M[6] class
         MrefTab [6*bitSymbol+3] = 4;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 5
      //------------------------------------------------------------------------
      case (5):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         // M[6] class
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
        // M[7] class
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         // M[8] class
         MrefTab [8*bitSymbol+4] = 5;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 6
      //------------------------------------------------------------------------
      case (6):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
        // M[7] class
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         // M[8] class
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         // M[9] class
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         // M[10] class
         MrefTab [10*bitSymbol+5] = 6;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 7
      //------------------------------------------------------------------------
      case (7):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
        // M[7] class
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         // M[8] class
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         // M[9] class
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         // M[10] class
         MrefTab [10*bitSymbol+4] = 7;
         MrefTab [10*bitSymbol+5] = 6;
         MrefTab [10*bitSymbol+6] = 5;
         // M[11] class
         MrefTab [11*bitSymbol+5] = 7;
         MrefTab [11*bitSymbol+6] = 6;
         // M[12] class
         MrefTab [12*bitSymbol+6] = 7;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 8
      //------------------------------------------------------------------------
      case (8):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
        // M[7] class
         MrefTab [7*bitSymbol+0] = 8;
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         MrefTab [7*bitSymbol+7] = 1;
         // M[8] class
         MrefTab [8*bitSymbol+1] = 8;
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         MrefTab [8*bitSymbol+7] = 2;
         // M[9] class
         MrefTab [9*bitSymbol+2] = 8;
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         MrefTab [9*bitSymbol+7] = 3;
         // M[10] class
         MrefTab [10*bitSymbol+3] = 8;
         MrefTab [10*bitSymbol+4] = 7;
         MrefTab [10*bitSymbol+5] = 6;
         MrefTab [10*bitSymbol+6] = 5;
         MrefTab [10*bitSymbol+7] = 4;
         // M[11] class
         MrefTab [11*bitSymbol+4] = 8;
         MrefTab [11*bitSymbol+5] = 7;
         MrefTab [11*bitSymbol+6] = 6;
         MrefTab [11*bitSymbol+7] = 5;
         // M[12] class
         MrefTab [12*bitSymbol+5] = 8; 
         MrefTab [12*bitSymbol+6] = 7;
         MrefTab [12*bitSymbol+7] = 6;
         // M[13] class
         MrefTab [13*bitSymbol+6] = 8;
         MrefTab [13*bitSymbol+7] = 7;
         // M[14] class
         MrefTab [14*bitSymbol+7] = 8;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 9
      //------------------------------------------------------------------------
      case (9):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
        // M[7] class
         MrefTab [7*bitSymbol+0] = 8;
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         MrefTab [7*bitSymbol+7] = 1;
         // M[8] class
         MrefTab [8*bitSymbol+0] = 9;
         MrefTab [8*bitSymbol+1] = 8;
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         MrefTab [8*bitSymbol+7] = 2;
         MrefTab [8*bitSymbol+8] = 1;
         // M[9] class
         MrefTab [9*bitSymbol+1] = 9;
         MrefTab [9*bitSymbol+2] = 8;
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         MrefTab [9*bitSymbol+7] = 3;
         MrefTab [9*bitSymbol+8] = 2;
         // M[10] class
         MrefTab [10*bitSymbol+2] = 9;
         MrefTab [10*bitSymbol+3] = 8;
         MrefTab [10*bitSymbol+4] = 7;
         MrefTab [10*bitSymbol+5] = 6;
         MrefTab [10*bitSymbol+6] = 5;
         MrefTab [10*bitSymbol+7] = 4;
         MrefTab [10*bitSymbol+8] = 3;
         // M[11] class
         MrefTab [11*bitSymbol+3] = 9;
         MrefTab [11*bitSymbol+4] = 8;
         MrefTab [11*bitSymbol+5] = 7;
         MrefTab [11*bitSymbol+6] = 6;
         MrefTab [11*bitSymbol+7] = 5;
         MrefTab [11*bitSymbol+8] = 4;
         // M[12] class
         MrefTab [12*bitSymbol+4] = 9;
         MrefTab [12*bitSymbol+5] = 8;
         MrefTab [12*bitSymbol+6] = 7;
         MrefTab [12*bitSymbol+7] = 6;
         MrefTab [12*bitSymbol+8] = 5;
         // M[13] class
         MrefTab [13*bitSymbol+5] = 9;
         MrefTab [13*bitSymbol+6] = 8;
         MrefTab [13*bitSymbol+7] = 7;
         MrefTab [13*bitSymbol+8] = 6;
         // M[14] class
         MrefTab [14*bitSymbol+6] = 9;
         MrefTab [14*bitSymbol+7] = 8;
         MrefTab [14*bitSymbol+8] = 7;
         // M[15] class
         MrefTab [15*bitSymbol+7] = 9;
         MrefTab [15*bitSymbol+8] = 8;
         // M[16] class
         MrefTab [16*bitSymbol+8] = 9;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 10
      //------------------------------------------------------------------------
      case (10):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
        // M[7] class
         MrefTab [7*bitSymbol+0] = 8;
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         MrefTab [7*bitSymbol+7] = 1;
         // M[8] class
         MrefTab [8*bitSymbol+0] = 9;
         MrefTab [8*bitSymbol+1] = 8;
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         MrefTab [8*bitSymbol+7] = 2;
         MrefTab [8*bitSymbol+8] = 1;
         // M[9] class
         MrefTab [9*bitSymbol+0] = 10;
         MrefTab [9*bitSymbol+1] = 9;
         MrefTab [9*bitSymbol+2] = 8;
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         MrefTab [9*bitSymbol+7] = 3;
         MrefTab [9*bitSymbol+8] = 2;
         MrefTab [9*bitSymbol+9] = 1;
         // M[10] class
         MrefTab [10*bitSymbol+1] = 10;
         MrefTab [10*bitSymbol+2] = 9;
         MrefTab [10*bitSymbol+3] = 8;
         MrefTab [10*bitSymbol+4] = 7;
         MrefTab [10*bitSymbol+5] = 6;
         MrefTab [10*bitSymbol+6] = 5;
         MrefTab [10*bitSymbol+7] = 4;
         MrefTab [10*bitSymbol+8] = 3;
         MrefTab [10*bitSymbol+9] = 2;
         // M[11] class
         MrefTab [11*bitSymbol+2] = 10;
         MrefTab [11*bitSymbol+3] = 9;
         MrefTab [11*bitSymbol+4] = 8;
         MrefTab [11*bitSymbol+5] = 7;
         MrefTab [11*bitSymbol+6] = 6;
         MrefTab [11*bitSymbol+7] = 5;
         MrefTab [11*bitSymbol+8] = 4;
         MrefTab [11*bitSymbol+9] = 3;
         // M[12] class
         MrefTab [12*bitSymbol+3] = 10;
         MrefTab [12*bitSymbol+4] = 9;
         MrefTab [12*bitSymbol+5] = 8;
         MrefTab [12*bitSymbol+6] = 7;
         MrefTab [12*bitSymbol+7] = 6;
         MrefTab [12*bitSymbol+8] = 5;
         MrefTab [12*bitSymbol+9] = 4;
         // M[13] class
         MrefTab [13*bitSymbol+4] = 10;
         MrefTab [13*bitSymbol+5] = 9;
         MrefTab [13*bitSymbol+6] = 8;
         MrefTab [13*bitSymbol+7] = 7;
         MrefTab [13*bitSymbol+8] = 6;
         MrefTab [13*bitSymbol+9] = 5;
         // M[14] class
         MrefTab [14*bitSymbol+5] = 10;
         MrefTab [14*bitSymbol+6] = 9;
         MrefTab [14*bitSymbol+7] = 8;
         MrefTab [14*bitSymbol+8] = 7;
         MrefTab [14*bitSymbol+9] = 6;
         // M[15] class
         MrefTab [15*bitSymbol+6] = 10;
         MrefTab [15*bitSymbol+7] = 9;
         MrefTab [15*bitSymbol+8] = 8;
         MrefTab [15*bitSymbol+9] = 7;
         // M[16] class
         MrefTab [16*bitSymbol+7] = 10;
         MrefTab [16*bitSymbol+8] = 9;
         MrefTab [16*bitSymbol+9] = 8;
         // M[17] class
         MrefTab [17*bitSymbol+8] = 10;
         MrefTab [17*bitSymbol+9] = 9;
         // M[18] class
         MrefTab [18*bitSymbol+9] = 10;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 11
      //------------------------------------------------------------------------
      case (11):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
         // M[7] class
         MrefTab [7*bitSymbol+0] = 8;
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         MrefTab [7*bitSymbol+7] = 1;
         // M[8] class
         MrefTab [8*bitSymbol+0] = 9;
         MrefTab [8*bitSymbol+1] = 8;
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         MrefTab [8*bitSymbol+7] = 2;
         MrefTab [8*bitSymbol+8] = 1;
         // M[9] class
         MrefTab [9*bitSymbol+0] = 10;
         MrefTab [9*bitSymbol+1] = 9;
         MrefTab [9*bitSymbol+2] = 8;
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         MrefTab [9*bitSymbol+7] = 3;
         MrefTab [9*bitSymbol+8] = 2;
         MrefTab [9*bitSymbol+9] = 1;
         // M[10] class
         MrefTab [10*bitSymbol+0]  = 11;
         MrefTab [10*bitSymbol+1]  = 10;
         MrefTab [10*bitSymbol+2]  = 9;
         MrefTab [10*bitSymbol+3]  = 8;
         MrefTab [10*bitSymbol+4]  = 7;
         MrefTab [10*bitSymbol+5]  = 6;
         MrefTab [10*bitSymbol+6]  = 5;
         MrefTab [10*bitSymbol+7]  = 4;
         MrefTab [10*bitSymbol+8]  = 3;
         MrefTab [10*bitSymbol+9]  = 2;
         MrefTab [10*bitSymbol+10] = 1;
         // M[11] class
         MrefTab [11*bitSymbol+1]  = 11;
         MrefTab [11*bitSymbol+2]  = 10;
         MrefTab [11*bitSymbol+3]  = 9;
         MrefTab [11*bitSymbol+4]  = 8;
         MrefTab [11*bitSymbol+5]  = 7;
         MrefTab [11*bitSymbol+6]  = 6;
         MrefTab [11*bitSymbol+7]  = 5;
         MrefTab [11*bitSymbol+8]  = 4;
         MrefTab [11*bitSymbol+9]  = 3;
         MrefTab [11*bitSymbol+10] = 2;
         // M[12] class
         MrefTab [12*bitSymbol+2]  = 11;
         MrefTab [12*bitSymbol+3]  = 10;
         MrefTab [12*bitSymbol+4]  = 9;
         MrefTab [12*bitSymbol+5]  = 8;
         MrefTab [12*bitSymbol+6]  = 7;
         MrefTab [12*bitSymbol+7]  = 6;
         MrefTab [12*bitSymbol+8]  = 5;
         MrefTab [12*bitSymbol+9]  = 4;
         MrefTab [12*bitSymbol+10] = 3;
         // M[13] class
         MrefTab [13*bitSymbol+3]  = 11;
         MrefTab [13*bitSymbol+4]  = 10;
         MrefTab [13*bitSymbol+5]  = 9;
         MrefTab [13*bitSymbol+6]  = 8;
         MrefTab [13*bitSymbol+7]  = 7;
         MrefTab [13*bitSymbol+8]  = 6;
         MrefTab [13*bitSymbol+9]  = 5;
         MrefTab [13*bitSymbol+10] = 4;
         // M[14] class
         MrefTab [14*bitSymbol+4]  = 11;
         MrefTab [14*bitSymbol+5]  = 10;
         MrefTab [14*bitSymbol+6]  = 9;
         MrefTab [14*bitSymbol+7]  = 8;
         MrefTab [14*bitSymbol+8]  = 7;
         MrefTab [14*bitSymbol+9]  = 6;
         MrefTab [14*bitSymbol+10] = 5;
         // M[15] class
         MrefTab [15*bitSymbol+5]  = 11;
         MrefTab [15*bitSymbol+6]  = 10;
         MrefTab [15*bitSymbol+7]  = 9;
         MrefTab [15*bitSymbol+8]  = 8;
         MrefTab [15*bitSymbol+9]  = 7;
         MrefTab [15*bitSymbol+10] = 6;
         // M[16] class
         MrefTab [16*bitSymbol+6]  = 11;
         MrefTab [16*bitSymbol+7]  = 10;
         MrefTab [16*bitSymbol+8]  = 9;
         MrefTab [16*bitSymbol+9]  = 8;
         MrefTab [16*bitSymbol+10] = 7;
         // M[17] class
         MrefTab [17*bitSymbol+7]  = 11;
         MrefTab [17*bitSymbol+8]  = 10;
         MrefTab [17*bitSymbol+9]  = 9;
         MrefTab [17*bitSymbol+10] = 8;
         // M[18] class
         MrefTab [18*bitSymbol+8]  = 11;
         MrefTab [18*bitSymbol+9]  = 10;
         MrefTab [18*bitSymbol+10] = 9;
         // M[19] class
         MrefTab [19*bitSymbol+9]  = 11;
         MrefTab [19*bitSymbol+10] = 10;
         // M[20] class
         MrefTab [20*bitSymbol+10] = 11;
      break;
      //------------------------------------------------------------------------
      // bitSymbol = 12
      //------------------------------------------------------------------------
      case (12):
         // M[0] class
         MrefTab [0] = 1;
         // M[1] class
         MrefTab [1*bitSymbol+0] = 2;
         MrefTab [1*bitSymbol+1] = 1;
         // M[2] class
         MrefTab [2*bitSymbol+0] = 3;
         MrefTab [2*bitSymbol+1] = 2;
         MrefTab [2*bitSymbol+2] = 1;
         // M[3] class
         MrefTab [3*bitSymbol+0] = 4;
         MrefTab [3*bitSymbol+1] = 3;
         MrefTab [3*bitSymbol+2] = 2;
         MrefTab [3*bitSymbol+3] = 1;
         // M[4] class
         MrefTab [4*bitSymbol+0] = 5;
         MrefTab [4*bitSymbol+1] = 4;
         MrefTab [4*bitSymbol+2] = 3;
         MrefTab [4*bitSymbol+3] = 2;
         MrefTab [4*bitSymbol+4] = 1;
         // M[5] class
         MrefTab [5*bitSymbol+0] = 6;
         MrefTab [5*bitSymbol+1] = 5;
         MrefTab [5*bitSymbol+2] = 4;
         MrefTab [5*bitSymbol+3] = 3;
         MrefTab [5*bitSymbol+4] = 2;
         MrefTab [5*bitSymbol+5] = 1;
         // M[6] class
         MrefTab [6*bitSymbol+0] = 7;
         MrefTab [6*bitSymbol+1] = 6;
         MrefTab [6*bitSymbol+2] = 5;
         MrefTab [6*bitSymbol+3] = 4;
         MrefTab [6*bitSymbol+4] = 3;
         MrefTab [6*bitSymbol+5] = 2;
         MrefTab [6*bitSymbol+6] = 1;
         // M[7] class
         MrefTab [7*bitSymbol+0] = 8;
         MrefTab [7*bitSymbol+1] = 7;
         MrefTab [7*bitSymbol+2] = 6;
         MrefTab [7*bitSymbol+3] = 5;
         MrefTab [7*bitSymbol+4] = 4;
         MrefTab [7*bitSymbol+5] = 3;
         MrefTab [7*bitSymbol+6] = 2;
         MrefTab [7*bitSymbol+7] = 1;
         // M[8] class
         MrefTab [8*bitSymbol+0] = 9;
         MrefTab [8*bitSymbol+1] = 8;
         MrefTab [8*bitSymbol+2] = 7;
         MrefTab [8*bitSymbol+3] = 6;
         MrefTab [8*bitSymbol+4] = 5;
         MrefTab [8*bitSymbol+5] = 4;
         MrefTab [8*bitSymbol+6] = 3;
         MrefTab [8*bitSymbol+7] = 2;
         MrefTab [8*bitSymbol+8] = 1;
         // M[9] class
         MrefTab [9*bitSymbol+0] = 10;
         MrefTab [9*bitSymbol+1] = 9;
         MrefTab [9*bitSymbol+2] = 8;
         MrefTab [9*bitSymbol+3] = 7;
         MrefTab [9*bitSymbol+4] = 6;
         MrefTab [9*bitSymbol+5] = 5;
         MrefTab [9*bitSymbol+6] = 4;
         MrefTab [9*bitSymbol+7] = 3;
         MrefTab [9*bitSymbol+8] = 2;
         MrefTab [9*bitSymbol+9] = 1;
         // M[10] class
         MrefTab [10*bitSymbol+0]  = 11;
         MrefTab [10*bitSymbol+1]  = 10;
         MrefTab [10*bitSymbol+2]  = 9;
         MrefTab [10*bitSymbol+3]  = 8;
         MrefTab [10*bitSymbol+4]  = 7;
         MrefTab [10*bitSymbol+5]  = 6;
         MrefTab [10*bitSymbol+6]  = 5;
         MrefTab [10*bitSymbol+7]  = 4;
         MrefTab [10*bitSymbol+8]  = 3;
         MrefTab [10*bitSymbol+9]  = 2;
         MrefTab [10*bitSymbol+10] = 1;
         // M[11] class
         MrefTab [11*bitSymbol+0]  = 12;
         MrefTab [11*bitSymbol+1]  = 11;
         MrefTab [11*bitSymbol+2]  = 10;
         MrefTab [11*bitSymbol+3]  = 9;
         MrefTab [11*bitSymbol+4]  = 8;
         MrefTab [11*bitSymbol+5]  = 7;
         MrefTab [11*bitSymbol+6]  = 6;
         MrefTab [11*bitSymbol+7]  = 5;
         MrefTab [11*bitSymbol+8]  = 4;
         MrefTab [11*bitSymbol+9]  = 3;
         MrefTab [11*bitSymbol+10] = 2;
         MrefTab [11*bitSymbol+11] = 1;
         // M[12] class
         MrefTab [12*bitSymbol+1]  = 12;
         MrefTab [12*bitSymbol+2]  = 11;
         MrefTab [12*bitSymbol+3]  = 10;
         MrefTab [12*bitSymbol+4]  = 9;
         MrefTab [12*bitSymbol+5]  = 8;
         MrefTab [12*bitSymbol+6]  = 7;
         MrefTab [12*bitSymbol+7]  = 6;
         MrefTab [12*bitSymbol+8]  = 5;
         MrefTab [12*bitSymbol+9]  = 4;
         MrefTab [12*bitSymbol+10] = 3;
         MrefTab [12*bitSymbol+11] = 2;
         // M[13] class
         MrefTab [13*bitSymbol+2]  = 12;
         MrefTab [13*bitSymbol+3]  = 11;
         MrefTab [13*bitSymbol+4]  = 10;
         MrefTab [13*bitSymbol+5]  = 9;
         MrefTab [13*bitSymbol+6]  = 8;
         MrefTab [13*bitSymbol+7]  = 7;
         MrefTab [13*bitSymbol+8]  = 6;
         MrefTab [13*bitSymbol+9]  = 5;
         MrefTab [13*bitSymbol+10] = 4;
         MrefTab [13*bitSymbol+11] = 3;
         // M[14] class
         MrefTab [14*bitSymbol+3]  = 12;
         MrefTab [14*bitSymbol+4]  = 11;
         MrefTab [14*bitSymbol+5]  = 10;
         MrefTab [14*bitSymbol+6]  = 9;
         MrefTab [14*bitSymbol+7]  = 8;
         MrefTab [14*bitSymbol+8]  = 7;
         MrefTab [14*bitSymbol+9]  = 6;
         MrefTab [14*bitSymbol+10] = 5;
         MrefTab [14*bitSymbol+11] = 4;
         // M[15] class
         MrefTab [15*bitSymbol+4]  = 12;
         MrefTab [15*bitSymbol+5]  = 11;
         MrefTab [15*bitSymbol+6]  = 10;
         MrefTab [15*bitSymbol+7]  = 9;
         MrefTab [15*bitSymbol+8]  = 8;
         MrefTab [15*bitSymbol+9]  = 7;
         MrefTab [15*bitSymbol+10] = 6;
         MrefTab [15*bitSymbol+11] = 5;
         // M[16] class
         MrefTab [16*bitSymbol+5]  = 12;
         MrefTab [16*bitSymbol+6]  = 11;
         MrefTab [16*bitSymbol+7]  = 10;
         MrefTab [16*bitSymbol+8]  = 9;
         MrefTab [16*bitSymbol+9]  = 8;
         MrefTab [16*bitSymbol+10] = 7;
         MrefTab [16*bitSymbol+11] = 6;
         // M[17] class
         MrefTab [17*bitSymbol+6]  = 12;
         MrefTab [17*bitSymbol+7]  = 11;
         MrefTab [17*bitSymbol+8]  = 10;
         MrefTab [17*bitSymbol+9]  = 9;
         MrefTab [17*bitSymbol+10] = 8;
         MrefTab [17*bitSymbol+11] = 7;
         // M[18] class
         MrefTab [18*bitSymbol+7]  = 12;
         MrefTab [18*bitSymbol+8]  = 11;
         MrefTab [18*bitSymbol+9]  = 10;
         MrefTab [18*bitSymbol+10] = 9;
         MrefTab [18*bitSymbol+11] = 8;
         // M[19] class
         MrefTab [19*bitSymbol+8]  = 12;
         MrefTab [19*bitSymbol+9]  = 11;
         MrefTab [19*bitSymbol+10] = 10;
         MrefTab [19*bitSymbol+11] = 9;
         // M[20] class
         MrefTab [20*bitSymbol+9]  = 12;
         MrefTab [20*bitSymbol+10] = 11;
         MrefTab [20*bitSymbol+11] = 10;
         // M[21] class
         MrefTab [21*bitSymbol+10] = 12;
         MrefTab [21*bitSymbol+11] = 11;
         // M[22] class
         MrefTab [22*bitSymbol+11] = 12;
      break;
      default:
         MrefTab [0] = 0;
      break;
   }


}