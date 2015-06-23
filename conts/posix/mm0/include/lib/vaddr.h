/*
 * Virtual address allocation pool (for shm)
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __VADDR_H__
#define __VADDR_H__

#include <lib/idpool.h>

void vaddr_pool_init(struct id_pool *pool, unsigned long start,
		     unsigned long end);
void *vaddr_new(struct id_pool *pool, int npages);
int vaddr_del(struct id_pool *, void *vaddr, int npages);

#endif /* __VADDR_H__ */

