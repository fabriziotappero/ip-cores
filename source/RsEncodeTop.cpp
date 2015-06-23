//===================================================================
// Module Name : RsEncodeTop
// File Name   : RsEncodeTop.cpp
// Function    : RTL Encoder Top Module generation
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
#include <ctime>
#include<windows.h>
#include<fstream>
#include <string.h>
using namespace std;
FILE  *OutFileEncodeTop;

void RsGfMultiplier( int*, int*,int*, int, int);


void RsEncodeTop(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int *coeffTab, int *MrefTab, int *PrefTab, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C parameters
   //---------------------------------------------------------------
   int syndromeLength;
   syndromeLength = TotalSize - DataSize;

   int ii,jj,zz;
   int countSize;
   int flag;
   int flagIndex;
   int Pidx;
   int init;
   int idx1;
   int idx2;
   int idx;
   int tempNum;
   int LoopSize;
   int Temp;
   int mmTabSize = (bitSymbol*2) -1;

   int *ttTab;
   int *bbTab;
   int *ppTab;
   int *bidon;
   char *strRsEncodeTop;

   ttTab     = new int[bitSymbol];
   bbTab     = new int[bitSymbol];
   ppTab     = new int[bitSymbol];
   bidon     = new int[bitSymbol];
   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsEncodeTop = (char *)calloc(lengthPath + 20,  sizeof(char));
   if (pathFlag == 0) { 
        strRsEncodeTop[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsEncodeTop[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsEncodeTop, "/rtl/RsEncodeTop.v");

   OutFileEncodeTop = fopen(strRsEncodeTop,"w");


   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------

   fprintf(OutFileEncodeTop, "//===================================================================\n");
   fprintf(OutFileEncodeTop, "// Module Name : RsEncodeTop\n");
   fprintf(OutFileEncodeTop, "// File Name   : RsEncodeTop.v\n");
   fprintf(OutFileEncodeTop, "// Function    : Rs Encoder Top Module\n");
   fprintf(OutFileEncodeTop, "// \n");
   fprintf(OutFileEncodeTop, "// Revision History:\n");
   fprintf(OutFileEncodeTop, "// Date          By           Version    Change Description\n");
   fprintf(OutFileEncodeTop, "//===================================================================\n");
   fprintf(OutFileEncodeTop, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileEncodeTop, "//\n");
   fprintf(OutFileEncodeTop, "//===================================================================\n");
   fprintf(OutFileEncodeTop, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileEncodeTop, "//\n\n\n");



   fprintf(OutFileEncodeTop, "module RsEncodeTop(\n");
   fprintf(OutFileEncodeTop, "   CLK,        // system clock\n");
   fprintf(OutFileEncodeTop, "   RESET,      // system reset\n");
   fprintf(OutFileEncodeTop, "   enable,     // rs encoder enable signal\n");
   fprintf(OutFileEncodeTop, "   startPls,   // rs encoder sync signal\n");
   fprintf(OutFileEncodeTop, "   dataIn,     // rs encoder data in\n");
   fprintf(OutFileEncodeTop, "   dataOut     // rs encoder data out\n");
   fprintf(OutFileEncodeTop, ");\n\n\n");
   fprintf(OutFileEncodeTop, "   input          CLK;        // system clock\n");
   fprintf(OutFileEncodeTop, "   input          RESET;      // system reset\n");
   fprintf(OutFileEncodeTop, "   input          enable;     // rs encoder enable signal\n");
   fprintf(OutFileEncodeTop, "   input          startPls;   // rs encoder sync signal\n");
   fprintf(OutFileEncodeTop, "   input  [%d:0]   dataIn;     // rs encoder data in\n", (bitSymbol-1));
   fprintf(OutFileEncodeTop, "   output [%d:0]   dataOut;    // rs encoder data out\n", (bitSymbol-1));
   fprintf(OutFileEncodeTop, "\n\n\n");


   //---------------------------------------------------------------
   //- registers
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

   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- registers\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
//   fprintf(OutFileEncodeTop, "   reg  [%d:0]   count;\n", bitSymbol);
   fprintf(OutFileEncodeTop, "   reg  [%d:0]   count;\n", countSize-1);
   fprintf(OutFileEncodeTop, "   reg          dataValid;\n");
   fprintf(OutFileEncodeTop, "   reg  [%d:0]   feedbackReg;\n", (bitSymbol-1));
   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileEncodeTop, "   wire [%d:0]   mult_%d;\n", (bitSymbol-1), ii);
   }

   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileEncodeTop, "   reg  [%d:0]   syndromeReg_%d;\n", (bitSymbol-1), ii);
   }

   fprintf(OutFileEncodeTop, "   reg  [%d:0]   dataReg;\n", (bitSymbol-1));
   fprintf(OutFileEncodeTop, "   reg  [%d:0]   syndromeRegFF;\n", (bitSymbol-1));
   fprintf(OutFileEncodeTop, "   reg  [%d:0]   wireOut;\n", (bitSymbol-1));


   //-----------------------------------------------------------------------
   // +  genPolynomCoeff_
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "\n\n\n");


   //-----------------------------------------------------------------------
   // count
   //------------------------------------------------------------------------

   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- count\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEncodeTop, "      if (~RESET) begin\n");
//   fprintf(OutFileEncodeTop, "         count [%d:0] <= %d'd0;\n", bitSymbol, (bitSymbol+1));
   fprintf(OutFileEncodeTop, "         count [%d:0] <= %d'd0;\n", (countSize-1), countSize);
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEncodeTop, "         if (startPls == 1'b1) begin\n");
//   fprintf(OutFileEncodeTop, "            count[%d:0] <= %d'd1;\n", bitSymbol, (bitSymbol+1));
   fprintf(OutFileEncodeTop, "            count[%d:0] <= %d'd1;\n", (countSize-1), countSize);
   fprintf(OutFileEncodeTop, "         end\n");
//   fprintf(OutFileEncodeTop, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", bitSymbol, (bitSymbol+1), bitSymbol, (bitSymbol+1), TotalSize);
   fprintf(OutFileEncodeTop, "         else if ((count[%d:0] ==%d'd0) || (count[%d:0] ==%d'd%d)) begin\n", (countSize-1), countSize, (countSize-1), countSize, TotalSize);
//   fprintf(OutFileEncodeTop, "            count[%d:0] <= %d'd0;\n", bitSymbol, (bitSymbol+1));
   fprintf(OutFileEncodeTop, "            count[%d:0] <= %d'd0;\n", (countSize-1), countSize);
   fprintf(OutFileEncodeTop, "         end\n");
   fprintf(OutFileEncodeTop, "         else begin\n");
//   fprintf(OutFileEncodeTop, "            count[%d:0] <= count[%d:0] + %d'd1;\n", bitSymbol, bitSymbol, (bitSymbol+1));
   fprintf(OutFileEncodeTop, "            count[%d:0] <= count[%d:0] + %d'd1;\n", (countSize-1), (countSize-1), countSize);
   fprintf(OutFileEncodeTop, "         end\n");
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");


   //-----------------------------------------------------------------------
   // dataValid
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- dataValid\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   always @(count or startPls) begin\n");
//   fprintf(OutFileEncodeTop, "      if (startPls == 1'b1 || (count[%d:0] < %d'd%d)) begin\n", bitSymbol, (bitSymbol+1), DataSize);
   fprintf(OutFileEncodeTop, "      if (startPls == 1'b1 || (count[%d:0] < %d'd%d)) begin\n", (countSize-1), countSize, DataSize);
//   fprintf(OutFileEncodeTop, "         dataValid <= 1'b1;\n");
   fprintf(OutFileEncodeTop, "         dataValid = 1'b1;\n");
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else begin\n");
//   fprintf(OutFileEncodeTop, "         dataValid <= 1'b0;\n");
   fprintf(OutFileEncodeTop, "         dataValid = 1'b0;\n");
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n\n");


   //-----------------------------------------------------------------------
   // Multipliers
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- Multipliers\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");


   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------
   // Multplication Process
   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------




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


   //------------------------------------------------------------------------
   // initialize LoopSize
   //------------------------------------------------------------------------
   LoopSize = 2;
   for(ii=0; ii<(bitSymbol-1); ii++){
      LoopSize = LoopSize*2;
   }


   //------------------------------------------------------------------------
   // if coeefTab is null
   //------------------------------------------------------------------------
   for(jj=0; jj<syndromeLength; jj++){
      if (coeffTab[jj] == 0) {
         for (idx2=0; idx2<bitSymbol;idx2++){
            fprintf(OutFileEncodeTop, "   assign mult_%d[%d] = feedbackReg[%d];\n", jj, idx2, idx2);
         }
      }
   }


   for(ii=1; ii<LoopSize; ii++){
      //------------------------------------------------------------------------
      // ppTab = ttTab * bbTab
      //------------------------------------------------------------------------
      RsGfMultiplier(ppTab, ttTab, bbTab, PrimPoly, bitSymbol);


      //------------------------------------------------------------------------
      // reassign ttTab
      //------------------------------------------------------------------------
      for (jj=0;jj<bitSymbol;jj++){
         ttTab[jj]	= ppTab[jj];
      }


      flag = 0;
      flagIndex = 0;
      for(jj=0; jj<syndromeLength; jj++){
         flag = 0;
         flagIndex = 0;
         if (coeffTab[jj] == ii) {
            flag = 1;
            flagIndex = jj;

            //------------------------------------------------------------------------
            // printf P_OUT[]
            //------------------------------------------------------------------------
            for (Pidx=0; Pidx<bitSymbol; Pidx++){
               if (flag == 1) {
                  fprintf(OutFileEncodeTop, "   assign mult_%d[%d] = ", flagIndex, Pidx);
               }
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
                        if (flag == 1) {
                           fprintf(OutFileEncodeTop, " feedbackReg[%d]", idx2);
                        }
                        init = 1;
                     }
                     else {
                        if (flag == 1) {
                           fprintf(OutFileEncodeTop, " ^ feedbackReg[%d]", idx2);
                        }
                     }
                  }
               }
               if (flag == 1) {
                  fprintf(OutFileEncodeTop,";\n");
               }
            }
         }
      }
   }



   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------
   // Multplication Process
   //-----------------------------------------------------------------------
   //-----------------------------------------------------------------------

   fprintf(OutFileEncodeTop, "\n\n\n");


   //-----------------------------------------------------------------------
   // syndromeReg
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- syndromeReg\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   always @(posedge CLK or negedge RESET) begin\n");
   fprintf(OutFileEncodeTop, "      if (~RESET) begin\n");
   for (ii=0; ii < syndromeLength; ii++) {
      if (ii < 10) {
         fprintf(OutFileEncodeTop, "         syndromeReg_%d [%d:0]  <= %d'd0;\n", ii, (bitSymbol-1), bitSymbol);
      }else{
         fprintf(OutFileEncodeTop, "         syndromeReg_%d [%d:0] <= %d'd0;\n", ii, (bitSymbol-1), bitSymbol);
      }
   }
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else if (enable == 1'b1) begin\n");

   fprintf(OutFileEncodeTop, "         if (startPls == 1'b1) begin\n");
   for (ii=0; ii < syndromeLength; ii++) {
      if (ii < 10) {
         fprintf(OutFileEncodeTop, "            syndromeReg_%d [%d:0]  <= mult_%d [%d:0];\n", ii, (bitSymbol-1), ii, (bitSymbol-1));
      }else{
         fprintf(OutFileEncodeTop, "            syndromeReg_%d [%d:0] <= mult_%d [%d:0];\n", ii, (bitSymbol-1), ii, (bitSymbol-1));
      }
   }

   fprintf(OutFileEncodeTop, "         end\n");
   fprintf(OutFileEncodeTop, "         else begin\n");
   fprintf(OutFileEncodeTop, "            syndromeReg_0 [%d:0]  <= mult_0 [%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   for (ii=1; ii < syndromeLength; ii++){
      if (ii < 10) {
         fprintf(OutFileEncodeTop, "            syndromeReg_%d [%d:0]  <= (syndromeReg_%d [%d:0] ^ mult_%d [%d:0]);\n", ii,(bitSymbol-1), (ii-1),(bitSymbol-1), ii, (bitSymbol-1));
      }else{
         fprintf(OutFileEncodeTop, "            syndromeReg_%d [%d:0] <= (syndromeReg_%d [%d:0] ^ mult_%d [%d:0]);\n", ii,(bitSymbol-1), (ii-1),(bitSymbol-1), ii, (bitSymbol-1));
      }
   }
   fprintf(OutFileEncodeTop, "         end\n");
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");



   //-----------------------------------------------------------------------
   // feedbackReg
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- feedbackReg\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   always @( startPls, dataValid, dataIn");
   fprintf(OutFileEncodeTop, ", syndromeReg_%d",(syndromeLength-1));
   fprintf(OutFileEncodeTop, " ) begin\n");
   fprintf(OutFileEncodeTop, "      if (startPls == 1'b1) begin\n");
//   fprintf(OutFileEncodeTop, "         feedbackReg[%d:0] <= dataIn[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "         feedbackReg[%d:0] = dataIn[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else if (dataValid == 1'b1) begin\n");
//   fprintf(OutFileEncodeTop, "         feedbackReg [%d:0] <= dataIn[%d:0] ^  syndromeReg_%d [%d:0];\n", (bitSymbol-1), (bitSymbol-1), (syndromeLength-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "         feedbackReg [%d:0] = dataIn[%d:0] ^  syndromeReg_%d [%d:0];\n", (bitSymbol-1), (bitSymbol-1), (syndromeLength-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else begin\n");
//   fprintf(OutFileEncodeTop, "         feedbackReg [%d:0] <=  %d'd0;\n", (bitSymbol-1), bitSymbol);
   fprintf(OutFileEncodeTop, "         feedbackReg [%d:0] =  %d'd0;\n", (bitSymbol-1), bitSymbol);
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");



   //-----------------------------------------------------------------------
   // dataReg syndromeRegFF
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- dataReg syndromeRegFF\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");

   fprintf(OutFileEncodeTop, "   always @(posedge CLK, negedge RESET) begin\n");
   fprintf(OutFileEncodeTop, "      if (~RESET) begin\n");
   fprintf(OutFileEncodeTop, "         dataReg [%d:0] <= %d'd0;\n", (bitSymbol-1), bitSymbol);
   fprintf(OutFileEncodeTop, "         syndromeRegFF  [%d:0] <= %d'd0;\n", (bitSymbol-1), bitSymbol);
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else if (enable == 1'b1) begin\n");
   fprintf(OutFileEncodeTop, "         dataReg [%d:0] <=  dataIn [%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "         syndromeRegFF  [%d:0] <=  syndromeReg_%d [%d:0];\n", (bitSymbol-1), (syndromeLength-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");


   //-----------------------------------------------------------------------
   // wireOut
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- wireOut\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   always @( count, dataReg, syndromeRegFF) begin\n");
//   fprintf(OutFileEncodeTop, "      if (count [%d:0]<= %d'd%d) begin\n", (bitSymbol-1), bitSymbol, DataSize);
   fprintf(OutFileEncodeTop, "      if (count [%d:0]<= %d'd%d) begin\n", (countSize-1), countSize, DataSize);
//   fprintf(OutFileEncodeTop, "         wireOut[%d:0] <= dataReg[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "         wireOut[%d:0] = dataReg[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else begin\n");
//   fprintf(OutFileEncodeTop, "         wireOut[%d:0] <= syndromeRegFF[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "         wireOut[%d:0] = syndromeRegFF[%d:0];\n", (bitSymbol-1), (bitSymbol-1));
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");



   //-----------------------------------------------------------------------
   // dataOutInner
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- dataOutInner\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   reg [%d:0]   dataOutInner;\n", (bitSymbol-1));
   fprintf(OutFileEncodeTop, "   always @(posedge CLK, negedge RESET) begin\n");
   fprintf(OutFileEncodeTop, "      if (~RESET) begin\n");
   fprintf(OutFileEncodeTop, "         dataOutInner <= %d'd0;\n", bitSymbol);
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "      else begin\n");
   fprintf(OutFileEncodeTop, "         dataOutInner <= wireOut;\n");
   fprintf(OutFileEncodeTop, "      end\n");
   fprintf(OutFileEncodeTop, "   end\n");
   fprintf(OutFileEncodeTop, "\n\n\n");


   //-----------------------------------------------------------------------
   // Output ports
   //------------------------------------------------------------------------
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   //- Output ports\n");
   fprintf(OutFileEncodeTop, "   //---------------------------------------------------------------\n");
   fprintf(OutFileEncodeTop, "   assign dataOut = dataOutInner;\n");
   fprintf(OutFileEncodeTop, "\n\n\n");

   fprintf(OutFileEncodeTop, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileEncodeTop);


  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] ttTab;
   delete[] bbTab;
   delete[] ppTab;
   delete[] bidon;


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsEncodeTop, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsEncodeTop);




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
	remove(strRsEncodeTop);
	//Rename the temporary file to the input file.
	rename(temp, strRsEncodeTop);



	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsEncodeTop);


}
