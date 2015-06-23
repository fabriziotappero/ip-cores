// Filename          : can_send_extended.c
//-- Description     : Sends four can frames with different ID's in extended frame format
//-- Author          : Harald Obereder
//-- Created On      : Wed Okt 06 10.07
//--
//-- CVS entries:
//--   $Author: hobe $
//--   $Date: 2004/10/12 12:47:19 $
//--   $Revision: 1.2 $
//--   $State: Exp $ 

// addressdefinition for basic can registers
// tb...transmit buffer
// rb...receive buffer
#define basic
#define extended

#ifdef basic
#define control_register *((unsigned char *)(0xfffc0000))
#define command_register *((unsigned char *)(0xfffc0001))
#define status_register *((unsigned char *)(0xfffc0002))
#define interrupt_register *((unsigned char *)(0xfffc0003))
#define acceptance_code_register *((unsigned char *)(0xfffc0004))
#define acceptance_mask_register *((unsigned char *)(0xfffc0005))
#define bus_timing_0_register *((unsigned char *)(0xfffc0006))
#define bus_timing_1_register *((unsigned char *)(0xfffc0007))
#define output_control_register *((unsigned char *)(0xfffc0008))
#define test_register *((unsigned char *)(0xfffc0009))
#define tb_identifier_byte_0 *((unsigned char *)(0xfffc000A))
#define tb_identifier_byte_1 *((unsigned char *)(0xfffc000B))
#define tb_data_byte_1 *((unsigned char *)(0xfffc000C))
#define tb_data_byte_2 *((unsigned char *)(0xfffc000D))
#define tb_data_byte_3 *((unsigned char *)(0xfffc000E))
#define tb_data_byte_4 *((unsigned char *)(0xfffc000F))
#define tb_data_byte_5 *((unsigned char *)(0xfffc0010))
#define tb_data_byte_6 *((unsigned char *)(0xfffc0011))
#define tb_data_byte_7 *((unsigned char *)(0xfffc0012))
#define tb_data_byte_8 *((unsigned char *)(0xfffc0013))
#define rb_identifier_byte_0 *((unsigned char *)(0xfffc0014))
#define rb_identifier_byte_1 *((unsigned char *)(0xfffc0015))
#define rb_data_byte_1 *((unsigned char *)(0xfffc0016))
#define rb_data_byte_2 *((unsigned char *)(0xfffc0017))
#define rb_data_byte_3 *((unsigned char *)(0xfffc0018))
#define rb_data_byte_4 *((unsigned char *)(0xfffc0019))
#define rb_data_byte_5 *((unsigned char *)(0xfffc001A))
#define rb_data_byte_6 *((unsigned char *)(0xfffc001B))
#define rb_data_byte_7 *((unsigned char *)(0xfffc001C))
#define rb_data_byte_8 *((unsigned char *)(0xfffc001D))
#define Extra_register *((unsigned char *)(0xfffc001E))
#define clock_divider_register *((unsigned char *)(0xfffc001F))

#endif

#ifdef extended
#define control_register *((unsigned char *)(0xfffc0000))
#define command_register *((unsigned char *)(0xfffc0001))
#define status_register *((unsigned char *)(0xfffc0002))
#define interrupt_register *((unsigned char *)(0xfffc0003))
#define interrupt_enable_register *((unsigned char *)(0xfffc0004))
#define reserved_register *((unsigned char *)(0xfffc0005))
#define bus_timing_0_register *((unsigned char *)(0xfffc0006))
#define bus_timing_1_register *((unsigned char *)(0xfffc0007))
#define output_control_register *((unsigned char *)(0xfffc0008))
#define test_register *((unsigned char *)(0xfffc0009))
#define reserved_1_register *((unsigned char *)(0xfffc000A))
#define arbitration_lost_capture *((unsigned char *)(0xfffc000B))
#define error_code_capture *((unsigned char *)(0xfffc000C))
#define error_warning_limit *((unsigned char *)(0xfffc000D))
#define rx_error_counter *((unsigned char *)(0xfffc000E))
#define tx_error_counter *((unsigned char *)(0xfffc000F))

#define acceptance_code_0 *((unsigned char *)(0xfffc0010))
#define acceptance_code_1 *((unsigned char *)(0xfffc0011))
#define acceptance_code_2 *((unsigned char *)(0xfffc0012))
#define acceptance_code_3 *((unsigned char *)(0xfffc0013))
#define acceptance_mask_0 *((unsigned char *)(0xfffc0014))
#define acceptance_mask_1 *((unsigned char *)(0xfffc0015))
#define acceptance_mask_2 *((unsigned char *)(0xfffc0016))
#define acceptance_mask_3 *((unsigned char *)(0xfffc0017))

#define rx_frame_information_sff *((unsigned char *)(0xfffc0010))
#define rx_identifier_1_sff *((unsigned char *)(0xfffc0011))
#define rx_identifier_2_sff *((unsigned char *)(0xfffc0012))
#define rx_data_1_sff *((unsigned char *)(0xfffc0013))
#define rx_data_2_sff *((unsigned char *)(0xfffc0014))
#define rx_data_3_sff *((unsigned char *)(0xfffc0015))
#define rx_data_4_sff *((unsigned char *)(0xfffc0016))
#define rx_data_5_sff *((unsigned char *)(0xfffc0017))
#define rx_data_6_sff *((unsigned char *)(0xfffc0018))
#define rx_data_7_sff *((unsigned char *)(0xfffc0019))
#define rx_data_8_sff *((unsigned char *)(0xfffc001A))

#define rx_frame_information_eff *((unsigned char *)(0xfffc0010))
#define rx_identifier_1_eff *((unsigned char *)(0xfffc0011))
#define rx_identifier_2_eff *((unsigned char *)(0xfffc0012))
#define rx_identifier_3_eff *((unsigned char *)(0xfffc0013))
#define rx_identifier_4_eff *((unsigned char *)(0xfffc0014))
#define rx_data_1_eff *((unsigned char *)(0xfffc0015))
#define rx_data_2_eff *((unsigned char *)(0xfffc0016))
#define rx_data_3_eff *((unsigned char *)(0xfffc0017))
#define rx_data_4_eff *((unsigned char *)(0xfffc0018))
#define rx_data_5_eff *((unsigned char *)(0xfffc0019))
#define rx_data_6_eff *((unsigned char *)(0xfffc001A))
#define rx_data_7_eff *((unsigned char *)(0xfffc001B))
#define rx_data_8_eff *((unsigned char *)(0xfffc001C))

#define tx_frame_information_sff *((unsigned char *)(0xfffc0010))
#define tx_identifier_1_sff *((unsigned char *)(0xfffc0011))
#define tx_identifier_2_sff *((unsigned char *)(0xfffc0012))
#define tx_data_1_sff *((unsigned char *)(0xfffc0013))
#define tx_data_2_sff *((unsigned char *)(0xfffc0014))
#define tx_data_3_sff *((unsigned char *)(0xfffc0015))
#define tx_data_4_sff *((unsigned char *)(0xfffc0016))
#define tx_data_5_sff *((unsigned char *)(0xfffc0017))
#define tx_data_6_sff *((unsigned char *)(0xfffc0018))
#define tx_data_7_sff *((unsigned char *)(0xfffc0019))
#define tx_data_8_sff *((unsigned char *)(0xfffc001A))

#define tx_frame_information_eff *((unsigned char *)(0xfffc0010))
#define tx_identifier_1_eff *((unsigned char *)(0xfffc0011))
#define tx_identifier_2_eff *((unsigned char *)(0xfffc0012))
#define tx_identifier_3_eff *((unsigned char *)(0xfffc0013))
#define tx_identifier_4_eff *((unsigned char *)(0xfffc0014))
#define tx_data_1_eff *((unsigned char *)(0xfffc0015))
#define tx_data_2_eff *((unsigned char *)(0xfffc0016))
#define tx_data_3_eff *((unsigned char *)(0xfffc0017))
#define tx_data_4_eff *((unsigned char *)(0xfffc0018))
#define tx_data_5_eff *((unsigned char *)(0xfffc0019))
#define tx_data_6_eff *((unsigned char *)(0xfffc001A))
#define tx_data_7_eff *((unsigned char *)(0xfffc001B))
#define tx_data_8_eff *((unsigned char *)(0xfffc001C))

#define rx_message_counter *((unsigned char *)(0xfffc001D))
#define rx_buffer_start_address *((unsigned char *)(0xfffc001E))
#define clock_divider_register *((unsigned char *)(0xfffc001F))

#endif


#define reset_mode_on 0x01
#define reset_mode_off 0xFE
#define enable_all_int 0x1E
#define tx_request 0x01
#define basic_mode 0x7F
#define extended_mode 0x80
#define release_buffer 0x04

#define self_test_mode 0x04
#define self_reception 0x10
#define enable_all_int_eff 0xFF

// can mode "Basic" or "Extended"
//const char * mode = "Basic";
//const char * mode = "Extended";
// waits for some time
void kill_time(int rep) {
  int i;

  for (i=rep; i>0; --i)
    asm("nop");
}

		

void self_testing_mode()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("***** Set to self testing mode *****\n");
	printf("************************************\n");
	
	r_val = control_register | self_test_mode;
	control_register = r_val;
	printf( "control_register 0x%X \n\n",control_register);

}
    

void reset_all_irqs()
{
	printf("************************************\n");
  	printf("********** reset all irqs **********\n");
	printf("************************************\n");
	
	printf( "interrupt_register 0x%X \n\n",interrupt_register);


}
void disable_irq_sff()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("*********** disable irqs ***********\n");
	printf("************************************\n");
	
	r_val = interrupt_enable_register | enable_all_int_eff;
	interrupt_enable_register = r_val;
	printf( "interrupt_enable_register 0x%X \n\n",interrupt_enable_register);

}

void enable_irq_sff()
{
	unsigned char r_val;
	
	//printf("************************************\n");
  	//printf("*********** enable irqs ************\n");
	//printf("************************************\n");
	
	r_val = control_register | enable_all_int;
	control_register = r_val;
	printf( "control_register 0x%X \n\n",control_register);
}

void disable_irq_eff()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("*********** disable irqs ***********\n");
	printf("************************************\n");
		
	r_val = interrupt_enable_register | enable_all_int_eff;
	interrupt_enable_register = r_val;
	printf( "interrupt_enable_register 0x%X \n\n",interrupt_enable_register);

}

void enable_irq_eff()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("*********** enable irqs eff ********\n");
	printf("************************************\n");
	
	r_val = interrupt_enable_register | enable_all_int_eff;
	interrupt_enable_register = r_val;
	printf( "interrupt_enable_register 0x%X \n\n",interrupt_enable_register);

}
		
void tx_request_command()
{
	unsigned char r_val;
	
//	printf("************************************\n");
//  	printf("*********** tx requestet ***********\n");
//	printf("************************************\n");
	
	printf( "Send transmit-request \n");
	r_val = command_register | tx_request;
	command_register = r_val;
	printf( "command register: 0x%X \n\n",command_register);
}
void self_reception_request()
{
	unsigned char r_val;

	printf("************************************\n");
  	printf("***** self reception requestet *****\n");
	printf("************************************\n");
 	
	r_val = command_register | self_reception;
	command_register = r_val;
	printf( "command register : 0x%X \n\n",command_register);

}

void release_receive_buffer()
{
	unsigned char r_val;

	printf("************************************\n");
  	printf("****** release receive buffer ******\n");
	printf("************************************\n");
 	

	r_val = command_register | release_buffer;
	command_register = r_val;
	printf( "command register : 0x%X \n\n",command_register);

}

void read_receive_buffer_basic()
{
	unsigned char r_val;

	printf("************************************\n");
  	printf("******** read receive buffer *******\n");
	printf("************************************\n");

	printf( "identifier 0: 0x%X \n",rb_identifier_byte_0);
	
	printf( "identifier 1: 0x%X \n",rb_identifier_byte_1);
	
	printf( "data byte 1: 0x%X \n",rb_data_byte_1);
	
	printf( "data byte 2: 0x%X \n",rb_data_byte_2);
		
	printf( "data byte 3: 0x%X \n",rb_data_byte_3);
	
	printf( "data byte 4: 0x%X \n",rb_data_byte_4);
	
	printf( "data byte 5: 0x%X \n",rb_data_byte_5);
	
	printf( "data byte 6: 0x%X \n",rb_data_byte_6);
	
	printf( "data byte 7: 0x%X \n",rb_data_byte_7);
	
	printf( "data byte 8: 0x%X \n\n",rb_data_byte_8);
	
}


void read_receive_buffer_extended()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("******* read frame extended ********\n");
	printf("************************************\n");

	printf( "rx_frame_information_eff: 0x%X \n\n",rx_frame_information_eff);
	
        printf( "identifier 0: 0x%X \n",rx_identifier_1_eff);
	
	printf( "identifier 1: 0x%X \n",rx_identifier_2_eff);
	
	printf( "identifier 2: 0x%X \n",rx_identifier_3_eff);
	
	printf( "identifier 3: 0x%X \n\n",rx_identifier_4_eff);
	
	printf( "data byte 1: 0x%X \n",rx_data_1_eff);
	
	printf( "data byte 2: 0x%X \n",rx_data_2_eff);
		
	printf( "data byte 3: 0x%X \n",rx_data_3_eff);
	
	printf( "data byte 4: 0x%X \n",rx_data_4_eff);
	
	printf( "data byte 5: 0x%X \n",rx_data_5_eff);
	
	printf( "data byte 6: 0x%X \n",rx_data_6_eff);
	
	printf( "data byte 7: 0x%X \n",rx_data_7_eff);
	
	printf( "data byte 8: 0x%X \n\n",rx_data_8_eff);
	  
}

/*void write_frame_basic()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("********* Send frame basic *********\n");
	printf("************************************\n");

	printf( "Set identifier - 0xEA 0x28\n");
	tb_identifier_byte_0 = 0xEA;
	printf( "identifier 0: 0x%X \n",tb_identifier_byte_0);
	
	tb_identifier_byte_1 = 0x28;
	printf( "identifier 1: 0x%X \n\n",tb_identifier_byte_1);
	
	printf( "Set data byte 1 \n");
	tb_data_byte_1 = 0x12;
	printf( "data byte 1: 0x%X \n",tb_data_byte_1);
	
	printf( "Set data byte 2 \n");
	tb_data_byte_2 = 0x34;
	printf( "data byte 2: 0x%X \n",tb_data_byte_2);
		
	printf( "Set data byte 3 \n");
	tb_data_byte_3 = 0x56;
	printf( "data byte 3: 0x%X \n",tb_data_byte_3);
	
	printf( "Set data byte 4 \n");
	tb_data_byte_4 = 0x78;
	printf( "data byte 4: 0x%X \n",tb_data_byte_4);
	
	printf( "Set data byte 5 \n");
	tb_data_byte_5 = 0x9A;
	printf( "data byte 5: 0x%X \n",tb_data_byte_5);
	
	printf( "Set data byte 6 \n");
	tb_data_byte_6 = 0xBC;
	printf( "data byte 6: 0x%X \n",tb_data_byte_6);
	
	printf( "Set data byte 7 \n");
	tb_data_byte_7 = 0xDE;
	printf( "data byte 7: 0x%X \n",tb_data_byte_7);
	
	printf( "Set data byte 8 \n");
	tb_data_byte_8 = 0xF0;
	printf( "data byte 8: 0x%X \n\n",tb_data_byte_8);
}
*/
/*void write_frame_extended()
{
	unsigned char r_val;
	
	printf("************************************\n");
  	printf("******* write frame extended *******\n");
	printf("************************************\n");

	
	tx_frame_information_eff = 0x88;
	printf( "tx_frame_information_eff: 0x%X \n\n",tx_frame_information_eff);
	
	
	printf( "Set identifier - 0xA6 0xB0 0x12 0x30\n");
	tx_identifier_1_eff = 0xA6;
	printf( "identifier 0: 0x%X \n",tx_identifier_1_eff);
	
	tx_identifier_2_eff = 0xB0;
	printf( "identifier 1: 0x%X \n",tx_identifier_2_eff);
	
	tx_identifier_3_eff = 0x12;
	printf( "identifier 2: 0x%X \n",tx_identifier_3_eff);
	
	tx_identifier_4_eff = 0x30;
	printf( "identifier 3: 0x%X \n\n",tx_identifier_4_eff);
	
	printf( "Set data - 0x12 0x34 0x56 0x78 0x9A 0xBC 0xDE 0xF0\n");
	tx_data_1_eff = 0x12;
	printf( "data byte 1: 0x%X \n",tx_data_1_eff);
	
	tx_data_2_eff = 0x34;
	printf( "data byte 2: 0x%X \n",tx_data_2_eff);
		
	tx_data_3_eff = 0x56;
	printf( "data byte 3: 0x%X \n",tx_data_3_eff);
	
	tx_data_4_eff = 0x78;
	printf( "data byte 4: 0x%X \n",tx_data_4_eff);
	
	tx_data_5_eff = 0x9A;
	printf( "data byte 5: 0x%X \n",tx_data_5_eff);
		
	tx_data_6_eff = 0xBC;
	printf( "data byte 6: 0x%X \n",tx_data_6_eff);
	
	tx_data_7_eff = 0xDE;
	printf( "data byte 7: 0x%X \n",tx_data_7_eff);
	
	tx_data_8_eff = 0xF0;
	printf( "data byte 8: 0x%X \n\n",tx_data_8_eff);
	
}
*/

void init_can(char * mode, char * self_test)
{
	unsigned char r_val;
	
	if (mode == "Basic")
	{
                //printf("************************************\n");
	  	printf("********** Basic Can Mode **********\n");
		//printf("************************************\n");
	  	
		printf( "Switch on Reset Mode\n"); 
	  	r_val = control_register | reset_mode_on;
		control_register = r_val;
	  	//printf( "control_register: 0x%X \n\n",control_register);	
	
		//printf( "Set clock divider register to basic can mode\n");
	        r_val = clock_divider_register & basic_mode | 0x07;
		clock_divider_register = r_val;
		//printf( "clock_divider_register: 0x%X \n\n",clock_divider_register);
	  	
		//printf( "Output control register \n");
	  	//output_control_register = 0x01;
	  	//printf( "output control register : 0x%X \n\n",output_control_register);
	
		//printf( "Set bus timing register 0\n");
	  	//printf( "Sync Jump Width = 2  Baudrate Prescaler = 1\n");	
  	  	bus_timing_0_register = 0x83;
	  	//printf( "bus timing register 0: 0x%X \n\n",bus_timing_0_register);

		//printf( "Set bus timing register 1\n");
		//printf( "SAM = 0 ---> Single Sampling\n");
	        bus_timing_1_register = 0x25;
		//printf( "bus timing register 1: 0x%X \n\n",bus_timing_1_register);
	
		//printf( "Set acceptance code register\n"); 
	        acceptance_code_register = 0xEA;
	 	//printf( "acceptance code register: 0x%X \n\n",acceptance_code_register);
	
		//printf( "Set acceptance mask register\n"); 
	        acceptance_mask_register = 0x0F;
	 	//printf( "acceptance mask register: 0x%X \n\n",acceptance_mask_register);
	
	
	  	kill_time(50);
		
		printf( "Switch off reset mode\n");
	        r_val = control_register & reset_mode_off;
		control_register = r_val;
		//printf( "control_register 0x%X \n\n",control_register);
		
 	    	kill_time(50);
		
	}
	else if (mode == "Extended")
	{
		printf("************************************\n");
	  	printf("******** Extended Can Mode *********\n");
		printf("************************************\n");
		
		printf( "Switch on Reset Mode\n"); 
	  	r_val = control_register | reset_mode_on;
		control_register = r_val;
	  	printf( "control_register: 0x%X \n\n",control_register);	
	        
		
 	    	kill_time(50);
		
		
		printf( "Set clock divider register to extended can mode\n");
	        r_val = clock_divider_register | extended_mode | 0x07;
		clock_divider_register = r_val;
		printf( "clock_divider_register: 0x%X \n\n",clock_divider_register);
	  	
		kill_time(50);

		//printf( "Output control register \n");
	  	//output_control_register = 0x01;
	  	//printf( "output control register: 0x%X \n\n",output_control_register);

		printf( "Set bus timing register 0\n");
	  	printf( "Sync Jump Width = 2  Baudrate Prescaler = 1\n");	
  	  	bus_timing_0_register = 0x83;
	  	printf( "bus timing register 0: 0x%X \n\n",bus_timing_0_register);
	
		printf( "Set bus timing register 1\n");
		printf( "SAM = 0 ---> Single Sampling\n");
	        bus_timing_1_register = 0x25;
		printf( "bus timing register 1: 0x%X \n\n",bus_timing_1_register);
	
		printf( "Set acceptance code register\n"); 
	        acceptance_code_0 = 0xA6;
	 	printf( "acceptance code register 0: 0x%X \n",acceptance_code_0);
	
	        acceptance_code_1 = 0xB0;
	 	printf( "acceptance code register 1: 0x%X \n",acceptance_code_1);
	
	        acceptance_code_2 = 0x12;
	 	printf( "acceptance code register 2: 0x%X \n",acceptance_code_2);
	
	        acceptance_code_3 = 0x30;
	 	printf( "acceptance code register 3: 0x%X \n\n",acceptance_code_3);
	
		
		printf( "Set acceptance mask register\n"); 
	        acceptance_mask_0 = 0x00;
	 	printf( "acceptance mask register: 0x%X \n",acceptance_mask_0);
	
	        acceptance_mask_1 = 0x00;
	 	printf( "acceptance mask register: 0x%X \n",acceptance_mask_1);
	
	        acceptance_mask_2 = 0x00;
	 	printf( "acceptance mask register: 0x%X \n",acceptance_mask_2);
	
	        acceptance_mask_3 = 0x00;
	 	printf( "acceptance mask register: 0x%X \n\n",acceptance_mask_3);
		
	  	if (self_test == "self_test")
		{
			self_testing_mode();
		}
		
		printf( "Switch off reset mode\n");
	        r_val = control_register & reset_mode_off;
		control_register = r_val;
		printf( "control_register 0x%X \n\n",control_register);
	
		kill_time(50);
	}
	

}


void self_reception_test()
{	
	unsigned char r_val;
	
	printf( "Switch on Reset Mode\n"); 
	control_register = 0x01;
	printf( "control 0x%X \n\n",control_register);	
	
	// witch to extended mode
	clock_divider_register = 0x80;
	printf( "clock_divider 0x%X \n\n",clock_divider_register);

	// set bus timing	
  	//bus_timing_0_register = 0xBF;
	bus_timing_0_register = 0x80;
	
        bus_timing_1_register = 0x34;
	
	// set acceptance and mask register
	acceptance_code_0 = 0xA6;
	printf( "acceptance 0 0x%X \n",acceptance_code_0);
	
	acceptance_code_1 = 0xB0;
	printf( "acceptance 1 0x%X \n",acceptance_code_1);
	
	acceptance_code_2 = 0x12;
	printf( "acceptance 2 0x%X \n",acceptance_code_2);
	
	acceptance_code_3 = 0x30;
	printf( "acceptance 3 0x%X \n\n",acceptance_code_3);
	
	acceptance_mask_0 = 0x00;
	printf( "acceptance mask 0x%X \n",acceptance_mask_0);
	
	acceptance_mask_1 = 0x00;
	printf( "acceptance mask 0x%X \n",acceptance_mask_1);
	
	acceptance_mask_2 = 0x00;
	printf( "acceptance mask 0x%X \n",acceptance_mask_2);
	
	acceptance_mask_3 = 0x00;
	printf( "acceptance mask 0x%X \n\n",acceptance_mask_3);
	 
	// Setting the "self test mode"	
	control_register = 0x05;
	printf( "control 0x%X \n\n",control_register);	
	
	kill_time(50);
	// Switch-off reset mode       
	control_register = 0X04;
	printf( "control_register 0x%X \n\n",control_register);
	
	kill_time(150);
	
	// Send frame
	tx_frame_information_eff = 0x88;
	
	printf( "Set identifier - 0xA6 0xB0 0x12 0x30\n");
	tx_identifier_1_eff = 0xA6;
	//printf( "identifier 0: 0x%X \n",tx_identifier_1_eff);
	
	tx_identifier_2_eff = 0xB0;
	//printf( "identifier 1: 0x%X \n",tx_identifier_2_eff);
	
	tx_identifier_3_eff = 0x12;
	//printf( "identifier 2: 0x%X \n",tx_identifier_3_eff);
	
	tx_identifier_4_eff = 0x30;
	//printf( "identifier 3: 0x%X \n\n",tx_identifier_4_eff);
	
	printf( "Set data - 0x12 0x34 0x56 0x78 0x9A 0xBC 0xDE 0xF0\n");
	tx_data_1_eff = 0x12;
	//printf( "data byte 1: 0x%X \n",tx_data_1_eff);
	
	tx_data_2_eff = 0x34;
	//printf( "data byte 2: 0x%X \n",tx_data_2_eff);
		
	tx_data_3_eff = 0x56;
	//printf( "data byte 3: 0x%X \n",tx_data_3_eff);
	
	tx_data_4_eff = 0x78;
	//printf( "data byte 4: 0x%X \n",tx_data_4_eff);
	
	tx_data_5_eff = 0x9A;
	//printf( "data byte 5: 0x%X \n",tx_data_5_eff);
	
	tx_data_6_eff = 0xBC;
	//printf( "data byte 6: 0x%X \n",tx_data_6_eff);
	
	tx_data_7_eff = 0xDE;
	//printf( "data byte 7: 0x%X \n",tx_data_7_eff);
	
	tx_data_8_eff = 0xF0;
	//printf( "data byte 8: 0x%X \n\n",tx_data_8_eff);
	
	
	// Enable ints
	interrupt_enable_register = 0xFF;
	kill_time(50);
	//tx_request_command();
	self_reception_request(); 
	
	
	//tx_request_command();
	printf( "Finnished \n");
	
	printf( "control_register 0x%X \n\n",control_register);
	
	//kill_time(10000);
	
	printf( "interrupt_register 0x%X \n\n",interrupt_register);
	
	printf( "control_register 0x%X \n\n",control_register);
	
	//read_receive_buffer_extended();
}

void write_frame_basic(unsigned char write_field[])
{	
	int i = 0;
        
        //printf("************************************\n");
  	//printf("******** write frame basic *********\n");
	//printf("************************************\n");

            for (i=0; i<10; i++)
              {
		*((unsigned char *)(0xfffc000A+i)) = write_field[i];
		kill_time(10);
		printf( "write data: %i , 0x%X , 0x%X \n",i,write_field[i],*((unsigned char *)(0xfffc000A+i)));
              }
   
}

void write_frame_extended(unsigned char write_field[])
{	
	int i = 0;
	//printf("************************************\n");
  	printf("******* write frame extended *******\n");
	//printf("************************************\n");
			
	for (i=0; i<13; i++)
	{
		*((unsigned char *)(0xfffc0010+i)) = write_field[i];
		kill_time(10);
		printf( "write data %i:  0x%X , 0x%X \n",i,write_field[i],*((unsigned char *)(0xfffc0010+i)));
	}
	
}

int test_read_frame_extended(unsigned char write_field[])
{	
	unsigned char read_field[13];
	int i = 0;
				
	for (i=0; i<13; i++)
	{
		read_field[i] = *((unsigned char *)(0xfffc0010+i));
	}
	
	for (i=0; i<13; i++)
	{
		if (read_field[i] != write_field[i])
		{
			return 0;
		}
	}
	
	return 1;
}
	
		
main()
{
  int i;
  
  unsigned char frame_extended0[13] = {0x88,0x16,0xB0,0x12,0x30,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};
  unsigned char frame_extended1[13] = {0x88,0x17,0xB0,0x12,0x30,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};
  unsigned char frame_extended2[13] = {0x88,0x18,0xB0,0x12,0x30,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};
  unsigned char frame_extended3[13] = {0x88,0x19,0xB0,0x12,0x30,0x12,0x34,0x56,0x78,0x9A,0xBC,0xDE,0xF0};


  unsigned char r_val;
	

  init_can("Extended","normal");  

  enable_irq_eff();

  while(1)
    {
      
      write_frame_extended(frame_extended0);

      tx_request_command();  

      reset_all_irqs();

      kill_time(100000);

      write_frame_extended(frame_extended1);

      tx_request_command();

      reset_all_irqs();

      kill_time(100000);

      write_frame_extended(frame_extended2);

      tx_request_command();

      reset_all_irqs();

      kill_time(100000);

      write_frame_extended(frame_extended3);

      tx_request_command();

      reset_all_irqs();

      kill_time(100000);

    }
}

