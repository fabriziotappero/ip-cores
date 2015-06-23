#include <macros.h>
#include <config.h>
#include <lib/list.h>
#include <lib/printk.h>
#include INC_GLUE(memory.h)
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <time.h>
#include "test_alloc_generic.h"
#include "test_allocpage.h"
#include "debug.h"
#include "tests.h"


extern struct subpage_area *km_areas;
extern struct page_area *areas;

void print_kmalloc_state(void)
{
	print_subpage_area_list(km_areas);
}

void test_kmalloc(int kmalloc_allocations, int kmalloc_alloc_size_max,
		  FILE *init_state, FILE *exit_state)
{
	unsigned int KMALLOC_ALLOCATIONS = 20;
	unsigned int KMALLOC_ALLOC_SIZE_MAX = (PAGE_SIZE * 3);

	if (!kmalloc_allocations)
		kmalloc_allocations = KMALLOC_ALLOCATIONS;
	if (!kmalloc_alloc_size_max)
		kmalloc_alloc_size_max = KMALLOC_ALLOC_SIZE_MAX;

	test_alloc_free_random_order(kmalloc_allocations, kmalloc_alloc_size_max,
				     kmalloc, kfree, print_kmalloc_state,
				     init_state, exit_state);
}

