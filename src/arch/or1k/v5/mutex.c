/*
 * ARM v5 Binary semaphore (mutex) implementation.
 *
 * Copyright (C) 2007-2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#include <l4/lib/printk.h>

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

void __spin_lock(unsigned long *s)
{
	int tmp = 0, tmp2;
	__asm__ __volatile__(
		"1: \n"
		"swp %0, %1, [%2] \n"
		"teq %0, %3 \n"
		"bne 1b \n"
		: "=&r" (tmp2)
		: "r" (tmp), "r"(s), "r"(0)
		: "cc", "memory"
		);
}

void __spin_unlock(unsigned long *s)
{
	int tmp = 1, tmp2;
	__asm__ __volatile__(
		"1: \n"
		"swp %0, %1, [%2] \n"
		"teq %0, %3 \n"
		"bne 1b \n"
		: "=&r" (tmp2)
		: "r" (tmp), "r"(s), "r"(0)
		: "cc", "memory"
		);
}

int __mutex_lock(unsigned long *s)
{
	int tmp = MUTEX_LOCKED, tmp2;
	__asm__ __volatile__(
		"swp %0, %1, [%2] \n"
		: "=&r"(tmp2)
		: "r"(tmp), "r"(s)
		: "cc", "memory"
		);
	if (tmp2 == MUTEX_UNLOCKED)
		return 1;

	return 0;
}

void __mutex_unlock(unsigned long *s)
{
	int tmp, tmp2=MUTEX_UNLOCKED;
	__asm__ __volatile__(
		"swp %0, %1, [%2] \n"
		: "=&r"(tmp)
		: "r"(tmp2), "r"(s)
		: "cc", "memory"
		);
	BUG_ON(tmp != MUTEX_LOCKED);
}
