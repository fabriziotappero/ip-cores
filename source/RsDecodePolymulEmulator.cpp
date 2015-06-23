//===================================================================
// Module Name : RsDecodePolymulEmulator
// File Name   : RsDecodePolymulEmulator.cpp
// Function    : RTL Decoder polymul emulator
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

void RsGfMultiplier( int*, int*,int*, int, int);
void RsDecodePolymulEmulator(int *sumRegTab, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *syndromeRegTab, int *epsilonRegTab) {

   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int flagEpsilon;
   int aa,ii,jj,zz;
   int tempNum;


   //---------------------------------------------------------------
   // syndrome Length calculation
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int *epsilonMSB;
   int *ppTab;
   int *tempixTab;
   int *powerTab;
   epsilonMSB = new int[bitSymbol];
   ppTab      = new int[bitSymbol];
   tempixTab  = new int[bitSymbol];
   powerTab   = new int[bitSymbol];


   //---------------------------------------------------------------
   // powerTab calculation
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //---------------------------------------------------------------
   //---------------------------------------------------------------
   for (ii = 0; ii<(syndromeLength+2); ii++){

      //---------------------------------------------------------------
      // ii == 0
      //---------------------------------------------------------------
      if (ii ==0){
         //---------------------------------------------------------------
         // check if epsilon MSB is null
         //---------------------------------------------------------------
         flagEpsilon = 0;
         for (jj=0;jj<bitSymbol;jj++){
            if (epsilonRegTab[syndromeLength*bitSymbol+jj] !=0){
               flagEpsilon = 1;
            }
         }
         //---------------------------------------------------------------
         // assign sumRegTab
         //---------------------------------------------------------------
         if (flagEpsilon == 0){
            for (jj=0;jj<(syndromeLength*bitSymbol);jj++){
               sumRegTab[jj]=0;
            }
         }else{
            for (jj=0;jj<(syndromeLength*bitSymbol);jj++){
               sumRegTab[jj]=syndromeRegTab[jj];
            }
         }
         //---------------------------------------------------------------
         // calculate epsilonMSB
         //---------------------------------------------------------------
         for (jj=0;jj<bitSymbol;jj++){
            epsilonMSB[jj] = epsilonRegTab[(syndromeLength*bitSymbol)+jj];
         }
      }
      //---------------------------------------------------------------
      // ii > 0
      //---------------------------------------------------------------
      else{
         //---------------------------------------------------------------
         // Multiplier
         //---------------------------------------------------------------
         for (jj=syndromeLength-1;jj>=0;jj--){
            
            for (zz=0;zz<bitSymbol;zz++){
               tempixTab [zz] = syndromeRegTab[jj*bitSymbol+ zz];
            }

            RsGfMultiplier(ppTab, epsilonMSB, tempixTab, PrimPoly, bitSymbol);

            if (jj>0){
               for (aa=0;aa<(bitSymbol);aa++){
                  sumRegTab[jj*bitSymbol+aa]= sumRegTab[(jj-1)*bitSymbol+aa] ^ ppTab[aa];
               }
            }else{
               for (aa=0;aa<(bitSymbol);aa++){
                  sumRegTab[aa]= ppTab[aa];
               }
            }
         }


         //---------------------------------------------------------------
         // calculate epsilonMSB
         //---------------------------------------------------------------
         if (ii<(syndromeLength+1)){
            for (jj=0;jj<bitSymbol;jj++){
               epsilonMSB[jj] = epsilonRegTab[((syndromeLength-ii)*bitSymbol)+jj];
            }
         }else{
            for (jj=0;jj<bitSymbol;jj++){
               epsilonMSB[jj] = 0;
            }
         }
      }
   }


   //---------------------------------------------------------------
   // free memory
   //---------------------------------------------------------------
   delete[] epsilonMSB;
   delete[] ppTab;
   delete[] tempixTab;
   delete[] powerTab;


}
