#include <macros.h>
#include <config.h>
#include INC_GLUE(memory.h)

#include <lib/printk.h>
#include <lib/list.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "test_allocpage.h"
#include "test_alloc_generic.h"
#include "debug.h"

unsigned int PAGE_ALLOCATIONS =	30;
unsigned int PAGE_ALLOC_SIZE_MAX = 8;

extern struct page_area *areas;
extern struct mem_cache *primary_cache;

extern struct mem_cache *secondary_cache;
extern struct mem_cache *spare_cache;

void print_page_area(struct page_area *ar, int areano)
{
	printf("Area starts @: 0x%x, %s, numpages: %d\n",
	       ar->index << PAGE_BITS,
	       (ar->used) ? "used" : "unused", ar->numpages);
	return;
}

void print_areas(struct page_area *ar)
{
	struct page_area *cur = ar;
	int areano = 1;
	printf("Page areas:\n-------------\n");

	if (!ar) {
		printf("None.\n");
		return;
	}
	print_page_area(cur, areano++);
	list_foreach_struct(cur, &ar->list, list) {
		print_page_area(cur, areano++);
	}
	return;
}

void print_cache(struct mem_cache *c, int cacheno)
{
	printf("Cache %d state:\n-------------\n", cacheno);
	printf("Total: %d\n", c->total);
	printf("Free: %d\n", c->free);
	printf("Start: 0x%x\n", c->start);
	return;
}

void print_caches(struct mem_cache *c)
{
	int caches = 1;
	struct mem_cache *cur = c;
	if (!c) {
		printf("None.\n");
		return;
	}
	print_cache(cur, caches++);
	list_foreach_struct(cur, &c->list, list) {
		print_cache(cur, caches++);
	}
	return;
}

void print_page_allocator_state(void)
{
	print_areas(areas);
	printf("PRIMARY:\n--------\n");
	print_caches(primary_cache);
	printf("SECONDARY:\n----------\n");
	print_caches(secondary_cache);
}

/* FIXME: with current default parameters (allocations = 30, sizemax = 8),
 * for some odd reason, we got the bug at line 280 in alloc_page.c.
 * Very weird. Find out why.
 */
void test_allocpage(int page_allocations, int page_alloc_size_max,
		    FILE *init_state, FILE *exit_state)
{
	if (!page_allocations)
		page_allocations = PAGE_ALLOCATIONS;
	if (!page_alloc_size_max)
		page_alloc_size_max = PAGE_ALLOC_SIZE_MAX;

	printf("\nPAGE ALLOCATOR TEST:====================================\n\n");
	test_alloc_free_random_order(page_allocations, page_alloc_size_max,
				     alloc_page, free_page,
				     print_page_allocator_state,
				     init_state, exit_state);
}
