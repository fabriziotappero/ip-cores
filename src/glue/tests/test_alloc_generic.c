/*
 * Generic random allocation/deallocation test
 *
 * Copyright 2005 (C) Bahadir Balban
 *
 */
#include <macros.h>
#include <config.h>
#include INC_GLUE(memory.h)

#include <lib/printk.h>
#include <lib/list.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h>
#include <string.h>
#include "test_alloc_generic.h"
#include "debug.h"

void print_test_state(unsigned int title,
		      print_alloc_state_t print_allocator_state)
{
	switch (title) {
		case TEST_STATE_BEGIN:
			printf(	"=================\n"
				"===== BEGIN =====\n"
				"=================\n\n");
			break;
		case TEST_STATE_MIDDLE:
			printf(	"==================\n"
				"===== MIDDLE =====\n"
				"==================\n\n");
			break;
		case TEST_STATE_END:
			printf(	"===========\n"
				"=== END ===\n"
				"===========\n\n");
			break;
		case TEST_STATE_ERROR:
			printf( "=================\n"
				"===== ERROR =====\n"
				"=================\n\n");
			break;
		default:
			printf("Title error.\n");
	}
	print_allocator_state();
}

void get_output_filepaths(FILE **out1, FILE **out2,
			  char *alloc_func_name)
{
	char pathbuf[150];
	char *rootpath = "/tmp/";
	char *initstate_prefix = "test_initstate_";
	char *endstate_prefix = "test_endstate_";
	char *extention = ".out";

	/* File path manipulations */
	sprintf(pathbuf, "%s%s%s%s", rootpath, initstate_prefix, alloc_func_name, extention);
	*out1 = fopen(pathbuf,"w+");
	sprintf(pathbuf, "%s%s%s%s", rootpath, endstate_prefix, alloc_func_name, extention);
	*out2 = fopen(pathbuf, "w+");
	return;
}

/* This function is at the heart of generic random allocation testing.
 * It is made as simple as possible, and can be used for testing all
 * allocators. It randomly allocates/deallocates data and prints out
 * the outcome of the action. Here are a few things it does and doesn't
 * do:
 * - It does not test false input on the allocators, e.g. attempting
 *   to free an address that hasn't been allocated, or attempting to
 *   free address 0.
 * - It does capture and compare initial and final states of the
 *   allocators' internal structures after all allocations are freed.
 *   This is done by comparing two files filled with allocator state
 *   by functions supplied by the allocators themselves.
 * - It expects the allocator NOT to run out of memory.
 */
int
test_alloc_free_random_order(const int MAX_ALLOCATIONS,
			     const int ALLOC_SIZE_MAX,
			     alloc_func_t alloc,
			     free_func_t free,
			     print_alloc_state_t print_allocator_state,
			     FILE *state_init_file, FILE *state_end_file)
{
	/* The last element in full_state that tells about any full index.
	 * This is the limit the random deallocation would use to find a full
	 * index */
	int random_size;
	int random_action;
	int random_index;
	int alloc_so_far = 0;
	int full_state_last = -1;
	int halfway_through = 0;
	FILE * const default_stdout = stdout;
	/* Memory pointers */
	void *mem[MAX_ALLOCATIONS];
	/* Each element keeps track of one currently full index number */
	int full_state[MAX_ALLOCATIONS];

	memset(mem, 0, MAX_ALLOCATIONS * sizeof(void *));
	memset(full_state, 0, MAX_ALLOCATIONS * sizeof(int));

	print_test_state(TEST_STATE_BEGIN, print_allocator_state);
	stdout = state_init_file;
	print_test_state(TEST_STATE_BEGIN, print_allocator_state);
	stdout = default_stdout;

	/* Randomly either allocate/deallocate at a random
	 * index, of random size */
	srand(time(0));

	/* Constraints */
	while (1) {
		if (alloc_so_far < (MAX_ALLOCATIONS / 2)) {
			/* Give more chance to allocations at the beginning */
			if ((rand() % 4) == 0)	/* 1/4 chance */
				random_action = FREE;
			else			/* 3/4 chance */
				random_action = ALLOCATE;
		} else {
			if (!halfway_through) {
				print_test_state(TEST_STATE_MIDDLE,
						 print_allocator_state);
				halfway_through = 1;
			}
			/* Give more chane to freeing after halfway-through */
			if ((rand() % 3) == 0)  /* 1/3 chance */
				random_action = ALLOCATE;
			else			/* 2/3 chance */
				random_action = FREE;
		}
		random_size = (rand() % (ALLOC_SIZE_MAX-1)) + 1;

		if (random_action == ALLOCATE) {
			if (alloc_so_far < MAX_ALLOCATIONS) {
				alloc_so_far++;
				for (int i = 0; i < MAX_ALLOCATIONS; i++) {
					if (mem[i] == 0) {
						int allocation_error =
							((mem[i] = alloc(random_size)) <= 0);
						printf("%-12s%-8s%-12p%-8s%-10d\n",
						       "alloc:", "addr:", mem[i],
						       "size:", random_size);
						if (allocation_error) {
							print_test_state(TEST_STATE_ERROR,
									 print_allocator_state);
							if (mem[i] < 0) {
								printf("Error: alloc() returned negative value\n");
								BUG();
							} else if (mem[i] == 0) {
								printf("Error: Allocator is out of memory.\n");
								return 1;
							}
						}
						full_state_last++;
						full_state[full_state_last] = i;
						break;
					}
				}
			} else
				random_action = FREE;
		}

		if (random_action == FREE) {
			/* all are free, can't free anymore */
			if (full_state_last < 0)
				continue;
			else if (full_state_last > 0)
				random_index = rand() % full_state_last;
			else
				random_index = 0; /* Last item */

			if(mem[full_state[random_index]] == 0)
				BUG();

			free(mem[full_state[random_index]]);
			printf("%-12s%-8s%-12p\n","free:",
			       "addr:",  mem[full_state[random_index]]);
			mem[full_state[random_index]] = 0;

			/* Fill in the empty gap with last element */
			full_state[random_index] = full_state[full_state_last];
			/* Last element now in the gap
			 * (somewhere inbetween first and last) */
			full_state[full_state_last] = 0;
			/* One less in the number of full items */
			full_state_last--;
		}

		/* Check that all allocations and deallocations took place */
		if (alloc_so_far == MAX_ALLOCATIONS && full_state_last < 0)
			break;
	}

	print_test_state(TEST_STATE_END, print_allocator_state);
	stdout = state_end_file;
	print_test_state(TEST_STATE_BEGIN, print_allocator_state);
	stdout = default_stdout;
	return 0;
}

