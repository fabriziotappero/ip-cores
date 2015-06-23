/*
 * Ties up platform's uart driver functions with printf
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <stdio.h>
#include <libdev/uart.h>

int __fputc(int c, FILE *stream)
{
	uart_tx_char(uart_print_base, c);
	return 0;
}
