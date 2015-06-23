//===================================================================
// Module Name : RsDecodeErasureEmulator
// File Name   : RsDecodeErasureEmulator.cpp
// Function    : RS Decoder erasure emulator
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

//FILE  *OutFileErasureDebug;


void RsGfMultiplier( int*, int*,int*, int, int);

void RsDecodeErasureEmulator(int failErasure, int numErasure, int *epsilonRegTab, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *MrefTab, int *PrefTab, int *erasureTab) {


   //---------------------------------------------------------------
   //---------------------------------------------------------------
//   OutFileErasureDebug = fopen("RsEmulatorErasureDebug.txt","w");


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii, kk, zz ,aa;
   int Pidx;
   int init;
   int idx2;
   int idx1;
   int mmTabSize = (bitSymbol*2) -1;
   int tempNum;
   int tempix;
   
   int MaxValue;
   int initValue;
   int numErasureWidth;
   syndromeLength = TotalSize - DataSize;

   int *powerInitialNewTab;
   int *powerNewTab;
   int *bbTab;
   int *ppTab;
   int *ttTab;
   int *erasureInitialPowerTab;
   int *powerRegTab;
   int *powerTab;
   int *bidon;
   int *tempixTab;
   int *numErasureBinary;


   powerInitialNewTab     = new int[bitSymbol*bitSymbol];
   powerNewTab            = new int[bitSymbol*bitSymbol];
   bbTab                  = new int[bitSymbol];
   ppTab                  = new int[bitSymbol];
   ttTab                  = new int[bitSymbol];
   bidon                  = new int[bitSymbol];
   tempixTab              = new int[bitSymbol];
   erasureInitialPowerTab = new int[bitSymbol];
   powerRegTab            = new int[bitSymbol];
   powerTab               = new int[bitSymbol];
   numErasureBinary       = new int[bitSymbol];


   //---------------------------------------------------------------
   // MaxValue calculation
   //---------------------------------------------------------------
   MaxValue = 2;
   for(ii=0; ii<(bitSymbol-1); ii++){
      MaxValue = MaxValue*2;
   }


   //---------------------------------------------------------------
   // param1 calculation
   //---------------------------------------------------------------
   int param1 = MaxValue - TotalSize;


   //---------------------------------------------------------------
   // powerTab calculation
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //---------------------------------------------------------------
   // initialize ttTab
   //---------------------------------------------------------------
   ttTab[0] = 1;
   for (ii=1;ii<bitSymbol;ii++){
      ttTab[ii] = 0;
   }


  //---------------------------------------------------------------
  // initialize bbTab
  //---------------------------------------------------------------
   bbTab[0] = 0;
   bbTab[1] = 1;
   for (ii=2;ii<bitSymbol;ii++){
      bbTab[ii] = 0;
   }


  //---------------------------------------------------------------
  //---------------------------------------------------------------
   for (ii=1;ii < (param1+1);ii++){
      RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

      for (kk=0; kk<bitSymbol;kk++){
         ttTab[kk]	= ppTab[kk];
      }
   }

   initValue = 0;
   for (kk=0; kk<bitSymbol;kk++){
      initValue = initValue + ttTab[kk] * powerTab[kk];
      erasureInitialPowerTab [kk] = ttTab[kk];
   }


   //------------------------------------------------------------------------
   // RsDecodeMakeMultErasure Emulation
   //------------------------------------------------------------------------
   ttTab[0] = 1;
   for (ii=1;ii<bitSymbol;ii++){
      ttTab[ii] = 0;
   }


   bbTab[0] = 0;
   bbTab[1] = 1;
   for (ii=2;ii<bitSymbol;ii++){
      bbTab[ii] = 0;
   }


   //------------------------------------------------------------------------
   // ppTab = ttTab * bbTab
   //------------------------------------------------------------------------
   RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);


   //------------------------------------------------------------------------
   // reassign ttTab
   //------------------------------------------------------------------------
   for (kk=0; kk<bitSymbol;kk++){
      ttTab[kk]	= ppTab[kk];
   }


   //------------------------------------------------------------------------
   // initialize powerInitialNewTab
   //------------------------------------------------------------------------
   for (kk=0; kk<bitSymbol*bitSymbol;kk++){
      powerInitialNewTab[kk] = 0;
   }


   //------------------------------------------------------------------------
   // powerInitialNewTab generation
   //------------------------------------------------------------------------
    for (Pidx=0; Pidx<bitSymbol; Pidx++){
       init = 0;

       for (idx2=0; idx2<bitSymbol;idx2++){
          bidon [idx2] = 0;
       }
       for (idx1=0; idx1<mmTabSize;idx1++){
          tempNum = PrefTab [Pidx*mmTabSize+idx1];
          if (tempNum == 1) {
             //------------------------------------------------------------------------
             // search
             //------------------------------------------------------------------------
             for (idx2=0; idx2<bitSymbol;idx2++){
                tempNum = MrefTab[idx1*bitSymbol+idx2];
                if ((tempNum > 0) && (ttTab[tempNum-1] == 1)) {
                   if  (bidon [idx2] == 0) {
                      bidon [idx2] = 1;
                   }
                   else {
                      bidon [idx2] = 0;
                   }
                }
             }
          }
       }
       //------------------------------------------------------------------------
       // printf
       //------------------------------------------------------------------------
       for (idx2=0; idx2<bitSymbol; idx2++){
          if (bidon[idx2] == 1) {
             powerInitialNewTab [Pidx*bitSymbol + idx2] = 1;
          }
       }
   }


   //------------------------------------------------------------------------
   // initialize powerNewTab
   //------------------------------------------------------------------------
   for (kk=0; kk<bitSymbol*bitSymbol;kk++){
      powerNewTab[kk] = 0;
   }


   //------------------------------------------------------------------------
   // powerNewTab generation
   //------------------------------------------------------------------------
   for (Pidx=0; Pidx<bitSymbol; Pidx++){
       init = 0;
       for (idx2=0; idx2<bitSymbol;idx2++){
          bidon [idx2] = 0;
       }
       for (idx1=0; idx1<mmTabSize;idx1++){
          tempNum = PrefTab [Pidx*mmTabSize+idx1];
          if (tempNum == 1) {
             //------------------------------------------------------------------------
             // search
             //------------------------------------------------------------------------
             for (idx2=0; idx2<bitSymbol;idx2++){
                tempNum = MrefTab[idx1*bitSymbol+idx2];
                if ((tempNum > 0) && (ttTab[tempNum-1] == 1)) {
                   if  (bidon [idx2] == 0) {
                      bidon [idx2] = 1;
                   }
                   else {
                      bidon [idx2] = 0;
                   }
                }
             }
          }
       }
       //------------------------------------------------------------------------
       // printf
       //------------------------------------------------------------------------
       for (idx2=0; idx2<bitSymbol; idx2++){
          if (bidon[idx2] == 1) {
             powerNewTab[Pidx*bitSymbol+idx2] = 1;
          }
       }
   }   


   //---------------------------------------------------------------
   // initialize epsilonRegTab
   //---------------------------------------------------------------
   for (kk=0; kk<((syndromeLength+1)*bitSymbol); kk++){
      epsilonRegTab[kk] = 0;
   }


   //---------------------------------------------------------------
   // calculate epsilonRegTab
   //---------------------------------------------------------------
   for (kk=0; kk<TotalSize; kk++){
      //---------------------------------------------------------------
      // sync
      //---------------------------------------------------------------
      if (kk == 0){
         if (erasureTab[0] == 1){
            for (zz=0;zz<bitSymbol;zz++){
               epsilonRegTab[zz] = erasureInitialPowerTab [zz];
            }
            epsilonRegTab[bitSymbol] = 1;
         }else{
            epsilonRegTab[0] = 1;
         }
         for (zz=0;zz<bitSymbol;zz++){
            powerRegTab [zz] = 0;
            for (aa=0;aa<bitSymbol;aa++){
               powerRegTab [zz] = powerRegTab [zz] ^ (erasureInitialPowerTab[aa] & powerInitialNewTab[zz*bitSymbol+aa]);
            }
         }
         for (zz=0; zz<syndromeLength; zz++){
            tempNum = 0;
            for (aa=0; aa<bitSymbol; aa++){
               tempNum = tempNum + epsilonRegTab[zz*bitSymbol+aa] * powerTab[aa];
            }
         }
      } else {
         //---------------------------------------------------------------
         // NOT sync
         //---------------------------------------------------------------
         if (erasureTab[kk] == 1){
            for (zz=syndromeLength; zz>=0; zz--){
               for (aa=0; aa<bitSymbol; aa++){
                  bbTab[aa] = epsilonRegTab[zz*bitSymbol+aa];
               }
               RsGfMultiplier(ppTab, powerRegTab, bbTab, PrimPoly, bitSymbol);
               
               if (zz>0){
                  for (aa=0; aa<bitSymbol; aa++){
                     epsilonRegTab[zz*bitSymbol+aa] = epsilonRegTab[(zz-1)*bitSymbol+aa] ^ ppTab[aa];
                  }
               }else{
                 //---------------------------------------------------------------
                 // epsilonReg0
                 //---------------------------------------------------------------
                  for (aa=0; aa<bitSymbol; aa++){
                     epsilonRegTab[zz*bitSymbol+aa] = ppTab[aa];
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // update powerReg
         //---------------------------------------------------------------
         for (zz=0;zz<bitSymbol;zz++){
            tempixTab[zz] = powerRegTab [zz];
         }
         for (zz=0;zz<bitSymbol;zz++){
            powerRegTab [zz] = 0;
            for (aa=0;aa<bitSymbol;aa++){
               powerRegTab [zz] = powerRegTab [zz] ^ (tempixTab [aa] & powerNewTab[zz*bitSymbol+aa]);
            }
         }
      }
   }


   //---------------------------------------------------------------
   // calculate numErasure
   //---------------------------------------------------------------
   numErasure = 0;

   for (kk=0; kk<TotalSize; kk++){
      if (erasureTab [kk] == 1) {
         numErasure = numErasure + 1;
      }
   }


   //---------------------------------------------------------------
   // convert numErasure (Decimal to binary)
   //---------------------------------------------------------------
   tempix = numErasure;
   for (zz =bitSymbol-1; zz>=0;zz--) {
      if (tempix >= powerTab[zz]) {
         tempix = tempix - powerTab[zz];
         numErasureBinary [zz] = 1;
      }else{
         numErasureBinary [zz] = 0;
      }
   }


   //---------------------------------------------------------------
   // numErasureWidth: allowed size for numErasure register
   //---------------------------------------------------------------
   if (syndromeLength > 2047) {
      numErasureWidth = 12;
   }else{
      if (syndromeLength > 1023) {
         numErasureWidth = 11;
      }else{
         if (syndromeLength > 511) {
            numErasureWidth = 10;
         }else{
            if (syndromeLength > 255) {
               numErasureWidth = 9;
            }else{
               if (syndromeLength > 127) {
                  numErasureWidth = 8;
               }else{
                  if (syndromeLength > 63) {
                     numErasureWidth = 7;
                  }else{
                     if (syndromeLength > 31){
                        numErasureWidth = 6;
                     }else{
                        if (syndromeLength > 15){
                           numErasureWidth = 5;
                        }else{
                           if (syndromeLength > 7){
                              numErasureWidth = 4;
                           }else{
                              if (syndromeLength > 3){
                                 numErasureWidth = 3;
                              }else{
                                 numErasureWidth = 2;
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
   }


   //---------------------------------------------------------------
   //---------------------------------------------------------------
//   fprintf(OutFileErasureDebug, "numErasure       = %d\n", numErasure);
//   fprintf(OutFileErasureDebug, "numErasureWidth  = %d\n", numErasureWidth);
//   fprintf(OutFileErasureDebug, "numErasureBinary = ");
//   for (zz =0; zz<bitSymbol;zz++) {
//      fprintf(OutFileErasureDebug, "%d_", numErasureBinary[zz]);
//   }
//   fprintf(OutFileErasureDebug, "\n");


   //---------------------------------------------------------------
   // adjust numErasure to numErasureWidth size
   //---------------------------------------------------------------
   numErasure = 0;

   for (zz = 0; zz <numErasureWidth; zz++){
      numErasure = numErasure + numErasureBinary[zz] * powerTab[zz];
   }

//   fprintf(OutFileErasureDebug, "numErasure Fixed = %d\n", numErasure);

   //---------------------------------------------------------------
   // calculate numErasure
   //---------------------------------------------------------------
   failErasure = 0;
   
   if (numErasure > syndromeLength) {
   failErasure = 1;
   }

//   fclose(OutFileErasureDebug);


   //---------------------------------------------------------------
   // Free memory
   //---------------------------------------------------------------
   delete[] powerInitialNewTab;
   delete[] powerNewTab;
   delete[] bbTab;
   delete[] ppTab;
   delete[] ttTab;
   delete[] erasureInitialPowerTab;
   delete[] powerRegTab;
   delete[] powerTab;
   delete[] bidon;
   delete[] tempixTab;
   delete[] numErasureBinary;

}
