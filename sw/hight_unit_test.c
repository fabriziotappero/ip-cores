//////////////////////////////////////////////////////////////////////
////                                                              ////
////  Source file of unit test functions for HIGHT Integer Model  ////
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

extern HIGHT_DATA *p_hight_data;

/* =====================================

    DeltaGenTest()

=======================================*/
void DeltaGenTest()
{
	int i;

	printf("\n\n===== DeltaGenTest =====\n\n");

	DeltaGen(p_hight_data->delta);

	for (i=0; i<128; i++){
		printf("%02X ", p_hight_data->delta[i]);
		if(i%8 == 7)
			printf("\n");
	}
}


/* =====================================

    SubKeyGenTest()

=======================================*/
void SubKeyGenTest()
{
	int i ;

	printf("\n\n===== SubKeyGenTest =====\n\n");

	/*
	// Test vectors 1
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x11;
	p_hight_data->i_mk[13] = 0x22;
	p_hight_data->i_mk[12] = 0x33;
	p_hight_data->i_mk[11] = 0x44;
	p_hight_data->i_mk[10] = 0x55;
	p_hight_data->i_mk[9] = 0x66;
	p_hight_data->i_mk[8] = 0x77;
	p_hight_data->i_mk[7] = 0x88;
	p_hight_data->i_mk[6] = 0x99;
	p_hight_data->i_mk[5] = 0xaa;
	p_hight_data->i_mk[4] = 0xbb;
	p_hight_data->i_mk[3] = 0xcc;
	p_hight_data->i_mk[2] = 0xdd;
	p_hight_data->i_mk[1] = 0xee;
	p_hight_data->i_mk[0] = 0xff;
	*/

	/*
	// Test vectors 2
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9] = 0x99;
	p_hight_data->i_mk[8] = 0x88;
	p_hight_data->i_mk[7] = 0x77;
	p_hight_data->i_mk[6] = 0x66;
	p_hight_data->i_mk[5] = 0x55;
	p_hight_data->i_mk[4] = 0x44;
	p_hight_data->i_mk[3] = 0x33;
	p_hight_data->i_mk[2] = 0x22;
	p_hight_data->i_mk[1] = 0x11;
	p_hight_data->i_mk[0] = 0x00;
	*/


	/*
	// Test vector 3
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9] = 0x06;
	p_hight_data->i_mk[8] = 0x07;
	p_hight_data->i_mk[7] = 0x08;
	p_hight_data->i_mk[6] = 0x09;
	p_hight_data->i_mk[5] = 0x0a;
	p_hight_data->i_mk[4] = 0x0b;
	p_hight_data->i_mk[3] = 0x0c;
	p_hight_data->i_mk[2] = 0x0d;
	p_hight_data->i_mk[1] = 0x0e;
	p_hight_data->i_mk[0] = 0x0f;
	*/

	// Test vector 4
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9] = 0xd8;
	p_hight_data->i_mk[8] = 0x7d;
	p_hight_data->i_mk[7] = 0xcf;
	p_hight_data->i_mk[6] = 0xa5;
	p_hight_data->i_mk[5] = 0x09;
	p_hight_data->i_mk[4] = 0xb1;
	p_hight_data->i_mk[3] = 0x1d;
	p_hight_data->i_mk[2] = 0x42;
	p_hight_data->i_mk[1] = 0x2b;
	p_hight_data->i_mk[0] = 0xe7;

	DeltaGen(p_hight_data->delta);

	SubKeyGen(p_hight_data->i_mk,
			p_hight_data->delta,
			p_hight_data->sk);
	
	for (i=0; i<128; i+=4){
		printf("%02x ", p_hight_data->sk[i+3]);
		printf("%02x ", p_hight_data->sk[i+2]);
		printf("%02x ", p_hight_data->sk[i+1]);
		printf("%02x ", p_hight_data->sk[i]);
		printf("\n");
	}
}


/* =====================================

    WhiteningKeyGenTest()

=======================================*/
void WhiteningKeyGenTest ()
{
	p_hight_data->i_mk[0] = 0; 
	p_hight_data->i_mk[1] = 1; 
	p_hight_data->i_mk[2] = 2; 
	p_hight_data->i_mk[3] = 3; 
	p_hight_data->i_mk[4] = -1; 
	p_hight_data->i_mk[5] = -1; 
	p_hight_data->i_mk[6] = -1; 
	p_hight_data->i_mk[7] = -1; 
	p_hight_data->i_mk[8] = -1;
	p_hight_data->i_mk[9] = -1;
	p_hight_data->i_mk[10] = -1;
	p_hight_data->i_mk[11] = -1;
	p_hight_data->i_mk[12] = 12;
	p_hight_data->i_mk[13] = 13;
	p_hight_data->i_mk[14] = 14;
	p_hight_data->i_mk[15] = 15;

	printf("\n\n===== WhiteningKeyGenTest =====\n\n"); 

	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 
	
	if ( p_hight_data->wk[0] == 12) 
		printf("wk[0] = %d (Correct) \n",p_hight_data->wk[0]);
	else     
		printf("wk[0] = %d (Wrong => expected = 12) \n",p_hight_data->wk[0]);

	if ( p_hight_data->wk[1] == 13) 
		printf("wk[1] = %d (Correct) \n",p_hight_data->wk[1]);
	else     
		printf("wk[1] = %d (Wrong => expected = 13) \n",p_hight_data->wk[1]);

	if ( p_hight_data->wk[2] == 14)
		printf("wk[2] = %d (Correct) \n",p_hight_data->wk[2]);
	else     
		printf("wk[2] = %d (Wrong => expected = 14) \n",p_hight_data->wk[2]);

	if ( p_hight_data->wk[3] == 15)
		printf("wk[3] = %d (Correct) \n",p_hight_data->wk[3]);
	else     
		printf("wk[3] = %d (Wrong => expected = 15) \n",p_hight_data->wk[3]);

	if ( p_hight_data->wk[4] == 0)
		printf("wk[4] = %d (Correct) \n",p_hight_data->wk[4]);
	else     
		printf("wk[4] = %d (Wrong => expected = 0) \n",p_hight_data->wk[4]);

	if ( p_hight_data->wk[5] == 1)
		printf("wk[5] = %d (Correct) \n",p_hight_data->wk[5]);
	else     
		printf("wk[5] = %d (Wrong => expected = 1) \n",p_hight_data->wk[5]);

	if ( p_hight_data->wk[6] == 2)
		printf("wk[6] = %d (Correct) \n",p_hight_data->wk[6]);
	else     
		printf("wk[6] = %d (Wrong => expected = 2) \n",p_hight_data->wk[6]);

	if ( p_hight_data->wk[7] == 3)
		printf("wk[7] = %d (Correct) \n",p_hight_data->wk[7]);
	else     
		printf("wk[7] = %d (Wrong => expected = [3]) \n",p_hight_data->wk[7]);
}


/* =====================================

    InitialWhiteningFunctionTest()

=======================================*/
void InitialWhiteningFunctionTest ()
{
	byte expected_iwf[8] = {0};
	int i_op = -1;
	int i;

	printf("\n\n===== InitialWhiteningFunctionTest =====\n\n");

	/////////////////////////////////////////////////
	//
	// Encryption vector
	//
	/////////////////////////////////////////////////
	printf("\n\n===== Encryption operation =====\n\n");

#if 0
	// Test vectors 1
	printf("test vectors 1\n");
	
	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x11;
	p_hight_data->i_mk[13] = 0x22;
	p_hight_data->i_mk[12] = 0x33;
	p_hight_data->i_mk[11] = 0x44;
	p_hight_data->i_mk[10] = 0x55;
	p_hight_data->i_mk[9]  = 0x66;
	p_hight_data->i_mk[8]  = 0x77;
	p_hight_data->i_mk[7]  = 0x88;
	p_hight_data->i_mk[6]  = 0x99;
	p_hight_data->i_mk[5]  = 0xaa;
	p_hight_data->i_mk[4]  = 0xbb;
	p_hight_data->i_mk[3]  = 0xcc;
	p_hight_data->i_mk[2]  = 0xdd;
	p_hight_data->i_mk[1]  = 0xee;
	p_hight_data->i_mk[0]  = 0xff;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0x00;
	p_hight_data->i_pct[5]  = 0x00;
	p_hight_data->i_pct[4]  = 0x00;
	p_hight_data->i_pct[3]  = 0x00;
	p_hight_data->i_pct[2]  = 0x00;
	p_hight_data->i_pct[1]  = 0x00;
	p_hight_data->i_pct[0]  = 0x00;

	// expected iwf
	expected_iwf[7]        = 0x00;
	expected_iwf[6]        = 0x00;
	expected_iwf[5]        = 0x00;
	expected_iwf[4]        = 0x11;
	expected_iwf[3]        = 0x00;
	expected_iwf[2]        = 0x22;
	expected_iwf[1]        = 0x00;
	expected_iwf[0]        = 0x33;

#elif 0
	// Test vectors 2
	printf("test vectors 2\n");
	
	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9]  = 0x99;
	p_hight_data->i_mk[8]  = 0x88;
	p_hight_data->i_mk[7]  = 0x77;
	p_hight_data->i_mk[6]  = 0x66;
	p_hight_data->i_mk[5]  = 0x55;
	p_hight_data->i_mk[4]  = 0x44;
	p_hight_data->i_mk[3]  = 0x33;
	p_hight_data->i_mk[2]  = 0x22;
	p_hight_data->i_mk[1]  = 0x11;
	p_hight_data->i_mk[0]  = 0x00;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0x11;
	p_hight_data->i_pct[5]  = 0x22;
	p_hight_data->i_pct[4]  = 0x33;
	p_hight_data->i_pct[3]  = 0x44;
	p_hight_data->i_pct[2]  = 0x55;
	p_hight_data->i_pct[1]  = 0x66;
	p_hight_data->i_pct[0]  = 0x77;

	// expected iwf
	expected_iwf[7]        = 0x00;
	expected_iwf[6]        = 0xee;
	expected_iwf[5]        = 0x22;
	expected_iwf[4]        = 0x21;
	expected_iwf[3]        = 0x44;
	expected_iwf[2]        = 0x88;
	expected_iwf[1]        = 0x66;
	expected_iwf[0]        = 0x43;

#elif 0
	// Test vector 3
	printf("test vectors 3\n");
	
	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9]  = 0x06;
	p_hight_data->i_mk[8]  = 0x07;
	p_hight_data->i_mk[7]  = 0x08;
	p_hight_data->i_mk[6]  = 0x09;
	p_hight_data->i_mk[5]  = 0x0a;
	p_hight_data->i_mk[4]  = 0x0b;
	p_hight_data->i_mk[3]  = 0x0c;
	p_hight_data->i_mk[2]  = 0x0d;
	p_hight_data->i_mk[1]  = 0x0e;
	p_hight_data->i_mk[0]  = 0x0f;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0x01;
	p_hight_data->i_pct[6]  = 0x23;
	p_hight_data->i_pct[5]  = 0x45;
	p_hight_data->i_pct[4]  = 0x67;
	p_hight_data->i_pct[3]  = 0x89;
	p_hight_data->i_pct[2]  = 0xab;
	p_hight_data->i_pct[1]  = 0xcd;
	p_hight_data->i_pct[0]  = 0xef;

	// expected iwf
	expected_iwf[7]        = 0x01;
	expected_iwf[6]        = 0x23;
	expected_iwf[5]        = 0x45;
	expected_iwf[4]        = 0x68;
	expected_iwf[3]        = 0x89;
	expected_iwf[2]        = 0xa9;
	expected_iwf[1]        = 0xcd;
	expected_iwf[0]        = 0xf2;

#elif 0
	// Test vector 4
	printf("test vectors 4\n");
	
	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9]  = 0xd8;
	p_hight_data->i_mk[8]  = 0x7d;
	p_hight_data->i_mk[7]  = 0xcf;
	p_hight_data->i_mk[6]  = 0xa5;
	p_hight_data->i_mk[5]  = 0x09;
	p_hight_data->i_mk[4]  = 0xb1;
	p_hight_data->i_mk[3]  = 0x1d;
	p_hight_data->i_mk[2]  = 0x42;
	p_hight_data->i_mk[1]  = 0x2b;
	p_hight_data->i_mk[0]  = 0xe7;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0xb4;
	p_hight_data->i_pct[6]  = 0x1e;
	p_hight_data->i_pct[5]  = 0x6b;
	p_hight_data->i_pct[4]  = 0xe2;
	p_hight_data->i_pct[3]  = 0xeb;
	p_hight_data->i_pct[2]  = 0xa8;
	p_hight_data->i_pct[1]  = 0x4a;
	p_hight_data->i_pct[0]  = 0x14;

	// expected iwf
	expected_iwf[7]        = 0xb4;
	expected_iwf[6]        = 0x36;
	expected_iwf[5]        = 0x6b;
	expected_iwf[4]        = 0xbd;
	expected_iwf[3]        = 0xeb;
	expected_iwf[2]        = 0x6b;
	expected_iwf[1]        = 0x4a;
	expected_iwf[0]        = 0xd0;
#endif


	/////////////////////////////////////////////////
	//
	// Decrytion vector
	//
	/////////////////////////////////////////////////
	
	printf("\n\n===== Decrytion operation =====\n\n");

#if 1
	// Test vectors 1
	printf("test vectors 1\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15]    = 0x00;
	p_hight_data->i_mk[14]    = 0x11;
	p_hight_data->i_mk[13]    = 0x22;
	p_hight_data->i_mk[12]    = 0x33;
	p_hight_data->i_mk[11]    = 0x44;
	p_hight_data->i_mk[10]    = 0x55;
	p_hight_data->i_mk[9]     = 0x66;
	p_hight_data->i_mk[8]     = 0x77;
	p_hight_data->i_mk[7]     = 0x88;
	p_hight_data->i_mk[6]     = 0x99;
	p_hight_data->i_mk[5]     = 0xaa;
	p_hight_data->i_mk[4]     = 0xbb;
	p_hight_data->i_mk[3]     = 0xcc;
	p_hight_data->i_mk[2]     = 0xdd;
	p_hight_data->i_mk[1]     = 0xee;
	p_hight_data->i_mk[0]     = 0xff;

	// Round32 output
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0xf4;
	p_hight_data->i_pct[5]  = 0x18;
	p_hight_data->i_pct[4]  = 0xae;
	p_hight_data->i_pct[3]  = 0xd9;
	p_hight_data->i_pct[2]  = 0x4f;
	p_hight_data->i_pct[1]  = 0x03;
	p_hight_data->i_pct[0]  = 0xf2;

	// expected iwf
	expected_iwf[7]        = 0x00;
	expected_iwf[6]        = 0x38;
	expected_iwf[5]        = 0x18;
	expected_iwf[4]        = 0xd1;
	expected_iwf[3]        = 0xd9;
	expected_iwf[2]        = 0xa1;
	expected_iwf[1]        = 0x03;
	expected_iwf[0]        = 0xf3;


#elif 0
	// Test vectors 2
	printf("test vectors 2\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15]   = 0xff;
	p_hight_data->i_mk[14]   = 0xee;
	p_hight_data->i_mk[13]   = 0xdd;
	p_hight_data->i_mk[12]   = 0xcc;
	p_hight_data->i_mk[11]   = 0xbb;
	p_hight_data->i_mk[10]   = 0xaa;
	p_hight_data->i_mk[9]    = 0x99;
	p_hight_data->i_mk[8]    = 0x88;
	p_hight_data->i_mk[7]    = 0x77;
	p_hight_data->i_mk[6]    = 0x66;
	p_hight_data->i_mk[5]    = 0x55;
	p_hight_data->i_mk[4]    = 0x44;
	p_hight_data->i_mk[3]    = 0x33;
	p_hight_data->i_mk[2]    = 0x22;
	p_hight_data->i_mk[1]    = 0x11;
	p_hight_data->i_mk[0]    = 0x00;
	
	//Round32 output
	p_hight_data->rf[32][7]    = 0x00;
	p_hight_data->rf[32][6]    = 0xee;
	p_hight_data->rf[32][5]    = 0x22;
	p_hight_data->rf[32][4]    = 0x21;
	p_hight_data->rf[32][3]    = 0x44;
	p_hight_data->rf[32][2]    = 0x88;
	p_hight_data->rf[32][1]    = 0x66;
	p_hight_data->rf[32][0]    = 0x43;

	// expected iwf
	expected_iwf[7]          = 0x00;
	expected_iwf[6]          = 0x11;
	expected_iwf[5]          = 0x22;
	expected_iwf[4]          = 0x33;
	expected_iwf[3]          = 0x44;
	expected_iwf[2]          = 0x55;
	expected_iwf[1]          = 0x66;
	expected_iwf[0]          = 0x77;

#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15]   = 0x00;
	p_hight_data->i_mk[14]   = 0x01;
	p_hight_data->i_mk[13]   = 0x02;
	p_hight_data->i_mk[12]   = 0x03;
	p_hight_data->i_mk[11]   = 0x04;
	p_hight_data->i_mk[10]   = 0x05;
	p_hight_data->i_mk[9]    = 0x06;
	p_hight_data->i_mk[8]    = 0x07;
	p_hight_data->i_mk[7]    = 0x08;
	p_hight_data->i_mk[6]    = 0x09;
	p_hight_data->i_mk[5]    = 0x0a;
	p_hight_data->i_mk[4]    = 0x0b;
	p_hight_data->i_mk[3]    = 0x0c;
	p_hight_data->i_mk[2]    = 0x0d;
	p_hight_data->i_mk[1]    = 0x0e;
	p_hight_data->i_mk[0]    = 0x0f;
	
	//Round32 output
	p_hight_data->rf[32][7]  = 0x01;
	p_hight_data->rf[32][6]  = 0x23;
	p_hight_data->rf[32][5]  = 0x45;
	p_hight_data->rf[32][4]  = 0x68;
	p_hight_data->rf[32][3]  = 0x89;
	p_hight_data->rf[32][2]  = 0xa9;
	p_hight_data->rf[32][1]  = 0xcd;
	p_hight_data->rf[32][0]  = 0xf2;

	// expected iwf
	expected_iwf[7]          = 0x01;
	expected_iwf[6]          = 0x23;
	expected_iwf[5]          = 0x45;
	expected_iwf[4]          = 0x67;
	expected_iwf[3]          = 0x89;
	expected_iwf[2]          = 0xab;
	expected_iwf[1]          = 0xcd;
	expected_iwf[0]          = 0xef;

#elif 0
	// Test vector 4
	printf("test vectors 4\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15]   = 0x28;
	p_hight_data->i_mk[14]   = 0xdb;
	p_hight_data->i_mk[13]   = 0xc3;
	p_hight_data->i_mk[12]   = 0xbc;
	p_hight_data->i_mk[11]   = 0x49;
	p_hight_data->i_mk[10]   = 0xff;
	p_hight_data->i_mk[9]    = 0xd8;
	p_hight_data->i_mk[8]    = 0x7d;
	p_hight_data->i_mk[7]    = 0xcf;
	p_hight_data->i_mk[6]    = 0xa5;
	p_hight_data->i_mk[5]    = 0x09;
	p_hight_data->i_mk[4]    = 0xb1;
	p_hight_data->i_mk[3]    = 0x1d;
	p_hight_data->i_mk[2]    = 0x42;
	p_hight_data->i_mk[1]    = 0x2b;
	p_hight_data->i_mk[0]    = 0xe7;
	
	//Round32 output
	p_hight_data->rf[32][7]  = 0xb4;
	p_hight_data->rf[32][6]  = 0x36;
	p_hight_data->rf[32][5]  = 0x6b;
	p_hight_data->rf[32][4]  = 0xbd;
	p_hight_data->rf[32][3]  = 0xeb;
	p_hight_data->rf[32][2]  = 0x6b;
	p_hight_data->rf[32][1]  = 0x4a;
	p_hight_data->rf[32][0]  = 0xd0;

	// expected iwf
	expected_iwf[7]          = 0xb4;
	expected_iwf[6]          = 0x1e;
	expected_iwf[5]          = 0x6b;
	expected_iwf[4]          = 0xe2;
	expected_iwf[3]          = 0xeb;
	expected_iwf[2]          = 0xa8;
	expected_iwf[1]          = 0x4a;
	expected_iwf[0]          = 0x14;
#endif



	/////////////////////////////////////////////////
	//
	// Run test
	//
	/////////////////////////////////////////////////
	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 
	
	InitialWhiteningFunction(i_op ,p_hight_data->i_pct, p_hight_data->wk, p_hight_data->iwf);

	printf("\n>> operation : %s <<<\n", (i_op == ENC) ? "encryption" : "decrytion");

	printf("\n>>> %s text <<<\n", (i_op == ENC) ? "plain" : "cipher");
	for(i=7; i>=0; i--) {
		printf("pct[%02d] = %02x\n", i, p_hight_data->i_pct[i]);
	}

	printf("\n>>> master key <<<\n");
	for(i=15; i>=0; i--) {
		printf("mk[%02d] = %02x\n", i, p_hight_data->i_mk[i]);
	}

	printf("\n>>> InitialWhiteningFunction result <<<\n");
	for(i=7; i>=0; i--) {
		printf("iwf[%02d] = %02x ",i, p_hight_data->iwf[i]);
		if(p_hight_data->iwf[i] == expected_iwf[i])
			printf("Correct\n");
		else
			printf("Wrong (expected = %02x) \n", expected_iwf[i]);
	}
}


/* =====================================

    FinalWhiteningFunctionTest()

=======================================*/
void FinalWhiteningFunctionTest ()
{
	byte expected_fwf[8] = {0};
	int i_op = -1;
	int i;

	printf("\n\n===== FinalWhiteningFunctionTest =====\n\n");

	/////////////////////////////////////////////////
	//
	// Encryption vector
	//
	/////////////////////////////////////////////////
	printf("\n\n===== Encryption operation =====\n\n");

#if 0
	// Test vectors 1
	printf("test vectors 1\n");

	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15]   = 0x00 ;
	p_hight_data->i_mk[14]   = 0x11 ;
	p_hight_data->i_mk[13]   = 0x22 ;
	p_hight_data->i_mk[12]   = 0x33 ;
	p_hight_data->i_mk[11]   = 0x44 ;
	p_hight_data->i_mk[10]   = 0x55 ;
	p_hight_data->i_mk[9]    = 0x66 ;
	p_hight_data->i_mk[8]    = 0x77 ;
	p_hight_data->i_mk[7]    = 0x88 ;
	p_hight_data->i_mk[6]    = 0x99 ;
	p_hight_data->i_mk[5]    = 0xaa ;
	p_hight_data->i_mk[4]    = 0xbb ;
	p_hight_data->i_mk[3]    = 0xcc ;
	p_hight_data->i_mk[2]    = 0xdd ;
	p_hight_data->i_mk[1]    = 0xee ;
	p_hight_data->i_mk[0]    = 0xff;

	// Round32 output
	p_hight_data->rf[32][7]  = 0x00;
	p_hight_data->rf[32][6]  = 0x38;
	p_hight_data->rf[32][5]  = 0x18;
	p_hight_data->rf[32][4]  = 0xd1;
	p_hight_data->rf[32][3]  = 0xd9;
	p_hight_data->rf[32][2]  = 0xa1;
	p_hight_data->rf[32][1]  = 0x03;
	p_hight_data->rf[32][0]  = 0xf3;

	// expected fwf
	expected_fwf[7]          = 0x00;
	expected_fwf[6]          = 0xf4;
	expected_fwf[5]          = 0x18;
	expected_fwf[4]          = 0xae;
	expected_fwf[3]          = 0xd9;
	expected_fwf[2]          = 0x4f;
	expected_fwf[1]          = 0x03;
	expected_fwf[0]          = 0xf2;

#elif 0
	// Test vectors 2
	printf("test vectors 2\n");

	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9]  = 0x99;
	p_hight_data->i_mk[8]  = 0x88;
	p_hight_data->i_mk[7]  = 0x77;
	p_hight_data->i_mk[6]  = 0x66;
	p_hight_data->i_mk[5]  = 0x55;
	p_hight_data->i_mk[4]  = 0x44;
	p_hight_data->i_mk[3]  = 0x33;
	p_hight_data->i_mk[2]  = 0x22;
	p_hight_data->i_mk[1]  = 0x11;
	p_hight_data->i_mk[0]  = 0x00;
	
	//Round32 output
	p_hight_data->rf[32][7]  = 0x23;
	p_hight_data->rf[32][6]  = 0xfd;
	p_hight_data->rf[32][5]  = 0x9f;
	p_hight_data->rf[32][4]  = 0x50;
	p_hight_data->rf[32][3]  = 0xe5;
	p_hight_data->rf[32][2]  = 0x52;
	p_hight_data->rf[32][1]  = 0xe6;
	p_hight_data->rf[32][0]  = 0xd8;

	// expected fwf
	expected_fwf[7]        = 0x23;
	expected_fwf[6]        = 0xce;
	expected_fwf[5]        = 0x9f;
	expected_fwf[4]        = 0x72;
	expected_fwf[3]        = 0xe5;
	expected_fwf[2]        = 0x43;
	expected_fwf[1]        = 0xe6;
	expected_fwf[0]        = 0xd8;

#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9]  = 0x06;
	p_hight_data->i_mk[8]  = 0x07;
	p_hight_data->i_mk[7]  = 0x08;
	p_hight_data->i_mk[6]  = 0x09;
	p_hight_data->i_mk[5]  = 0x0a;
	p_hight_data->i_mk[4]  = 0x0b;
	p_hight_data->i_mk[3]  = 0x0c;
	p_hight_data->i_mk[2]  = 0x0d;
	p_hight_data->i_mk[1]  = 0x0e;
	p_hight_data->i_mk[0]  = 0x0f;
	
	//Round32 output
	p_hight_data->rf[1][7]  = 0x7a;
	p_hight_data->rf[1][6]  = 0x63;
	p_hight_data->rf[1][5]  = 0xb2;
	p_hight_data->rf[1][4]  = 0x95;
	p_hight_data->rf[1][3]  = 0x8d;
	p_hight_data->rf[1][2]  = 0x2d;
	p_hight_data->rf[1][1]  = 0xf4;
	p_hight_data->rf[1][0]  = 0x57;

	// expected fwf
	expected_fwf[7]        = 0x7a;
	expected_fwf[6]        = 0x6f;
	expected_fwf[5]        = 0xb2;
	expected_fwf[4]        = 0xa2;
	expected_fwf[3]        = 0x8d;
	expected_fwf[2]        = 0x23;
	expected_fwf[1]        = 0xf4;
	expected_fwf[0]        = 0x66;

#elif 0
	// Test vector 4
	printf("test vectors 4\n");

	i_op = ENC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9]  = 0xd8;
	p_hight_data->i_mk[8]  = 0x7d;
	p_hight_data->i_mk[7]  = 0xcf;
	p_hight_data->i_mk[6]  = 0xa5;
	p_hight_data->i_mk[5]  = 0x09;
	p_hight_data->i_mk[4]  = 0xb1;
	p_hight_data->i_mk[3]  = 0x1d;
	p_hight_data->i_mk[2]  = 0x42;
	p_hight_data->i_mk[1]  = 0x2b;
	p_hight_data->i_mk[0]  = 0xe7;
	
	//Round32 output
	p_hight_data->rf[32][7]  = 0xcc;
	p_hight_data->rf[32][6]  = 0x19;
	p_hight_data->rf[32][5]  = 0x7a;
	p_hight_data->rf[32][4]  = 0x33;
	p_hight_data->rf[32][3]  = 0x20;
	p_hight_data->rf[32][2]  = 0xb7;
	p_hight_data->rf[32][1]  = 0x1f;
	p_hight_data->rf[32][0]  = 0xdf;

	// expected fwf
	expected_fwf[7]        = 0xcc;
	expected_fwf[6]        = 0x04;
	expected_fwf[5]        = 0x7a;
	expected_fwf[4]        = 0x75;
	expected_fwf[3]        = 0x20;
	expected_fwf[2]        = 0x9c;
	expected_fwf[1]        = 0x1f;
	expected_fwf[0]        = 0xc6;
#endif

/*
	/////////////////////////////////////////////////
	//
	// Decrytion vector
	//
	/////////////////////////////////////////////////
	printf("\n\n===== Decrytion operation =====\n\n");

#if 0

// Test vectors 1
	printf("test vectors 1\n");

	i_op = DEC;

	// MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x11;
	p_hight_data->i_mk[13] = 0x22;
	p_hight_data->i_mk[12] = 0x33;
	p_hight_data->i_mk[11] = 0x44;
	p_hight_data->i_mk[10] = 0x55;
	p_hight_data->i_mk[9]  = 0x66;
	p_hight_data->i_mk[8]  = 0x77;
	p_hight_data->i_mk[7]  = 0x88;
	p_hight_data->i_mk[6]  = 0x99;
	p_hight_data->i_mk[5]  = 0xaa;
	p_hight_data->i_mk[4]  = 0xbb;
	p_hight_data->i_mk[3]  = 0xcc;
	p_hight_data->i_mk[2]  = 0xdd;
	p_hight_data->i_mk[1]  = 0xee;
	p_hight_data->i_mk[0]  = 0xff;
	
	// CipherText
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0xf4;
	p_hight_data->i_pct[5]  = 0x18;
	p_hight_data->i_pct[4]  = 0xae;
	p_hight_data->i_pct[3]  = 0xd9;
	p_hight_data->i_pct[2]  = 0x4f;
	p_hight_data->i_pct[1]  = 0x03;
	p_hight_data->i_pct[0]  = 0xf2;

	// expected fwf
	expected_fwf[7]        = 0x00;
	expected_fwf[6]        = 0x38;
	expected_fwf[5]        = 0x18;
	expected_fwf[4]        = 0xd1;
	expected_fwf[3]        = 0xd9;
	expected_fwf[2]        = 0xa1;
	expected_fwf[1]        = 0x03;
	expected_fwf[0]        = 0xf3;

#elif 0
	// Test vectors 2
	printf("test vectors 2\n");

	i_op = DEC;

	// MasterKey
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9]  = 0x99;
	p_hight_data->i_mk[8]  = 0x88;
	p_hight_data->i_mk[7]  = 0x77;
	p_hight_data->i_mk[6]  = 0x66;
	p_hight_data->i_mk[5]  = 0x55;
	p_hight_data->i_mk[4]  = 0x44;
	p_hight_data->i_mk[3]  = 0x33;
	p_hight_data->i_mk[2]  = 0x22;
	p_hight_data->i_mk[1]  = 0x11;
	p_hight_data->i_mk[0]  = 0x00;
	
	// CipherText
	p_hight_data->i_pct[7]  = 0x23;
	p_hight_data->i_pct[6]  = 0xce;
	p_hight_data->i_pct[5]  = 0x9f;
	p_hight_data->i_pct[4]  = 0x72;
	p_hight_data->i_pct[3]  = 0xe5;
	p_hight_data->i_pct[2]  = 0x43;
	p_hight_data->i_pct[1]  = 0xe6;
	p_hight_data->i_pct[0]  = 0xd8;

	// expected fwf
	expected_fwf[7]        = 0x23;
	expected_fwf[6]        = 0xfd;
	expected_fwf[5]        = 0x9f;
	expected_fwf[4]        = 0x50;
	expected_fwf[3]        = 0xe5;
	expected_fwf[2]        = 0x52;
	expected_fwf[1]        = 0xe6;
	expected_fwf[0]        = 0xd8;

#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9]  = 0x06;
	p_hight_data->i_mk[8]  = 0x07;
	p_hight_data->i_mk[7]  = 0x08;
	p_hight_data->i_mk[6]  = 0x09;
	p_hight_data->i_mk[5]  = 0x0a;
	p_hight_data->i_mk[4]  = 0x0b;
	p_hight_data->i_mk[3]  = 0x0c;
	p_hight_data->i_mk[2]  = 0x0d;
	p_hight_data->i_mk[1]  = 0x0e;
	p_hight_data->i_mk[0]  = 0x0f;
	
	//CipherText
	p_hight_data->i_pct[7]  = 0x7a;
	p_hight_data->i_pct[6]  = 0x6f;
	p_hight_data->i_pct[5]  = 0xb2;
	p_hight_data->i_pct[4]  = 0xa2;
	p_hight_data->i_pct[3]  = 0x8d;
	p_hight_data->i_pct[2]  = 0x23;
	p_hight_data->i_pct[1]  = 0xf4;
	p_hight_data->i_pct[0]  = 0x66; 

	// expected fwf
	expected_fwf[7]        = 0x7a;
	expected_fwf[6]        = 0x63;
	expected_fwf[5]        = 0xb2;
	expected_fwf[4]        = 0x95;
	expected_fwf[3]        = 0x8d;
	expected_fwf[2]        = 0x2d;
	expected_fwf[1]        = 0xf4;
	expected_fwf[0]        = 0x57;

#elif 1
	// Test vector 4
	printf("test vectors 4\n");

	i_op = DEC;

	//MasterKey
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9]  = 0xd8;
	p_hight_data->i_mk[8]  = 0x7d;
	p_hight_data->i_mk[7]  = 0xcf;
	p_hight_data->i_mk[6]  = 0xa5;
	p_hight_data->i_mk[5]  = 0x09;
	p_hight_data->i_mk[4]  = 0xb1;
	p_hight_data->i_mk[3]  = 0x1d;
	p_hight_data->i_mk[2]  = 0x42;
	p_hight_data->i_mk[1]  = 0x2b;
	p_hight_data->i_mk[0]  = 0xe7;
	
	//CipherText
	p_hight_data->i_pct[7]  = 0xcc;
	p_hight_data->i_pct[6]  = 0x04;
	p_hight_data->i_pct[5]  = 0x7a;
	p_hight_data->i_pct[4]  = 0x75;
	p_hight_data->i_pct[3]  = 0x20;
	p_hight_data->i_pct[2]  = 0x9c;
	p_hight_data->i_pct[1]  = 0x1f;
	p_hight_data->i_pct[0]  = 0xc6;

	// expected fwf
	expected_fwf[7]        = 0xcc;
	expected_fwf[6]        = 0x19;
	expected_fwf[5]        = 0x7a;
	expected_fwf[4]        = 0x33;
	expected_fwf[3]        = 0x20;
	expected_fwf[2]        = 0xb7;
	expected_fwf[1]        = 0x1f;
	expected_fwf[0]        = 0xdf;
#endif
*/


	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 

	FinalWhiteningFunction(i_op, p_hight_data->rf[32], p_hight_data->wk, p_hight_data->fwf);
 
	
	printf("\n>> operation : %s <<<\n", (i_op == ENC) ? "encryption" : "decrytion");

	printf("\n>>> master key <<<\n");
	for(i=15; i>=0; i--) {
		printf("mk[%02d] = %02x\n", i, p_hight_data->i_mk[i]);
	}

	printf("\n>>> round32 output <<<\n");
	for(i=7; i>=0; i--) {
		printf("rf[32][%02d] = %02x\n", i, p_hight_data->rf[32][i]);
	}

	printf("\n>>> FinalWhiteningFunction result <<<\n");
	for(i=7; i>=0; i--) {
		printf("fwf[%02d] = %02x ",i, p_hight_data->fwf[i]);
		if(p_hight_data->fwf[i] == expected_fwf[i])
			printf("Correct\n");
		else
			printf("Wrong (expected = %02x) \n", expected_fwf[i]);
	}
}

/* =====================================

    InterRoundFunctionTest()

=======================================*/
void InterRoundFunctionTest()
{
#define IRF_TV1
//#define IRF_TV2
//#define IRF_TV3
//#define IRF_TV4

#define IRF_ENC
//#define IRF_DEC

//#define ROUND_FUNCTION_DUMP

#ifdef ROUND_FUNCTION_DUMP
	FILE *fp= fopen("roundfunction_4.txt","w+");
#endif
	int i,j; 
	int i_op = -1;
	byte expected_rf[32][8];

/*	
	// F0(X) & F1(X) 
	int a, b, c;

	a = 0xa1;
	//a = 0xc4;
	//a = 0x48  ;
	//a = 0x8   ;

	b = ((a<<1 | a>>7) ^ (a<<2 | a>>6) ^ (a<<7 | a>>1));
	printf("\n\n%02x\n%02x\n" ,a,b);

	c = (a<<3 | a>>5) ^ (a<<4 | a>>4) ^ (a<<6 | a>>2);
	printf("%x" ,c);

*/

	printf("\n\n===== InterRoundFunctionTest =====\n\n");

#if defined(IRF_TV1)
	// Test vectors 1

	p_hight_data-> sk[3]     = 0xe7;
	p_hight_data-> sk[2]     = 0x13;	
	p_hight_data-> sk[1]     = 0x5b;	
	p_hight_data-> sk[0]     = 0x59;	

	p_hight_data-> sk[7]     = 0xc9;	
	p_hight_data-> sk[6]     = 0x9c;	
	p_hight_data-> sk[5]     = 0xb0;	
	p_hight_data-> sk[4]     = 0xc8;	

	p_hight_data-> sk[11]    = 0x90;	
	p_hight_data-> sk[10]    = 0x6d;	
	p_hight_data-> sk[9]     = 0x96;	
	p_hight_data-> sk[8]     = 0xd7;	

	p_hight_data-> sk[15]    = 0x2c;	
	p_hight_data-> sk[14]    = 0x6a;	
	p_hight_data-> sk[13]    = 0x55;	
	p_hight_data-> sk[12]    = 0x99;	

	p_hight_data-> sk[19]    = 0x27;	
	p_hight_data-> sk[18]    = 0x03;	
	p_hight_data-> sk[17]    = 0x2a;	
	p_hight_data-> sk[16]    = 0xde;	

	p_hight_data-> sk[23]    = 0xb5;	
	p_hight_data-> sk[22]    = 0xe3;	
	p_hight_data-> sk[21]    = 0x2d;	
	p_hight_data-> sk[20]    = 0x31;	

	p_hight_data-> sk[27]    = 0xce;	
	p_hight_data-> sk[26]    = 0xd9;	
	p_hight_data-> sk[25]    = 0xde;	
	p_hight_data-> sk[24]    = 0x4e;	

	p_hight_data-> sk[31]    = 0x48;	
	p_hight_data-> sk[30]    = 0x91;	
	p_hight_data-> sk[29]    = 0x91;	
	p_hight_data-> sk[28]    = 0x80;	

	p_hight_data-> sk[35]    = 0xf9;	
	p_hight_data-> sk[34]    = 0x15;	
	p_hight_data-> sk[33]    = 0xb5;	
	p_hight_data-> sk[32]    = 0xf4;	

	p_hight_data-> sk[39]    = 0xfa;	
	p_hight_data-> sk[38]    = 0xdc;	
	p_hight_data-> sk[37]    = 0x0e;	
	p_hight_data-> sk[36]    = 0xe2;	

	p_hight_data-> sk[43]    = 0xbb;	
	p_hight_data-> sk[42]    = 0xa1;	
	p_hight_data-> sk[41]    = 0x54;	
	p_hight_data-> sk[40]    = 0x39;	

	p_hight_data-> sk[47]    = 0x9f;	
	p_hight_data-> sk[46]    = 0xad;	
	p_hight_data-> sk[45]    = 0xb9;	
	p_hight_data-> sk[44]    = 0xbf;	

	p_hight_data-> sk[51]    = 0x16;	
	p_hight_data-> sk[50]    = 0xb7;	
	p_hight_data-> sk[49]    = 0xf8;	
	p_hight_data-> sk[48]    = 0xe8;	

	p_hight_data-> sk[55]    = 0xe4;	
	p_hight_data-> sk[54]    = 0x1e;	
	p_hight_data-> sk[53]    = 0x02;	
	p_hight_data-> sk[52]    = 0x39;	

	p_hight_data-> sk[59]    = 0xd9;	
	p_hight_data-> sk[58]    = 0x45;	
	p_hight_data-> sk[57]    = 0x1b;	
	p_hight_data-> sk[56]    = 0x36;	

	p_hight_data-> sk[63]    = 0xa9;	
	p_hight_data-> sk[62]    = 0xb0;	
	p_hight_data-> sk[61]    = 0xad;	
	p_hight_data-> sk[60]    = 0x97;	

	p_hight_data-> sk[67]    = 0xcf;	
	p_hight_data-> sk[66]    = 0xa7;	
	p_hight_data-> sk[65]    = 0xc7;	
	p_hight_data-> sk[64]    = 0xf6;	

	p_hight_data-> sk[71]    = 0x48;	
	p_hight_data-> sk[70]    = 0x55;	
	p_hight_data-> sk[69]    = 0x5f;	
	p_hight_data-> sk[68]    = 0x62;	

	p_hight_data-> sk[75]    = 0x1f;	
	p_hight_data-> sk[74]    = 0x50;	
	p_hight_data-> sk[73]    = 0xa1;	
	p_hight_data-> sk[72]    = 0xb1;	

	p_hight_data-> sk[79]    = 0xa5;	
	p_hight_data-> sk[78]    = 0x98;	
	p_hight_data-> sk[77]    = 0x6d;	
	p_hight_data-> sk[76]    = 0x86;	

	p_hight_data-> sk[83]    = 0x07;	
	p_hight_data-> sk[82]    = 0x06;	
	p_hight_data-> sk[81]    = 0xf3;	
	p_hight_data-> sk[80]    = 0x3c;	

	p_hight_data-> sk[87]    = 0xfb;	
	p_hight_data-> sk[86]    = 0x2b;	
	p_hight_data-> sk[85]    = 0x7a;	
	p_hight_data-> sk[84]    = 0xff;	

	p_hight_data-> sk[91]    = 0x7a;	
	p_hight_data-> sk[90]    = 0x75;	
	p_hight_data-> sk[89]    = 0x5a;	
	p_hight_data-> sk[88]    = 0x93;	

	p_hight_data-> sk[95]    = 0x7b;	
	p_hight_data-> sk[94]    = 0xb3;	
	p_hight_data-> sk[93]    = 0x91;	
	p_hight_data-> sk[92]    = 0x34;	

	p_hight_data-> sk[99]    = 0xbc;	
	p_hight_data-> sk[98]    = 0xdf;	
	p_hight_data-> sk[97]    = 0x15;	
	p_hight_data-> sk[96]    = 0xf0;	

	p_hight_data-> sk[103]   = 0xef;	
	p_hight_data-> sk[102]   = 0x01;	
	p_hight_data-> sk[101]   = 0x8c;	
	p_hight_data-> sk[100]   = 0xa2;	

	p_hight_data-> sk[107]   = 0x2a;	
	p_hight_data-> sk[106]   = 0x43;	
	p_hight_data-> sk[105]   = 0x64;	
	p_hight_data-> sk[104]   = 0x95;	

	p_hight_data-> sk[111]   = 0xae;	
	p_hight_data-> sk[110]   = 0x88;	
	p_hight_data-> sk[109]   = 0x22;	
	p_hight_data-> sk[108]   = 0x55;	

	p_hight_data-> sk[115]   = 0xc7;	
	p_hight_data-> sk[114]   = 0xe5;	
	p_hight_data-> sk[113]   = 0x0f;	
	p_hight_data-> sk[112]   = 0x52;	

	p_hight_data-> sk[119]   = 0x67;	
	p_hight_data-> sk[118]   = 0xd9;	
	p_hight_data-> sk[117]   = 0xbc;	
	p_hight_data-> sk[116]   = 0xf0;	

	p_hight_data-> sk[123]   = 0x61;	
	p_hight_data-> sk[122]   = 0xa1;	
	p_hight_data-> sk[121]   = 0x8f;	
	p_hight_data-> sk[120]   = 0xda;	

	p_hight_data-> sk[127]   = 0xd1;	
	p_hight_data-> sk[126]   = 0x35;	
	p_hight_data-> sk[125]   = 0x7c;	
	p_hight_data-> sk[124]   = 0x79;	
	 
	expected_rf[1][7]        = 0x00;
	expected_rf[1][6]        = 0xce;
	expected_rf[1][5]        = 0x11;
	expected_rf[1][4]        = 0x38;
	expected_rf[1][3]        = 0x22;
	expected_rf[1][2]        = 0x3f;
	expected_rf[1][1]        = 0x33;
	expected_rf[1][0]        = 0xe7;

	expected_rf[2][7]        = 0xce;
	expected_rf[2][6]        = 0xe1;
	expected_rf[2][5]        = 0x38;
	expected_rf[2][4]        = 0xef;
	expected_rf[2][3]        = 0x3f;
	expected_rf[2][2]        = 0xa3;
	expected_rf[2][1]        = 0xe7;
	expected_rf[2][0]        = 0x8a;
	
	expected_rf[3][7]        = 0xe1;
	expected_rf[3][6]        = 0x4f;
	expected_rf[3][5]        = 0xef;
	expected_rf[3][4]        = 0x91;
	expected_rf[3][3]        = 0xa3;
	expected_rf[3][2]        = 0x70;
	expected_rf[3][1]        = 0x8a;
	expected_rf[3][0]        = 0x8a;

	expected_rf[4][7]        = 0x4f;
	expected_rf[4][6]        = 0x8a;
	expected_rf[4][5]        = 0x91;
	expected_rf[4][4]        = 0xcd;
	expected_rf[4][3]        = 0x70;
	expected_rf[4][2]        = 0x51;
	expected_rf[4][1]        = 0x8a;
	expected_rf[4][0]        = 0xd1;

	expected_rf[5][7]        = 0x8a;
	expected_rf[5][6]        = 0x53;
	expected_rf[5][5]        = 0xcd;
	expected_rf[5][4]        = 0x09;
	expected_rf[5][3]        = 0x51;
	expected_rf[5][2]        = 0xc3;
	expected_rf[5][1]        = 0xd1;
	expected_rf[5][0]        = 0xee;

	expected_rf[6][7]        = 0x53;
	expected_rf[6][6]        = 0x46;
	expected_rf[6][5]        = 0x09;
	expected_rf[6][4]        = 0xc7;
	expected_rf[6][3]        = 0xc3;
	expected_rf[6][2]        = 0xe4;
	expected_rf[6][1]        = 0xee;
	expected_rf[6][0]        = 0x7d;

	expected_rf[7][7]        = 0x46;
	expected_rf[7][6]        = 0x73;
	expected_rf[7][5]        = 0xc7;
	expected_rf[7][4]        = 0xc5;
	expected_rf[7][3]        = 0xe4;
	expected_rf[7][2]        = 0x1b;
	expected_rf[7][1]        = 0x7d;
	expected_rf[7][0]        = 0xd7;

	expected_rf[8][7]        = 0x73;
	expected_rf[8][6]        = 0x59;
	expected_rf[8][5]        = 0xc5;
	expected_rf[8][4]        = 0x8c;
	expected_rf[8][3]        = 0x1b;
	expected_rf[8][2]        = 0x33;
	expected_rf[8][1]        = 0xd7;
	expected_rf[8][0]        = 0x9c;

	expected_rf[9][7]        = 0x59;
	expected_rf[9][6]        = 0x5f;
	expected_rf[9][5]        = 0x8c;
	expected_rf[9][4]        = 0xf3;
	expected_rf[9][3]        = 0x33;
	expected_rf[9][2]        = 0xd5;
	expected_rf[9][1]        = 0x9c;
	expected_rf[9][0]        = 0x07;
	
	expected_rf[10][7]       = 0x5f;
	expected_rf[10][6]       = 0x0c;
	expected_rf[10][5]       = 0xf3;
	expected_rf[10][4]       = 0x17;
	expected_rf[10][3]       = 0xd5;
	expected_rf[10][2]       = 0x07;
	expected_rf[10][1]       = 0x07;
	expected_rf[10][0]       = 0x3f;

	expected_rf[11][7]       = 0x0c;
	expected_rf[11][6]       = 0xa0;
	expected_rf[11][5]       = 0x17;
	expected_rf[11][4]       = 0x30;
	expected_rf[11][3]       = 0x07;
	expected_rf[11][2]       = 0x03;
	expected_rf[11][1]       = 0x3f;
	expected_rf[11][0]       = 0xb6;

	expected_rf[12][7]       = 0xa0;
	expected_rf[12][6]       = 0x3a;
	expected_rf[12][5]       = 0x30;
	expected_rf[12][4]       = 0x43;
	expected_rf[12][3]       = 0x03;
	expected_rf[12][2]       = 0x0b;
	expected_rf[12][1]       = 0xb6;
	expected_rf[12][0]       = 0x3e;

	expected_rf[13][7]       = 0x3a;
	expected_rf[13][6]       = 0x79;
	expected_rf[13][5]       = 0x43;
	expected_rf[13][4]       = 0xb4;
	expected_rf[13][3]       = 0x0b;
	expected_rf[13][2]       = 0x2b;
	expected_rf[13][1]       = 0x3e;
	expected_rf[13][0]       = 0x37;

	expected_rf[14][7]       = 0x79;
	expected_rf[14][6]       = 0x20;
	expected_rf[14][5]       = 0xb4;
	expected_rf[14][4]       = 0x7a;
	expected_rf[14][3]       = 0x2b;
	expected_rf[14][2]       = 0x7c;
	expected_rf[14][1]       = 0x37;
	expected_rf[14][0]       = 0xb5;

	expected_rf[15][7]       = 0x20;
	expected_rf[15][6]       = 0x63;
	expected_rf[15][5]       = 0x7a;
	expected_rf[15][4]       = 0x79;
	expected_rf[15][3]       = 0x7c;
	expected_rf[15][2]       = 0xe4;
	expected_rf[15][1]       = 0xb5;
	expected_rf[15][0]       = 0xd0;

	expected_rf[16][7]       = 0x63;
	expected_rf[16][6]       = 0x2c;
	expected_rf[16][5]       = 0x79;
	expected_rf[16][4]       = 0xa9;
	expected_rf[16][3]       = 0xe4;
	expected_rf[16][2]       = 0xdd;
	expected_rf[16][1]       = 0xd0;
	expected_rf[16][0]       = 0x83;
	
	expected_rf[17][7]       = 0x2c;
	expected_rf[17][6]       = 0x93;
	expected_rf[17][5]       = 0xa9;
	expected_rf[17][4]       = 0x0d;
	expected_rf[17][3]       = 0xdd;
	expected_rf[17][2]       = 0x02;
	expected_rf[17][1]       = 0x83;
	expected_rf[17][0]       = 0xae;

	expected_rf[18][7]       = 0x93;
	expected_rf[18][6]       = 0x57;
	expected_rf[18][5]       = 0x0d;
	expected_rf[18][4]       = 0xb1;
	expected_rf[18][3]       = 0x02;
	expected_rf[18][2]       = 0xd9;
	expected_rf[18][1]       = 0xae;
	expected_rf[18][0]       = 0xc4;

	expected_rf[19][7]       = 0x57;
	expected_rf[19][6]       = 0xb7;
	expected_rf[19][5]       = 0xb1;
	expected_rf[19][4]       = 0xdb;
	expected_rf[19][3]       = 0xd9;
	expected_rf[19][2]       = 0x98;
	expected_rf[19][1]       = 0xc4;
	expected_rf[19][0]       = 0xe4;

	expected_rf[20][7]       = 0xb7;
	expected_rf[20][6]       = 0xbe;
	expected_rf[20][5]       = 0xdb;
	expected_rf[20][4]       = 0x55;
	expected_rf[20][3]       = 0x98;
	expected_rf[20][2]       = 0x9a;
	expected_rf[20][1]       = 0xe4;
	expected_rf[20][0]       = 0x58;

	expected_rf[21][7]       = 0xbe;
	expected_rf[21][6]       = 0x87;
	expected_rf[21][5]       = 0x55;
	expected_rf[21][4]       = 0x9d;
	expected_rf[21][3]       = 0x9a;
	expected_rf[21][2]       = 0x51;
	expected_rf[21][1]       = 0x58;
	expected_rf[21][0]       = 0x68;

	expected_rf[22][7]       = 0x87;
	expected_rf[22][6]       = 0xce;
	expected_rf[22][5]       = 0x9d;
	expected_rf[22][4]       = 0x53;
	expected_rf[22][3]       = 0x51;
	expected_rf[22][2]       = 0x78;
	expected_rf[22][1]       = 0x68;
	expected_rf[22][0]       = 0x73;

	expected_rf[23][7]       = 0xce;
	expected_rf[23][6]       = 0xab;
	expected_rf[23][5]       = 0x53;
	expected_rf[23][4]       = 0xd6;
	expected_rf[23][3]       = 0x78;
	expected_rf[23][2]       = 0x4b;
	expected_rf[23][1]       = 0x73;
	expected_rf[23][0]       = 0xbc;
	
	expected_rf[24][7]       = 0xab;
	expected_rf[24][6]       = 0x30;
	expected_rf[24][5]       = 0xd6;
	expected_rf[24][4]       = 0xd7;
	expected_rf[24][3]       = 0x4b;
	expected_rf[24][2]       = 0xa8;
	expected_rf[24][1]       = 0xbc;
	expected_rf[24][0]       = 0x69;

	expected_rf[25][7]       = 0x30;
	expected_rf[25][6]       = 0xbf;
	expected_rf[25][5]       = 0xd7;
	expected_rf[25][4]       = 0xf7;
	expected_rf[25][3]       = 0xa8;
	expected_rf[25][2]       = 0x33;
	expected_rf[25][1]       = 0x69;
	expected_rf[25][0]       = 0xdf;

	expected_rf[26][7]       = 0xbf;
	expected_rf[26][6]       = 0x13;
	expected_rf[26][5]       = 0xf7;
	expected_rf[26][4]       = 0x17;
	expected_rf[26][3]       = 0x33;
	expected_rf[26][2]       = 0xbf;
	expected_rf[26][1]       = 0xdf;
	expected_rf[26][0]       = 0x7d;

	expected_rf[27][7]       = 0x13;
	expected_rf[27][6]       = 0x46;
	expected_rf[27][5]       = 0x17;
	expected_rf[27][4]       = 0xf1;
	expected_rf[27][3]       = 0xbf;
	expected_rf[27][2]       = 0xd5;
	expected_rf[27][1]       = 0x7d;
	expected_rf[27][0]       = 0xb2;

	expected_rf[28][7]       = 0x46;
	expected_rf[28][6]       = 0x7b;
	expected_rf[28][5]       = 0xf1;
	expected_rf[28][4]       = 0x87;
	expected_rf[28][3]       = 0xd5;
	expected_rf[28][2]       = 0xc4;
	expected_rf[28][1]       = 0xb2;
	expected_rf[28][0]       = 0x77;

	expected_rf[29][7]       = 0x7b;
	expected_rf[29][6]       = 0x31;
	expected_rf[29][5]       = 0x87;
	expected_rf[29][4]       = 0xd2;
	expected_rf[29][3]       = 0xc4;
	expected_rf[29][2]       = 0xf5;
	expected_rf[29][1]       = 0x77;
	expected_rf[29][0]       = 0x2b;

	expected_rf[30][7]       = 0x31;
	expected_rf[30][6]       = 0x5d;
	expected_rf[30][5]       = 0xd2;
	expected_rf[30][4]       = 0x46;
	expected_rf[30][3]       = 0xf5;
	expected_rf[30][2]       = 0x48;
	expected_rf[30][1]       = 0x2b;
	expected_rf[30][0]       = 0xde;

	expected_rf[31][7]       = 0x5d;
	expected_rf[31][6]       = 0x38;
	expected_rf[31][5]       = 0x46;
	expected_rf[31][4]       = 0xd1;
	expected_rf[31][3]       = 0x48;
	expected_rf[31][2]       = 0xa1;
	expected_rf[31][1]       = 0xde;
	expected_rf[31][0]       = 0xf3;

#elif defined(IRF_TV2)
	printf("IRF_TV2");

#elif defined(IRF_TV3)
	printf("IRF_TV3");

#elif defined(IRF_TV4)
	printf("IRF_TV4");

#endif



#if defined(IRF_ENC)
	/////////////////////////////////////////////////
	//
	// Encryption vector
	//
	/////////////////////////////////////////////////
	printf("\n\n===== Encryption operation =====\n\n");

#if defined(IRF_TV1)

	// Test vectors 1
	printf("test vectors 1\n");
	
	i_op = ENC;

	p_hight_data-> iwf[7]    = 0x00;	
	p_hight_data-> iwf[6]    = 0x00;	
	p_hight_data-> iwf[5]    = 0x00;	
	p_hight_data-> iwf[4]    = 0x11;	
	p_hight_data-> iwf[3]    = 0x00;	
	p_hight_data-> iwf[2]    = 0x22;	
	p_hight_data-> iwf[1]    = 0x00;	
	p_hight_data-> iwf[0]    = 0x33;	
	
#elif defined(IRF_TV2)
	printf("IRF_TV2");

#elif defined(IRF_TV3)
	printf("IRF_TV3");

#elif defined(IRF_TV4)
	printf("IRF_TV4");

#endif
#endif

#if defined(IRF_DEC) && !defined(IRF_ENC)
	/////////////////////////////////////////////////
	//
	// Decrytion vector
	//
	/////////////////////////////////////////////////
	
	printf("\n\n===== Decrytion operation =====\n\n");

#if defined(IRF_TV1)
	// Test vectors 1
	printf("test vectors 1\n");

	i_op = DEC;

	/* ??
	p_hight_data-> fwf[7]   = ;	
	p_hight_data-> fwf[6]   = ;	
	p_hight_data-> fwf[5]   = ;	
	p_hight_data-> fwf[4]   = ;	
	p_hight_data-> fwf[3]   = ;	
	p_hight_data-> fwf[2]   = ;	
	p_hight_data-> fwf[1]   = ;	
	p_hight_data-> fwf[0]   = ;	
	*/

#elif defined(IRF_TV2)
	printf("IRF_TV2");

#elif defined(IRF_TV3)
	printf("IRF_TV3");

#elif defined(IRF_TV4)
	printf("IRF_TV4");

#endif
#endif

	/////////////////////////////////////////////////
	//
	// Run test
	//
	/////////////////////////////////////////////////
	if(i_op == -1) {
		printf("Wrong operation\n");
		printf("You should set operation mode for ENC or DEC");
		return;
	}

	// RoundFunction1
	if(i_op == ENC) {
		InterRoundFunction(i_op,
							p_hight_data->iwf,
							p_hight_data->sk,
							p_hight_data->rf[1]);
	} else { // DEC


		InterRoundFunction(i_op,
							p_hight_data->fwf,
							p_hight_data->sk,
							p_hight_data->rf[1]);
	}
	
	// RoundFunction2~31
	for(i=1; i<31; i++){
		if(i_op == ENC) {
			InterRoundFunction(i_op,
								p_hight_data->rf[i],
								p_hight_data->sk+(i*4),
								p_hight_data->rf[i+1]);
		} else { // DEC
			InterRoundFunction(i_op,
								p_hight_data->rf[i],
								p_hight_data->sk+((32-i)*4),
								p_hight_data->rf[i+1]);
		}
	}


	// RoundFunction 1 
	printf("\n>> operation : %s <<<\n", (i_op == ENC) ? "encryption" : "decrytion");
#ifdef ROUND_FUNCTION_DUMP
	fprintf(fp,"\n>> operation : %s <<<\n", (i_op == ENC) ? "encryption" : "decrytion");
#endif

	printf("\n\n===== RoundFunction 1 =====\n\n");	
#ifdef ROUND_FUNCTION_DUMP
	fprintf(fp,"\n\n===== RoundFunction 1 =====\n\n");
#endif

	printf("\n>>> InitialWhiteningFunction  <<<\n");
#ifdef ROUND_FUNCTION_DUMP
	fprintf(fp,"\n>>> InitialWhiteningFunction  <<<\n");
#endif

	for(i=7; i>=0; i--){
		printf("iwf[%02d] = %02x\n",i, p_hight_data->iwf[i]);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"iwf[%02d] = %02x\n",i, p_hight_data->iwf[i]);
#endif
	}

	printf("\n>>> Sub Key <<<\n");
#ifdef ROUND_FUNCTION_DUMP
	fprintf(fp,"\n>>> Sub Key <<<\n");
#endif

	for(i=3; i>=0; i--){
		printf("sk[%02d] = %02x\n", i, p_hight_data->sk[i]);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"sk[%02d] = %02x\n", i, p_hight_data->sk[i]);
#endif
	}
	
	printf("\n>>> Round #1 Result  <<<\n");
#ifdef ROUND_FUNCTION_DUMP
	fprintf(fp,"\n>>> Round #1 Result  <<<\n");
#endif

	for(i=7; i>=0; i--){
        if((i_op == ENC) ? p_hight_data->rf[1][i] == expected_rf[1][i]: 
						   p_hight_data->rf[1][i] == expected_rf[31][i]){
			printf("rf[1][%02d] = %02x : Correct\n", i, p_hight_data->rf[1][i]);

#ifdef ROUND_FUNCTION_DUMP
			fprintf(fp,"rf[1][%02d] = %02x : Correct\n", i, p_hight_data->rf[1][i]);
#endif
		} else {
			printf("rf[1][%02d] = %02x : Wrong (expected = %02x) \n",i, p_hight_data->rf[1][i],
																	(i_op == ENC) ? expected_rf[1][i]: expected_rf[31][i]);

#ifdef ROUND_FUNCTION_DUMP
			fprintf(fp,"rf[1][%02d] : Wrong (expected = %02x) \n",i, (i_op == ENC) ? expected_rf[1][i]:
				                                                                     expected_rf[31][i]);
#endif	
		}
	}

	// RoundFunction 2~31
	for(i=2; i<32; i++){
		
		printf("\n\n===== RoundFunction %d =====\n\n",i);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"\n\n===== RoundFunction %d =====\n\n",i);
#endif

		printf("\n>>> Round #%d Result <<<\n", i-1);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"\n>>> Round #%d Result <<<\n", i-1);
#endif

		for(j=7; j>=0; j--){
			printf("rf[%02d][%02d] = %02x\n",i-1, j, p_hight_data->rf[i-1][j]);
#ifdef ROUND_FUNCTION_DUMP
			fprintf(fp,"rf[%02d][%02d] = %02x\n",i-1, j, p_hight_data->rf[i-1][j]);
#endif
		}
		
		printf("\n>>> Sub Key <<<\n");
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"\n>>> Sub Key <<<\n");
#endif
		printf("\n sk[%02d] = %02x\n sk[%02d] = %02x\n sk[%02d] = %02x\n sk[%02d] = %02x\n  ", 
				(i-1)*4+3, p_hight_data->sk[(i-1)*4+3],(i-1)*4+2, p_hight_data->sk[(i-1)*4+2],(i-1)*4+1, p_hight_data->sk[(i-1)*4+1],(i-1)*4, p_hight_data->sk[(i-1)*4]);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"\n sk[%02d] = %02x\n sk[%02d] = %02x\n sk[%02d] = %02x\n sk[%02d] = %02x\n  ", 
				(i-1)*4+3, p_hight_data->sk[(i-1)*4+3],(i-1)*4+2, p_hight_data->sk[(i-1)*4+2],(i-1)*4+1, p_hight_data->sk[(i-1)*4+1],(i-1)*4, p_hight_data->sk[(i-1)*4]);
#endif
		printf("\n>>> Round #%d Result  <<<\n",i);
#ifdef ROUND_FUNCTION_DUMP
		fprintf(fp,"\n>>> Round #%d Result  <<<\n",i);
#endif

		for(j=7; j>=0; j--){
			if(p_hight_data->rf[i][j] == expected_rf[i][j]){
				printf("rf[%02d][%02d] = %02x : Correct\n", i,j,p_hight_data->rf[i][j]);
#ifdef ROUND_FUNCTION_DUMP
				fprintf(fp,"rf[%02d][%02d] = %02x : Correct\n", i,j,p_hight_data->rf[i][j]);
#endif
			} else {
				printf("rf[%02d][%02d] : Wrong (expected = %02x) \n", i,j,expected_rf[i][j]);
#ifdef ROUND_FUNCTION_DUMP
				fprintf(fp,"rf[%02d][%02d] : Wrong (expected = %02x) \n", i,j,expected_rf[i][j]);
#endif 
			}	
		}
	}


#if defined(IRF_DEC)
	// RoundFunction32
	FinalRoundFunction(i_op,
						p_hight_data->rf[31],
						p_hight_data->sk,
						p_hight_data->rf[32]);

	printf("\n>>> Round 32 Result  <<<\n");

	for(i=7; i>=0; i--){
			printf("rf[32][%02d] = %02x\n" , i, p_hight_data->rf[32][i]);
	}
#endif

#ifdef ROUND_FUNCTION_DUMP
	fclose(fp);
#endif
}


/* =====================================

    FinalRoundFunctionTest ()

=======================================*/
void FinalRoundFunctionTest()
{
	int i; 
	byte expected_rf[33][8];


	printf("\n\n===== FinalRoundFunctionTest =====\n\n");

#if 0

	// Test vector 1
	printf("test vectors 1\n");

	p_hight_data->rf[31][7]   = 0x5d;
	p_hight_data->rf[31][6]   = 0x38;
	p_hight_data->rf[31][5]   = 0x46;
	p_hight_data->rf[31][4]   = 0xd1;
	p_hight_data->rf[31][3]   = 0x48;
	p_hight_data->rf[31][2]   = 0xa1;
	p_hight_data->rf[31][1]   = 0xde;
	p_hight_data->rf[31][0]   = 0xf3;

	p_hight_data-> sk[127]    = 0xd1;	
	p_hight_data-> sk[126]    = 0x35;	
	p_hight_data-> sk[125]    = 0x7c;	
	p_hight_data-> sk[124]    = 0x79;	

	expected_rf[32][7]        = 0x00;
	expected_rf[32][6]        = 0x38;
	expected_rf[32][5]        = 0x18;
	expected_rf[32][4]        = 0xd1;
	expected_rf[32][3]        = 0xd9;
	expected_rf[32][2]        = 0xa1;
	expected_rf[32][1]        = 0x03;
	expected_rf[32][0]        = 0xf3;

#elif 0
	// Test vector 2
	printf("test vectors 2\n");
	
	p_hight_data->rf[31][7]   = 0xf7;
	p_hight_data->rf[31][6]   = 0xfd;
	p_hight_data->rf[31][5]   = 0xf8;
	p_hight_data->rf[31][4]   = 0x50;
	p_hight_data->rf[31][3]   = 0xf8;
	p_hight_data->rf[31][2]   = 0x52;
	p_hight_data->rf[31][1]   = 0x9d;
	p_hight_data->rf[31][0]   = 0xd8;

	p_hight_data-> sk[127]    = 0xe2;	
	p_hight_data-> sk[126]    = 0x34;	
	p_hight_data-> sk[125]    = 0x59;	
	p_hight_data-> sk[124]    = 0x34;	

	expected_rf[32][7]        = 0x23;
	expected_rf[32][6]        = 0xfd;
	expected_rf[32][5]        = 0x9f;
	expected_rf[32][4]        = 0x50;
	expected_rf[32][3]        = 0xe5;
	expected_rf[32][2]        = 0x52;
	expected_rf[32][1]        = 0xe6;
	expected_rf[32][0]        = 0xd8;

#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	p_hight_data->rf[31][7]   = 0x21;
	p_hight_data->rf[31][6]   = 0x63;
	p_hight_data->rf[31][5]   = 0x0d;
	p_hight_data->rf[31][4]   = 0x95;
	p_hight_data->rf[31][3]   = 0x69;
	p_hight_data->rf[31][2]   = 0x2d;
	p_hight_data->rf[31][1]   = 0xb1;
	p_hight_data->rf[31][0]   = 0x57;

	p_hight_data-> sk[127]    = 0x61;	
	p_hight_data-> sk[126]    = 0x35;	
	p_hight_data-> sk[125]    = 0x6c;	
	p_hight_data-> sk[124]    = 0x59;	

	expected_rf[32][7]        = 0x7a;
	expected_rf[32][6]        = 0x63;
	expected_rf[32][5]        = 0xb2;
	expected_rf[32][4]        = 0x95;
	expected_rf[32][3]        = 0x8d;
	expected_rf[32][2]        = 0x2d;
	expected_rf[32][1]        = 0xf4;
	expected_rf[32][0]        = 0x57;
#elif 4
	// Test vector 4
	printf("test vectors 4\n");

	p_hight_data->rf[31][7]   = 0x7d;
	p_hight_data->rf[31][6]   = 0x19;
	p_hight_data->rf[31][5]   = 0x3f;
	p_hight_data->rf[31][4]   = 0x33;
	p_hight_data->rf[31][3]   = 0x90;
	p_hight_data->rf[31][2]   = 0xb7;
	p_hight_data->rf[31][1]   = 0x31;
	p_hight_data->rf[31][0]   = 0xdf;

	p_hight_data-> sk[127]    = 0xd7;	
	p_hight_data-> sk[126]    = 0x5d;	
	p_hight_data-> sk[125]    = 0x46;	
	p_hight_data-> sk[124]    = 0x1a;	

	expected_rf[32][7]        = 0xcc;
	expected_rf[32][6]        = 0x19;
	expected_rf[32][5]        = 0x7a;
	expected_rf[32][4]        = 0x33;
	expected_rf[32][3]        = 0x20;
	expected_rf[32][2]        = 0xb7;
	expected_rf[32][1]        = 0x1f;
	expected_rf[32][0]        = 0xdf;

#endif 


	
	// RoundFunction32
	for(i=31; i<32; i++){
		FinalRoundFunction(ENC,
							p_hight_data->rf[i],
							p_hight_data->sk+(i*4),
							p_hight_data->rf[i+1]);
	}
	
	// RoundFunction 1 
	printf("\n\n===== RoundFunction 32 =====\n\n");	

	printf("\n>>> Round 31 Result <<<\n");

	for(i=7; i>=0; i--){
		printf("rf[31][%02d] = %02x\n",i, p_hight_data->rf[31][i]);
	}

	printf("\n>>> Sub Key <<<\n");

	for(i=127; i>=124; i--){
		printf("sk[%02d] = %02x\n", i, p_hight_data->sk[i]);
	}
	
	printf("\n>>> Round 32 Result  <<<\n");

	for(i=7; i>=0; i--){
        if(p_hight_data->rf[32][i] == expected_rf[32][i])
			printf("rf[32][%02d] = %02x : Correct\n", i, p_hight_data->rf[32][i]);
		else 
			printf("rf[32][%02d] = %02x: Wrong (expected = %02x) \n",i, p_hight_data->rf[32][i], expected_rf[32][i]);
		}
	}


/* =====================================

    HightEncryptionTest()

=======================================*/
void HightEncryptionTest()
{
	int i; 
	byte expected_c_text[8] ={0};

	printf("\n\n=====  HightEncryptionTest =====\n\n");

#if 1

	// Test vector 1
	printf("test vectors 1\n");

	//Master Key 
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x11;
	p_hight_data->i_mk[13] = 0x22;
	p_hight_data->i_mk[12] = 0x33;
	p_hight_data->i_mk[11] = 0x44;
	p_hight_data->i_mk[10] = 0x55;
	p_hight_data->i_mk[9] = 0x66;
	p_hight_data->i_mk[8] = 0x77;
	p_hight_data->i_mk[7] = 0x88;
	p_hight_data->i_mk[6] = 0x99;
	p_hight_data->i_mk[5] = 0xaa;
	p_hight_data->i_mk[4] = 0xbb;
	p_hight_data->i_mk[3] = 0xcc;
	p_hight_data->i_mk[2] = 0xdd;
	p_hight_data->i_mk[1] = 0xee;
	p_hight_data->i_mk[0] = 0xff;
	
	// Plain Text 
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0x00;
	p_hight_data->i_pct[5]  = 0x00;
	p_hight_data->i_pct[4]  = 0x00;
	p_hight_data->i_pct[3]  = 0x00;
	p_hight_data->i_pct[2]  = 0x00;
	p_hight_data->i_pct[1]  = 0x00;
	p_hight_data->i_pct[0]  = 0x00;

	// Expected Ciphered Text 
	expected_c_text[7]     = 0x00; 
	expected_c_text[6]     = 0xf4; 
	expected_c_text[5]     = 0x18; 
	expected_c_text[4]     = 0xae; 
	expected_c_text[3]     = 0xd9; 
	expected_c_text[2]     = 0x4f; 
	expected_c_text[1]     = 0x03; 
	expected_c_text[0]     = 0xf2; 

#elif 0
	// Test vectors 2
	printf("test vectors 2\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9]  = 0x99;
	p_hight_data->i_mk[8]  = 0x88;
	p_hight_data->i_mk[7]  = 0x77;
	p_hight_data->i_mk[6]  = 0x66;
	p_hight_data->i_mk[5]  = 0x55;
	p_hight_data->i_mk[4]  = 0x44;
	p_hight_data->i_mk[3]  = 0x33;
	p_hight_data->i_mk[2]  = 0x22;
	p_hight_data->i_mk[1]  = 0x11;
	p_hight_data->i_mk[0]  = 0x00;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0x11;
	p_hight_data->i_pct[5]  = 0x22;
	p_hight_data->i_pct[4]  = 0x33;
	p_hight_data->i_pct[3]  = 0x44;
	p_hight_data->i_pct[2]  = 0x55;
	p_hight_data->i_pct[1]  = 0x66;
	p_hight_data->i_pct[0]  = 0x77;

	// Expected Ciphered Text 
	expected_c_text[7]     = 0x23; 
	expected_c_text[6]     = 0xce; 
	expected_c_text[5]     = 0x9f; 
	expected_c_text[4]     = 0x72; 
	expected_c_text[3]     = 0xe5; 
	expected_c_text[2]     = 0x43; 
	expected_c_text[1]     = 0xe6; 
	expected_c_text[0]     = 0xd8; 

#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9]  = 0x06;
	p_hight_data->i_mk[8]  = 0x07;
	p_hight_data->i_mk[7]  = 0x08;
	p_hight_data->i_mk[6]  = 0x09;
	p_hight_data->i_mk[5]  = 0x0a;
	p_hight_data->i_mk[4]  = 0x0b;
	p_hight_data->i_mk[3]  = 0x0c;
	p_hight_data->i_mk[2]  = 0x0d;
	p_hight_data->i_mk[1]  = 0x0e;
	p_hight_data->i_mk[0]  = 0x0f;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0x01;
	p_hight_data->i_pct[6]  = 0x23;
	p_hight_data->i_pct[5]  = 0x45;
	p_hight_data->i_pct[4]  = 0x67;
	p_hight_data->i_pct[3]  = 0x89;
	p_hight_data->i_pct[2]  = 0xab;
	p_hight_data->i_pct[1]  = 0xcd;
	p_hight_data->i_pct[0]  = 0xef;

	// Expected Ciphered Text 
	expected_c_text[7]     = 0x7a; 
	expected_c_text[6]     = 0x6f; 
	expected_c_text[5]     = 0xb2; 
	expected_c_text[4]     = 0xa2; 
	expected_c_text[3]     = 0x8d; 
	expected_c_text[2]     = 0x23; 
	expected_c_text[1]     = 0xf4; 
	expected_c_text[0]     = 0x66; 

#elif 0
	// Test vector 4
	printf("test vectors 4\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9]  = 0xd8;
	p_hight_data->i_mk[8]  = 0x7d;
	p_hight_data->i_mk[7]  = 0xcf;
	p_hight_data->i_mk[6]  = 0xa5;
	p_hight_data->i_mk[5]  = 0x09;
	p_hight_data->i_mk[4]  = 0xb1;
	p_hight_data->i_mk[3]  = 0x1d;
	p_hight_data->i_mk[2]  = 0x42;
	p_hight_data->i_mk[1]  = 0x2b;
	p_hight_data->i_mk[0]  = 0xe7;
	
	//PlainText
	p_hight_data->i_pct[7]  = 0xb4;
	p_hight_data->i_pct[6]  = 0x1e;
	p_hight_data->i_pct[5]  = 0x6b;
	p_hight_data->i_pct[4]  = 0xe2;
	p_hight_data->i_pct[3]  = 0xeb;
	p_hight_data->i_pct[2]  = 0xa8;
	p_hight_data->i_pct[1]  = 0x4a;
	p_hight_data->i_pct[0]  = 0x14;

	// Expected Ciphered Text 
	expected_c_text[7]     = 0xcc; 
	expected_c_text[6]     = 0x04; 
	expected_c_text[5]     = 0x7a; 
	expected_c_text[4]     = 0x75; 
	expected_c_text[3]     = 0x20; 
	expected_c_text[2]     = 0x9c; 
	expected_c_text[1]     = 0x1f; 
	expected_c_text[0]     = 0xc6;


#endif

	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 
	
	DeltaGen(p_hight_data->delta);	

	SubKeyGen(p_hight_data->i_mk,		
			  p_hight_data->delta,
			  p_hight_data->sk);
	
	InitialWhiteningFunction(ENC, p_hight_data->i_pct, p_hight_data->wk, p_hight_data->iwf);
		
	// RoundFunction1
	InterRoundFunction(ENC,
						p_hight_data->iwf,
						p_hight_data->sk,
						p_hight_data->rf[1]);
	
	// InterRoundFunction2~31
	for(i=1; i<31; i++){
		InterRoundFunction(ENC,
							p_hight_data->rf[i],
							p_hight_data->sk+(i*4),
							p_hight_data->rf[i+1]);
	}
	// RoundFunction32
	FinalRoundFunction(ENC,
						p_hight_data->rf[31],
						p_hight_data->sk+(31*4),
						p_hight_data->rf[32]);

	FinalWhiteningFunction(ENC, p_hight_data->rf[32], p_hight_data->wk, p_hight_data->fwf);
	
	for(i=7; i>=0; i--) {
		p_hight_data->o_cpt[i] = p_hight_data->fwf[i];
	}

	printf("\n>>> plaint text <<<\n");
	for(i=7; i>=0; i--) {
		printf("pt[%02d] = %02x\n", i, p_hight_data->i_pct[i]);
	}

	printf("\n>>> master key <<<\n");
	for(i=15; i>=0; i--) {
		printf("mk[%02d] = %02x\n", i, p_hight_data->i_mk[i]);
	}

	printf("\n>>>  HightEncryption result <<<\n");
	for(i=7; i>=0; i--) {
		if(p_hight_data->o_cpt[i] == expected_c_text[i])
			printf("o_c_text[%02d] = %02x : Correct\n", i , p_hight_data->o_cpt[i]);
		else
			printf("o_c_text[%02d] = %02x : Wrong (expected = %02x) \n", i, p_hight_data->o_cpt[i], expected_c_text[i]);
	}

}

/* =====================================

    HightDecryptionTest()

=======================================*/
void HightDecryptionTest()
{
	int i; 
	byte expected_p_text[8] ={0};
	byte dec_sk[128] = {0};

	printf("\n\n=====  HightDecryptionTest =====\n\n");

#if 0

	// Test vector 1
	printf("test vectors 1\n");

	//Master Key 
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x11;
	p_hight_data->i_mk[13] = 0x22;
	p_hight_data->i_mk[12] = 0x33;
	p_hight_data->i_mk[11] = 0x44;
	p_hight_data->i_mk[10] = 0x55;
	p_hight_data->i_mk[9]  = 0x66;
	p_hight_data->i_mk[8]  = 0x77;
	p_hight_data->i_mk[7]  = 0x88;
	p_hight_data->i_mk[6]  = 0x99;
	p_hight_data->i_mk[5]  = 0xaa;
	p_hight_data->i_mk[4]  = 0xbb;
	p_hight_data->i_mk[3]  = 0xcc;
	p_hight_data->i_mk[2]  = 0xdd;
	p_hight_data->i_mk[1]  = 0xee;
	p_hight_data->i_mk[0]  = 0xff;
	
	// Cipher Text 
	p_hight_data->i_pct[7]  = 0x00;
	p_hight_data->i_pct[6]  = 0xf4;
	p_hight_data->i_pct[5]  = 0x18;
	p_hight_data->i_pct[4]  = 0xae;
	p_hight_data->i_pct[3]  = 0xd9;
	p_hight_data->i_pct[2]  = 0x4f;
	p_hight_data->i_pct[1]  = 0x03;
	p_hight_data->i_pct[0]  = 0xf2;

	// Expected plain Text 
	expected_p_text[7]     = 0x00; 
	expected_p_text[6]     = 0x00; 
	expected_p_text[5]     = 0x00; 
	expected_p_text[4]     = 0x00; 
	expected_p_text[3]     = 0x00; 
	expected_p_text[2]     = 0x00; 
	expected_p_text[1]     = 0x00; 
	expected_p_text[0]     = 0x00; 

#elif 0
	// Test vector 2
	printf("test vectors 2\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0xff;
	p_hight_data->i_mk[14] = 0xee;
	p_hight_data->i_mk[13] = 0xdd;
	p_hight_data->i_mk[12] = 0xcc;
	p_hight_data->i_mk[11] = 0xbb;
	p_hight_data->i_mk[10] = 0xaa;
	p_hight_data->i_mk[9]  = 0x99;
	p_hight_data->i_mk[8]  = 0x88;
	p_hight_data->i_mk[7]  = 0x77;
	p_hight_data->i_mk[6]  = 0x66;
	p_hight_data->i_mk[5]  = 0x55;
	p_hight_data->i_mk[4]  = 0x44;
	p_hight_data->i_mk[3]  = 0x33;
	p_hight_data->i_mk[2]  = 0x22;
	p_hight_data->i_mk[1]  = 0x11;
	p_hight_data->i_mk[0]  = 0x00;

	// Cipher Text 
	p_hight_data->i_pct[7]  = 0x23;
	p_hight_data->i_pct[6]  = 0xce;
	p_hight_data->i_pct[5]  = 0x9f;
	p_hight_data->i_pct[4]  = 0x72;
	p_hight_data->i_pct[3]  = 0xe5;
	p_hight_data->i_pct[2]  = 0x43;
	p_hight_data->i_pct[1]  = 0xe6;
	p_hight_data->i_pct[0]  = 0xd8;

	// Expected Plain Text 
	expected_p_text[7]     = 0x00; 
	expected_p_text[6]     = 0x11; 
	expected_p_text[5]     = 0x22; 
	expected_p_text[4]     = 0x33; 
	expected_p_text[3]     = 0x44; 
	expected_p_text[2]     = 0x55; 
	expected_p_text[1]     = 0x66; 
	expected_p_text[0]     = 0x77; 


#elif 0
	// Test vector 3
	printf("test vectors 3\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0x00;
	p_hight_data->i_mk[14] = 0x01;
	p_hight_data->i_mk[13] = 0x02;
	p_hight_data->i_mk[12] = 0x03;
	p_hight_data->i_mk[11] = 0x04;
	p_hight_data->i_mk[10] = 0x05;
	p_hight_data->i_mk[9]  = 0x06;
	p_hight_data->i_mk[8]  = 0x07;
	p_hight_data->i_mk[7]  = 0x08;
	p_hight_data->i_mk[6]  = 0x09;
	p_hight_data->i_mk[5]  = 0x0a;
	p_hight_data->i_mk[4]  = 0x0b;
	p_hight_data->i_mk[3]  = 0x0c;
	p_hight_data->i_mk[2]  = 0x0d;
	p_hight_data->i_mk[1]  = 0x0e;
	p_hight_data->i_mk[0]  = 0x0f;

	// Cipher Text 
	p_hight_data->i_pct[7]  = 0x7a;
	p_hight_data->i_pct[6]  = 0x6f;
	p_hight_data->i_pct[5]  = 0xb2;
	p_hight_data->i_pct[4]  = 0xa2;
	p_hight_data->i_pct[3]  = 0x8d;
	p_hight_data->i_pct[2]  = 0x23;
	p_hight_data->i_pct[1]  = 0xf4;
	p_hight_data->i_pct[0]  = 0x66;

	// Expected plain Text 
	expected_p_text[7]     = 0x01; 
	expected_p_text[6]     = 0x23; 
	expected_p_text[5]     = 0x45; 
	expected_p_text[4]     = 0x67; 
	expected_p_text[3]     = 0x89; 
	expected_p_text[2]     = 0xab; 
	expected_p_text[1]     = 0xcd; 
	expected_p_text[0]     = 0xef; 

#elif 1
	// Test vector 4
	printf("test vectors 4\n");

	//MasterKey
	p_hight_data->i_mk[15] = 0x28;
	p_hight_data->i_mk[14] = 0xdb;
	p_hight_data->i_mk[13] = 0xc3;
	p_hight_data->i_mk[12] = 0xbc;
	p_hight_data->i_mk[11] = 0x49;
	p_hight_data->i_mk[10] = 0xff;
	p_hight_data->i_mk[9]  = 0xd8;
	p_hight_data->i_mk[8]  = 0x7d;
	p_hight_data->i_mk[7]  = 0xcf;
	p_hight_data->i_mk[6]  = 0xa5;
	p_hight_data->i_mk[5]  = 0x09;
	p_hight_data->i_mk[4]  = 0xb1;
	p_hight_data->i_mk[3]  = 0x1d;
	p_hight_data->i_mk[2]  = 0x42;
	p_hight_data->i_mk[1]  = 0x2b;
	p_hight_data->i_mk[0]  = 0xe7;

	// Cipher Text 
	p_hight_data->i_pct[7]  = 0xcc;
	p_hight_data->i_pct[6]  = 0x04;
	p_hight_data->i_pct[5]  = 0x7a;
	p_hight_data->i_pct[4]  = 0x75;
	p_hight_data->i_pct[3]  = 0x20;
	p_hight_data->i_pct[2]  = 0x9c;
	p_hight_data->i_pct[1]  = 0x1f;
	p_hight_data->i_pct[0]  = 0xc6;

	// Expected plain Text 
	expected_p_text[7]     = 0xb4; 
	expected_p_text[6]     = 0x1e; 
	expected_p_text[5]     = 0x6b; 
	expected_p_text[4]     = 0xe2; 
	expected_p_text[3]     = 0xeb; 
	expected_p_text[2]     = 0xa8; 
	expected_p_text[1]     = 0x4a; 
	expected_p_text[0]     = 0x14; 

#endif

	WhiteningKeyGen(p_hight_data->i_mk, p_hight_data->wk); 
	
	DeltaGen(p_hight_data->delta);	

	SubKeyGen(p_hight_data->i_mk,		
			  p_hight_data->delta,
			  p_hight_data->sk);

	// Reverse of sk 
	for(i=0; i<=127; i++){
		dec_sk[127-i] = p_hight_data->sk[i];
	}
	
	FinalWhiteningFunction(DEC, p_hight_data->i_pct, p_hight_data->wk, p_hight_data->fwf);
		
	// RoundFunction1
	InterRoundFunction(DEC,
						p_hight_data->fwf,
						dec_sk,//p_hight_data->sk+124,
						p_hight_data->rf[1]);
	
	// InterRoundFunction2~31
	for(i=1; i<31; i++){
		InterRoundFunction(DEC,
							p_hight_data->rf[i],
							dec_sk+i*4, //p_hight_data->sk+((31-i)*4),
							p_hight_data->rf[i+1]);
	}
	// RoundFunction32
	FinalRoundFunction(DEC,
						p_hight_data->rf[31],
						dec_sk+124, //p_hight_data->sk,
						p_hight_data->rf[32]);

	InitialWhiteningFunction(DEC, p_hight_data->rf[32], p_hight_data->wk, p_hight_data->iwf);
	
	for(i=7; i>=0; i--) {
		p_hight_data->o_cpt[i] = p_hight_data->iwf[i];
	}

	printf("\n>>> Cipher text <<<\n");
	for(i=7; i>=0; i--) {
		printf("pt[%02d] = %02x\n", i, p_hight_data->i_pct[i]);
	}

	printf("\n>>> Master key <<<\n");
	for(i=15; i>=0; i--) {
		printf("mk[%02d] = %02x\n", i, p_hight_data->i_mk[i]);
	}

	printf("\n>>>  HightDecryption result <<<\n");
	for(i=7; i>=0; i--) {
		if(p_hight_data->o_cpt[i] == expected_p_text[i])
			printf("o_c_text[%02d] = %02x : Correct\n", i , p_hight_data->o_cpt[i]);
		else
			printf("o_c_text[%02d] = %02x : Wrong (expected = %02x) \n", i, p_hight_data->o_cpt[i], expected_p_text[i]);
	}

	printf("\n\n====  Verbose Log  ====\n");

	printf("\n>>>  FinalWhiFunction <<<\n");
	printf("Final     : %02x %02x %02x %02x %02x %02x %02x %02x \n",
		    p_hight_data->fwf[7], p_hight_data->fwf[6], p_hight_data->fwf[5], p_hight_data->fwf[4],
			p_hight_data->fwf[3], p_hight_data->fwf[2], p_hight_data->fwf[1], p_hight_data->fwf[0]);

	printf("\n>>>  RoundFunction <<<\n");
	for(i=1; i<=32; i++){
		printf("Round[%02d] : %02x %02x %02x %02x %02x %02x %02x %02x\n",
			    i, p_hight_data->rf[i][7], p_hight_data->rf[i][6], 
				   p_hight_data->rf[i][5], p_hight_data->rf[i][4],
				   p_hight_data->rf[i][3], p_hight_data->rf[i][2], 
				   p_hight_data->rf[i][1], p_hight_data->rf[i][0]);
	}

	printf("\n>>>  InitialWhiteningFunction <<<\n");
	printf("Initial   : %02x %02x %02x %02x %02x %02x %02x %02x\n",
		    p_hight_data->iwf[7], p_hight_data->iwf[6], p_hight_data->iwf[5], p_hight_data->iwf[4],
			p_hight_data->iwf[3], p_hight_data->iwf[2], p_hight_data->iwf[1], p_hight_data->iwf[0]);


}


