#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <stdlib.h>

#include <macros.h>
#include <config.h>
#include <generic/physmem.h>
#include <generic/kmalloc.h>
#include <generic/alloc_page.h>

#include INC_SUBARCH(mm.h)
#include INC_ARCH(linker.h)
#include INC_PLAT(printascii.h)
#include INC_PLAT(offsets.h)
#include INC_GLUE(basiclayout.h)

#include "tests.h"
#include "test_kmalloc.h"
#include "test_allocpage.h"
#include "test_memcache.h"
#include "clz.h"

unsigned int TEST_PHYSMEM_TOTAL_PAGES = 250;
unsigned int TEST_PHYSMEM_TOTAL_SIZE;

void *malloced_test_memory;
/* Allocating memory from the host C library, and
 * it is used as if it is the physical memory available
 * on the system.
 */
void alloc_test_memory()
{
	TEST_PHYSMEM_TOTAL_SIZE = (PAGE_SIZE * TEST_PHYSMEM_TOTAL_PAGES);

	if (!(malloced_test_memory = malloc(TEST_PHYSMEM_TOTAL_SIZE)))
		printf("Host system out of memory.\n");
	PHYS_MEM_START = (unsigned int)malloced_test_memory;
	PHYS_MEM_END = PHYS_MEM_START + TEST_PHYSMEM_TOTAL_SIZE;
	PHYS_MEM_START = page_align_up(PHYS_MEM_START);
	PHYS_MEM_END = page_align(PHYS_MEM_END);
	/* Normally _end is to know where the loaded kernel image
	 * ends in physical memory, so the system can start allocating
	 * physical memory from there. Because in our mock-up there's no
	 * used space in the malloc()'ed memory, _end is the same as the
	 * beginning of malloc()'ed memory.
	 */
	_end = PHYS_MEM_START;
}

struct cmdline_opts {
	char run_allocator;
	int allocations;
	int alloc_size_max;
	int physmem_pages;
	int page_size;
	int no_of_pages;
	char *finit_path;
	char *fexit_path;
} options;

void print_options(struct cmdline_opts *opts)
{
	printf("Running: %s\n",
	       ((opts->run_allocator == 'p') ? "page allocator" :
		((opts->run_allocator == 'k') ? "kmalloc/kfree" :
		 "memcache allocator")));
	printf("Total suggested allocations: %d\n", opts->allocations);
	printf("Maximum allocation size: %d, 0x%x(hex)\n\n",
	       opts->alloc_size_max, opts->alloc_size_max);
	printf("Initial state file: %s\n", opts->finit_path);
	printf("Exit state file: %s\n", opts->fexit_path);

}

void display_help(void)
{
	printf("Main:\n");
	printf("\tUsage:\n");
	printf("\tmain\t-a=<p>|<k>|<m> [-n=<number of allocations>] [-s=<maximum size for any allocation>]\n"
	       "\t\t[-fi=<file to dump init state>] [-fx=<file to dump exit state>]\n"
	       "\t\t[-ps=<page size>] [-pn=<total number of pages>]\n");
	printf("\n");
}

int get_cmdline_opts(int argc, char *argv[], struct cmdline_opts *opts)
{
	int parsed = 0;

	memset(opts, 0, sizeof (struct cmdline_opts));
	if (argc <= 1)
		return -1;
	for (int i = 1; i < argc; i++) {
		if (argv[i][0] == '-' && argv[i][2] == '=') {
			if (argv[i][1] == 'a') {
				if (argv[i][3] == 'k' ||
				    argv[i][3] == 'm' ||
				    argv[i][3] == 'p') {
					opts->run_allocator = argv[i][3];
					parsed = 1;
				}
			}
			if (argv[i][1] == 'n') {
				opts->allocations = atoi(&argv[i][3]);
				parsed = 1;
			}
			if (argv[i][1] == 's') {
				opts->alloc_size_max = atoi(&argv[i][3]);
				parsed = 1;
			}
		}
		if (argv[i][0] == '-' && argv[i][1] == 'f'
		    && argv[i][3] == '=') {
			if (argv[i][2] == 'i') {
				opts->finit_path = &argv[i][4];
				parsed = 1;
			}
			if (argv[i][2] == 'x') {
				opts->fexit_path = &argv[i][4];
				parsed = 1;
			}
		}
		if (argv[i][0] == '-' && argv[i][1] == 'p'
		    && argv[i][3] == '=') {
			if (argv[i][2] == 's') {
				opts->page_size = atoi(&argv[i][4]);
				parsed = 1;
			}
			if (argv[i][2] == 'n') {
				opts->no_of_pages = atoi(&argv[i][4]);
				parsed = 1;
			}
		}
	}

	if (!parsed)
		return -1;
	return 0;
}

void get_output_files(FILE **out1, FILE **out2,
		      char *alloc_func_name, char *rootpath)
{
	char pathbuf[150];
	char *root = "/tmp/";
	char *initstate_prefix = "test_initstate_";
	char *endstate_prefix = "test_endstate_";
	char *extention = ".out";

	if (!rootpath)
		rootpath = root;
	/* File path manipulations */
	sprintf(pathbuf, "%s%s%s%s", rootpath, initstate_prefix, alloc_func_name, extention);
	*out1 = fopen(pathbuf,"w+");
	sprintf(pathbuf, "%s%s%s%s", rootpath, endstate_prefix, alloc_func_name, extention);
	*out2 = fopen(pathbuf, "w+");
	return;
}

int main(int argc, char *argv[])
{
	FILE *finit, *fexit;
	int output_files = 0;
	if (get_cmdline_opts(argc, argv, &options) < 0) {
		display_help();
		return 1;
	}
	print_options(&options);

	if (options.finit_path && options.fexit_path) {
		finit = fopen(options.finit_path, "w+");
		fexit = fopen(options.fexit_path, "w+");
		output_files = 1;
	}
	if (options.page_size) {
		PAGE_SIZE = options.page_size;
		PAGE_MASK = PAGE_SIZE - 1;
		PAGE_BITS = 32 - __clz(PAGE_MASK);
		printf("Using: Page Size: %d\n", PAGE_SIZE);
		printf("Using: Page Mask: 0x%x\n", PAGE_MASK);
		printf("Using: Page Bits: %d\n", PAGE_BITS);
	}
	if (options.no_of_pages) {
		printf("Using: Total pages: %d\n", options.no_of_pages);
		TEST_PHYSMEM_TOTAL_PAGES = options.no_of_pages;
	}
	alloc_test_memory();
	printf("Initialising physical memory\n");
	physmem_init();
	printf("Initialising allocators:\n");
	memory_init();
	if (options.run_allocator == 'p') {
		if (!output_files)
			get_output_files(&finit, &fexit, "alloc_page", 0);
		test_allocpage(options.allocations, options.alloc_size_max,
			       finit, fexit);
	} else if (options.run_allocator == 'k') {
		if (!output_files)
			get_output_files(&finit, &fexit, "kmalloc", 0);
		test_kmalloc(options.allocations, options.alloc_size_max,
			     finit, fexit);
	} else if (options.run_allocator == 'm') {
		if (!output_files)
			get_output_files(&finit, &fexit, "memcache", 0);
		test_memcache(options.allocations, options.alloc_size_max,
			      finit, fexit, 1);
	} else {
		printf("Invalid allocator option.\n");
	}
	free((void *)malloced_test_memory);
	fclose(finit);
	fclose(fexit);
	return 0;
}

