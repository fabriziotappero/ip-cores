#ifndef __PLATFORM__PB926__UART__H__
#define __PLATFORM__PB926__UART__H__

/*
 * Platform specific ties to generic uart functions that putc expects.
 *
 * Copyright (C) 2005 Bahadir Balban
 *
 */

/* C library on host */
#include <stdio.h>

#include INC_PLAT(offsets.h)
#include INC_GLUE(basiclayout.h)
/* TODO: PL011_BASE must point at a well-known virtual uart base address */
//#define PL011_BASE			PB926_UART0_BASE
#define PL011_BASE			(IO_AREA0_VADDR + 0xF1000)
#include <drivers/uart/pl011/pl011_uart.h>

static inline void uart_initialise(void)
{

}

#define uart_putc(c)	printf("%c",(char)c)



#endif /* __PLATFORM__PB926__UART__H__ */
