/*
 * CPU cycles per timer tick
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */

#define CPUOP_NOOP	0
#define CPUOP_MEMORY	1

#include INC_ARCH(asm.h)

	.section .text
/*
 * Default:
 * Go for 1000 CPU cycles on no ops and calculate
 * how many timer ticks it takes.
 *
 * By default timer is expected to tick per 1/1,000,000 second,
 * has been preloaded, and initialized for enabling. All we do
 * here is enable it, do our ops and read back the counter
 * difference.
 *
 * r0 = timer enable address
 * r1 = timer value address
 * r2 = op type
 * r3 = op count
 * return = how many timer ticks
 */
BEGIN_PROC(cpu_do_cycles_and_tick)
	stmfd sp!, {r4, lr}	@ Make room for new data in r4-5
	ldr r4, [r1]		@ Load timer value to r5
	str r2, [r0]		@ Start the timer.
1:
	subs r3, r3, #1		@ Decrement count
	bhi 1b
finish:
	ldr r0, [r1, #4]	@ Load current value, from load register + 4
	sub r0, r4, r0		@ Return difference between original and read
	ldmfd sp!, {r4, pc}	@ Restore R4-R5, pc


BEGIN_PROC(busy_loop)
	subs r0, r0, #1
	bhi busy_loop
	mov pc, lr
END_PROC(busy_loop)

