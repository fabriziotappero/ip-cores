/*
 * Physical memory descriptors
 *
 * Copyright (C) 2007 - 2009 Bahadir Balban
 */
#ifndef __PAGER_PHYSMEM_H__
#define __PAGER_PHYSMEM_H__

/* A compact memory descriptor to determine used/unused pages in the system */
struct page_bitmap {
	unsigned long pfn_start;
	unsigned long pfn_end;
	unsigned int map[];
};

/* Describes a portion of physical memory. */
struct memdesc {
	unsigned int start;
	unsigned int end;
	unsigned int free_cur;
	unsigned int free_end;
	unsigned int numpages;
};

struct membank {
	unsigned long start;
	unsigned long end;
	unsigned long free;
	struct page *page_array;
};
extern struct membank membank[];

/* Describes bitmap of used/unused state for all physical pages */
extern struct memdesc physmem;

/* Sets the global page map as used/unused. Aligns input when needed. */
int set_page_map(struct page_bitmap *pmap, unsigned long start,
		 int numpages, int val);

void init_physmem_primary();
void init_physmem_secondary(struct membank *membank);

#endif /* __PAGER_PHYSMEM_H__ */
