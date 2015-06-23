//===================================================================
// Module Name : RsDecodeEmulator
// File Name   : RsDecodeEmulator.cpp
// Function    : RS Decoder Top emulator
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

//FILE  *OutFileEmulator;


void RsDecodeSyndromeEmulator(int*, int, int, int, int, int*, int*, int*);
void RsDecodeErasureEmulator(int, int, int*, int, int, int, int, int*, int*, int*);
void RsDecodePolymulEmulator(int*, int, int, int, int, int*, int*);
void RsDecodeEuclideEmulator(int*, int*,int*,int, int, int, int, int, int*);
void RsDecodeShiftOmegaEmulator(int* , int* , int*, int , int , int);
void RsDecodeDegreeEmulator(int*, int*, int, int, int);
void RsDecodeChienEmulator(int*, int*, int, int, int, int, int* , int*, int*, int*, int*, int* );


void RsDecodeEmulator(int *ErrorNum, int *ErasureNum, int *RTLfailFlag, int *RTLDataOut, int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *MrefTab, int *PrefTab, int *coeffTab, int *DataInTab, int *ErasureInTab) {

//   OutFileEmulator = fopen("RsEmulatorTAMPON.v","w");
//   OutFileEmulator = fopen("RsEmulatorTAMPON.txt","at+");

   //---------------------------------------------------------------
   // syndrome Length calculation
   //---------------------------------------------------------------
   int syndromeLength;

   syndromeLength = TotalSize - DataSize;

//   fprintf(OutFileEmulator, "POINt 1\n");

   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int ii,jj,kk, aa,zz;
   int tempNum;
   int tempix;
   int tempix1;
   int tempix2;
   int failErasure;
   int numErasure;
   int failFlag;
   int numErasureWidth;
   int numErasureAdjusted;

   int *powerTab;
   int *OmegaRegTab;
   int *LambdaRegTab;
   int *numShiftedReg;
   int *OmegaShiftedTab;
   int *DegreeLambda;
   int *DegreeOmega;
   int *numError;
   int *errorOutTab;
   int *DataInBin;
   int *errorOutBin;
   int *dataOutBin;
   int *DataOutTab;
   int *regSyndrome;
   int *epsilonRegTab;
   int *sumRegTab;
   int *numErasureBinary;

   DataOutTab      = new int[TotalSize];
   dataOutBin      = new int[bitSymbol];
   errorOutBin     = new int[bitSymbol];
   DataInBin       = new int[bitSymbol];
   powerTab        = new int[bitSymbol];
   regSyndrome     = new int[syndromeLength*bitSymbol];
   epsilonRegTab   = new int[(syndromeLength+1)*bitSymbol];
   sumRegTab       = new int[syndromeLength*bitSymbol];
   OmegaRegTab     = new int[syndromeLength*bitSymbol];
   LambdaRegTab    = new int[syndromeLength*bitSymbol];
   numShiftedReg   = new int[bitSymbol];
   DegreeLambda    = new int[bitSymbol];
   DegreeOmega     = new int[bitSymbol];
   OmegaShiftedTab = new int[syndromeLength*bitSymbol];
   numError        = new int[bitSymbol];
   errorOutTab     = new int[TotalSize];
   numErasureBinary= new int[bitSymbol];

//   fprintf(OutFileEmulator, "POINt 2\n");

   //---------------------------------------------------------------
   //+ initialize powerTab
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }



  //---------------------------------------------------------------
  // RS decode syndrome calculator emulator
  //---------------------------------------------------------------
   RsDecodeSyndromeEmulator(regSyndrome, DataSize, TotalSize, PrimPoly, bitSymbol, MrefTab, PrefTab, DataInTab);

   for (aa=0; aa < syndromeLength; aa++) {
      tempNum = 0;
      for (zz=0; zz < bitSymbol; zz++) {
         tempNum = tempNum + regSyndrome[aa*bitSymbol+zz] * powerTab[zz];
      }
//      fprintf(OutFileEmulator, "regSyndrome [%d] = %d \n", aa, tempNum);
      
   }

//   fprintf(OutFileEmulator, "POINt 3\n");

  //---------------------------------------------------------------
  // RS decode erasure calculator emulator
  //---------------------------------------------------------------
  numErasure  = 0;
  failErasure = 0;
  RsDecodeErasureEmulator(failErasure, numErasure, epsilonRegTab, DataSize, TotalSize, PrimPoly, bitSymbol, MrefTab, PrefTab, ErasureInTab);

   for (aa=0; aa < (syndromeLength+1); aa++) {
      tempNum = 0;
      for (zz=0; zz < bitSymbol; zz++) {
         tempNum = tempNum + epsilonRegTab[aa*bitSymbol+zz] * powerTab[zz];
      }
//      fprintf(OutFileEmulator, "epsilonRegTab [%d] = %d \n", aa, tempNum);
   }
//   fprintf(OutFileEmulator, "POINt 4\n");

   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------

   //---------------------------------------------------------------
   // calculate numErasure
   //---------------------------------------------------------------
   numErasure = 0;

   for (aa=0; aa<TotalSize; aa++){
      if (ErasureInTab [aa] == 1) {
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
   // adjust numErasure to numErasureWidth size
   //---------------------------------------------------------------
   numErasureAdjusted = 0;

   for (zz = 0; zz <numErasureWidth; zz++){
      numErasureAdjusted = numErasureAdjusted + numErasureBinary[zz] * powerTab[zz];
   }


   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------


   //---------------------------------------------------------------
   // calculate numErasure
   //---------------------------------------------------------------
   failErasure = 0;
   
   if (numErasure > syndromeLength) {
   failErasure = 1;
   }

//   fprintf(OutFileEmulator, "POINt 5\n");

  //---------------------------------------------------------------
  // RS decode polymul calculator emulator
  //---------------------------------------------------------------
  RsDecodePolymulEmulator(sumRegTab, DataSize, TotalSize, PrimPoly, bitSymbol, regSyndrome, epsilonRegTab);

   for (aa=0; aa < (syndromeLength); aa++) {
      tempNum = 0;
      for (zz=0; zz < bitSymbol; zz++) {
         tempNum = tempNum + sumRegTab[aa*bitSymbol+zz] * powerTab[zz];
      }
//      fprintf(OutFileEmulator, "sumRegTab [%d] = %d \n", aa, tempNum);
   }

//   fprintf(OutFileEmulator, "POINt 6\n");


  //---------------------------------------------------------------
  // RS decode euclide emulator
  //---------------------------------------------------------------
//  RsDecodeEuclideEmulator(numShiftedReg, OmegaRegTab, LambdaRegTab, numErasure, DataSize, TotalSize, PrimPoly, bitSymbol, sumRegTab);
  RsDecodeEuclideEmulator(numShiftedReg, OmegaRegTab, LambdaRegTab, numErasureAdjusted, DataSize, TotalSize, PrimPoly, bitSymbol, sumRegTab);

   for(jj=0; jj < syndromeLength; jj++){
      tempNum = 0;
      for(kk=0; kk< bitSymbol; kk++){
         tempNum = tempNum + OmegaRegTab[jj*bitSymbol+kk] * powerTab[kk];
      }
   }
   for(jj=0; jj < syndromeLength; jj++){
      tempNum = 0;
      for(kk=0; kk< bitSymbol; kk++){
         tempNum = tempNum + LambdaRegTab[jj*bitSymbol+kk] * powerTab[kk];
      }
//      fprintf(OutFileEmulator, "LambdaRegTab [%d] = %d \n", aa, tempNum);
   }

//   fprintf(OutFileEmulator, "POINt 7\n");

  //---------------------------------------------------------------
  // RS decode shift omega emulator
  //---------------------------------------------------------------
  RsDecodeShiftOmegaEmulator(OmegaShiftedTab, OmegaRegTab, numShiftedReg, TotalSize, DataSize, bitSymbol);


   for(jj=0; jj < syndromeLength; jj++){
      tempNum = 0;
      for(kk=0; kk< bitSymbol; kk++){
         tempNum = tempNum + OmegaShiftedTab[jj*bitSymbol+kk] * powerTab[kk];
      }
//      fprintf(OutFileEmulator, "OmegaShiftedTab [%d] = %d \n", aa, tempNum);
   }

//   fprintf(OutFileEmulator, "POINt 8\n");

  //---------------------------------------------------------------
  // RS decode lambda degree emulator
  //---------------------------------------------------------------
  RsDecodeDegreeEmulator(DegreeLambda, LambdaRegTab, TotalSize, DataSize, bitSymbol);

//   fprintf(OutFileEmulator, "POINt 9\n");



  //---------------------------------------------------------------
  // RS decode omega degree emulator
  //---------------------------------------------------------------
  RsDecodeDegreeEmulator(DegreeOmega, OmegaShiftedTab, TotalSize, DataSize, bitSymbol);

//   fprintf(OutFileEmulator, "POINt 10\n");



  //---------------------------------------------------------------
  // RS decode chien emulator
  //---------------------------------------------------------------
  RsDecodeChienEmulator(numError, errorOutTab, DataSize, TotalSize, PrimPoly, bitSymbol, MrefTab, PrefTab, LambdaRegTab, OmegaShiftedTab, epsilonRegTab, ErasureInTab);

//   fprintf(OutFileEmulator, "POINt 11\n");

  //---------------------------------------------------------------
  // RS decode output generation
  //---------------------------------------------------------------
   for(jj=0; jj < TotalSize; jj++){
      tempix1 = DataInTab[jj];
      tempix2 = errorOutTab[jj];

      for (zz =bitSymbol-1; zz>=0;zz=zz-1) {
         if (tempix1 >= powerTab[zz]) {
            tempix1 = tempix1 - powerTab[zz];
            DataInBin [zz] = 1;
         }else{
            DataInBin [zz] = 0;
         }
      }
      
      for (zz =bitSymbol-1; zz>=0;zz=zz-1) {
         if (tempix2 >= powerTab[zz]) {
            tempix2 = tempix2 - powerTab[zz];
            errorOutBin [zz] = 1;
         }else{
            errorOutBin [zz] = 0;
         }
      }
      
      for(zz=0; zz < bitSymbol; zz++){
         dataOutBin[zz] = DataInBin[zz] ^ errorOutBin[zz];
      }


      //---------------------------------------------------------------
      // bin to dec
      //---------------------------------------------------------------
      tempNum = 0;
      for(kk=0; kk< bitSymbol; kk++){
         tempNum = tempNum + dataOutBin[kk] * powerTab[kk];
      }
      DataOutTab[jj] = tempNum;
      
   }

//   fprintf(OutFileEmulator, "POINt 12\n");

   //---------------------------------------------------------------
   // fail flag value calculation
   //---------------------------------------------------------------
   failFlag = 0;

   if (failErasure == 1){
      failFlag = 1;
   }

//   if (DegreeOmega [0] >= DegreeLambda[0] + numErasure){
   if (DegreeOmega [0] > DegreeLambda[0] + numErasure){
      failFlag = 1;
   }


   if ( DegreeLambda[0] != numError[0]){
      failFlag = 1;
   }


/*   fprintf(OutFileEmulator, "failErasure = %d \n\n", failErasure);
   fprintf(OutFileEmulator, "DegreeOmega = %d \n", DegreeOmega [0] );
   fprintf(OutFileEmulator, "DegreeLambda = %d \n", DegreeLambda[0] );
   fprintf(OutFileEmulator, "numErasure = %d \n\n", numErasure );
   fprintf(OutFileEmulator, "numError = %d \n", numError[0] );
*/

//   fprintf(OutFileEmulator, "POINt 13\n");

   //---------------------------------------------------------------
   // assign outputs
   //---------------------------------------------------------------
   for(kk=0; kk< bitSymbol; kk++){
      ErrorNum    [kk] = 0;
      ErasureNum  [kk] = 0;
      RTLfailFlag [kk] = 0;
   }


   ErrorNum    [0] = numError[0];
//   ErasureNum  [0] = numErasure;
   ErasureNum  [0] = numErasureAdjusted;
   RTLfailFlag [0] = failFlag;



   for(jj=0; jj < TotalSize; jj++){
      RTLDataOut[jj] = DataOutTab[jj];
   }
//   fprintf(OutFileEmulator, "POINt 14\n");

//   fclose(OutFileEmulator);
  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] powerTab;
   delete[] OmegaRegTab;
   delete[] LambdaRegTab;
   delete[] numShiftedReg;
   delete[] OmegaShiftedTab;
   delete[] DegreeLambda;
   delete[] DegreeOmega;
   delete[] numError;
   delete[] errorOutTab;
   delete[] DataInBin;
   delete[] errorOutBin;
   delete[] dataOutBin;
   delete[] DataOutTab;
   delete[] regSyndrome;
   delete[] epsilonRegTab;
   delete[] sumRegTab;
   delete[] numErasureBinary;

}
