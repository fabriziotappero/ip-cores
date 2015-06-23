/*
 * ARM-specific syscall type accounting.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */

#ifndef __ARM_DEBUG_H__
#define __ARM_DEBUG_H__

#include INC_SUBARCH(perfmon.h)

#if defined (CONFIG_DEBUG_ACCOUNTING)

extern struct system_accounting system_accounting;

static inline void
system_account_syscall_type(unsigned long swi_address)
{
	*(((u64 *)&system_accounting.syscalls) +
				  ((swi_address & 0xFF) >> 2)) += 1;
}

#else /* End of CONFIG_DEBUG_ACCOUNTING */

static inline void system_account_syscall_type(unsigned long swi_address) { }

#endif /* End of !CONFIG_DEBUG_ACCOUNTING */


#if defined (CONFIG_DEBUG_PERFMON_KERNEL)

static inline void
system_measure_syscall_start(void)
{
	/* To avoid non-voluntary rescheduling during call */
	perfmon_reset_start_cyccnt();
}

/* Defined in arm/glue/debug.c */
void system_measure_syscall_end(unsigned long swi_address);

#else /* End of CONFIG_DEBUG_PERFMON_KERNEL */

static inline void system_measure_syscall_start(void) { }
static inline void system_measure_syscall_end(unsigned long swi_address) { }

#endif /* End of !CONFIG_DEBUG_PERFMON_KERNEL */

#endif /* __ARM_DEBUG_H__ */
