/*
 * Used for thread and space ids.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <l4/lib/printk.h>
#include <l4/lib/idpool.h>
#include INC_GLUE(memory.h)

struct id_pool *id_pool_new_init(int totalbits, void *freebuf)
{
	int nwords = BITWISE_GETWORD(totalbits);
	struct id_pool *new = freebuf;
	// int bufsize = (nwords * SZ_WORD) + sizeof(struct id_pool);

	spin_lock_init(&new->lock);
	new->nwords = nwords;
	return new;
}

int id_new(struct id_pool *pool)
{
	int id;

	spin_lock(&pool->lock);
	id = find_and_set_first_free_bit(pool->bitmap,
					     pool->nwords * WORD_BITS);
	spin_unlock(&pool->lock);
	BUG_ON(id < 0);

	return id;
}

int id_del(struct id_pool *pool, int id)
{
	int ret;

	spin_lock(&pool->lock);
	ret = check_and_clear_bit(pool->bitmap, id);
	spin_unlock(&pool->lock);

	BUG_ON(ret < 0);
	return ret;
}

/* Return a specific id, if available */
int id_get(struct id_pool *pool, int id)
{
	int ret;

	spin_lock(&pool->lock);
	ret = check_and_set_bit(pool->bitmap, id);
	spin_unlock(&pool->lock);

	if (ret < 0)
		return ret;
	else
		return id;
}

