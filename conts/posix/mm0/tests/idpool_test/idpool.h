#ifndef __MM0_IDPOOL_H__
#define __MM0_IDPOOL_H__

#include "bit.h"

struct id_pool {
	int nwords;
	u32 bitmap[];
};

struct id_pool *id_pool_new_init(int mapsize);
int id_new(struct id_pool *pool);
int id_del(struct id_pool *pool, int id);

int ids_new_contiguous(struct id_pool *pool, int numids);
int ids_del_contiguous(struct id_pool *pool, int first, int numids);
#endif /* __MM0_IDPOOL_H__ */
