//===================================================================
// Module Name : RsDecodeEuclideEmulator
// File Name   : RsDecodeEuclideEmulator.cpp
// Function    : RS Decoder euclide emulator
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
void RsGfInverse( int*, int*, int, int);


void RsDecodeEuclideEmulator(int *numShiftedReg, int *OmegaRegTab, int *LambdaRegTab, int numErasure, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *syndromeRegTab) {


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii,jj,kk;;
   int phase;
   int offset;
   int skip = 0;
   int tempNum;


   //---------------------------------------------------------------
   // initialize numShiftedReg
   //---------------------------------------------------------------
   numShiftedReg[0] = 0;


   //---------------------------------------------------------------
   // syndrome Length Calculation
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int *euclideTab;
   int *OmegaBkpTab;
   int *OmegaMultqNewTab;
   int *LambdaBkpTab;
   int *LambdaXorRegTab;
   int *LambdaMultqNewTab;
   int *saveOmega;
   int *OmegaInvIn;
   int *OmegaInv;
   int *OmegaRegTabSAVE;
   int *OmegaBkpReg;
   int *OmegaInvReg;
   int *LambdaRegTabSAVE;
   int *qNew;
   int *qNewReg;
   int *tempTab2;
   int *tempTab;
   int *powerTab;
   int LoopSize;


   euclideTab        = new int[(syndromeLength+1)];
   powerTab          = new int[bitSymbol];
   OmegaBkpTab       = new int[syndromeLength*bitSymbol];
   OmegaMultqNewTab  = new int[syndromeLength*bitSymbol];
   OmegaRegTabSAVE   = new int[syndromeLength*bitSymbol];
   saveOmega         = new int[bitSymbol];
   OmegaInvIn        = new int[bitSymbol];
   OmegaInv          = new int[bitSymbol];
   OmegaBkpReg       = new int[bitSymbol];
   OmegaInvReg       = new int[bitSymbol];
   LambdaBkpTab      = new int[syndromeLength*bitSymbol];
   LambdaXorRegTab   = new int[syndromeLength*bitSymbol];
   LambdaMultqNewTab = new int[syndromeLength*bitSymbol];
   LambdaRegTabSAVE  = new int[syndromeLength*bitSymbol];
   qNew              = new int[bitSymbol];
   qNewReg           = new int[bitSymbol];
   tempTab2          = new int[bitSymbol];
   tempTab           = new int[bitSymbol];


   //---------------------------------------------------------------
   // calculate powerTab
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


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


   //---------------------------------------------------------------
   // Initialize variables
   //---------------------------------------------------------------
   phase             = 0;
   offset            = 0;
   numShiftedReg [0] = 0;

   for(kk=0; kk< bitSymbol; kk++){
      qNew[kk]        = 0;
      qNewReg[kk]     = 0;
      tempTab2[kk]    = 0;
      tempTab[kk]     = 0;
      OmegaInvIn[kk]  = 0;
      OmegaInv[kk]    = 0;
      saveOmega[kk]   = 0;
      OmegaInvReg[kk] = 0;
   }


   //---------------------------------------------------------------
   // calculate LoopSize of Euclide algorithm
   //---------------------------------------------------------------
   if (numErasure <= syndromeLength) { 
      LoopSize = euclideTab[numErasure];
   }else{
      LoopSize = 3;
   }


   //---------------------------------------------------------------
   // OmegaRegTab && LambdaRegTab calculation
   //---------------------------------------------------------------
   for(ii=0; ii <= LoopSize; ii++){
      //---------------------------------------------------------------
      // sync == 1'b1
      //---------------------------------------------------------------
      if (ii == 0){
         for(jj=0; jj < syndromeLength*bitSymbol; jj++){
            OmegaRegTab[jj]      = syndromeRegTab[jj];
            OmegaBkpTab[jj]      = 0;
            LambdaRegTab[jj]     = 0;
            LambdaXorRegTab[jj]  = 0;
            LambdaBkpTab[jj]     = 0;
            OmegaRegTabSAVE[jj]  = 0;
            OmegaMultqNewTab[jj] = 0;
            LambdaMultqNewTab[jj]= 0;
            LambdaRegTabSAVE[jj] = 0;
         }
         LambdaRegTab[0]  = 1;
         OmegaBkpTab[(syndromeLength-1)*bitSymbol] = 1;
         phase            = 1;
         offset           = 1;
         numShiftedReg[0] = 0;
      }

      //---------------------------------------------------------------
      // sync == 1'b0
      //---------------------------------------------------------------
      else{
         skip = 1;
         //---------------------------------------------------------------
         // calculate skip
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            if (OmegaRegTab[(syndromeLength-1)*bitSymbol+kk] == 1){
               skip = 0;
            }
         }

         //---------------------------------------------------------------
         // save omega_bkp[syndromeLength-1]
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            saveOmega[kk] = OmegaBkpTab[(syndromeLength-1)*bitSymbol+kk];
         }


         //---------------------------------------------------------------
         // selectOmegaInverse Input
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            OmegaInvIn[kk] = OmegaRegTab[(syndromeLength-1)*bitSymbol+kk];
         }

         //---------------------------------------------------------------
         // calculate omegaInv
         //---------------------------------------------------------------
         RsGfInverse(OmegaInv, OmegaInvIn, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // calculate qNew
         //---------------------------------------------------------------
         RsGfMultiplier(qNew, OmegaBkpReg, OmegaInvReg, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // update OmegaMultqNewTab && LambdaMultqNewTab
         //---------------------------------------------------------------
         for(jj=0; jj< syndromeLength; jj++){
            //---------------------------------------------------------------
            // for omegaMultqNew
            //---------------------------------------------------------------
            for(kk=0; kk< bitSymbol; kk++){
               tempTab[kk] = OmegaRegTab[jj*bitSymbol+kk];
            }
            RsGfMultiplier(tempTab2, tempTab, qNewReg, PrimPoly, bitSymbol);
            for(kk=0; kk< bitSymbol; kk++){
               OmegaMultqNewTab[jj*bitSymbol+kk] = tempTab2[kk];
            }
            //---------------------------------------------------------------
            // for lambdaMultqNew
            //---------------------------------------------------------------
            for(kk=0; kk< bitSymbol; kk++){
               tempTab[kk] = LambdaRegTab[jj*bitSymbol+kk];
            }
            RsGfMultiplier(tempTab2, tempTab, qNewReg, PrimPoly, bitSymbol);
            for(kk=0; kk< bitSymbol; kk++){
               LambdaMultqNewTab[jj*bitSymbol+kk] = tempTab2[kk];
            }
         }


         //---------------------------------------------------------------
         // phase == 2'd0
         //---------------------------------------------------------------
         if (phase == 0){
            //---------------------------------------------------------------
            // skip == 0 && offset == 0
            //---------------------------------------------------------------
            if ((skip == 0) && (offset == 0)) {
               numShiftedReg[0] = numShiftedReg[0]+1;

               //---------------------------------------------------------------
               // save OmegaRegTab Value
               //---------------------------------------------------------------
               for(jj=0; jj < syndromeLength*bitSymbol; jj++){
                  OmegaRegTabSAVE[jj]  = OmegaRegTab[jj];
                  LambdaRegTabSAVE[jj] = LambdaRegTab[jj];
               }


               //---------------------------------------------------------------
               // compute Next OmegaRegTab Value
               //---------------------------------------------------------------
               for(jj=syndromeLength-1; jj >=0; jj--){
                  if (jj > 0) {
                     for(kk=0; kk< bitSymbol; kk++){
                        OmegaRegTab[jj*bitSymbol+kk] = OmegaMultqNewTab[(jj-1)*bitSymbol+kk] ^ OmegaBkpTab[(jj-1)*bitSymbol+kk];
                     }
                  }else{
                     for(kk=0; kk< bitSymbol; kk++){
                        OmegaRegTab[kk] = 0;
                     }
                  }
               }


               //---------------------------------------------------------------
               // compute Next LambdaRegTab Value
               //---------------------------------------------------------------
               for(jj=syndromeLength-1; jj >=0; jj--){
                  if (jj > 0) {
                     for(kk=0; kk< bitSymbol; kk++){
                        LambdaRegTab[jj*bitSymbol+kk] = LambdaBkpTab[jj*bitSymbol+kk] ^ LambdaMultqNewTab[jj*bitSymbol+kk] ^ LambdaXorRegTab[(jj-1)*bitSymbol+kk];
                     }
                  }else{
                     for(kk=0; kk< bitSymbol; kk++){
                        LambdaRegTab[kk] = LambdaBkpTab[kk] ^ LambdaMultqNewTab[kk];
                     }
                  }
               }


               //---------------------------------------------------------------
               // compute Next OmegaBkpTab Value
               //---------------------------------------------------------------
               for(jj=0; jj < syndromeLength*bitSymbol; jj++){
                  OmegaBkpTab[jj] = OmegaRegTabSAVE[jj];
               }


               //---------------------------------------------------------------
               // compute Next LambdaBkpTab Value
               //---------------------------------------------------------------
               for(jj=0; jj < syndromeLength*bitSymbol; jj++){
                  LambdaBkpTab[jj] = LambdaRegTabSAVE[jj];
               }


               //---------------------------------------------------------------
               // compute Next LambdaXorRegTab Value
               //---------------------------------------------------------------
               for(jj=0; jj < (syndromeLength-1)*bitSymbol; jj++){
                  LambdaXorRegTab[jj] = 0;
               }
            }
            else{
               //---------------------------------------------------------------
               // skip == 1
               //---------------------------------------------------------------
               if (skip == 1) {
                  numShiftedReg [0]= numShiftedReg[0]+1;

                  for(jj=syndromeLength-1; jj >=0; jj=jj-1){
                     if (jj > 0) {
                        for(kk=0; kk< bitSymbol; kk++){
                           OmegaRegTab[jj*bitSymbol+kk] = OmegaRegTab[(jj-1)*bitSymbol+kk];
                        }
                     }else{
                        for(kk=0; kk< bitSymbol; kk++){
                           OmegaRegTab[kk] = 0;
                        }
                     }
                  }
               }
               else{
               //---------------------------------------------------------------
               // skip == 0
               //---------------------------------------------------------------
                  //---------------------------------------------------------------
                  // for OmegaBkpTab
                  //---------------------------------------------------------------
                  for(jj=(syndromeLength-1); jj>=0; jj=jj-1){
                     if (jj > 0) {
                        for(kk=0; kk< bitSymbol; kk++){
                           OmegaBkpTab[jj*bitSymbol+kk] = OmegaMultqNewTab[(jj-1)*bitSymbol+kk] ^ OmegaBkpTab[(jj-1)*bitSymbol+kk];
                        }
                     }else{
                        for(kk=0; kk< bitSymbol; kk++){
                           OmegaBkpTab[kk] = 0;
                        }
                     }
                  }


                  //---------------------------------------------------------------
                  // compute Next LambdaXorRegTab Value
                  //---------------------------------------------------------------
                  for(jj=(syndromeLength-2); jj>=0; jj--){
                     if (jj > 0) {
                        for(kk=0; kk< bitSymbol; kk++){
                           LambdaXorRegTab[jj*bitSymbol+kk] = LambdaMultqNewTab[jj*bitSymbol+kk] ^ LambdaXorRegTab[(jj-1)*bitSymbol+kk];
                        }
                     }else{
                        for(kk=0; kk< bitSymbol; kk++){
                           LambdaXorRegTab[kk] = LambdaMultqNewTab[kk];
                        }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // update offset
         //---------------------------------------------------------------
         if (phase == 0) {
            if ((skip == 0) && (offset == 0)){
               offset = 1;
            }
            else{
               if (skip == 1){
                  offset = offset + 1;
               }else{
                  offset = offset - 1;
               }
            }
         }


         //---------------------------------------------------------------
         // update phase
         //---------------------------------------------------------------
         if (phase == 2) {
            phase = 0;
         }else{
            phase = phase + 1;
         }


         //---------------------------------------------------------------
         // update qNewReg
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            qNewReg[kk] = qNew[kk];
         }


         //---------------------------------------------------------------
         // update omegaInvReg
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            OmegaInvReg[kk] = OmegaInv[kk];
         }


         //---------------------------------------------------------------
         // update omegaBkpReg
         //---------------------------------------------------------------
         for(kk=0; kk< bitSymbol; kk++){
            OmegaBkpReg[kk] = saveOmega[kk];
         }
      }
   }


   //---------------------------------------------------------------
   // Free memory
   //---------------------------------------------------------------
   delete[] euclideTab;
   delete[] OmegaBkpTab;
   delete[] OmegaMultqNewTab;
   delete[] LambdaBkpTab;
   delete[] LambdaXorRegTab;
   delete[] LambdaMultqNewTab;
   delete[] saveOmega;
   delete[] OmegaInvIn;
   delete[] OmegaInv;
   delete[] OmegaRegTabSAVE;
   delete[] OmegaBkpReg;
   delete[] OmegaInvReg;
   delete[] LambdaRegTabSAVE;
   delete[] qNew;
   delete[] qNewReg;
   delete[] tempTab2;
   delete[] tempTab;
   delete[] powerTab;

}
