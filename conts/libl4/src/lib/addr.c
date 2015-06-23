/*
 * This module allocates an unused address range from
 * a given memory region defined as the pool range.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4lib/lib/addr.h>
#include <stdio.h>

/*
 * Initializes an address pool, but uses an already
 * allocated id pool for it.
 */
int address_pool_init(struct address_pool *pool,
		      struct id_pool *idpool,
		      unsigned long start, unsigned long end)
{
	pool->idpool = idpool;
	pool->start = start;
	pool->end = end;

	id_pool_init(idpool, __pfn(end - start));

	return 0;
}

/*
 * Allocates an id pool and initializes it
 */
int address_pool_alloc_init(struct address_pool *pool,
			    unsigned long start, unsigned long end,
			     unsigned int size)
{
	if ((pool->idpool = id_pool_new_init(__pfn(end - start) )) < 0)
		return (int)pool->idpool;
	pool->start = start;
	pool->end = end;
	return 0;
}

void *address_new(struct address_pool *pool, int nitems, int size)
{
	unsigned int idx;

	if ((int)(idx = ids_new_contiguous(pool->idpool, nitems)) < 0)
		return 0;

	return (void *)(idx * size) + pool->start;
}

int address_del(struct address_pool *pool, void *addr, int nitems, int size)
{
	unsigned long idx = (addr - (void *)pool->start) / size;

	if (ids_del_contiguous(pool->idpool, idx, nitems) < 0) {
		printf("%s: Invalid address range returned to "
		       "virtual address pool.\n", __FUNCTION__);
		return -1;
	}
	return 0;
}

