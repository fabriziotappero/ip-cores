//===================================================================
// Module Name : RsDecodeErasure
// File Name   : RsDecodeErasure.cpp
// Function    : RTL Decoder Erasure polynomial Module generation
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

FILE  *OutFileDecodeErasure;

void RsGfMultiplier( int*, int*,int*, int, int);

void RsDecodeErasure(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int passFailFlag, int ErasureOption, int *MrefTab, int *PrefTab, int *coeffTab, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   int MaxValue;
   int initValue;
   int Pidx;
   int init;
   int idx1;
   int idx2;
   int countSize;
   int mmTabSize = (bitSymbol*2) -1;
   int tempNum;
   int *bbTab;
   int *ppTab;
   int *ttTab;
   int *powerTab;
   int *bidon;
   char *strRsDecodeErasure;

   bbTab    =new int[bitSymbol];
   ppTab    =new int[bitSymbol];
   ttTab    =new int[bitSymbol];
   powerTab =new int[bitSymbol];
   bidon    =new int[bitSymbol];

   //---------------------------------------------------------------
   // syndrome Length calculation
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;


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
   // MaxValue calculation
   //---------------------------------------------------------------
   MaxValue = 2;
   for(ii=0; ii<(bitSymbol-1); ii++){
      MaxValue = MaxValue*2;
   }

   int param1 = MaxValue - TotalSize;


   //---------------------------------------------------------------
   // powerTab calculation
   //---------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeErasure = (char *)calloc(lengthPath + 23,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeErasure[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeErasure[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeErasure, "/rtl/RsDecodeErasure.v");

   OutFileDecodeErasure = fopen(strRsDecodeErasure,"w");
   
   

   //---------------------------------------------------------------
   // header file
   //---------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "//===================================================================\n");
   fprintf(OutFileDecodeErasure, "// Module Name : RsDecodeErasure\n");
   fprintf(OutFileDecodeErasure, "// File Name   : RsDecodeErasure.v\n");
   fprintf(OutFileDecodeErasure, "// Function    : Rs Decoder Erasure polynomial calculation Module\n");
   fprintf(OutFileDecodeErasure, "// \n");
   fprintf(OutFileDecodeErasure, "// Revision History:\n");
   fprintf(OutFileDecodeErasure, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDecodeErasure, "//===================================================================\n");
   fprintf(OutFileDecodeErasure, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDecodeErasure, "//\n");
   fprintf(OutFileDecodeErasure, "//===================================================================\n");
   fprintf(OutFileDecodeErasure, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDecodeErasure, "//\n\n\n");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "module RsDecodeErasure(\n");
   fprintf(OutFileDecodeErasure, "   CLK,          // system clock\n");
   fprintf(OutFileDecodeErasure, "   RESET,        // system reset\n");
   fprintf(OutFileDecodeErasure, "   enable,       // enable signal\n");
   fprintf(OutFileDecodeErasure, "   sync,         // sync signal\n");
   fprintf(OutFileDecodeErasure, "   erasureIn,    // erasure input\n");

   for (ii=0; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeErasure, "   epsilon_%d,    // epsilon polynom %d\n",ii,ii);
      }else{
         fprintf(OutFileDecodeErasure, "   epsilon_%d,   // epsilon polynom %d\n",ii,ii);
      }
   }

   fprintf(OutFileDecodeErasure, "   numErasure,   // erasure amount\n");
   if (passFailFlag == 1){
      fprintf(OutFileDecodeErasure, "   fail,         // decoder failure signal\n");
   }
   fprintf(OutFileDecodeErasure, "   done          // done signal\n");
   fprintf(OutFileDecodeErasure, ");\n\n\n");

   fprintf(OutFileDecodeErasure, "   input          CLK;           // system clock\n");
   fprintf(OutFileDecodeErasure, "   input          RESET;         // system reset\n");
   fprintf(OutFileDecodeErasure, "   input          enable;        // enable signal\n");
   fprintf(OutFileDecodeErasure, "   input          sync;          // sync signal\n");
   fprintf(OutFileDecodeErasure, "   input          erasureIn;     // erasure input\n");

   for (ii=0; ii<(syndromeLength+1);ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeErasure,  "   output [%d:0]   epsilon_%d;     // syndrome polynom %d\n",(bitSymbol-1), ii, ii);
      }else{
         fprintf(OutFileDecodeErasure,  "   output [%d:0]   epsilon_%d;    // syndrome polynom %d\n",(bitSymbol-1), ii, ii);
      }
   }

  if (syndromeLength > 2047) {
     fprintf(OutFileDecodeErasure, "   output [11:0]   numErasure;    // erasure amount\n");
  }else{
     if (syndromeLength > 1023) {
        fprintf(OutFileDecodeErasure, "   output [10:0]   numErasure;    // erasure amount\n");
     }else{
        if (syndromeLength > 511) {
           fprintf(OutFileDecodeErasure, "   output [9:0]   numErasure;    // erasure amount\n");
        }else{
           if (syndromeLength > 255) {
               fprintf(OutFileDecodeErasure, "   output [8:0]   numErasure;    // erasure amount\n");
           }else{
              if (syndromeLength > 127) {
                 fprintf(OutFileDecodeErasure, "   output [7:0]   numErasure;    // erasure amount\n");
              }else{
                 if (syndromeLength > 63) {
                    fprintf(OutFileDecodeErasure, "   output [6:0]   numErasure;    // erasure amount\n");
                 }else{
                    if (syndromeLength > 31) {
                       fprintf(OutFileDecodeErasure, "   output [5:0]   numErasure;    // erasure amount\n");
                    }else{
                       if (syndromeLength > 15) {
                          fprintf(OutFileDecodeErasure, "   output [4:0]   numErasure;    // erasure amount\n");
                       }else{
                          if (syndromeLength > 7) {
                             fprintf(OutFileDecodeErasure, "   output [3:0]   numErasure;    // erasure amount\n");
                          }else{
                             if (syndromeLength > 3) {
                                fprintf(OutFileDecodeErasure, "   output [2:0]   numErasure;    // erasure amount\n");
                             }else{
                                fprintf(OutFileDecodeErasure, "   output [1:0]   numErasure;    // erasure amount\n");
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

   if (passFailFlag == 1){
      fprintf(OutFileDecodeErasure, "   output         fail;          // decoder failure signal\n");
   }
   fprintf(OutFileDecodeErasure, "   output         done;          // done signal\n");


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
   int kk;


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
   }

   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // - parameters\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------\n");
//   fprintf(OutFileDecodeErasure, "   parameter erasurePower     = %d'd1;\n", bitSymbol);
   fprintf(OutFileDecodeErasure, "   parameter erasureInitialPower = %d'd%d;\n", bitSymbol, initValue);
   fprintf(OutFileDecodeErasure, "\n\n\n");


   //------------------------------------------------------------------------
   // + count
   //- Counter
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + count\n");
   fprintf(OutFileDecodeErasure, "   //- Counter\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
//   fprintf(OutFileDecodeErasure, "  reg    [%d:0]   count;\n",bitSymbol);
   fprintf(OutFileDecodeErasure, "  reg    [%d:0]   count;\n",countSize-1);
   fprintf(OutFileDecodeErasure, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeErasure, "      if (~RESET) begin\n");
//   fprintf(OutFileDecodeErasure, "         count [%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "         count [%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "         if (sync == 1'b1) begin\n");
//   fprintf(OutFileDecodeErasure, "            count[%d:0] <= %d'd1;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "            count[%d:0] <= %d'd1;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "         end\n");
//   fprintf(OutFileDecodeErasure, "         else if ( (count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n",bitSymbol,bitSymbol+1,bitSymbol,bitSymbol+1, TotalSize);
   fprintf(OutFileDecodeErasure, "         else if ( (count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n",countSize-1,countSize,countSize-1,countSize, TotalSize);
//   fprintf(OutFileDecodeErasure, "            count[%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "            count[%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "         else begin\n");
//   fprintf(OutFileDecodeErasure, "            count[%d:0] <= count[%d:0] + %d'd1;\n",bitSymbol,bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "            count[%d:0] <= count[%d:0] + %d'd1;\n",countSize-1,countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "   end\n");
   fprintf(OutFileDecodeErasure, "\n\n\n");


   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + done\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   reg         done;\n");
   fprintf(OutFileDecodeErasure, "   always @(count) begin\n");
//   fprintf(OutFileDecodeErasure, "      if (count ==%d'd%d) begin\n",bitSymbol+1,TotalSize);
   fprintf(OutFileDecodeErasure, "      if (count ==%d'd%d) begin\n",countSize,TotalSize);
   fprintf(OutFileDecodeErasure, "         done = 1'b1;\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "      else begin\n");
   fprintf(OutFileDecodeErasure, "         done = 1'b0;\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "   end\n");
   fprintf(OutFileDecodeErasure, "\n\n");


   //------------------------------------------------------------------------
   // + erasureCount
   //- Erasure Counter
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + erasureCount\n");
   fprintf(OutFileDecodeErasure, "   //- Erasure Counter\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
//   fprintf(OutFileDecodeErasure, "   reg    [%d:0]   erasureCount;\n",bitSymbol);
   fprintf(OutFileDecodeErasure, "   reg    [%d:0]   erasureCount;\n",countSize-1);
   fprintf(OutFileDecodeErasure, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeErasure, "      if (~RESET) begin\n");
//   fprintf(OutFileDecodeErasure, "         erasureCount [%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "         erasureCount [%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "            if (erasureIn == 1'b1) begin\n");
//   fprintf(OutFileDecodeErasure, "               erasureCount [%d:0] <= %d'd1;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "               erasureCount [%d:0] <= %d'd1;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "            end\n");
   fprintf(OutFileDecodeErasure, "            else begin\n");
//   fprintf(OutFileDecodeErasure, "               erasureCount [%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "               erasureCount [%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "            end\n");
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "         else if (erasureIn == 1'b1) begin\n");
//   fprintf(OutFileDecodeErasure, "            erasureCount [%d:0] <= erasureCount [%d:0] + %d'd1;\n",bitSymbol,bitSymbol,bitSymbol+1);
   fprintf(OutFileDecodeErasure, "            erasureCount [%d:0] <= erasureCount [%d:0] + %d'd1;\n",countSize-1,countSize-1,countSize);
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "   end\n");
   fprintf(OutFileDecodeErasure, "\n\n");


   //------------------------------------------------------------------------
   // + fail
   //- If Erasure amount > CHECK_LEN -> fail is ON
   //------------------------------------------------------------------------
   if (passFailFlag == 1){
      fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeErasure, "   // + fail\n");
      fprintf(OutFileDecodeErasure, "   //- If Erasure amount > %d -> fail is ON\n", syndromeLength);
      fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
      fprintf(OutFileDecodeErasure, "   reg         fail;\n");
      fprintf(OutFileDecodeErasure, "   always @(erasureCount) begin\n");
//      fprintf(OutFileDecodeErasure, "      if (erasureCount [%d:0]> %d'd%d) begin\n",bitSymbol,bitSymbol+1,syndromeLength);
      fprintf(OutFileDecodeErasure, "      if (erasureCount [%d:0]> %d'd%d) begin\n",countSize-1,countSize,syndromeLength);
      fprintf(OutFileDecodeErasure, "         fail = 1'b1;\n");
      fprintf(OutFileDecodeErasure, "      end\n");
      fprintf(OutFileDecodeErasure, "      else begin\n");
      fprintf(OutFileDecodeErasure, "         fail = 1'b0;\n");
      fprintf(OutFileDecodeErasure, "      end\n");
      fprintf(OutFileDecodeErasure, "   end\n");
      fprintf(OutFileDecodeErasure, "\n\n");
   }

   //------------------------------------------------------------------------
   // Erasure Polynominal Generator
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // Erasure Polynominal Generator\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   reg    [%d:0]    powerReg;\n",bitSymbol-1);
   fprintf(OutFileDecodeErasure, "   wire    [%d:0]   powerNew;\n",bitSymbol-1);
   fprintf(OutFileDecodeErasure, "   wire    [%d:0]   powerInitialNew;\n",bitSymbol-1);
   fprintf(OutFileDecodeErasure, "\n");


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
   //------------------------------------------------------------------------
    for (Pidx=0; Pidx<bitSymbol; Pidx++){
       fprintf(OutFileDecodeErasure, "   assign powerInitialNew [%d] =",Pidx);
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
                fprintf(OutFileDecodeErasure, " erasureInitialPower[%d]", idx2);
                init = 1;
             }
             else {
                fprintf(OutFileDecodeErasure, " ^ erasureInitialPower[%d]", idx2);
             }
          }
       }
       fprintf(OutFileDecodeErasure, ";\n");
   }


    for (Pidx=0; Pidx<bitSymbol; Pidx++){
       fprintf(OutFileDecodeErasure, "   assign powerNew [%d] =",Pidx);
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
                fprintf(OutFileDecodeErasure, " powerReg[%d]", idx2);
                init = 1;
             }
             else {
                fprintf(OutFileDecodeErasure, " ^ powerReg[%d]", idx2);
             }
          }
       }
       fprintf(OutFileDecodeErasure, ";\n");
   }

   fprintf(OutFileDecodeErasure, "\n\n");


   //------------------------------------------------------------------
   // + powerReg
   //------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + powerReg\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeErasure, "      if (~RESET) begin\n");
   fprintf(OutFileDecodeErasure, "         powerReg [%d:0] <= %d'd0;\n", bitSymbol-1, bitSymbol);
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "            powerReg[%d:0] <= powerInitialNew[%d:0];\n", bitSymbol-1, bitSymbol-1);
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "         else begin\n");
   fprintf(OutFileDecodeErasure, "            powerReg[%d:0] <= powerNew[%d:0];\n", bitSymbol-1, bitSymbol-1);
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "   end\n");
   fprintf(OutFileDecodeErasure, "\n\n");


   //------------------------------------------------------------------------
   // + product_0,..., product_xxx
   //- Erasure Polynominal Generator
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + product_0,..., product_%d\n", syndromeLength);
   fprintf(OutFileDecodeErasure, "   //- Erasure Polynominal Generator\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");

   for (ii=0;ii<(syndromeLength+1);ii++){
       fprintf(OutFileDecodeErasure, "   wire [%d:0]   product_%d;\n", bitSymbol-1, ii);
   }
   fprintf(OutFileDecodeErasure, "\n");


   for (ii=0;ii<(syndromeLength+1);ii++){
      fprintf(OutFileDecodeErasure, "   reg  [%d:0]    epsilonReg_%d;\n", bitSymbol-1, ii);
   }
   fprintf(OutFileDecodeErasure, "\n\n");


   for (ii=0;ii<(syndromeLength+1);ii++){
    fprintf(OutFileDecodeErasure,  "   RsDecodeMult   RsDecodeMult_%d (.A(powerReg[%d:0]), .B(epsilonReg_%d[%d:0]), .P(product_%d[%d:0]));\n", ii, bitSymbol-1, ii, bitSymbol-1, ii, bitSymbol-1);
   }
   fprintf(OutFileDecodeErasure, "\n\n\n");


   //------------------------------------------------------------------------
   // + epsilonReg_0,..., epsilonReg_xxx
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   // + epsilonReg_0,..., epsilonReg_%d\n", syndromeLength-1);
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeErasure, "      if (~RESET) begin\n");


   for (ii=0;ii<(syndromeLength+1);ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeErasure, "         epsilonReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileDecodeErasure, "         epsilonReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }

   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "            if (erasureIn == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "               epsilonReg_0 [%d:0]   <= erasureInitialPower[%d:0];\n",bitSymbol-1,bitSymbol-1);
   fprintf(OutFileDecodeErasure, "               epsilonReg_1 [%d:0]   <= %d'd1;\n",bitSymbol-1,bitSymbol);


   for (ii=2;ii<(syndromeLength+1);ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeErasure, "               epsilonReg_%d [%d:0]   <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFileDecodeErasure, "               epsilonReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFileDecodeErasure, "            end\n");
   fprintf(OutFileDecodeErasure, "            else begin\n");
   fprintf(OutFileDecodeErasure, "               epsilonReg_0 [%d:0]  <= %d'd1;\n",bitSymbol-1,bitSymbol);


   for (ii=1;ii<(syndromeLength+1);ii++){
      if (ii < 10) {
         fprintf(OutFileDecodeErasure, "               epsilonReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
        fprintf(OutFileDecodeErasure, "               epsilonReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }

   fprintf(OutFileDecodeErasure, "            end\n");
   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "         else if (erasureIn == 1'b1) begin\n");
   fprintf(OutFileDecodeErasure, "            epsilonReg_0 [%d:0]  <= product_0[%d:0];\n",bitSymbol-1,bitSymbol-1);

   for (ii=1;ii<(syndromeLength+1);ii++){
      if (ii < 10){
         fprintf(OutFileDecodeErasure, "            epsilonReg_%d [%d:0]  <= epsilonReg_%d [%d:0] ^ product_%d[%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, ii,bitSymbol-1);
      }else{
        fprintf(OutFileDecodeErasure, "            epsilonReg_%d [%d:0] <= epsilonReg_%d [%d:0] ^ product_%d[%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, ii,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeErasure, "         end\n");
   fprintf(OutFileDecodeErasure, "      end\n");
   fprintf(OutFileDecodeErasure, "   end\n");
   fprintf(OutFileDecodeErasure, "\n\n\n");


   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeErasure, "   //- Output Ports\n");
   fprintf(OutFileDecodeErasure, "   //------------------------------------------------------------------------\n");


   for (ii=0;ii<(syndromeLength+1);ii++){
      if (ii < 10){
        fprintf(OutFileDecodeErasure, "   assign epsilon_%d [%d:0]   = epsilonReg_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
        fprintf(OutFileDecodeErasure, "   assign epsilon_%d [%d:0]  = epsilonReg_%d[%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
   fprintf(OutFileDecodeErasure, "\n");


   
   if (syndromeLength > 2047) {
      fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[11:0];\n");
   }else{
      if (syndromeLength > 1023) {
         fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[10:0];\n");
      }else{
         if (syndromeLength > 511) {
            fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[9:0];\n");
         }else{
            if (syndromeLength > 255) {
               fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[8:0];\n");
            }else{
               if (syndromeLength > 127) {
                  fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[7:0];\n");
               }else{
                  if (syndromeLength > 63) {
                     fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[6:0];\n");
                  }else{
                     if (syndromeLength > 31){
                        fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[5:0];\n");
                     }else{
                        if (syndromeLength > 15){
                           fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[4:0];\n");
                        }else{
                           if (syndromeLength > 7){
                              fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[3:0];\n");
                           }else{
                              if (syndromeLength > 3){
                                 fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[2:0];\n");
                              }else{
                                 fprintf(OutFileDecodeErasure, "   assign numErasure   = erasureCount[1:0];\n");
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


   fprintf(OutFileDecodeErasure, "\n");
   fprintf(OutFileDecodeErasure, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileDecodeErasure);


  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] ttTab;
   delete[] bbTab;
   delete[] ppTab;
   delete[] powerTab;
   delete[] bidon;



   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeErasure, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeErasure);

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
	remove(strRsDecodeErasure);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeErasure);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeErasure);


}
