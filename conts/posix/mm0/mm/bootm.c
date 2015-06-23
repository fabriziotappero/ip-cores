/*
 * Boot memory allocator
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include <l4/lib/list.h>
#include <l4/lib/math.h>
#include <l4/api/thread.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include INC_GLUE(memory.h)

#include <stdio.h>

/* All memory allocated here is discarded after boot */

#define BOOTMEM_SIZE		SZ_32K

SECTION(".init.bootmem") char bootmem[BOOTMEM_SIZE];
SECTION(".stack") char stack[4096];
// SECTION("init.data")

extern unsigned long __stack[];		/* Linker defined */

static unsigned long cursor = (unsigned long)&bootmem;

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

