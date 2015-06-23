#include <asm/page.h>

	.global __main
	.global __rom_start

        .global _rambase
        .global _ramvec
        .global _ramstart
        .global _ramend
	
	.global splash_bits
	.global _start
	.global _stext
	.global _edata

	.text
	
_start:
_stext:
	movew	#0x2700, %sr            /* Exceptions off! */

	moveal	#(CONFIG_RAMBASE + CONFIG_RAMSIZE), %ssp
	moveal	#_sbss, %a0
	moveal	#_ebss, %a1

	/* Copy 0 to %a0 until %a0 >= %a1 */
L1:
	movel	#0, %a0@+
	cmpal	%a0, %a1
	bhi	L1

	/* Thread */
	lea 	init_thread_union, %a0
	lea	PAGE_SIZE(%a0), %sp

lp:
	jsr	start_kernel
        jmp lp
_exit:

	jmp	_exit

__main:
	/* nothing */
	rts

	.data

/*
 *      Set up the usable of RAM stuff. Size of RAM is determined then
 *      an initial stack set up at the end.
 */
.align 4
_ramvec:
.long   0
_rambase:
.long   0
_ramstart:
.long   _ebss
_ramend:
.long   (CONFIG_RAMBASE + CONFIG_RAMSIZE)
