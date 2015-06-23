/*
 * Address allocation pool.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __ADDR_H__
#define __ADDR_H__

#include <l4lib/lib/idpool.h>

/* Address pool to allocate from a range of addresses */
struct address_pool {
	struct id_pool *idpool;
	unsigned long start;
	unsigned long end;
};

int address_pool_init(struct address_pool *pool,
		      struct id_pool *idpool,
		      unsigned long start, unsigned long end);
int address_pool_alloc_init(struct address_pool *pool,
			    unsigned long start, unsigned long end,
			    unsigned int size);
void *address_new(struct address_pool *pool, int nitems, int size);
int address_del(struct address_pool *, void *addr, int nitems, int size);

#endif /* __ADDR_H__ */
