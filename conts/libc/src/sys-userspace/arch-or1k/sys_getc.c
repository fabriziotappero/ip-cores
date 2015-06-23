/*
 * Library calls for uart rx.
 *
 * Copyright (C) 2009 B Labs Ltd.
 *
 */
#include <stdio.h>
#include <libdev/uart.h>

char fgetc(FILE * file)
{
	return uart_rx_char(uart_print_base);
}

#define MAX_LINE_LEN		256
char data[MAX_LINE_LEN];

char *fgetline(FILE * file)
{
	int index = 0;

	/*
	 * Line will end if,
	 * 1. We have recieved 256 chars or
	 * 2. we recieved EOL: '\n' followed by '\r'
	 */
	while((data[index] != '\n' && ((data[index++] = fgetc(file)) != '\r')) ||
	      index != MAX_LINE_LEN);

	return data;
}
