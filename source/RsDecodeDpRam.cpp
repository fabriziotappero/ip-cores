//===================================================================
// Module Name : RsDecodeDpRam
// File Name   : RsDecodeDpRam.cpp
// Function    : RTL Decoder DpRam Module generation
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

FILE  *OutFileDpRam;

void RsDecodeDpRam(int DataSize, int TotalSize, int PrimPoly, int ErasureOption, int bitSymbol, int pathFlag, int lengthPath, char *rootFolderPath) {


   //---------------------------------------------------------------
   // C++ variables
   //---------------------------------------------------------------
   int syndromeLength;
   syndromeLength = TotalSize - DataSize;

   int ii;
   int Delay;
   int *euclideTab;
   char *strRsDecodeDpRam;

   euclideTab    =new int[(syndromeLength+1)];


   //---------------------------------------------------------------
   // open file
   //---------------------------------------------------------------
   strRsDecodeDpRam = (char *)calloc(lengthPath + 21,  sizeof(char));
   if (pathFlag == 0) {
        strRsDecodeDpRam[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strRsDecodeDpRam[ii] = rootFolderPath[ii];
      }
   }
   strcat(strRsDecodeDpRam, "/rtl/RsDecodeDpRam.v");

   OutFileDpRam = fopen(strRsDecodeDpRam,"w");


   //---------------------------------------------------------------
  // euclideTab calculation
  //---------------------------------------------------------------
   euclideTab [syndromeLength] = 3;
   euclideTab [syndromeLength-1] = 3;

   for(ii=(syndromeLength-2); ii>0; ii=ii-2){
      euclideTab [ii] = euclideTab   [ii+2] + 6;
      euclideTab [ii-1] = euclideTab [ii+1] + 6;
   }

   euclideTab [0] = euclideTab [2] + 6;   


   //---------------------------------------------------------------
   // Delay calculation
   //---------------------------------------------------------------
   if (ErasureOption == 1) {
      Delay = TotalSize + syndromeLength + 1 + euclideTab [0] + 5;
   }else{
      Delay = TotalSize + euclideTab [0] + 5;
   }


   //---------------------------------------------------------------
   // Write Header File
   //---------------------------------------------------------------
//   fprintf(OutFileDpRam, "// $Id: $\n");
//   fprintf(OutFileDpRam, "//=================================================================\n");
//   fprintf(OutFileDpRam, "// Project Name: MyRS\n");
//   fprintf(OutFileDpRam, "// File Name   : RsDecodeDpRam.v\n");
//   fprintf(OutFileDpRam, "// Function    : RS Memory\n");
//   fprintf(OutFileDpRam, "//=================================================================\n\n\n");

   fprintf(OutFileDpRam, "//===================================================================\n");
   fprintf(OutFileDpRam, "// Module Name : RsDecodeDpRam\n");
   fprintf(OutFileDpRam, "// File Name   : RsDecodeDpRam.v\n");
   fprintf(OutFileDpRam, "// Function    : Rs Decoder DpRam Memory Module\n");
   fprintf(OutFileDpRam, "// \n");
   fprintf(OutFileDpRam, "// Revision History:\n");
   fprintf(OutFileDpRam, "// Date          By           Version    Change Description\n");
   fprintf(OutFileDpRam, "//===================================================================\n");
   fprintf(OutFileDpRam, "// 2009/02/03  Gael Sapience     1.0       Original\n");
   fprintf(OutFileDpRam, "//\n");
   fprintf(OutFileDpRam, "//===================================================================\n");
   fprintf(OutFileDpRam, "// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.\n");
   fprintf(OutFileDpRam, "//\n\n\n");

   //---------------------------------------------------------------
   // Ports Declaration
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "module RsDecodeDpRam (/*AUTOARG*/\n");
   fprintf(OutFileDpRam, "   // Outputs\n");
   fprintf(OutFileDpRam, "   q,\n");
   fprintf(OutFileDpRam, "   // Inputs\n");
   fprintf(OutFileDpRam, "   clock,\n");
   fprintf(OutFileDpRam, "   data,\n");
   fprintf(OutFileDpRam, "   rdaddress,\n");
   fprintf(OutFileDpRam, "   rden,\n");
   fprintf(OutFileDpRam, "   wraddress,\n");
   fprintf(OutFileDpRam, "   wren\n");
   fprintf(OutFileDpRam, "   );\n");
   fprintf(OutFileDpRam,"\n");


   //---------------------------------------------------------------
   // I/O instantiation
   //---------------------------------------------------------------
   if (ErasureOption == 1) {
      fprintf(OutFileDpRam, "   output [%d:0]   q;\n", bitSymbol);
   }else{
      fprintf(OutFileDpRam, "   output [%d:0]   q;\n", bitSymbol-1);
   }


   fprintf(OutFileDpRam, "   input          clock;\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDpRam, "   input  [%d:0]   data;\n", bitSymbol);
   }else{
      fprintf(OutFileDpRam, "   input  [%d:0]   data;\n", bitSymbol-1);
   }


   if (Delay < 4) {
      fprintf(OutFileDpRam, "   input  [1:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [1:0]   wraddress;\n");
   }
   if (Delay < 8) {
      fprintf(OutFileDpRam, "   input  [2:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [2:0]   wraddress;\n");
   }
   if (Delay < 16) {
      fprintf(OutFileDpRam, "   input  [3:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [3:0]   wraddress;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDpRam, "   input  [4:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [4:0]   wraddress;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDpRam, "   input  [5:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [5:0]   wraddress;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDpRam, "   input  [6:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [6:0]   wraddress;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDpRam, "   input  [7:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [7:0]   wraddress;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDpRam, "   input  [8:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [8:0]   wraddress;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDpRam, "   input  [9:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [9:0]   wraddress;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDpRam, "   input  [10:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [10:0]   wraddress;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDpRam, "   input  [11:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [11:0]   wraddress;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDpRam, "   input  [12:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [12:0]   wraddress;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDpRam, "   input  [13:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [13:0]   wraddress;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDpRam, "   input  [14:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [14:0]   wraddress;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDpRam, "   input  [15:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [15:0]   wraddress;\n");
   }
   else{
      fprintf(OutFileDpRam, "   input  [16:0]   rdaddress;\n");
      fprintf(OutFileDpRam, "   input  [16:0]   wraddress;\n");
   }

   fprintf(OutFileDpRam, "   input          rden;\n");
   fprintf(OutFileDpRam, "   input          wren;\n");
   fprintf(OutFileDpRam,"\n\n\n");


   //---------------------------------------------------------------
   // + mem
   //- DpRam memory
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   fprintf(OutFileDpRam, "    // + mem\n");
   fprintf(OutFileDpRam, "    //  - DpRam Memory\n");
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDpRam, "   reg [%d:0]   mem[0:%d];\n", bitSymbol, (Delay -1));
   }else{
      fprintf(OutFileDpRam, "   reg [%d:0]   mem[0:%d];\n", bitSymbol-1 , (Delay -1));
   }


   //---------------------------------------------------------------
   //- DpRam write process
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "    always@(posedge clock) begin\n");
   fprintf(OutFileDpRam, "       if (wren)\n");
   fprintf(OutFileDpRam, "         mem[wraddress] <= data;\n");
   fprintf(OutFileDpRam, "    end\n");
   fprintf(OutFileDpRam,"\n\n\n");


   //---------------------------------------------------------------
   // + rRdAddr
   //- Read Address register
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   fprintf(OutFileDpRam, "    // + rRdAddr\n");
   fprintf(OutFileDpRam, "    //  - Read Address register\n");
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");

   if (Delay < 4) {
      fprintf(OutFileDpRam, "    reg [1:0] rRdAddr;\n");
   }
   else if (Delay < 8) {
      fprintf(OutFileDpRam, "    reg [2:0] rRdAddr;\n");
   }
   else if (Delay < 16) {
      fprintf(OutFileDpRam, "    reg [3:0] rRdAddr;\n");
   }
   else if (Delay < 32) {
      fprintf(OutFileDpRam, "    reg [4:0] rRdAddr;\n");
   }
   else if (Delay < 64) {
      fprintf(OutFileDpRam, "    reg [5:0] rRdAddr;\n");
   }
   else if (Delay < 128) {
      fprintf(OutFileDpRam, "    reg [6:0] rRdAddr;\n");
   }
   else if (Delay < 256) {
      fprintf(OutFileDpRam, "    reg [7:0] rRdAddr;\n");
   }
   else if (Delay < 512) {
      fprintf(OutFileDpRam, "    reg [8:0] rRdAddr;\n");
   }
   else if  (Delay < 1024) {
      fprintf(OutFileDpRam, "    reg [9:0] rRdAddr;\n");
   }
   else if  (Delay < 2048) {
      fprintf(OutFileDpRam, "    reg [10:0] rRdAddr;\n");
   }
   else if  (Delay < 4096) {
      fprintf(OutFileDpRam, "    reg [11:0] rRdAddr;\n");
   }
   else if  (Delay < 8192) {
      fprintf(OutFileDpRam, "    reg [12:0] rRdAddr;\n");
   }
   else if  (Delay < 16384) {
      fprintf(OutFileDpRam, "    reg [13:0] rRdAddr;\n");
   }
   else if  (Delay < 32768) {
      fprintf(OutFileDpRam, "    reg [14:0] rRdAddr;\n");
   }
   else if  (Delay < 65536) {
      fprintf(OutFileDpRam, "    reg [15:0] rRdAddr;\n");
   }
   else{     
      fprintf(OutFileDpRam, "    reg [16:0] rRdAddr;\n");
   }

   fprintf(OutFileDpRam, "    always@(posedge clock) begin\n");
   fprintf(OutFileDpRam, "       rRdAddr <= rdaddress;\n");
   fprintf(OutFileDpRam, "    end\n");
   fprintf(OutFileDpRam,"\n\n\n");



   //---------------------------------------------------------------
   // + rRdEn
   //- Read enable register
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   fprintf(OutFileDpRam, "    // + rRdEn\n");
   fprintf(OutFileDpRam, "    //  - リードイネーブ?\n");
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   fprintf(OutFileDpRam, "    reg  rRdEn;\n");
   fprintf(OutFileDpRam, "    always@(posedge clock) begin\n");
   fprintf(OutFileDpRam, "       rRdEn <= rden;\n");
   fprintf(OutFileDpRam, "    end\n");
   fprintf(OutFileDpRam,"\n\n\n");


   //---------------------------------------------------------------
   // + q
   //- Read data register
   //---------------------------------------------------------------
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   fprintf(OutFileDpRam, "    // + q\n");
   fprintf(OutFileDpRam, "    //  - リード処理\n");
   fprintf(OutFileDpRam, "    //------------------------------------------------------------------\n");
   if (ErasureOption == 1) {
      fprintf(OutFileDpRam, "    reg [%d:0] q;\n", bitSymbol);
   }else{
      fprintf(OutFileDpRam, "    reg [%d:0] q;\n", bitSymbol-1);
   }
   fprintf(OutFileDpRam, "    always@(posedge clock) begin\n");
   fprintf(OutFileDpRam, "       if (rRdEn)\n");
   fprintf(OutFileDpRam, "          q <= mem[rRdAddr];\n");
   fprintf(OutFileDpRam, "    end\n");
   fprintf(OutFileDpRam,"\n\n\n");
   fprintf(OutFileDpRam, " endmodule\n");


  //---------------------------------------------------------------
  // close file
  //---------------------------------------------------------------
   fclose(OutFileDpRam);


  //---------------------------------------------------------------
  // Free memory
  //---------------------------------------------------------------
   delete[] euclideTab;


   //---------------------------------------------------------------
   // automatically convert Dos mode To Unix mode
   //---------------------------------------------------------------
	char ch;
	char temp[MAX_PATH]="\0";

	//Open the file for reading in binarymode.
	ifstream fp_read(strRsDecodeDpRam, ios_base::in | ios_base::binary);
	sprintf(temp, "%s.temp", strRsDecodeDpRam);
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
	remove(strRsDecodeDpRam);
	//Rename the temporary file to the input file.
	rename(temp, strRsDecodeDpRam);
	//Delete the temporary file.
	remove(temp);


   //---------------------------------------------------------------
   // clean string
   //---------------------------------------------------------------
   free(strRsDecodeDpRam);


}
