/*
 * Test cache control system call
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include INC_GLUE(memory.h)
#include <l4lib/lib/cap.h>
#include <l4/api/cache.h>
#include <linker.h>
#include <stdio.h>

#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)

/* This simply tests that all cache calls are working */
int test_cctrl_basic(void)
{
	struct capability *virtcap = cap_get_by_type(CAP_TYPE_MAP_VIRTMEM);
	void *start = (void *)__pfn_to_addr(virtcap->start);
	void *end = (void *)__end;
	int err;

	if ((err = l4_cache_control(start, end, L4_INVALIDATE_ICACHE)) < 0)
		return err;

	if ((err = l4_cache_control(start, end, L4_INVALIDATE_DCACHE)) < 0)
		return err;

	if ((err = l4_cache_control(start, end, L4_CLEAN_INVALIDATE_DCACHE)) < 0)
		return err;

	if ((err = l4_cache_control(start, end, L4_CLEAN_DCACHE)) < 0)
		return err;

	if ((err = l4_cache_control(start, end, L4_INVALIDATE_TLB)) < 0)
		return err;

	return 0;
}

int test_cctrl_sync_caches()
{
	/*
	 * Double-map a physical page and fill it with
	 * mov r0, r0, r0 * PAGE_SIZE - 1
	 * b return_label
	 */

	/* Flush the Dcache for that page */

	/* Invalidate I cache for that page */

	/* Execute the page */

	/*
	 * Create a new address space and execute the page from
	 * that space
	 */
	return 0;
}

int test_api_cctrl(void)
{
	int err;

	if ((err = test_cctrl_basic()) < 0)
		goto out_err;


	printf("CACHE CONTROL:                 -- PASSED --\n");
	return 0;

out_err:
	printf("CACHE CONTROL:                 -- FAILED --\n");
	return err;

}

