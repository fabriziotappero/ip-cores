#include "../lib/storm_core.h"
#include "../lib/storm_soc_basic.h"
#include "../lib/io_driver.c"
#include "../lib/uart.c"
#include "../lib/utilities.c"


// ############################################################################################
// STORM SoC Bootloader
   int main(void)
// ############################################################################################
{
	int function_sel, data, i, start_app = 0;
	unsigned long *data_pointer, word_buffer, adr_buffer, cnt;
	unsigned char buffer[5], char_tmp, *char_pointer, device_id;

	// show reset ack
	io_set_gpio0_port(0);
	set_syscpreg(0xC3, SYS_IO);

	// init I²C
	io_i2c0_speed(0x0063); // 100kHz

	// enable write-through strategy
	set_syscpreg(get_syscpreg(SYS_CTRL_0) | (1<<DC_WTHRU), SYS_CTRL_0);

	// Check config switches for immediate boot-config
	function_sel = (int)((~(get_syscpreg(SYS_IO) >> 17)) & 0x0F);
	switch(function_sel){
		case 1: function_sel = '0'; goto main_menu; break; // auto start application from RAM
		case 2: function_sel = '3'; goto main_menu; start_app = 1; device_id = 0xA0; break; // auto boot from i²c EEPROM 0xA0
		default: break;
	}

	// Intro screen
	uart0_printf("\r\n\r\n\r\n+----------------------------------------------------------------+\r\n");
	uart0_printf(            "|    <<< STORM Core Processor System - By Stephan Nolting >>>    |\r\n");
	uart0_printf(            "+----------------------------------------------------------------+\r\n");
	uart0_printf(            "|         Bootloader for STORM SoC   Version: 20120524-D         |\r\n");
	uart0_printf(            "|               Contact: stnolting@googlemail.com                |\r\n");
	uart0_printf(            "+----------------------------------------------------------------+\r\n\r\n");

	uart0_printf(            " < Welcome to the STORM SoC bootloader console! >\r\n < Select an operation from the menu below or press >\r\n");
	uart0_printf(            " < the boot key for immediate application start. >\r\n\r\n");

	// Console menu
	uart0_printf(" 0 - boot from core RAM (start application)\r\n 1 - program core RAM via UART_0\r\n 2 - core RAM dump\r\n");
	uart0_printf(" 3 - boot from I2C EEPROM\r\n 4 - program I2C EEPROM via UART_0\r\n 5 - show content of I2C EEPROM\r\n");
	uart0_printf(" a - automatic boot configuration\r\n h - help\r\n r - restart system\r\n\r\nSelect: ");

	while(1){

		// console input
		function_sel = io_uart0_read_byte();

main_menu:

		// boot button
		if (((get_syscpreg(SYS_IO) >> 16) & 0x01) == 0){
			function_sel = '3';
			start_app    = 1;
			device_id    = 0xA0;
		}

		// main functions
		switch(function_sel){

			// boot from RAM (start application)
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '0':
				io_uart0_send_byte((char)function_sel);
				start_app = 1;
				break;

			// load ram via UART0
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '1':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nApplication will start automatically after download.\r\n-> Waiting for 'storm_program.bin' in byte-stream mode...");
				uart0_scanf(buffer,4,0); // get storm master boot record code
				if((buffer[0] == 'S') && (buffer[1] == 'M') && (buffer[2] == 'B') && (buffer[3] == 'R')){
					uart0_scanf(buffer,4,0); // get image size
					adr_buffer = qbytes_to_long(buffer);
					if (adr_buffer > RAM_SIZE-8){
						uart0_printf(" ERROR! Program file too big!\r\n\r\n");
						break;
					}
					data_pointer = 0;
					while(data_pointer != adr_buffer+4){
						uart0_scanf(buffer,4,0); // get word
						*data_pointer = qbytes_to_long(buffer); // store memory entry
						data_pointer = data_pointer + 1;
					}
					start_app = 1;
				}
				else
					uart0_printf(" Invalid programming file!\r\n\r\nSelect: ");
				break;

			// ram memory dump
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '2':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nAbort dumping by pressing any key.\r\nPress any key to continue.\r\n\r\n");
				while(io_uart0_read_byte() == -1);
				while(io_uart0_read_byte() != -1);
				data_pointer = 0;
				while(data_pointer != RAM_SIZE){
					word_buffer = *data_pointer;
					io_uart0_send_byte(word_buffer >> 24);
					io_uart0_send_byte(word_buffer >> 16);
					io_uart0_send_byte(word_buffer >>  8);
					io_uart0_send_byte(word_buffer >>  0);
					data_pointer++;
					if(io_uart0_read_byte() != -1){
						break;
						uart0_printf("\r\n\r\nAborted!");
					}
				}
				uart0_printf("\r\n\r\nDumping completed.\r\n\r\nSelect: ");
				break;

			// boot from I²C EEPROM
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '3':
				if(start_app == 0){
					io_uart0_send_byte((char)function_sel);
					uart0_printf("\r\n\r\nEnter device address (2x hex_chars, set LSB to '0'): ");
					uart0_scanf(buffer,2,1);
					device_id = (unsigned char)hex_string_to_long(buffer, 2);
					if(device_id == 0){
						uart0_printf(" Invalid address!\r\n\r\nSelect: ");
						break;
					}
				}

				uart0_printf("\r\nApplication will start automatically after upload.\r\n-> Loading boot image...");
				cnt = 0;
				buffer[0] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
				buffer[1] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
				buffer[2] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
				buffer[3] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
				if((buffer[0] == 'S') && (buffer[1] == 'M') && (buffer[2] == 'B') && (buffer[3] == 'R')){
					buffer[0] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
					buffer[1] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
					buffer[2] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
					buffer[3] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
					adr_buffer = qbytes_to_long(buffer);
					data_pointer = 0;
					while((data_pointer != adr_buffer+4) && (data_pointer < IRAM_SIZE)){
						buffer[0] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
						buffer[1] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
						buffer[2] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
						buffer[3] = (unsigned char)io_i2c0_byte_transfer('r',device_id,cnt++,2,0x00);
						*data_pointer = qbytes_to_long(buffer); // store memory entry
						data_pointer = data_pointer + 1;
					}
					uart0_printf(" Upload complete\r\n");
					start_app = 1;
				}
				else
					uart0_printf(" Invalid boot device or file!\r\n\r\nSelect: ");
				break;

			// program I²C EEPROM
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '4':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nEnter device address (2x hex_chars, set LSB to '0'): ");
				uart0_scanf(buffer,2,1);
				device_id = (unsigned char)hex_string_to_long(buffer, 2);
				if(device_id == 0){
					uart0_printf("\r\nInvalid address!\r\n\r\nSelect: ");
					break;
				}

				uart0_printf("\r\nData will overwrite RAM content!\r\n-> Waiting for 'storm_program.bin' in byte-stream mode...");
				uart0_scanf(buffer,4,0);
				if((buffer[0]=='S') && (buffer[1]=='M') && (buffer[2]=='B') && (buffer[3]=='R')){
					char_pointer = 0; // beginning of RAM
					*char_pointer++ = 'S'; asm volatile ("NOP");
					*char_pointer++ = 'M'; asm volatile ("NOP");
					*char_pointer++ = 'B'; asm volatile ("NOP");
					*char_pointer++ = 'R'; asm volatile ("NOP");
					uart0_scanf(buffer,4,0);
					*char_pointer++ = buffer[0];
					*char_pointer++ = buffer[1];
					*char_pointer++ = buffer[2];
					*char_pointer++ = buffer[3];
					cnt = qbytes_to_long(buffer);
					if(cnt > 0xFFFC){
						uart0_printf(" ERROR! Program file too big!\r\n\r\n");
						break;
					}

					for(i=0; i<cnt+4; i++){
						data = -1;
						while(data == -1)
							data = io_uart0_read_byte();
						*char_pointer++ = (unsigned char)data;
					}
					uart0_printf(" Download completed\r\n");

					uart0_printf("Writing buffer to i2c EEPROM...");
					char_pointer = 0; // beginning of RAM
					for(i=0; i<cnt+12; i++){
						char_tmp = *char_pointer++;
						while(io_i2c0_byte_transfer('w', device_id, i, 2, char_tmp) != 0);
					}
					uart0_printf(" Completed\r\n\r\n");
				}
				else
					uart0_printf(" Invalid boot device or file!\r\n\r\n");
				uart0_printf("Select: ");
				break;

			// show content of I2C EEPROM
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case '5':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nEnter device address (2 hex-chars, set LSB to '0'): ");
				uart0_scanf(buffer,2,1);
				device_id = (unsigned char)hex_string_to_long(buffer, 2);
				if(device_id == 0){
					uart0_printf(" Invalid address!\r\n\r\nSelect: ");
					break;
				}
				uart0_printf("\r\n\r\nAbort dumping by pressing any key. If no data is shown,\r\n");
				uart0_printf("the selected device is not responding. Press any key to continue.\r\n\r\n");
				while(io_uart0_read_byte() == -1);
				while(io_uart0_read_byte() != -1);
				for(i=0; i<0xFFFF; i++){
						data = -1;
						while(data < 0){
							data = io_i2c0_byte_transfer('r', device_id, i, 2, 0x00);
							if(io_uart0_read_byte() != -1){
								function_sel = 'X';
								break;
							}
						}
						if(function_sel == 'X'){
							uart0_printf("\r\n\r\nAborted!");
							break;
						}
						io_uart0_send_byte(data);
				}
				uart0_printf("\r\n\r\nDumping completed.\r\n\r\nSelect: ");
				break;

			// Automatic boot configuration
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case 'a':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nAutomatic boot configuration for power-up:\r\n");
				uart0_printf("[3210] configuration DIP switch\r\n 0000 - Start bootloader console\r\n 0001 - Automatic boot from core RAM\r\n");
				uart0_printf(" 0010 - Automatic boot from I2C EEPROM (Address 0xA0)\r\n\r\nSelect: ");
				break;

			// Help screen
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case 'h':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nSTORM SoC bootloader\r\n");
				uart0_printf("'0': Execute program in RAM.\r\n");
				uart0_printf("'1': Write 'storm_program.bin' to the core's RAM via UART.\r\n");
				uart0_printf("'2': Print current content of complete core RAM.\r\n");
				uart0_printf("'3': Load boot image from EEPROM and start application.\r\n");
				uart0_printf("'4': Write 'storm_program.bin' to I2C EEPROM via UART.\r\n");
				uart0_printf("'5': Print content of I2C EEPROM.\r\n");
				uart0_printf("'a': Show DIP switch configurations for automatic boot.\r\n");
				uart0_printf("'h': Show this screen.\r\n");
				uart0_printf("'r': Reset system.\r\n\r\n");
				uart0_printf("Boot EEPROM: 24xxnnn (like 24AA64), 7 bit address + dont-care bit,\r\n");
				uart0_printf("connected to I2C_CONTROLLER_0, operating frequency is 100kHz,\r\n");
				uart0_printf("maximum EEPROM size = 65536 byte => 16 bit addresses,\r\n");
				uart0_printf("fixed boot device address: 0xA0\r\n\r\n");
				uart0_printf("Terminal setup: 9600 baud, 8 data bits, no parity, 1 stop bit\r\n\r\n");
				uart0_printf("For more information see the STORM Core / STORM SoC datasheet\r\n");
				uart0_printf("http://opencores.org/project,storm_core\r\n");
				uart0_printf("http://opencores.org/project,storm_soc\r\n");
				uart0_printf("Contact: stnolting@googlemail.com\r\n");
				uart0_printf("(c) 2012 by Stephan Nolting\r\n\r\nSelect: ");
				break;

			// back to the future
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case 'f':
				io_uart0_send_byte((char)function_sel);
				uart0_printf("\r\n\r\nWe'll send you back - to the future!.\r\n\r\n");
				uart0_printf(" - Doctor Emmet L. Brown\r\n\r\nSelect: ");
				break;

			// restart system
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case 'r':
				io_uart0_send_byte((char)function_sel);
				asm volatile ("mov r0,     #0x0FF00000");
				asm volatile ("add pc, r0, #0xF0000000"); // jump to bootloader
				while(1);
				break;

			// no input
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			case -1:
				break;

			// invalid selection
			// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
			default:
				io_uart0_send_byte((char)function_sel);
				uart0_printf(" Invalid operation!\r\nTry again: ");
				break;

		}

		// start application request
		if(start_app != 0)
			break;

	}

	// start application
	uart0_printf("\r\n\r\n-> Starting application...\r\n\r\n");
	set_syscpreg(0x00, SYS_IO);

	// disable write-through strategy
	set_syscpreg(get_syscpreg(SYS_CTRL_0) & ~(1<<DC_WTHRU), SYS_CTRL_0);

	// jump to application
	asm volatile ("mov pc, #0");
	while(1);
}
