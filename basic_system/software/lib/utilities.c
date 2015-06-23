#include "utilities.h"

// ############################################################################################
// Convert 4/8/12/16/20/24/28/32 bit hexadecimal value to ASCII string
   void long_to_hex_string(unsigned long data,    // max 32 bit data word
                           unsigned char *buffer, // buffer to store the string
						   unsigned char numbers) // number of places, max 8
// ############################################################################################
{
	unsigned char temp_char = 0;
	unsigned long temp_data = 0;

	// fit into range
	if(numbers > 8)
		numbers = 8;
	if(numbers < 1)
		numbers = 1;

	while(numbers > 0){
		// isolate one 4-bit value
		if(numbers > 1)
			temp_data = data >> ((numbers-1)*4);
		else
			temp_data = data;
		temp_data = temp_data & 0x0000000F;
		numbers--;

		// convert 4-bit value temp_data to char temp_char
		if(temp_data < 10)
			temp_char = '0' + temp_data;
		else
			temp_char = 'A' + temp_data - 10;

		// save character
		*buffer++ = temp_char;
	}

	*buffer++ = 0; // terminate string
}

// ############################################################################################
// read external ADC value
   unsigned int get_adc(int adc_index) // adc 0..7
// ############################################################################################
{
	unsigned long temp;

	if ((adc_index < 0) || (adc_index > 7))
		return 0;

	// config spi
	io_spi0_config(1,16); // auto assert cs, 16 bit transfer
	io_spi0_enable(adc_cs);

	temp = adc_index * 2048;
	io_spi0_trans(0); // dummy read
	return (unsigned int)io_spi0_trans(temp);
}

// ############################################################################################
// simple delay routine
   void delay(int time) // waits time*10000 clock ticks
// ############################################################################################
{
	time = time*2500*4;
	while(time > 0){
		asm volatile ("NOP");
		time--;
	}
}

// ############################################################################################
// String compare, buffered string with immediate const char string
   unsigned char string_cmpc(unsigned char *string1, const char *string2, unsigned char length)
// ############################################################################################
{
	while(length != 0){
		if(*string1++ != (unsigned char)*string2++)
			return(0); // missmatch
		length--;
	}
	return(1); // match
}
