/*
 * ARM v5 Binary semaphore (mutex) implementation.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */

#include INC_ARCH(asm.h)

/* Recap on swp:
 * swp rx, ry, [rz]
 * In one instruction:
 * 1) Stores the value in ry into location pointed by rz.
 * 2) Loads the value in the location of rz into rx.
 * By doing so, in one instruction one can attempt to lock
 * a word, and discover whether it was already locked.
 */

#define MUTEX_UNLOCKED	0
#define MUTEX_LOCKED	1

BEGIN_PROC(__spin_lock)
	mov	r1, #1
__spin:
	swp	r2, r1, [r0]
	cmp	r2, #0
	bne	__spin
	mov	pc, lr
END_PROC(__spin_lock)

BEGIN_PROC(__spin_unlock)
	mov	r1, #0
	swp	r2, r1, [r0]
	cmp	r2, #1		@ Debug check.
1:
	bne	1b
	mov	pc, lr
END_PROC(__spin_unlock)


/*
 * @r0: Address of mutex location.
 */
BEGIN_PROC(__mutex_lock)
	mov	r1, #1
	swp	r2, r1, [r0]
	cmp	r2, #0
	movne	r0, #0
	moveq	r0, #1
	mov	pc, lr
END_PROC(__mutex_lock)

/*
 * @r0: Address of mutex location.
 */
BEGIN_PROC(__mutex_unlock)
	mov	r1, #0
	swp	r2, r1, [r0]
	cmp	r2, #1
1:				@ Debug check.
	bne	1b
	mov	pc, lr
END_PROC(__mutex_unlock)

/*
 * @r0: Address of mutex location.
 */
BEGIN_PROC(__mutex_inc)
	swp	r2, r1, [r0]
	mov	r1, #1
	swp	r2, r1, [r0]
	cmp	r2, #0
	movne	r0, #0
	moveq	r0, #1
	mov	pc, lr
END_PROC(__mutex_inc)

/*
 * @r0: Address of mutex location.
 */
BEGIN_PROC(__mutex_dec)
	mov	r1, #0
	swp	r2, r1, [r0]
	cmp	r2, #1
1:				@ Debug check.
	bne	1b
	mov	pc, lr
END_PROC(__mutex_dec)


