//===================================================================
// Module Name : RsDecodeShiftOmega
// File Name   : RsDecodeShiftOmega.cpp
// Function    : RTL Decoder Shit Omega module generation
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

FILE  *OutFileShiftOmega;


void RsDecodeShiftOmega(int DataSize, int TotalSize, int PrimPoly, int ErasureOption, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   int startPointer;
   int endPointer;
   int ii;
   int jj;
   int index;
   char *strRsDecodeShiftOmega;

   syndromeLength = TotalSize - DataSize;


   //------------------------------------------------------------------------
   // omega shift register core
   //------------------------------------------------------------------------
   if (ErasureOption == 0) {
      startPointer = syndromeLength/2;
   }else{
      startPointer = 0;
   }
   if (ErasureOption == 0){
      endPointer = (syndromeLength/2);
   }else{
      endPointer = syndromeLength;
   }
   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeShiftOmega = (char *)calloc(lengthPath + 26,  sizeof(char));
   if (pathFlag == 0) { 
        strRsDecodeShiftOmega[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeShiftOmega[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeShiftOmega, "/rtl/RsDecodeShiftOmega.v");

   OutFileShiftOmega = fopen(strRsDecodeShiftOmega,"w");



   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileShiftOmega, "//===================================================================\n");
   fprintf(OutFileShiftOmega, "// Module Name : RsDecodeShiftOmega\n");
   fprintf(OutFileShiftOmega, "// File Name   : RsDecodeShiftOmega.v\n");
   fprintf(OutFileShiftOmega, "// Function    : Rs Decoder Shift Omega Module\n");
   fprintf(OutFileShiftOmega, "// \n");
   fprintf(OutFileShiftOmega, "// Revision History:\n");
   fprintf(OutFileShiftOmega, "// Date          By           Version    Change Description\n");
   fprintf(OutFileShiftOmega, "//===================================================================\n");
   fprintf(OutFileShiftOmega, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileShiftOmega, "//\n");
   fprintf(OutFileShiftOmega, "//===================================================================\n");
   fprintf(OutFileShiftOmega, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileShiftOmega, "//\n\n\n");


   fprintf(OutFileShiftOmega, "module RsDecodeShiftOmega(\n");


   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   omega_%d,           // omega polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   omega_%d,          // omega polynom %d\n", ii, ii);
      }
   }




//   fprintf(OutFileShiftOmega, "   numShifted,        // shift amount\n");
/*   for(ii=0; ii<(syndromeLength-1); ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   omegaShifted_%d,    // omega shifted polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   omegaShifted_%d,   // omega shifted polynom %d\n", ii, ii);
      }
   }
   if ((syndromeLength-1) < 10){
         fprintf(OutFileShiftOmega, "   omegaShifted_%d     // omega shifted polynom %d\n", (syndromeLength-1), (syndromeLength-1));
   }else{   
         fprintf(OutFileShiftOmega, "   omegaShifted_%d    // omega shifted polynom %d\n", (syndromeLength-1), (syndromeLength-1));
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   omegaShifted_%d,    // omega shifted polynom %d\n", ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   omegaShifted_%d,   // omega shifted polynom %d\n", ii, ii);
      }
   }

   fprintf(OutFileShiftOmega, "   numShifted         // shift amount\n");


   fprintf(OutFileShiftOmega, ");\n\n\n");

/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   input [%d:0] omega_%d;            // omega polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   input [%d:0] omega_%d;           // omega polynom %d\n", bitSymbol-1, ii, ii);
      }
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   input [%d:0] omega_%d;            // omega polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   input [%d:0] omega_%d;           // omega polynom %d\n", bitSymbol-1, ii, ii);
      }
   }


   if (syndromeLength > 2047) {
      fprintf(OutFileShiftOmega, "   input [11:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 1023) {
      fprintf(OutFileShiftOmega, "   input [10:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 511) {
      fprintf(OutFileShiftOmega, "   input [9:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 255) {
      fprintf(OutFileShiftOmega, "   input [8:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 127) {
      fprintf(OutFileShiftOmega, "   input [7:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 63) {
      fprintf(OutFileShiftOmega, "   input [6:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 31) {
      fprintf(OutFileShiftOmega, "   input [5:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 15) {
      fprintf(OutFileShiftOmega, "   input [4:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 7) {
      fprintf(OutFileShiftOmega, "   input [3:0] numShifted;         // shift amount\n\n");
   }
   else if (syndromeLength > 3) {
      fprintf(OutFileShiftOmega, "   input [2:0] numShifted;         // shift amount\n\n");
   }
   else {
      fprintf(OutFileShiftOmega, "   input [1:0] numShifted;         // shift amount\n\n");
   }


/*   for(ii=0; ii<syndromeLength; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   output [%d:0] omegaShifted_%d;    // omega shifted polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   output [%d:0] omegaShifted_%d;   // omega shifted polynom %d\n", bitSymbol-1, ii, ii);
      }
   }*/
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   output [%d:0] omegaShifted_%d;    // omega shifted polynom %d\n", bitSymbol-1, ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   output [%d:0] omegaShifted_%d;   // omega shifted polynom %d\n", bitSymbol-1, ii, ii);
      }
   }

   fprintf(OutFileShiftOmega, "\n\n\n");


   //------------------------------------------------------------------------
   //+ omegaShifted_0 ... omegaShifted_xxx
   //- omegaShifted registers
   //------------------------------------------------------------------------
   fprintf(OutFileShiftOmega, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileShiftOmega, "   //+ omegaShifted_0,..., omegaShifted_%d\n", syndromeLength-1);
   fprintf(OutFileShiftOmega, "   //- omegaShifted registers\n");
   fprintf(OutFileShiftOmega, "   //------------------------------------------------------------------------\n");
/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileShiftOmega, "   reg [%d:0]   omegaShiftedInner_%d;\n", bitSymbol-1, ii);
   }*/
   for(ii=0; ii<endPointer; ii++){
      fprintf(OutFileShiftOmega, "   reg [%d:0]   omegaShiftedInner_%d;\n", bitSymbol-1, ii);
   }


   fprintf(OutFileShiftOmega, "\n\n");

   fprintf(OutFileShiftOmega, "   always @ (numShifted");
/*   for(ii=0; ii<syndromeLength; ii++){
      fprintf(OutFileShiftOmega, " or omega_%d", ii);
   }*/
   for(ii=startPointer; ii<syndromeLength; ii++){
      fprintf(OutFileShiftOmega, " or omega_%d", ii);
   }
   fprintf(OutFileShiftOmega, " ) begin\n");
   fprintf(OutFileShiftOmega, "      case (numShifted)\n");







   //------------------------------------------------------------------------
   // omega shift register core
   //------------------------------------------------------------------------
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=startPointer; ii<syndromeLength; ii++){
      if (syndromeLength > 2047) {
         fprintf(OutFileShiftOmega, "         (12'd%d): begin\n", ii);
      }
      else if (syndromeLength > 1023) {
         fprintf(OutFileShiftOmega, "         (11'd%d): begin\n", ii);
      }
      else if (syndromeLength > 511) {
         fprintf(OutFileShiftOmega, "         (10'd%d): begin\n", ii);
      }
      else if (syndromeLength > 255) {
         fprintf(OutFileShiftOmega, "         (9'd%d): begin\n", ii);
      }
      else if (syndromeLength > 127) {
         fprintf(OutFileShiftOmega, "         (8'd%d): begin\n", ii);
      }
      else if (syndromeLength > 63) {
         fprintf(OutFileShiftOmega, "         (7'd%d): begin\n", ii);
      }
      else if (syndromeLength > 31) {
         fprintf(OutFileShiftOmega, "         (6'd%d): begin\n", ii);
      }
      else if (syndromeLength > 15) {
         fprintf(OutFileShiftOmega, "         (5'd%d): begin\n", ii);
      }
      else if (syndromeLength > 7) {
         fprintf(OutFileShiftOmega, "         (4'd%d): begin\n", ii);
      }
      else if (syndromeLength > 3) {
         fprintf(OutFileShiftOmega, "         (3'd%d): begin\n", ii);
      }
      else {
         fprintf(OutFileShiftOmega, "         (2'd%d): begin\n", ii);
      }

      index = ii;
//      for(jj=0; jj<syndromeLength; jj++){
      for(jj=0; jj<endPointer; jj++){
         if (jj < 10){
            fprintf(OutFileShiftOmega, "            omegaShiftedInner_%d [%d:0]  = ", jj, bitSymbol-1);
         }else{
            fprintf(OutFileShiftOmega, "            omegaShiftedInner_%d [%d:0] = ", jj, bitSymbol-1);
         }
         if (index < syndromeLength) {
            fprintf(OutFileShiftOmega, "omega_%d", index);
            fprintf(OutFileShiftOmega, " [%d:0];\n", bitSymbol-1);
            index ++;
         }else{
            fprintf(OutFileShiftOmega, "%d'd0;\n",bitSymbol);
         }
      }
      fprintf(OutFileShiftOmega, "         end\n", ii);
   }


   fprintf(OutFileShiftOmega, "         default: begin\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "            omegaShiftedInner_%d [%d:0]  = %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }else{
         fprintf(OutFileShiftOmega, "            omegaShiftedInner_%d [%d:0] = %d'd0;\n", ii, bitSymbol-1, bitSymbol);
      }
   }

   fprintf(OutFileShiftOmega, "         end\n");
   fprintf(OutFileShiftOmega, "        endcase\n");
   fprintf(OutFileShiftOmega, "    end\n");
   fprintf(OutFileShiftOmega, "\n\n\n");


  //---------------------------------------------------------------
  // Output Ports
  //---------------------------------------------------------------
   fprintf(OutFileShiftOmega, "   //------------------------------------------------------------------------\n");
   fprintf(OutFileShiftOmega, "   //- Output Ports\n");
   fprintf(OutFileShiftOmega, "   //------------------------------------------------------------------------\n");
//   for(ii=0; ii<syndromeLength; ii++){
   for(ii=0; ii<endPointer; ii++){
      if (ii < 10){
         fprintf(OutFileShiftOmega, "   assign omegaShifted_%d   = omegaShiftedInner_%d;\n", ii, ii);
      }else{
         fprintf(OutFileShiftOmega, "   assign omegaShifted_%d  = omegaShiftedInner_%d;\n", ii, ii);
      }
   }
   fprintf(OutFileShiftOmega, "\n\n\n");
   fprintf(OutFileShiftOmega, "endmodule\n");


  //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileShiftOmega);


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeShiftOmega, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeShiftOmega);
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
	remove(strRsDecodeShiftOmega);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeShiftOmega);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeShiftOmega);


}
