#ifndef __TESTS_H__
#define __TESTS_H__

/* Mock-up physical memory */
extern unsigned int TEST_PHYSMEM_TOTAL_PAGES;
extern unsigned int TEST_PHYSMEM_TOTAL_SIZE;

/* Allocator test */
extern unsigned int PAGE_ALLOCATIONS;
extern unsigned int PAGE_ALLOC_SIZE_MAX;

/* Memcache test */
extern unsigned int MEMCACHE_ALLOCS_MAX;
extern unsigned int TEST_CACHE_ITEM_SIZE;

/* Kmalloc */
extern unsigned int KMALLOC_ALLOCATIONS;
extern unsigned int KMALLOC_ALLOC_SIZE_MAX;


#endif /* __TESTS_H__ */
