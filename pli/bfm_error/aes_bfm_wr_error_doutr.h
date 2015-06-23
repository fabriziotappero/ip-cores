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
static int aes_bfm_wr_error_doutr_calltf(char*user_data)
{

	vpiHandle PRESETn = vpi_handle_by_name("AES_GLADIC_tb.PRESETn", NULL);
	vpiHandle PWDATA = vpi_handle_by_name("AES_GLADIC_tb.PWDATA", NULL);
	vpiHandle PENABLE = vpi_handle_by_name("AES_GLADIC_tb.PENABLE", NULL);
	vpiHandle PSEL = vpi_handle_by_name("AES_GLADIC_tb.PSEL", NULL);
	vpiHandle PWRITE = vpi_handle_by_name("AES_GLADIC_tb.PWRITE", NULL);
	vpiHandle PADDR = vpi_handle_by_name("AES_GLADIC_tb.PADDR", NULL);
	vpiHandle PRDATA = vpi_handle_by_name("AES_GLADIC_tb.PRDATA", NULL);
	vpiHandle PREADY = vpi_handle_by_name("AES_GLADIC_tb.PREADY", NULL);
	vpiHandle PSLVERR = vpi_handle_by_name("AES_GLADIC_tb.PSLVERR", NULL);
	vpiHandle int_ccf = vpi_handle_by_name("AES_GLADIC_tb.int_ccf", NULL);
	vpiHandle int_err = vpi_handle_by_name("AES_GLADIC_tb.int_err", NULL);
	vpiHandle dma_req_wr = vpi_handle_by_name("AES_GLADIC_tb.dma_req_wr", NULL);
	vpiHandle dma_req_rd = vpi_handle_by_name("AES_GLADIC_tb.dma_req_rd", NULL);

	v_wr.format=vpiIntVal;


	std::random_device rd;
	std::uniform_int_distribution<long int> data_in(0,4294967295);


	v_wr.format=vpiIntVal;
	vpi_get_value(PRESETn, &v_wr);


	if(type_bfm == AES_WR_ERROR_DOUTR_ONLY && v_wr.value.integer == 1)
	{

		//printf("%i\n",STATE);
		
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

					v_wr.value.integer = 0;
					vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);

					v_wr.value.integer = 0;
					vpi_put_value(PWDATA, &v_wr, NULL, vpiNoDelay);

					v_wr.value.integer = 1;
					vpi_put_value(PWRITE, &v_wr, NULL, vpiNoDelay);	

					v_wr.value.integer = 1;
					vpi_put_value(PSEL, &v_wr, NULL, vpiNoDelay);
				}


	
			break;

			case WRITE:

				if(counter == 0)
				{

					counter_write++;
				 	counter++;

					v_wr.value.integer = 1;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);


				}else if(counter == 1)
				{	

					v_wr.value.integer = 0;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);

					t_wr.type = vpiScaledRealTime;
					t_wr.real = 0;
					v_wr.format=vpiIntVal;

					if(counter_write < 9)
					{

					v_wr.value.integer = vector_address[counter_write];
					vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);

						if(FIPS_ENABLE == FIPS)
						{

							if(vector_address[counter_write] == ADDR_AES_KEYR3 || vector_address[counter_write] == ADDR_AES_IVR3)
							{
								a = a | KEY_FIPS_NOT_DERIVATED[0]; 
								a = a << 8;
								a = a | KEY_FIPS_NOT_DERIVATED[1];
								a = a << 8;
								a = a | KEY_FIPS_NOT_DERIVATED[2]; 
								a = a << 8;
								a = a | KEY_FIPS_NOT_DERIVATED[3];
								v_wr.value.integer = a; 
							}


							if(vector_address[counter_write] == ADDR_AES_KEYR2 || vector_address[counter_write] == ADDR_AES_IVR2)
							{
								b = b | KEY_FIPS_NOT_DERIVATED[4];
								b = b << 8;
								b = b | KEY_FIPS_NOT_DERIVATED[5];
								b = b << 8;
								b = b | KEY_FIPS_NOT_DERIVATED[6]; 
								b = b << 8;
								b = b | KEY_FIPS_NOT_DERIVATED[7];
								v_wr.value.integer = b; 
							}

							if(vector_address[counter_write] == ADDR_AES_KEYR1 || vector_address[counter_write] == ADDR_AES_IVR1)
							{

								c = c | KEY_FIPS_NOT_DERIVATED[8];
								c = c << 8;
								c = c | KEY_FIPS_NOT_DERIVATED[9];
								c = c << 8;
								c = c | KEY_FIPS_NOT_DERIVATED[10]; 
								c = c << 8;
								c = c | KEY_FIPS_NOT_DERIVATED[11]; 
								v_wr.value.integer = c;

							}

							if(vector_address[counter_write] == ADDR_AES_KEYR0 || vector_address[counter_write] == ADDR_AES_IVR0)
							{
								d = d | KEY_FIPS_NOT_DERIVATED[12];
								d = d << 8;
								d = d | KEY_FIPS_NOT_DERIVATED[13];
								d = d << 8;
								d = d | KEY_FIPS_NOT_DERIVATED[14]; 
								d = d << 8;
								d = d | KEY_FIPS_NOT_DERIVATED[15];
								v_wr.value.integer = d;
							}



						}else if(FIPS_ENABLE == RANDOM_DATA)
						{
							v_wr.value.integer = data_in(rd);
						}					
						vpi_put_value(PWDATA, &v_wr, &t_wr, vpiTransportDelay);
					
						a = 0;
						b = 0;
						c = 0;
						d = 0;

						v_wr.value.integer = 1;
						vpi_put_value(PSEL, &v_wr, NULL, vpiNoDelay);


					}else if(counter_write == 9)
					{

						v_wr.value.integer = ADDR_AES_CR;
						vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);

						v_wr.value.integer = vector_CR[PACKETS_GENERATED];
						vpi_put_value(PWDATA, &v_wr, NULL, vpiNoDelay);	
		
					}if(counter_write > 9  &&  counter_write < 14) //WRITE DINR
					{

						v_wr.value.integer = ADDR_AES_DINR;
						vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);


						if(FIPS_ENABLE == FIPS)
						{

							if(counter_write == 10)
							{
								a = a | TEXT_FIPS_DERIVATED[0]; 
								a = a << 8;
								a = a | TEXT_FIPS_DERIVATED[1];
								a = a << 8;
								a = a | TEXT_FIPS_DERIVATED[2]; 
								a = a << 8;
								a = a | TEXT_FIPS_DERIVATED[3];
								v_wr.value.integer = a; 

							}else if(counter_write == 11)
							{
								b = b | TEXT_FIPS_DERIVATED[4];
								b = b << 8;
								b = b | TEXT_FIPS_DERIVATED[5];
								b = b << 8;
								b = b | TEXT_FIPS_DERIVATED[6]; 
								b = b << 8;
								b = b | TEXT_FIPS_DERIVATED[7];
								v_wr.value.integer = b; 

							}else if(counter_write == 12 )
							{

								c = c | TEXT_FIPS_DERIVATED[8];
								c = c << 8;
								c = c | TEXT_FIPS_DERIVATED[9];
								c = c << 8;
								c = c | TEXT_FIPS_DERIVATED[10]; 
								c = c << 8;
								c = c | TEXT_FIPS_DERIVATED[11]; 
								v_wr.value.integer = c;

							}else if(counter_write == 13 )
							{
								d = d | TEXT_FIPS_DERIVATED[12];
								d = d << 8;
								d = d | TEXT_FIPS_DERIVATED[13];
								d = d << 8;
								d = d | TEXT_FIPS_DERIVATED[14]; 
								d = d << 8;
								d = d | TEXT_FIPS_DERIVATED[15];
								v_wr.value.integer = d;

							}


						}else if(FIPS_ENABLE == RANDOM_DATA)
						{
							v_wr.value.integer = data_in(rd);
						}
	
						vpi_put_value(PWDATA, &v_wr, &t_wr, vpiTransportDelay);
					
						a = 0;
						b = 0;
						c = 0;
						d = 0;


					}

					counter=0;

				}//ELSE COUNTER



				if(counter_write == 14)
				{					
					STATE =WAIT;
					counter_write = 0;
					counter_read  = 0;

				}


			break;

			case WAIT:


				v_wr.value.integer = 0;
				vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);

				v_wr.value.integer = 0;
				vpi_put_value(PWRITE, &v_wr, NULL, vpiNoDelay);

				if(counter_wait == 3)
				{

					STATE = READ_DOUTR;
					counter_wait=0;	
					counter=1;

				}else
				{

					v_wr.value.integer = ADDR_AES_CR;
					vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);	

					counter_wait++;

				}
			break;

			case READ_DOUTR:


				if(counter == 0)
				{

				 	counter++;
					counter_read++;

					v_wr.value.integer = 1;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);


				}else if(counter == 1)
				{

					v_wr.value.integer = 0;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);


					v_wr.value.integer = ADDR_AES_DOUTR;
					vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);						

				 	counter=0;
				}



				if(counter_read == 4)
				{					
					STATE = READ_RESULTS;
					counter_write = 0;
					counter_read  = 0;
				 	counter=1;
				}


			break;

			case READ_RESULTS:



				if(counter == 0)
				{

					v_wr.value.integer = 1;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);					

					counter_read++;
				 	counter++;

				}else if(counter == 1)
				{				


					v_wr.value.integer = 0;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);

					if(counter_read == 0)
					{
						v_wr.value.integer = 1;
						vpi_put_value(PWRITE, &v_wr, NULL, vpiNoDelay);

						v_wr.value.integer = ADDR_AES_CR;
						vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);

						v_wr.value.integer = 0;
						vpi_put_value(PWDATA, &v_wr, NULL, vpiNoDelay);

						v_wr.value.integer = 1;
						vpi_put_value(PSEL, &v_wr, NULL, vpiNoDelay);
					}else
					{
						v_wr.value.integer = 0;
						vpi_put_value(PWRITE, &v_wr, NULL, vpiNoDelay);

						v_wr.value.integer = ADDR_AES_SR;
						vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);


					}

					counter=0;

				}

				if(counter_read == 14)
				{					
					STATE = RESET_SR;
					counter_write = 0;
					counter_read  = 0;
					PACKETS_GENERATED = PACKETS_GENERATED + 1;
					counter=1;

				}

			break;

			case RESET_SR:




				if(counter == 0)
				{

					counter_write++;
				 	counter++;

					v_wr.value.integer = 1;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);

				}else if(counter == 1)
				{

					v_wr.value.integer = 0;
					vpi_put_value(PENABLE, &v_wr, NULL, vpiNoDelay);	

					v_wr.value.integer = 1;
					vpi_put_value(PWRITE, &v_wr, NULL, vpiNoDelay);

					v_wr.value.integer = 1;
					vpi_put_value(PSEL, &v_wr, NULL, vpiNoDelay);

					v_wr.value.integer = 0;
					vpi_put_value(PADDR, &v_wr, NULL, vpiNoDelay);

					v_wr.value.integer = 384;
					vpi_put_value(PWDATA, &v_wr, NULL, vpiNoDelay);

					counter=0;

				}

				if(counter_write == 2)
				{					
					STATE =IDLE;
					counter_write = 0;
					counter_read  = 0;
				}

					

			break;
		}


		
	}


	return 0;
}
