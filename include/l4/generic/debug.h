/*
 * Definitions for kernel entry accounting.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Written by Bahadir Balban
 */
#ifndef __GENERIC_DEBUG_H__
#define __GENERIC_DEBUG_H__

#include INC_ARCH(types.h)
#include INC_SUBARCH(cache.h)
#include <l4/lib/printk.h>

#if defined(CONFIG_DEBUG_ACCOUNTING)

struct exception_count {
	u64 syscall;
	u64 data_abort;
	u64 prefetch_abort;
	u64 irq;
	u64 undefined_abort;
};

/*
 * Note these are packed to match systable offsets
 * so that they're incremented with an auccess
 */
struct syscall_count {
	u64 ipc;
	u64 tswitch;
	u64 tctrl;
	u64 exregs;
	u64 emtpy;
	u64 unmap;
	u64 irqctrl;
	u64 empty1;
	u64 map;
	u64 getid;
	u64 capctrl;
	u64 empty2;
	u64 time;
	u64 mutexctrl;
	u64 cachectrl;
} __attribute__ ((__packed__));

struct task_op_count {
	u64 context_switch;
	u64 space_switch;
};

struct cache_op_count {
	u64 dcache_clean_mva;
	u64 dcache_inval_mva;
	u64 icache_clean_mva;
	u64 icache_inval_mva;
	u64 dcache_clean_setway;
	u64 dcache_inval_setway;
	u64 tlb_mva;
};

#if defined(CONFIG_DEBUG_PERFMON_KERNEL)

/* Minimum, maximum and average timings for the call */
struct syscall_timing {
	u64 total;
	u32 min;
	u32 max;
	u32 avg;
};

struct syscall_timings {
	struct syscall_timing ipc;
	struct syscall_timing tswitch;
	struct syscall_timing tctrl;
	struct syscall_timing exregs;
	struct syscall_timing emtpy;
	struct syscall_timing unmap;
	struct syscall_timing irqctrl;
	struct syscall_timing empty1;
	struct syscall_timing map;
	struct syscall_timing getid;
	struct syscall_timing capctrl;
	struct syscall_timing empty2;
	struct syscall_timing time;
	struct syscall_timing mutexctrl;
	struct syscall_timing cachectrl;
	u64 all_total;
} __attribute__ ((__packed__));

extern struct syscall_timings syscall_timings;


#endif /* End of CONFIG_DEBUG_PERFMON_KERNEL */

struct system_accounting {
	struct syscall_count syscalls;

#if defined(CONFIG_DEBUG_PERFMON_KERNEL)
	struct syscall_timings syscall_timings;
#endif

	struct exception_count exceptions;
	struct cache_op_count cache_ops;
	struct task_op_count task_ops;
} __attribute__ ((__packed__));


extern struct system_accounting system_accounting;

static inline void system_account_dabort(void)
{
	system_accounting.exceptions.data_abort++;
}

static inline void system_account_pabort(void)
{
	system_accounting.exceptions.prefetch_abort++;
}

static inline void system_account_undef_abort(void)
{
	system_accounting.exceptions.undefined_abort++;
}

static inline void system_account_irq(void)
{
	system_accounting.exceptions.irq++;
}

static inline void system_account_syscall(void)
{
	system_accounting.exceptions.syscall++;
}

static inline void system_account_context_switch(void)
{
	system_accounting.task_ops.context_switch++;
}

static inline void system_account_space_switch(void)
{
	system_accounting.task_ops.space_switch++;
}

#include INC_SUBARCH(debug.h)

#else /* End of CONFIG_DEBUG_ACCOUNTING */

static inline void system_account_cache_op(int op) { }
static inline void system_account_irq(void) { }
static inline void system_account_syscall(void) { }
static inline void system_account_dabort(void) { }
static inline void system_account_pabort(void) { }
static inline void system_account_undef_abort(void) { }
static inline void system_account_space_switch(void) { }
static inline void system_account_context_switch(void) { }

#endif /* End of !CONFIG_DEBUG_ACCOUNTING */


#endif /* __GENERIC_DEBUG_H__ */
