/*
 * Copyright (C) 2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#include <l4lib/mutex.h>
#include <l4lib/types.h>
#include L4LIB_INC_ARCH(syslib.h)	/* for BUG/BUG_ON,  */
#include L4LIB_INC_ARCH(asm.h)
#include INC_SUBARCH(mmu_ops.h)

int __l4_mutex_lock(void *m, l4id_t tid)
{
	int tmp, ret;
 loop:
	__asm__ __volatile__(
			     "ldrex %0, [%1]\n"
			     : "=&r"(tmp)
			     : "r"(m)
			     : "memory"
	);

	if(tmp != L4_MUTEX_UNLOCKED)
		ret = L4_MUTEX_CONTENDED;
	else
		ret = L4_MUTEX_SUCCESS;

	/* Store our 'tid' */
	__asm__ __volatile__(
			     "strex	%0, %1, [%2]\n"
			     :"=&r"(tmp)
			     :"r"(tid), "r"(m)
			     );
	if (tmp != 0) {
		/* We couldn't succeed the store, we retry */
#ifdef CONFIG_SMP
		  /* don't hog the CPU, sleep till an event */
		__asm__ __volatile__("wfe\n");
#endif
		goto loop;
	}

	dsb();

	return ret;
}

int __l4_mutex_unlock(void *m, l4id_t tid)
{
	int tmp, ret;
 loop:
	/* Load and see if the lock had our tid */
	__asm__ __volatile__(
			     "ldrex %0, [%1]\n"
			     : "=r"(tmp)
			     : "r"(m)
			     );

	if(tmp != tid)
		ret = L4_MUTEX_CONTENDED;
	else
		ret = L4_MUTEX_SUCCESS;

	/* We store unlock value '0' */
	__asm__ __volatile__(
			     "strex	%0, %1, [%2]\n"
			     :"=&r"(tmp)
			     :"rI"(L4_MUTEX_UNLOCKED), "r"(m)
			     );
	if(tmp != 0) {
		/* The store wasn't successfull, retry */
		goto loop;
	}

	dsb();

#ifdef CONFIG_SMP
	__asm__ __volatile__("sev\n");
#endif
	return ret;
}

u8 l4_atomic_dest_readb(unsigned long *location)
{
	unsigned int tmp, res;
	__asm__ __volatile__ (
		"1: 				\n"
		"	ldrex %0, [%2]		\n"
		"	strex %1, %3, [%2]	\n"
		"	teq %1, #0		\n"
		"	bne 1b			\n"
		: "=&r"(tmp), "=&r"(res)
		: "r"(location), "r"(0)
		: "cc", "memory"
	);

	return (u8)tmp;
}
