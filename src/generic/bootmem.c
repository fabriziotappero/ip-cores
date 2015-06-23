/*
 * Boot memory allocator
 *
 * Copyright (C) 2009 Bahadir Balban
 */


#include INC_ARCH(linker.h)
#include INC_GLUE(memory.h)
#include <l4/lib/printk.h>
#include <l4/generic/space.h>

/*
 * All memory allocated here is discarded after boot.
 * Increase this size if bootmem allocations fail.
 */
#define BOOTMEM_SIZE		(SZ_4K * 4)
SECTION(".init.bootmem") char bootmem[BOOTMEM_SIZE];
struct address_space init_space;

static unsigned long cursor = (unsigned long)&bootmem;

unsigned long bootmem_free_pages(void)
{
	return BOOTMEM_SIZE - (page_align_up(cursor) - (unsigned long)&bootmem);
}

void *alloc_bootmem(int size, int alignment)
{
	void *ptr;

	/* If alignment is required */
	if (alignment) {
		/* And cursor is not aligned */
		if (!is_aligned(cursor, alignment))
			/* Align the cursor to alignment */
			cursor = align_up(cursor, alignment);
	/* Align to 4 byte by default */
	} else if (size >= 4) {
		/* And cursor is not aligned */
		if (!is_aligned(cursor, 4))
			/* Align the cursor to alignment */
			cursor = align_up(cursor, 4);
	}

	/* Allocate from cursor */
	ptr = (void *)cursor;

	/* Update cursor */
	cursor += size;

	/* Check if cursor is passed bootmem area */
	if (cursor >= (unsigned long)&bootmem[BOOTMEM_SIZE]) {
		printk("Fatal: Insufficient boot memory.\n");
		BUG();
	}

	return ptr;
}

pmd_table_t *alloc_boot_pmd(void)
{
	return alloc_bootmem(sizeof(pmd_table_t), sizeof(pmd_table_t));
}

