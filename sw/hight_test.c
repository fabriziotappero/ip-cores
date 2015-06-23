//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Source file of top test function for HIGHT Integer Model    ////
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
#include "hight_test.h"
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

const byte vec_pt[4][8] = { // vec_pt[vec_num-1]
	{0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00},
	{0x77,0x66,0x55,0x44,0x33,0x22,0x11,0x00},
	{0xef,0xcd,0xab,0x89,0x67,0x45,0x23,0x01},
	{0x14,0x4a,0xa8,0xeb,0xe2,0x6b,0x1e,0xb4}
};

const byte vec_mk[4][16] = { // vec_mk[vec_num-1]
	{0xff,0xee,0xdd,0xcc,0xbb,0xaa,0x99,0x88,0x77,0x66,0x55,0x44,0x33,0x22,0x11,0x00},
	{0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xaa,0xbb,0xcc,0xdd,0xee,0xff},
	{0x0f,0x0e,0x0d,0x0c,0x0b,0x0a,0x09,0x08,0x07,0x06,0x05,0x04,0x03,0x02,0x01,0x00},
	{0xe7,0x2b,0x42,0x1d,0xb1,0x09,0xa5,0xcf,0x7d,0xd8,0xff,0x49,0xbc,0xc3,0xdb,0x28}
};

const byte vec_ct[4][8] = { // vec_ct[vec_num-1]
	{0xf2,0x03,0x4f,0xd9,0xae,0x18,0xf4,0x00},
	{0xd8,0xe6,0x43,0xe5,0x72,0x9f,0xce,0x23},
	{0x66,0xf4,0x23,0x8d,0xa2,0xb2,0x6f,0x7a},
	{0xc6,0x1f,0x9c,0x20,0x75,0x7a,0x04,0xcc}
};


/* =====================================

    HightTopTest

=======================================*/
void HightTopTest(const char *vec_id, int op_mode, int dump_opt, const char *dump_fname, HIGHT_DATA *p_hight_vec)
{
	enum{SUCC=0,FAIL};

	FILE *fdump = NULL;
	int compResult = FAIL;
	int i;
	byte expected1[8] = {0};
	byte expected2[8] = {0};

	// setup input vectors
	if(!strcmp(vec_id, "v1")) {
		if(op_mode == ENC) {
			memcpy(p_hight_vec->i_pct, vec_pt[0], 8);
		} else if(op_mode == DEC) {
			memcpy(p_hight_vec->i_pct, vec_ct[0], 8);
		} else {
			printf("Error\n");
			return;
		}
		memcpy(p_hight_vec->i_mk, vec_mk[0], 16);

	} else if (!strcmp(vec_id, "v2")) {
		if(op_mode == ENC) {
			memcpy(p_hight_vec->i_pct, vec_pt[1], 8);
		} else if(op_mode == DEC) {
			memcpy(p_hight_vec->i_pct, vec_ct[1], 8);
		} else {
			printf("Error!!\n");
			return;
		}
		memcpy(p_hight_vec->i_mk, vec_mk[1], 16);

	} else if (!strcmp(vec_id, "v3")) {
		if(op_mode == ENC) {
			memcpy(p_hight_vec->i_pct, vec_pt[2], 8);
		} else if(op_mode == DEC) {
			memcpy(p_hight_vec->i_pct, vec_ct[2], 8);
		} else {
			printf("Error!!!\n");
			return;
		}
		memcpy(p_hight_vec->i_mk, vec_mk[2], 16);

	} else if (!strcmp(vec_id, "v4")) {
		if(op_mode == ENC) {
			memcpy(p_hight_vec->i_pct, vec_pt[3], 8);
		} else if(op_mode == DEC) {
			memcpy(p_hight_vec->i_pct, vec_ct[3], 8);
		} else {
			printf("Error!!!!\n");
			return;
		}
		memcpy(p_hight_vec->i_mk, vec_mk[3], 16);

	} else if (!strcmp(vec_id, "rv")) {

	} else {
		printf("Error!!!!!!!!\n");
		return;
	}

	// Run !!!
	HightTop(op_mode, p_hight_vec);

	// Compare
	if(op_mode == ENC) {
		compResult = (((!strcmp(vec_id, "v1") && !memcmp(vec_ct[0], p_hight_vec->o_cpt, 8)) ||
			           (!strcmp(vec_id, "v2") && !memcmp(vec_ct[1], p_hight_vec->o_cpt, 8)) || 
					   (!strcmp(vec_id, "v3") && !memcmp(vec_ct[2], p_hight_vec->o_cpt, 8)) ||
					   (!strcmp(vec_id, "v4") && !memcmp(vec_ct[3], p_hight_vec->o_cpt, 8)))  ? SUCC : FAIL);
	} else if(op_mode == DEC) {
		compResult = (((!strcmp(vec_id, "v1") && !memcmp(vec_pt[0], p_hight_vec->o_cpt, 8)) ||
			           (!strcmp(vec_id, "v2") && !memcmp(vec_pt[1], p_hight_vec->o_cpt, 8)) || 
					   (!strcmp(vec_id, "v3") && !memcmp(vec_pt[2], p_hight_vec->o_cpt, 8)) ||
					   (!strcmp(vec_id, "v4") && !memcmp(vec_pt[3], p_hight_vec->o_cpt, 8)))  ? SUCC : FAIL);
	} else {
		printf("Error!!!\n");
		return;
	}

	// Display result
	// * ^.~ *
	printf("//===== %s =====//\n", (op_mode == ENC) ? "Encryption" :
		                           (op_mode == DEC) ? "Decryption" : "==Error=="); 
	printf("// %s [7..0]\n", (op_mode == ENC) ? "Plain text" : 
		                     (op_mode == DEC) ? "Cipher text" : "Error~");
	printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
		                                           p_hight_vec->i_pct[7],
		                                           p_hight_vec->i_pct[6],
												   p_hight_vec->i_pct[5],
												   p_hight_vec->i_pct[4],
												   p_hight_vec->i_pct[3],
												   p_hight_vec->i_pct[2],
												   p_hight_vec->i_pct[1],
												   p_hight_vec->i_pct[0]);
	// * ^.~ *
	printf("// Master key [15..0]\n");
	printf("%02x %02x %02x %02x %02x %02x %02x %02x\n%02x %02x %02x %02x %02x %02x %02x %02x\n",
                                                   p_hight_vec->i_mk[15],
												   p_hight_vec->i_mk[14],
												   p_hight_vec->i_mk[13],
												   p_hight_vec->i_mk[12],
												   p_hight_vec->i_mk[11],
												   p_hight_vec->i_mk[10],
												   p_hight_vec->i_mk[9],
												   p_hight_vec->i_mk[8],
												   p_hight_vec->i_mk[7],
												   p_hight_vec->i_mk[6],
												   p_hight_vec->i_mk[5],
												   p_hight_vec->i_mk[4],
												   p_hight_vec->i_mk[3],
												   p_hight_vec->i_mk[2],
												   p_hight_vec->i_mk[1],
												   p_hight_vec->i_mk[0]);
	// * ^.~ *
	printf("// Whitening key [7..0]\n");
	printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
												   p_hight_vec->wk[7],
		                                           p_hight_vec->wk[6],
												   p_hight_vec->wk[5],
												   p_hight_vec->wk[4],
												   p_hight_vec->wk[3],
												   p_hight_vec->wk[2],
												   p_hight_vec->wk[1],
												   p_hight_vec->wk[0]);
	// * ^.~ *
	printf("// Delta [0..127]\n");
	for(i=0; i<128; i+=8)
		printf("%02x %02x %02x %02x %02x %02x %02x %02x\n",
		                                           p_hight_vec->delta[i],
												   p_hight_vec->delta[i+1],
												   p_hight_vec->delta[i+2],
												   p_hight_vec->delta[i+3],
												   p_hight_vec->delta[i+4],
												   p_hight_vec->delta[i+5],
												   p_hight_vec->delta[i+6],
												   p_hight_vec->delta[i+7]);
	// * ^.~ *
	printf("// Sub key [0..127]\n");
	for(i=0; i<128; i+=8)
		printf("%02x %02x %02x %02x %02x %02x %02x %02x\n",
		                                           p_hight_vec->sk[i],
												   p_hight_vec->sk[i+1],
												   p_hight_vec->sk[i+2],
												   p_hight_vec->sk[i+3],
												   p_hight_vec->sk[i+4],
												   p_hight_vec->sk[i+5],
												   p_hight_vec->sk[i+6],
												   p_hight_vec->sk[i+7]);
	// * ^.~ *
	printf("// %s whitening function(1st) [7..0]\n", (op_mode == ENC) ? "Initial" :
		                                             (op_mode == DEC) ? "Final" : "Error~");
	if(op_mode == ENC){
		printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
		                                           p_hight_vec->iwf[7],
		                                           p_hight_vec->iwf[6],
												   p_hight_vec->iwf[5],
												   p_hight_vec->iwf[4],
												   p_hight_vec->iwf[3],
												   p_hight_vec->iwf[2],
												   p_hight_vec->iwf[1],
												   p_hight_vec->iwf[0]);
	} else if(op_mode == DEC){
			printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
		                                           p_hight_vec->fwf[7],
		                                           p_hight_vec->fwf[6],
												   p_hight_vec->fwf[5],
												   p_hight_vec->fwf[4],
												   p_hight_vec->fwf[3],
												   p_hight_vec->fwf[2],
												   p_hight_vec->fwf[1],
												   p_hight_vec->fwf[0]);
	}

	// * ^.~ *
	printf("// Round function 1~32 [7..0]\n");
	for(i=1; i<=32; i++)
		printf("%02x %02x %02x %02x %02x %02x %02x %02x\n",
		                                           p_hight_vec->rf[i][7],
												   p_hight_vec->rf[i][6],
												   p_hight_vec->rf[i][5],
												   p_hight_vec->rf[i][4],
												   p_hight_vec->rf[i][3],
												   p_hight_vec->rf[i][2],
												   p_hight_vec->rf[i][1],
												   p_hight_vec->rf[i][0]);

	// * ^.~ *
	printf("// %s whitening function(2nd) [7..0]\n", (op_mode == ENC) ? "Final" :
		                                             (op_mode == DEC) ? "Initial" : "Error~");
	if(op_mode == ENC){
		printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
		                                           p_hight_vec->fwf[7],
		                                           p_hight_vec->fwf[6],
												   p_hight_vec->fwf[5],
												   p_hight_vec->fwf[4],
												   p_hight_vec->fwf[3],
												   p_hight_vec->fwf[2],
												   p_hight_vec->fwf[1],
												   p_hight_vec->fwf[0]);
	} else if(op_mode == DEC){
			printf("%02x %02x %02x %02x %02x %02x %02x %02x\n", 
		                                           p_hight_vec->iwf[7],
		                                           p_hight_vec->iwf[6],
												   p_hight_vec->iwf[5],
												   p_hight_vec->iwf[4],
												   p_hight_vec->iwf[3],
												   p_hight_vec->iwf[2],
												   p_hight_vec->iwf[1],
												   p_hight_vec->iwf[0]);
	}

	// * ^.~ *
	printf("// %s [7..0]\n", (op_mode == ENC) ? "Cipher text" : 
		                     (op_mode == DEC) ? "Plain text" : "Error~");
	printf("%02x %02x %02x %02x %02x %02x %02x %02x (%s)\n\n\n", 
		                                           p_hight_vec->o_cpt[7],
		                                           p_hight_vec->o_cpt[6],
												   p_hight_vec->o_cpt[5],
												   p_hight_vec->o_cpt[4],
												   p_hight_vec->o_cpt[3],
												   p_hight_vec->o_cpt[2],
												   p_hight_vec->o_cpt[1],
												   p_hight_vec->o_cpt[0],
												   (compResult == SUCC) ? "Correct" : "Wrong");
	// Dump
	if(dump_opt) {
		if(!(fdump = fopen(dump_fname, "w+"))){
			printf("fail to create dump file... Error!!!\n");
			return;
		} 

		fclose(fdump);
	}
}
