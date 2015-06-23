/*
 * Generic cache api calls
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#ifndef __GLUE_CACHE_H__
#define __GLUE_CACHE_H__

#include INC_SUBARCH(mmu_ops.h)

/* Lowest byte is reserved for and used by capability permissions */
#define ARCH_INVALIDATE_ICACHE			0x10
#define ARCH_INVALIDATE_DCACHE			0x20
#define ARCH_CLEAN_DCACHE			0x30
#define ARCH_CLEAN_INVALIDATE_DCACHE		0x40
#define ARCH_INVALIDATE_TLB			0x50

void arch_invalidate_dcache(unsigned long start, unsigned long end);
void arch_clean_invalidate_dcache(unsigned long start, unsigned long end);
void arch_invalidate_icache(unsigned long start, unsigned long end);
void arch_invalidate_tlb(unsigned long start, unsigned long end);
void arch_clean_dcache(unsigned long start, unsigned long end);

#endif /* __GLUE_CACHE_H__ */
