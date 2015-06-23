#include <board.h>
#include <support.h>
#include "uart.h"

#define BOTH_EMPTY (UART_LSR_TEMT | UART_LSR_THRE)

#define WAIT_FOR_XMITR \
	do { \
		lsr = REG8(uart_base + UART_LSR); \
	} while ((lsr & BOTH_EMPTY) != BOTH_EMPTY)

#define WAIT_FOR_THRE \
	do { \
		lsr = REG8(uart_base + UART_LSR); \
	} while ((lsr & UART_LSR_THRE) != UART_LSR_THRE)

#define CHECK_FOR_CHAR (REG8(uart_base + UART_LSR) & UART_LSR_DR)

#define WAIT_FOR_CHAR \
	do { \
		lsr = REG8(uart_base + UART_LSR); \
	} while ((lsr & UART_LSR_DR) != UART_LSR_DR)

#define UART_TX_BUFF_LEN 32
#define UART_TX_BUFF_MASK (UART_TX_BUFF_LEN -1)

static unsigned long uart_base = 0;

char tx_buff[UART_TX_BUFF_LEN];
volatile int tx_level, rx_level;

void uart_init(unsigned long base)
{
	int divisor;
    uart_base = base;
	/* Reset receiver and transmiter */
	/* Set RX interrupt for each byte */
	REG8(uart_base + UART_FCR) = UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR | UART_FCR_CLEAR_XMIT | UART_FCR_TRIGGER_1;

	/* Enable RX interrupt */
	REG8(uart_base + UART_IER) = UART_IER_RDI | UART_IER_THRI;

	/* Set 8 bit char, 1 stop bit, no parity */
	REG8(uart_base + UART_LCR) = UART_LCR_WLEN8 & ~(UART_LCR_STOP | UART_LCR_PARITY);

	/* Set baud rate */
	divisor = IN_CLK/(16 * UART_BAUD_RATE);
	REG8(uart_base + UART_LCR) |= UART_LCR_DLAB;
	REG8(uart_base + UART_DLM) = (divisor >> 8) & 0x000000ff;
	REG8(uart_base + UART_DLL) = divisor & 0x000000ff;
	REG8(uart_base + UART_LCR) &= ~(UART_LCR_DLAB);

	return;
}

void uart_putc(char c)
{
	unsigned char lsr;

	WAIT_FOR_THRE;
	REG8(uart_base + UART_TX) = c;
	WAIT_FOR_XMITR;
}



char uart_getc()
{
	char c;
	c = REG8(uart_base + UART_RX);
	return c;
}


void uart_interrupt()
{
	char lala;
	unsigned char interrupt_id;
	interrupt_id = REG8(uart_base + UART_IIR);
	if ( interrupt_id & UART_IIR_RDI )
	{
		lala = uart_getc();
		uart_putc(lala+1);
	}

}

void uart_print_str(char *p)
{
	while(*p != 0) {
		uart_putc(*p);
		p++;
	}
}

void uart_print_long(unsigned long ul)
{
	int i;
	char c;


	uart_print_str("0x");
	for(i=0; i<8; i++) {

		c = (char) (ul>>((7-i)*4)) & 0xf;
		if(c >= 0x0 && c<=0x9)
			c += '0';
		else
			c += 'a' - 10;
		uart_putc(c);
	}

}

void uart_print_short(unsigned long ul)
{
	int i;
	char c;
	char flag=0;


	uart_print_str("0x");
	for(i=0; i<8; i++) {

		c = (char) (ul>>((7-i)*4)) & 0xf;
		if(c >= 0x0 && c<=0x9)
			c += '0';
		else
			c += 'a' - 10;
		if ((c != '0') || (i==7))
			flag=1;
		if(flag)
			uart_putc(c);
	}

}
