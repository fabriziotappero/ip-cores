/*
 * Generic putc implementation that ties with platform-specific uart driver.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include INC_PLAT(uart.h)

void putc(char c)
{
	if (c == '\n')
		uart_tx_char(PLATFORM_CONSOLE_VBASE, '\r');
	uart_tx_char(PLATFORM_CONSOLE_VBASE, c);
}
