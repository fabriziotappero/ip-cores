/*
 * This module allocates an unused virtual address range for shm segments.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <lib/bit.h>
#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memory.h)
#include <lib/vaddr.h>
#include <stdio.h>
#include <memory.h>

void vaddr_pool_init(struct id_pool *pool, unsigned long start, unsigned long end)
{
	pool = id_pool_new_init(__pfn(end - start));
}

void *vaddr_new(struct id_pool *pool, int npages)
{
	unsigned int shm_vpfn;

	if ((int)(shm_vpfn = ids_new_contiguous(pool, npages)) < 0)
		return 0;

	return (void *)__pfn_to_addr(shm_vpfn + cont_mem_regions.shmem->start);
}

int vaddr_del(struct id_pool *pool, void *vaddr, int npages)
{
	unsigned long idpfn = __pfn(page_align(vaddr) -
				    __pfn_to_addr(cont_mem_regions.shmem->start));

	if (ids_del_contiguous(pool, idpfn, npages) < 0) {
		printf("%s: Invalid address range returned to "
		       "virtual address pool.\n", __FUNCTION__);
		return -1;
	}
	return 0;
}

