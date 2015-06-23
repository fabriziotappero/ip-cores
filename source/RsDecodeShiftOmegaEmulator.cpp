//===================================================================
// Module Name : RsDecodeShiftOmegaEmulator
// File Name   : RsDecodeShiftOmegaEmulator.cpp
// Function    : RS decoder shift omega emulator
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


void RsDecodeShiftOmegaEmulator(int* OmegaShiftedTab, int* OmegaTab, int *numShifted, int TotalSize, int DataSize, int bitSymbol) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   int jj;
   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   


   //---------------------------------------------------------------
   // compute OmegaShiftedTab
   //---------------------------------------------------------------
   for(ii=0; ii<syndromeLength; ii++){
      if ((ii+numShifted[0]) < syndromeLength){
         for(jj=0; jj<bitSymbol; jj++){
            OmegaShiftedTab[ii*bitSymbol+jj] = OmegaTab[(ii+numShifted[0])*bitSymbol+jj];
         }
      }else{
         for(jj=0; jj<bitSymbol; jj++){
            OmegaShiftedTab[ii*bitSymbol+jj] = 0;
         }
      }
   }


}
