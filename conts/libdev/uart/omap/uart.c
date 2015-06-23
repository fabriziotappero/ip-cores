/*
 * UART driver used by OMAP devices
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include <libdev/uart.h>
#include <libdev/io.h>
#include "uart.h"

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

void uart_set_baudrate(unsigned long uart_base, u32 baudrate)
{
	u32 clk_div;

	/* 48Mhz clock fixed on beagleboard */
	const u32 clkrate = 48000000;

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
	uart_set_baudrate(uart_base, 115200);

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

unsigned long uart_print_base;

void platform_init(void)
{
	uart_print_base = OMAP_UART_BASE;

	/*
         * We dont need to initialize uart here for variant-userspace,
         * as this is the same uart as used by kernel and hence
         * already initialized, we just need
         * a uart struct instance with proper base address.
         *
         * But in case of baremetal like loader, no one has done
         * initialization, so we need to do it.
         */
#if defined(VARIANT_BAREMETAL)
	uart_init(uart_print_base);
#endif
}


