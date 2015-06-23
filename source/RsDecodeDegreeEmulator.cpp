//===================================================================
// Module Name : RsDecodeDegreeEmulator
// File Name   : RsDecodeDegreeEmulator.cpp
// Function    : RS Decoder degree emulator
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


void RsDecodeDegreeEmulator(int *Degree, int *PoynomTab, int TotalSize, int DataSize, int bitSymbol) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int DegreeFlag;
   int nonZeroflag;
   int ii, jj;
   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // compute Degree
   //---------------------------------------------------------------
   Degree [0]    = 0;
   DegreeFlag = 0;


   for(ii=(syndromeLength-1); ii>=0; ii=ii-1){
      nonZeroflag = 0;

      for(jj=0; jj<bitSymbol; jj++){
         if (PoynomTab[ii*bitSymbol+jj] !=0) {
            nonZeroflag = 1;
         }
      }

      if ((nonZeroflag == 1) && (DegreeFlag == 0)){
         Degree [0]    = ii;
         DegreeFlag = 1;
      }
   }


}
