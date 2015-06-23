/*
 * Copyright (C) 2008 Bahadir Balban
 */
#include <l4/lib/list.h>
#include <vm_area.h>
#include <malloc/malloc.h>
#include <fs.h>

/*
 * This is yet unused, it is more of an anticipation
 * of how mmaped devices would be mapped with a pager.
 */
struct mmap_device {
	struct link page_list;	/* Dyn-allocated page list */
	unsigned long pfn_start;	/* Physical pfn start */
	unsigned long pfn_end;		/* Physical pfn end */
};

struct page *memdev_page_in(struct vm_object *vm_obj,
			    unsigned long pfn_offset)
{
	struct vm_file *f = vm_object_to_file(vm_obj);
	struct mmap_device *memdev = f->vnode->inode;
	struct page *page;

	/* Check if its within device boundary */
	if (pfn_offset >= memdev->pfn_end - memdev->pfn_start)
		return PTR_ERR(-1);

	/* Simply return the page if found */
	list_foreach_struct(page, &memdev->page_list, list)
		if (page->offset == pfn_offset)
			return page;

	/* Otherwise allocate one of our own for that offset and return it */
	page = kzalloc(sizeof(struct page));
	link_init(&page->list);
	spin_lock_init(&page->lock);
	page->offset = pfn_offset;
	page->owner = vm_obj;
	list_insert(&page->list, &memdev->page_list);

	return page;
}

/* All mmapable devices are handled by this */
struct vm_pager memdev_pager = {
	.ops = {
		.page_in = memdev_page_in,
	},
};


