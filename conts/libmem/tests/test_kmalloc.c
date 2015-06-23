/*
 * Testing code for the kmalloc allocator.
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
#include <string.h>
#include <time.h>
#include "test_alloc_generic.h"
#include "test_allocpage.h"
#include "debug.h"
#include "tests.h"

extern struct link km_area_start;

void print_kmalloc_state(void)
{
	print_km_area_list(&km_area_start);
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

