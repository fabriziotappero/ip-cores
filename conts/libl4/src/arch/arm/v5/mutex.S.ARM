/*
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4lib/arch/arm/asm.h>
#include <l4lib/mutex.h>

/*
 * These use the same lock word for both being granted
 * exclusive access to the word, and for storing lock values.
 */

BEGIN_PROC(__l4_mutex_lock)
	mov	r2, #-2
1:
	swp	r1, r2, [r0]
	cmp	r1, r2
	beq	1b

	@ Grabbed the lock,
	add	r1, r1, #1		@ now increment its value
	str	r1, [r0]		@ Store and finish
	cmp	r1, #L4_MUTEX_LOCKED	@ Have we locked it?
	moveq	r0, #L4_MUTEX_SUCCESS
	movne	r0, #L4_MUTEX_CONTENDED
	mov 	pc, lr
END_PROC(__l4_mutex_lock)


BEGIN_PROC(__l4_mutex_unlock)
	mov	r2, #-2
	mov	r1, #L4_MUTEX_UNLOCKED
1:
	swp	r3, r2, [r0]
	cmp	r3, r2
	beq	1b

	@ Grabbed the lock
	str	r1, [r0]		@ Now store unlocked value and finish
	mov	r0, r3			@ Get the value of contenders
	mov 	pc, lr
END_PROC(__l4_mutex_unlock)

