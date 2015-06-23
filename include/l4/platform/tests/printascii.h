#ifndef __PLATFORM__PB926__PRINTASCII__H__
#define __PLATFORM__PB926__PRINTASCII__H__

/* This include is for the C library on the host. So that
 * any test executables that run on host can use it.
 * Don't confuse it with anything else.
 */
#include <stdio.h>

#define printascii(str)		printf(str)
#define printhex8(x)		printf("0x%x",(unsigned int)x)
#define dprintk(str, val)	printf("%-25s0x%x\n", str, val)
/*
#define	dprintk(str, val)		\
	printascii(str);		\
	printhex8((val));		\
	printascii("\n");
*/

#endif /* __PLATFORM__PB926__PRINTASCII__H__ */
