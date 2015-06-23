/*
 * Copyright (C) 2008 Bahadir Balban
 */
#include <l4/macros.h>
#include <l4/lib/list.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include <malloc/malloc.h>
#include <mm/alloc_page.h>
#include <vm_area.h>
#include <string.h>
#include <globals.h>
#include <file.h>
#include <init.h>
#include <l4/api/errno.h>
#include <fs.h>

struct page *page_init(struct page *page)
{
	/* Reset page */
	memset(page, 0, sizeof(*page));
	page->refcnt = -1;
	spin_lock_init(&page->lock);
	link_init(&page->list);

	return page;
}

struct page *find_page(struct vm_object *obj, unsigned long pfn)
{
	struct page *p;

	list_foreach_struct(p, &obj->page_cache, list)
		if (p->offset == pfn)
			return p;

	return 0;
}

/*
 * Deletes all pages in a page cache, assumes pages are from the
 * page allocator, and page structs are from the page_array, which
 * is the default situation.
 */
int default_release_pages(struct vm_object *vm_obj)
{
	struct page *p, *n;

	list_foreach_removable_struct(p, n, &vm_obj->page_cache, list) {
		list_remove_init(&p->list);
		BUG_ON(p->refcnt);

		/* Reinitialise the page */
		page_init(p);

		/* Return page back to allocator */
		free_page((void *)page_to_phys(p));

		/* Reduce object page count */
		BUG_ON(--vm_obj->npages < 0);
	}
	return 0;
}

int file_page_out(struct vm_object *vm_obj, unsigned long page_offset)
{
	struct vm_file *f = vm_object_to_file(vm_obj);
	struct page *page;
	void *paddr;
	int err;

	/* Check first if the file has such a page at all */
	if (__pfn(page_align_up(f->length) <= page_offset)) {
		printf("%s: %s: Trying to look up page %lu, but file length "
		       "is %lu bytes.\n", __TASKNAME__, __FUNCTION__,
		       page_offset, f->length);
		BUG();
	}

	/* If the page is not in the page cache, simply return. */
	if (!(page = find_page(vm_obj, page_offset)))
		return 0;

	/* If the page is not dirty, simply return */
	if (!(page->flags & VM_DIRTY))
		return 0;

	paddr = (void *)page_to_phys(page);

	//printf("%s/%s: Writing to vnode %lu, at pgoff 0x%lu, %d pages, buf at %p\n",
	//	__TASKNAME__, __FUNCTION__, f->vnode->vnum, page_offset, 1, vaddr);

	/* Syscall to vfs to write page back to file. */
	if ((err = vfs_write(f->vnode, page_offset, 1,
			     phys_to_virt(paddr))) < 0)
		return err;

	/* Clear dirty flag */
	page->flags &= ~VM_DIRTY;

	return 0;
}

struct page *file_page_in(struct vm_object *vm_obj, unsigned long page_offset)
{
	struct vm_file *f = vm_object_to_file(vm_obj);
	struct page *page;
	void *paddr;
	int err;

	/* Check first if the file has such a page at all */
	if (__pfn(page_align_up(f->length) <= page_offset)) {
		printf("%s: %s: Trying to look up page %lu, but file length "
		       "is %lu bytes.\n", __TASKNAME__, __FUNCTION__,
		       page_offset, f->length);
		BUG();
	}

	/* Call vfs only if the page is not resident in page cache. */
	if (!(page = find_page(vm_obj, page_offset))) {
		/* Allocate a new page */
		paddr = alloc_page(1);
		page = phys_to_page(paddr);

		/* Call to vfs to read into the page. */
		if ((err = vfs_read(f->vnode, page_offset,
				    1, phys_to_virt(paddr))) < 0) {

			free_page(paddr);
			return PTR_ERR(err);
		}

	//	printf("%s/%s: Reading into vnode %lu, at pgoff 0x%lu, %d pages, buf at %p\n",
	//	       __TASKNAME__, __FUNCTION__, f->vnode->vnum, page_offset, 1, vaddr);

		/* Update vm object details */
		vm_obj->npages++;

		/* Update page details */
		page_init(page);
		page->refcnt++;
		page->owner = vm_obj;
		page->offset = page_offset;
		page->virtual = 0;

		/* Add the page to owner's list of in-memory pages */
		BUG_ON(!list_empty(&page->list));
		insert_page_olist(page, vm_obj);
	}

	return page;
}

/*
 * All non-mmapable char devices are handled by this.
 * VFS calls those devices to read their pages
 */
struct vm_pager file_pager = {
	.ops = {
		.page_in = file_page_in,
		.page_out = file_page_out,
		.release_pages = default_release_pages,
	},
};


/* A proposal for shadow vma container, could be part of vm_file->priv_data */
struct vm_swap_node {
	struct vm_file *swap_file;
	struct task_ids task_ids;
	struct address_pool *pool;
};

/*
 * This should save swap_node/page information either in the pte or in a global
 * list of swap descriptors, and then write the page into the possibly one and
 * only swap file.
 */
struct page *swap_page_in(struct vm_object *vm_obj, unsigned long file_offset)
{
	struct page *p;

	/* No swapping yet, so the page is either here or not here. */
	if (!(p = find_page(vm_obj, file_offset)))
		return PTR_ERR(-EINVAL);
	else
		return p;
}

struct vm_pager swap_pager = {
	.ops = {
		.page_in = swap_page_in,
		.release_pages = default_release_pages,
	},
};

/*
 * Just releases the page structures since the actual pages are
 * already in memory as read-only.
 */
int bootfile_release_pages(struct vm_object *vm_obj)
{
	struct page *p, *n;

	list_foreach_removable_struct(p, n, &vm_obj->page_cache, list) {
		list_remove(&p->list);
		BUG_ON(p->refcnt);

		/* Reinitialise the page */
		page_init(p);

		/*
		 * We don't free the page because it doesn't
		 * come from the page allocator
		 */
		// free_page((void *)page_to_phys(p));


		/* Reduce object page count */
		BUG_ON(--vm_obj->npages < 0);
	}
	return 0;
}

#if 0
/* Returns the page with given offset in this vm_object */
struct page *bootfile_page_in(struct vm_object *vm_obj,
			      unsigned long offset)
{
	struct vm_file *boot_file = vm_object_to_file(vm_obj);
	struct svc_image *img = boot_file->priv_data;
	struct page *page;

	/* Check first if the file has such a page at all */
	if (__pfn(page_align_up(boot_file->length) <= offset)) {
		printf("%s: %s: Trying to look up page %lu, but file length "
		       "is %lu bytes.\n", __TASKNAME__, __FUNCTION__,
		       offset, boot_file->length);
		BUG();
	}

	/* The page is not resident in page cache. */
	if (!(page = find_page(vm_obj, offset))) {
		page = phys_to_page(img->phys_start + __pfn_to_addr(offset));

		/* Update page */
		page_init(page);
		page->refcnt++;
		page->owner = vm_obj;
		page->offset = offset;

		/* Update object */
		vm_obj->npages++;

		/* Add the page to owner's list of in-memory pages */
		BUG_ON(!list_empty(&page->list));
		insert_page_olist(page, vm_obj);
	}

	return page;
}

struct vm_pager bootfile_pager = {
	.ops = {
		.page_in = bootfile_page_in,
		.release_pages = bootfile_release_pages,
	},
};

void bootfile_destroy_priv_data(struct vm_file *bootfile)
{

}

/* From bare boot images, create mappable device files */
int init_boot_files(struct initdata *initdata)
{
	struct bootdesc *bd = initdata->bootdesc;
	struct vm_file *boot_file;
	struct svc_image *img;

	link_init(&initdata->boot_file_list);

	for (int i = 0; i < bd->total_images; i++) {
		img = &bd->images[i];
		boot_file = vm_file_create();

		/* Allocate private data */
		boot_file->priv_data = kzalloc(sizeof(*img));
		memcpy(boot_file->priv_data, img, sizeof(*img));

		boot_file->length = img->phys_end - img->phys_start;
		boot_file->type = VM_FILE_BOOTFILE;
		boot_file->destroy_priv_data =
			bootfile_destroy_priv_data;

		/* Initialise the vm object */
		boot_file->vm_obj.flags = VM_OBJ_FILE;
		boot_file->vm_obj.pager = &bootfile_pager;

		/* Add the file to initdata's bootfile list */
		list_insert_tail(&boot_file->list, &initdata->boot_file_list);
	}

	return 0;
}
#endif

/*
 * FIXME:
 * Problem is that devzero is a character device and we don't have a
 * character device subsystem yet.
 *
 * Therefore even though the vm_file for devzero requires a vnode,
 * currently it has no vnode field, and the information (the zero page)
 * that needs to be stored in the dynamic vnode is now stored in the
 * field file_private_data in the vm_file, which really needs to be
 * removed.
 */

/* Returns the page with given offset in this vm_object */
struct page *devzero_page_in(struct vm_object *vm_obj,
			     unsigned long page_offset)
{
	struct vm_file *devzero = vm_object_to_file(vm_obj);
	struct page *zpage = devzero->private_file_data;

	BUG_ON(!(devzero->type & VM_FILE_DEVZERO));

	/* Update zero page struct. */
	spin_lock(&zpage->lock);
	BUG_ON(zpage->refcnt < 0);
	zpage->refcnt++;
	spin_unlock(&zpage->lock);

	return zpage;
}

struct vm_pager devzero_pager = {
	.ops = {
		.page_in = devzero_page_in,
	},
};

struct vm_file *get_devzero(void)
{
	struct vm_file *f;

	list_foreach_struct(f, &global_vm_files.list, list)
		if (f->type == VM_FILE_DEVZERO)
			return f;
	return 0;
}

int init_devzero(void)
{
	void *zphys, *zvirt;
	struct page *zpage;
	struct vm_file *devzero;

	/* Allocate and initialise the zero page */
	zphys = alloc_page(1);
	zpage = phys_to_page(zphys);
	zvirt = (void *)phys_to_virt(zphys);
	memset(zvirt, 0, PAGE_SIZE);

	/*
	 * FIXME:
	 * Flush the dcache if virtual data cache
	 */

	/* Allocate and initialise devzero file */
	devzero = vm_file_create();
	devzero->type = VM_FILE_DEVZERO;
	devzero->private_file_data = zpage;
	devzero->length = page_align(~0UL); /* So we dont wraparound to 0! */
	devzero->vm_obj.npages = __pfn(devzero->length);
	devzero->vm_obj.pager = &devzero_pager;
	devzero->vm_obj.flags = VM_OBJ_FILE;

	/* Initialise zpage */
	zpage->refcnt++;
	zpage->owner = &devzero->vm_obj;

	global_add_vm_file(devzero);
	return 0;
}

