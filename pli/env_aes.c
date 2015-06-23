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

#include "../iverilog/vpi_user.h"
//#include <vpi_user.h>
#include <iostream>
#include <random>
#include<string.h>


s_vpi_value v_generate;

s_vpi_value v_ecb;
s_vpi_time  t_ecb;

s_vpi_value v_monitor;
s_vpi_value v_monitor_catch;

s_vpi_time  t_monitor;

s_vpi_value v_wr;
s_vpi_time  t_wr;

s_vpi_value v_reset;
s_vpi_time  t_reset;


s_vpi_value v_initial;
s_vpi_time  t_initial;

//USED BY BFM ONLY
unsigned long  int a;
unsigned long  int b;
unsigned long  int c;
unsigned long  int d;


//USED BY MONITOR ONLY
unsigned long  int A;
unsigned long  int B;
unsigned long  int C;
unsigned long  int D;


unsigned long  int E;
unsigned long  int F;
unsigned long  int G;
unsigned long  int H;

unsigned long  int I;

unsigned long  int J;
unsigned long  int L;
unsigned long  int M;
unsigned long  int N;

unsigned long  int O;

unsigned long  int last_cr;

int counter_sufle;

int type_bfm;

int STATE;
int STATE_RESET;

int counter;
int counter_monitor;
int cycle_counter;

int flag;

int DATATYPE;

int reset_counter;
int counter_reset_enter;
int counter_reset_wait;
int FIPS_ENABLE;

int RESET_GENERATED;
int PACKETS_GENERATED;

int counter_write;
int counter_read;
int counter_wait;

/* DATATYPE */
#define TYPE_00 0
#define TYPE_01 1
#define TYPE_02 2
#define TYPE_03 3

/*AES REGISTERS*/
#define ADDR_AES_CR 0
#define ADDR_AES_SR 4
#define ADDR_AES_DINR 8

#define ADDR_AES_DOUTR 12
#define ADDR_AES_KEYR0 16
#define ADDR_AES_KEYR1 20
#define ADDR_AES_KEYR2 24
#define ADDR_AES_KEYR3 28

#define ADDR_AES_IVR0 32
#define ADDR_AES_IVR1 36
#define ADDR_AES_IVR2 40
#define ADDR_AES_IVR3 44

int vector_address[11];

int vector_CR[233];

/*STATE MACHINE TO WORK WITH BFM*/
#define IDLE           0
#define WRITE          1
#define WAIT           2
#define READ_RESULTS   3

#define WRITE_DINR     4
#define READ_DOUTR     5
#define WAIT_SR	       6
#define RESET_SR       7 
#define READ_KEY_GEN   8


/*STATE MACHINE TO WORK WITH BFM RESET*/
#define ENTER_RESET    9
#define WAIT_RESET    10
#define GET_OUT_RESET 11


#define AES_WR_ONLY 99
#define AES_WR_ERROR_DINR_ONLY 100
#define AES_WR_ERROR_DOUTR_ONLY 101

/*TEST USING NAMES TO ENABLE BFMs*/
#define ECB_ENCRYPTION                   1
#define ECB_DECRYPTION                   2
#define ECB_KEY_GEN                      3
#define ECB_DERIVATION_DECRYPTION        4

#define ECB_ENCRYPTION_DMA               5
#define ECB_DECRYPTION_DMA   	         6
#define ECB_KEY_GEN_DMA      	         7
#define ECB_DERIVATION_DECRYPTION_DMA    8

#define ECB_ENCRYPTION_CCFIE             9
#define ECB_DECRYPTION_CCFIE            10
#define ECB_DERIVATION_DECRYPTION_CCFIE 11
#define ECB_KEY_GEN_CCFIE		12

/*TEST USING CBC*/

#define CBC_ENCRYPTION                  13
#define CBC_DECRYPTION                  14
#define CBC_KEY_GEN                     15
#define CBC_DERIVATION_DECRYPTION       16

#define CBC_ENCRYPTION_DMA              17
#define CBC_DECRYPTION_DMA   	        18
#define CBC_KEY_GEN_DMA      	        19
#define CBC_DERIVATION_DECRYPTION_DMA   20

#define CBC_ENCRYPTION_CCFIE            21
#define CBC_DECRYPTION_CCFIE            22
#define CBC_DERIVATION_DECRYPTION_CCFIE 23
#define CBC_KEY_GEN_CCFIE		24

/*TEST USING CTR*/
#define CTR_ENCRYPTION 		        25
#define CTR_DECRYPTION 		        26
#define CTR_KEY_GEN    		        27
#define CTR_DERIVATION_DECRYPTION       28

#define CTR_ENCRYPTION_DMA              29
#define CTR_DECRYPTION_DMA   	        30
#define CTR_KEY_GEN_DMA      	        31
#define CTR_DERIVATION_DECRYPTION_DMA   32

#define CTR_ENCRYPTION_CCFIE            33
#define CTR_DECRYPTION_CCFIE            34
#define CTR_DERIVATION_DECRYPTION_CCFIE 35
#define CTR_KEY_GEN_CCFIE		36

/*SUFLE TEST*/
#define SUFLE_TEST			37

/*TYPE CONFIGURATION USED TO INSERT DATA ON DUT*/
#define FIPS 0
#define RANDOM_DATA 1


/*MAX PACKETS GENERATION*/
#define MAX_ITERATIONS 4

#define MAX_ITERATION_PER_SUFLE 6

/*MAX RESET GENERATION */
#define MAX_RESET_TIMES 4

/*THIS IS USED BY MONITOR TO CATCH INPUTS AND OUTPUTS*/	
unsigned char INPUT_KEYR[16];
unsigned char OUTPUT_KEYR[16];

unsigned char INPUT_IVR[16];
unsigned char OUTPUT_IVR[16];

unsigned char INPUT_TEXT[16];
unsigned char OUTPUT_TEXT[16];


/*THIS INCLUDE IS USED TO GENERATE DATA DO BE INSERTED ON DUT*/
unsigned char TEXT_FIPS_NOT_DATATYPE_DERIVATED[] = {0x22,0x33,0x00,0x11,0x66,0x77,0x44,0x55,0xAA,0xBB,0x88,0x99,0xEE,0xFF,0xCC,0xDD};
unsigned char TEXT_FIPS_NOT_DERIVATED[]    	 = {0x00,0x11,0x22,0x33,0x44,0x55,0x66,0x77,0x88,0x99,0xAA,0xBB,0xCC,0xDD,0xEE,0xFF};
unsigned char KEY_FIPS_NOT_DERIVATED[]     	 = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};

unsigned char TEXT_FIPS_DERIVATED[] 	    	 = {0x69,0xC4,0xE0,0xD8,0x6A,0x7B,0x04,0x30,0xD8,0xCD,0xB7,0x80,0x70,0xB4,0xC5,0x5A};
unsigned char TEXT_FIPS_DATATYPE_T01_DERIVATED[] = {0xE0,0xD8,0x69,0xC4,0x04,0x30,0x6A,0x7B,0xB7,0x80,0xD8,0xCD,0xC5,0x5A,0x70,0xB4};
unsigned char TEXT_FIPS_DATATYPE_T02_DERIVATED[] = {0x15,0xDA,0x8D,0x52,0x27,0x77,0xA3,0x69,0x6D,0x2C,0x49,0x5B,0x08,0x13,0xBF,0x90};
unsigned char TEXT_FIPS_DATATYPE_T03_DERIVATED[] = {0xA3,0xB4,0x12,0xDA,0x43,0x04,0x7B,0x7C,0x21,0xEC,0x50,0x0A,0xDF,0x0B,0xF6,0x77};
unsigned char KEY_FIPS_DERIVATED[]  	    	 = {0x13,0x11,0x1D,0x7F,0xE3,0x94,0x4A,0x17,0xF3,0x07,0xA7,0x8B,0x4D,0x2B,0x30,0xC5};


unsigned char KEY_FIPS_CBC_NOT_DERIVATED[] 	 = {0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};
unsigned char IV_FIPS_CBC_NOT_DERIVATED[]  	 = {0x00,0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0A,0x0B,0x0C,0x0D,0x0E,0x0F};


unsigned char TEXT_FIPS_CBC_NOT_DERIVATED[]	 = {0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};
unsigned char TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED[] = {0xBE,0xE2,0x6B,0xC1,0x9F,0x96,0x2E,0x40,0x7E,0x11,0xE9,0x3D,0x17,0x2A,0x73,0x93};
unsigned char KEY_FIPS_CBC_DERIVATED[]     	 = {0xD0,0x14,0xF9,0xA8,0xC9,0xEE,0x25,0x89,0xE1,0x3F,0x0C,0xC8,0xB6,0x63,0x0C,0xA6};


unsigned char TEXT_CBC_FIPS_DERIVATED[]   	     = {0x76,0x49,0xAB,0xAC,0x81,0x19,0xB2,0x46,0xCE,0xE9,0x8E,0x9B,0x12,0xE9,0x19,0x7D};
unsigned char TEXT_CBC_FIPS_DATATYPE_T01_DERIVATED[] = {0xAB,0xAC,0x76,0x49,0xB2,0x46,0x81,0x19,0x8E,0x9B,0xCE,0xE9,0x19,0x7D,0x12,0xE9};
unsigned char TEXT_CBC_FIPS_DATATYPE_T02_DERIVATED[] = {0xCD,0x29,0x94,0xFC,0xF6,0xAE,0x27,0x96,0x7D,0xA4,0x45,0xFA,0x28,0x9E,0xE8,0x39};
unsigned char TEXT_CBC_FIPS_DATATYPE_T03_DERIVATED[] = {0x7F,0x59,0xFD,0x0E,0x0F,0x88,0xD0,0x32,0x7F,0x75,0x0E,0xB5,0x07,0x85,0xC3,0x4E};


unsigned char KEY_FIPS_CTR_NOT_DERIVATED[]	  = {0x2B,0x7E,0x15,0x16,0x28,0xAE,0xD2,0xA6,0xAB,0xF7,0x15,0x88,0x09,0xCF,0x4F,0x3C};
unsigned char IV_FIPS_CTR_NOT_DERIVATED[] 	  = {0xF0,0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xF8,0xF9,0xFA,0xFB,0xFC,0xFD,0xFE,0xFF};
unsigned char TEXT_FIPS_CTR_NOT_DERIVATED[]	  = {0x6B,0xC1,0xBE,0xE2,0x2E,0x40,0x9F,0x96,0xE9,0x3D,0x7E,0x11,0x73,0x93,0x17,0x2A};
unsigned char TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED[]  = {0xBE,0xE2,0x6B,0xC1,0x9F,0x96,0x2E,0x40,0x7E,0x11,0xE9,0x3D,0x17,0x2A,0x73,0x93};

unsigned char TEXT_CTR_FIPS_DERIVATED[]  	  = {0x87,0x4D,0x61,0x91,0xB6,0x20,0xE3,0x26,0x1B,0xEF,0x68,0x64,0x99,0x0D,0xB6,0xCE};
unsigned char TEXT_CTR_FIPS_DATATYPE_T01_DERIVATED[]  = {0x61,0x91,0x87,0x4D,0xE3,0x26,0xB6,0x20,0x68,0x64,0x1B,0xEF,0xB6,0xCE,0x99,0x0D};
unsigned char TEXT_CTR_FIPS_DATATYPE_T02_DERIVATED[]  = {0xCD,0x3D,0xE7,0x2D,0x2F,0xEA,0x4E,0xD8,0x0B,0x07,0x3B,0xCF,0xF3,0x8B,0xED,0x79};
unsigned char TEXT_CTR_FIPS_DATATYPE_T03_DERIVATED[]  = {0x70,0x19,0x5A,0xF6,0x92,0xA8,0x28,0x59,0xD0,0x79,0xA2,0x72,0x30,0xAF,0x0A,0xC4};
unsigned char KEY_FIPS_CTR_DERIVATED[] 		  = {0xD0,0x14,0xF9,0xA8,0xC9,0xEE,0x25,0x89,0xE1,0x3F,0x0C,0xC8,0xB6,0x63,0x0C,0xA6};

unsigned char TEXT_NULL[]			  = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};

/*BFM CONTROL FLOW*/
#include "aes_bfm_generate.h"

/*BASIC TEST WRITE READ*/
#include "aes_bfm_wr.h"
#include "bfm_error/aes_bfm_wr_error_dinr.h"
#include "bfm_error/aes_bfm_wr_error_doutr.h"

/*ECB TEST CASES*/
#include "bfm_ecb/aes_bfm_encryption_ecb.h"
#include "bfm_ecb/aes_bfm_decryption_ecb.h"
#include "bfm_ecb/aes_bfm_derivation_decryption_ecb.h"
#include "bfm_ecb/aes_bfm_key_generation_ecb.h"

#include "bfm_ecb/aes_bfm_decryption_dma_ecb.h"
#include "bfm_ecb/aes_bfm_encryption_dma_ecb.h"
#include "bfm_ecb/aes_bfm_key_generation_dma_ecb.h"
#include "bfm_ecb/aes_bfm_derivation_decryption_dma_ecb.h"

#include "bfm_ecb/aes_bfm_encryption_ccfie_ecb.h"
#include "bfm_ecb/aes_bfm_decryption_ccfie_ecb.h"
#include "bfm_ecb/aes_bfm_derivation_decryption_ccfie_ecb.h"
#include "bfm_ecb/aes_bfm_key_generation_ccfie_ecb.h"

/*CBC TEST CASES*/

#include "bfm_cbc/aes_bfm_encryption_cbc.h"
#include "bfm_cbc/aes_bfm_decryption_cbc.h"
#include "bfm_cbc/aes_bfm_derivation_decryption_cbc.h"
#include "bfm_cbc/aes_bfm_key_generation_cbc.h"

#include "bfm_cbc/aes_bfm_encryption_dma_cbc.h"
#include "bfm_cbc/aes_bfm_decryption_dma_cbc.h"
#include "bfm_cbc/aes_bfm_derivation_decryption_dma_cbc.h"
#include "bfm_cbc/aes_bfm_key_generation_dma_cbc.h"

#include "bfm_cbc/aes_bfm_encryption_ccfie_cbc.h"
#include "bfm_cbc/aes_bfm_decryption_ccfie_cbc.h"
#include "bfm_cbc/aes_bfm_derivation_decryption_ccfie_cbc.h"
#include "bfm_cbc/aes_bfm_key_generation_ccfie_cbc.h"

/*CTR TEST CASES*/

#include "bfm_ctr/aes_bfm_encryption_ctr.h"
#include "bfm_ctr/aes_bfm_decryption_ctr.h"
#include "bfm_ctr/aes_bfm_key_generation_ctr.h"
#include "bfm_ctr/aes_bfm_derivation_decryption_ctr.h"

#include "bfm_ctr/aes_bfm_encryption_dma_ctr.h"
#include "bfm_ctr/aes_bfm_decryption_dma_ctr.h"
#include "bfm_ctr/aes_bfm_key_generation_dma_ctr.h"
#include "bfm_ctr/aes_bfm_derivation_decryption_dma_ctr.h"

#include "bfm_ctr/aes_bfm_encryption_ccfie_ctr.h"
#include "bfm_ctr/aes_bfm_decryption_ccfie_ctr.h"
#include "bfm_ctr/aes_bfm_key_generation_ccfie_ctr.h"
#include "bfm_ctr/aes_bfm_derivation_decryption_ccfie_ctr.h"

/*SUFLE TEST*/
 #include "random/aes_bfm_sufle.h"

/*ENV CONFIG */
#include "aes_init.h"
#include "aes_monitor.h"
#include "aes_bfm_reset.h"
#include "aes_init_reset.h"


void AES_GLADIC_register()
{

      s_vpi_systf_data tf_data;

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_generate_type";
      tf_data.calltf    = aes_bfm_generate_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);


      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_wr_aes128";
      tf_data.calltf    = aes_bfm_wr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //DMA WITH ERROR 
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_wr_error_dinr_aes128";
      tf_data.calltf    = aes_bfm_wr_error_dinr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_wr_error_doutr_aes128";
      tf_data.calltf    = aes_bfm_wr_error_doutr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //ECB ENCRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ecb_aes128";
      tf_data.calltf    = aes_bfm_encryption_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ecb_dma_aes128";
      tf_data.calltf    =  aes_bfm_encryption_ecb_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ccfie_ecb_aes128";
      tf_data.calltf    =  aes_bfm_encryption_ccfie_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CBC ENCRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_cbc_aes128";
      tf_data.calltf    = aes_bfm_encryption_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_cbc_dma_aes128";
      tf_data.calltf    =  aes_bfm_encryption_cbc_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ccfie_cbc_aes128";
      tf_data.calltf    =  aes_bfm_encryption_ccfie_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CTR ENCRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ctr_aes128";
      tf_data.calltf    = aes_bfm_encryption_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ctr_dma_aes128";
      tf_data.calltf    =  aes_bfm_encryption_ctr_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_encryption_ccfie_ctr_aes128";
      tf_data.calltf    =  aes_bfm_encryption_ccfie_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //ECB DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ecb_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ecb_dma_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ecb_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ccfie_ecb_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ccfie_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CBC DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_cbc_aes128";
      tf_data.calltf    =  aes_bfm_decryption_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_cbc_dma_aes128";
      tf_data.calltf    =  aes_bfm_decryption_cbc_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ccfie_cbc_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ccfie_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CTR DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ctr_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ctr_dma_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ctr_dma_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_decryption_ccfie_ctr_aes128";
      tf_data.calltf    =  aes_bfm_decryption_ccfie_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //ECB DERIVATION DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_ecb_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_dma_ecb_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_dma_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_ccfie_ecb_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_ccfie_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CBC DERIVATION DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_cbc_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_dma_cbc_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_dma_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_ccfie_cbc_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_ccfie_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CTR DERIVATION DECRYPTION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_ctr_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_dma_ctr_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_dma_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_derivation_decryption_ccfie_ctr_aes128";
      tf_data.calltf    =  aes_bfm_derivation_decryption_ccfie_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);


      //KEY DERIVATION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_ecb_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_dma_ecb_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_dma_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);


      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_ccfie_ecb_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_ccfie_ecb_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CBC DERIVATION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_cbc_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_dma_cbc_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_dma_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_ccfie_cbc_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_ccfie_cbc_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //CTR DERIVATION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_ctr_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_dma_ctr_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_dma_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_key_generation_ccfie_ctr_aes128";
      tf_data.calltf    =  aes_bfm_key_generation_ccfie_ctr_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      //BFM SUFLE

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$bfm_sufle_aes128";
      tf_data.calltf    =  aes_bfm_sufle_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

 

      // RESET BFM
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$reset_aes128";
      tf_data.calltf    = aes_reset_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

	
      //ENV CONFIGURATION
      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$init";
      tf_data.calltf    = init_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$init_reset";
      tf_data.calltf    = init_reset_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

      tf_data.type      = vpiSysTask;
      tf_data.sysfunctype = 0;
      tf_data.tfname    = "$monitor_aes";
      tf_data.calltf    = mon_calltf;
      tf_data.compiletf = 0;
      tf_data.sizetf    = 0;
      tf_data.user_data = 0;
      vpi_register_systf(&tf_data);

}


void (*vlog_startup_routines[])() = {
    AES_GLADIC_register,
    0
};

