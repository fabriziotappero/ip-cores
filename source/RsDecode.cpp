//===================================================================
// Module Name : RsDecode
// File Name   : RsDecode.cpp
// Function    : Rs Decode Top instance
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
#include <string.h>

void RsDecodeSyndrome( int, int, int, int, int*, int*, int*, int, int, char*);
void RsDecodeErasure( int, int, int, int, int, int, int*, int*, int*, int, int, char*);
void RsDecodePolymul( int, int, int, int, int, int, char*);
void RsDecodeEuclide( int, int, int, int, int, int, int, char*);
void RsDecodeInv(int, int, int, int, char*);
void RsDecodeShiftOmega( int, int, int, int, int, int, int, char*);
void RsDecodeDegree( int, int, int, int, int, int, int, char*);
void RsDecodeChien( int, int, int, int, int, int*, int*, int, int, int, int, char*);
void RsDecodeDelay( int, int, int, int, int, int, int, char*);
void RsDecodeDpRam( int, int, int, int, int, int, int, char*);
void RsDecodeTop( int, int, int, int, int, int, int, int, int, int, char*);
void RsDecodeMul( int, int, int, int, int, int, char*);
void RsDecodeMakeData(int, int, int, int, int, int, int, int, int, int, int, int*, int*, int*, int, int, int, int, int, int, char*);


void RsDecode(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int errorStats, int passFailFlag, int delayDataIn, int ErasureOption, int BlockAmount, int ErrorRate, int PowerErrorRate, int ErasureRate, int PowerErasureRate, int *MrefTab, int *PrefTab, int *coeffTab, int encDecMode, int encBlockAmount, int pathFlag, int lengthPath, char *rootFolderPath) {


  //---------------------------------------------------------------
  // RS Decode Syndrome
  //---------------------------------------------------------------
  RsDecodeSyndrome(DataSize, TotalSize, PrimPoly, bitSymbol, MrefTab, PrefTab, coeffTab, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Erasure
  //---------------------------------------------------------------
  if (ErasureOption == 1){
     RsDecodeErasure(DataSize, TotalSize, PrimPoly, bitSymbol, passFailFlag, ErasureOption, MrefTab, PrefTab, coeffTab, pathFlag, lengthPath, rootFolderPath);
  }

  //---------------------------------------------------------------
  // RS Decode Polymul
  //---------------------------------------------------------------
  if (ErasureOption == 1){
     RsDecodePolymul(DataSize, TotalSize, PrimPoly, bitSymbol, pathFlag, lengthPath, rootFolderPath);
  }

  //---------------------------------------------------------------
  // RS Decode Euclide
  //---------------------------------------------------------------
  RsDecodeEuclide(DataSize, TotalSize, PrimPoly, ErasureOption, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Shift Omega
  //---------------------------------------------------------------
  RsDecodeShiftOmega(DataSize, TotalSize, PrimPoly, ErasureOption, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Degree
  //---------------------------------------------------------------
  if (passFailFlag == 1){
     RsDecodeDegree(DataSize, TotalSize, PrimPoly, bitSymbol, ErasureOption, pathFlag, lengthPath, rootFolderPath);
  }

  //---------------------------------------------------------------
  // RS Decode Chien
  //---------------------------------------------------------------
  RsDecodeChien(DataSize, TotalSize, PrimPoly, bitSymbol, ErasureOption, MrefTab, PrefTab, errorStats, passFailFlag, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Inverse
  //---------------------------------------------------------------
  RsDecodeInv(PrimPoly, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Delay
  //---------------------------------------------------------------
  RsDecodeDelay(DataSize, TotalSize, PrimPoly, ErasureOption, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode DpRam
  //---------------------------------------------------------------
  RsDecodeDpRam(DataSize, TotalSize, PrimPoly, ErasureOption, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Top
  //---------------------------------------------------------------
  RsDecodeTop(DataSize, TotalSize, PrimPoly, ErasureOption, bitSymbol, errorStats, passFailFlag, delayDataIn, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode Mul
  //---------------------------------------------------------------
  RsDecodeMul(DataSize, TotalSize, PrimPoly, bitSymbol, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS Decode MakeData
  //---------------------------------------------------------------
  RsDecodeMakeData(DataSize, TotalSize, PrimPoly, bitSymbol, ErasureOption, delayDataIn, BlockAmount, ErrorRate, PowerErrorRate, ErasureRate, PowerErasureRate, coeffTab, MrefTab, PrefTab, errorStats, passFailFlag, encDecMode, encBlockAmount, pathFlag, lengthPath, rootFolderPath);


}
