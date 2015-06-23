#include <stdio.h>
#include <avr/io.h>

#include "uart.h"
#include "busmaster.h"

int main(void);
void print_usage(void);
uint8_t read_hex_byte(void);
void read_single_address(uint8_t addr);
void write_single_address(uint8_t addr, uint32_t data);
void dump_memory(void);
static int uart_putchar(char c, FILE *stream);

static FILE stderrtest = FDEV_SETUP_STREAM(uart_putchar, NULL, _FDEV_SETUP_WRITE);

char msg[] = "Hello world\n";

static int uart_putchar(char c, FILE *stream) {

	if ( c == '\n' ) uart_putchar('\r', stream);
	send_byte(c);
	return 0;
}

int main () {
//	char msg[] = "lol\n";
	uint8_t input;
	uint8_t param;
	
	XDIV = (0<<XDIVEN);
	init_usart();
	init_fpgabus();
	
	stdout = stdin = &stderrtest;
//	send_byte('B');
//	send_byte('C');
//	send_byte('D');
//	printString(msg);
	//vfprintf(stderr,"%s",msg);
	printf("\n");
	print_usage();

	while (1) {
			input = read_byte();
			printf("%c\n", input);
			switch (input) {
				case 'r':
					printf("Input address (hex) : 0x");
					param = read_hex_byte();
					send_byte('\r');
					send_byte('\n');
					read_single_address(param);
					break;
				case 'd':
					dump_memory();
					break;
				case 'w':
					printf("Input address (hex) : 0x");
					param = read_hex_byte();
					send_byte('\r');
					send_byte('\n');
					{
					volatile uint32_t data; 
					printf("Input data (hex) : 0x");
					
					data = ((uint32_t)read_hex_byte())<<24;
					data |= ((uint32_t)read_hex_byte())<<16;
					data |= ((uint32_t)read_hex_byte())<<8;
					data |= read_hex_byte();
					
					send_byte('\r');
					send_byte('\n');
				
					write_single_address(param,data);
					}
				default:
					print_usage();
					break;
			}
			
	}
}

void print_usage() {
	printf("AVR-FPGA Bus master\n");
	printf("r) Read single address\n");
	printf("d) Dump entire memory\n");
	printf("w) Write single address\n");
	printf("\n");
}

void dump_memory() {
	for ( uint8_t i = 0 ; i < 0xFF; i++ ) {
		read_single_address(i);
	} 
	// If we looped <= 0xFF the loop would run forever because of the limited range of i
	read_single_address(0xFF);
}

void read_single_address(uint8_t addr) {
	uint32_t data;
	printf("0x%02x\t",addr);
	data = bus_read(addr);
	printf("0x%04x%04x\n",(unsigned int)(data>>16), (unsigned int)data);
}

void write_single_address(uint8_t addr, uint32_t data) {
	printf("0x%02x\t",addr);
	bus_write(addr,data);
	printf("0x%04x%04x\n",(unsigned int)(data>>16), (unsigned int)data);
}

/* Lots of duplicate code.. */
uint8_t read_hex_byte() {
	uint8_t result = 0;
	uint8_t preconvert;


	preconvert = read_byte();
	send_byte(preconvert);
	if ( preconvert >= '0' && preconvert <= '9' ) {
		preconvert -= '0';
	} else if ( preconvert >= 'A' && preconvert <= 'F' ) {
		preconvert -= 'A'-10;
	} else if ( preconvert >= 'a' && preconvert <= 'f' ) {
		preconvert -= 'a'-10;
	} else {
		printf("invalid input\n");
		return read_hex_byte();
	}
	
	result = preconvert<<4;

	preconvert = read_byte();
	send_byte(preconvert);
	if ( preconvert >= '0' && preconvert <= '9' ) {
		preconvert -= '0';
	} else if ( preconvert >= 'A' && preconvert <= 'F' ) {
		preconvert -= 'A'-10;
	} else if ( preconvert >= 'a' && preconvert <= 'f' ) {
		preconvert -= 'a'-10;
	} else {
		printf("invalid input\n");
		return read_hex_byte();
	}

	result |= (preconvert&0x0F);
	return result;
}
