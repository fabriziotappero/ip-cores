/*
 * ARMv7 Performance Monitor operations
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#ifndef __PERFMON_H__
#define __PERFMON_H__

#include <l4lib/types.h>

/* Perfmon control register */
#define PMCR_DP_BIT			5 /* Disable prohibited */
#define PMCR_X_BIT			4 /* Export event enable */
#define PMCR_D_BIT			3 /* 64-cycle granularity */
#define PMCR_C_BIT			2 /* PMCCNTR reset */
#define PMCR_P_BIT			1 /* Events all reset */
#define PMCR_E_BIT			0 /* Enable all */

/* Obtain number of event counters */
#define PMCR_N_SHIFT			11
#define PMCR_N_MASK			0x1F

/* Special bit for cycle counter */
#define PMCCNTR_BIT			31


/*
 * Performance Events
 */

/* Generic v7 events */
#define PERFMON_EVENT_SOFTINC			0
#define PERFMON_EVENT_IFETCH_L1CREFILL		1
#define PERFMON_EVENT_IFETCH_TLBREFILL		2
#define PERFMON_EVENT_DFETCH_L1CREFILL		3
#define PERFMON_EVENT_DFETCH_L1CACCESS		4
#define PERFMON_EVENT_DFETCH_TLBREFILL		5
#define PERFMON_EVENT_MEMREAD_INSTR		6
#define PERFMON_EVENT_MEMWRITE_INSTR		7
#define PERFMON_EVENT_ALL_INSTR			8
#define PERFMON_EVENT_EXCEPTION			9
#define PERFMON_EVENT_EXCEPTION_RETURN		10
#define PERFMON_EVENT_CONTEXTIDR_CHANGE		11
#define PERFMON_EVENT_PC_CHANGE			12
#define PERFMON_EVENT_IMM_BRANCH		13
#define PERFMON_EVENT_FUNCTION_RETURN		14
#define PERFMON_EVENT_UNALIGNED_ACCESS		15
#define PERFMON_EVENT_BRANCH_MISS		16
#define PERFMON_EVENT_RAW_CYCLE_COUNT		17
#define PERFMON_EVENT_BRANCH_MAYBEHIT		18

/*
 * Cortex-A9 events (only relevant ones)
 * 0x40-2, 0x6E, 0x70, 0x71-4, 0x80-0x81, 0x8A-8B
 * 0xA0-5 omitted
 */

/*
 * Linefill not satisfied from other cpu caches but
 * has to go to external memory
 */
#define PERFMON_EVENT_SMP_LINEFILL_MISS		0x50

/* Linefill satisfied from other cpu caches */
#define PERFMON_EVENT_SMP_LINEFILL_HIT		0x51

/* Icache refill stall cycles on cpu pipeline */
#define PERFMON_EVENT_ICACHE_CPU_STALL		0x60

/* Dcache refill stall cycles on cpu pipeline */
#define PERFMON_EVENT_DCACHE_CPU_STALL		0x61

/* TLB miss stall cycles on cpu pipeline */
#define PERFMON_EVENT_TLBMISS_CPU_STALL		0x62

#define PERFMON_EVENT_STREX_SUCCESS		0x63
#define PERFMON_EVENT_STREX_FAIL		0x64
#define PERFMON_EVENT_DCACHE_EVICTION		0x65

/* Issue stage can't proceed to dispatch any instruction */
#define PERFMON_EVENT_PIPELINE_CANT_ISSUE	0x66

/* Issue stage empty */
#define PERFMON_EVENT_PIPELINE_ISSUE_EMPTY	0x67

/* Register renamed instructions */
#define PERFMON_EVENT_REGRENAMED_INSTR		0x68

#define PERFMON_EVENT_CPUSTALL_ITLB_MISS	0x82
#define PERFMON_EVENT_CPUSTALL_DTLB_MISS	0x83
#define PERFMON_EVENT_CPUSTALL_IUTLB_MISS	0x84
#define PERFMON_EVENT_CPUSTALL_DUTLB_MISS	0x85
#define PERFMON_EVENT_CPUSTALL_DMB		0x86
#define PERFMON_EVENT_ISB_COUNT			0x90
#define PERFMON_EVENT_DSB_COUNT			0x91
#define PERFMON_EVENT_DMB_COUNT			0x92
#define PERFMON_EVENT_EXTIRQ_COUNT		0x93


static inline u32 __attribute__((always_inline))
cp15_read_perfmon_ctrl(void)
{
	volatile u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c12, 0\n"
		"isb\n"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_ctrl(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 0"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_cntenset(void)
{
	volatile u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c12, 1\n"
		"isb\n"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_cntenset(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 1"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_cntenclr(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c12, 2"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_cntenclr(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 2"
		:
		: "r" (word)
	);
}


static inline u32 __attribute__((always_inline))
cp15_read_perfmon_overflow(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c12, 3"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_overflow(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 3"
		:
		: "r" (word)
	);
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_softinc(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 4"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_evcntsel(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c12, 5"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_evcntsel(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c12, 5"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_cyccnt(void)
{
	volatile u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c13, 0\n"
		"isb\n"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_cyccnt(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c13, 0"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_evtypesel(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c13, 1"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_evtypesel(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c13, 1"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_evcnt(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c13, 2"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_evcnt(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c13, 2"
		:
		: "r" (word)
	);
}


static inline u32 __attribute__((always_inline))
cp15_read_perfmon_useren(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c14, 0"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_useren(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c14, 0"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_intenset(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c14, 1"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_intenset(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c14, 1"
		:
		: "r" (word)
	);
}

static inline u32 __attribute__((always_inline))
cp15_read_perfmon_intenclr(void)
{
	u32 val = 0;

	__asm__ __volatile__ (
		"mrc p15, 0, %0, c9, c14, 2"
		: "=r" (val)
		:
	);

	return val;
}

static inline void __attribute__((always_inline))
cp15_write_perfmon_intenclr(volatile u32 word)
{
	__asm__ __volatile__ (
		"mcr p15, 0, %0, c9, c14, 2"
		:
		: "r" (word)
	);
}

#include <stdio.h>

#if defined (CONFIG_DEBUG_PERFMON_USER)
static inline
u32 perfmon_read_cyccnt()
{
	u32 cnt = cp15_read_perfmon_cyccnt();
	u32 ovfl = cp15_read_perfmon_overflow();

	/* Detect overflow and signal something was wrong */
	if (ovfl & (1 << PMCCNTR_BIT))
		printf("%s: Overflow.\n", __FUNCTION__);
	return cnt;
}

void perfmon_reset_start_cyccnt();
u32 perfmon_read_reset_start_cyccnt();

#endif


void perfmon_init();

#endif /* __PERFMON_H__ */

