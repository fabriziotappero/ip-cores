#ifndef __DEBUG__MACRO__S__
#define __DEBUG__MACRO__S__

#include <macros.h>
#include <config.h>
#include INC_PLAT(offsets.h)

#define UART01x_DR		0x00
/*
 *  linux/arch/arm/kernel/debug.S
 *
 *  Copyright (C) 1994-1999 Russell King
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 *  32-bit debugging code
 */
		.macro	addruart,rx
		mrc	p15, 0, \rx, c1, c0
		tst	\rx, #1			@ MMU enabled?
		moveq	\rx,      #0x10000000
		orreq	\rx, \rx, #0x001F0000
		orreq	\rx, \rx, #0x00001000
		/* FIXME: This offset is incorrect for now. Make sure you pass correct offset */
		movne	\rx,      #0xf9000000 @#IO_AREA0_VADDR
		addne	\rx, \rx, #0xF1000
		@ addne	\rx, \rx, #PB926_UART0_VOFFSET	@ UART0 page offset from
							@ virtual io area base.
		.endm

		.macro	senduart,rd,rx
		strb	\rd, [\rx, #UART01x_DR]
		.endm

		.macro	waituart,rd,rx
1001:		ldr	\rd, [\rx, #0x18]	@ UARTFLG
		tst	\rd, #1 << 5		@ UARTFLGUTXFF - 1 when full
		bne	1001b
		.endm

		.macro	busyuart,rd,rx
1001:		ldr	\rd, [\rx, #0x18]	@ UARTFLG
		tst	\rd, #1 << 3		@ UARTFLGUBUSY - 1 when busy
		bne	1001b
		.endm

#endif /* __DEBUG__MACRO__S__ */
