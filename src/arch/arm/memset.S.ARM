/*
 * Copyright 2010 (C) B Labs.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 * Description: Optimized memset for ARM
 */

#include INC_ARCH(asm.h)

/*
void *
memset(void *dst, int c, int len)
*/
BEGIN_PROC(_memset)
	stmfd	sp!, {r4 - r11, lr}

	and	r1, r1, #255		/* c &= 0xff */
	orr	r1, r1, lsl #8		/* c |= c<<8 */
	orr	r1, r1, lsl #16		/* c |= c<<16 */
	mov	r4, r1
	cmp	r2, #8
	blt	4f
	movge	r5, r4
	cmpge	r2, #16
	blt	8f
	movge	r6, r4
	movge	r7, r4
	cmpge	r2, #32
	blt	16f
	movge	r8, r4
	movge	r9, r4
	movge	r10, r4
	movge	r11, r4
	32:
		cmp	r2, #32
		blt	16f
		stmia	r0!, {r4 - r11}
		sub	r2, r2, #32
		b	32b

	16:
		cmp	r2, #16
		blt	8f
		stmia	r0!, {r4 - r7}
		sub	r2, r2, #16
		b	16b

	8:
		cmp	r2, #8
		blt	4f
		stmia	r0!, {r4, r5}
		sub	r2, r2, #8
		b	8b

	4:
		cmp	r2, #4
		blt	end
		stmia	r0!, {r4}
		sub	r2, r2, #4
		b	4b
	end:
		teq	r2, #0
		strneb	r4, [r0, #0]
		subne	r2, r2, #1
		addne	r0, r0, #1
		bne	end

	ldmfd	sp!, {r4 - r11, pc}
END_PROC(_memset)
