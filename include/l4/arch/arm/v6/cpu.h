/*
 * Cpu specific features
 * defined upon the base architecture.
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Written by Bahadir Balban
 */

#ifndef __V6_CPU_H__
#define __V6_CPU_H__

#include INC_SUBARCH(mmu_ops.h)

#define MPIDR_CPUID_MASK		0x7

/* Read multi-processor affinity register */
static inline unsigned int __attribute__((always_inline))
cp15_read_mpidr(void)
{
	unsigned int val;

	__asm__ __volatile__ (
		"mrc  p15, 0, %0, c0, c0, 5\n"
		: "=r" (val)
		:
	);

	return val;
}

static inline int smp_get_cpuid()
{
	volatile u32 mpidr = cp15_read_mpidr();

	return mpidr & MPIDR_CPUID_MASK;
}

static inline void cpu_startup(void)
{

}

#endif /* __V6_CPU_H__ */
