/*
 * Address allocation pool
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __ADDR_H__
#define __ADDR_H__

#include <lib/idpool.h>

/* Address pool to allocate from a range of addresses */
struct address_pool {
	struct id_pool *idpool;
	unsigned long start;
	unsigned long end;
};

int address_pool_init_with_idpool(struct address_pool *pool,
				  struct id_pool *idpool,
				  unsigned long start, unsigned long end);
int address_pool_init(struct address_pool *pool, unsigned long start,
		      unsigned long end);
void *address_new(struct address_pool *pool, int npages);
int address_del(struct address_pool *, void *addr, int npages);

#endif /* __ADDR_H__ */
