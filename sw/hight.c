//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Source file of hight core functions for HIGHT Integer Model ////
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

#include "hight.h"
#include <stdio.h>
#include <string.h>

//#define SUB_KEY_GEN_DUMP


/* =====================================

    WhiteningKeyGen (WKG)

=======================================*/
void WhiteningKeyGen(byte *i_mk, byte *o_wk)
{


	o_wk[0] = i_mk[12];
	o_wk[1] = i_mk[13];
	o_wk[2] = i_mk[14];
	o_wk[3] = i_mk[15];
	o_wk[4] = i_mk[ 0];
	o_wk[5] = i_mk[ 1];
	o_wk[6] = i_mk[ 2];
	o_wk[7] = i_mk[ 3];
}



/* =====================================

    DeltaGen (DG)

=======================================*/
void DeltaGen(byte *o_delta)
{
	static byte s[133];
	int i;

	s[0] = 0 ;
	s[1] = 1 ;
	s[2] = 0 ;
	s[3] = 1 ;
	s[4] = 1 ;
	s[5] = 0 ;
    s[6] = 1 ;
	

	for(i=1; i<128; i++){
		s[i+6]= s[i+2]^s[i-1];
	}

	o_delta[0] = s[0]|s[1]<<1|s[2]<<2|s[3]<<3|s[4]<<4|s[5]<<5|s[6]<<6;
	for(i=1; i<128; i++){
		o_delta[i] = s[i]|s[i+1]<<1|s[i+2]<<2|s[i+3]<<3|s[i+4]<<4|s[i+5]<<5|s[i+6]<<6;
	}
}



/* =====================================

    SubKeyGen (SKG)

=======================================*/
void SubKeyGen(byte *i_mk, byte *i_delta, byte *o_sk)
{
	int i, j;
#ifdef SUB_KEY_GEN_DUMP
	FILE *fp = fopen("result.txt", "w+");
#endif

	/* 
	// print delta values
	for (i=0; i<128; i++){
		printf("%02X ", i_delta[i]);
		if(i%8 == 7)
			printf("\n");
	}
	*/

	for(i=0; i<8; i++){
		for(j=0; j<8; j++){
			o_sk[16*i+j]=(byte)(i_mk[(j-i)&7]+i_delta[16*i+j]);
#ifdef SUB_KEY_GEN_DUMP
			fprintf(fp, "rk[%d]:%02X = (mk[%d]:%02X + delta[%d]:%02X\n", 16*i+j, o_sk[16*i+j],
				                                                       (j-i)&7, i_mk[(j-i)&7],
                                                                       16*i+j, i_delta[16*i+j]); // comp
#endif
		}
		for(j=0; j<8; j++){
			o_sk[16*i+j+8]=(byte)(i_mk[((j-i)&7)+8]+i_delta[16*i+j+8]);
#ifdef SUB_KEY_GEN_DUMP
			fprintf(fp, "rk[%d]:%02X = (mk[%d]:%02X + delta[%d]:%02X\n", 16*i+j+8, o_sk[16*i+j+8],
				                                                       ((j-i)&7)+8, i_mk[((j-i)&7)+8],
		                                                               16*i+j+8, i_delta[16*i+j+8]); // comp
#endif
		}
	}

#ifdef SUB_KEY_GEN_DUMP
	fclose(fp); // comp
#endif
}


/* =====================================

    InitialWhiteningFunction (IWF)

=======================================*/
void InitialWhiteningFunction(int i_op, byte *i_pc_text, byte *i_wk, byte *o_xx)
{	
	o_xx[7] =  i_pc_text[7];
	o_xx[6] =  (i_op == ENC) ? i_pc_text[6] ^ i_wk[3] :
		                       i_pc_text[6] ^ i_wk[3] ; // op == DEC   
	o_xx[5] =  i_pc_text[5];
	o_xx[4] =  (i_op == ENC) ? (i_pc_text[4] + i_wk[2])&0xff :
		                       (i_pc_text[4] - i_wk[2])&0xff ; // op == DEC
	o_xx[3] =  i_pc_text[3];
	o_xx[2] =  (i_op == ENC) ? i_pc_text[2] ^ i_wk[1] :
		                       i_pc_text[2] ^ i_wk[1] ; // op == DEC
	o_xx[1] =  i_pc_text[1];
	o_xx[0] =  (i_op == ENC) ? (i_pc_text[0] + i_wk[0])&0xff : 
	                           (i_pc_text[0] - i_wk[0])&0xff ; // op == DEC

}


/* =====================================

    InterRoundFunction (IRF)

=======================================*/
void InterRoundFunction(int i_op, byte *i_xx, byte *i_rsk, byte*o_xx)
{
	o_xx[7] = (i_op == ENC) ? i_xx[6] : 
		                      i_xx[0] ;

	o_xx[6] = (i_op == ENC) ? i_xx[5] + (((i_xx[4]<<3 | i_xx[4]>>5) ^ (i_xx[4]<<4 | i_xx[4]>>4) 
		      ^ (i_xx[4]<<6 | i_xx[4]>>2))^i_rsk[2])&0xff :
	                          i_xx[7] ^ (((i_xx[6]<<1 | i_xx[6]>>7) ^ (i_xx[6]<<2 | i_xx[6]>>6) 
			  ^ (i_xx[6]<<7 | i_xx[6]>>1))+i_rsk[0]&0xff) ;

	o_xx[5] = (i_op == ENC) ? i_xx[4] :
		                      i_xx[6] ;

	o_xx[4] = (i_op == ENC) ? i_xx[3] ^ (((i_xx[2]<<1 | i_xx[2]>>7) ^ (i_xx[2]<<2 | i_xx[2]>>6) 
		      ^ (i_xx[2]<<7 | i_xx[2]>>1))+i_rsk[1]&0xff) :
	                          i_xx[5] - (((i_xx[4]<<3 | i_xx[4]>>5) ^ (i_xx[4]<<4 | i_xx[4]>>4) 
		      ^ (i_xx[4]<<6 | i_xx[4]>>2))^i_rsk[1])&0xff ;

	o_xx[3] = (i_op == ENC) ? i_xx[2] :
		                      i_xx[4] ;

	o_xx[2] = (i_op == ENC) ? i_xx[1] + (((i_xx[0]<<3 | i_xx[0]>>5) ^ (i_xx[0]<<4 | i_xx[0]>>4) 
		      ^ (i_xx[0]<<6 | i_xx[0]>>2))^i_rsk[0])&0xff :
	                          i_xx[3] ^ (((i_xx[2]<<1 | i_xx[2]>>7) ^ (i_xx[2]<<2 | i_xx[2]>>6) 
			  ^ (i_xx[2]<<7 | i_xx[2]>>1))+i_rsk[2]&0xff) ;
	o_xx[1] = (i_op == ENC) ? i_xx[0] :
		                      i_xx[2] ;

	o_xx[0] = (i_op == ENC) ? i_xx[7] ^ (((i_xx[6]<<1 | i_xx[6]>>7) ^ (i_xx[6]<<2 | i_xx[6]>>6) 
		      ^ (i_xx[6]<<7 | i_xx[6]>>1))+i_rsk[3]&0xff) : 
	                          i_xx[1] - (((i_xx[0]<<3 | i_xx[0]>>5) ^ (i_xx[0]<<4 | i_xx[0]>>4) 
		      ^ (i_xx[0]<<6 | i_xx[0]>>2))^i_rsk[3])&0xff ;
}


/* =====================================

    FinalRoundFunction (FRF)

=======================================*/
void FinalRoundFunction(int i_op, byte *i_xx, byte *i_rsk, byte *o_rf)
{

	o_rf[7] = (i_op == ENC) ? i_xx[7] ^ (((i_xx[6]<<1 | i_xx[6]>>7) ^ (i_xx[6]<<2 | i_xx[6]>>6) ^ 
		                      (i_xx[6]<<7 | i_xx[6]>>1))+i_rsk[3]&0xff) : 
	                          i_xx[7] ^ (((i_xx[6]<<1 | i_xx[6]>>7) ^ (i_xx[6]<<2 | i_xx[6]>>6) ^ 
		                      (i_xx[6]<<7 | i_xx[6]>>1))+i_rsk[0]&0xff) ;

	o_rf[6] = i_xx[6];

	o_rf[5] = (i_op == ENC) ? i_xx[5] + (((i_xx[4]<<3 | i_xx[4]>>5) ^ (i_xx[4]<<4 | i_xx[4]>>4) ^  
		                      (i_xx[4]<<6 | i_xx[4]>>2))^i_rsk[2])&0xff : 
	                          i_xx[5] - (((i_xx[4]<<3 | i_xx[4]>>5) ^ (i_xx[4]<<4 | i_xx[4]>>4) ^  
		                      (i_xx[4]<<6 | i_xx[4]>>2))^i_rsk[1])&0xff;

	o_rf[4] = i_xx[4];

	o_rf[3] = (i_op == ENC) ? i_xx[3] ^ (((i_xx[2]<<1 | i_xx[2]>>7) ^ (i_xx[2]<<2 | i_xx[2]>>6) ^ 
		                      (i_xx[2]<<7 | i_xx[2]>>1))+i_rsk[1]&0xff) : 
	                          i_xx[3] ^ (((i_xx[2]<<1 | i_xx[2]>>7) ^ (i_xx[2]<<2 | i_xx[2]>>6) ^ 
		                      (i_xx[2]<<7 | i_xx[2]>>1))+i_rsk[2]&0xff);

	o_rf[2] =  i_xx[2];

	o_rf[1] = (i_op == ENC) ? i_xx[1] + (((i_xx[0]<<3 | i_xx[0]>>5) ^ (i_xx[0]<<4 | i_xx[0]>>4) ^ 
		                      (i_xx[0]<<6 | i_xx[0]>>2))^i_rsk[0])&0xff : 
	                          i_xx[1] - (((i_xx[0]<<3 | i_xx[0]>>5) ^ (i_xx[0]<<4 | i_xx[0]>>4) ^ 
		                      (i_xx[0]<<6 | i_xx[0]>>2))^i_rsk[3])&0xff;

	o_rf[0] =  i_xx[0];

}


/* =====================================

    FinalWhiteningFunction (FWF)

=======================================*/
void FinalWhiteningFunction(int i_op, byte *i_rf, byte *i_wk, byte *o_cp_text)
{

	o_cp_text[7] = (i_op == ENC) ? i_rf[7] : 
	                               i_rf[7] ;            
	o_cp_text[6] = (i_op == ENC) ? i_rf[6] ^ i_wk[7] : 
		                           i_rf[6] ^ i_wk[7] ; // op == DEC  ;    
	o_cp_text[5] = (i_op == ENC) ? i_rf[5] :
	                               i_rf[5];
	o_cp_text[4] = (i_op == ENC) ? (i_rf[4] + i_wk[6])&0xff : 
		                           (i_rf[4] - i_wk[6])&0xff  ;
	o_cp_text[3] = (i_op == ENC) ? i_rf[3] :
		                           i_rf[3] ;
	o_cp_text[2] = (i_op == ENC) ? i_rf[2] ^ i_wk[5] : 
		                           i_rf[2] ^ i_wk[5] ; // op == DEC
	o_cp_text[1] = (i_op == ENC) ? i_rf[1] : 
		                           i_rf[1] ;
	o_cp_text[0] = (i_op == ENC) ? (i_rf[0] + i_wk[4])&0xff :
		                           (i_rf[0] - i_wk[4])&0xff ; // op == DEC;

}


/* =====================================

    HightTop (HT)

=======================================*/
void HightTop(int i_op, HIGHT_DATA *p_hight_data)
{
	int i;
	byte w_sk[128] = {0};
	byte w_wf1[8] = {0};
	byte w_wf2[8] = {0};

	// Whitening Key Generation
	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 
	
	// Delta Generation
	DeltaGen(p_hight_data->delta);	

	// Sub Key Generation
	SubKeyGen(p_hight_data->i_mk,		
			  p_hight_data->delta,
			  p_hight_data->sk);

	// re-arrange subkey index 
	if(i_op == ENC) {
		for(i=0; i<=127; i++)
			w_sk[i] = p_hight_data->sk[i];
	} else if(i_op == DEC) {
		for(i=0; i<=127; i++)
			w_sk[127-i] = p_hight_data->sk[i];
	} else {
		printf("Error\n");
	}
	
	// select proper WF related to i_op 
	if(i_op == ENC) {
		InitialWhiteningFunction(i_op, p_hight_data->i_pct, p_hight_data->wk, p_hight_data->iwf);
		memcpy(w_wf1, p_hight_data->iwf, 8);
	} else if(i_op == DEC) {
		FinalWhiteningFunction(i_op, p_hight_data->i_pct, p_hight_data->wk, p_hight_data->fwf);
		memcpy(w_wf1, p_hight_data->fwf, 8);
	} else {
		printf("Error\n");
	}


	// RoundFunction1
	InterRoundFunction(i_op,
					w_wf1,
					w_sk,
					p_hight_data->rf[1]);
	
	// InterRoundFunction2~31
	for(i=1; i<31; i++){
		InterRoundFunction(i_op,
						p_hight_data->rf[i],
						w_sk+(i*4),
						p_hight_data->rf[i+1]);
	}
	// RoundFunction32
	FinalRoundFunction(i_op,
					p_hight_data->rf[31],
					w_sk+(31*4),
					p_hight_data->rf[32]);

	// select proper WF related to i_op 
	if(i_op == ENC){
		FinalWhiteningFunction(i_op, p_hight_data->rf[32], p_hight_data->wk, p_hight_data->fwf);
		memcpy(w_wf2, p_hight_data->fwf, 8);
	} else if(i_op == DEC) {
		InitialWhiteningFunction(i_op, p_hight_data->rf[32], p_hight_data->wk, p_hight_data->iwf);
		memcpy(w_wf2, p_hight_data->iwf, 8);
	} else {
		printf("Error\n");
	}

	// assign output
	memcpy(p_hight_data->o_cpt, w_wf2, 8);
}
