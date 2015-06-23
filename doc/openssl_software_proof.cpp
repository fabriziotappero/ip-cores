//////////////////////////////////////////////////////////////////
////
////
//// 	AES CORE BLOCK
////
////
////
//// This file is part of the APB to AES128 project
////
//// http://www.opencores.org/cores/apbtoaes128/
////
////
////
//// Description
////
//// Implementation of APB IP core according to
////
//// aes128_spec IP core specification document.
////
////
////
//// To Do: Things are right here but always all block can suffer changes
////
////
////
////
////
//// Author(s): - Felipe Fernandes Da Costa, fefe2560@gmail.com
////
///////////////////////////////////////////////////////////////// 
////
////
//// Copyright (C) 2009 Authors and OPENCORES.ORG
////
////
////
//// This source file may be used and distributed without
////
//// restriction provided that this copyright statement is not
////
//// removed from the file and that any derivative work contains
//// the original copyright notice and the associated disclaimer.
////
////
//// This source file is free software; you can redistribute it
////
//// and/or modify it under the terms of the GNU Lesser General
////
//// Public License as published by the Free Software Foundation;
//// either version 2.1 of the License, or (at your option) any
////
//// later version.
////
////
////
//// This source is distributed in the hope that it will be
////
//// useful, but WITHOUT ANY WARRANTY; without even the implied
////
//// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
////
//// PURPOSE. See the GNU Lesser General Public License for more
//// details.
////
////
////
//// You should have received a copy of the GNU Lesser General
////
//// Public License along with this source; if not, download it
////
//// from http://www.opencores.org/lgpl.shtml
////
////
///////////////////////////////////////////////////////////////////
#include <iostream>
#include <openssl/aes.h>  
#include <stdio.h>
#include <string.h>

using namespace std;


//g++ teste.cpp -o teste -lm -m64  -lcrypto



unsigned char TEXT_FIPS_NOT_DERIVATED[]	    = {0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF};
unsigned char KEY_FIPS_NOT_DERIVATED[]      = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};

unsigned char TEXT_FIPS_DERIVATED[] 	    = {0x69,0xC4,0xE0,0xD8,0x6A,0x7B,0x04,0x30,0xD8,0xCD,0xB7,0x80,0x70,0xB4,0xC5,0x5A};
unsigned char KEY_FIPS_DERIVATED[]          = {0x13,0x11,0x1D,0x7F,0xE3,0x94,0x4A,0x17,0xF3,0x07,0xA7,0x8B,0x4D,0x2B,0x30,0xC5};


unsigned char KEY_FIPS_CBC_NOT_DERIVATED[]  = {0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};

unsigned char IV_FIPS_CBC_NOT_DERIVATED[]   = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};
unsigned char IV_FIPS_CBC_NOT_DERIVATEDD[]   = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};

unsigned char TEXT_FIPS_CBC_NOT_DERIVATED[] = {0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};

unsigned char TEXT_CBC_FIPS_DERIVATED[]     = {0x76,0x49,0xAB,0xAC,0x81,0x19,0xB2,0x46,0xCE,0xE9,0x8E,0x9B,0x12,0xE9,0x19,0x7D};


unsigned char KEY_FIPS_CTR_NOT_DERIVATED[]  = {0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};
unsigned char IV_FIPS_CTR_NOT_DERIVATED[]   = {0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF};
unsigned char TEXT_FIPS_CTR_NOT_DERIVATED[] = {0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};

unsigned char TEXT_CTR_FIPS_DERIVATED[]     = {0x87,0x4D,0x61,0x91,0xB6,0x20,0xE3,0x26,0x1B,0xEF,0x68,0x64,0x99,0x0D,0xB6,0xCE};

unsigned char TEXT_NULL[]		    = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

unsigned char CBLOCK[16];
unsigned char BLOCK[16];


struct ctr_state { 
    unsigned char ivec[16];   
    unsigned int num; 
    unsigned char ecount[16]; 
};

struct ctr_state state;



int main()
{
	
	unsigned long int result[4];
	unsigned char result_to_compare[16];
	unsigned char *ptr;

	int i,j,n;

	for(i=0;i<=16;i++)
	{
		CBLOCK[i]='0';
	}

	AES_KEY wctx;

	printf(" ECB SAMPLE \n");

	AES_set_encrypt_key(KEY_FIPS_NOT_DERIVATED, 128, &wctx);	
	AES_encrypt(TEXT_FIPS_NOT_DERIVATED, CBLOCK, &wctx);


	result[0]=wctx.rd_key[40];
	result[1]=wctx.rd_key[41];
	result[2]=wctx.rd_key[42];
	result[3]=wctx.rd_key[43];


	for(i=0,n=0;i<4;i++)
	{
		ptr = (unsigned char *)&result[i];

		for(j=0;j<4;j++)
		{
			result_to_compare[j+n] = ptr[j];
		}
		n=n+4;

	}


	printf("TEXT ECB ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
									    CBLOCK[1],
								       	    CBLOCK[2],
								       	    CBLOCK[3],
							               	    CBLOCK[4],
								       	    CBLOCK[5],
								            CBLOCK[6],
								            CBLOCK[7],
								            CBLOCK[8],
								            CBLOCK[9],
								            CBLOCK[10],
								            CBLOCK[11],
								            CBLOCK[12],
								            CBLOCK[13],
								            CBLOCK[14],
								            CBLOCK[15]);

	printf("KEY  ECB ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n", result_to_compare[0],
    									result_to_compare[1],
									result_to_compare[2],
									result_to_compare[3],
									result_to_compare[4],
									result_to_compare[5],
									result_to_compare[6],
									result_to_compare[7],
									result_to_compare[8],
									result_to_compare[9],
									result_to_compare[10],
									result_to_compare[11],
									result_to_compare[12],
									result_to_compare[13],
									result_to_compare[14],
									result_to_compare[15]);


	AES_set_decrypt_key(KEY_FIPS_NOT_DERIVATED, 128, &wctx);


	result[0]=wctx.rd_key[4];
	result[1]=wctx.rd_key[5];
	result[2]=wctx.rd_key[6];
	result[3]=wctx.rd_key[7];


	//AES_set_encrypt_key(result_to_compare, 128, &wctx);	
	AES_decrypt(TEXT_FIPS_DERIVATED, CBLOCK, &wctx);

	printf("TEXT ECB DECRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
					    				CBLOCK[1],
									CBLOCK[2],
									CBLOCK[3],
									CBLOCK[4],
									CBLOCK[5],
									CBLOCK[6],
									CBLOCK[7],
									CBLOCK[8],
									CBLOCK[9],
									CBLOCK[10],
									CBLOCK[11],
									CBLOCK[12],
									CBLOCK[13],
									CBLOCK[14],
									CBLOCK[15]);

	printf(" CBC SAMPLE \n");

	//CBC
	for(i=0;i<=16;i++)
	{
		CBLOCK[i]='0';
	}

	AES_set_encrypt_key(KEY_FIPS_CBC_NOT_DERIVATED, 128, &wctx);
	AES_cbc_encrypt(TEXT_FIPS_CBC_NOT_DERIVATED, CBLOCK, 16, &wctx ,IV_FIPS_CBC_NOT_DERIVATED, AES_ENCRYPT);	

	result[0]=wctx.rd_key[40];
	result[1]=wctx.rd_key[41];
	result[2]=wctx.rd_key[42];
	result[3]=wctx.rd_key[43];


	for(i=0,n=0;i<4;i++)
	{
		ptr = (unsigned char *)&result[i];

		for(j=0;j<4;j++)
		{
			result_to_compare[j+n] = ptr[j];
		}
		n=n+4;

	}


	printf("TEXT CBC ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
									    CBLOCK[1],
								       	    CBLOCK[2],
								       	    CBLOCK[3],
							               	    CBLOCK[4],
								       	    CBLOCK[5],
								            CBLOCK[6],
								            CBLOCK[7],
								            CBLOCK[8],
								            CBLOCK[9],
								            CBLOCK[10],
								            CBLOCK[11],
								            CBLOCK[12],
								            CBLOCK[13],
								            CBLOCK[14],
								            CBLOCK[15]);

	printf("KEY  CBC ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n", result_to_compare[0],
    									result_to_compare[1],
									result_to_compare[2],
									result_to_compare[3],
									result_to_compare[4],
									result_to_compare[5],
									result_to_compare[6],
									result_to_compare[7],
									result_to_compare[8],
									result_to_compare[9],
									result_to_compare[10],
									result_to_compare[11],
									result_to_compare[12],
									result_to_compare[13],
									result_to_compare[14],
									result_to_compare[15]);


	AES_set_decrypt_key(KEY_FIPS_CBC_NOT_DERIVATED, 128, &wctx);
	for(i=0;i<=16;i++)
	{
		CBLOCK[i]='0';
	}
	//AES_decrypt(TEXT_CBC_FIPS_DERIVATED, CBLOCK, &wctx);
	AES_cbc_encrypt(TEXT_CBC_FIPS_DERIVATED, CBLOCK, 16, &wctx ,IV_FIPS_CBC_NOT_DERIVATEDD, AES_DECRYPT);	

	


	printf("TEXT CBC DECRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
									    CBLOCK[1],
								       	    CBLOCK[2],
								       	    CBLOCK[3],
							               	    CBLOCK[4],
								       	    CBLOCK[5],
								            CBLOCK[6],
								            CBLOCK[7],
								            CBLOCK[8],
								            CBLOCK[9],
								            CBLOCK[10],
								            CBLOCK[11],
								            CBLOCK[12],
								            CBLOCK[13],
								            CBLOCK[14],
								            CBLOCK[15]);

	printf(" CTR SAMPLE \n");

	//CTR
	memset(CBLOCK , 0, 16);
	state.num=0;
	memset(state.ecount , 0, 16);
	memset(state.ivec , 0, 16);
	memcpy(state.ivec, IV_FIPS_CTR_NOT_DERIVATED, 16);

	AES_set_encrypt_key(KEY_FIPS_CTR_NOT_DERIVATED, 128, &wctx);
	AES_ctr128_encrypt(TEXT_FIPS_CTR_NOT_DERIVATED, CBLOCK , 16 ,  &wctx,  state.ivec , state.ecount , &state.num);


	result[0]=wctx.rd_key[40];
	result[1]=wctx.rd_key[41];
	result[2]=wctx.rd_key[42];
	result[3]=wctx.rd_key[43];


	for(i=0,n=0;i<4;i++)
	{
		ptr = (unsigned char *)&result[i];

		for(j=0;j<4;j++)
		{
			result_to_compare[j+n] = ptr[j];
		}
		n=n+4;

	}


	

	printf("TEXT CTR ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
									    CBLOCK[1],
								       	    CBLOCK[2],
								       	    CBLOCK[3],
							               	    CBLOCK[4],
								       	    CBLOCK[5],
								            CBLOCK[6],
								            CBLOCK[7],
								            CBLOCK[8],
								            CBLOCK[9],
								            CBLOCK[10],
								            CBLOCK[11],
								            CBLOCK[12],
								            CBLOCK[13],
								            CBLOCK[14],
								            CBLOCK[15]);

	printf("KEY  CTR ENCRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n", result_to_compare[0],
    									result_to_compare[1],
									result_to_compare[2],
									result_to_compare[3],
									result_to_compare[4],
									result_to_compare[5],
									result_to_compare[6],
									result_to_compare[7],
									result_to_compare[8],
									result_to_compare[9],
									result_to_compare[10],
									result_to_compare[11],
									result_to_compare[12],
									result_to_compare[13],
									result_to_compare[14],
									result_to_compare[15]);

	memset(CBLOCK , 0, 16);
	state.num=0;
	memset(state.ecount , 0, 16);
	memset(state.ivec , 0, 16);
	memcpy(state.ivec, IV_FIPS_CTR_NOT_DERIVATED, 16);


	AES_set_encrypt_key(KEY_FIPS_CTR_NOT_DERIVATED, 128, &wctx);
	AES_ctr128_encrypt(TEXT_CTR_FIPS_DERIVATED, CBLOCK , 16 ,  &wctx,  state.ivec , state.ecount , &state.num);

	printf("TEXT CTR DECRYPTED: %x%x%x%x %x%x%x%x %x%x%x%x %x%x%x%x \n",CBLOCK[0],
									    CBLOCK[1],
								       	    CBLOCK[2],
								       	    CBLOCK[3],
							               	    CBLOCK[4],
								       	    CBLOCK[5],
								            CBLOCK[6],
								            CBLOCK[7],
								            CBLOCK[8],
								            CBLOCK[9],
								            CBLOCK[10],
								            CBLOCK[11],
								            CBLOCK[12],
								            CBLOCK[13],
								            CBLOCK[14],
								            CBLOCK[15]);

 return 0;
}
