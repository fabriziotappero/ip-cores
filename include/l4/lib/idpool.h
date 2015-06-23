#ifndef __IDPOOL_H__
#define __IDPOOL_H__

#include <l4/lib/bit.h>
#include <l4/lib/spinlock.h>

/* One page size minus the structure fields */
#define CONFIG_MAX_SYSTEM_IDS			(1023*32)
#define SYSTEM_IDS_MAX				(CONFIG_MAX_SYSTEM_IDS >> 5)

struct id_pool {
	struct spinlock lock;
	int nwords;
	u32 bitmap[SYSTEM_IDS_MAX];
};

struct id_pool_variable {
	struct spinlock lock;
	int nwords;
	u32 bitmap[];
};

struct id_pool *id_pool_new_init(int mapsize, void *buffer);
int id_new(struct id_pool *pool);
int id_del(struct id_pool *pool, int id);
int id_get(struct id_pool *pool, int id);

#endif /* __IDPOOL_H__ */
