/*
 * This module allocates an unused address range from
 * a given memory region defined as the pool range.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <lib/bit.h>
#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memory.h)
#include <lib/addr.h>
#include <stdio.h>

/*
 * Initializes an address pool, but uses an already
 * allocated id pool for it.
 */
int address_pool_init_with_idpool(struct address_pool *pool,
				  struct id_pool *idpool,
				  unsigned long start, unsigned long end)
{
	pool->idpool = idpool;
	pool->start = start;
	pool->end = end;

	return 0;
}

int address_pool_init(struct address_pool *pool, unsigned long start, unsigned long end)
{
	if ((pool->idpool = id_pool_new_init(__pfn(end - start))) < 0)
		return (int)pool->idpool;
	pool->start = start;
	pool->end = end;
	return 0;
}

void *address_new(struct address_pool *pool, int npages)
{
	unsigned int pfn;

	if ((int)(pfn = ids_new_contiguous(pool->idpool, npages)) < 0)
		return 0;

	return (void *)__pfn_to_addr(pfn) + pool->start;
}

int address_del(struct address_pool *pool, void *addr, int npages)
{
	unsigned long pfn = __pfn(page_align(addr) - pool->start);

	if (ids_del_contiguous(pool->idpool, pfn, npages) < 0) {
		printf("%s: Invalid address range returned to "
		       "virtual address pool.\n", __FUNCTION__);
		return -1;
	}
	return 0;
}

