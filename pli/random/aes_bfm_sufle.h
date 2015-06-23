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

static int aes_bfm_sufle_calltf(char*user_data)
{

	vpiHandle PRESETn = vpi_handle_by_name("AES_GLADIC_tb.PRESETn", NULL);
	vpiHandle PWDATA  = vpi_handle_by_name("AES_GLADIC_tb.PWDATA", NULL);
	vpiHandle PENABLE = vpi_handle_by_name("AES_GLADIC_tb.PENABLE", NULL);
	vpiHandle PSEL    = vpi_handle_by_name("AES_GLADIC_tb.PSEL", NULL);
	vpiHandle PWRITE  = vpi_handle_by_name("AES_GLADIC_tb.PWRITE", NULL);
	vpiHandle PADDR   = vpi_handle_by_name("AES_GLADIC_tb.PADDR", NULL);
	vpiHandle PRDATA  = vpi_handle_by_name("AES_GLADIC_tb.PRDATA", NULL);
	vpiHandle PREADY  = vpi_handle_by_name("AES_GLADIC_tb.PREADY", NULL);
	vpiHandle PSLVERR = vpi_handle_by_name("AES_GLADIC_tb.PSLVERR", NULL);
	vpiHandle int_ccf = vpi_handle_by_name("AES_GLADIC_tb.int_ccf", NULL);
	vpiHandle int_err = vpi_handle_by_name("AES_GLADIC_tb.int_err", NULL);
	vpiHandle dma_req_wr = vpi_handle_by_name("AES_GLADIC_tb.dma_req_wr", NULL);
	vpiHandle dma_req_rd = vpi_handle_by_name("AES_GLADIC_tb.dma_req_rd", NULL);

	std::random_device rd;
	std::uniform_int_distribution<long int> data_in(0,4294967295);

	std::uniform_int_distribution<long int> register_config(0,232);

	v_ecb.format=vpiIntVal;

	vpi_get_value(PRESETn, &v_ecb);

	if(type_bfm == SUFLE_TEST && v_generate.value.integer == 1)
	{

		switch(STATE)
		{

			 case IDLE:

				if(PACKETS_GENERATED >= MAX_ITERATIONS)
				{

					STATE = IDLE;
					type_bfm = 0;	

				}else
				{
					STATE = WRITE; 	
				
					counter = 0;					

					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);
	
					v_ecb.value.integer = vector_address[0];
					vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					v_ecb.value.integer = 0;
					vpi_put_value(PWDATA, &v_ecb, NULL, vpiNoDelay);

					v_ecb.value.integer = 1;
					vpi_put_value(PWRITE, &v_ecb, NULL, vpiNoDelay);	

					v_ecb.value.integer = 1;
					vpi_put_value(PSEL, &v_ecb, NULL, vpiNoDelay);
				}

			 break;
			 case WRITE:

				v_ecb.value.integer = 1;
				vpi_put_value(PSEL, &v_ecb, NULL, vpiNoDelay);
	
				if(counter == 0)
				{
					counter_write++;
					counter++;

					v_ecb.value.integer = 1;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);


				}else if(counter == 1)
				{

					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);

					t_ecb.type = vpiScaledRealTime;
					t_ecb.real = 0;
					v_ecb.format=vpiIntVal;

				 	if(counter_write < 9)
					{
						v_ecb.value.integer = vector_address[counter_write];
						vpi_put_value(PADDR, &v_ecb, &t_ecb, vpiTransportDelay);
						v_ecb.value.integer = data_in(rd);
						vpi_put_value(PWDATA, &v_ecb, &t_ecb, vpiTransportDelay);

					}else if(counter_write == 9)
					{
						v_wr.value.integer = ADDR_AES_CR;
						vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);
						last_cr = vector_CR[register_config(rd)];
						v_wr.value.integer = last_cr;
						vpi_put_value(PWDATA, &v_wr, NULL, vpiNoDelay);

					}else if(counter_write > 9  &&  counter_write < 14)
					{

						v_ecb.value.integer = ADDR_AES_DINR;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);
						v_ecb.value.integer = data_in(rd);
						vpi_put_value(PWDATA, &v_ecb, &t_ecb, vpiTransportDelay);
					}

					counter=0;


				}


				if(counter_write == 14)
				{					
					counter_write = 0;
					STATE = WAIT_SR;
				}

			 break;
			 case WRITE_DINR:


				v_ecb.value.integer = ADDR_AES_DINR;
				vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);


				
				if(counter == 0)
				{



				 	counter++;
					counter_write++;

					v_ecb.value.integer = 1;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);


				}else if(counter == 1)
				{
					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);

					v_ecb.value.integer = ADDR_AES_DINR;
					vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					v_ecb.value.integer = data_in(rd);
					vpi_put_value(PWDATA, &v_ecb, &t_ecb, vpiTransportDelay);

					counter=0;
				}

				if(counter_write == 4)
				{					
					counter_write = 0;
					STATE = WAIT_SR;
				}



			 break;
		         case WAIT_SR:

				v_ecb.value.integer = ADDR_AES_SR;
				vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

				v_ecb.value.integer = 0;
				vpi_put_value(PWRITE, &v_ecb, NULL, vpiNoDelay);


				if(counter == 0)
				{

				 	counter++;

					v_ecb.value.integer = 1;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);


					v_ecb.value.integer = 0;
					vpi_get_value(PRDATA,&v_ecb);


					if(v_ecb.value.integer == 1)
					{
						STATE = READ_DOUTR;
					}


				}else if(counter == 1)
				{
					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);

					counter=0;
				}


			 break;
			 case READ_DOUTR:

				if(counter == 0)
				{

					v_ecb.value.integer = 1;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);

					counter_read++;
				 	counter++;



				}else if(counter == 1)
				{	
					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);


					if(counter_read < 4)
					{

						v_ecb.value.integer = ADDR_AES_DOUTR;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 4)
					{

						v_ecb.value.integer = ADDR_AES_KEYR3;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 5)
					{

						v_ecb.value.integer = ADDR_AES_KEYR2;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}



					if(counter_read == 6)
					{

						v_ecb.value.integer = ADDR_AES_KEYR1;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 7)
					{

						v_ecb.value.integer = ADDR_AES_KEYR0;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 8)
					{

						v_ecb.value.integer = ADDR_AES_IVR3;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 9)
					{

						v_ecb.value.integer = ADDR_AES_IVR2;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}



					if(counter_read == 10)
					{

						v_ecb.value.integer = ADDR_AES_IVR1;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					if(counter_read == 11)
					{

						v_ecb.value.integer = ADDR_AES_IVR0;
						vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

					}


					counter = 0;
				}

				if(counter_read == 12)
				{					
					STATE = RESET_SR;					
					counter_read = 0;
				}


			 break;
			 case RESET_SR:

				v_ecb.value.integer = 1;
				vpi_put_value(PWRITE, &v_ecb, NULL, vpiNoDelay);

				v_ecb.value.integer = 1;
				vpi_put_value(PSEL, &v_ecb, NULL, vpiNoDelay);

				v_ecb.value.integer = 0;
				vpi_put_value(PADDR, &v_ecb, NULL, vpiNoDelay);

				v_ecb.value.integer = 128 + last_cr;
				vpi_put_value(PWDATA, &v_ecb, NULL, vpiNoDelay);


				if(counter == 0)
				{

					counter_write++;
				 	counter++;

					v_ecb.value.integer = 1;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);

				}else if(counter == 1)
				{

					v_ecb.value.integer = 0;
					vpi_put_value(PENABLE, &v_ecb, NULL, vpiNoDelay);	
					counter=0;

				}

				if(counter_write == 1)
				{					
					
					counter_write = 0;
					counter=1;

					if( counter_sufle == MAX_ITERATION_PER_SUFLE)
					{
						PACKETS_GENERATED = PACKETS_GENERATED + 1;
						counter_sufle = 0 ;
						STATE =IDLE;
					}else
					{
						counter_sufle++;
						STATE =WRITE_DINR;
					}
				}

			 break;

		}


	}

	return 0;
}
