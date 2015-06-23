/*
 * munmap() for unmapping a portion of an address space.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <mmap.h>
#include <file.h>
#include <l4/api/errno.h>
#include <l4/lib/math.h>
#include L4LIB_INC_ARCH(syslib.h)
#include <vm_area.h>
#include <malloc/malloc.h>

/* This splits a vma, splitter region must be in the *middle* of original vma */
int vma_split(struct vm_area *vma, struct tcb *task,
	      const unsigned long pfn_start, const unsigned long pfn_end)
{
	struct vm_area *new;
	unsigned long unmap_start = pfn_start, unmap_end = pfn_end;
	int err;

	/* Allocate an uninitialised vma first */
	if (!(new = vma_new(0, 0, 0, 0)))
		return -ENOMEM;

	/*
	 * Some sanity checks to show that splitter range does end up
	 * producing two smaller vmas.
	 */
	BUG_ON(vma->pfn_start >= pfn_start || vma->pfn_end <= pfn_end);

	/* Update new and original vmas */
	new->pfn_end = vma->pfn_end;
	new->pfn_start = pfn_end;
	new->file_offset = vma->file_offset + new->pfn_start - vma->pfn_start;
	vma->pfn_end = pfn_start;
	new->flags = vma->flags;

	/*
	 * Copy the object links of original vma to new vma. A split like this
	 * increases the map count of mapped object(s) since now 2 vmas on the
	 * same task maps the same object(s).
	 */
	vma_copy_links(new, vma);

	/* Add new one next to original vma */
	list_insert_tail(&new->list, &vma->list);

	/* Unmap the removed portion */
	BUG_ON((err = l4_unmap((void *)__pfn_to_addr(unmap_start),
	       unmap_end - unmap_start, task->tid)) < 0);

	return 0;
}

/* This shrinks the vma from *one* end only, either start or end */
int vma_shrink(struct vm_area *vma, struct tcb *task,
	       const unsigned long pfn_start, const unsigned long pfn_end)
{
	unsigned long diff, unmap_start, unmap_end;
	int err;

	/* Shrink from the end */
	if (vma->pfn_start < pfn_start) {
		BUG_ON(pfn_start >= vma->pfn_end);
		unmap_start = pfn_start;
		unmap_end = vma->pfn_end;
		vma->pfn_end = pfn_start;

	/* Shrink from the beginning */
	} else if (vma->pfn_end > pfn_end) {
		BUG_ON(pfn_end <= vma->pfn_start);
		unmap_start = vma->pfn_start;
		unmap_end = pfn_end;
		diff = pfn_end - vma->pfn_start;
		vma->file_offset += diff;
		vma->pfn_start = pfn_end;
	} else
		BUG();

	/* Unmap the shrinked portion */
	BUG_ON((err = l4_unmap((void *)__pfn_to_addr(unmap_start),
	       unmap_end - unmap_start, task->tid)) < 0);

	return 0;
}

/* Destroys a single vma from a task and unmaps its range from task space */
int vma_destroy_single(struct tcb *task, struct vm_area *vma)
{
	int ret;

	/* Release all object links */
	if ((ret = vma_drop_merge_delete_all(vma)) < 0)
		return ret;

	/*
	 * Unmap the whole vma address range. Note that this
	 * may return -1 if the area was already faulted, which
	 * means the area was unmapped before being touched.
	 */
	l4_unmap((void *)__pfn_to_addr(vma->pfn_start),
		 vma->pfn_end - vma->pfn_start, task->tid);

	/* Unlink and delete vma */
	list_remove(&vma->list);
	kfree(vma);

	return 0;
}

/*
 * Unmaps the given region from a vma. Depending on the region and vma range,
 * this may result in either shrinking, splitting or destruction of the vma.
 */
int vma_unmap(struct vm_area *vma, struct tcb *task,
	      const unsigned long pfn_start, const unsigned long pfn_end)
{
	// printf("Unmapping vma. Tid: %d, 0x%x-0x%x\n",task->tid, __pfn_to_addr(pfn_start), __pfn_to_addr(pfn_end));

	/* Split needed? */
	if (vma->pfn_start < pfn_start && vma->pfn_end > pfn_end)
		return vma_split(vma, task, pfn_start, pfn_end);
	/* Shrink needed? */
	else if (((vma->pfn_start >= pfn_start) && (vma->pfn_end > pfn_end))
	    	   || ((vma->pfn_start < pfn_start) && (vma->pfn_end <= pfn_end)))
		return vma_shrink(vma, task, pfn_start, pfn_end);
	/* Destroy needed? */
	else if ((vma->pfn_start >= pfn_start) && (vma->pfn_end <= pfn_end))
		return vma_destroy_single(task, vma);
	else
		BUG();

	return 0;
}

/* Checks vma and vm_object type and flushes its pages accordingly */
int vma_flush_pages(struct vm_area *vma)
{
	struct vm_object *vmo;
	struct vm_obj_link *vmo_link;
	int err;

	/* Read-only vmas need not flush objects */
	if (!(vma->flags & VM_WRITE))
		return 0;

	/*
	 * We just check the first object under the vma, since there
	 * could only be a single VM_SHARED file-backed object in the chain.
	 */
	BUG_ON(list_empty(&vma->list));
	vmo_link = link_to_struct(vma->vm_obj_list.next, struct vm_obj_link, list);
	vmo = vmo_link->obj;

	/* Only dirty objects would need flushing */
	if (!(vmo->flags & VM_DIRTY))
		return 0;

	/* Only vfs file objects are flushed */
	if (vmo->flags & VM_OBJ_FILE &&
	    vmo->flags & VMA_SHARED &&
	    !(vmo->flags & VMA_ANONYMOUS)) {

		/* Only vfs files ought to match above criteria */
	    	BUG_ON(vm_object_to_file(vmo)->type != VM_FILE_VFS);

		/* Flush the pages */
		if ((err = flush_file_pages(vm_object_to_file(vmo))) < 0)
			return err;
	}

	return 0;
}

/*
 * Unmaps the given virtual address range from the task, the region
 * may span into zero or more vmas, and may involve shrinking, splitting
 * and destruction of multiple vmas.
 *
 * NOTE: Shared object addresses are returned back to their pools when
 * such objects are deleted, and not via this function.
 */
int do_munmap(struct tcb *task, unsigned long vaddr, unsigned long npages)
{
	const unsigned long munmap_start = __pfn(vaddr);
	const unsigned long munmap_end = munmap_start + npages;
	struct vm_area *vma, *n;
	int err;

	list_foreach_removable_struct(vma, n, &task->vm_area_head->list, list) {
		/* Check for intersection */
		if (set_intersection(munmap_start, munmap_end,
				     vma->pfn_start, vma->pfn_end)) {
			/*
			 * Flush pages if vma is writable,
			 * dirty and file-backed.
			 */
			if ((err = vma_flush_pages(vma)) < 0)
				return err;

			/* Unmap the vma accordingly. This may delete the vma */
			if ((err = vma_unmap(vma, task, munmap_start,
					     munmap_end)) < 0)
				return err;
		}
	}

	return 0;
}

int sys_munmap(struct tcb *task, void *start, unsigned long length)
{
	/* Must be aligned on a page boundary */
	if (!is_page_aligned(start))
		return -EINVAL;

	return do_munmap(task, (unsigned long)start,
			 __pfn(page_align_up(length)));
}


/* Syncs mapped area. Currently just synchronously */
int do_msync(struct tcb *task, void *vaddr, unsigned long npages, int flags)
{
	const unsigned long msync_start = __pfn(vaddr);
	const unsigned long msync_end = msync_start + npages;
	struct vm_area *vma;
	unsigned long addr = (unsigned long)vaddr;
	int err;

	/* Find a vma that overlaps with this address range */
	while ((vma = find_vma(addr, &task->vm_area_head->list))) {

		/* Flush pages if vma is writable, dirty and file-backed. */
		if ((err = vma_flush_pages(vma)) < 0)
			return err;

		/* Update address to next vma */
		addr = __pfn_to_addr(vma->pfn_end);

		/* Are we still good to go? */
		if (addr >= msync_end)
			break;
	}

	return 0;
}

int sys_msync(struct tcb *task, void *start, unsigned long length, int flags)
{
	/* Must be aligned on a page boundary */
	if (!is_page_aligned(start))
		return -EINVAL;

	/*
	 * TODO: We need to pass sync'ed and non-sync'ed file flushes to vfs
	 * and support synced and non-synced io.
	 */
	return do_msync(task, start, __pfn(page_align_up(length)), flags);
}

