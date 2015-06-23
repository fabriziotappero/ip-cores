//===================================================================
// Module Name : main
// File Name   : RsIpEngine.cpp
// Function    : main
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//
#include <cstdio>
#include <cstdlib>
#include <ctime>
#include <iostream>
#include<windows.h>
#include<fstream>
#include <stdio.h>
#include <stdlib.h>
using namespace std;
#include <io.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <string.h>

FILE  *OutFileIPSpecs;


void RsEncode(int, int, int, int, int, int, int, int*, int*, int*, int, int, int, int, int, int, int, int, int, int, char*);
void RsGfMultiplier(int*, int*,int*, int, int);
void RsDecode(int, int, int, int, int, int, int, int,int,int,int,int,int, int*, int*, int*,int,int, int, int, char*);
void RsSimBench(int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, int, char*);
void RsMrefTab(int*, int);
void RsPrefTab(int*, int, int);

int main(int argc, char *argv[])
{



   //---------------------------------------------------------------
   //---------------------------------------------------------------
   //- Get Parameters from C# program
   //---------------------------------------------------------------
   int DataSize, TotalSize, PrimPoly, ErasureOption;
   int BlockAmount, ErrorRate;
   int bitSymbol;
   int syndromeLength;
   int syndromeMod2;
   int ii,jj,zz;
   int tempix;
   int symbolMax;
   int DecNumber;
   int index;
   int errorStats;
   int passFailFlag;
   int delayDataIn;
   int encDecMode;
   int encBlockAmount;
   int ipCustomerKey;
   int PowerErrorRate;
   int ErasureRate;
   int PowerErasureRate;
   int cppCoreInternalKey;
   int pathFlag;
   int lengthPath;

   char *rootFolderPath;
   char *strsimReedSolomon;
   char *strrtl;
   char *strsim;
   char *strRsEncIn;
   char *strRsEncOut;
   char *strRsDecIn;
   char *strRsDecOut;
   char *strRsEncodeTop;
   char *strRsDecodeTop;
   char *strRsDecodeSyndrome;
   char *strRsDecodeShiftOmega;
   char *strRsDecodePolymul;
   char *strRsDecodeMult;
   char *strRsDecodeInv;
   char *strRsDecodeEuclide;
   char *strRsDecodeErasure;
   char *strRsDecodeDpRam;
   char *strRsDecodeDelay;
   char *strRsDecodeDegree;
   char *strRsDecodeChien;
   char *strIPSpecs;



   //---------------------------------------------------------------
   // cpp core internal ip key
   //- It is the only line to change before release
   //---------------------------------------------------------------
   cppCoreInternalKey = 27;



   //---------------------------------------------------------------
   // convert parameters to Int
   //---------------------------------------------------------------
   DataSize         = atoi(argv[1]);  // Data Size
   TotalSize        = atoi(argv[2]);  // Total Size
   PrimPoly         = atoi(argv[3]);  // Primitve Polynom
   ErasureOption    = atoi(argv[4]);  // Erasure Decoding ( 0: No, 1:Yes)
   BlockAmount      = atoi(argv[5]);  // RS Decoder Block Amount for Sim
   ErrorRate        = atoi(argv[6]);  // Error rate
   PowerErrorRate   = atoi(argv[7]);  // 0: 1, 1: 10^-1, 4: 10^-4
   ErasureRate      = atoi(argv[8]);  // Erasure rate
   PowerErasureRate = atoi(argv[9]);  // 0: 1, 1: 10^-1, 4: 10^-4
   bitSymbol        = atoi(argv[10]); // range = [3..12]
   errorStats       = atoi(argv[11]); //( 0: No, 1:Yes)
   passFailFlag     = atoi(argv[12]); //( 0: No, 1:Yes)
   delayDataIn      = atoi(argv[13]); //( 0: No, 1:Yes)
   encDecMode       = atoi(argv[14]); //(1: enc only, 2:dec only, 3: enc & dec)
   encBlockAmount   = atoi(argv[15]); // encoder block amount
   ipCustomerKey    = atoi(argv[16]); // IP Key


   //---------------------------------------------------------------
   // check parameter amount if not 17 or 18 -> escape code
   //---------------------------------------------------------------
   if ((argc < 17) || (argc > 18)){
      exit(1);
   }

   //---------------------------------------------------------------
   // get Root folder path if specified
   // apthFlag= 1 if Path specified, 0 if not specified
   //---------------------------------------------------------------
   if (argc == 18) {
      pathFlag = 1;
      lengthPath = strlen(argv[17]);
   }else{
      pathFlag = 0;
      lengthPath = 1;
   }


   rootFolderPath = (char *)calloc(lengthPath,  sizeof(char));


   if (pathFlag == 1) {
      rootFolderPath   = argv[17]; // Root Folder Path
      
      for(ii=0; ii<lengthPath; ii++){ // unify markers
         if (rootFolderPath[ii] == '\\'  ) {
            rootFolderPath[ii] = '/';
         }
      }
   }else{
      rootFolderPath = "Z";
   }


   //---------------------------------------------------------------
   // make path file strings
   //---------------------------------------------------------------
   strsimReedSolomon = (char *)calloc(lengthPath + 22,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strsimReedSolomon[ii] = rootFolderPath[ii];
   }
   strcat(strsimReedSolomon, "/sim/simReedSolomon.v");

   strRsEncIn = (char *)calloc(lengthPath + 17,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsEncIn[ii] = rootFolderPath[ii];
   }
   strcat(strRsEncIn, "/sim/RsEncIn.hex");

   strRsEncOut = (char *)calloc(lengthPath + 18,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsEncOut[ii] = rootFolderPath[ii];
   }
   strcat(strRsEncOut, "/sim/RsEncOut.hex");

   strRsDecIn = (char *)calloc(lengthPath + 17,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecIn[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecIn, "/sim/RsDecIn.hex");

   strRsDecOut = (char *)calloc(lengthPath + 18,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecOut[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecOut, "/sim/RsDecOut.hex");

   strRsEncodeTop = (char *)calloc(lengthPath + 19,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsEncodeTop[ii] = rootFolderPath[ii];
   }
   strcat(strRsEncodeTop, "/rtl/RsEncodeTop.v");        

   strRsDecodeTop = (char *)calloc(lengthPath + 19,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeTop[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeTop, "/rtl/RsDecodeTop.v");        

   strRsDecodeSyndrome = (char *)calloc(lengthPath + 24,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeSyndrome[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeSyndrome, "/rtl/RsDecodeSyndrome.v");        

   strRsDecodeShiftOmega = (char *)calloc(lengthPath + 26,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeShiftOmega[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeShiftOmega, "/rtl/RsDecodeShiftOmega.v");        

   strRsDecodePolymul = (char *)calloc(lengthPath + 23,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodePolymul[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodePolymul, "/rtl/RsDecodePolymul.v");

   strRsDecodeMult = (char *)calloc(lengthPath + 20,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeMult[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeMult, "/rtl/RsDecodeMult.v");

   strRsDecodeInv = (char *)calloc(lengthPath + 19,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeInv[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeInv, "/rtl/RsDecodeInv.v");

   strRsDecodeEuclide = (char *)calloc(lengthPath + 23,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeEuclide[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeEuclide, "/rtl/RsDecodeEuclide.v");

   strRsDecodeErasure = (char *)calloc(lengthPath + 23,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeErasure[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeErasure, "/rtl/RsDecodeErasure.v");

   strRsDecodeDpRam = (char *)calloc(lengthPath + 21,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeDpRam[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeDpRam, "/rtl/RsDecodeDpRam.v");

   strRsDecodeDelay = (char *)calloc(lengthPath + 21,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeDelay[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeDelay, "/rtl/RsDecodeDelay.v");

   strRsDecodeDegree = (char *)calloc(lengthPath + 22,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeDegree[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeDegree, "/rtl/RsDecodeDegree.v");

   strRsDecodeChien = (char *)calloc(lengthPath + 21,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strRsDecodeChien[ii] = rootFolderPath[ii];
   }
   strcat(strRsDecodeChien, "/rtl/RsDecodeChien.v");

   strrtl = (char *)calloc(lengthPath + 5,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strrtl[ii] = rootFolderPath[ii];
   }
   strcat(strrtl, "/rtl");

   strsim = (char *)calloc(lengthPath + 5,  sizeof(char));
   for(ii=0; ii<lengthPath; ii++){
      strsim[ii] = rootFolderPath[ii];
   }
   strcat(strsim, "/sim");


   //---------------------------------------------------------------
   // syndrome Polynom calculation
   //---------------------------------------------------------------
   syndromeLength = TotalSize - DataSize;
   syndromeMod2   = syndromeLength %2;


   //---------------------------------------------------------------
   // symbolMax calculation
   //---------------------------------------------------------------
   symbolMax = 1;
   for (ii=0;ii<bitSymbol;ii++){
      symbolMax= 2* symbolMax;
   }


   //---------------------------------------------------------------
   //- c++ variables
   //---------------------------------------------------------------
   int mmTabSize = (bitSymbol*2) -1;
   int *PrefTab;
   int *MrefTab;
   int *x1Tab;
   int *x2Tab;
   int *ppTab;
   int *aTab;
   int *checkTab;
   int *powerTab;
   int *GenPoly;
   int *convPoly;
   int *xPoly;
   int *coeffPoly;
   int *aPoly;
   int *coeffTab;

   PrefTab   = new int[mmTabSize*bitSymbol];
   MrefTab   = new int[mmTabSize*bitSymbol];
   x1Tab     = new int[bitSymbol];
   x2Tab     = new int[bitSymbol];
   ppTab     = new int[bitSymbol];
   checkTab  = new int[symbolMax-1];
   aTab      = new int[syndromeLength+1];
   powerTab  = new int[bitSymbol];
   GenPoly   = new int[syndromeLength+1];
   convPoly  = new int[syndromeLength+1];
   xPoly     = new int[syndromeLength+1];
   coeffPoly = new int[syndromeLength+1];
   aPoly     = new int[syndromeLength+1];
   coeffTab  = new int[symbolMax];


   //------------------------------------------------------------------------
   // MrefTab Construction
   //------------------------------------------------------------------------
   RsMrefTab(MrefTab, bitSymbol);


   //------------------------------------------------------------------------
   // PrefTab Construction
   //------------------------------------------------------------------------
   RsPrefTab(PrefTab, PrimPoly, bitSymbol);


   //-----------------------------------------------------------------------
   // initialize x1Tab
   //------------------------------------------------------------------------
   x1Tab[0] = 1;
   for (ii=1;ii<bitSymbol;ii++){
      x1Tab[ii] = 0;
   }


   //-----------------------------------------------------------------------
   // initialize x2Tab
   //------------------------------------------------------------------------
   x2Tab[0] = 0;
   x2Tab[1] = 1;
   for (ii=2;ii<bitSymbol;ii++){
      x2Tab[ii] = 0;
   }


   //-----------------------------------------------------------------------
   // initialize powerTab
   //------------------------------------------------------------------------
   powerTab[0] = 1;
   for (ii=1; ii<bitSymbol;ii++){
      powerTab[ii] = 2*powerTab[ii-1];
   }


   //-----------------------------------------------------------------------
   //------------------------------------------------------------------------
   for(ii=0; ii<symbolMax-1; ii++){

      //-----------------------------------------------------------------------
      // ppTab = x1Tab * x2Tab
      //------------------------------------------------------------------------
      RsGfMultiplier(ppTab, x1Tab, x2Tab, PrimPoly, bitSymbol);


      //-----------------------------------------------------------------------
      // Binary To Decimal DecNumber [dec] = ppTab [bin]
      //------------------------------------------------------------------------
      DecNumber = 0;
      for (jj=0; jj<bitSymbol;jj++){
         DecNumber = DecNumber + ppTab[jj] * powerTab[jj];
      }

      checkTab[ii] = DecNumber;


      //-----------------------------------------------------------------------
      // Reassign x1Tab
      //------------------------------------------------------------------------
      for (jj=0; jj<bitSymbol;jj++){
         x1Tab[jj] = ppTab [jj];
      }
   }


   aTab[0] = 1;

   //-----------------------------------------------------------------------
   // initialize x1Tab
   //------------------------------------------------------------------------
   x1Tab[0] = 1;
   for (ii=1;ii<bitSymbol;ii++){
      x1Tab[ii] = 0;
   }


   //-----------------------------------------------------------------------
   // initialize x2Tab
   //------------------------------------------------------------------------
   x2Tab[0] = 0;
   x2Tab[1] = 1;
   for (ii=2;ii<bitSymbol;ii++){
      x2Tab[ii] = 0;
   }


   for(ii=1; ii<(syndromeLength+1); ii++){

      //-----------------------------------------------------------------------
      // ppTab = x1Tab * x2Tab
      //------------------------------------------------------------------------
      RsGfMultiplier(ppTab, x1Tab, x2Tab, PrimPoly, bitSymbol);

      //-----------------------------------------------------------------------
      // Binary To Decimal DecNumber [dec] = ppTab [bin]
      //------------------------------------------------------------------------
      DecNumber = 0;
      for (jj=0; jj<bitSymbol;jj++){
          DecNumber = DecNumber + ppTab[jj] * powerTab[jj];
      }
      aTab[ii] = DecNumber;

      //-----------------------------------------------------------------------
      // Reassign x1Tab
      //------------------------------------------------------------------------
      for (jj=0; jj<bitSymbol;jj++){
         x1Tab[jj] = ppTab [jj];
      }
   }


   //-----------------------------------------------------------------------
   // initialize GenPoly, aPoly, convPoly, xPoly, coeffPoly
   //------------------------------------------------------------------------
   for(ii=0; ii<syndromeLength+1; ii++){
      GenPoly   [ii] = 0;
      aPoly     [ii] = 0;
      convPoly  [ii] = 0;
      xPoly     [ii] = 0;
      coeffPoly [ii] = 0;
   }
   GenPoly [0] = 1;
   GenPoly [1] = 1;
   aPoly   [1] = 1;



   for(ii=0; ii<(syndromeLength-1); ii++){
      aPoly   [0] = aTab[ii+1];

      //-----------------------------------------------------------------------
      // assign xPoly
      //-----------------------------------------------------------------------
      for (jj=1; jj< (syndromeLength+1); jj++){
         xPoly [jj] = GenPoly[jj-1];
      }

      for (jj=0; jj< (syndromeLength+1); jj++){

         //-----------------------------------------------------------------------
         // Decimal To Binary x1Tab [bin] = GenPoly[jj][dec]
         //-----------------------------------------------------------------------
         tempix = GenPoly[jj];

         for (zz =(bitSymbol-1); zz>=0;zz--) {
            if (tempix >= powerTab[zz]) {
               tempix = tempix - powerTab[zz];
               x1Tab [zz] = 1;
            }else{
               x1Tab [zz] = 0;
            }
         }


         //-----------------------------------------------------------------------
         // Decimal To Binary x2Tab [bin] = aPoly[0][dec]
         //-----------------------------------------------------------------------
         tempix = aPoly   [0];
         for (zz =(bitSymbol-1); zz>=0;zz--) {
            if (tempix >= powerTab[zz]) {
               tempix = tempix -powerTab[zz];
               x2Tab [zz] = 1;
            }else{
               x2Tab [zz] = 0;
            }
         }

         //-----------------------------------------------------------------------
         // ppTab = x1Tab * x2Tab
         //-----------------------------------------------------------------------
           RsGfMultiplier(ppTab, x1Tab, x2Tab, PrimPoly, bitSymbol);


         //-----------------------------------------------------------------------
         // Binary To Decimal coeffPoly[jj] [dec] = ppTab[zz] [bin]
         //-----------------------------------------------------------------------
         coeffPoly[jj] = 0;
         for (zz=0;zz<bitSymbol;zz++){
            coeffPoly[jj] = coeffPoly[jj] + ppTab[zz] *powerTab[zz];
         }


         //-----------------------------------------------------------------------
         // compute GenPoly (convolution function)
         //-----------------------------------------------------------------------
         GenPoly [jj] = coeffPoly[jj] ^ xPoly[jj];
      }
   }


  //---------------------------------------------------------------
  // coeffTab calculation
  //---------------------------------------------------------------
   for(ii=0; ii<syndromeLength; ii++){
      index = 0;
      for (jj= 0; jj<symbolMax-2; jj++){
         if (checkTab[jj] == GenPoly [ii]) {
            index = jj+1;
         }
      }
      coeffTab[ii] = index;
   }




  if (ipCustomerKey == cppCoreInternalKey) {
     
     
     //---------------------------------------------------------------
     // remove Files if they already exists
     //---------------------------------------------------------------
     if (pathFlag == 0) { // no path folder specified
        DeleteFile ("./sim/simReedSolomon.v");
        DeleteFile ("./sim/RsEncIn.hex");
        DeleteFile ("./sim/RsEncOut.hex");
        DeleteFile ("./sim/RsDecIn.hex");
        DeleteFile ("./sim/RsDecOut.hex");
        DeleteFile ("./rtl/RsEncodeTop.v");
        DeleteFile ("./rtl/RsDecodeTop.v");
        DeleteFile ("./rtl/RsDecodeSyndrome.v");
        DeleteFile ("./rtl/RsDecodeShiftOmega.v");
        DeleteFile ("./rtl/RsDecodePolymul.v");
        DeleteFile ("./rtl/RsDecodeMult.v");
        DeleteFile ("./rtl/RsDecodeInv.v");
        DeleteFile ("./rtl/RsDecodeEuclide.v");
        DeleteFile ("./rtl/RsDecodeErasure.v");
        DeleteFile ("./rtl/RsDecodeDpRam.v");
        DeleteFile ("./rtl/RsDecodeDelay.v");
        DeleteFile ("./rtl/RsDecodeDegree.v");
        DeleteFile ("./rtl/RsDecodeChien.v");
     }else{ // a path folder has been specified
        DeleteFile (strsimReedSolomon);
        DeleteFile (strRsEncIn);
        DeleteFile (strRsEncOut);
        DeleteFile (strRsDecIn);
        DeleteFile (strRsDecOut);
        DeleteFile (strRsEncodeTop);
        DeleteFile (strRsDecodeTop);
        DeleteFile (strRsDecodeSyndrome);
        DeleteFile (strRsDecodeShiftOmega);
        DeleteFile (strRsDecodePolymul);
        DeleteFile (strRsDecodeMult);
        DeleteFile (strRsDecodeInv);
        DeleteFile (strRsDecodeEuclide);
        DeleteFile (strRsDecodeErasure);
        DeleteFile (strRsDecodeDpRam);
        DeleteFile (strRsDecodeDelay);
        DeleteFile (strRsDecodeDegree);
        DeleteFile (strRsDecodeChien);
     }


     //---------------------------------------------------------------
     // create source and sim folders if they do not already exists
     //---------------------------------------------------------------
     if (pathFlag == 0) { // no path folder specified
        CreateDirectory ("rtl", NULL);
        CreateDirectory ("sim", NULL);
     }else{ // a path folder has been specified
        CreateDirectory (strrtl, NULL);
        CreateDirectory (strsim, NULL);
     }


     //---------------------------------------------------------------
     // RS DECODE
     //---------------------------------------------------------------
     if ((encDecMode == 2) || (encDecMode == 3)){
        RsDecode(DataSize, TotalSize, PrimPoly, bitSymbol, errorStats, passFailFlag, delayDataIn, ErasureOption, BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, MrefTab, PrefTab, coeffTab, encDecMode, encBlockAmount, pathFlag, lengthPath, rootFolderPath);
     }

     //---------------------------------------------------------------
     // RS ENCODE
     //---------------------------------------------------------------
     if ((encDecMode == 1) || (encDecMode == 3)){
        RsEncode(DataSize, TotalSize, PrimPoly, bitSymbol, ErasureOption, encBlockAmount, ErrorRate, MrefTab, PrefTab, coeffTab, errorStats, passFailFlag, delayDataIn, encDecMode, PowerErrorRate, ErasureRate, PowerErasureRate, BlockAmount, pathFlag, lengthPath, rootFolderPath);
     }

     //---------------------------------------------------------------
     // RS SimBench
     //---------------------------------------------------------------
     if ((encDecMode == 1) ||(encDecMode == 2) || (encDecMode == 3)){
        RsSimBench(DataSize, TotalSize, PrimPoly, bitSymbol, errorStats, passFailFlag, delayDataIn, encDecMode, ErasureOption, BlockAmount, encBlockAmount, ErrorRate,PowerErrorRate, ErasureRate, PowerErasureRate, pathFlag, lengthPath, rootFolderPath);
     }




     //---------------------------------------------------------------
     // create IP summary File
     //---------------------------------------------------------------
//     OutFileIPSpecs = fopen("./sim/IPSpecs.txt","w");

   strIPSpecs = (char *)calloc(lengthPath + 17,  sizeof(char));
   if (pathFlag == 0) { 
        strIPSpecs[0] = '.';
   }else{
      for(ii=0; ii<lengthPath; ii++){
         strIPSpecs[ii] = rootFolderPath[ii];
      }
   }
   strcat(strIPSpecs, "/sim/IPSpecs.txt");

   OutFileIPSpecs = fopen(strIPSpecs,"w");


     fprintf(OutFileIPSpecs, "//=================================================================\n");
     fprintf(OutFileIPSpecs, "//                       RS-IP Global Settings                     \n");
     fprintf(OutFileIPSpecs, "//=================================================================\n");

     if (pathFlag == 1) {
        fprintf(OutFileIPSpecs, "- Path Folder : ");
        for(ii=0; ii<lengthPath; ii++){
           fprintf(OutFileIPSpecs, "%c", rootFolderPath[ii]);
        }
        fprintf(OutFileIPSpecs, "\n");
     }else{
        fprintf(OutFileIPSpecs, "- Path Folder : No Path Specified\n");
     }
     
     fprintf(OutFileIPSpecs, "- Symbol Bit Width: %d bits\n", bitSymbol);
     if (encDecMode == 1) { fprintf(OutFileIPSpecs, "- IP Mode: Encoder Only\n");}
     if (encDecMode == 2) { fprintf(OutFileIPSpecs, "- IP Mode: Decoder Only\n");}
     if (encDecMode == 3) { fprintf(OutFileIPSpecs, "- IP Mode: Encoder + Decoder\n");}
     fprintf(OutFileIPSpecs, "- Data Symbol Amount: %d symbols\n", DataSize);
     fprintf(OutFileIPSpecs, "- Data+Redundancy Symbol Amount: %d symbols\n", TotalSize);
     fprintf(OutFileIPSpecs, "- Primitive Polynomial: %d\n", PrimPoly);

     if ((encDecMode == 1) || (encDecMode == 3)) {
        fprintf(OutFileIPSpecs, "\n\n//=================================================================\n");
        fprintf(OutFileIPSpecs, "//                       RS-IP Encoder Settings                    \n");
        fprintf(OutFileIPSpecs, "//=================================================================\n");
        fprintf(OutFileIPSpecs, "- RTL sim block amount: %d Blocks\n", encBlockAmount);
     }
     if ((encDecMode == 2) || (encDecMode == 3)) {
        fprintf(OutFileIPSpecs, "\n\n//=================================================================\n");
        fprintf(OutFileIPSpecs, "//                       RS-IP Decoder Settings                    \n");
        fprintf(OutFileIPSpecs, "//=================================================================\n");
        if (ErasureOption == 0) { fprintf(OutFileIPSpecs, "- Erasure Decoding: No\n" );}
        if (ErasureOption == 1) { fprintf(OutFileIPSpecs, "- Erasure Decoding: Yes\n" );}
        if (errorStats == 0) { fprintf(OutFileIPSpecs, "- Decoder Statisctics Pin: No\n" );}
        if (errorStats == 1) { fprintf(OutFileIPSpecs, "- Decoder Statisctics Pin: Yes\n" );}
        if (passFailFlag == 0) { fprintf(OutFileIPSpecs, "- Decoder Result Pin: No\n" );}
        if (passFailFlag == 1) { fprintf(OutFileIPSpecs, "- Decoder Result Pin: Yes\n" );}
        if (delayDataIn == 0) { fprintf(OutFileIPSpecs, "- Delayed Data Pin: No\n" );}
        if (delayDataIn == 1) { fprintf(OutFileIPSpecs, "- Delayed Data Pin: Yes\n" );}
        fprintf(OutFileIPSpecs, "- RTL sim block amount: %d Blocks\n", BlockAmount);
        fprintf(OutFileIPSpecs, "- RTL sim Input Error Rate: %d * 10^-%d Percent\n",  ErrorRate, PowerErrorRate);
        if (ErasureOption == 1)
        {
           fprintf(OutFileIPSpecs, "- RTL sim Input Erasure Rate: %d * 10^-%d Percent\n",   ErasureRate, PowerErasureRate);
        }
     }

     fclose(OutFileIPSpecs);



  }
  //---------------------------------------------------------------
  // clean data
  //---------------------------------------------------------------
  delete[] PrefTab;
  delete[] MrefTab;
  delete[] x1Tab;
  delete[] x2Tab;
  delete[] ppTab;
  delete[] checkTab;
  delete[] aTab;
  delete[] powerTab;
  delete[] GenPoly;
  delete[] convPoly;
  delete[] xPoly;
  delete[] coeffPoly;
  delete[] aPoly;
  delete[] coeffTab;


  //---------------------------------------------------------------
  // clean strings
  //---------------------------------------------------------------
  free(strrtl);
  free(strsim);
  free(strsimReedSolomon);
  free(strRsEncIn);
  free(strRsEncOut);
  free(strRsDecIn);
  free(strRsDecOut);
  free(strRsEncodeTop);
  free(strRsDecodeTop);
  free(strRsDecodeSyndrome);
  free(strRsDecodeShiftOmega);
  free(strRsDecodePolymul);
  free(strRsDecodeMult);
  free(strRsDecodeInv);
  free(strRsDecodeEuclide);
  free(strRsDecodeErasure);
  free(strRsDecodeDpRam);
  free(strRsDecodeDelay);
  free(strRsDecodeDegree);
  free(strRsDecodeChien);
  free(strIPSpecs);


}