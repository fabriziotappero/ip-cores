/**
*  \file avs_aes.c
*  \brief AES Avalon IP Core software driver 
*
*  This file is part of the project	 avs_aes
*  see: http://opencores.org/project,avs_aes
* 
* \section AUTHORS
* 	   Thomas Ruschival -- ruschi@opencores.org (www.ruschival.de)
* 
* \section LICENSE
*  Copyright (c) 2009, Authors and opencores.org
*  All rights reserved.
* 
*  Redistribution and use in source and binary forms, with or without modification,
*  are permitted provided that the following conditions are met:
* 	  * Redistributions of source code must retain the above copyright notice,
* 	  this list of conditions and the following disclaimer.
* 	  * Redistributions in binary form must reproduce the above copyright notice,
* 	  this list of conditions and the following disclaimer in the documentation
* 	  and/or other materials provided with the distribution.
* 	  * Neither the name of the organization nor the names of its contributors
* 	  may be used to endorse or promote products derived from this software without
* 	  specific prior written permission.
*  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
*  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
*  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
*  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
*  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY,
*  OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
*  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
*  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
*  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
*  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF
*  THE POSSIBILITY OF SUCH DAMAGE	
*/


#include <avs_aes.h>
#include <string.h>
#include <stdint.h>

/** memory offset for key  DON'T CHANGE!  */
const uint32_t KEY_ADDR = AES_BASEADDR;
/** memory offset of payload */
const uint32_t DATA_ADDR = AES_BASEADDR+0x08;
/** memory offset of result   */
const uint32_t RESULT_ADDR = AES_BASEADDR+0x10;
/** memory offset for control word */
const uint32_t AESCTRLWD = AES_BASEADDR+0x18;


void avs_aes_init(avs_aes_handle* context){
	context->key	= (unsigned int*) KEY_ADDR;
	context->payload= (unsigned int*) DATA_ADDR;
	context->result	= (unsigned int*) RESULT_ADDR;
	context->control  	= (unsigned int*) AESCTRLWD;
	*(context->control) = 0x00000000;
}


void avs_aes_setKey(avs_aes_handle* context, unsigned int* key){
	int i=0;
	unsigned int* target_ptr = (unsigned int* )context->key;
	/* Invalidate old key; */
	*(context->control) &= (~KEY_VALID);
	asm __volatile("sync" :::);
	for(i=0; i<KEYWORDS; i++){
		*(target_ptr++) = *(key++);
	}
	asm __volatile("sync" :::);
	/* validate key */
	*(context->control) |= KEY_VALID;
}


void avs_aes_setPayload(avs_aes_handle* context, unsigned int* payload){
	int i=0;
	unsigned int* target_ptr = (unsigned int* )context->payload;
	for(i=0; i<4; i++){
		*(target_ptr++) = *(payload++);
	}	
}


void avs_aes_setKeyvalid(avs_aes_handle* context){
	*(context->control) |= KEY_VALID;
	asm __volatile("sync" :::);
}


void avs_aes_encrypt(avs_aes_handle* context){
	*(context->control) |= ENCRYPT;
	asm __volatile("sync" :::);
}


void avs_aes_decrypt(avs_aes_handle* context) {
	*(context->control) |= DECRYPT;
	asm __volatile("sync" :::);
}


int avs_aes_isBusy(avs_aes_handle* context) {
	unsigned int mycontrol = *(context->control);	
	return mycontrol & (DECRYPT | ENCRYPT);
}
