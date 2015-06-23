/*
 * Bitmap-based link-listable fixed-size memory cache.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __MEMCACHE_H__
#define __MEMCACHE_H__

#include <l4/config.h>
#include <l4/macros.h>
#include <l4/types.h>
#include <l4/lib/list.h>

/* Very basic cache structure. All it does is, keep an internal bitmap of
 * items of struct_size. (Note bitmap is fairly efficient and simple for a
 * fixed-size memory cache) Keeps track of free/occupied items within its
 * start/end boundaries. Does not grow/shrink but you can link-list it. */
struct mem_cache {
	struct link list;
	int total;
	int free;
	unsigned int start;
	unsigned int end;
	unsigned int struct_size;
	unsigned int *bitmap;
};

void *mem_cache_zalloc(struct mem_cache *cache);
void *mem_cache_alloc(struct mem_cache *cache);
int mem_cache_free(struct mem_cache *cache, void *addr);
struct mem_cache *mem_cache_init(void *start, int cache_size,
				 int struct_size, unsigned int alignment);
static inline int mem_cache_is_full(struct mem_cache *cache)
{
	return cache->free == 0;
}
static inline int mem_cache_is_empty(struct mem_cache *cache)
{
	return cache->free == cache->total;
}
static inline int mem_cache_is_last_free(struct mem_cache *cache)
{
	return cache->free == 1;
}
static inline int mem_cache_total_empty(struct mem_cache *cache)
{
	return cache->free;
}
#endif /* __MEMCACHE_H__ */
