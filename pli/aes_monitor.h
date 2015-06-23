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
static int mon_calltf(char*user_data)
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

	std::random_device rd;
	std::uniform_int_distribution<long int> data_in(0,4294967295);



	v_monitor.format=vpiIntVal;
	v_monitor_catch.format=vpiIntVal;


	vpi_get_value(PRESETn, &v_monitor);

	t_monitor.type = vpiScaledRealTime;
	t_monitor.real = 10;

	if(v_monitor.value.integer == 1)
	{
		vpi_get_value(PENABLE, &v_monitor);

		if(v_monitor.value.integer == 1)
		{

				vpi_get_value(PWRITE, &v_monitor);


				if(v_monitor.value.integer == 1)
				{
					vpi_get_value(PADDR, &v_monitor);


					if(v_monitor.value.integer == ADDR_AES_KEYR3)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						A=v_monitor_catch.value.integer;

						INPUT_KEYR[0]=A>>24;
						INPUT_KEYR[1]=A>>16;
						INPUT_KEYR[2]=A>>8;
						INPUT_KEYR[3]=A;	
					}

					if(v_monitor.value.integer == ADDR_AES_KEYR2)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						B=v_monitor_catch.value.integer;

						INPUT_KEYR[4]=B>>24;
						INPUT_KEYR[5]=B>>16;
						INPUT_KEYR[6]=B>>8;
						INPUT_KEYR[7]=B;
					}

					if(v_monitor.value.integer == ADDR_AES_KEYR1)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						C=v_monitor_catch.value.integer;

						INPUT_KEYR[8]=C>>24;
						INPUT_KEYR[9]=C>>16;
						INPUT_KEYR[10]=C>>8;
						INPUT_KEYR[11]=C;
					}

					if(v_monitor.value.integer == ADDR_AES_KEYR0)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						D=v_monitor_catch.value.integer;
						
						INPUT_KEYR[12]=D>>24;
						INPUT_KEYR[13]=D>>16;
						INPUT_KEYR[14]=D>>8;
						INPUT_KEYR[15]=D;

						//printf("%x%x%x%x\n",INPUT_KEYR[0],INPUT_KEYR[1],INPUT_KEYR[2],INPUT_KEYR[3]);

						//printf("%x%x%x%x\n",KEYR[0],KEYR[1],KEYR[2],KEYR[3]);					
					}


					if(v_monitor.value.integer == ADDR_AES_IVR3)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						E=v_monitor_catch.value.integer;

						INPUT_IVR[0]=E>>24;
						INPUT_IVR[1]=E>>16;
						INPUT_IVR[2]=E>>8;
						INPUT_IVR[3]=E;
					}

					if(v_monitor.value.integer == ADDR_AES_IVR2)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						F=v_monitor_catch.value.integer;

						INPUT_IVR[4]=F>>24;
						INPUT_IVR[5]=F>>16;
						INPUT_IVR[6]=F>>8;
						INPUT_IVR[7]=F;
					}

					if(v_monitor.value.integer == ADDR_AES_IVR1)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						G=v_monitor_catch.value.integer;

						INPUT_IVR[8]=G>>24;
						INPUT_IVR[9]=G>>16;
						INPUT_IVR[10]=G>>8;
						INPUT_IVR[11]=G;
					}

					if(v_monitor.value.integer == ADDR_AES_IVR0)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						H=v_monitor_catch.value.integer;

						INPUT_IVR[12]=H>>24;
						INPUT_IVR[13]=H>>16;
						INPUT_IVR[14]=H>>8;
						INPUT_IVR[15]=H;

					}

					if(v_monitor.value.integer == ADDR_AES_CR)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						I=v_monitor_catch.value.integer;
					}

					if(v_monitor.value.integer == ADDR_AES_DINR)
					{
						vpi_get_value(PWDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);

						if(counter_monitor == 0)	
						{

							J=v_monitor_catch.value.integer;
							INPUT_TEXT[0]=J>>24;
							INPUT_TEXT[1]=J>>16;
							INPUT_TEXT[2]=J>>8;
							INPUT_TEXT[3]=J;
							
							counter_monitor++;
					

						}else if(counter_monitor == 1)
						{

							L=v_monitor_catch.value.integer;
							INPUT_TEXT[4]=L>>24;
							INPUT_TEXT[5]=L>>16;
							INPUT_TEXT[6]=L>>8;
							INPUT_TEXT[7]=L;

							counter_monitor++;


						}else if(counter_monitor == 2)
						{

							M=v_monitor_catch.value.integer;
							INPUT_TEXT[8]=M>>24;
							INPUT_TEXT[9]=M>>16;
							INPUT_TEXT[10]=M>>8;
							INPUT_TEXT[11]=M;

							counter_monitor++;


						}else if(counter_monitor == 3)
						{

							N=v_monitor_catch.value.integer;
							INPUT_TEXT[12]=N>>24;
							INPUT_TEXT[13]=N>>16;
							INPUT_TEXT[14]=N>>8;
							INPUT_TEXT[15]=N;

							counter_monitor=0;
						}


			
					}

				}else if(v_monitor.value.integer == 0){

					vpi_get_value(PADDR, &v_monitor);

					if(v_monitor.value.integer == ADDR_AES_KEYR3)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						A=v_monitor_catch.value.integer;

						OUTPUT_KEYR[0]=A>>24;
						OUTPUT_KEYR[1]=A>>16;
						OUTPUT_KEYR[2]=A>>8;
						OUTPUT_KEYR[3]=A;

						counter_monitor++;

						//printf("%x%x%x%x\n",KEYR[0],KEYR[1],KEYR[2],KEYR[3]);	
					}

					if(v_monitor.value.integer == ADDR_AES_KEYR2)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						B=v_monitor_catch.value.integer;

						OUTPUT_KEYR[4]=B>>24;
						OUTPUT_KEYR[5]=B>>16;
						OUTPUT_KEYR[6]=B>>8;
						OUTPUT_KEYR[7]=B;

						counter_monitor++;

					}

					if(v_monitor.value.integer == ADDR_AES_KEYR1)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						C=v_monitor_catch.value.integer;

						OUTPUT_KEYR[8]=C>>24;
						OUTPUT_KEYR[9]=C>>16;
						OUTPUT_KEYR[10]=C>>8;
						OUTPUT_KEYR[11]=C;
							
						counter_monitor++;


					}

					if(v_monitor.value.integer == ADDR_AES_KEYR0)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						D=v_monitor_catch.value.integer;
						
						OUTPUT_KEYR[12]=D>>24;
						OUTPUT_KEYR[13]=D>>16;
						OUTPUT_KEYR[14]=D>>8;
						OUTPUT_KEYR[15]=D;

						counter_monitor++;

							//printf("%x%x%x%x\n",KEYR[0],KEYR[1],KEYR[2],KEYR[3]);					
					}

					if(v_monitor.value.integer == ADDR_AES_IVR3)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						E=v_monitor_catch.value.integer;

						OUTPUT_IVR[0]=E>>24;
						OUTPUT_IVR[1]=E>>16;
						OUTPUT_IVR[2]=E>>8;
						OUTPUT_IVR[3]=E;
								
						counter_monitor++;

					}

					if(v_monitor.value.integer == ADDR_AES_IVR2)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						F=v_monitor_catch.value.integer;

						OUTPUT_IVR[4]=F>>24;
						OUTPUT_IVR[5]=F>>16;
						OUTPUT_IVR[6]=F>>8;
						OUTPUT_IVR[7]=F;

						counter_monitor++;


					}

					if(v_monitor.value.integer == ADDR_AES_IVR1)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						G=v_monitor_catch.value.integer;

						OUTPUT_IVR[8]=G>>24;
						OUTPUT_IVR[9]=G>>16;
						OUTPUT_IVR[10]=G>>8;
						OUTPUT_IVR[11]=G;

						counter_monitor++;

					}

					if(v_monitor.value.integer == ADDR_AES_IVR0)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						H=v_monitor_catch.value.integer;

						OUTPUT_IVR[12]=H>>24;
						OUTPUT_IVR[13]=H>>16;
						OUTPUT_IVR[14]=H>>8;
						OUTPUT_IVR[15]=H;

						counter_monitor++;
					}


					if(v_monitor.value.integer == ADDR_AES_SR)
					{
						vpi_get_value(PRDATA, &v_monitor_catch);
						//printf("%X\n",v_monitor_catch.value.integer);
						O =v_monitor_catch.value.integer;

						if(type_bfm == AES_WR_ERROR_DOUTR_ONLY || type_bfm == AES_WR_ERROR_DINR_ONLY)
						{
							counter_monitor++;
						}
					}

					if(v_monitor.value.integer == ADDR_AES_DOUTR)
					{
					
						vpi_get_value(PRDATA, &v_monitor_catch);
						//vpi_put_value(PRDATA, &v_monitor_catch, &t_monitor, vpiTransportDelay);
						//printf("%X\n",v_monitor_catch.value.integer);

						if(counter_monitor == 0)	
						{

							J=v_monitor_catch.value.integer;
							OUTPUT_TEXT[0]=J>>24;
							OUTPUT_TEXT[1]=J>>16;
							OUTPUT_TEXT[2]=J>>8;
							OUTPUT_TEXT[3]=J;
						
							counter_monitor++;

					
						}else if(counter_monitor == 1)
						{
							L=v_monitor_catch.value.integer;
							OUTPUT_TEXT[4]=L>>24;
							OUTPUT_TEXT[5]=L>>16;
							OUTPUT_TEXT[6]=L>>8;
							OUTPUT_TEXT[7]=L;

							counter_monitor++;



						}else if(counter_monitor == 2)
						{

							M=v_monitor_catch.value.integer;
							OUTPUT_TEXT[8]=M>>24;
							OUTPUT_TEXT[9]=M>>16;
							OUTPUT_TEXT[10]=M>>8;
							OUTPUT_TEXT[11]=M;

							counter_monitor++;


						}else if(counter_monitor == 3)
						{

							N=v_monitor_catch.value.integer;
							OUTPUT_TEXT[12]=N>>24;
							OUTPUT_TEXT[13]=N>>16;
							OUTPUT_TEXT[14]=N>>8;
							OUTPUT_TEXT[15]=N;

							counter_monitor++;
						}
			

					}

					// vpi_mcd_printf(1,"%d\n",counter_monitor);


					if(counter_monitor == 12  && FIPS_ENABLE == FIPS)
					{
						printf("Checking results\n\n");
						counter_monitor = 0;
						
						if(type_bfm == AES_WR_ERROR_DOUTR_ONLY)
						{
							if(O == 2 || O == 6)
							{
								printf("AES_WR_ERROR_DOUTR_ONLY PASS\n");
							}else
							{
								printf("AES_WR_ERROR_DOUTR_ONLY FAILs\n");
								printf("%i\n",O);
							}


						}else if(type_bfm == AES_WR_ERROR_DINR_ONLY)
						{

							if(O == 4)
							{
								printf("AES_WR_ERROR_DINR_ONLY PASS\n");
							}else
							{
								printf("AES_WR_ERROR_DINR_ONLY FAILs\n");
								printf("%i\n",O);
							}


						}else if(I == 4094)// WR
						{
							if(memcmp(TEXT_NULL,OUTPUT_TEXT,16) == 0)
							{
								printf("WRITE READ: TEXT CR DISABLED PASSED.\n");
							}else
							{
								printf("WRITE READ: TEXT CR DISABLED FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,INPUT_KEYR,16) == 0)
							{
									printf("WRITE READ: KEYR WHEN CR DISABLED PASSED.\n");
							}else 
							{
								printf("WRITE READ: KEYR WHEN CR DISABLED FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,INPUT_IVR,16) == 0)
							{
								printf("WRITE READ: IVR WHEN CR DISABLED PASSED.\n");
							}else 
							{
								printf("WRITE READ: IVR WHEN CR DISABLED FAIL.\n");
							}

						}else if(I == 1)//ECB ENCRYPTION DATATYPE 00
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");
							}else
							{
								printf("ECB ENCRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 3)//ECB ENCRYPTION DATATYPE 01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");
							}else
							{
								printf("ECB ENCRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 5)//ECB ENCRYPTION DATATYPE 02
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");
							}else
							{
								printf("ECB ENCRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 7)//ECB ENCRYPTION DATATYPE 03
						{ 

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");
							}else
							{
								printf("ECB ENCRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6145 ) //ECB ENCRYPTION DMA DATATYPE 00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE00 : TEXT CYPHER  WHEN CR ENABLE PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION DMA DATATYPE00 : TEXT CYPHER WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6147 ) //ECB ENCRYPTION DMA DATATYPE 01
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE01 : TEXT CYPHER  WHEN CR ENABLE PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION DMA DATATYPE01 : TEXT CYPHER WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if (I == 6149 ) //ECB ENCRYPTION DMA DATATYPE 02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE02 : TEXT CYPHER  WHEN CR ENABLE PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION DMA DATATYPE02 : TEXT CYPHER WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if (I == 6151 ) //ECB ENCRYPTION DMA DATATYPE 03
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE03 : TEXT CYPHER  WHEN CR ENABLE PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION DMA DATATYPE03 : TEXT CYPHER WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if (I == 513) //ECB ENCRYPTION CCFIE DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 515)//ECB ENCRYPTION CCFIE DATA TYPE01
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 517)//ECB ENCRYPTION CCFIE DATA TYPE02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 519)//ECB ENCRYPTION CCFIE DATA TYPE03
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 25)// ECB DERIVATION DECRYPTION DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 27)// ECB DERIVATION DECRYPTION DATA TYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 29)// ECB DERIVATION DECRYPTION DATA TYPE02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 31)// ECB DERIVATION DECRYPTION DATA TYPE03
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6169)// ECB DERIVATION DECRYPTION DMA DATA TYPE00
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6171)// ECB DERIVATION DECRYPTION DMA DATATYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6173)// ECB DERIVATION DECRYPTION DMA DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6175)// ECB DERIVATION DECRYPTION DMA DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 537)// ECB DERIVATION DECRYPTION CCFIE DATA TYPE00 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 539)// ECB DERIVATION DECRYPTION CCFIE DATA TYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 541)// ECB DERIVATION DECRYPTION CCFIE DATA TYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 543)// ECB DERIVATION DECRYPTION CCFIE DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DERIVATION DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 17)//ECB DECRYPTION DATA TYPE00 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 19)//ECB DECRYPTION DATA TYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 21)//ECB DECRYPTION DATA TYPE02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 23)//ECB DECRYPTION DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6161)//ECB DECRYPTION DMA DATA TYPE00 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6163)//ECB DECRYPTION DMA DATA TYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6165)//ECB DECRYPTION DMA DATA TYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6167)//ECB DECRYPTION DMA DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 529)//ECB DECRYPTION CCFIE DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 531)//ECB DECRYPTION CCFIE DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 533)//ECB DECRYPTION CCFIE DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 535)//ECB DECRYPTION CCFIE DATATYPE03
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						
						}else if(I == 9) //ECB KEY GENARATION
						{


							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("ECB KEY GEN : TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB KEY GEN : TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,KEY_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,KEY_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6153)// ECB KEY GENARATION DMA
						{

							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("ECB KEY GEN DMA: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB KEY GEN DMA: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN DMA: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN DMA: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,KEY_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN DMA: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN DMA: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 521)// ECB KEY GENARATION CCFIE
						{

							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("ECB KEY GEN CCFIE: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("ECB KEY GEN CCFIE: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN CCFIE: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN CCFIE: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,KEY_FIPS_NOT_DERIVATED,16) == 0)
							{
								printf("ECB KEY GEN CCFIE: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("ECB KEY GEN CCFIE: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 33) // ENCRYPTION CBC DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 35) // ENCRYPTION CBC DATA TYPE01
						{
							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 37) // ENCRYPTION CBC DATA TYPE02 
						{
							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 39) // ENCRYPTION CBC DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6177)//CBC ENCRYPTION DMA DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6179)//CBC ENCRYPTION DMA DATA TYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6181)//CBC ENCRYPTION DMA DATA TYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6183)//CBC ENCRYPTION DMA DATA TYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 545)//CBC ENCRYPTION CCFIE DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 547)//CBC ENCRYPTION CCFIE DATA TYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 549)//CBC ENCRYPTION CCFIE DATA TYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 551)//CBC ENCRYPTION CCFIE DATA TYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CBC_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 49)// CBC DECRYPTION DATA TYPE00
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 51)// CBC DECRYPTION DATA TYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 53)// CBC DECRYPTION DATA TYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 55)// CBC DECRYPTION DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6193)//CBC DECRYPTION DMA  DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6195)//CBC DECRYPTION DMA  DATA TYPE01
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6197)//CBC DECRYPTION DMA  DATA TYPE02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6199)//CBC DECRYPTION DMA  DATA TYPE03 
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 561)// CBC DECRYPTION CCFIE DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE  DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");

							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 563)// CBC DECRYPTION CCFIE DATATYPE01 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");

							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE01 : KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE01 : KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION  CCFIE DATATYPE01 : IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION  CCFIE DATATYPE01 : IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 565)// CBC DECRYPTION CCFIE DATATYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");

							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02 : KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02 : KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02 : IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE02 : IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 567)// CBC DECRYPTION CCFIE DATATYPE03 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 41) //CBC KEY GENERATION
						{


							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CBC KEY GEN  : TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC KEY GEN  : TEXT CYPHER FAIL.\n");

							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CBC_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN  : KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN  : KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,IV_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN  : IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN  : IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6185) //CBC KEY GENERATION DMA
						{ 

							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CBC KEY GEN DMA : TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC KEY GEN DMA : TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CBC_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN DMA : KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN DMA : KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,IV_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN DMA : IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN DMA : IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 553 ) //CBC KEY GENERATION CCFIE 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CBC KEY GEN CCFIE : TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC KEY GEN CCFIE : TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CBC_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN CCFIE : KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN CCFIE : KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,IV_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC KEY GEN CCFIE : IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC KEY GEN CCFIE : IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 57)// CBC DERIVATION DECRYPTION DATA TYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 59)// CBC DERIVATION DECRYPTION DATA TYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}




						}else if(I == 61)// CBC DERIVATION DECRYPTION DATA TYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 63)// CBC DERIVATION DECRYPTION DATA TYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

				
						}else if(I == 6201) // CBC DERIVATION DECRYPTION DMA DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6203) // CBC DERIVATION DECRYPTION DMA DATATYPE01
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6205) // CBC DERIVATION DECRYPTION DMA DATATYPE02
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6207) // CBC DERIVATION DECRYPTION DMA DATATYPE03 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 569) // CBC DERIVATION DECRYPTION CCFIE DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 571) // CBC DERIVATION DECRYPTION CCFIE DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 573) // CBC DERIVATION DECRYPTION CCFIE DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 575) // CBC DERIVATION DECRYPTION CCFIE DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CBC_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CBC DERIVATION DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 65)// CTR ENCFRYPTION DATATYPE00
						{


							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 67)// CTR ENCFRYPTION DATATYPE01 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 69)// CTR ENCFRYPTION DATATYPE02 
						{


							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 71)// CTR ENCFRYPTION DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6209)// CTR ENCRYPTION DMA DATATYPE00
						{


							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6211)// CTR ENCRYPTION DMA DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6213)// CTR ENCRYPTION DMA DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6215)// CTR ENCRYPTION DMA DATATYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 577)// CTR ENCRYPTION CCFIE DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 579)// CTR ENCRYPTION CCFIE DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T01_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 581)// CTR ENCRYPTION CCFIE DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T02_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 583)// CTR ENCRYPTION CCFIE DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_CTR_FIPS_DATATYPE_T03_DERIVATED,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR ENCRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 81) //CTR DECRYPTION DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 83) //CTR DECRYPTION DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 85) //CTR DECRYPTION DATATYPE02 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 87) //CTR DECRYPTION DATATYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 6225) //CTR DECRYPTION DMA DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6227) //CTR DECRYPTION DMA DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6229) //CTR DECRYPTION DMA DATATYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6231) //CTR DECRYPTION DMA DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 593) //CTR DECRYPTION CCFIE DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 595) //CTR DECRYPTION CCFIE DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: TEXT CYPHER FAIL.\n");
							}



							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 597) //CTR DECRYPTION CCFIE DATATYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 599) //CTR DECRYPTION CCFIE DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: TEXT CYPHER FAIL.\n");
							}


							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DECRYPTION CCFIE DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 89) //CTR DERIVATION DECRYPTION DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 91) //CTR DERIVATION DECRYPTION DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 93) //CTR DERIVATION DECRYPTION DATATYPE02 
						{
							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 95) //CTR DERIVATION DECRYPTION DATATYPE03 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6233) //CTR DERIVATION DECRYPTION DMA DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 6235) //CTR DERIVATION DECRYPTION DMA DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6237) //CTR DERIVATION DECRYPTION DMA DATATYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6239) //CTR DERIVATION DECRYPTION DMA DATATYPE03  
						{


							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}



						}else if(I == 601) //CTR DERIVATION DECRYPTION CCFIE DATATYPE00
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE00: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 603) //CTR DERIVATION DECRYPTION CCFIE DATATYPE01 
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE01: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 605) //CTR DERIVATION DECRYPTION CCFIE DATATYPE02  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE02: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 607) //CTR DERIVATION DECRYPTION CCFIE DATATYPE03  
						{

							if(memcmp(OUTPUT_TEXT,TEXT_FIPS_CTR_NOT_DATATYPE_DERIVATED,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: KEYR WHEN CR ENABLE FAIL.\n");
							}

							if(memcmp(OUTPUT_IVR,TEXT_NULL,16) == 0)
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR DERIVATION DECRYPTION DMA DATATYPE03: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 73)// CTR KEY GENERATION
						{

							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CTR KEY GEN: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR KEY GEN: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CTR_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,IV_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN: IVR WHEN CR ENABLE FAIL.\n");
							}


						}else if(I == 6217) // CTR KEY GENERATION DMA
						{


							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CTR KEY GEN DMA: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR KEY GEN DMA: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CTR_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN DMA: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN DMA: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,IV_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN DMA: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN DMA: IVR WHEN CR ENABLE FAIL.\n");
							}

						}else if(I == 585) // CTR KEY GENERATION CCFIE
						{

							if(memcmp(OUTPUT_TEXT,TEXT_NULL,16) == 0)
							{
								printf("CTR KEY GEN CCFIE: TEXT CYPHER PASSED.\n");

							}else
							{
								printf("CTR KEY GEN CCFIE: TEXT CYPHER FAIL.\n");
							}

							if(memcmp(OUTPUT_KEYR,KEY_FIPS_CTR_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN CCFIE: KEYR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN CCFIE: KEYR WHEN CR ENABLE FAIL.\n");
							}


							if(memcmp(OUTPUT_IVR,IV_FIPS_CTR_NOT_DERIVATED,16) == 0)
							{
								printf("CTR KEY GEN CCFIE: IVR WHEN CR ENABLE PASSED.\n");
							}else 
							{
								printf("CTR KEY GEN CCFIE: IVR WHEN CR ENABLE FAIL.\n");
							}

						}
							




					}else if(type_bfm == SUFLE_TEST && counter_monitor == 12) 
					{


						//printf("CONFIGURATION REGISTER %d \n",I); 
						//printf("KEY         %X %X %X %X \n",A,B,C,D);
						//printf("IVR         %X %X %X %X \n",E,F,G,H);
						//printf("TEXT CYPHER %X %X %X %X \n",J,L,M,N);


					}

				}




		}


			
					

	}

	return 0;
}
