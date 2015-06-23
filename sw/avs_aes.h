/**
 *  \file avs_aes.h
 *  \brief header file for AES Avalon IP Core software driver
 *  offers interfaces to convinient access to the core
 *
 *  This file is part of the project	 avs_aes
 *  see: http://opencores.org/project,avs_aes
 *
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

#ifndef AVS_AES_H_
#define AVS_AES_H_

/**
 * \section Configuration
 * Configuration items for the Avalon Slave component 
 * change them or define them elsewhere
 */
#ifndef KEYWORDS
/** 
 * Keylength 256 Bit AES 
 */
#define KEYWORDS    	8
#endif  /*  KEYWORDS  */

#ifndef AES_BASEADDR
/**
 * base address of the Avalon Slave component in memory map 
 */
#define AES_BASEADDR    0x40000 
#endif /* AES_BASEADDR */

/**
 * \addtogroup control-register
 * Bits in Control Register 
 * \see{avs_aes_handle::control} 
 * \{
 */

/** Signal load of new key valid \see{avs_aes_handle::control} */
#define KEY_VALID 	(1 << 7)
/** Enable interrupt bit \see{avs_aes_handle::control} */
#define IRQ_ENA  	(1 << 6)
/** Start decryption bit \see{avs_aes_handle::control} */
#define DECRYPT  	(1 << 1)
/** start encryption bit \see{avs_aes_handle::control} */
#define ENCRYPT  	(1 << 0)

/** \} */

/**
 * \brief object storing addresses for this Avalon AES slave 
 * might be useful in case there are more attached, also for convinience
 */
typedef struct {
	/**
	 * \brief pointer to key field in memory mapping
	 */
	volatile unsigned int* key;
	/**
	 * \brief pointer to data field in memory mapping
	 * 		  used for both decryption and encryption
	 */
	volatile unsigned int* payload;
	/**
	 * \brief pointer to result field in memory mapping
	 */
	volatile unsigned int* result;
	/**
	 * \brief pointer to control word
	 */
	volatile unsigned int* control;

} avs_aes_handle;

/**
 * \section functions 
 **/

/**
 * \brief setup the context to be used later.
 * initializes the pointers to the correct memory locations
 * \param context : struct grouping address information 
 */
void avs_aes_init(avs_aes_handle* context);

/**
 * \brief Set a new key
 *  This call asserts the KEY_VALID flag and triggers the key-expansion in the core
 * \param context  struct grouping address information 
 * \param key user key to load
 */
void avs_aes_setKey(avs_aes_handle* context, unsigned int* key);

/**
 * \brief loads payload for processing to the core
 * basically memcopy...
 * \param context  struct grouping address information 
 * \param payload user data to be processed
 */
void avs_aes_setPayload(avs_aes_handle* context, unsigned int* payload);

/**
 * \brief set the KEY_VALID flag in the control word
 * used to signal the completion of writing the key ( \ref avs_aes_setKey )
 * \param context  struct grouping address information 
 */
void avs_aes_setKeyvalid(avs_aes_handle* context);

/**
 * \brief set the ENCRYPT flag in the control word
 * start encryption of (hopefully) previously loaded payload 
 * \param context  struct grouping address information 
 */
void avs_aes_encrypt(avs_aes_handle* context);

/**
 * \brief set the DECRYPT flag in the control word
 * start encryption of (hopefully) previously loaded payload 
 * \param context  struct grouping address information 
 */
void avs_aes_decrypt(avs_aes_handle* context);

/**
 * \brief checks the COMPLETED flag
 * can be used for ugly polling the slave if IRQs are not used
 * \param context  struct grouping address information 
 * \return 1 if still computing 0 if done.
 */
int avs_aes_isBusy(avs_aes_handle* context);

#endif /*AVS_AES_H_*/
