#include <time.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <lib/list.h>
#include <lib/printk.h>
#include <generic/memcache.h>
#include "test_memcache.h"
#include "test_alloc_generic.h"
#include "debug.h"
#include "tests.h"

#include <macros.h>
#include <config.h>
#include INC_GLUE(memory.h)

unsigned int MEM_CACHE_SIZE;

struct mem_cache *this;

void *buffer;

void *mem_cache_alloc_wrapped(int size)
{
	return mem_cache_alloc(this);
}

int mem_cache_free_wrapped(void *addr)
{
	return mem_cache_free(this, addr);
}

void print_memcache_state(void)
{
	printf("%-15s%d\n","Total:", this->total);
	printf("%-15s%d\n","Free:", this->free);
	printf("Bitmap has %d words:\n", BITWISE_GETWORD(this->total) + 1);
	for (int i = 0; i <= BITWISE_GETWORD(this->total); i++)
		printf("0x%x\n", this->bitmap[i]);
}

int test_memcache_init_aligned(int *items_max, int item_size)
{
	if (item_size * 10 > MEM_CACHE_SIZE)
		MEM_CACHE_SIZE = item_size * 10;
	if (!(buffer = calloc(1, MEM_CACHE_SIZE))) {
		printf("System out of memory.\n");
		BUG();
	}
	if ((this = mem_cache_init((unsigned int)buffer,
				   MEM_CACHE_SIZE,
				   item_size, 1)) == 0) {
		printf("Unable to initialise cache.\n");
		return -1;
	}
	*items_max = mem_cache_total_free(this);
	printf("\nMEMCACHE TEST: ALIGNED ELEMENTS\n==========================\n");
	printf("%-30s%d\n", "Item size:", item_size);
	printf("%-30s0x%x\n", "Cache occupied space:", MEM_CACHE_SIZE);
	printf("%-30s%d\n","Total items in cache:", *items_max);
	printf("%-30s0x%x\n","Total items space:", (*items_max * item_size));
	return 0;
}


int test_memcache_init(int *items_max, int item_size)
{
	if (item_size * 10 > MEM_CACHE_SIZE)
		MEM_CACHE_SIZE = item_size * 10;
	printf("%s: Allocating cache memory.\n",__FUNCTION__);
	if (!(buffer = calloc(1, MEM_CACHE_SIZE))) {
		printf("System out of memory.\n");
		BUG();
	}
	if ((this = mem_cache_init((unsigned int)buffer,
				   MEM_CACHE_SIZE,
				   item_size, 0)) == 0) {
		printf("Unable to initialise cache.\n");
		return -1;
	}
	*items_max = mem_cache_total_free(this);
	printf("\nMEMCACHE TEST:\n========================\n");
	printf("%-30s%d\n", "Item size:", item_size);
	printf("%-30s0x%x\n", "Cache occupied space:", MEM_CACHE_SIZE);
	printf("%-30s%d\n","Total items in cache:", *items_max);
	printf("%-30s0x%x\n","Total items space:", (*items_max * item_size));
	return 0;
}

int test_memcache(int items_max, int item_size, FILE *init_state, FILE *exit_state, int aligned)
{
	const unsigned int TEST_CACHE_ITEM_SIZE = 5;
	MEM_CACHE_SIZE = PAGE_SIZE * 5;
	if (!item_size)
		item_size = TEST_CACHE_ITEM_SIZE;
	/* items_max value is ignored and overwritten because caches have fixed size. */
	test_memcache_init(&items_max, item_size);
	test_alloc_free_random_order(items_max, /* unused */ 2, mem_cache_alloc_wrapped,
				     mem_cache_free_wrapped, print_memcache_state,
				     init_state, exit_state);
	free(buffer);
	if (aligned) {
		test_memcache_init_aligned(&items_max, item_size);
		test_alloc_free_random_order(items_max, /* unused */ 2, mem_cache_alloc_wrapped,
					     mem_cache_free_wrapped, print_memcache_state,
					     init_state, exit_state);
	}
	free(buffer);
	return 0;
}


