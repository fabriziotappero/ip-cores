//===================================================================
// Module Name : RsEncode
// File Name   : RsEncode.cpp
// Function    : RTL Encoder Top instance
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
#include <string.h>

void RsGfMultiplier( int*, int*,int*, int, int);
void RsEncodeTop( int, int, int, int, int*, int*, int*, int, int, char*);
void RsEncodeMakeData(int, int, int, int, int, int, int, int*, int*, int*, int, int, int, int, int, int, int, int, int, int, char*);

void RsEncode(int DataSize, int TotalSize, int PrimPoly, int bitSymbol, int ErasureOption, int BlockAmount, int ErrorRate, int *MrefTab, int *PrefTab, int *coeffTab, int errorStats,int passFailFlag,int delayDataIn,int encDecMode,int PowerErrorRate,int ErasureRate,int PowerErasureRate, int decBlockAmount, int pathFlag, int lengthPath, char *rootFolderPath) {


  //---------------------------------------------------------------
  // RS encode Top Module
  //---------------------------------------------------------------
  RsEncodeTop(DataSize, TotalSize, PrimPoly, bitSymbol, coeffTab, MrefTab, PrefTab, pathFlag, lengthPath, rootFolderPath);


  //---------------------------------------------------------------
  // RS encode MakeData
  //---------------------------------------------------------------
  RsEncodeMakeData(DataSize, TotalSize, PrimPoly, bitSymbol, ErasureOption, BlockAmount, ErrorRate, coeffTab, MrefTab, PrefTab, errorStats, passFailFlag, delayDataIn, encDecMode, PowerErrorRate, ErasureRate, PowerErasureRate, decBlockAmount, pathFlag, lengthPath, rootFolderPath);


}
