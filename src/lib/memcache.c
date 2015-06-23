/*
 * Bitmap-based linked-listable fixed-size memory cache.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/memcache.h>
#include <l4/lib/string.h>
#include <l4/lib/printk.h>
#include INC_GLUE(memory.h)
#include <l4/lib/bit.h>
#include <l4/api/errno.h>

/* Allocate, clear and return element */
void *mem_cache_zalloc(struct mem_cache *cache)
{
	void *elem = mem_cache_alloc(cache);
	memset(elem, 0, cache->struct_size);
	return elem;
}

/* Allocate another element from given @cache. Returns 0 when full. */
void *mem_cache_alloc(struct mem_cache *cache)
{
	int bit;
	int err;

	if (cache->free > 0) {
		if ((err = mutex_lock(&cache->mutex)) < 0)
			return PTR_ERR(err);	/* Interruptible mutex */
		cache->free--;
		if ((bit = find_and_set_first_free_bit(cache->bitmap,
						       cache->total)) < 0) {
			printk("Error: Anomaly in cache occupied state.\n"
			       "Bitmap full although cache->free > 0\n");
			BUG();
		}
		mutex_unlock(&cache->mutex);
		return (void *)(cache->start + (cache->struct_size * bit));
	} else {
		/* Cache full */
		return 0;
	}
}

/* Free element at @addr in @cache. Return negative on error. */
int mem_cache_free(struct mem_cache *cache, void *addr)
{
	unsigned int struct_addr = (unsigned int)addr;
	unsigned int bit;
	int err = 0;

	/* Check boundary */
	if (struct_addr < cache->start || struct_addr > cache->end)
		return -1; /* Address doesn't belong to cache */

	bit = ((struct_addr - cache->start) / cache->struct_size);

	/*
	 * Check alignment:
	 * Find out if there was a lost remainder in last division.
	 * There shouldn't have been, because addresses are allocated at
	 * struct_size offsets from cache->start.
	 */
	if (((bit * cache->struct_size) + cache->start) != struct_addr) {
		printk("Error: This address is not aligned on a predefined "
		       "structure address in this cache.\n");
		err = -1;
		return err;
	}

	if ((err = mutex_lock(&cache->mutex)) < 0)
		return err; /* Interruptible mutex */

	/* Check free/occupied state */
	if (check_and_clear_bit(cache->bitmap, bit) < 0) {
		printk("Error: Anomaly in cache occupied state:\n"
		       "Trying to free already free structure.\n");
		err = -1;
		goto out;
	}
	cache->free++;
	if (cache->free > cache->total) {
		printk("Error: Anomaly in cache occupied state:\n"
		       "More free elements than total.\n");
		err = -1;
		goto out;
	}
out:
	mutex_unlock(&cache->mutex);
	return err;
}

/*
 * Given a buffer start address, structure size, number of
 * structs and alignment requirements, determines how much
 * memory is needed from that starting address
 */
int mem_cache_bufsize(void *start, int struct_size, int nstructs, int aligned)
{
	unsigned long start_address = (unsigned long)start;
	int total_bytes, bwords, bitmap_size;

	/* Word alignment requirement */
	start_address = align_up(start_address, sizeof(int));

	/* Total bytes to contain structures */
	total_bytes = struct_size * nstructs;

	/* Total words to contain bitmap */
	bwords = nstructs >> 5;

	/* An extra word if not a multiple of one word's bits */
	if (nstructs & 0x1F)
		bwords++;

	/* Total bitmap bytes */
	bitmap_size = bwords * sizeof(int);

	/* Current would-be start address */
	start_address += bitmap_size + total_bytes + sizeof(struct mem_cache);

	/* Check alignment requirement */
	if (aligned)
		start_address = align_up(start_address, struct_size);

	return start_address - (unsigned long)start;
}

struct mem_cache *mem_cache_init(void *bufstart, int cache_size,
				 int struct_size, unsigned int aligned)
{
	void *start;
	struct mem_cache *cache;
	unsigned int area_start;
	unsigned int *bitmap;
	int bwords, total, bsize;

	/* Align to nearest word boundary */
       	start = (void *)align_up(bufstart, sizeof(int));
	cache_size -= (int)start - (int)bufstart;
	cache = start;

	if ((struct_size < 0) || (cache_size < 0) ||
	    ((unsigned long)start == ~(0))) {
		printk("Invalid parameters.\n");
		return 0;
	}

	/*
	 * The cache definition itself is at the beginning.
	 * Skipping it to get to start of free memory. i.e. the cache.
	 */
	area_start = (unsigned long)start + sizeof(struct mem_cache);
	cache_size -= sizeof(struct mem_cache);

	if (cache_size < struct_size) {
		printk("Cache too small for given struct_size\n");
		return 0;
	}

	/* Get how much bitmap words occupy */
	total = cache_size / struct_size;
	bwords = total >> 5;	/* Divide by 32 */
	if (total & 0x1F) {	/* Remainder? */
		bwords++;	/* Add one more word for remainder */
	}
	bsize = bwords * 4;

	/* Reduce bitmap bytes from cache size */
	cache_size -= bsize;

	/* Recalculate total - it may or may not have changed */
	total = cache_size / struct_size;

	/* This should always catch too small caches */
	if (total <= 0) {
		printk("Cache too small for given struct_size\n");
		return 0;
	}
	if (cache_size <= 0) {
		printk("Cache too small for given struct_size\n");
		return 0;
	}

	bitmap = (unsigned int *)area_start;
	area_start = (unsigned int)(bitmap + bwords);

	if (aligned) {
		unsigned int addr = area_start;
		unsigned int addr_aligned = align_up(area_start, struct_size);
		unsigned int diff = addr_aligned - addr;

		BUG_ON(diff >= struct_size);
		cache_size -= diff;

		/* Recalculate total */
		total = cache_size / struct_size;
		area_start = addr_aligned;
	}

	link_init(&cache->list);
	cache->start = area_start;
	cache->end = area_start + cache_size;
	cache->total = total;
	cache->free = cache->total;
	cache->struct_size = struct_size;
	cache->bitmap = bitmap;

	mutex_init(&cache->mutex);
	memset(cache->bitmap, 0, bwords*SZ_WORD);

	return cache;
}


