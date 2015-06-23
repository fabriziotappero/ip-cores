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

static int aes_bfm_generate_calltf(char*user_data)
{

	vpiHandle PRESETn = vpi_handle_by_name("AES_GLADIC_tb.PRESETn", NULL);
	vpiHandle i = vpi_handle_by_name("AES_GLADIC_tb.i", NULL);

	v_generate.format=vpiIntVal;
	vpi_get_value(PRESETn, &v_generate);

	if(v_generate.value.integer == 1)
	{

			FIPS_ENABLE =RANDOM_DATA;
			DATATYPE = TYPE_00;

//			type_bfm = AES_WR_ONLY;
//			type_bfm = AES_WR_ERROR_DINR_ONLY;
//			type_bfm = AES_WR_ERROR_DOUTR_ONLY;

//			type_bfm = ECB_ENCRYPTION;
//			type_bfm = ECB_DECRYPTION;
//			type_bfm = ECB_KEY_GEN;
//			type_bfm = ECB_DERIVATION_DECRYPTION;

//			type_bfm = ECB_ENCRYPTION_DMA;
//			type_bfm = ECB_DECRYPTION_DMA;
//			type_bfm = ECB_KEY_GEN_DMA;
//			type_bfm = ECB_DERIVATION_DECRYPTION_DMA;

//			type_bfm = ECB_ENCRYPTION_CCFIE;
//			type_bfm = ECB_DECRYPTION_CCFIE;
//			type_bfm = ECB_KEY_GEN_CCFIE;
//			type_bfm = ECB_DERIVATION_DECRYPTION_CCFIE;


//			type_bfm = CBC_ENCRYPTION;
//			type_bfm = CBC_DECRYPTION;
//			type_bfm = CBC_DERIVATION_DECRYPTION;
//			type_bfm = CBC_KEY_GEN;

//			type_bfm = CBC_ENCRYPTION_DMA;
//			type_bfm = CBC_DECRYPTION_DMA;
//			type_bfm = CBC_DERIVATION_DECRYPTION_DMA;
//			type_bfm = CBC_KEY_GEN_DMA;

//			type_bfm = CBC_ENCRYPTION_CCFIE;
//			type_bfm = CBC_DECRYPTION_CCFIE;
//			type_bfm = CBC_DERIVATION_DECRYPTION_CCFIE;
//			type_bfm = CBC_KEY_GEN_CCFIE;

//			type_bfm = CTR_ENCRYPTION;
//			type_bfm = CTR_DECRYPTION;
//			type_bfm = CTR_KEY_GEN;
//			type_bfm = CTR_DERIVATION_DECRYPTION;

//			type_bfm = CTR_ENCRYPTION_DMA;
//			type_bfm = CTR_DECRYPTION_DMA;
//			type_bfm = CTR_KEY_GEN_DMA;
//			type_bfm = CTR_DERIVATION_DECRYPTION_DMA;

//			type_bfm = CTR_ENCRYPTION_CCFIE;
//			type_bfm = CTR_DECRYPTION_CCFIE;
//			type_bfm = CTR_KEY_GEN_CCFIE;
//			type_bfm = CTR_DERIVATION_DECRYPTION_CCFIE;

			type_bfm = SUFLE_TEST;


			if(PACKETS_GENERATED == MAX_ITERATIONS)
			{
				v_generate.value.integer = 1;
				vpi_put_value(i, &v_generate, NULL, vpiNoDelay);
			}
	}

	return 0;
}
