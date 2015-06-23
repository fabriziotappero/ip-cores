//===================================================================
// Module Name : RsDecodeChien
// File Name   : RsDecodeChien.cpp
// Function    : RTL Decoder Chien Module generation
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
#include<windows.h>
#include<fstream>
#include <string.h>
using namespace std;

FILE  *OutFileDecodeChien;
void RsGfMultiplier( int*, int*,int*, int, int);

void RsDecodeChien(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int ErasureOption, int *MrefTab, int *PrefTab, int errorStats, int passFailFlag, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   syndromeLength = TotalSize - DataSize;

   int ii,jj,zz,kk;
   int MaxValue;
   int param1;
   int tempix;
   int tempo2;
   int index;
   int initValue;
   int Pidx;
   int init;
   int idx1;
   int idx2;
   int tempNum;
   int mmTabSize = (bitSymbol*2) -1;
   int indexSyndrome;
   int countSize;
   int lambdaPointer;
   int omegaPointer;
   int *coeffTab;
   int *initTab;
   int *x1Tab;
   int *x2Tab;
   int *ppTab;
   int *powerTab;
   int *bbTab;
   int *ttTab;
   int *bidon;
   char *strRsDecodeChien;

   MaxValue = 2;
   for(ii=0; ii<(bitSymbol-1); ii++){
      MaxValue = MaxValue*2;
   }

   coeffTab = new int[MaxValue];
   initTab  = new int[MaxValue];
   x1Tab    = new int[bitSymbol];
   x2Tab    = new int[bitSymbol];
   ppTab    = new int[bitSymbol];
   powerTab = new int[bitSymbol];
   bbTab    = new int[bitSymbol];
   ttTab    = new int[bitSymbol];
   bidon    = new int[bitSymbol];


   if (ErasureOption == 0){
      lambdaPointer = (syndromeLength/2)+1;
      omegaPointer  = (syndromeLength/2);
   }else{
      lambdaPointer = syndromeLength;
      omegaPointer  = syndromeLength;
   }



   //---------------------------------------------------------------
   //---------------------------------------------------------------
   countSize = 0;

   if (TotalSize > 2047) {
      countSize = 12;
   } else{
      if (TotalSize > 1023) {
         countSize = 11;
      } else{
         if (TotalSize > 511) {
            countSize = 10;
         }else{
            if (TotalSize > 255) {
               countSize = 9;
            }else{
               if (TotalSize > 127) {
                  countSize = 8;
               }else{
                  if (TotalSize > 63) {
                     countSize = 7;
                  }else{
                     if (TotalSize > 31) {
                        countSize = 6;
                     }else{
                        if (TotalSize > 15) {
                           countSize = 5;
                        }else{
                           if (TotalSize > 7) {
                              countSize = 4;
                           }else{
                              if (TotalSize > 3) {
                                 countSize = 3;
                              }else{
                                 countSize = 2;
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
   // calculate indexSyndrome
   //---------------------------------------------------------------
   if (syndromeLength > 2047) {
      indexSyndrome = 11;
   }
   else if (syndromeLength > 1023) {
      indexSyndrome = 10;
   }
   else if (syndromeLength > 511) {
      indexSyndrome = 9;
   }
   else if (syndromeLength > 255) {
      indexSyndrome = 8;
   }
   else if (syndromeLength > 127) {
      indexSyndrome = 7;
   }
   else if  (syndromeLength > 63) {
      indexSyndrome = 6;
   }
   else if  (syndromeLength > 31) {
      indexSyndrome = 5;
   }
   else if  (syndromeLength > 15) {
      indexSyndrome = 4;
   }
   else if  (syndromeLength > 7) {
      indexSyndrome = 3;
   }
   else if  (syndromeLength > 3) {
      indexSyndrome = 2;
   }
   else {
      indexSyndrome = 1;
   }


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeChien = (char *)calloc(lengthPath + 21,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeChien[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeChien[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeChien, "/rtl/RsDecodeChien.v");

   OutFileDecodeChien = fopen(strRsDecodeChien,"w");


   //---------------------------------------------------------------
   // write File Header
   //---------------------------------------------------------------
   fprintf(OutFileDecodeChien, "//===================================================================\n");
   fprintf(OutFileDecodeChien, "// Module Name : RsDecodeChien\n");
   fprintf(OutFileDecodeChien, "// File Name   : RsDecodeChien.v\n");
   fprintf(OutFileDecodeChien, "// Function    : Rs Decoder Chien search algorithm Module\n");
   fprintf(OutFileDecodeChien, "// \n");
   fprintf(OutFileDecodeChien, "// Revision History:\n");
   fprintf(OutFileDecodeChien, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDecodeChien, "//===================================================================\n");
   fprintf(OutFileDecodeChien, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDecodeChien, "//\n");
   fprintf(OutFileDecodeChien, "//===================================================================\n");
   fprintf(OutFileDecodeChien, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDecodeChien, "//\n\n\n");

   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDecodeChien, "module RsDecodeChien(\n");
   fprintf(OutFileDecodeChien, "   CLK,            // system clock\n");
   fprintf(OutFileDecodeChien, "   RESET,          // system reset\n");
   fprintf(OutFileDecodeChien, "   enable,         // enable signal\n");
   fprintf(OutFileDecodeChien, "   sync,           // sync signal\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   erasureIn,      // erasure input\n");
   }

//   for (ii=0; ii<syndromeLength;ii++){
   for (ii=0; ii<lambdaPointer;ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeChien, "   lambdaIn_%d,     // lambda polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileDecodeChien, "   lambdaIn_%d,    // lambda polynom %d\n", ii, ii);
      }
   }

//   for (ii=0 ; ii<syndromeLength;ii++){
   for (ii=0 ; ii<omegaPointer;ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeChien, "   omegaIn_%d,      // omega polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileDecodeChien, "   omegaIn_%d,     // omega polynom %d\n", ii, ii);
      }
   }

   if (ErasureOption == 1) {
      for (ii=0; ii<(syndromeLength+1);ii++){
         if (ii < 10) {
            fprintf(OutFileDecodeChien, "   epsilonIn_%d,    // epsilon polynom %d\n", ii, ii);
         }else{
            fprintf(OutFileDecodeChien, "   epsilonIn_%d,   // epsilon polynom %d\n", ii, ii);
         }
      }
   }

   fprintf(OutFileDecodeChien, "   errorOut,       // error output\n");
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileDecodeChien, "   numError,       // error amount\n");
   }
   fprintf(OutFileDecodeChien, "   done            // done signal\n");
   fprintf(OutFileDecodeChien, ");\n\n\n");


   //---------------------------------------------------------------
   // I/O instantiation
   //---------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   input          CLK;            // system clock\n");
   fprintf(OutFileDecodeChien, "   input          RESET;          // system reset\n");
   fprintf(OutFileDecodeChien, "   input          enable;         // enable signal\n");
   fprintf(OutFileDecodeChien, "   input          sync;           // sync signal\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   input          erasureIn;      // erasure input\n");
   }

//   for (ii=0;ii<(syndromeLength);ii++){
   for (ii=0;ii<(lambdaPointer);ii++){
      if (ii < 10){
         fprintf(OutFileDecodeChien, "   input  [%d:0]   lambdaIn_%d;     // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileDecodeChien, "   input  [%d:0]   lambdaIn_%d;    // lambda polynom %d\n", bitSymbol-1, ii, ii);
      }
   }

//   for (ii=0;ii<(syndromeLength);ii++){
   for (ii=0;ii<(omegaPointer);ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeChien, "   input  [%d:0]   omegaIn_%d;      // omega polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileDecodeChien, "   input  [%d:0]   omegaIn_%d;     // omega polynom %d\n", bitSymbol-1, ii, ii);
      }
   }
   fprintf(OutFileDecodeChien, "\n");

   if (ErasureOption == 1) {
      for (ii=0; ii<(syndromeLength+1);ii++){
         if (ii < 10) {
            fprintf(OutFileDecodeChien, "   input  [%d:0]   epsilonIn_%d;    // epsilon polynom %d\n", bitSymbol-1, ii, ii);
         }else{
            fprintf(OutFileDecodeChien, "   input  [%d:0]   epsilonIn_%d;   // epsilon polynom %d\n", bitSymbol-1, ii, ii);
         }
      }
   }
   fprintf(OutFileDecodeChien, "   output [%d:0]   errorOut;       // error output\n", bitSymbol-1);
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileDecodeChien, "   output [%d:0]   numError;       // error amount\n", indexSyndrome);
   }
   fprintf(OutFileDecodeChien, "   output         done;           // done signal\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   //- registers instantiation
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + \n");
   fprintf(OutFileDecodeChien, "   //- registers\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");

   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaSum;\n", bitSymbol-1);
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaSumReg;\n", bitSymbol-1);
   }
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaEven;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaEvenReg;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaEvenReg2;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaEvenReg3;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaOdd;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaOddReg;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaOddReg2;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaOddReg3;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   wire [%d:0]   denomE0;\n", bitSymbol-1);

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   wire [%d:0]   denomE1;\n", bitSymbol-1);
   }
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   denomE0Reg;\n", bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   denomE1Reg;\n", bitSymbol-1);
   }
   fprintf(OutFileDecodeChien, "   wire [%d:0]   denomE0Inv;\n", bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   wire [%d:0]   denomE1Inv;\n", bitSymbol-1);
   }
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   denomE0InvReg;\n", bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   denomE1InvReg;\n", bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, "   reg  [%d:0]   omegaSum;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   omegaSumReg;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   numeReg;\n", bitSymbol-1);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   numeReg2;\n", bitSymbol-1);

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   epsilonSum;\n", bitSymbol-1);
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   epsilonSumReg;\n", bitSymbol-1);
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   epsilonOdd;\n", bitSymbol-1);
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   epsilonOddReg;\n", bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, "   wire [%d:0]   errorValueE0;\n", bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   wire [%d:0]   errorValueE1;\n", bitSymbol-1);
   }

//   fprintf(OutFileDecodeChien, "   reg  [%d:0]   count;\n", bitSymbol);
   fprintf(OutFileDecodeChien, "   reg  [%d:0]   count;\n", countSize-1);
   fprintf(OutFileDecodeChien, "   reg          doneOrg;\n");
   fprintf(OutFileDecodeChien, "\n\n");


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
   //- powerTab initialize
   //------------------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
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


   fprintf(OutFileDecodeChien, "\n\n\n");



   //------------------------------------------------------------------
   // + count
   //------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + count\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
//   fprintf(OutFileDecodeChien, "         count [%d:0] <= %d'd0;\n", bitSymbol, bitSymbol+1);
   fprintf(OutFileDecodeChien, "         count [%d:0] <= %d'd0;\n", countSize-1, countSize);
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");

   fprintf(OutFileDecodeChien, "         if (sync == 1'b1) begin\n");
//   fprintf(OutFileDecodeChien, "            count[%d:0] <= %d'd1;\n", bitSymbol, bitSymbol+1);
   fprintf(OutFileDecodeChien, "            count[%d:0] <= %d'd1;\n", countSize-1, countSize);
   fprintf(OutFileDecodeChien, "         end\n");
//   fprintf(OutFileDecodeChien, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", bitSymbol, bitSymbol+1, bitSymbol, bitSymbol+1,TotalSize);
   fprintf(OutFileDecodeChien, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", countSize-1, countSize, countSize-1, countSize,TotalSize);
//   fprintf(OutFileDecodeChien, "            count[%d:0] <= %d'd0;\n", bitSymbol, bitSymbol+1);
   fprintf(OutFileDecodeChien, "            count[%d:0] <= %d'd0;\n", countSize-1, countSize);
   fprintf(OutFileDecodeChien, "         end\n");
   fprintf(OutFileDecodeChien, "         else begin\n");
//   fprintf(OutFileDecodeChien, "            count[%d:0] <= count[%d:0] + %d'd1;\n", bitSymbol, bitSymbol, bitSymbol+1);
   fprintf(OutFileDecodeChien, "            count[%d:0] <= count[%d:0] + %d'd1;\n", countSize-1, countSize-1, countSize);
   fprintf(OutFileDecodeChien, "         end\n");
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------
   // + doneOrg
   //------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + doneOrg\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   always @(count) begin\n");
   fprintf(OutFileDecodeChien, "      if (count[%d:0] == %d'd%d) begin\n", countSize-1, countSize, TotalSize);
   fprintf(OutFileDecodeChien, "         doneOrg   = 1'b1;\n");
   fprintf(OutFileDecodeChien, "      end else begin\n");
   fprintf(OutFileDecodeChien, "         doneOrg   = 1'b0;\n");
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n");
   fprintf(OutFileDecodeChien, "   assign   done   = doneOrg;\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   //- LAMBDA_INI = CHIEN_COEFF_LI * LAMBDA_IN
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- lambdaIni\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      fprintf(OutFileDecodeChien, "   wire [%d:0]   lambdaIni_%d;\n",bitSymbol-1,ii);
   }
   fprintf(OutFileDecodeChien, "\n\n");




//   for (zz=0;zz<syndromeLength;zz++){
   for (zz=0;zz<lambdaPointer;zz++){
      //------------------------------------------------------------------------
      //- mult Coeff Emulator
      //------------------------------------------------------------------------
      if (coeffTab[zz] ==0) {
         for (ii=0;ii<bitSymbol;ii++){
            fprintf(OutFileDecodeChien, "   assign lambdaIni_%d [%d] = lambdaIn_%d[%d];\n", zz, ii, zz, ii);
         }
      }else{

         //------------------------------------------------------------------------
         // initialize ttTab
         //------------------------------------------------------------------------
         ttTab[0] = 1;
         for (ii=1;ii<bitSymbol;ii++){
            ttTab[ii] = 0;
         }


         //------------------------------------------------------------------------
         // initialize bbTab
         //------------------------------------------------------------------------
         bbTab[0] = 0;
         bbTab[1] = 1;
         for (ii=2;ii<bitSymbol;ii++){
            bbTab[ii] = 0;
         }


         for(ii=1; ii<(coeffTab[zz]+1); ii++){

            //------------------------------------------------------------------------
            //- ppTab = ttTab * bbTab
            //------------------------------------------------------------------------
            RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

            //------------------------------------------------------------------------
            //- reassign ttTab
            //------------------------------------------------------------------------
            for (kk=0;kk<bitSymbol;kk++){
               ttTab[kk]	= ppTab[kk];
            }

            //------------------------------------------------------------------------
            // write P_OUT[0]
            //------------------------------------------------------------------------
            if (ii==coeffTab[zz]) {
               for (Pidx=0; Pidx<bitSymbol; Pidx++){
                  fprintf(OutFileDecodeChien, "   assign lambdaIni_%d [%d] =", zz,Pidx);
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
                        if (init == 0) {
                           fprintf(OutFileDecodeChien, " lambdaIn_%d[%d]", zz,idx2);
                           init = 1;
                        }
                        else {
                           fprintf(OutFileDecodeChien, " ^ lambdaIn_%d[%d]", zz,idx2);
                        }
                     }
                  }
                  fprintf(OutFileDecodeChien, ";\n");
               }
            }
         }
      }
   }
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   //- LAMBDA_NEW = CHIEN_COEFF_LN * LAMBDA_REG
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- lambdaNew\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      fprintf(OutFileDecodeChien, "   reg  [%d:0]   lambdaReg_%d;\n",bitSymbol-1, ii);
   }


//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      fprintf(OutFileDecodeChien, "   wire [%d:0]   lambdaUp_%d;\n",bitSymbol-1,ii);
   }
   fprintf(OutFileDecodeChien, "\n\n");


//   for (zz=0;zz<syndromeLength;zz++){
   for (zz=0;zz<lambdaPointer;zz++){
      if (zz ==0) {
         for (kk=0;kk<bitSymbol;kk++){
            fprintf(OutFileDecodeChien, "   assign lambdaUp_%d [%d] = lambdaReg_%d[%d];\n", zz, kk, zz, kk);
         }
      }else{
         //------------------------------------------------------------------------
         //- ttTab initialize
         //------------------------------------------------------------------------
         ttTab[0] = 1;
         for (kk=1;kk<bitSymbol;kk++){
            ttTab[kk] = 0;
         }


         //------------------------------------------------------------------------
         //- bbTab initialize
         //------------------------------------------------------------------------
         bbTab[0] = 0;
         bbTab[1] = 1;
         for (kk=2;kk<bitSymbol;kk++){
            bbTab[kk] = 0;
         }


         for(ii=1; ii<(zz+1); ii++){
            //------------------------------------------------------------------------
            //- ppTab = ttTab * bbTab
            //------------------------------------------------------------------------
            RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

            //------------------------------------------------------------------------
            // reassign ttTab
            //------------------------------------------------------------------------
            for (kk=0;kk<bitSymbol;kk++){
               ttTab[kk]	= ppTab[kk];
            }

            //------------------------------------------------------------------------
            // write P_OUT[0]
            //------------------------------------------------------------------------
            if (ii==zz) {
               for (Pidx=0; Pidx<bitSymbol; Pidx++){
                  fprintf(OutFileDecodeChien, "   assign lambdaUp_%d [%d] =", zz,Pidx);
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
                        if (init == 0) {
                           fprintf(OutFileDecodeChien, " lambdaReg_%d[%d]", zz,idx2);
                           init = 1;
                        }
                        else {
                           fprintf(OutFileDecodeChien, " ^ lambdaReg_%d[%d]", zz,idx2);
                        }
                     }
                  }
                  fprintf(OutFileDecodeChien, ";\n");
               }
            }
         }
      }
   }
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   // + lambdaReg_0,...,lambdaReg_
   //- registers
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + lambdaReg_0,...,lambdaReg_%d\n", lambdaPointer-1);
   fprintf(OutFileDecodeChien, "   //- registers\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      if (ii < 10){
         fprintf(OutFileDecodeChien, "         lambdaReg_%d [%d:0]  <= %d'd0;\n",ii, bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileDecodeChien, "         lambdaReg_%d [%d:0] <=  %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }
   }

   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeChien, "         if (sync == 1'b1) begin\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      if (ii < 10){
         fprintf(OutFileDecodeChien, "            lambdaReg_%d [%d:0]  <= lambdaIni_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }else{
         fprintf(OutFileDecodeChien, "            lambdaReg_%d [%d:0] <= lambdaIni_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeChien, "        end\n");
   fprintf(OutFileDecodeChien, "        else begin\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<lambdaPointer;ii++){
      if (ii < 10){
         fprintf(OutFileDecodeChien, "           lambdaReg_%d [%d:0]  <= lambdaUp_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }else{
         fprintf(OutFileDecodeChien, "           lambdaReg_%d [%d:0] <= lambdaUp_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeChien, "         end\n");
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");



   //------------------------------------------------------------------------
   //- OMEGA_INI = CHIEN_COEFF_OI * OMEGA_IN
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- omegaIni\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      fprintf(OutFileDecodeChien, "   wire [%d:0]  omegaIni_%d;\n",bitSymbol-1,ii);
   }
   fprintf(OutFileDecodeChien, "\n\n");   

//   for (zz=0;zz<syndromeLength;zz++){
   for (zz=0;zz<omegaPointer;zz++){
      if (coeffTab[zz] ==0) {
         for (kk=0;kk<bitSymbol;kk++){
            fprintf(OutFileDecodeChien, "   assign omegaIni_%d [%d] = omegaIn_%d[%d];\n", zz, kk,zz, kk);
         }
      }else{
         //------------------------------------------------------------------------
         //- ttTab initialize
         //------------------------------------------------------------------------
         ttTab[0] = 1;
         for (kk=1;kk<bitSymbol;kk++){
            ttTab[kk] = 0;
         }

         //------------------------------------------------------------------------
         //- bbTab initialize
         //------------------------------------------------------------------------
         bbTab[0] = 0;
         bbTab[1] = 1;
         for (kk=2;kk<bitSymbol;kk++){
            bbTab[kk] = 0;
         }

         //------------------------------------------------------------------------
         //------------------------------------------------------------------------
         for(ii=1; ii<(coeffTab[zz]+1); ii++){

            //------------------------------------------------------------------------
            //- ppTab = ttTab * bbTab
            //------------------------------------------------------------------------
            RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

            //------------------------------------------------------------------------
            // reassign ttTab
            //------------------------------------------------------------------------
            for (kk=0;kk<bitSymbol;kk++){
               ttTab[kk]	= ppTab[kk];
            }


            //------------------------------------------------------------------------
            // write P_OUT[0]
            //------------------------------------------------------------------------
            if (ii==coeffTab[zz]) {
               for (Pidx=0; Pidx<bitSymbol; Pidx++){
                  fprintf(OutFileDecodeChien, "   assign omegaIni_%d [%d] =", zz,Pidx);
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
                        if (init == 0) {
                           fprintf(OutFileDecodeChien, " omegaIn_%d[%d]", zz,idx2);
                           init = 1;
                        }
                        else {
                           fprintf(OutFileDecodeChien, " ^ omegaIn_%d[%d]", zz,idx2);
                        }
                     }
                  }
                  fprintf(OutFileDecodeChien, ";\n");
               }
            }
         }
      }
   }
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   //- OMEGA_NEW = CHIEN_COEFF_ON * OMEGA_REG
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- omegaNew\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      fprintf(OutFileDecodeChien, "   reg [%d:0]  omegaReg_%d;\n", bitSymbol -1,ii);
   }
//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      fprintf(OutFileDecodeChien, "   wire [%d:0]  omegaNew_%d;\n", bitSymbol -1,ii);
   }
   fprintf(OutFileDecodeChien, "\n\n");   
//   for (zz=0;zz<syndromeLength;zz++){
   for (zz=0;zz<omegaPointer;zz++){
      if (zz ==0) {
         for (kk=0;kk<bitSymbol;kk++){
            fprintf(OutFileDecodeChien, "   assign omegaNew_%d [%d] = omegaReg_%d[%d];\n", zz, kk, zz, kk);
         }
      }else{
         //------------------------------------------------------------------------
         // initialize ttTab
         //------------------------------------------------------------------------
         ttTab[0] = 1;
         for (kk=1;kk<bitSymbol;kk++){
            ttTab[kk] = 0;
         }

         //------------------------------------------------------------------------
         // initialize bbTab
         //------------------------------------------------------------------------
         bbTab[0] = 0;
         bbTab[1] = 1;
         for (kk=2;kk<bitSymbol;kk++){
            bbTab[kk] = 0;
         }


         //------------------------------------------------------------------------
         //------------------------------------------------------------------------
         for(ii=1; ii<(zz+1); ii++){

            //------------------------------------------------------------------------
            //- ppTab = ttTab * bbTab
            //------------------------------------------------------------------------
            RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

            //------------------------------------------------------------------------
            //- reassign ttTab
            //------------------------------------------------------------------------
            for (kk=0;kk<bitSymbol;kk++){
               ttTab[kk]	= ppTab[kk];
            }


            //------------------------------------------------------------------------
            // write P_OUT[0]
            //------------------------------------------------------------------------
            if (ii==zz) {
               for (Pidx=0; Pidx<bitSymbol; Pidx++){
                  fprintf(OutFileDecodeChien, "   assign omegaNew_%d [%d] =", zz,Pidx);
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
                        if (init == 0) {
                           fprintf(OutFileDecodeChien, " omegaReg_%d[%d]", zz,idx2);
                           init = 1;
                        }
                        else {
                           fprintf(OutFileDecodeChien, " ^ omegaReg_%d[%d]", zz,idx2);
                        }
                     }
                  }
                  fprintf(OutFileDecodeChien, ";\n");
               }
            }
         }
      }
   }
   fprintf(OutFileDecodeChien, "\n\n\n");



   //------------------------------------------------------------------
   // + omegaReg_0,..., omegaReg_19
   //- registers
   //------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + omegaReg_0,..., omegaReg_%d\n", omegaPointer-1);
   fprintf(OutFileDecodeChien, "   //- registers\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeChien, "         omegaReg_%d [%d:0]  <= %d'd0;\n",ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileDecodeChien, "         omegaReg_%d [%d:0] <= %d'd0;\n",ii, bitSymbol-1, bitSymbol);
      }
   }

   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeChien, "         if (sync == 1'b1) begin\n");


//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeChien, "            omegaReg_%d [%d:0]  <= omegaIni_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
      }else{
         fprintf(OutFileDecodeChien, "            omegaReg_%d [%d:0] <= omegaIni_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeChien, "         end\n");
   fprintf(OutFileDecodeChien, "         else begin\n");

//   for (ii=0;ii<syndromeLength;ii++){
   for (ii=0;ii<omegaPointer;ii++){
      if (ii < 10){
         fprintf(OutFileDecodeChien, "            omegaReg_%d [%d:0]  <= omegaNew_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
      }else{
         fprintf(OutFileDecodeChien, "            omegaReg_%d [%d:0] <= omegaNew_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
      }
   }
   fprintf(OutFileDecodeChien, "         end\n");
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   //- EPSILON_INI = CHIEN_COEFF_EI * EPSILON_IN
   //------------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   //- epsilonIni\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      for (ii=0;ii<(syndromeLength+1);ii++){
         fprintf(OutFileDecodeChien, "   wire [%d:0]  epsilonIni_%d;\n", bitSymbol-1,ii);
      }
      fprintf(OutFileDecodeChien, "\n\n");
      for (zz=0;zz<(syndromeLength+1);zz++){
         if (coeffTab[zz] ==0) {
            for (kk=0;kk<bitSymbol;kk++){
               fprintf(OutFileDecodeChien, "   assign epsilonIni_%d [%d] = epsilonIn_%d[%d];\n", zz, kk, zz, kk);
            }
         }else{
            //------------------------------------------------------------------------
            //- initialize ttTab
            //------------------------------------------------------------------------
            ttTab[0] = 1;
            for (kk=1;kk<bitSymbol;kk++){
               ttTab[kk] = 0;
            }


            //------------------------------------------------------------------------
            //- initialize bbTab
            //------------------------------------------------------------------------
            bbTab[0] = 0;
            bbTab[1] = 1;
            for (kk=2;kk<bitSymbol;kk++){
               bbTab[kk] = 0;
            }


            //------------------------------------------------------------------------
            //------------------------------------------------------------------------
            for(ii=1; ii<(coeffTab[zz]+1); ii++){
               //------------------------------------------------------------------------
               //- ppTab = ttTab * bbTab
               //------------------------------------------------------------------------
               RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);


               //------------------------------------------------------------------------
               // reassign ttTab = ppTab
               //------------------------------------------------------------------------
               for (kk=0;kk<bitSymbol;kk++){
                  ttTab[kk]	= ppTab[kk];
               }


               //------------------------------------------------------------------------
               // write P_OUT[0]
               //------------------------------------------------------------------------
               if (ii==coeffTab[zz]) {
                  for (Pidx=0; Pidx<bitSymbol; Pidx++){
                     fprintf(OutFileDecodeChien, "   assign epsilonIni_%d [%d] =", zz,Pidx);
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
                                 }else{
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
                           if (init == 0) {
                              fprintf(OutFileDecodeChien, " epsilonIn_%d[%d]", zz,idx2);
                              init = 1;
                           }else{
                              fprintf(OutFileDecodeChien, " ^ epsilonIn_%d[%d]", zz,idx2);
                           }
                        }
                     }
                     fprintf(OutFileDecodeChien, ";\n");
                  }
               }
            }
         }
      }
      fprintf(OutFileDecodeChien, "\n\n\n");
   }


   //------------------------------------------------------------------------
   //- EPSILON_NEW = CHIEN_COEFF_EN * EPSILON_REG
   //------------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   //- epsilonNew\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      for (ii=0; ii<(syndromeLength+1);ii++){
        fprintf(OutFileDecodeChien, "   reg  [%d:0]  epsilonReg_%d;\n", bitSymbol-1,ii);
      }
      for (ii=0;ii<(syndromeLength+1);ii++){
         fprintf(OutFileDecodeChien, "   wire [%d:0]  epsilonNew_%d;\n", bitSymbol-1, ii);
      }
      fprintf(OutFileDecodeChien, "\n\n");
      for (zz=0;zz<(syndromeLength+1);zz++){
         if (zz ==0) {
            for (kk=0;kk<bitSymbol;kk++){
               fprintf(OutFileDecodeChien, "   assign epsilonNew_%d [%d] = epsilonReg_%d[%d];\n", zz, kk, zz, kk);
            }
         }else{
            //------------------------------------------------------------------------
            // initialize ttTab
            //------------------------------------------------------------------------
            ttTab[0] = 1;
            for (kk=1;kk<bitSymbol;kk++){
               ttTab[kk] = 0;
            }

            //------------------------------------------------------------------------
            // initialize bbTab
            //------------------------------------------------------------------------
            bbTab[0] = 0;
            bbTab[1] = 1;
            for (kk=2;kk<bitSymbol;kk++){
               bbTab[kk] = 0;
            }

            //------------------------------------------------------------------------
            //------------------------------------------------------------------------
            for(ii=1; ii<(zz+1); ii++){
               
               //------------------------------------------------------------------------
               //- ppTab = ttTab * bbTab
               //------------------------------------------------------------------------
               RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);

               //------------------------------------------------------------------------
               // reassign ttTab
               //------------------------------------------------------------------------
               for (kk=0;kk<bitSymbol;kk++){
                  ttTab[kk]	= ppTab[kk];
               }


               //------------------------------------------------------------------------
               // write P_OUT[0]
               //------------------------------------------------------------------------
               if (ii==zz) {
                  for (Pidx=0; Pidx<bitSymbol; Pidx++){
                     fprintf(OutFileDecodeChien, "   assign epsilonNew_%d [%d] =", zz,Pidx);
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
                                 }else{
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
                           if (init == 0) {
                              fprintf(OutFileDecodeChien, " epsilonReg_%d[%d]", zz,idx2);
                              init = 1;
                           }else{
                              fprintf(OutFileDecodeChien, " ^ epsilonReg_%d[%d]", zz,idx2);
                           }
                        }
                     }
                     fprintf(OutFileDecodeChien, ";\n");
                  }
               }
            }
         }
      }
      fprintf(OutFileDecodeChien, "\n\n\n");
   }


   //------------------------------------------------------------------
   // + epsilonReg_0,..., epsilonReg_20
   //- registers
   //------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   // + epsilonReg_0,..., epsilonReg_%d\n", syndromeLength);
      fprintf(OutFileDecodeChien, "   //- registers\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
      for (ii=0;ii<(syndromeLength+1);ii++){
         if (ii<10){
            fprintf(OutFileDecodeChien, "         epsilonReg_%d [%d:0]  <= %d'd0;\n",ii, bitSymbol-1,bitSymbol);
         }else{
            fprintf(OutFileDecodeChien, "         epsilonReg_%d [%d:0] <= %d'd0;\n",ii, bitSymbol-1,bitSymbol);
         }
      }

      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileDecodeChien, "         if (sync == 1'b1) begin\n");
      for (ii=0;ii<(syndromeLength+1);ii++){
         if (ii<10){
            fprintf(OutFileDecodeChien, "            epsilonReg_%d [%d:0]  <= epsilonIni_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
         }else{
            fprintf(OutFileDecodeChien, "            epsilonReg_%d [%d:0] <= epsilonIni_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
         }
      }

      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "         else begin\n");

      for (ii=0;ii<(syndromeLength+1);ii++){
         if (ii<10) {
            fprintf(OutFileDecodeChien, "            epsilonReg_%d [%d:0]  <= epsilonNew_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
         }else{
            fprintf(OutFileDecodeChien, "            epsilonReg_%d [%d:0] <= epsilonNew_%d [%d:0];\n",ii, bitSymbol-1,ii, bitSymbol-1);
         }
      }

      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "   end\n");
      fprintf(OutFileDecodeChien, "\n\n\n");
   }


   //------------------------------------------------------------------------
   // Generate Error Pattern: Lambda
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // Generate Error Pattern: Lambda\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");

   fprintf(OutFileDecodeChien, "   always @( lambdaReg_0");

//   for (ii=1;ii<syndromeLength;ii++){
   for (ii=1;ii<lambdaPointer;ii++){
      fprintf(OutFileDecodeChien, "   or lambdaReg_%d", ii);
   }
   fprintf(OutFileDecodeChien, " ) begin\n");

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "      lambdaSum [%d:0] = lambdaReg_0[%d:0]", bitSymbol-1, bitSymbol-1);
      for (ii=1;ii<syndromeLength;ii++){
         fprintf(OutFileDecodeChien, "   ^ lambdaReg_%d[%d:0]",ii, bitSymbol-1);
      }
      fprintf(OutFileDecodeChien, ";\n");
   }


   fprintf(OutFileDecodeChien, "      lambdaEven [%d:0] = lambdaReg_0[%d:0]", bitSymbol-1, bitSymbol-1);
//   for (ii=2;ii<(syndromeLength-1);ii=ii+2){

   if (ErasureOption == 1){
      for (ii=2;ii<(syndromeLength-1);ii=ii+2){
         fprintf(OutFileDecodeChien, "   ^ lambdaReg_%d[%d:0]",ii, bitSymbol-1);
      }
   }else{
      for (ii=2;ii<(lambdaPointer+1);ii=ii+2){
         if (ii < lambdaPointer) {
            fprintf(OutFileDecodeChien, "   ^ lambdaReg_%d[%d:0]",ii, bitSymbol-1);
         }
      }
   }



   fprintf(OutFileDecodeChien, ";\n");


   fprintf(OutFileDecodeChien, "      lambdaOdd [%d:0] =  lambdaReg_1[%d:0]", bitSymbol-1, bitSymbol-1);
//   for (ii=3;ii<(syndromeLength);ii=ii+2){
   for (ii=3;ii<(lambdaPointer);ii=ii+2){
      fprintf(OutFileDecodeChien, "   ^ lambdaReg_%d[%d:0]",ii, bitSymbol-1);
   }
   fprintf(OutFileDecodeChien, ";\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");   


   //------------------------------------------------------------------------
   // Generate Error Pattern: Omega
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // Generate Error Pattern: Omega\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");

   fprintf(OutFileDecodeChien, "   always @( omegaReg_0");
//   for (ii=1;ii<syndromeLength;ii++){
   for (ii=1;ii<omegaPointer;ii++){
      fprintf(OutFileDecodeChien, "   or omegaReg_%d", ii);
   }

   fprintf(OutFileDecodeChien, " ) begin\n");
   fprintf(OutFileDecodeChien, "      omegaSum [%d:0] = omegaReg_0[%d:0]", bitSymbol-1, bitSymbol-1);

//   for (ii=1;ii<syndromeLength;ii++){
   for (ii=1;ii<omegaPointer;ii++){
      fprintf(OutFileDecodeChien, "   ^ omegaReg_%d[%d:0]", ii, bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, ";\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   // Generate Error Pattern: Epsilon
   //------------------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   //- Generate Error Pattern: Epsilon\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   always @( epsilonReg_0");
      for (ii=1;ii<(syndromeLength+1);ii++){
         fprintf(OutFileDecodeChien, "   or epsilonReg_%d", ii);
      }
      fprintf(OutFileDecodeChien, " ) begin\n");
      fprintf(OutFileDecodeChien, "      epsilonSum [%d:0] = epsilonReg_0[%d:0]", bitSymbol-1, bitSymbol-1);
      for (ii=1;ii<(syndromeLength+1);ii++){
         fprintf(OutFileDecodeChien, "   ^ epsilonReg_%d[%d:0]", ii, bitSymbol-1);
      }
      fprintf(OutFileDecodeChien, ";\n");
      fprintf(OutFileDecodeChien, "      epsilonOdd [%d:0] =  epsilonReg_1[%d:0]", bitSymbol-1, bitSymbol-1);
      for (ii=3;ii<syndromeLength;ii=ii+2){
         fprintf(OutFileDecodeChien, "   ^ epsilonReg_%d[%d:0]",ii, bitSymbol-1);
      }
      fprintf(OutFileDecodeChien, ";\n");
      fprintf(OutFileDecodeChien, "   end\n");
      fprintf(OutFileDecodeChien, "\n\n\n");   
   }


   //------------------------------------------------------------------------
   // RsDecodeMult instantiation
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- RsDecodeMult instantiation, RsDecodeMult_MuldE0 && RsDecodeMult_MuldE1\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   RsDecodeMult RsDecodeMult_MuldE0 (.A(lambdaOddReg[%d:0]), .B(epsilonSumReg[%d:0]), .P(denomE0[%d:0]));\n", bitSymbol-1, bitSymbol-1, bitSymbol-1);
   }else{
      fprintf(OutFileDecodeChien, "   assign denomE0[%d:0] = lambdaOddReg[%d:0];\n", bitSymbol-1, bitSymbol-1);
   }

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   RsDecodeMult RsDecodeMult_MuldE1 (.A(lambdaSumReg[%d:0]), .B(epsilonOddReg[%d:0]), .P(denomE1[%d:0]));\n", bitSymbol-1, bitSymbol-1, bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, "\n\n");


   //------------------------------------------------------------------------
   // RsDecodeInv instantiation
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- RsDecodeInv instantiation, RsDecodeInv_InvE0 && RsDecodeInv_InvE1\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   RsDecodeInv RsDecodeInv_InvE0 (.B(denomE0Reg[%d:0]), .R(denomE0Inv[%d:0]));\n", bitSymbol-1, bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   RsDecodeInv RsDecodeInv_InvE1 (.B(denomE1Reg[%d:0]), .R(denomE1Inv[%d:0]));\n", bitSymbol-1, bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, "\n\n");


   //------------------------------------------------------------------------
   // RsDecodeMult instantiation
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- RsDecodeMult instantiation, RsDecodeMult_MulE0 && RsDecodeMult_MulE1 \n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   RsDecodeMult RsDecodeMult_MulE0 (.A(numeReg2[%d:0]), .B(denomE0InvReg[%d:0]), .P(errorValueE0[%d:0]));\n", bitSymbol-1, bitSymbol-1, bitSymbol-1);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   RsDecodeMult RsDecodeMult_MulE1 (.A(numeReg2[%d:0]), .B(denomE1InvReg[%d:0]), .P(errorValueE1[%d:0]));\n", bitSymbol-1, bitSymbol-1, bitSymbol-1);
   }

   fprintf(OutFileDecodeChien, "\n\n\n\n");


   //------------------------------------------------------------------------
   // registers
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   // + lambdaSumReg, denomE1Reg, denomE1InvReg, epsilonSumReg, epsilonOddReg\n");
   }
   fprintf(OutFileDecodeChien, "   // + lambdaEvenReg, lambdaEvenReg2, lambdaEvenReg3, lambdaOddReg, lambdaOddReg2, lambdaOddReg3, denomE0Reg, denomE0InvReg\n");
   fprintf(OutFileDecodeChien, "   // + omegaSumReg, numeReg, numeReg2\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         lambdaSumReg   [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   }

   fprintf(OutFileDecodeChien, "         lambdaEvenReg  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         lambdaEvenReg2 [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         lambdaEvenReg3 [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         lambdaOddReg   [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         lambdaOddReg2  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         lambdaOddReg3  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         denomE0Reg     [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         denomE1Reg     [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   }
   fprintf(OutFileDecodeChien, "         denomE0InvReg  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         denomE1InvReg  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   }
   fprintf(OutFileDecodeChien, "         omegaSumReg    [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         numeReg        [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeChien, "         numeReg2       [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         epsilonSumReg  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
      fprintf(OutFileDecodeChien, "         epsilonOddReg  [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   }

   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         lambdaSumReg   <= lambdaSum;\n");
   }

   fprintf(OutFileDecodeChien, "         lambdaEvenReg3 <= lambdaEvenReg2;\n");
   fprintf(OutFileDecodeChien, "         lambdaEvenReg2 <= lambdaEvenReg;\n");
   fprintf(OutFileDecodeChien, "         lambdaEvenReg  <= lambdaEven;\n");
   fprintf(OutFileDecodeChien, "         lambdaOddReg3  <= lambdaOddReg2;\n");
   fprintf(OutFileDecodeChien, "         lambdaOddReg2  <= lambdaOddReg;\n");
   fprintf(OutFileDecodeChien, "         lambdaOddReg   <= lambdaOdd;\n");
   fprintf(OutFileDecodeChien, "         denomE0Reg     <= denomE0;\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         denomE1Reg     <= denomE1;\n");
   }

   fprintf(OutFileDecodeChien, "         denomE0InvReg  <= denomE0Inv;\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         denomE1InvReg  <= denomE1Inv;\n");
   }

   fprintf(OutFileDecodeChien, "         numeReg2       <= numeReg;\n");
   fprintf(OutFileDecodeChien, "         numeReg        <= omegaSumReg;\n");
   fprintf(OutFileDecodeChien, "         omegaSumReg    <= omegaSum;\n");
   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "         epsilonSumReg  <= epsilonSum;\n");
      fprintf(OutFileDecodeChien, "         epsilonOddReg  <= epsilonOdd;\n");
   }
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------
   // + errorOut
   //- 
   //------------------------------------------------------------------
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   // + errorOut\n");
   fprintf(OutFileDecodeChien, "   //- \n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   reg   [%d:0]  errorOut;\n", bitSymbol-1);

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "   always @(erasureIn or lambdaEvenReg3 or lambdaOddReg3 or errorValueE0 or errorValueE1) begin\n");
   }else{
      fprintf(OutFileDecodeChien, "   always @(lambdaEvenReg3 or lambdaOddReg3 or errorValueE0) begin\n");
   }

   if (ErasureOption == 1){
      fprintf(OutFileDecodeChien, "      if (erasureIn == 1'b1) begin\n");
      fprintf(OutFileDecodeChien, "         errorOut = errorValueE1;\n");
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "      else if (lambdaEvenReg3 == lambdaOddReg3) begin\n");
      fprintf(OutFileDecodeChien, "         errorOut = errorValueE0;\n");
      fprintf(OutFileDecodeChien, "      end\n");
   }else{
      fprintf(OutFileDecodeChien, "      if (lambdaEvenReg3 == lambdaOddReg3) begin\n");
      fprintf(OutFileDecodeChien, "         errorOut = errorValueE0;\n");
      fprintf(OutFileDecodeChien, "      end\n");
   }

   fprintf(OutFileDecodeChien, "      else begin\n");
   fprintf(OutFileDecodeChien, "         errorOut = %d'd0;\n", bitSymbol);
   fprintf(OutFileDecodeChien, "      end\n");
   fprintf(OutFileDecodeChien, "   end\n");
   fprintf(OutFileDecodeChien, "\n\n\n");


   //------------------------------------------------------------------------
   // + numErrorReg
   //- Count Error
   //------------------------------------------------------------------------
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   // + numErrorReg\n");
      fprintf(OutFileDecodeChien, "   //- Count Error\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   reg    [%d:0]   numErrorReg;\n", indexSyndrome);
      fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
      fprintf(OutFileDecodeChien, "         numErrorReg [%d:0]   <= %d'd0;\n", indexSyndrome, indexSyndrome+1);
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "      else if (enable == 1'b1) begin\n");
      fprintf(OutFileDecodeChien, "         if (sync == 1'b1) begin\n");
      fprintf(OutFileDecodeChien, "            numErrorReg <= %d'd0;\n", indexSyndrome+1);
      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "         else if (lambdaEven == lambdaOdd) begin\n");
      fprintf(OutFileDecodeChien, "            numErrorReg <= numErrorReg + %d'd1;\n", indexSyndrome+1);
      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "   end\n");
      fprintf(OutFileDecodeChien, "\n\n\n");
   }

   //------------------------------------------------------------------
   // + numErrorReg2
   //------------------------------------------------------------------
   if ((errorStats!=0) || (passFailFlag!=0)) {
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   // + numErrorReg2\n");
      fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------\n");
      fprintf(OutFileDecodeChien, "   reg    [%d:0]   numErrorReg2;\n", indexSyndrome);
      fprintf(OutFileDecodeChien, "   always @(posedge CLK or negedge RESET) begin\n");
      fprintf(OutFileDecodeChien, "      if (~RESET) begin\n");
      fprintf(OutFileDecodeChien, "         numErrorReg2 <=  %d'd0;\n", indexSyndrome+1);
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "      else if ((enable == 1'b1) && (doneOrg == 1'b1)) begin\n");
      fprintf(OutFileDecodeChien, "         if (lambdaEven == lambdaOdd) begin\n");
      fprintf(OutFileDecodeChien, "            numErrorReg2 <= numErrorReg + %d'd1;\n", indexSyndrome+1);
      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "         else begin\n");
      fprintf(OutFileDecodeChien, "            numErrorReg2 <= numErrorReg;\n");
      fprintf(OutFileDecodeChien, "         end\n");
      fprintf(OutFileDecodeChien, "      end\n");
      fprintf(OutFileDecodeChien, "   end\n");
   }

   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   if ((errorStats!=0) || (passFailFlag!=0)) {
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   //- Output Ports\n");
   fprintf(OutFileDecodeChien, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeChien, "   assign   numError = numErrorReg2;\n");
   }
   
   fprintf(OutFileDecodeChien, "\n\n");
   fprintf(OutFileDecodeChien, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileDecodeChien);


  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] coeffTab;
   delete[] initTab;
   delete[] x1Tab;
   delete[] x2Tab;
   delete[] ppTab;
   delete[] powerTab;
   delete[] bbTab;
   delete[] ttTab;
   delete[] bidon;


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeChien, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeChien);
	//Create a temporary file for writing in the binary mode. This
	//file will be created in the same directory as the input file.
	ofstream fp_write(temp, ios_base::out | ios_base::trunc | ios_base::binary);

	while(fp_read.eof() != true)
	{
		fp_read.get(ch);
		//Check for CR (carriage return)
		if((int)ch == 0x0D)
			continue;
		if (!fp_read.eof())fp_write.put(ch);
	}

	fp_read.close();
	fp_write.close();
	//Delete the existing input file.
	remove(strRsDecodeChien);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeChien);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeChien);


}
