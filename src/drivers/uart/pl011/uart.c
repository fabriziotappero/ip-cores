/*
 * PL011 UART driver
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <l4/drivers/uart/pl011/uart.h>
#include INC_ARCH(io.h)

/* Error status bits in receive status register */
#define PL011_FE		(1 << 0)
#define PL011_PE		(1 << 1)
#define PL011_BE		(1 << 2)
#define PL011_OE		(1 << 3)

/* Status bits in flag register */
#define PL011_TXFE		(1 << 7)
#define PL011_RXFF		(1 << 6)
#define PL011_TXFF		(1 << 5)
#define PL011_RXFE		(1 << 4)
#define PL011_BUSY		(1 << 3)
#define PL011_DCD		(1 << 2)
#define PL011_DSR		(1 << 1)
#define PL011_CTS		(1 << 0)

#define PL011_UARTEN	(1 << 0)
static inline void pl011_uart_enable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTCR));
	val |= PL011_UARTEN;
	write(val, (base + PL011_UARTCR));

	return;
}

static inline void pl011_uart_disable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTCR));
	val &= ~PL011_UARTEN;
	write(val, (base + PL011_UARTCR));

	return;
}

#define PL011_TXE	(1 << 8)
static inline void pl011_tx_enable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTCR));
	val |= PL011_TXE;
	write(val, (base + PL011_UARTCR));
	return;
}

static inline void pl011_tx_disable(unsigned long base)
{
	unsigned int val = 0;

	val =read((base + PL011_UARTCR));
	val &= ~PL011_TXE;
	write(val, (base + PL011_UARTCR));
	return;
}

#define PL011_RXE	(1 << 9)
static inline void pl011_rx_enable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTCR));
	val |= PL011_RXE;
	write(val, (base + PL011_UARTCR));
	return;
}

static inline void pl011_rx_disable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTCR));
	val &= ~PL011_RXE;
	write(val, (base + PL011_UARTCR));
	return;
}

#define PL011_TWO_STOPBITS_SELECT	(1 << 3)
static inline void pl011_set_stopbits(unsigned long base, int stopbits)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));

	if(stopbits == 2) {			/* Set to two bits */
		val |= PL011_TWO_STOPBITS_SELECT;
	} else {				/* Default is 1 */
		val &= ~PL011_TWO_STOPBITS_SELECT;
	}
	write(val, (base + PL011_UARTLCR_H));
	return;
}

#define PL011_PARITY_ENABLE	(1 << 1)
static inline void pl011_parity_enable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base +PL011_UARTLCR_H));
	val |= PL011_PARITY_ENABLE;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

static inline void pl011_parity_disable(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));
	val &= ~PL011_PARITY_ENABLE;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

#define PL011_PARITY_EVEN	(1 << 2)
static inline void pl011_set_parity_even(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));
	val |= PL011_PARITY_EVEN;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

static inline void pl011_set_parity_odd(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));
	val &= ~PL011_PARITY_EVEN;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

#define	PL011_ENABLE_FIFOS	(1 << 4)
static inline void pl011_enable_fifos(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));
	val |= PL011_ENABLE_FIFOS;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

static inline void pl011_disable_fifos(unsigned long base)
{
	unsigned int val = 0;

	val = read((base + PL011_UARTLCR_H));
	val &= ~PL011_ENABLE_FIFOS;
	write(val, (base + PL011_UARTLCR_H));
	return;
}

/* Sets the transfer word width for the data register. */
static inline void pl011_set_word_width(unsigned long base, int size)
{
	unsigned int val = 0;
	if(size < 5 || size > 8)	/* Default is 8 */
		size = 8;

	/* Clear size field */
	val = read((base + PL011_UARTLCR_H));
	val &= ~(0x3 << 5);
	write(val, (base + PL011_UARTLCR_H));

	/*
	 * The formula is to write 5 less of size given:
	 * 11 = 8 bits
	 * 10 = 7 bits
	 * 01 = 6 bits
	 * 00 = 5 bits
	 */
	val = read((base + PL011_UARTLCR_H));
	val |= (size - 5) << 5;
	write(val, (base + PL011_UARTLCR_H));

	return;
}

/*
 * Defines at which level of fifo fullness an irq will be generated.
 * @xfer: tx fifo = 0, rx fifo = 1
 * @level: Generate irq if:
 * 0	rxfifo >= 1/8 full  	txfifo <= 1/8 full
 * 1	rxfifo >= 1/4 full  	txfifo <= 1/4 full
 * 2	rxfifo >= 1/2 full  	txfifo <= 1/2 full
 * 3	rxfifo >= 3/4 full	txfifo <= 3/4 full
 * 4	rxfifo >= 7/8 full	txfifo <= 7/8 full
 * 5-7	reserved		reserved
 */
static inline void pl011_set_irq_fifolevel(unsigned long base, \
			unsigned int xfer, unsigned int level)
{
	if(xfer != 1 && xfer != 0)	/* Invalid fifo */
		return;
	if(level > 4)			/* Invalid level */
		return;

	write(level << (xfer * 3), (base + PL011_UARTIFLS));
	return;
}

void uart_tx_char(unsigned long base, char c)
{
	unsigned int val = 0;

	do {
		val = read((base + PL011_UARTFR));
	} while (val & PL011_TXFF);  /* TX FIFO FULL */

	write(c, (base + PL011_UARTDR));
}

char uart_rx_char(unsigned long base)
{
	unsigned int val = 0;

	do {
		val = read(base + PL011_UARTFR);
	} while (val & PL011_RXFE); /* RX FIFO Empty */

	return (char)read((base + PL011_UARTDR));
}

/*
 * Sets the baud rate in kbps. It is recommended to use
 * standard rates such as: 1200, 2400, 3600, 4800, 7200,
 * 9600, 14400, 19200, 28800, 38400, 57600 76800, 115200.
 */
void pl011_set_baudrate(unsigned long base, unsigned int baud,
			unsigned int clkrate)
{
	const unsigned int uartclk = 24000000;	/* 24Mhz clock fixed on pb926 */
	unsigned int val = 0, ipart = 0, fpart = 0;

	/* Use default pb926 rate if no rate is supplied */
	if (clkrate == 0)
		clkrate = uartclk;
	if (baud > 115200 || baud < 1200)
		baud = 38400;	/* Default rate. */

	/* 24000000 / (38400 * 16) */
	ipart = 39;

	write(ipart, base + PL011_UARTIBRD);
	write(fpart, base + PL011_UARTFBRD);

	/*
	 * For the IBAUD and FBAUD to update, we need to
	 * write to UARTLCR_H because the 3 registers are
	 * actually part of a single register in hardware
	 * which only updates by a write to UARTLCR_H
	 */
	val = read(base + PL011_UARTLCR_H);
	write(val, base + PL011_UARTLCR_H);

}

void uart_init(unsigned long uart_base)
{
	/* Initialise data register for 8 bit data read/writes */
	pl011_set_word_width(uart_base, 8);

	/*
	 * Fifos are disabled because by default it is assumed the port
	 * will be used as a user terminal, and in that case the typed
	 * characters will only show up when fifos are flushed, rather than
	 * when each character is typed. We avoid this by not using fifos.
	 */
	pl011_disable_fifos(uart_base);

	/* Set default baud rate of 38400 */
	pl011_set_baudrate(uart_base, 38400, 24000000);

	/* Set default settings of 1 stop bit, no parity, no hw flow ctrl */
	pl011_set_stopbits(uart_base, 1);
	pl011_parity_disable(uart_base);

	/* Enable rx, tx, and uart chip */
	pl011_tx_enable(uart_base);
	pl011_rx_enable(uart_base);
	pl011_uart_enable(uart_base);
}
