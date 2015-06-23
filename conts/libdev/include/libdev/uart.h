/*
 * Generic uart API
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#ifndef __LIBDEV_UART_H__
#define __LIBDEV_UART_H__

void uart_tx_char(unsigned long uart_base, char c);
char uart_rx_char(unsigned long uart_base);
void uart_set_baudrate(unsigned long uart_base, unsigned int val);
void uart_init(unsigned long base);

/*
 * Base of primary uart used for printf
 */
extern unsigned long uart_print_base;

#endif /* __LIBDEV_UART_H__  */
