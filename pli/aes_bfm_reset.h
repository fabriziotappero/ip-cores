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
static int aes_reset_calltf(char*user_data)
{

	vpiHandle PRESETn = vpi_handle_by_name("AES_GLADIC_tb.PRESETn", NULL);

	std::random_device rd_counter;
	std::uniform_int_distribution<int> counter(1,50);

 	std::mt19937 rd;
        std::uniform_real_distribution<> time(0,50);

	
	v_reset.format=vpiIntVal;

	//printf("STATE_RESET : %i\n",STATE_RESET);
	//printf("MAX_RESET_TIMES : %i\n",MAX_RESET_TIMES);
	//printf("RESET_GENERATED : %i\n",RESET_GENERATED);
		
		switch(STATE_RESET)
		{

			case IDLE:

				if(RESET_GENERATED > MAX_RESET_TIMES)
				{
						STATE_RESET = IDLE;
				}else
				{

						STATE_RESET = ENTER_RESET;

						v_reset.value.integer = 0;
						t_reset.type = vpiScaledRealTime;
						t_reset.real = time(rd);
						v_wr.format=vpiIntVal;
						v_reset.value.integer = 0;
						vpi_put_value(PRESETn, &v_reset, &t_reset, vpiTransportDelay);

						counter_reset_wait = counter(rd_counter);

				}

						counter_reset_enter=0;
						counter_reset_wait=0;	


			break;

			case ENTER_RESET:
				
				if(counter_reset_enter >= counter_reset_wait)
				{
					v_reset.value.integer = 0;
					t_reset.type = vpiScaledRealTime;
					t_reset.real = time(rd);
					v_wr.format=vpiIntVal;
					v_reset.value.integer = 1;
					vpi_put_value(PRESETn,&v_reset, &t_reset, vpiTransportDelay);

					STATE_RESET = GET_OUT_RESET;					
				}

				counter_reset_enter++;
					
			break;

			case GET_OUT_RESET:

				counter_reset_wait=0;
				counter_reset_enter=0;

				STATE_RESET = WAIT_RESET;

				counter_reset_wait = counter(rd_counter);

			break;

			case WAIT_RESET:
				
				if(counter_reset_enter >= counter_reset_wait)
				{
					STATE_RESET = IDLE;
					counter_reset_wait=0;
					counter_reset_enter=0;
					RESET_GENERATED++;

				}
				counter_reset_enter++;


			break;

		}

	return 0;
}

