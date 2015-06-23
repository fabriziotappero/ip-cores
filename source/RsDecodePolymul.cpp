//===================================================================
// Module Name : RsDecodePolymul
// File Name   : RsDecodePolymul.cpp
// Function    : RTL Decoder polymul Module generation
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
FILE  *OutFilePolymul;


void RsDecodePolymul(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {


  //---------------------------------------------------------------
  // c++ variables
  //---------------------------------------------------------------
  int syndromeLength;
  int ii;
  int countSize;
  char *strRsDecodePolymul;


  syndromeLength = TotalSize - DataSize;


  //---------------------------------------------------------------
  // open file
  //---------------------------------------------------------------
   strRsDecodePolymul = (char *)calloc(lengthPath + 24,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodePolymul[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodePolymul[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodePolymul, "/rtl/RsDecodePolymul.v");

   OutFilePolymul = fopen(strRsDecodePolymul,"w");


  //---------------------------------------------------------------
  // Ports Declaration
  //---------------------------------------------------------------
   fprintf(OutFilePolymul, "//===================================================================\n");
   fprintf(OutFilePolymul, "// Module Name : RsDecodePolymul\n");
   fprintf(OutFilePolymul, "// File Name   : RsDecodePolymul.v\n");
   fprintf(OutFilePolymul, "// Function    : Rs Decoder polymul calculation Module\n");
   fprintf(OutFilePolymul, "// \n");
   fprintf(OutFilePolymul, "// Revision History:\n");
   fprintf(OutFilePolymul, "// Date          By           Version    Change Description\n");
   fprintf(OutFilePolymul, "//===================================================================\n");
   fprintf(OutFilePolymul, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFilePolymul, "//\n");
   fprintf(OutFilePolymul, "//===================================================================\n");
   fprintf(OutFilePolymul, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFilePolymul, "//\n\n\n");


   fprintf(OutFilePolymul, "module RsDecodePolymul(\n");
   fprintf(OutFilePolymul, "   CLK,              // system clock\n");
   fprintf(OutFilePolymul, "   RESET,            // system reset\n");
   fprintf(OutFilePolymul, "   enable,           // enable signal\n");
   fprintf(OutFilePolymul, "   sync,             // sync signal\n");

   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   syndromeIn_%d,     // syndrome polynom %d\n", ii, ii);
      }else{
         fprintf(OutFilePolymul, "   syndromeIn_%d,    // syndrome polynom %d\n", ii, ii);
      }
   }
   for(ii=0; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   epsilon_%d,        // epsilon polynom %d\n", ii, ii);
      }else{
         fprintf(OutFilePolymul, "   epsilon_%d,       // epsilon polynom %d\n", ii, ii);
      }
   }
   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   syndromeOut_%d,    // modified syndrome polynom %d\n", ii, ii);
      }else{
         fprintf(OutFilePolymul, "   syndromeOut_%d,   // modified syndrome polynom %d\n", ii, ii);
      }
   }

   fprintf(OutFilePolymul, "   done              // done signal\n");
   fprintf(OutFilePolymul, ");\n\n\n");


   fprintf(OutFilePolymul, "   input          CLK;              // system clock\n");
   fprintf(OutFilePolymul, "   input          RESET;            // system reset\n");
   fprintf(OutFilePolymul, "   input          enable;           // enable signal\n");
   fprintf(OutFilePolymul, "   input          sync;             // sync signal\n");

   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   input  [%d:0]   syndromeIn_%d;     // syndrome polynom %d\n",bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFilePolymul, "   input  [%d:0]   syndromeIn_%d;    // syndrome polynom %d\n",bitSymbol-1, ii, ii);
      }
   }
   for(ii=0; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   input  [%d:0]   epsilon_%d;        // epsilon polynom %d\n",bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFilePolymul, "   input  [%d:0]   epsilon_%d;       // epsilon polynom %d\n",bitSymbol-1, ii, ii);
      }
   }
   fprintf(OutFilePolymul, "\n");

   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "   output [%d:0]   syndromeOut_%d;    // modified syndrome polynom %d\n",bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFilePolymul, "   output [%d:0]   syndromeOut_%d;   // modified syndrome polynom %d\n",bitSymbol-1, ii, ii);
      }
   }

   fprintf(OutFilePolymul, "   output         done;             // done signal\n\n\n");
   fprintf(OutFilePolymul, "\n\n\n");


   //------------------------------------------------------------------------
   // + count
   //- Counter
   //------------------------------------------------------------------------
   countSize = 0;

   if ((syndromeLength+1) > 2047) {
      countSize = 12;
   } else{
      if ((syndromeLength+1) > 1023) {
         countSize = 11;
      } else{
         if ((syndromeLength+1) > 511) {
            countSize = 10;
         }else{
            if ((syndromeLength+1) > 255) {
               countSize = 9;
            }else{
               if ((syndromeLength+1) > 127) {
                  countSize = 8;
               }else{
                  if ((syndromeLength+1) > 63) {
                     countSize = 7;
                  }else{
                     if ((syndromeLength+1) > 31) {
                        countSize = 6;
                     }else{
                        if ((syndromeLength+1) > 15) {
                           countSize = 5;
                        }else{
                           if ((syndromeLength+1) > 7) {
                              countSize = 4;
                           }else{
                              if ((syndromeLength+1) > 3) {
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


   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + count\n");
   fprintf(OutFilePolymul, "   //- Counter\n");
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
//   fprintf(OutFilePolymul, "   reg    [%d:0]   count;\n",bitSymbol);
   fprintf(OutFilePolymul, "   reg    [%d:0]   count;\n",countSize -1);
   fprintf(OutFilePolymul, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFilePolymul, "      if (~RESET) begin\n");
//   fprintf(OutFilePolymul, "         count [%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFilePolymul, "         count [%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFilePolymul, "         if (sync == 1'b1) begin\n");
//   fprintf(OutFilePolymul, "            if (count[%d:0]==%d'd0) begin\n",bitSymbol,bitSymbol+1);
/*   fprintf(OutFilePolymul, "            if (count[%d:0]==%d'd0) begin\n",countSize-1,countSize);
//   fprintf(OutFilePolymul, "               count[%d:0] <= %d'd1;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFilePolymul, "               count[%d:0] <= %d'd1;\n",countSize-1,countSize);
   fprintf(OutFilePolymul, "            end\n");
   fprintf(OutFilePolymul, "            else begin\n");
//   fprintf(OutFilePolymul, "               count[%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFilePolymul, "               count[%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFilePolymul, "            end\n");*/
   fprintf(OutFilePolymul, "            count[%d:0] <= %d'd1;\n",countSize-1,countSize);
   fprintf(OutFilePolymul, "         end\n");
//   fprintf(OutFilePolymul, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n",bitSymbol,bitSymbol+1,bitSymbol,bitSymbol+1, (syndromeLength+1));
   fprintf(OutFilePolymul, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n",countSize-1,countSize,countSize-1,countSize, (syndromeLength+1));
//   fprintf(OutFilePolymul, "            count[%d:0] <= %d'd0;\n",bitSymbol,bitSymbol+1);
   fprintf(OutFilePolymul, "            count[%d:0] <= %d'd0;\n",countSize-1,countSize);
   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "         else begin\n");
//   fprintf(OutFilePolymul, "            count[%d:0] <= count[%d:0] + %d'd1;\n",bitSymbol,bitSymbol,bitSymbol+1);
   fprintf(OutFilePolymul, "            count[%d:0] <= count[%d:0] + %d'd1;\n",countSize-1,countSize-1,countSize);
   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");
   fprintf(OutFilePolymul, "\n\n");


   //------------------------------------------------------------------------
   // + done
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + done\n");
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   reg         done;\n");
   fprintf(OutFilePolymul, "   always @(count) begin\n");
//   fprintf(OutFilePolymul, "      if (count[%d:0] == %d'd%d) begin\n",bitSymbol,bitSymbol+1,(syndromeLength+1));
   fprintf(OutFilePolymul, "      if (count[%d:0] == %d'd%d) begin\n",countSize-1,countSize,(syndromeLength+1));
   fprintf(OutFilePolymul, "         done = 1'b1;\n");
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "      else begin\n");
   fprintf(OutFilePolymul, "         done = 1'b0;\n");
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");
   fprintf(OutFilePolymul, "\n\n");


   //------------------------------------------------------------------------
   // + syndromeReg_0,..., syndromeReg_xxx
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + syndromeReg_0,..., syndromeReg_%d\n", syndromeLength-1);
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFilePolymul, "   reg [%d:0]   syndromeReg_%d;\n",bitSymbol-1,ii);
   }
   fprintf(OutFilePolymul, "\n\n");


   fprintf(OutFilePolymul, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFilePolymul, "      if (~RESET) begin\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "         syndromeReg_%d [%d:0]  <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFilePolymul, "         syndromeReg_%d [%d:0] <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFilePolymul, "      end \n");
   fprintf(OutFilePolymul, "      else if ((enable == 1'b1) && (sync == 1'b1)) begin\n");
   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "         syndromeReg_%d [%d:0]  <= syndromeIn_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "         syndromeReg_%d [%d:0] <= syndromeIn_%d [%d:0];\n",ii,bitSymbol-1,ii,bitSymbol-1);
      }
   }
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");


   //------------------------------------------------------------------------
   // + epsilonReg_0,..., epsilonReg_xxx
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + epsilonReg_0,..., epsilonReg_%d\n", syndromeLength);
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");

   for(ii=0; ii<(syndromeLength+1); ii++){
      fprintf(OutFilePolymul, "   reg [%d:0]   epsilonReg_%d;\n",bitSymbol-1,ii);
   }
   fprintf(OutFilePolymul, "\n");

   fprintf(OutFilePolymul, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFilePolymul, "      if (~RESET) begin\n");
   for(ii=0; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "         epsilonReg_%d [%d:0]  <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFilePolymul, "         epsilonReg_%d [%d:0] <= %d'd0;\n",ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFilePolymul, "         if (sync == 1'b1) begin\n");
   fprintf(OutFilePolymul, "            epsilonReg_0 [%d:0]  <= %d'd0;\n",bitSymbol-1,bitSymbol);
   for(ii=1; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "            epsilonReg_%d [%d:0]  <= epsilon_%d[%d:0];\n",ii,bitSymbol-1,(ii-1),bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "            epsilonReg_%d [%d:0] <= epsilon_%d[%d:0];\n",ii,bitSymbol-1,(ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "         else begin\n");
   fprintf(OutFilePolymul, "            epsilonReg_0 [%d:0]  <= %d'd0;\n",bitSymbol-1,bitSymbol);
   for(ii=1; ii<(syndromeLength+1); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "            epsilonReg_%d [%d:0]  <= epsilonReg_%d[%d:0];\n",ii,bitSymbol-1,(ii-1),bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "            epsilonReg_%d [%d:0] <= epsilonReg_%d[%d:0];\n",ii,bitSymbol-1,(ii-1),bitSymbol-1);
      }
   }
   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");
   fprintf(OutFilePolymul, "\n\n");


   //------------------------------------------------------------------------
   // + epsilonMsb
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "    //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "    // + epsilonMsb\n");
   fprintf(OutFilePolymul, "    //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "    reg [%d:0]   epsilonMsb;\n",bitSymbol-1);
   fprintf(OutFilePolymul, "\n");
   fprintf(OutFilePolymul, "   always @(sync");
   fprintf(OutFilePolymul, " or epsilon_%d",syndromeLength);
   fprintf(OutFilePolymul, " or epsilonReg_%d",syndromeLength);
   fprintf(OutFilePolymul, " ) begin\n");
   fprintf(OutFilePolymul, "      if (sync == 1'b1) begin\n");
   fprintf(OutFilePolymul, "         epsilonMsb [%d:0] = epsilon_%d [%d:0];\n",bitSymbol-1, syndromeLength,bitSymbol-1);
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "      else begin\n");
   fprintf(OutFilePolymul, "         epsilonMsb [%d:0] = epsilonReg_%d [%d:0];\n",bitSymbol-1, syndromeLength,bitSymbol-1);
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");
   fprintf(OutFilePolymul, "\n\n");


   //------------------------------------------------------------------------
   // + product_0,..., product_xxx
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + product_0,..., product_%d\n", syndromeLength-1);
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");

   for(ii=0; ii<(syndromeLength); ii++){
      fprintf(OutFilePolymul, "   wire [%d:0]   product_%d;\n",bitSymbol-1, ii);
   }
   fprintf(OutFilePolymul, "\n\n");


   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "    RsDecodeMult  RsDecodeMult_%d  (  .A(epsilonMsb[%d:0]), .B(syndromeReg_%d[%d:0]), .P(product_%d[%d:0]));\n", ii,bitSymbol-1, ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "    RsDecodeMult  RsDecodeMult_%d (  .A(epsilonMsb[%d:0]), .B(syndromeReg_%d[%d:0]), .P(product_%d[%d:0]));\n", ii,bitSymbol-1, ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
   fprintf(OutFilePolymul, "\n\n\n");


   //------------------------------------------------------------------------
   // + sumReg_0,..., sumReg_xxx
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // + sumReg_0,..., sumReg_%d\n", syndromeLength-1);
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   for(ii=0; ii<(syndromeLength); ii++){
      fprintf(OutFilePolymul, "   reg [%d:0]   sumReg_%d;\n",bitSymbol-1, ii);
   }

   fprintf(OutFilePolymul, "\n\n");

   fprintf(OutFilePolymul, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFilePolymul, "      if (~RESET) begin\n");
   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "         sumReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFilePolymul, "         sumReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFilePolymul, "         if (sync == 1'b1) begin\n");
   fprintf(OutFilePolymul, "            if (epsilon_%d[%d:0] != %d'd0) begin\n", syndromeLength,bitSymbol-1,bitSymbol);
   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "               sumReg_%d [%d:0]  <= syndromeIn_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "               sumReg_%d [%d:0] <= syndromeIn_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }

   fprintf(OutFilePolymul, "            end\n");
   fprintf(OutFilePolymul, "            else begin\n");

   for(ii=0; ii<(syndromeLength); ii++){
      if (ii < 10) {
         fprintf(OutFilePolymul, "               sumReg_%d [%d:0]  <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }else{
         fprintf(OutFilePolymul, "               sumReg_%d [%d:0] <= %d'd0;\n", ii,bitSymbol-1,bitSymbol);
      }
   }

   fprintf(OutFilePolymul, "            end\n");
   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "         else begin\n");
   fprintf(OutFilePolymul, "            sumReg_0 [%d:0]  <= product_0 [%d:0];\n",bitSymbol-1,bitSymbol-1);

   for(ii=1; ii<(syndromeLength); ii++){
      if (ii<10){
         fprintf(OutFilePolymul, "            sumReg_%d  [%d:0] <= sumReg_%d  [%d:0] ^ product_%d  [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "            sumReg_%d [%d:0] <= sumReg_%d [%d:0] ^ product_%d [%d:0];\n", ii,bitSymbol-1, (ii-1),bitSymbol-1, ii,bitSymbol-1);
      }
   }

   fprintf(OutFilePolymul, "         end\n");
   fprintf(OutFilePolymul, "      end\n");
   fprintf(OutFilePolymul, "   end\n");
   fprintf(OutFilePolymul, "\n\n\n");


   //------------------------------------------------------------------------
   //- Output Ports
   //------------------------------------------------------------------------
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");
   fprintf(OutFilePolymul, "   // Output signals\n");
   fprintf(OutFilePolymul, "   //------------------------------------------------------------------------\n");

   for(ii=0; ii<(syndromeLength); ii++){
      if (ii<10){
         fprintf(OutFilePolymul, "   assign   syndromeOut_%d  [%d:0] = sumReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }else{
         fprintf(OutFilePolymul, "   assign   syndromeOut_%d [%d:0] = sumReg_%d [%d:0];\n", ii,bitSymbol-1, ii,bitSymbol-1);
      }
   }
   fprintf(OutFilePolymul, "\n\n");
   fprintf(OutFilePolymul, "endmodule\n");

  //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFilePolymul);


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodePolymul, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodePolymul);
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
	remove(strRsDecodePolymul);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodePolymul);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodePolymul);


}
