/*
 * Ties up platform's uart driver functions with generic API
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/platform.h>
#include INC_PLAT(platform.h)

#include <l4/drivers/uart/pl011/pl011_uart.h>

extern struct pl011_uart uart;

void uart_init()
{
	/* We are using UART0 for kernel */
	uart.base = PLATFORM_CONSOLE0_BASE;
	pl011_initialise_device(&uart);
}

/* Generic uart function that lib/putchar.c expects to see implemented */
void uart_putc(char c)
{
	int res;
	/* Platform specific uart implementation */
	do {
		res = pl011_tx_char(uart.base, c);
	} while (res < 0);
}

