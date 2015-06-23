//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Header file of unit test functions for HIGHT Integer Model  ////
////                                                              ////
////  This file is part of the HIGHT Crypto Core project          ////
////  http://github.com/OpenSoCPlus/hight_crypto_core             ////
////  http://www.opencores.org/project,hight                      ////
////                                                              ////
////  Description                                                 ////
////  __description__                                             ////
////                                                              ////
////  Author(s):                                                  ////
////      - JoonSoo Ha, json.ha@gmail.com                         ////
////      - Younjoo Kim, younjookim.kr@gmail.com                  ////
////                                                              ////
//////////////////////////////////////////////////////////////////////
////                                                              ////
//// Copyright (C) 2015 Authors, OpenSoCPlus and OPENCORES.ORG    ////
////                                                              ////
//// This source file may be used and distributed without         ////
//// restriction provided that this copyright statement is not    ////
//// removed from the file and that any derivative work contains  ////
//// the original copyright notice and the associated disclaimer. ////
////                                                              ////
//// This source file is free software; you can redistribute it   ////
//// and/or modify it under the terms of the GNU Lesser General   ////
//// Public License as published by the Free Software Foundation; ////
//// either version 2.1 of the License, or (at your option) any   ////
//// later version.                                               ////
////                                                              ////
//// This source is distributed in the hope that it will be       ////
//// useful, but WITHOUT ANY WARRANTY; without even the implied   ////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      ////
//// PURPOSE.  See the GNU Lesser General Public License for more ////
//// details.                                                     ////
////                                                              ////
//// You should have received a copy of the GNU Lesser General    ////
//// Public License along with this source; if not, download it   ////
//// from http://www.opencores.org/lgpl.shtml                     ////
////                                                              ////
//////////////////////////////////////////////////////////////////////

#ifndef __HIGHT_UNIT_TEST_H__
#define __HIGHT_UNIT_TEST_H__

/* =====================================

    DeltaGenTest()

=======================================*/
void DeltaGenTest();


/* =====================================

    SubKeyGenTest()

=======================================*/
void SubKeyGenTest();


/* =====================================

    WhiteningKeyGenTest()

=======================================*/
void WhiteningKeyGenTest ();


/* =====================================

    InitialWhiteningFunctionTest()

=======================================*/
void InitialWhiteningFunctionTest (); 


/* =====================================

    FinalWhiteningFunctionTest()

=======================================*/
void FinalWhiteningFunctionTest ();


/* =====================================

    InterRoundFunctionTest()

=======================================*/
void InterRoundFunctionTest();


/* =====================================

    FinalRoundFunctionTest ()

=======================================*/
void FinalRoundFunctionTest();


/* =====================================

    HightEncryptionTest()

=======================================*/
void HightEncryptionTest();


/* =====================================

    HightDecryptionTest()

=======================================*/
void HightDecryptionTest();

#endif


