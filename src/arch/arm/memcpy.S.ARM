/*
 * Copyright 2010 B Labs.Ltd.
 *
 * Author: Prem Mallappa  <prem.mallappa@b-labs.co.uk>
 *
 * Description: Optimized memcpy for ARM
 *
 */

#include  INC_ARCH(asm.h)
/*
void*
_memcpy(void *dst, const void *src, register uint len)
*/
BEGIN_PROC(_memcpy)
		push {r0, r4-r11, lr}
	loop32:
		cmp r2, #32
		blt loop16
		ldmia r1!, {r4 - r11}
		stmia r0!, {r4 - r11}
		sub r2, r2, #32
		b loop32

	loop16:
		cmp r2, #16
		blt loop8
		ldmia	r1!, {r4 - r7}
		stmia	r0!, {r4 - r7}
		sub r2, r2, #16
		b loop16

	loop8:
		cmp r2, #8
		blt loop4
		ldmia	r1!, {r4, r5}
		stmia	r0!, {r4, r5}
		sub r2, r2, #8
		b loop8

	loop4:
		cmp r2, #4
		blt end
		ldmia	r1!, {r4}
		stmia	r0!, {r4}
		sub r2, r2, #4
		b loop4
	end:
	last:
		teq   r2, #0
		ldrgtb r4, [r1]
		strneb r4, [r0]		// V7 supports strneb <rt>, [<rb>, +/-<index>] !, with write back
		lsrne r4, r4, #8
		subne r2, r2, #1	// Can be reduced to 1 LDR, but has a catch if it is end of memory
		addne r0, r0, #1	// we dont want to fetch 1 byte extra to end up in abort
		addne r1, r1, #1	// so, playing safe, worst case 3 LDRs
		bne last
	1:
	pop {r0, r4 - r11, pc}
END_PROC(_memcpy)
