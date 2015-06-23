/*
 * PL011 UART Generic driver implementation.
 * Copyright Bahadir Balban (C) 2009
 */
#ifndef __PL011_H__
#define __PL011_H__

#include INC_ARCH(io.h)
#include INC_PLAT(offsets.h)

/* Register offsets */
#define PL011_UARTDR		0x00
#define PL011_UARTRSR		0x04
#define PL011_UARTECR		0x04
#define PL011_UARTFR		0x18
#define PL011_UARTILPR		0x20
#define PL011_UARTIBRD		0x24
#define PL011_UARTFBRD		0x28
#define PL011_UARTLCR_H		0x2C
#define PL011_UARTCR		0x30
#define PL011_UARTIFLS		0x34
#define PL011_UARTIMSC		0x38
#define PL011_UARTRIS		0x3C
#define PL011_UARTMIS		0x40
#define PL011_UARTICR		0x44
#define PL011_UARTDMACR		0x48


void uart_tx_char(unsigned long uart_base, char c);
char uart_rx_char(unsigned long uart_base);
void uart_init(unsigned long base);


#endif /* __PL011__UART__ */

