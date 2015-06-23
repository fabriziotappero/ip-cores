/*
 * Cpu specific features
 * defined upon the base architecture.
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Written by Bahadir Balban
 */

#ifndef __V5_CPU_H__
#define __V5_CPU_H__

#include INC_SUBARCH(mmu_ops.h)

static inline void cpu_startup(void)
{

}

static inline int smp_get_cpuid()
{
	return 0;
}

#endif /* __V5_CPU_H__ */
