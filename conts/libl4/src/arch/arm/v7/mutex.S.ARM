/*
 * Copyright (C) 2009 Bahadir Balban
 */

#include <l4lib/arch/arm/asm.h>
#include <l4lib/mutex.h>

/*
 * @r0 = address of mutex word
 */
BEGIN_PROC(__l4_mutex_lock)
1:
	ldrex	r1, [r0]			@ Load value
	add	r1, r1, #1			@ Add 1
	strex	r3, r1, [r0]			@ Store prospective lock state
	cmp	r3, #0				@ If not successful
	bne	1b				@ Retry and decide again on the prospective lock state. No WFE as this would be a problem on single cpu
	dsb

	cmp	r1, #L4_MUTEX_LOCKED		@ We succeeded in store, but are we a locker or a contender?
	movne	r2, #L4_MUTEX_CONTENDED
	moveq	r2, #L4_MUTEX_SUCCESS
	mov	r0, r2
	mov	pc, lr
END_PROC(__l4_mutex_lock)

/*
 * @r0 = address of mutex word
 */
BEGIN_PROC(__l4_mutex_unlock)
	dsb
	mov	r3, #L4_MUTEX_UNLOCKED
1:
	ldrex	r1, [r0]
	strex	r2, r3, [r0]
	cmp	r2, #0
	bne	1b
	mov	r0, r1
	mov	pc, lr
END_PROC(__l4_mutex_unlock)

