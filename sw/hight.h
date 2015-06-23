//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Header file of hight core functions for HIGHT Integer Model ////
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

#ifndef __HIGHT_H__
#define __HIGHT_H__

#define byte unsigned char 
//#define ROUND_FUNCTION_DUMP

typedef struct _HIGHT_DATA {
	byte i_pct[8];		// plain or cipher text input data
	byte i_mk[16];		// master key input data
	byte wk[8]; 		// generated white key 
	byte delta[128];	// generated delta
	byte sk[128];		// generated sub key 
	byte iwf[8]; 		// result data of intial white function
	byte rf[33][8];		// result data of each round function
						// rf[0][x]s are unused
	byte fwf[8];		// result data of final white function
	byte o_cpt[8];		// cipher or plain text output data
} HIGHT_DATA;

enum HIGHT_OP{ENC=0, DEC};

/* =====================================

    WhiteningKeyGen (WKG)

=======================================*/
void WhiteningKeyGen(byte *i_mk, byte *o_wk);



/* =====================================

    DeltaGen (DG)

=======================================*/
void DeltaGen(byte *o_delta);



/* =====================================

    SubKeyGen (SKG)

=======================================*/
void SubKeyGen(byte *i_mk, byte *i_delta, byte *o_sk); 



/* =====================================

    InitialWhiteningFunction (IWF)

=======================================*/
void InitialWhiteningFunction(int i_op, byte *i_pc_text, byte *i_wk, byte *o_xx);


/* =====================================

    InterRoundFunction (IRF)

=======================================*/
void InterRoundFunction(int i_op, byte *i_xx, byte *i_rsk, byte *o_xx);


/* =====================================

    FinalRoundFunction (FRF)

=======================================*/
void FinalRoundFunction(int i_op, byte *i_xx, byte *i_rsk, byte *o_rf);


/* =====================================

    FinalWhiteningFunction (FWF)

=======================================*/
void FinalWhiteningFunction(int i_op, byte *i_rf, byte *i_wk, byte *o_cp_text);



/* =====================================

    HightTop (HT)

=======================================*/
void HightTop(int i_op, HIGHT_DATA *p_hight_data);

#endif
