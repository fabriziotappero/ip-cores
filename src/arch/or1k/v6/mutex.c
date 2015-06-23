/*
 * Copyright (C) 2009 B Labs Ltd.
 */

#include <l4/macros.h>
#include <l4/lib/printk.h>
#include <l4/lib/mutex.h>
#include INC_SUBARCH(mmu_ops.h)

#define MUTEX_UNLOCKED	0
#define MUTEX_LOCKED	1


/* Notes on ldrex/strex:
 * ldrex rD, [rN, #imm] : loads rD with contents of at address (rN + imm)
 * strex rD, rS, [rN, #imm]: pushes contents of rS to memory location (rN + imm)
 *		rD is 0 if operation is successful, 1 otherwise
 */

void __spin_lock(unsigned int *s)
{
	unsigned int tmp;
	__asm__ __volatile__ (
		"1:\n"
		"ldrex	  %0, [%2]\n"
		"teq	  %0, #0\n"
		"strexeq  %0, %1, [%2]\n"
		"teq	  %0, #0\n"
#ifdef CONFIG_SMP
		"wfene\n"
#endif
		"bne	  1b\n"
		: "=&r" (tmp)
		: "r"(1), "r"(s)
		: "cc", "memory"
	);

	dsb();
}

void __spin_unlock(unsigned int *s)
{
	__asm__ __volatile__ (
		"str	%0, [%1]\n"
		:
		: "r"(0), "r"(s)
		: "memory"
	);

#ifdef CONFIG_SMP
	dsb();
	__asm__ __volatile__ ("sev\n");
#endif
}


/*
 * Current implementation uses __mutex_(un)lock within a protected
 * spinlock, needs to be revisited in the future
 */
unsigned int __mutex_lock(unsigned int *m)
{
	unsigned int tmp, res;
	__asm__ __volatile__ (
		"1:\n"
		"ldrex	%0, [%3]\n"
		"tst	%0, #0\n"
		"strexeq %1, %2, [%3]\n"
		"tsteq	%1, #0\n"
		"bne 1b\n"
		: "=&r" (tmp), "=&r"(res)
		: "r"(1), "r"(m)
		: "cc", "memory"
	);

	if ((tmp | res) != 0)
		return 0;
	return 1;
}

void __mutex_unlock(unsigned int *m)
{
	__asm__ __volatile__ (
		"str  %0, [%1] \n"
		:
		: "r"(0), "r"(m)
		: "memory"
		);

}

