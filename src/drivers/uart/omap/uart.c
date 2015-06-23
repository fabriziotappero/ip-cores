/*
 * UART driver used by OMAP devices
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include <l4/drivers/uart/omap/uart.h>
#include INC_ARCH(io.h)

#define OMAP_UART_FIFO_ENABLE	(1 << 0)
#define OMAP_UART_RX_FIFO_CLR   (1 << 1)
#define OMAP_UART_TX_FIFO_CLR	(1 << 2)
static inline void uart_enable_fifo(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_FCR);
	reg |= (OMAP_UART_FIFO_ENABLE | OMAP_UART_RX_FIFO_CLR |
	        OMAP_UART_TX_FIFO_CLR);
	write(reg, uart_base + OMAP_UART_FCR);
}

static inline void uart_disable_fifo(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_FCR);
	reg &= (~OMAP_UART_FIFO_ENABLE | OMAP_UART_RX_FIFO_CLR |
		OMAP_UART_TX_FIFO_CLR);
	write(reg, uart_base + OMAP_UART_FCR);
}

#define OMAP_UART_TX_ENABLE	(1 << 0)
static inline void uart_enable_tx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg |= OMAP_UART_TX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

static inline void uart_disable_tx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg &= ~OMAP_UART_TX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);

}

#define OMAP_UART_RX_ENABLE	(1 << 1)
static inline void uart_enable_rx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg |= OMAP_UART_RX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

static inline void uart_disable_rx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg &= ~OMAP_UART_RX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

#define OMAP_UART_STOP_BITS_MASK	(1 << 2)
static inline void uart_set_stop_bits(unsigned long uart_base, int bits)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_STOP_BITS_MASK;
	reg |= (bits << 2);
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_DATA_BITS_MASK	(0x3)
static inline void uart_set_data_bits(unsigned long uart_base, int bits)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_DATA_BITS_MASK;
	reg |= bits;
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_PARITY_ENABLE		(1 << 3)
static inline void uart_enable_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg |= OMAP_UART_PARITY_ENABLE;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_disable_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_PARITY_ENABLE;
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_PARITY_EVEN		(1 << 4)
static inline void uart_set_even_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg |= OMAP_UART_PARITY_EVEN;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_set_odd_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_PARITY_EVEN;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_select_mode(unsigned long uart_base, int mode)
{
	write(mode, uart_base + OMAP_UART_MDR1);
}

#define OMAP_UART_INTR_EN	1
static inline void uart_enable_interrupt(unsigned long uart_base)
{
	write(OMAP_UART_INTR_EN, uart_base + OMAP_UART_IER);
}

static inline void uart_disable_interrupt(unsigned long uart_base)
{
	write((~OMAP_UART_INTR_EN), uart_base + OMAP_UART_IER);
}

static inline void uart_set_link_control(unsigned long uart_base, int mode)
{
	write(mode, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_TXFE		0x20
void uart_tx_char(unsigned long uart_base, char c)
{
	volatile u32 reg;

	/* Check if there is space for tx */
	do {
		reg = read(uart_base + OMAP_UART_LSR);
	} while(!(reg & OMAP_UART_TXFE));

	write(c, uart_base + OMAP_UART_THR);
}

#define OMAP_UART_RXFNE			0x1
#define OMAP_UART_RX_FIFO_STATUS	0x8
char uart_rx_char(unsigned long uart_base)
{
	volatile u32 reg;

	/* Check if pending data is there */
	do {
		reg = read(uart_base + OMAP_UART_LSR);
	} while(!(reg & OMAP_UART_RXFNE));

#if 0
	/* Check if there is some error in recieve */
	if(reg & OMAP_UART_RX_FIFO_STATUS)
		return -1;
#endif

	return (char)read(uart_base + OMAP_UART_RHR);
}

void uart_set_baudrate(unsigned long uart_base, u32 baudrate, u32 clkrate)
{
	u32 clk_div = 0;

	/* 48Mhz clock fixed on beagleboard */
	const u32 uartclk = 48000000;

	if(clkrate == 0)
		clkrate = uartclk;

	/* If baud out of range, set default rate */
	if(baudrate > 3686400 || baudrate < 300)
		baudrate = 115200;

	clk_div = clkrate/(16 * baudrate);

	/* Set clockrate in DLH and DLL */
	write((clk_div & 0xff), uart_base + OMAP_UART_DLL);
	write(((clk_div >> 8) & 0xff ), uart_base + OMAP_UART_DLH);
}

void uart_init(unsigned long uart_base)
{
	/* Disable UART */
	uart_select_mode(uart_base, OMAP_UART_MODE_DEFAULT);

	/* Disable interrupts */
	uart_disable_interrupt(uart_base);

	/* Change to config mode, to set baud divisor */
	uart_set_link_control(uart_base, OMAP_UART_BANKED_MODE_CONFIG_A);

	/* Set the baud rate */
	uart_set_baudrate(uart_base, 115200, 48000000);

	/* Switch to operational mode */
	uart_set_link_control(uart_base, OMAP_UART_BANKED_MODE_OPERATIONAL);

	/* Set up the link- parity, data bits stop bits to 8N1 */
	uart_disable_parity(uart_base);
	uart_set_data_bits(uart_base, OMAP_UART_DATA_BITS_8);
	uart_set_stop_bits(uart_base, OMAP_UART_STOP_BITS_1);

	/* Disable Fifos */
	uart_disable_fifo(uart_base);

	/* Enable modem Rx/Tx */
	uart_enable_tx(uart_base);
	uart_enable_rx(uart_base);

	/* Enable UART in 16x mode */
	uart_select_mode(uart_base, OMAP_UART_MODE_UART16X);
}
