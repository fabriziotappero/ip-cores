//===================================================================
// Module Name : RsDecodeDegree
// File Name   : RsDecodeDegree.cpp
// Function    : RTL Decoder Degree Module generation
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


FILE  *OutFileDegree;


void RsDecodeDegree(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int ErasureOption, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int ii;
   int degreeOrder;
   int stopPointer;
   int comparator;
   char *strRsDecodeDegree;
   syndromeLength = TotalSize - DataSize;


   if (ErasureOption == 0)
   {
      stopPointer = (syndromeLength/2)+1;
      comparator = syndromeLength/2;
   }else{
      stopPointer = syndromeLength;
      comparator = syndromeLength;
   }

   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeDegree = (char *)calloc(lengthPath + 22,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeDegree[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeDegree[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeDegree, "/rtl/RsDecodeDegree.v");

   OutFileDegree = fopen(strRsDecodeDegree,"w");



   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDegree, "//===================================================================\n");
   fprintf(OutFileDegree, "// Module Name : RsDecodeDegree\n");
   fprintf(OutFileDegree, "// File Name   : RsDecodeDegree.v\n");
   fprintf(OutFileDegree, "// Function    : Rs Decoder Degree Module\n");
   fprintf(OutFileDegree, "// \n");
   fprintf(OutFileDegree, "// Revision History:\n");
   fprintf(OutFileDegree, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDegree, "//===================================================================\n");
   fprintf(OutFileDegree, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDegree, "//\n");
   fprintf(OutFileDegree, "//===================================================================\n");
   fprintf(OutFileDegree, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDegree, "//\n\n\n");

   fprintf(OutFileDegree, "module RsDecodeDegree(\n");

//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<stopPointer; ii++){
      fprintf(OutFileDegree, "   polynom_%d,\n", ii);
   }
   fprintf(OutFileDegree, "   degree\n");
   fprintf(OutFileDegree, ");\n\n\n");


//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<stopPointer; ii++){
      if (ii < 10) {
         fprintf(OutFileDegree, "   input  [%d:0]   polynom_%d;    // polynom %d\n",bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileDegree, "   input  [%d:0]   polynom_%d;   // polynom %d\n",bitSymbol-1, ii, ii);
      }
   }
   
   
   int degreeIdx;


//   if (syndromeLength > 2047) {
   if (comparator > 2047) {
      fprintf(OutFileDegree, "   output [11:0]   degree;       // polynom degree\n");
      degreeIdx = 12;
   }
//   else if (syndromeLength > 1023) {
   else if (comparator > 1023) {
      fprintf(OutFileDegree, "   output [10:0]   degree;       // polynom degree\n");
      degreeIdx = 11;
   }
//   else if (syndromeLength > 511) {
   else if (comparator > 511) {
      fprintf(OutFileDegree, "   output [9:0]   degree;       // polynom degree\n");
      degreeIdx = 10;
   }
//   else if (syndromeLength > 255) {
   else if (comparator > 255) {
      fprintf(OutFileDegree, "   output [8:0]   degree;       // polynom degree\n");
      degreeIdx = 9;
   }
//   else if (syndromeLength > 127) {
   else if (comparator > 127) {
      fprintf(OutFileDegree, "   output [7:0]   degree;       // polynom degree\n");
      degreeIdx = 8;
   }
//   else if (syndromeLength > 63) {
   else if (comparator > 63) {
      fprintf(OutFileDegree, "   output [6:0]   degree;       // polynom degree\n");
      degreeIdx = 7;
   }
//   else if (syndromeLength > 31) {
   else if (comparator > 31) {
      fprintf(OutFileDegree, "   output [5:0]   degree;       // polynom degree\n");
      degreeIdx = 6;
   }
//   else if (syndromeLength > 15) {
   else if (comparator > 15) {
      fprintf(OutFileDegree, "   output [4:0]   degree;       // polynom degree\n");
      degreeIdx = 5;
   }
//   else if (syndromeLength > 7) {
   else if (comparator > 7) {
      fprintf(OutFileDegree, "   output [3:0]   degree;       // polynom degree\n");
      degreeIdx = 4;
   }
//   else if (syndromeLength > 3) {
   else if (comparator > 3) {
      fprintf(OutFileDegree, "   output [2:0]   degree;       // polynom degree\n");
      degreeIdx = 3;
   }
   else {
      fprintf(OutFileDegree, "   output [1:0]   degree;       // polynom degree\n");
      degreeIdx = 2;
   }
   fprintf(OutFileDegree, "\n\n\n");


   //------------------------------------------------------------------------
   //- registers
   //------------------------------------------------------------------------
   fprintf(OutFileDegree, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDegree, "   //- registers\n");
   fprintf(OutFileDegree, "   //------------------------------------------------------------------------\n");

 /*  if (syndromeLength > 2047) {
      fprintf(OutFileDegree, "   reg  [11:0]   degree;\n");
      degreeOrder = 12;
   }
   else if (syndromeLength > 1023) {
      fprintf(OutFileDegree, "   reg  [10:0]   degree;\n");
      degreeOrder = 11;
   }
   else if (syndromeLength > 511) {
      fprintf(OutFileDegree, "   reg  [9:0]   degree;\n");
      degreeOrder = 10;
   }
   else if (syndromeLength > 255) {
      fprintf(OutFileDegree, "   reg  [8:0]   degree;\n");
      degreeOrder = 9;
   }
   else if (syndromeLength > 127) {
      fprintf(OutFileDegree, "   reg  [7:0]   degree;\n");
      degreeOrder = 8;
   }
   else if (syndromeLength > 63) {
      fprintf(OutFileDegree, "   reg  [6:0]   degree;\n");
      degreeOrder = 7;
   }
   else if (syndromeLength > 31) {
      fprintf(OutFileDegree, "   reg  [5:0]   degree;\n");
      degreeOrder = 6;
   }
   else if (syndromeLength > 15) {
      fprintf(OutFileDegree, "   reg  [4:0]   degree;\n");
      degreeOrder = 5;
   }
   else if (syndromeLength > 7) {
      fprintf(OutFileDegree, "   reg  [3:0]   degree;\n");
      degreeOrder = 4;
   }
   else if (syndromeLength > 3) {
      fprintf(OutFileDegree, "   reg  [2:0]   degree;\n");
      degreeOrder = 3;
   }
   else {
      fprintf(OutFileDegree, "   reg  [1:0]   degree;\n");
      degreeOrder = 2;
   }

   for(ii=1; ii<syndromeLength; ii++){
      fprintf(OutFileDegree, "   wire         flag%d;\n", ii);
   }
   fprintf(OutFileDegree, "\n\n");
   for(ii=1; ii<syndromeLength; ii++){
      fprintf(OutFileDegree, "   assign flag%d = (polynom_%d [%d:0] == %d'd0) ? 1'b0 : 1'b1;\n", ii, ii,bitSymbol-1,bitSymbol);
   }
   fprintf(OutFileDegree, "\n\n\n");


   //------------------------------------------------------------------------
   //- degree
   //------------------------------------------------------------------------
   fprintf(OutFileDegree, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileDegree, "   //- degree\n");
   fprintf(OutFileDegree, "   //------------------------------------------------------------------------\n");

   fprintf(OutFileDegree, "    always @ ( flag1");
   if (syndromeLength > 2) {
      for(ii=2; ii<syndromeLength; ii++){
         fprintf(OutFileDegree, ", flag%d", ii);
      }
   }

   fprintf(OutFileDegree, " ) begin\n");

   //------------------------------------------------------------------------
   //------------------------------------------------------------------------
   fprintf(OutFileDegree, "      if((flag%d==1'b0)", syndromeLength/2);
   for(ii=((syndromeLength/2)+1); ii<syndromeLength; ii++){
      fprintf(OutFileDegree, " && (flag%d==1'b0)", ii);
   }
   fprintf(OutFileDegree, " ) begin\n");



   //------------------------------------------------------------------------
   //------------------------------------------------------------------------
   if ((syndromeLength/2)-1 > 0) {
      fprintf(OutFileDegree, "         if (flag%d==1'b1) begin\n", (syndromeLength/2)-1);
   }
   else {
      fprintf(OutFileDegree, "         if (flag%d==1'b1) begin\n", 1);
   }

   fprintf(OutFileDegree, "            degree <= %d'd%d;\n", degreeOrder,(syndromeLength/2)-1);
   fprintf(OutFileDegree, "         end\n");


   //------------------------------------------------------------------------
   //------------------------------------------------------------------------
   for(ii=((syndromeLength/2)-2); ii>0; ii--){
      fprintf(OutFileDegree, "         else\n");
      fprintf(OutFileDegree, "         if (flag%d==1'b1) begin\n", ii);
      fprintf(OutFileDegree, "            degree <= %d'd%d;\n",degreeOrder, ii);
      fprintf(OutFileDegree, "         end\n");
   }
   fprintf(OutFileDegree, "         else begin\n");
   fprintf(OutFileDegree, "            degree <= %d'd0;\n", degreeOrder);
   fprintf(OutFileDegree, "         end\n");
   fprintf(OutFileDegree, "      end\n");
   fprintf(OutFileDegree, "      else begin\n");
   fprintf(OutFileDegree, "         if (flag%d==1'b1) begin\n", (syndromeLength-1));
   fprintf(OutFileDegree, "            degree <= %d'd%d;\n", degreeOrder, syndromeLength-1);
   fprintf(OutFileDegree, "         end\n");



   //------------------------------------------------------------------------
   //------------------------------------------------------------------------
   if (((syndromeLength)-2) > (syndromeLength/2)) {
      for(ii=((syndromeLength)-2); ii>(syndromeLength/2); ii--){
         fprintf(OutFileDegree, "         else\n");
         fprintf(OutFileDegree, "         if (flag%d==1'b1) begin\n", ii);
         fprintf(OutFileDegree, "            degree <= %d'd%d;\n", degreeOrder, ii);
         fprintf(OutFileDegree, "         end\n");
      }
   }
   fprintf(OutFileDegree, "         else begin\n");
   fprintf(OutFileDegree, "            degree <= %d'd%d;\n", degreeOrder, (syndromeLength/2));
   fprintf(OutFileDegree, "         end\n");
   fprintf(OutFileDegree, "      end\n");
   fprintf(OutFileDegree, "   end\n");
*/


   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   int ChallengerNb;
   int LoopCount;
   LoopCount = 0;
   ChallengerNb = syndromeLength;
   int oddFlag;
   oddFlag = 0;
   


   if (ErasureOption == 0) {
      ChallengerNb = (syndromeLength/2)+ 1;
   }else{
      ChallengerNb = syndromeLength;
   }


   int *WinnerIdx;
   int *StepIdx;
   int *NextWinnerIdx;
   int *NextStepIdx;
   int LastStep;
   int LastIdx;
   
   LastStep = 0;
   LastIdx  = 0;
   
   WinnerIdx     = new int [syndromeLength];
   StepIdx       = new int [syndromeLength];
   NextWinnerIdx = new int [syndromeLength];
   NextStepIdx   = new int [syndromeLength];

   for(ii=0; ii<syndromeLength; ii++){
      WinnerIdx     [ii] = 0;
      StepIdx       [ii] = 0;
      NextWinnerIdx [ii] = 0;
      NextStepIdx   [ii] = 0;
   }

   while (ChallengerNb > 1) {

      fprintf(OutFileDegree, "//---------------------------------------------------------------\n");
      fprintf(OutFileDegree, "//- step %d\n", LoopCount);
//      for(ii=0; ii<syndromeLength; ii++){
//         fprintf(OutFileDegree, "//winner%dStep%d \n", WinnerIdx [ii], StepIdx   [ii]);
//      }
//      for(ii=0; ii<syndromeLength; ii++){
//         fprintf(OutFileDegree, "//Nextwinner%dStep%d \n", NextWinnerIdx [ii], NextStepIdx   [ii]);
//      }
      fprintf(OutFileDegree, "//---------------------------------------------------------------\n");


      //---------------------------------------------------------------
      //
      //---------------------------------------------------------------
      if (LoopCount == 0){
         if (ErasureOption == 1) {
            for(ii=0; ii<(syndromeLength/2); ii++){
               fprintf(OutFileDegree, "wire [%d:0]   winner%dStep%d;\n", degreeIdx-1, ii, LoopCount);
               fprintf(OutFileDegree, "assign winner%dStep%d =", ii, LoopCount);
               fprintf(OutFileDegree, "(polynom_%d [%d:0] == %d'd0) ? ", (ii*2)+1,bitSymbol-1,bitSymbol );
               fprintf(OutFileDegree, "((polynom_%d [%d:0] == %d'd0) ? %d'd0 : %d'd%d)", (ii*2),bitSymbol-1,bitSymbol, degreeIdx,degreeIdx, ii*2 );
               fprintf(OutFileDegree, ":  %d'd%d;\n", degreeIdx,(ii*2)+1 );
            
               LastStep = ii;
               LastIdx  = LoopCount;

               WinnerIdx [ii] = ii;
               StepIdx   [ii] = LoopCount;
            }
         }else{
            for(ii=0; ii<(syndromeLength/4); ii++){
               fprintf(OutFileDegree, "wire [%d:0]   winner%dStep%d;\n", degreeIdx-1, ii, LoopCount);
               fprintf(OutFileDegree, "assign winner%dStep%d =", ii, LoopCount);
               fprintf(OutFileDegree, "(polynom_%d [%d:0] == %d'd0) ? ", (ii*2)+1,bitSymbol-1,bitSymbol );
               fprintf(OutFileDegree, "((polynom_%d [%d:0] == %d'd0) ? %d'd0 : %d'd%d)", (ii*2),bitSymbol-1,bitSymbol, degreeIdx,degreeIdx, ii*2 );
               fprintf(OutFileDegree, ":  %d'd%d;\n", degreeIdx,(ii*2)+1 );
            
               LastStep = ii;
               LastIdx  = LoopCount;

               WinnerIdx [ii] = ii;
               StepIdx   [ii] = LoopCount;
            }
               fprintf(OutFileDegree, "wire [%d:0]   winner%dStep%d;\n", degreeIdx-1, (syndromeLength/4), LoopCount);
               fprintf(OutFileDegree, "assign winner%dStep%d =", (syndromeLength/4), LoopCount);
               if ( ((ii*2)) < (syndromeLength/2)){
                  fprintf(OutFileDegree, "(polynom_%d [%d:0] == %d'd0) ? ", (ii*2)+1,bitSymbol-1,bitSymbol );
                  fprintf(OutFileDegree, "((polynom_%d [%d:0] == %d'd0) ? %d'd0 : %d'd%d)", (ii*2),bitSymbol-1,bitSymbol, degreeIdx,degreeIdx, ii*2 );
               fprintf(OutFileDegree, ":  %d'd%d;\n", degreeIdx,(ii*2)+1 );
               }else{
//                  fprintf(OutFileDegree, "(polynom_%d [%d:0] == %d'd0) ? %d'd0 : %d'd%d;\n", (syndromeLength/2),bitSymbol-1,bitSymbol , bitSymbol, degreeIdx, (syndromeLength/2));
                  fprintf(OutFileDegree, "(polynom_%d [%d:0] == %d'd0) ? %d'd0 : %d'd%d;\n", (syndromeLength/2),bitSymbol-1,bitSymbol , degreeIdx, degreeIdx, (syndromeLength/2));
               }
               LastStep = (syndromeLength/4);
               LastIdx  = LoopCount;

               WinnerIdx [(syndromeLength/4)] = ii;
               StepIdx   [(syndromeLength/4)] = LoopCount;
            
         }
      }
      //---------------------------------------------------------------
      //---------------------------------------------------------------
      else{
         for(ii=0; ii<(ChallengerNb/2); ii++){
            fprintf(OutFileDegree, "wire [%d:0]   winner%dStep%d;\n", degreeIdx-1, ii, LoopCount);
            fprintf(OutFileDegree, "assign winner%dStep%d =", ii, LoopCount);
            fprintf(OutFileDegree, "( winner%dStep%d [%d:0] < winner%dStep%d  [%d:0]) ? ", WinnerIdx[(ii*2)+1], StepIdx[(ii*2)+1],degreeIdx-1, WinnerIdx[(ii*2)], StepIdx[(ii*2)],degreeIdx-1);
            fprintf(OutFileDegree, "winner%dStep%d  [%d:0]", WinnerIdx[(ii*2)], StepIdx[(ii*2)],degreeIdx-1);
            fprintf(OutFileDegree, ":  winner%dStep%d  [%d:0];\n", WinnerIdx[(ii*2)+1], StepIdx[(ii*2)+1] ,degreeIdx-1);
            
            NextWinnerIdx [ii] = ii;
            NextStepIdx   [ii] = LoopCount;
            LastStep = ii;
            LastIdx  = LoopCount;
         }
      


      //---------------------------------------------------------------
      //---------------------------------------------------------------
      if (ChallengerNb % 2 == 0){
         for(ii=0; ii<syndromeLength; ii++){
            WinnerIdx [ii] = 0;
            StepIdx   [ii] = 0;
         }
         for(ii=0; ii<syndromeLength; ii++){
            WinnerIdx [ii] = NextWinnerIdx [ii];
            StepIdx   [ii] = NextStepIdx   [ii];
         }
         for(ii=0; ii<syndromeLength; ii++){
            NextWinnerIdx [ii] = 0;
            NextStepIdx   [ii] = 0;
         }
      }else{
      //---------------------------------------------------------------
      //---------------------------------------------------------------
            NextWinnerIdx [ChallengerNb/2] = WinnerIdx [ChallengerNb-1];
            NextStepIdx   [ChallengerNb/2] = StepIdx   [ChallengerNb-1];
            
            
            for(ii=0; ii<syndromeLength; ii++){
               WinnerIdx [ii] = 0;
               StepIdx   [ii] = 0;
            }
            for(ii=0; ii<syndromeLength; ii++){
              WinnerIdx [ii] = NextWinnerIdx [ii];
              StepIdx   [ii] = NextStepIdx   [ii];
            }
            for(ii=0; ii<syndromeLength; ii++){
               NextWinnerIdx [ii] = 0;
               NextStepIdx   [ii] = 0;
            }
         
      }

      }

      
      
      //---------------------------------------------------------------
      // Challenger Nb update
      //---------------------------------------------------------------
      if (ChallengerNb % 2 == 0){
         ChallengerNb = ChallengerNb/2;
      }else{
         ChallengerNb = ((ChallengerNb-1)/2)+1;
         oddFlag = 1;
      }
      LoopCount +=1;
      
   }



   fprintf(OutFileDegree, "//---------------------------------------------------------------\n");
   fprintf(OutFileDegree, "//---------------------------------------------------------------\n");

/*
   if (syndromeLength > 2047) {
      fprintf(OutFileDegree, "   wire  [11:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 1023) {
      fprintf(OutFileDegree, "   wire  [10:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 511) {
      fprintf(OutFileDegree, "   wire  [9:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 255) {
      fprintf(OutFileDegree, "   wire  [8:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 127) {
      fprintf(OutFileDegree, "   wire  [7:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 63) {
      fprintf(OutFileDegree, "   wire  [6:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 31) {
      fprintf(OutFileDegree, "   wire  [5:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 15) {
      fprintf(OutFileDegree, "   wire  [4:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 7) {
      fprintf(OutFileDegree, "   wire  [3:0]   degreeBETA;\n");
   }
   else if (syndromeLength > 3) {
      fprintf(OutFileDegree, "   wire  [2:0]   degreeBETA;\n");
   }
   else {
      fprintf(OutFileDegree, "   wire  [1:0]   degreeBETA;\n");
   }   
   */
//    fprintf(OutFileDegree, "assign degreeBETA [%d:0] =  winner%dStep%d [%d:0] ;\n", degreeIdx-1, LastStep, LastIdx, degreeIdx-1);
    fprintf(OutFileDegree, "assign degree [%d:0] =  winner%dStep%d [%d:0] ;\n", degreeIdx-1, LastStep, LastIdx, degreeIdx-1);
   


   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //---------------------------------------------------------------
   fprintf(OutFileDegree, "\n\n\n");
   fprintf(OutFileDegree, "endmodule\n");


   //---------------------------------------------------------------
   // close file
   //---------------------------------------------------------------
   fclose(OutFileDegree);


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeDegree, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeDegree);
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
	remove(strRsDecodeDegree);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeDegree);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeDegree);


}
