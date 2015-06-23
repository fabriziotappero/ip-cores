//===================================================================
// Module Name : RsDecodeSyndromeEmulator
// File Name   : RsDecodeSyndromeEmulator.cpp
// Function    : RS Decoder syndrome emulator
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
void RsDecodeSyndromeEmulator(int *regSyndrome, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *MrefTab, int *PrefTab, int *DataIn) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int aa, bb, kk, ii,ff, zz, tt;
   int syndromeLength;
   int tempix;
   int LoopSize;
   int Pidx;
   int init;
   int idx1;
   int idx2;
   int tempNum;
   int mmTabSize = (bitSymbol*2) -1;

   //---------------------------------------------------------------
   // calculate syndrome polynom length
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;

   int *powerTab;
   int *DataInBin;
   int *productTab;
   int *bbTab;
   int *ppTab;
   int *ttTab;
   int *bidon;

   powerTab        = new int[bitSymbol];
   DataInBin       = new int[bitSymbol];
   productTab      = new int[syndromeLength*bitSymbol];
   bbTab           = new int[bitSymbol];
   ppTab           = new int[bitSymbol];
   ttTab           = new int[bitSymbol];
   bidon           = new int[bitSymbol];


   //---------------------------------------------------------------
   //+ initialize powerTab
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //---------------------------------------------------------------
   // Dec2Bin Datain[0]
   //---------------------------------------------------------------
   tempix = DataIn[0];

   for (zz =bitSymbol-1; zz>=0;zz=zz-1) {
      if (tempix >= powerTab[zz]) {
         tempix = tempix - powerTab[zz];
         DataInBin [zz] = 1;
      }else{
         DataInBin [zz] = 0;
      }
   }


   //---------------------------------------------------------------
   // assign regSyndrome
   //---------------------------------------------------------------
   for (ii=0; ii < syndromeLength; ii++) {
      for (zz=0; zz < bitSymbol; zz++) {
         regSyndrome[ii*bitSymbol+zz] = DataInBin [zz];
      }
   }




   //---------------------------------------------------------------
   // calculate regSyndrome
   //---------------------------------------------------------------
   for (ii=1; ii < TotalSize; ii++) {


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
               productTab[zz*bitSymbol+bb] = regSyndrome[zz*bitSymbol+bb];
            }
         }else{
         ttTab[0] = 1;

         for (kk = 1; kk <bitSymbol;kk++){
            ttTab[kk] = 0;
         }

         bbTab[0] = 0;
         bbTab[1] = 1;

         for (kk = 2; kk <bitSymbol;kk++){
           bbTab[kk] = 0;
         }

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
                        productTab[zz*bitSymbol+Pidx] = productTab[zz*bitSymbol+Pidx] ^ regSyndrome[zz*bitSymbol+idx2];
                     }
                  }
               }
            }
         }
      }
      }


      //---------------------------------------------------------------
      // Dec2Bin Datain[0]
      //---------------------------------------------------------------
      tempix = DataIn[ii];
      for (zz =bitSymbol-1; zz>=0;zz=zz-1) {
         if (tempix >= powerTab[zz]) {
            tempix = tempix - powerTab[zz];
            DataInBin [zz] = 1;
         }else{
            DataInBin [zz] = 0;
         }
      }


      //---------------------------------------------------------------
      // assign regSyndrome
      //---------------------------------------------------------------
      for (aa=0; aa < syndromeLength; aa++) {
         for (zz=0; zz < bitSymbol; zz++) {
            regSyndrome[aa*bitSymbol+zz] = DataInBin [zz] ^ productTab[aa*bitSymbol+zz];
         }
      }
   }





   //---------------------------------------------------------------
   // Free memory
   //---------------------------------------------------------------
   delete[] powerTab;
   delete[] DataInBin;
   delete[] productTab;
   delete[] bbTab;
   delete[] ppTab;
   delete[] ttTab;
   delete[] bidon;


}
