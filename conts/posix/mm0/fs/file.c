/*
 * File content tracking.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <fs.h>
#include <file.h>
#include <l4/lib/list.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include <stdio.h>

/*
 * This reads contents of a file in pages, calling the fs-specific file read function to read-in
 * those pages' contents.
 *
 * Normally this is ought to be called by mm0 when a file's pages cannot be found in the page
 * cache.
 */
int generic_file_read(struct vnode *v, unsigned long pfn, unsigned long npages, void *page_buf)
{
	BUG_ON(!is_page_aligned(page_buf));

	return v->fops.read(v, pfn, npages, page_buf);
}
