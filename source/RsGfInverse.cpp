//===================================================================
// Module Name : RsGfInverse
// File Name   : RsGfInverse.cpp
// Function    : RS Decoder GF inverter
// 
// Revision History:
// Date          By           Version    Change Description
//===================================================================
// 2009/02/03  Gael Sapience     1.0       Original
//
//===================================================================
// (C) COPYRIGHT 2009 SYSTEM LSI CO., Ltd.
//
//#include <stdio.h>
//#include <stdlib.h>
//#include <cstdio>
//#include <cstdlib>
#include <stdio.h>
#include <stdlib.h>
void RsGfMultiplier( int*, int*,int*, int, int);


void RsGfInverse(int *yFinalTab, int *x1Tab, int PrimPoly, int bitSymbol) {


   //---------------------------------------------------------------
   //
   //---------------------------------------------------------------
   int zz;


   //---------------------------------------------------------------
   // c++ variables
   //---------------------------------------------------------------
   int *y2Tab;
   int *y3Tab;
   int *y6Tab;
   int *y12Tab;
   int *y15Tab;
   int *y30Tab;
   int *y60Tab;
   int *y120Tab;
   int *y240Tab;
   int *y14Tab;
   int *y254Tab;
   int *y508Tab;
   int *y510Tab;
   int *y1020Tab;
   int *y1022Tab;
   int *y62Tab;
   int *y126Tab;
   int *y2044Tab;
   int *y2046Tab;
   int *y4092Tab;
   int *y4094Tab;

   y2Tab    = new int[bitSymbol];
   y3Tab    = new int[bitSymbol];
   y6Tab    = new int[bitSymbol];
   y12Tab   = new int[bitSymbol];
   y15Tab   = new int[bitSymbol];
   y30Tab   = new int[bitSymbol];
   y60Tab   = new int[bitSymbol];
   y120Tab  = new int[bitSymbol];
   y240Tab  = new int[bitSymbol];
   y14Tab   = new int[bitSymbol];
   y254Tab  = new int[bitSymbol];
   y508Tab  = new int[bitSymbol];
   y510Tab  = new int[bitSymbol];
   y1020Tab = new int[bitSymbol];
   y1022Tab = new int[bitSymbol];
   y62Tab   = new int[bitSymbol];
   y126Tab  = new int[bitSymbol];
   y2044Tab = new int[bitSymbol];
   y2046Tab = new int[bitSymbol];
   y4092Tab = new int[bitSymbol];
   y4094Tab = new int[bitSymbol];


   //---------------------------------------------------------------
   // Galois multiplier: Y^2 = x1*x1
   //---------------------------------------------------------------
   RsGfMultiplier(y2Tab, x1Tab, x1Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^3 = Y^2 *x1
   //---------------------------------------------------------------
   RsGfMultiplier(y3Tab, y2Tab, x1Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^6 = Y^3 *Y^3
   //---------------------------------------------------------------
   RsGfMultiplier(y6Tab, y3Tab, y3Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^12 = Y^6 *Y^6
   //---------------------------------------------------------------
   RsGfMultiplier(y12Tab, y6Tab, y6Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^15 = Y^12 *Y^3
   //---------------------------------------------------------------
   RsGfMultiplier(y15Tab, y12Tab, y3Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^30 = Y^15 *Y^15
   //---------------------------------------------------------------
   RsGfMultiplier(y30Tab, y15Tab, y15Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^60 = Y^30 *Y^30
   //---------------------------------------------------------------
   RsGfMultiplier(y60Tab, y30Tab, y30Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^62 = Y^60 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y62Tab, y60Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^120 = Y^60 *Y^60
   //---------------------------------------------------------------
   RsGfMultiplier(y120Tab, y60Tab, y60Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^126 = Y^120 *Y^6
   //---------------------------------------------------------------
   RsGfMultiplier(y126Tab, y120Tab, y6Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^240 = Y^120 *Y^120
   //---------------------------------------------------------------
   RsGfMultiplier(y240Tab, y120Tab, y120Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^14 = Y^12 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y14Tab, y12Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^254 = Y^240 *Y^14
   //---------------------------------------------------------------
   RsGfMultiplier(y254Tab, y240Tab, y14Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^508 = Y^254 *Y^254
   //---------------------------------------------------------------
   RsGfMultiplier(y508Tab, y254Tab, y254Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^510 = Y^508 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y510Tab, y508Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^1020 = Y^510 *Y^510
   //---------------------------------------------------------------
   RsGfMultiplier(y1020Tab, y510Tab, y510Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^1022 = Y^1020 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y1022Tab, y1020Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^2044 = Y^1022 *Y^1022
   //---------------------------------------------------------------
   RsGfMultiplier(y2044Tab, y1022Tab, y1022Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^2044 = Y^2044 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y2046Tab, y2044Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^4092 = Y^2046 *Y^2046
   //---------------------------------------------------------------
   RsGfMultiplier(y4092Tab, y2046Tab, y2046Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Galois multiplier: Y^4094 = Y^4092 *Y^2
   //---------------------------------------------------------------
   RsGfMultiplier(y4094Tab, y4092Tab, y2Tab, PrimPoly, bitSymbol);


   //---------------------------------------------------------------
   // Result assignment 2^8=y^254, 2^9=y^510, 2^10=y^1022
   //---------------------------------------------------------------
   switch(bitSymbol){
      case (3):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y6Tab[zz];
         }
      break;
      case (4):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y14Tab[zz];
         }
      break;
      case (5):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y30Tab[zz];
         }
      break;
      case (6):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y62Tab[zz];
         }
      break;
      case (7):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y126Tab[zz];
         }
      break;
      case (8):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y254Tab[zz];
         }
      break;
      case (9):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y510Tab[zz];
         }
      break;
      case (10):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y1022Tab[zz];
         }
      break;
      case (11):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y2046Tab[zz];
         }
      break;
      case (12):
         for (zz=0; zz<bitSymbol;zz++){
            yFinalTab [zz] = y4094Tab[zz];
         }
      break;
      default:
         yFinalTab [0] = 0;
      break;
   }


   //---------------------------------------------------------------
   // Free memory
   //---------------------------------------------------------------
   delete[] y2Tab;
   delete[] y3Tab;
   delete[] y6Tab;
   delete[] y12Tab;
   delete[] y15Tab;
   delete[] y30Tab;
   delete[] y60Tab;
   delete[] y120Tab;
   delete[] y240Tab;
   delete[] y14Tab;
   delete[] y254Tab;
   delete[] y508Tab;
   delete[] y510Tab;
   delete[] y1020Tab;
   delete[] y1022Tab;
   delete[] y62Tab;
   delete[] y126Tab;
   delete[] y2044Tab;
   delete[] y2046Tab;
   delete[] y4092Tab;
   delete[] y4094Tab;


}
