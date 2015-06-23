/**
*  \file AEStester.c
*  \brief test program and example of how to use the software
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
#include <stdio.h>
#include <string.h>
#include <avs_aes.h>

int main() {
	avs_aes_handle context;
	int i = 0;

	unsigned int result[4];
	unsigned int Userkey[] = {
			0x11111111, 0x22222222,
			0x33333333, 0x44444444,
			0x55555555, 0x66666666,
			0x77777777, 0x88888888
	};
	unsigned int Payload[] = {
			0xAA555555, 0xBB666666,
			0xCC777777, 0xDD888888
	};

// START AES-Operations
	printf("AES-Test\n");
	avs_aes_init(&context);
	avs_aes_setKey(&context, &Userkey);
	avs_aes_setPayload(&context, &Payload);
	avs_aes_encrypt(&context);

	while (avs_aes_isBusy(&context)) {
		printf("not ready\n");
	}
	printf("receiving 729cd44f 32a48d85 b8188185 c579ae49\n");
	memcpy(result, context.result, sizeof(result));
	for (i = 0; i < 4; i++) {
		printf("received 0x%X \n", result[i]);
	}

// Decrypt same payload -  
	avs_aes_decrypt(&context);
	while (avs_aes_isBusy(&context)) {
		printf("not ready\n");
	}
	printf("receiving 9c7076af ac2e5716 6681d3ac 014f64c0 \n");
	memcpy(result, context.result, sizeof(result));
	for (i = 0; i < 4; i++) {
		printf("received 0x%X \n", result[i]);
	}
// Change payload ...
	Payload[3] = 0x11111111;
	Payload[2] = 0xAAAAAAAA;
	Payload[1] = 0xCCCCCCCC;
	Payload[0] = 0x00000000;
	//new encryption
	avs_aes_setPayload(&context, &Payload);
	avs_aes_encrypt(&context);
	while (avs_aes_isBusy(&context)) {
		printf("not ready\n");
	}
	memcpy(result, context.result, sizeof(result));
	for (i = 0; i < 4; i++) {
		printf("received 0x%X \n", result[i]);
	}
	//new decryption
	avs_aes_decrypt(&context);
	while (avs_aes_isBusy(&context)) {
		printf("not ready\n");
	}
	memcpy(result, context.result, 4 * sizeof(unsigned int));
	for (i = 0; i < 4; i++) {
		printf("received 0x%X \n", result[i]);
	}
	printf("Done \n");

	return 0;

}
