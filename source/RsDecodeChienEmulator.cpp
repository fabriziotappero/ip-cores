//===================================================================
// Module Name : RsDecodeChienEmulator
// File Name   : RsDecodeChienEmulator.cpp
// Function    : RS decoder chien emulator
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

void RsDecodeChienEmulator(int *numError,int *errorOutTab, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *MrefTab, int *PrefTab, int *LambdaInTab, int *OmegaInTab, int *EpsilonInTab, int *ErasureInTab) {


   //---------------------------------------------------------------
   // C++ variables int
   //---------------------------------------------------------------
   int syndromeLength;
   int aa,bb,ff,ii,jj,kk,tt,zz;
   int tempix;
   int MaxValue;
   int param1;
   int initValue;
   int numErrorReg2 = 0;
   int numErrorReg  = 0;
   int mmTabSize = (bitSymbol*2) -1;
   int idx1;
   int idx2;
   int tempo2;
   int index;
   int Pidx;
   int init;
   int tempNum;
   int lambdaFlag;

   //---------------------------------------------------------------
   // syndrome length calculation
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // C++ variables pointer
   //---------------------------------------------------------------
   int *x1Tab;
   int *x2Tab;
   int *initTab;

   int *LambdaRegTab;
   int *LambdaUpTab;

   int *LambdaRegTab2;
   int *LambdaUpTab2;



   int *lambdaSum;
   int *lambdaEven;
   int *lambdaOdd;
   int *lambdaSumReg;
   int *lambdaEvenReg;
   int *lambdaEvenReg2;
   int *lambdaEvenReg3;
   int *lambdaOddReg;
   int *lambdaOddReg2;
   int *lambdaOddReg3;
   int *denomE0;
   int *denomE0Reg;
   int *denomE0Inv;
   int *denomE0InvReg;
   int *denomE1;
   int *denomE1Reg;
   int *denomE1Inv;
   int *denomE1InvReg;
   int *bidon;
   int *numeReg;
   int *numeReg2;
   int *errorValueE0;
   int *errorValueE1;
   int *ppTab;
   int *bbTab;
   int *ttTab;
   int *powerTab;
   int *coeffTab;
   int *OmegaRegTab;
   int *OmegaNewTab;
   int *omegaSum;
   int *omegaSumReg;
   int *EpsilonRegTab;
   int *EpsilonNewTab;
   int *epsilonSum;
   int *epsilonSumReg;
   int *epsilonOdd;
   int *epsilonOddReg;
   int *errorOutTabBin;
   int *productTab;


   //------------------------------------------------------------------------
   // MaxValue calculation
   //------------------------------------------------------------------------
   MaxValue = 2;
   for(ii=0; ii<(bitSymbol-1); ii++){
      MaxValue = MaxValue*2;
   }


   coeffTab             = new int[MaxValue];
   initTab              = new int[MaxValue];
   lambdaSum            = new int[bitSymbol];
   lambdaEven           = new int[bitSymbol];
   lambdaOdd            = new int[bitSymbol];
   lambdaSumReg         = new int[bitSymbol];
   lambdaEvenReg        = new int[bitSymbol];
   lambdaEvenReg2       = new int[bitSymbol];
   lambdaEvenReg3       = new int[bitSymbol];
   lambdaOddReg         = new int[bitSymbol];
   lambdaOddReg2        = new int[bitSymbol];
   lambdaOddReg3        = new int[bitSymbol];
   x1Tab                = new int[bitSymbol];
   x2Tab                = new int[bitSymbol];
   denomE0              = new int[bitSymbol];
   denomE0Reg           = new int[bitSymbol];
   denomE0Inv           = new int[bitSymbol];
   denomE0InvReg        = new int[bitSymbol];
   denomE1              = new int[bitSymbol];
   denomE1Reg           = new int[bitSymbol];
   denomE1Inv           = new int[bitSymbol];
   denomE1InvReg        = new int[bitSymbol];
   bbTab                = new int[bitSymbol];
   ttTab                = new int[bitSymbol];
   ppTab                = new int[bitSymbol];
   numeReg              = new int[bitSymbol];
   numeReg2             = new int[bitSymbol];
   bidon                = new int[bitSymbol];
   errorValueE0         = new int[bitSymbol];
   errorValueE1         = new int[bitSymbol];
   omegaSum             = new int[bitSymbol];
   omegaSumReg          = new int[bitSymbol];
   epsilonSum           = new int[bitSymbol];
   epsilonSumReg        = new int[bitSymbol];
   epsilonOdd           = new int[bitSymbol];
   epsilonOddReg        = new int[bitSymbol];
   LambdaRegTab         = new int[syndromeLength*bitSymbol];
   LambdaUpTab          = new int[syndromeLength*bitSymbol];

   LambdaRegTab2        = new int[syndromeLength*bitSymbol];
   LambdaUpTab2         = new int[syndromeLength*bitSymbol];


   OmegaRegTab          = new int[syndromeLength*bitSymbol];
   OmegaNewTab          = new int[syndromeLength*bitSymbol];
   EpsilonRegTab        = new int[(syndromeLength+1)*bitSymbol];
   EpsilonNewTab        = new int[(syndromeLength+1)*bitSymbol];
   powerTab             = new int[bitSymbol];
   errorOutTabBin       = new int[bitSymbol];
   productTab           = new int[(syndromeLength+1)*bitSymbol];

   //---------------------------------------------------------------
   // initialize lambdaFlag
   //---------------------------------------------------------------
   lambdaFlag = 1;


   //---------------------------------------------------------------
   //+ initialize powerTab
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //------------------------------------------------------------------------
   //- coeffTab initialize
   //------------------------------------------------------------------------
   coeffTab [0] = 0;
   coeffTab [1] = MaxValue - TotalSize;
   param1 = MaxValue - TotalSize;


   //------------------------------------------------------------------------
   //- x1Tab initialize
   //------------------------------------------------------------------------
   x1Tab[0] = 1;
   for (ii=1;ii<bitSymbol;ii++){
      x1Tab[ii] = 0;
   }


   //------------------------------------------------------------------------
   //- x2Tab initialize
   //------------------------------------------------------------------------
   x2Tab[0] = 0;
   x2Tab[1] = 1;
   for (ii=2;ii<bitSymbol;ii++){
      x2Tab[ii] = 0;
   }


   //------------------------------------------------------------------------
   //- phase 1 : initTab calculation
   //------------------------------------------------------------------------
   for(ii=0;ii<MaxValue;ii++){

      //------------------------------------------------------------------------
      //- ppTab = x1Tab * x2Tab
      //------------------------------------------------------------------------
      RsGfMultiplier(ppTab, x1Tab, x2Tab, PrimPoly, bitSymbol);


      //------------------------------------------------------------------------
      //- reassign x1Tab
      //------------------------------------------------------------------------
      for (zz=0; zz<bitSymbol;zz++){
         x1Tab[zz]	= ppTab[zz];
      }


      //------------------------------------------------------------------------
      //- Binary To Decimal initValue[dec] = x1Tab[bin]
      //------------------------------------------------------------------------
      initValue = 0;
      for (zz=0; zz<bitSymbol;zz++){
         initValue = initValue + x1Tab[zz] * powerTab[zz];
      }
      initTab[ii] = initValue;
   }


   //------------------------------------------------------------------------
   //- Decimal To Binary x1Tab[bin] = x2Tab[bin] = tempix[dec]
   //------------------------------------------------------------------------
   tempix = initTab[param1-1];

   for (zz =bitSymbol-1; zz>=0;zz--) {
      if (tempix >= powerTab[zz]) {
         tempix = tempix - powerTab[zz];
         x1Tab [zz] = 1;
         x2Tab [zz] = 1;
      }else{
         x1Tab [zz] = 0;
         x2Tab [zz] = 0;
      }
   }


   //------------------------------------------------------------------------
   //- phase 2
   //------------------------------------------------------------------------
   for (ii = 1;ii<(syndromeLength+1); ii++){

      //------------------------------------------------------------------------
      //- ppTab = x1Tab * x2Tab
      //------------------------------------------------------------------------
      RsGfMultiplier(ppTab, x1Tab, x2Tab, PrimPoly, bitSymbol);


      //------------------------------------------------------------------------
      //- reassign x1Tab
      //------------------------------------------------------------------------
      for (zz=0; zz<bitSymbol;zz++){
         x2Tab[zz]	= ppTab[zz];
      }


      //------------------------------------------------------------------------
      //- Binary To Decimal initValue[dec] = x2Tab[bin]
      //------------------------------------------------------------------------
      initValue = 0;
      for (zz=0; zz<bitSymbol;zz++){
         initValue = initValue + x2Tab[zz] * powerTab[zz];
      }
      tempo2= initValue;


      //------------------------------------------------------------------------
      //- index search
      //------------------------------------------------------------------------
      index = 0;
      for (jj=0;jj<MaxValue;jj++){
         if (initTab[jj]==tempo2){
            if (jj == (MaxValue-1)){
               index = 0;
            }else{
               index = jj;
            }
         }
      }
      coeffTab[ii+1] = index+1;
   }



   //---------------------------------------------------------------
   // initialize LambaRegTab
   //---------------------------------------------------------------
   for (ii=0; ii < syndromeLength; ii++) {
      for (zz=0; zz < bitSymbol; zz++) {
         LambdaRegTab[ii*bitSymbol+zz] = 0;
      }
   }

   //---------------------------------------------------------------
   // initialize OmegaRegTab
   //---------------------------------------------------------------
   for (ii=0; ii < syndromeLength; ii++) {
      for (zz=0; zz < bitSymbol; zz++) {
         OmegaRegTab[ii*bitSymbol+zz] = 0;
      }
   }



   for (zz=0; zz < bitSymbol; zz++) {
      lambdaSum [zz] = 0;
      lambdaEven [zz] = 0;
      lambdaOdd [zz] = 0;
      omegaSum [zz] = 0;
      epsilonSum [zz] = 0;
      epsilonOdd [zz] = 0;
      lambdaSumReg[zz] = 0;
      lambdaEvenReg3[zz] = 0;
      lambdaEvenReg2[zz] = 0;
      lambdaEvenReg[zz] = 0;
      lambdaOddReg3[zz] = 0;
      lambdaOddReg2[zz] = 0;
      lambdaOddReg[zz] = 0;
      denomE0[zz] = 0;
      denomE1[zz] = 0;
      denomE0Inv[zz] = 0;
      denomE1Inv[zz] = 0;
      denomE0Reg[zz] = 0;
      denomE1Reg[zz] = 0;
      denomE0InvReg[zz] = 0;
      denomE1InvReg[zz] = 0;
      numeReg2[zz] = 0;
      numeReg[zz] = 0;
      omegaSumReg[zz] = 0;
      epsilonSumReg[zz] = 0;
      epsilonOddReg[zz] = 0;
      errorValueE0[zz] = 0;
      errorValueE1[zz] = 0;
   }


   //---------------------------------------------------------------
   // Chien algorithm loop
   //---------------------------------------------------------------
   for (ii=0; ii < (TotalSize+4); ii++) {



      //---------------------------------------------------------------
      // ii == 0
      //---------------------------------------------------------------
      if (ii ==0){

         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < syndromeLength*bitSymbol; tt++) {
            productTab [tt] = 0;
         }

         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            if (coeffTab[zz] == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = LambdaInTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<coeffTab[zz]+1; ff++){
                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }

                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==coeffTab[zz]) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ LambdaInTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // update LambdaRegTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               LambdaRegTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }




         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < syndromeLength*bitSymbol; tt++) {
            productTab [tt] = 0;
         }

         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            if (coeffTab[zz] == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = OmegaInTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<coeffTab[zz]+1; ff++){
                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }

                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==coeffTab[zz]) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ OmegaInTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // update OmegaRegTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               OmegaRegTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }



         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < (syndromeLength+1)*bitSymbol; tt++) {
            productTab [tt] = 0;
         }


         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz <= syndromeLength; zz++) {
            if (coeffTab[zz] == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = EpsilonInTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<coeffTab[zz]+1; ff++){
                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }

                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==coeffTab[zz]) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ EpsilonInTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // update EpsilonRegTab
         //---------------------------------------------------------------
         for (zz=0; zz <= syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               EpsilonRegTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }


      }else{

         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < syndromeLength*bitSymbol; tt++) {
            productTab [tt] = 0;
         }


         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            if (zz == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = LambdaRegTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<zz+1; ff++){
                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }

                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==zz) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ LambdaRegTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // calulate LambdaUpTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               LambdaUpTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }


         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < syndromeLength*bitSymbol; tt++) {
            productTab [tt] = 0;
         }


         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            if (zz == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = OmegaRegTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<zz+1; ff++){
                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }

                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==zz) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ OmegaRegTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }


         //---------------------------------------------------------------
         // calulate OmegaNewTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               OmegaNewTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }

         //---------------------------------------------------------------
         // reset productTab
         //---------------------------------------------------------------
         for (tt=0; tt < (syndromeLength+1)*bitSymbol; tt++) {
            productTab [tt] = 0;
         }

         //---------------------------------------------------------------
         // update productTab
         //---------------------------------------------------------------
         for (zz=0; zz <= syndromeLength; zz++) {
            
            
            if (zz == 0) {
               for (bb = 0; bb <bitSymbol;bb++){
                  productTab[zz*bitSymbol+bb] = EpsilonRegTab[zz*bitSymbol+bb];
               }
            }else{
               ttTab[0] = 1;

               for (kk = 1; kk <bitSymbol;kk++){ ttTab[kk] = 0;}

               bbTab[0] = 0;
               bbTab[1] = 1;

               for (kk = 2; kk <bitSymbol;kk++){ bbTab[kk] = 0;}

               //------------------------------------------------------------------------
               //------------------------------------------------------------------------
               for(ff=1; ff<zz+1; ff++){

                  //------------------------------------------------------------------------
                  // ppTab = ttTab * bbTab
                  //------------------------------------------------------------------------
                  RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

                  //------------------------------------------------------------------------
                  // reassign ttTab
                  //------------------------------------------------------------------------
                  for (kk = 0; kk <bitSymbol;kk++){
                     ttTab[kk]	= ppTab[kk];
                  }


                  //------------------------------------------------------------------------
                  // write P_OUT[0]
                  //------------------------------------------------------------------------
                  if (ff==zz) {
                     for (Pidx=0; Pidx<bitSymbol; Pidx++){
                        init = 0;
                         for (idx2=0; idx2<bitSymbol;idx2++){bidon [idx2] = 0;}
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
                                     } else {
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
                               productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ EpsilonRegTab[zz*bitSymbol+idx2];
                            }
                         }
                     }
                  }
               }
            }
         }

         //---------------------------------------------------------------
         // calulate EpsilonNewTab
         //---------------------------------------------------------------
         for (zz=0; zz <= syndromeLength; zz++) {
            for (aa=0; aa < bitSymbol; aa++) {
               EpsilonNewTab[zz*bitSymbol+aa] = productTab[zz*bitSymbol+aa];
            }
         }

         //---------------------------------------------------------------
         // calculate lambdaSum
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            lambdaSum[bb] = 0;
            for (zz=0; zz < syndromeLength; zz++) {
               lambdaSum[bb] = lambdaSum[bb] ^ LambdaRegTab[zz*bitSymbol+bb];
            }
         }

         //---------------------------------------------------------------
         // calculate lambdaEven
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            lambdaEven[bb] = 0;
            for (zz=0; zz < syndromeLength; zz++) {
               if (zz % 2 == 0){
                  lambdaEven[bb] = lambdaEven[bb] ^ LambdaRegTab[zz*bitSymbol+bb];
               }
            }
         }


         //---------------------------------------------------------------
         // calculate lambdaOdd
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            lambdaOdd[bb] = 0;
            for (zz=0; zz < syndromeLength; zz++) {
               if (zz % 2 == 1){
                  lambdaOdd[bb] = lambdaOdd[bb] ^ LambdaRegTab[zz*bitSymbol+bb];
               }
            }
         }

         //---------------------------------------------------------------
         // calculate omegaSum
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            omegaSum[bb] = 0;
            for (zz=0; zz < syndromeLength; zz++) {
               omegaSum[bb] = omegaSum[bb] ^ OmegaRegTab[zz*bitSymbol+bb];
            }
         }


         //---------------------------------------------------------------
         // calculate epsilonSum
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            epsilonSum[bb] = 0;
            for (zz=0; zz <= syndromeLength; zz++) {
               epsilonSum[bb] = epsilonSum[bb] ^ EpsilonRegTab[zz*bitSymbol+bb];
            }
         }


         //---------------------------------------------------------------
         // calculate epsilonOdd
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            epsilonOdd[bb] = 0;
            for (zz=0; zz <= syndromeLength; zz++) {
               if (zz % 2 == 1){
                  epsilonOdd[bb] = epsilonOdd[bb] ^ EpsilonRegTab[zz*bitSymbol+bb];
               }
            }
         }

         //---------------------------------------------------------------
         // calculate denomE0
         //---------------------------------------------------------------
         RsGfMultiplier(denomE0, lambdaOddReg, epsilonSumReg, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // calculate denomE1
         //---------------------------------------------------------------
         RsGfMultiplier(denomE1, lambdaSumReg, epsilonOddReg, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // calculate denomE0Inv
         //---------------------------------------------------------------
         RsGfInverse(denomE0Inv, denomE0Reg, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // calculate denomE1Inv
         //---------------------------------------------------------------
         RsGfInverse(denomE1Inv, denomE1Reg, PrimPoly, bitSymbol);

         //---------------------------------------------------------------
         // calculate errorValueE0
         //---------------------------------------------------------------
         RsGfMultiplier(errorValueE0, numeReg2, denomE0InvReg, PrimPoly, bitSymbol);


         //---------------------------------------------------------------
         // calculate errorValueE1
         //---------------------------------------------------------------
         RsGfMultiplier(errorValueE1, numeReg2, denomE1InvReg, PrimPoly, bitSymbol);

         //---------------------------------------------------------------
         // calculate errorOut
         //---------------------------------------------------------------
         if (ii>3) {
            if (ErasureInTab [ii-4] == 1){
               for (bb=0; bb < bitSymbol; bb++) {
                  errorOutTabBin [bb] = errorValueE1[bb];
               }
            }else{
               lambdaFlag = 1;
               for (bb=0; bb < bitSymbol; bb++) {
                  if (lambdaEvenReg3 [bb] != lambdaOddReg3[bb]){
                     lambdaFlag = 0;
                  }
               }
            
               if (lambdaFlag == 1) {
                  for (bb=0; bb < bitSymbol; bb++) {
                     errorOutTabBin [bb] = errorValueE0[bb];
                  }
               }else{
                  for (bb=0; bb < bitSymbol; bb++) {
                     errorOutTabBin [bb] = 0;
                  }
               }
            }

            //---------------------------------------------------------------
            // bin to dec
            //---------------------------------------------------------------
            tempNum = 0;
            for(kk=0; kk< bitSymbol; kk++){
               tempNum = tempNum + errorOutTabBin[kk] * powerTab[kk];
            }
            errorOutTab[ii-4] = tempNum;
         }

         //---------------------------------------------------------------
         // update numErrorReg2
         //---------------------------------------------------------------
            lambdaFlag = 1;
            for (bb=0; bb < bitSymbol; bb++) {
               if (lambdaEven [bb] != lambdaOdd[bb]){
                  lambdaFlag = 0;
               }
            }
         
         if (ii == (TotalSize)){
            if (lambdaFlag==1) {
               numErrorReg2 = numErrorReg + 1;
            }else{
               numErrorReg2 = numErrorReg;
            }
         }

         //---------------------------------------------------------------
         // update numErrorReg
         //---------------------------------------------------------------
         if (ii == 0){
            numErrorReg = 0;
         }else{
            if (lambdaFlag==1) {
               numErrorReg = numErrorReg + 1;
            }
         }


         //---------------------------------------------------------------
         // update LambdaRegTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (bb=0; bb < bitSymbol; bb++) {
               LambdaRegTab[zz*bitSymbol+bb] = LambdaUpTab[zz*bitSymbol+bb];
            }
         }

         //---------------------------------------------------------------
         // update OmegaRegTab
         //---------------------------------------------------------------
         for (zz=0; zz < syndromeLength; zz++) {
            for (bb=0; bb < bitSymbol; bb++) {
               OmegaRegTab[zz*bitSymbol+bb] = OmegaNewTab[zz*bitSymbol+bb];
            }
         }


         //---------------------------------------------------------------
         // update EpsilonRegTab
         //---------------------------------------------------------------
         for (zz=0; zz <= syndromeLength; zz++) {
            for (bb=0; bb < bitSymbol; bb++) {
               EpsilonRegTab[zz*bitSymbol+bb] = EpsilonNewTab[zz*bitSymbol+bb];
            }
         }

         //---------------------------------------------------------------
         // update registers
         //---------------------------------------------------------------
         for (bb=0; bb < bitSymbol; bb++) {
            lambdaSumReg   [bb] = lambdaSum[bb];
            lambdaEvenReg3 [bb] = lambdaEvenReg2[bb];
            lambdaEvenReg2 [bb] = lambdaEvenReg [bb];
            lambdaEvenReg  [bb] = lambdaEven    [bb];
            lambdaOddReg3  [bb] = lambdaOddReg2[bb];
            lambdaOddReg2  [bb] = lambdaOddReg [bb];
            lambdaOddReg   [bb] = lambdaOdd    [bb];
            denomE0Reg     [bb] = denomE0 [bb];
            denomE1Reg     [bb] = denomE1 [bb];
            denomE0InvReg  [bb] = denomE0Inv [bb];
            denomE1InvReg  [bb] = denomE1Inv [bb];
            numeReg2       [bb] = numeReg [bb];
            numeReg        [bb] = omegaSumReg [bb];
            omegaSumReg    [bb] = omegaSum [bb];
            epsilonSumReg  [bb] = epsilonSum[bb];
            epsilonOddReg  [bb] = epsilonOdd[bb];
         }
      }
   }


   //---------------------------------------------------------------
   // assign numError
   //---------------------------------------------------------------
   numError [0] = numErrorReg2;


   //---------------------------------------------------------------
   // Free memory
   //---------------------------------------------------------------
   delete[] x1Tab;
   delete[] x2Tab;
   delete[] initTab;
   delete[] LambdaRegTab;
   delete[] LambdaUpTab;
   delete[] LambdaRegTab2;
   delete[] LambdaUpTab2;
   delete[] lambdaSum;
   delete[] lambdaEven;
   delete[] lambdaOdd;
   delete[] lambdaSumReg;
   delete[] lambdaEvenReg;
   delete[] lambdaEvenReg2;
   delete[] lambdaEvenReg3;
   delete[] lambdaOddReg;
   delete[] lambdaOddReg2;
   delete[] lambdaOddReg3;
   delete[] denomE0;
   delete[] denomE0Reg;
   delete[] denomE0Inv;
   delete[] denomE0InvReg;
   delete[] denomE1;
   delete[] denomE1Reg;
   delete[] denomE1Inv;
   delete[] denomE1InvReg;
   delete[] bidon;
   delete[] numeReg;
   delete[] numeReg2;
   delete[] errorValueE0;
   delete[] errorValueE1;
   delete[] ppTab;
   delete[] bbTab;
   delete[] ttTab;
   delete[] powerTab;
   delete[] coeffTab;
   delete[] OmegaRegTab;
   delete[] OmegaNewTab;
   delete[] omegaSum;
   delete[] omegaSumReg;
   delete[] EpsilonRegTab;
   delete[] EpsilonNewTab;
   delete[] epsilonSum;
   delete[] epsilonSumReg;
   delete[] epsilonOdd;
   delete[] epsilonOddReg;
   delete[] errorOutTabBin;
   delete[] productTab;


}
