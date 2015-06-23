/*
 * Debug/performance measurements for mm0
 *
 * Copyright (C) 2010 B Labs Ltd.
 */
#ifndef __ARCH_DEBUG_H__
#define __ARCH_DEBUG_H__

#if !defined(CONFIG_DEBUG_PERFMON_USER)

#include <l4lib/types.h>

/* Common empty definitions for all arches */
static inline u32 perfmon_read_cyccnt() { return 0; }

static inline void perfmon_reset_start_cyccnt() { }
static inline u32 perfmon_read_reset_start_cyccnt() { return 0; }

#define debug_record_cycles(str)

#else /* End of CONFIG_DEBUG_PERFMON_USER */

/* Architecture specific perfmon cycle counting */
#include L4LIB_INC_SUBARCH(perfmon.h)

extern u64 perfmon_total_cycles;
extern u64 current_cycles;

/*
 * This is for Cortex-A9 running at 400Mhz. 25 / 100000 is
 * a rewriting of 2.5 nanosec / 1,000,000
 */
#define debug_record_cycles(str)			\
{							\
	current_cycles = perfmon_read_cyccnt();		\
	perfmon_total_cycles += current_cycles;		\
	printf("%s: took %llu milliseconds\n", str,	\
	       current_cycles * 64 * 25 / 100000);	\
	perfmon_reset_start_cyccnt();			\
}

#endif /* End of !CONFIG_DEBUG_PERFMON_USER */

#endif /* __ARCH_DEBUG_H__ */
