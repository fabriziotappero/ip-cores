#ifndef __IDPOOL_H__
#define __IDPOOL_H__

#include <l4lib/lib/bit.h>
#include <string.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)

struct id_pool {
	int nwords;
	int bitlimit;
	u32 bitmap[];
};

/* Copy one id pool to another by calculating its size */
static inline void id_pool_copy(struct id_pool *to, struct id_pool *from, int totalbits)
{
	int nwords = BITWISE_GETWORD(totalbits);

	memcpy(to, from, nwords * SZ_WORD + sizeof(struct id_pool));
}

void id_pool_init(struct id_pool *idpool, int bits);
struct id_pool *id_pool_new_init(int mapsize);
int id_new(struct id_pool *pool);
int id_del(struct id_pool *pool, int id);
int id_get(struct id_pool *pool, int id);
int id_is_empty(struct id_pool *pool);
int ids_new_contiguous(struct id_pool *pool, int numids);
int ids_del_contiguous(struct id_pool *pool, int first, int numids);

#endif /* __IDPOOL_H__ */
