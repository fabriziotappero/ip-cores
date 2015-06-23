/*
 * Testing code for the page allocator.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include <l4/lib/list.h>
#include INC_GLUE(memory.h)
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "test_allocpage.h"
#include "test_alloc_generic.h"
#include "debug.h"

unsigned int PAGE_ALLOCATIONS =	30;
unsigned int PAGE_ALLOC_SIZE_MAX = 8;

extern struct page_allocator allocator;

void print_page_area(struct page_area *a, int areano)
{
	printf("Area starts @: 0x%lu, %s, numpages: %d\n",
	       __pfn_to_addr(a->pfn),
	       (a->used) ? "used" : "unused", a->numpages);
	return;
}

void print_areas(struct link *area_head)
{
	struct page_area *cur;
	int areano = 1;

	printf("Page areas:\n-------------\n");
	list_foreach_struct(cur, area_head, list)
		print_page_area(cur, areano++);
}

void print_cache(struct mem_cache *c, int cacheno)
{
	printf("Cache %d state:\n-------------\n", cacheno);
	printf("Total: %d\n", c->total);
	printf("Free: %d\n", c->free);
	printf("Start: 0x%x\n", c->start);
}

void print_caches(struct link *cache_head)
{
	int caches = 1;
	struct mem_cache *cur;

	list_foreach_struct(cur, cache_head, list)
		print_cache(cur, caches++);
}

void print_page_allocator_state(void)
{
	print_areas(&allocator.page_area_list);
	printf("Data Cache:\n--------\n");
	print_caches(&allocator.dcache_list);
	printf("Cache Cache:\n----------\n");
	print_caches(&allocator.ccache_list);
}

/* FIXME: with current default parameters (allocations = 30, sizemax = 8),
 * for some odd reason, we got the bug at line 280 in alloc_page.c.
 * Very weird. Find out why.
 */
void test_allocpage(int page_allocations, int page_alloc_size_max,
		    FILE *init_state, FILE *exit_state)
{
	//if (!page_allocations)
	//	page_allocations = PAGE_ALLOCATIONS;
	//if (!page_alloc_size_max)
	//	page_alloc_size_max = PAGE_ALLOC_SIZE_MAX;

	dprintf("\nPAGE ALLOCATOR TEST:====================================\n\n");
	test_alloc_free_random_order(page_allocations, page_alloc_size_max,
				     alloc_page, free_page,
				     print_page_allocator_state,
				     init_state, exit_state);
}
