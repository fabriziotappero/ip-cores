/*
 * Empty virtual and physical pages for
 * creating test scenarios
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/lib/addr.h>
#include INC_GLUE(memory.h)
#include <l4/generic/cap-types.h>
#include <l4lib/lib/cap.h>
#include <l4/lib/math.h>
#include <stdio.h>
#include <memory.h>
#include <linker.h>
#include <tests.h>

/*
 * Declare a statically allocated char buffer
 * with enough bitmap size to cover given size
 */
#define DECLARE_IDPOOL(name, size)	\
	char name[(sizeof(struct id_pool) + ((size >> 12) >> 3))]

struct address_pool virtual_page_pool, physical_page_pool;

#define PAGE_POOL_SIZE			SZ_16MB

DECLARE_IDPOOL(virtual_idpool, PAGE_POOL_SIZE);
DECLARE_IDPOOL(physical_idpool, PAGE_POOL_SIZE);

#define virt_to_phys(virtual)	((unsigned long)(virtual) - (unsigned long)(offset))
#define phys_to_virt(physical)	((unsigned long)(physical) + (unsigned long)(offset))


#define TEST_POOL_TOTAL		5
/*
 * Test page pool
 */
void test_page_pool(void)
{
	void *p[TEST_POOL_TOTAL], *v[TEST_POOL_TOTAL];

	/* Allocate test pages */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		v[i] = virtual_page_new(1);
		p[i] = physical_page_new(1);
		dbg_printf("Test allocated: Virtual%d: 0x%p, "
			   "Physical%d, 0x%p\n",
			   i, v[i], i, p[i]);
	}

	/* Free test pages */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		virtual_page_free(v[i], 1);
		physical_page_free(p[i], 1);
	}

	/* Re-allocate test pages */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		v[i] = virtual_page_new(1);
		p[i] = physical_page_new(1);
		dbg_printf("Test allocated: Virtual%d: 0x%p, "
			   "Physical%d, 0x%p\n",
			   i, v[i], i, p[i]);
	}

	/* Free test pages */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		virtual_page_free(v[i], 1);
		physical_page_free(p[i], 1);
	}

	/* Allocate in different lengths */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		v[i] = virtual_page_new(i);
		p[i] = physical_page_new(i);
		dbg_printf("Test allocated: Virtual%d: 0x%p, "
			   "Physical%d, 0x%p\n",
			   i, v[i], i, p[i]);
	}

	/* Free test pages in different order */
	for (int i = TEST_POOL_TOTAL - 1; i >= 0; i--) {
		virtual_page_free(v[i], 1);
		physical_page_free(p[i], 1);
	}

	/* Allocate in different lengths */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		v[i] = virtual_page_new(i);
		p[i] = physical_page_new(i);
		dbg_printf("Test allocated: Virtual%d: 0x%p, "
			   "Physical%d, 0x%p\n",
			   i, v[i], i, p[i]);
	}

	/* Free test pages in normal order */
	for (int i = 0; i < TEST_POOL_TOTAL; i++) {
		virtual_page_free(v[i], 1);
		physical_page_free(p[i], 1);
	}
}

void page_pool_init(void)
{
	struct capability *physcap, *virtcap;
	unsigned long phys_start, phys_end;
	unsigned long virt_start, virt_end;

	/*
	 * Get physmem capability (Must be only one)
	 */
	if (!(physcap = cap_get_physmem(CAP_TYPE_MAP_PHYSMEM))) {
		printf("FATAL: Could not find a physical memory"
		       "capability to use as a page pool.\n");
		BUG();
	}

	/*
	 * Get virtmem capability (Must be only one)
	 */
	if (!(virtcap = cap_get_by_type(CAP_TYPE_MAP_VIRTMEM))) {
		printf("FATAL: Could not find a virtual memory"
		       "capability to use as a page pool.\n");
		BUG();
	}

	/*
	 * Now initialize physical and virtual page marks
	 * from unused pages. Linker script will help us
	 * on this.
	 */
	/*
	printf("__data_start symbol: %lx\n", (unsigned long)__data_start);
	printf("__data_end symbol: %lx\n", (unsigned long)__data_end);
	printf("__bss_start symbol: %lx\n", (unsigned long)__bss_start);
	printf("__bss_end symbol: %lx\n", (unsigned long)__bss_end);
	printf("__stack_start symbol: %lx\n", (unsigned long)__stack_start);
	printf("__stack_end symbol: %lx\n", (unsigned long)__stack_end);
	printf("__end symbol: %lx\n", (unsigned long)__end);
	*/

	phys_start = page_align_up(virt_to_phys(__end) +
				   (unsigned long)lma_start);
	phys_end = __pfn_to_addr(physcap->end);

	dbg_printf("%s: Initializing physical range 0x%lx - 0x%lx\n",
		   __FUNCTION__, phys_start, phys_end);

	virt_start = page_align_up(__end) + (unsigned long)lma_start;
	virt_end = __pfn_to_addr(virtcap->end);

	dbg_printf("%s: Initializing virtual range 0x%lx - 0x%lx\n",
		   __FUNCTION__, virt_start, virt_end);

	/* Initialize pools, maximum of PAGE_POOL_SIZE size */
	address_pool_init(&virtual_page_pool,
			  (struct id_pool *)&virtual_idpool,
			  virt_start, min(virt_end,
				  	  virt_start + PAGE_POOL_SIZE));
	address_pool_init(&physical_page_pool,
			  (struct id_pool *)&physical_idpool,
			  phys_start, min(phys_end,
				  	  phys_start + PAGE_POOL_SIZE));

	// test_page_pool();
}

/*
 * Some tests require page-faulting virtual addresses or
 * differing virtual addresses that map onto the same
 * physical page. These functions provide these pages.
 */

void *virtual_page_new(int npages)
{
	return address_new(&virtual_page_pool, npages, PAGE_SIZE);
}

void *physical_page_new(int npages)
{
	return address_new(&physical_page_pool, npages, PAGE_SIZE);
}

void virtual_page_free(void *address, int npages)
{
	address_del(&virtual_page_pool, address,
		    npages, PAGE_SIZE);
}

void physical_page_free(void *address, int npages)
{
	address_del(&physical_page_pool, address,
		    npages, PAGE_SIZE);
}

