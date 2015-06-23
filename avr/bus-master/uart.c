#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include "uart.h"

//#define FOSC	8000000
#define FOSC	3686400
#define BAUD(x) ((FOSC/16/x)-1)

void init_usart() {
	UBRR0H = (unsigned char) (BAUD(9600) >> 8);
	UBRR0L = (unsigned char) BAUD(9600);

	UCSR0B = (1<<TXEN0) |(1<<RXEN0);
	UCSR0C = (1<<UCSZ00)|(1<<UCSZ01);	
}

void send_byte(uint8_t byte) {
	while ( !(UCSR0A & (1<<UDRE0)));
	UDR0 = byte;
}


uint8_t read_byte() {
	while ( !(UCSR0A & ( 1<<RXC0)));
	return UDR0;
}