//===================================================================
// Module Name : RsDecodeSyndrome
// File Name   : RsDecodeSyndrome.cpp
// Function    : RTL Decoder syndrome Module generation
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

FILE  *OutFileDecodeSyndrome;

void RsGfMultiplier( int*, int*,int*, int, int);
void RsDecodeSyndrome(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *MrefTab, int *PrefTab, int *coeffTab, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii,zz;
   int Pidx;
   int init;
   int idx1;
   int idx2;
   int tempNum;
   int countSize;
   int kk;
   int *bbTab;
   int *ppTab;
   int *ttTab;
   int *bidon;
   int mmTabSize = (bitSymbol*2) -1;
   char *strRsDecodeSyndrome;


   bbTab = new int[bitSymbol];
   ppTab = new int[bitSymbol];
   ttTab = new int[bitSymbol];
   bidon = new int[bitSymbol];


   syndromeLength = TotalSize - DataSize;


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeSyndrome = (char *)calloc(lengthPath + 24,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeSyndrome[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeSyndrome[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeSyndrome, "/rtl/RsDecodeSyndrome.v");

   OutFileDecodeSyndrome = fopen(strRsDecodeSyndrome,"w");


   //---------------------------------------------------------------
   // header file
   //---------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "//===================================================================\n");
   fprintf(OutFileDecodeSyndrome, "// Module Name : RsDecodeSyndrome\n");
   fprintf(OutFileDecodeSyndrome, "// File Name   : RsDecodeSyndrome.v\n");
   fprintf(OutFileDecodeSyndrome, "// Function    : Rs Decoder syndrome calculation\n");
   fprintf(OutFileDecodeSyndrome, "// \n");
   fprintf(OutFileDecodeSyndrome, "// Revision History:\n");
   fprintf(OutFileDecodeSyndrome, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDecodeSyndrome, "//===================================================================\n");
   fprintf(OutFileDecodeSyndrome, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDecodeSyndrome, "//\n");
   fprintf(OutFileDecodeSyndrome, "//===================================================================\n");
   fprintf(OutFileDecodeSyndrome, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDecodeSyndrome, "//\n\n\n");



   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "module RsDecodeSyndrome(\n");
   fprintf(OutFileDecodeSyndrome, "   CLK,           // system clock\n");
   fprintf(OutFileDecodeSyndrome, "   RESET,         // system reset\n");
   fprintf(OutFileDecodeSyndrome, "   enable,        // enable signal\n");
   fprintf(OutFileDecodeSyndrome, "   sync,          // sync signal\n");
   fprintf(OutFileDecodeSyndrome, "   dataIn,        // data input\n");

   for (ii=0; ii < syndromeLength; ii++) {
      if (ii < 10) {
         fprintf(OutFileDecodeSyndrome, "   syndrome_%d,    // syndrome polynom %d\n", ii, ii);
      }else{
        fprintf(OutFileDecodeSyndrome,  "   syndrome_%d,   // syndrome polynom %d\n",ii,ii);
      }
   }

   fprintf(OutFileDecodeSyndrome, "   done           // done signal\n");
   fprintf(OutFileDecodeSyndrome, ");\n\n\n");
   fprintf(OutFileDecodeSyndrome, "   input          CLK;           // system clock\n");
   fprintf(OutFileDecodeSyndrome, "   input          RESET;         // system reset\n");
   fprintf(OutFileDecodeSyndrome, "   input          enable;        // enable signal\n");
   fprintf(OutFileDecodeSyndrome, "   input          sync;          // sync signal\n");
   fprintf(OutFileDecodeSyndrome, "   input  [%d:0]   dataIn;        // data input\n", (bitSymbol -1));

   for (ii=0; ii<syndromeLength; ii++) {
      if (ii < 10) {
         fprintf(OutFileDecodeSyndrome, "   output [%d:0]   syndrome_%d;    // syndrome polynom %d\n",(bitSymbol -1),ii,ii);
      } else {
         fprintf(OutFileDecodeSyndrome, "   output [%d:0]   syndrome_%d;   // syndrome polynom %d\n",(bitSymbol -1),ii,ii);
      }
   }
   fprintf(OutFileDecodeSyndrome, "   output         done;          // done signal\n\n\n");



   //------------------------------------------------------------------------
   // + COUNT
   //- Counter
   //------------------------------------------------------------------------
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



   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   // + count\n");
   fprintf(OutFileDecodeSyndrome, "   //- Counter\n");
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
//   fprintf(OutFileDecodeSyndrome, "   reg    [%d:0]   count;\n", bitSymbol);
   fprintf(OutFileDecodeSyndrome, "   reg    [%d:0]   count;\n", (countSize-1));
   fprintf(OutFileDecodeSyndrome, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeSyndrome, "      if (~RESET) begin\n");
//   fprintf(OutFileDecodeSyndrome, "         count [%d:0] <= %d'd0;\n", bitSymbol, (bitSymbol+1));
   fprintf(OutFileDecodeSyndrome, "         count [%d:0] <= %d'd0;\n", (countSize-1), countSize);
   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeSyndrome, "         if (sync == 1'b1) begin\n");
   fprintf(OutFileDecodeSyndrome, "            count[%d:0] <= %d'd1;\n", (countSize-1), countSize);
   fprintf(OutFileDecodeSyndrome, "         end\n");
//   fprintf(OutFileDecodeSyndrome, "         else if ( (count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", bitSymbol, (bitSymbol+1), bitSymbol, (bitSymbol+1),TotalSize);
   fprintf(OutFileDecodeSyndrome, "         else if ( (count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", (countSize-1), countSize, (countSize-1), countSize,TotalSize);
//   fprintf(OutFileDecodeSyndrome, "            count[%d:0] <= %d'd0;\n", bitSymbol, (bitSymbol+1));
   fprintf(OutFileDecodeSyndrome, "            count[%d:0] <= %d'd0;\n", (countSize-1), countSize);
   fprintf(OutFileDecodeSyndrome, "         end\n");
   fprintf(OutFileDecodeSyndrome, "         else begin\n");
//   fprintf(OutFileDecodeSyndrome, "            count[%d:0] <= count[%d:0] + %d'd1;\n", bitSymbol, bitSymbol, (bitSymbol+1));
   fprintf(OutFileDecodeSyndrome, "            count[%d:0] <= count[%d:0] + %d'd1;\n", (countSize-1), (countSize-1), countSize);
   fprintf(OutFileDecodeSyndrome, "         end\n");
   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "   end\n");
   fprintf(OutFileDecodeSyndrome, "\n\n\n");


   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   // + done\n");
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   reg         done;\n");
   fprintf(OutFileDecodeSyndrome, "   always @(count) begin\n");
//   fprintf(OutFileDecodeSyndrome, "      if (count ==%d'd%d) begin\n", (bitSymbol+1),TotalSize);
   fprintf(OutFileDecodeSyndrome, "      if (count ==%d'd%d) begin\n", countSize,TotalSize);
   fprintf(OutFileDecodeSyndrome, "         done = 1'b1;\n");
   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "      else begin\n");
   fprintf(OutFileDecodeSyndrome, "         done = 1'b0;\n");
   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "   end\n");
   fprintf(OutFileDecodeSyndrome, "\n\n");


   //------------------------------------------------------------------------
   // + product_0,..., product_xxx
   //- Syndrome Generator
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   // + product_0,..., product_%d\n", (syndromeLength-1));
   fprintf(OutFileDecodeSyndrome, "   //- Syndrome Generator\n");
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");

   for (ii=0; ii<syndromeLength;ii++) {
      fprintf(OutFileDecodeSyndrome, "   wire [%d:0]   product_%d;\n",(bitSymbol-1),ii);
   }
   fprintf(OutFileDecodeSyndrome, "\n");

   for (ii=0;ii<syndromeLength;ii++) {
      fprintf(OutFileDecodeSyndrome, "   reg  [%d:0]    reg_%d;\n",(bitSymbol-1), ii);
   }
   fprintf(OutFileDecodeSyndrome, "\n");


   //------------------------------------------------------------------------
   // + RsDecodeMakeMultCoeff Emulation
   //------------------------------------------------------------------------
   for (zz = 0; zz <syndromeLength;zz++){
      if (zz == 0) {
         for (kk = 0; kk <bitSymbol;kk++){
            fprintf(OutFileDecodeSyndrome, "   assign product_%d [%d] = reg_%d[%d];\n", zz, kk,zz,kk);
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
         for(ii=1; ii<zz+1; ii++){
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
            if (ii==zz) {
               for (Pidx=0; Pidx<bitSymbol; Pidx++){
                  fprintf(OutFileDecodeSyndrome, "   assign product_%d [%d] =", zz,Pidx);
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
                           fprintf(OutFileDecodeSyndrome, " reg_%d[%d]", zz,idx2);
                           init = 1;
                        }
                        else {
                           fprintf(OutFileDecodeSyndrome, " ^ reg_%d[%d]", zz,idx2);
                        }
                     }
                  }
                  fprintf(OutFileDecodeSyndrome, ";\n");
               }
            }
         }
      }
   }

   fprintf(OutFileDecodeSyndrome, "\n\n\n");



   //------------------------------------------------------------------------
   // + REG_0,..., REG_xxx
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   // + REG_0,..., REG_%d\n", syndromeLength-1);
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileDecodeSyndrome, "      if (~RESET) begin\n");

   for (ii=0; ii<syndromeLength;ii++) {
      if (ii < 10) {
         fprintf(OutFileDecodeSyndrome, "         reg_%d [%d:0]  <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
        fprintf(OutFileDecodeSyndrome, "         reg_%d [%d:0] <= %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }


   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileDecodeSyndrome, "         if (sync == 1'b1) begin\n");


   for (ii=0; ii<syndromeLength;ii++) {
      if (ii < 10) {
         fprintf(OutFileDecodeSyndrome, "            reg_%d [%d:0]  <= dataIn[%d:0];\n",ii, bitSymbol-1 ,bitSymbol-1);
      }else{
         fprintf(OutFileDecodeSyndrome, "            reg_%d [%d:0] <= dataIn[%d:0];\n",ii, bitSymbol-1 ,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeSyndrome, "         end\n");
   fprintf(OutFileDecodeSyndrome, "         else begin\n");


   for (ii=0; ii<syndromeLength; ii++) {
      if (ii < 10) {
        fprintf(OutFileDecodeSyndrome, "            reg_%d [%d:0]  <= dataIn [%d:0] ^ product_%d[%d:0];\n", ii,bitSymbol-1,bitSymbol-1, ii,bitSymbol-1);
      }else{
        fprintf(OutFileDecodeSyndrome, "            reg_%d [%d:0] <= dataIn [%d:0] ^ product_%d[%d:0];\n", ii,bitSymbol-1,bitSymbol-1, ii,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeSyndrome, "         end\n");
   fprintf(OutFileDecodeSyndrome, "      end\n");
   fprintf(OutFileDecodeSyndrome, "   end\n");
   fprintf(OutFileDecodeSyndrome, "\n\n\n");


   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDecodeSyndrome, "   //- Output Ports\n");
   fprintf(OutFileDecodeSyndrome, "   //------------------------------------------------------------------------\n");

   for (ii=0;ii<syndromeLength;ii++){
      if (ii<10) {
        fprintf(OutFileDecodeSyndrome, "   assign   syndrome_%d[%d:0]  = reg_%d[%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }else{
        fprintf(OutFileDecodeSyndrome, "   assign   syndrome_%d[%d:0] = reg_%d[%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }
   }

   fprintf(OutFileDecodeSyndrome, "\n");
   fprintf(OutFileDecodeSyndrome, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileDecodeSyndrome);


  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] bbTab;
   delete[] ppTab;
   delete[] ttTab;
   delete[] bidon;


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeSyndrome, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeSyndrome);

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
	remove(strRsDecodeSyndrome);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeSyndrome);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeSyndrome);


}
