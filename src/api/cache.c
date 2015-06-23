/*
 * Low level cache control functions.
 *
 * Copyright (C) 2009 - 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4/lib/printk.h>
#include <l4/api/errno.h>
#include <l4/generic/tcb.h>
#include <l4/api/cache.h>
#include <l4/generic/capability.h>
#include INC_GLUE(cache.h)

int sys_cache_control(unsigned long start, unsigned long end,
		      unsigned int flags)
{
	int ret = 0;

	if ((ret = cap_cache_check(start, end, flags)) < 0)
		return ret;

	switch (flags) {
	case L4_INVALIDATE_ICACHE:
		arch_invalidate_icache(start, end);
		break;

	case L4_INVALIDATE_DCACHE:
		arch_invalidate_dcache(start, end);
		break;

	case L4_CLEAN_DCACHE:
		arch_clean_dcache(start, end);
		break;

	case L4_CLEAN_INVALIDATE_DCACHE:
		arch_clean_invalidate_dcache(start, end);
		break;

	case L4_INVALIDATE_TLB:
		arch_invalidate_tlb(start, end);
		break;

	default:
		ret = -EINVAL;
	}

	return ret;
}

