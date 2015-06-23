#include "uart.h"

// ############################################################################################
// Print text string via UART 0
   const char *uart0_printf(const char *string)
// ############################################################################################
{
	char ch;

	while ((ch = *string)){
		if (io_uart0_send_byte(ch)<=0)
			break;
		string++;
	}
	return string;
}

// ############################################################################################
// Read text string via UART 0
   void uart0_scanf(unsigned char *buffer, int length, unsigned char en_echo)
// ############################################################################################
{
	int temp = 0;

	while(length > 0){
		temp = io_uart0_read_byte();
		if(temp != -1){
			temp = (unsigned char)(temp & 0x000000FF);
			*buffer++ = temp;
			if(en_echo == 1)
				io_uart0_send_byte(temp); // echo
			length--;
		}
	}
}

// ############################################################################################
// Print character buffer via UART 0
   void uart0_print_buffer(unsigned char *buffer, int size)
// ############################################################################################
{
	unsigned char char_buffer = 0;
	while(size > 0){
		char_buffer = *buffer++;
		io_uart0_send_byte((int)char_buffer);
		size--;
	}
}
