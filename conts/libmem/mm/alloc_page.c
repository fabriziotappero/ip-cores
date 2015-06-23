/*
 * A proof-of-concept linked-list based page allocator.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <stdio.h>
#include <string.h>
#include <l4/config.h>
#include <l4/macros.h>
#include <l4/types.h>
#include <l4/lib/list.h>
#include "alloc_page.h"
#include INC_GLUE(memory.h)
#include INC_SUBARCH(mm.h)
#include INC_GLUE(memlayout.h)
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)

struct page_allocator allocator;

/*
 * Allocate a new page area from the page area cache
 */
static struct page_area *new_page_area(struct page_allocator *p)
{
	struct mem_cache *cache;
	struct page_area *new_area;

	list_foreach_struct(cache, &p->pga_cache_list, list) {
		if ((new_area = mem_cache_alloc(cache)) != 0) {
			new_area->cache = cache;
			p->pga_free--;
			return new_area;
		}
	}
	return 0;
}

/* Given the page @quantity, finds a free region, divides and returns new area. */
static struct page_area *
get_free_page_area(int quantity, struct page_allocator *p)
{
	struct page_area *new, *area;

	if (quantity <= 0)
		return 0;

	list_foreach_struct(area, &p->page_area_list, list) {

		/* Check for exact size match */
		if (area->numpages == quantity && !area->used) {
			area->used = 1;
			return area;
		}

		/* Divide a bigger area */
		if (area->numpages > quantity && !area->used) {
			new = new_page_area(p);
			area->numpages -= quantity;
			new->pfn = area->pfn + area->numpages;
			new->numpages = quantity;
			new->used = 1;
			link_init(&new->list);
			list_insert(&new->list, &area->list);
			return new;
		}
	}

	/* No more pages */
	return 0;
}


/*
 * All physical memory is tracked by a simple linked list implementation. A
 * single list contains both used and free page_area descriptors. Each page_area
 * describes a continuous region of physical pages, indicating its location by
 * it's pfn.
 *
 * alloc_page() keeps track of all page-granuled memory, except the bits that
 * were in use before the allocator initialised. This covers anything that is
 * outside the @start @end range. This includes the page tables, first caches
 * allocated by this function, compile-time allocated kernel data and text.
 * Also other memory regions like IO are not tracked by alloc_page() but by
 * other means.
 */

void init_page_allocator(unsigned long start, unsigned long end)
{
	/* Initialise a page area cache in the first page */
	struct page_area *freemem, *area;
	struct mem_cache *cache;

	link_init(&allocator.page_area_list);
	link_init(&allocator.pga_cache_list);

	/* Initialise the first page area cache */
	cache = mem_cache_init(phys_to_virt((void *)start), PAGE_SIZE,
			       sizeof(struct page_area), 0);
	list_insert(&cache->list, &allocator.pga_cache_list);

	/* Initialise the first area that describes the page just allocated */
	area = mem_cache_alloc(cache);
	link_init(&area->list);
	area->pfn = __pfn(start);
	area->used = 1;
	area->numpages = 1;
	area->cache = cache;
	list_insert(&area->list, &allocator.page_area_list);

	/* Update freemem start address */
	start += PAGE_SIZE;

	/* Initialise first area that describes all of free physical memory */
	freemem = mem_cache_alloc(cache);
	link_init(&freemem->list);
	freemem->pfn = __pfn(start);
	freemem->numpages = __pfn(end) - freemem->pfn;
	freemem->cache = cache;
	freemem->used = 0;

	/* Add it as the first unused page area */
	list_insert(&freemem->list, &allocator.page_area_list);

	/* Initialise free page area counter */
	allocator.pga_free = mem_cache_total_empty(cache);
}

/*
 * Check if we're about to run out of free page area structures.
 * If so, allocate a new cache of page areas.
 */
int check_page_areas(struct page_allocator *p)
{
	struct page_area *new;
	struct mem_cache *newcache;

	/* If only one free area left */
	if (p->pga_free == 1) {

		/* Use that area to allocate a new page */
		if (!(new = get_free_page_area(1, p)))
			return -1;	/* Out of memory */

		/* Free page areas must now be reduced to 0 */
		BUG_ON(p->pga_free != 0);

		/* Initialise it as a new source of page area structures */
		newcache = mem_cache_init(phys_to_virt((void *)__pfn_to_addr(new->pfn)),
					  PAGE_SIZE, sizeof(struct page_area), 0);

		/*
		 * Update the free page area counter
		 * NOTE: need to lock the allocator here
		 */
		p->pga_free += mem_cache_total_empty(newcache);

		/*
		 * Add the new cache to available
		 * list of free page area caches
		 */
		list_insert(&newcache->list, &p->pga_cache_list);
		/* Unlock here */
	}
	return 0;
}

void *alloc_page(int quantity)
{
	struct page_area *new;

	/*
	 * First make sure we have enough page
	 * area structures in the cache
	 */
	if (check_page_areas(&allocator) < 0)
		return 0; /* Out of memory */

	/*
	 * Now allocate the actual pages, using the available
	 * page area structures to describe the allocation
	 */
	new = get_free_page_area(quantity, &allocator);

	/* Return physical address */
	return (void *)__pfn_to_addr(new->pfn);
}


/* Merges two page areas, frees area cache if empty, returns the merged area. */
struct page_area *merge_free_areas(struct page_area *before,
				   struct page_area *after)
{
	struct mem_cache *c;

	BUG_ON(before->pfn + before->numpages != after->pfn);
	BUG_ON(before->used || after->used)
	BUG_ON(before == after);

	before->numpages += after->numpages;
	list_remove(&after->list);
	c = after->cache;
	mem_cache_free(c, after);

	/* Recursively free the cache page */
	if (mem_cache_is_empty(c)) {
		list_remove(&c->list);
		if (free_page(virt_to_phys(c)) < 0) {
			printf("Page ptr: 0x%lx, virt_to_phys = 0x%lx\n"
			       "Page not found in cache.\n",
			       (unsigned long)c, (unsigned long)virt_to_phys(c));
			BUG();
		}
	}
	return before;
}

static int find_and_free_page_area(void *addr, struct page_allocator *p)
{
	struct page_area *area, *prev, *next;

	/* First find the page area to be freed. */
	list_foreach_struct(area, &p->page_area_list, list)
		if (__pfn_to_addr(area->pfn) == (unsigned long)addr &&
		    area->used) {	/* Found it */
			area->used = 0;
			goto found;
		}
	return -1; /* Finished the loop, but area not found. */

found:
	/* Now merge with adjacent areas, if possible */
	if (area->list.prev != &p->page_area_list) {
		prev = link_to_struct(area->list.prev, struct page_area, list);
		if (!prev->used)
			area = merge_free_areas(prev, area);
	}
	if (area->list.next != &p->page_area_list) {
		next = link_to_struct(area->list.next, struct page_area, list);
		if (!next->used)
			area = merge_free_areas(area, next);
	}
	return 0;
}

int free_page(void *paddr)
{
	return find_and_free_page_area(paddr, &allocator);
}

