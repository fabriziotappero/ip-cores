/*
 * Bitmap-based linked-listable fixed-size memory cache.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <memcache/memcache.h>
#include <string.h>
#include <stdio.h>

/* Some definitions from glue/memory.h */
#define align_up(addr, size)		((((unsigned long)addr) + (size - 1)) & (~(size - 1)))
#define SZ_WORD			sizeof(unsigned long)
#define WORD_BITS		32
#define BITWISE_GETWORD(x)	(x >> 5) /* Divide by 32 */
#define	BITWISE_GETBIT(x)	(1 << (x % WORD_BITS))

static int find_and_set_first_free_bit(u32 *word, unsigned int limit)
{
	int success = 0;
	int i;

	for(i = 0; i < limit; i++) {
		/* Find first unset bit */
		if (!(word[BITWISE_GETWORD(i)] & BITWISE_GETBIT(i))) {
			/* Set it */
			word[BITWISE_GETWORD(i)] |= BITWISE_GETBIT(i);
			success = 1;
			break;
		}
	}
	/* Return bit just set */
	if (success)
		return i;
	else
		return -1;
}

static int check_and_clear_bit(u32 *word, int bit)
{
	/* Check that bit was set */
	if (word[BITWISE_GETWORD(bit)] & BITWISE_GETBIT(bit)) {
		word[BITWISE_GETWORD(bit)] &= ~BITWISE_GETBIT(bit);
		return 0;
	} else {
		//printf("Trying to clear already clear bit\n");
		return -1;
	}
}

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
	if (cache->free > 0) {
		/* NOTE: If needed, must lock here */
		cache->free--;
		if ((bit = find_and_set_first_free_bit(cache->bitmap,
						       cache->total)) < 0) {
			printk("Error: Anomaly in cache occupied state.\n"
			       "Bitmap full although cache->free > 0\n");
			BUG();
		}
		/* NOTE: If needed, must unlock here */
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
	if (struct_addr < cache->start || struct_addr > cache->end) {
		printk("Error: This address doesn't belong to this cache.\n");
		return -1;
	}
	bit = ((struct_addr - cache->start) / cache->struct_size);

	/* Check alignment:
	 * Find out if there was a lost remainder in last division.
	 * There shouldn't have been, because addresses are allocated at
	 * struct_size offsets from cache->start. */
	if (((bit * cache->struct_size) + cache->start) != struct_addr) {
		printk("Error: This address is not aligned on a predefined "
		       "structure address in this cache.\n");
		err = -1;
		return err;
	}
	/* NOTE: If needed, must lock here */
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
	/* NOTE: If locked, must unlock here */
	return err;
}

struct mem_cache *mem_cache_init(void *start,
				 int cache_size,
				 int struct_size,
				 unsigned int aligned)
{
	struct mem_cache *cache = start;
	unsigned int area_start;
	unsigned int *bitmap;
	int bwords_in_structs;
	int bwords;
	int total;
	int bsize;

	if ((struct_size < 0) || (cache_size < 0) ||
	    ((unsigned long)start == ~(0))) {
		printk("Invalid parameters.\n");
		return 0;
	}

	/* The cache definition itself is at the beginning.
	 * Skipping it to get to start of free memory. i.e. the cache. */
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

	/* This many structures will be chucked from cache for bitmap space */
	bwords_in_structs = ((bsize) / struct_size) + 1;

	/* Total structs left after deducing bitmaps */
	total = total - bwords_in_structs;
	cache_size -= bsize;

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
		area_start = addr_aligned;
	}

	/* Now recalculate total over cache bytes left */
	total = cache_size / struct_size;

	link_init(&cache->list);
	cache->start = area_start;
	cache->end = area_start + cache_size;
	cache->total = total;
	cache->free = cache->total;
	cache->struct_size = struct_size;
	cache->bitmap = bitmap;

	/* NOTE: If needed, must initialise lock here */
	memset(cache->bitmap, 0, bwords*SZ_WORD);

	return cache;
}


