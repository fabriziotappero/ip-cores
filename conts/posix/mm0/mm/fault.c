/*
 * Page fault handling.
 *
 * Copyright (C) 2007, 2008-2010 Bahadir Bilgehan Balban
 */
#include <vm_area.h>
#include <task.h>
#include <mm/alloc_page.h>
#include <malloc/malloc.h>
#include <l4/generic/space.h>
#include <l4/api/errno.h>
#include <string.h>
#include <memory.h>
#include <shm.h>
#include <file.h>
#include <test.h>

#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include INC_GLUE(memory.h)
#include INC_SUBARCH(mm.h)
#include __INC_ARCH(mm.h)
#include __INC_ARCH(debug.h)

/* Given a page and the vma it is in, returns that page's virtual address */
unsigned long vma_page_to_virtual(struct vm_area *vma, struct page *page)
{
	unsigned long virtual_pfn = vma->pfn_start + page->offset - vma->file_offset;

	/* Page must be contained in vma's pages  */
	BUG_ON(vma->file_offset > page->offset);

	return __pfn_to_addr(virtual_pfn);
}

unsigned long fault_to_file_offset(struct fault_data *fault)
{
	/* Fault's offset in its vma */
	unsigned long vma_off_pfn = __pfn(fault->address) - fault->vma->pfn_start;

	/* Fault's offset in the file */
	unsigned long f_off_pfn = fault->vma->file_offset + vma_off_pfn;

	return f_off_pfn;
}

/*
 * Given a reference to a vm_object link, returns the next link but
 * avoids wrapping around back to head. If next is head, returns 0.
 *
 * vma->link1->link2->link3
 *       |      |      |
 *       V      V      V
 *       vmo1   vmo2   vmo3|vm_file
 *
 * Example:
 * Given a reference to link = vma, head = vma, returns link1.
 * Given a reference to link = link3, head = vma, returns 0.
 */
struct vm_obj_link *vma_next_link(struct link *link,
				  struct link *head)
{
	BUG_ON(list_empty(link));
	if (link->next == head)
		return 0;
	else
		return link_to_struct(link->next, struct vm_obj_link, list);
}

/* Unlinks orig_link from its vma and deletes it but keeps the object. */
struct vm_object *vma_drop_link(struct vm_obj_link *link)
{
	struct vm_object *dropped;

	/* Remove object link from vma's list */
	list_remove(&link->list);

	/* Unlink the link from object */
	dropped = vm_unlink_object(link);

	/* Delete the original link */
	kfree(link);

	return dropped;
}

/*
 * Checks if page cache pages of lesser is a subset of those of copier.
 *
 * FIXME:
 * Note this just checks the page cache, so if any objects have pages
 * swapped to disk, this function won't work, which is a logic error.
 * This should really count the swapped ones as well.
 */
int vm_object_is_subset(struct vm_object *shadow,
			struct vm_object *original)
{
	struct page *pc, *pl;

	/* Copier must have equal or more pages to overlap lesser */
	if (shadow->npages < original->npages)
		return 0;

	/*
	 * Do a page by page comparison. Every lesser page
	 * must be in copier for overlap.
	 */
	list_foreach_struct(pl, &original->page_cache, list)
		if (!(pc = find_page(shadow, pl->offset)))
			return 0;
	/*
	 * For all pages of lesser vmo, there seems to be a page
	 * in the copier vmo. So lesser is a subset of copier
	 */
	return 1;
}

static inline int vm_object_is_droppable(struct vm_object *shadow,
					 struct vm_object *original)
{
	if (shadow->npages == original->npages &&
	    (original->flags & VM_OBJ_SHADOW))
		return 1;
	else
		return 0;
}



/*
 * vma_merge_object()
 *
 * FIXME: Currently this is an optimisation that needs to go
 * away when swapping is available. We have this solely because
 * currently a shadow needs to identically mirror the whole
 * object underneath, in order to drop it. A file that is 1MB
 * long would spend 2MB until dropped. When swapping is available,
 * we will go back to identical mirroring instead of merging the
 * last shadow, since most unused pages would be swapped out.
 */

/*
 * When one shadow object is redundant, merges it into the shadow in front of it.
 * Note it must be determined that it is redundant before calling this function.
 *
 * vma --> link1 --> link2 --> link3
 *         |         |         |
 *         v         v         v
 *         Front     Redundant Next
 *         Shadow    Shadow    Object (E.g. shadow or file)
 */
int vma_merge_object(struct vm_object *redundant)
{
	/* The redundant shadow object */
	struct vm_object *front; /* Shadow in front of redundant */
	struct vm_obj_link *last_link;
	struct page *p1, *p2, *n;

	/* Check link and shadow count is really 1 */
	BUG_ON(redundant->nlinks != 1);
	BUG_ON(redundant->shadows != 1);

	/* Get the last shadower object in front */
	front = link_to_struct(redundant->shdw_list.next,
			   struct vm_object, shref);

	/* Move all non-intersecting pages to front shadow. */
	list_foreach_removable_struct(p1, n, &redundant->page_cache, list) {
		/* Page doesn't exist in front, move it there */
		if (!(p2 = find_page(front, p1->offset))) {
			list_remove_init(&p1->list);
			spin_lock(&p1->lock);
			p1->owner = front;
			spin_unlock(&p1->lock);
			insert_page_olist(p1, front);
			front->npages++;
		}
	}

	/* Sort out shadow relationships after the merge: */

	/* Front won't be a shadow of the redundant shadow anymore */
	list_remove_init(&front->shref);

	/* Check that there really was one shadower of redundant left */
	BUG_ON(!list_empty(&redundant->shdw_list));

	/* Redundant won't be a shadow of its next object */
	list_remove_init(&redundant->shref);

	/* Front is now a shadow of redundant's next object */
	list_insert(&front->shref, &redundant->orig_obj->shdw_list);
	front->orig_obj = redundant->orig_obj;

	/* Find last link for the object */
	last_link = link_to_struct(redundant->link_list.next,
			       struct vm_obj_link, linkref);

	/* Drop the last link to the object */
	vma_drop_link(last_link);

	/* Redundant shadow has no shadows anymore */
	BUG_ON(--redundant->shadows < 0);

	/* Delete the redundant shadow along with all its pages. */
	vm_object_delete(redundant);

	return 0;
}

struct vm_obj_link *vm_objlink_create(void)
{
	struct vm_obj_link *vmo_link;

	if (!(vmo_link = kzalloc(sizeof(*vmo_link))))
		return PTR_ERR(-ENOMEM);
	link_init(&vmo_link->list);
	link_init(&vmo_link->linkref);

	return vmo_link;
}

/*
 * Creates a bare vm_object along with its vma link, since
 * the shadow will be immediately used in a vma object list.
 */
struct vm_obj_link *vma_create_shadow(void)
{
	struct vm_object *vmo;
	struct vm_obj_link *vmo_link;

	if (IS_ERR(vmo_link = vm_objlink_create()))
		return 0;

	if (!(vmo = vm_object_create())) {
		kfree(vmo_link);
		return 0;
	}
	vmo->flags = VM_OBJ_SHADOW;

	vm_link_object(vmo_link, vmo);

	return vmo_link;
}

/* Allocates a new page, copies the original onto it and returns. */
struct page *copy_to_new_page(struct page *orig)
{
	void *paddr = alloc_page(1);

	BUG_ON(!paddr);

	/* Copy the page into new page */
	memcpy(phys_to_virt(paddr), page_to_virt(orig), PAGE_SIZE);

	return phys_to_page(paddr);
}

/* Copy all mapped object link stack from vma to new vma */
int vma_copy_links(struct vm_area *new_vma, struct vm_area *vma)
{
	struct vm_obj_link *vmo_link, *new_link;

	/* Get the first object on the vma */
	BUG_ON(list_empty(&vma->vm_obj_list));
	vmo_link = link_to_struct(vma->vm_obj_list.next,
			      struct vm_obj_link, list);
	do {
		/* Create a new link */
		new_link = vm_objlink_create();

		/* Link object with new link */
		vm_link_object(new_link, vmo_link->obj);

		/* Add the new link to vma in object order */
		list_insert_tail(&new_link->list, &new_vma->vm_obj_list);

	/* Continue traversing links, doing the same copying */
	} while((vmo_link = vma_next_link(&vmo_link->list,
					  &vma->vm_obj_list)));

	return 0;
}

/*
 * Determine if an object is deletable.
 *
 * Shadows are deleted if nlinks = 0, and
 * merged if they have nlinks = 1, shadows = 1.
 * See below for explanation.
 *
 * vfs-type vmfiles are deleted if their
 * openers = 0, and their nlinks
 * (i.e. mappers) = 0.
 *
 * shm-type vmfiles are deleted if their
 * nlinks = 0, since they only have map count.
 */
int vm_object_is_deletable(struct vm_object *obj)
{
	struct vm_file *f;

	//printf("%s: Checking: ", __FUNCTION__);
	//vm_object_print(obj);

	if (obj->nlinks != 0)
		return 0;

	BUG_ON(obj->shadows != 0);
	BUG_ON(!list_empty(&obj->shref));

	if (obj->flags & VM_OBJ_SHADOW)
		return 1;

	f = vm_object_to_file(obj);

	/* Devzero should probably never have 0 refs left */
	if (f->type == VM_FILE_DEVZERO)
		return 0;
	else if (f->type == VM_FILE_SHM)
		return 1;
	else if (f->type == VM_FILE_VFS) {
		if (f->openers == 0)
			return 1;
		else
			return 0;
	}

	/* To make gcc happy */
	BUG();
	return 0;
}

/*
 * exit has: !prev, next || !next
 * shadow drop has: prev, next
 */

/*
 * Shadow drops: Dropping a link to shadow does not mean the shadow's
 * next object has lost a shadow. There may be other links to both. But
 * when the shadow has dropped its last link, and is going to be deleted,
 * it is then true that the shadow is lost by the next object.
 */
int vma_drop_merge_delete(struct vm_area *vma, struct vm_obj_link *link)
{
	struct vm_obj_link *prev, *next;
	struct vm_object *obj;

	/* Get previous and next links, if they exist */
	prev = (link->list.prev == &vma->vm_obj_list) ? 0 :
		link_to_struct(link->list.prev, struct vm_obj_link, list);

	next = (link->list.next == &vma->vm_obj_list) ? 0 :
		link_to_struct(link->list.next, struct vm_obj_link, list);

	/* Drop the link */
	obj = vma_drop_link(link);

	/* If there is an object in front, this is a shadow drop */
	if (prev) {
		BUG_ON(!(prev->obj->flags & VM_OBJ_SHADOW));
		BUG_ON(!(prev->obj->flags & VM_WRITE));
		BUG_ON(--obj->shadows < 0);
		// vm_object_print(obj);

		/* Remove prev from current object's shadow list */
		BUG_ON(list_empty(&prev->obj->shref));
		list_remove_init(&prev->obj->shref);

		/*
		 * We don't allow dropping non-shadow objects yet,
		 * (see ...is_droppable) so there must be a next.
		 */
		BUG_ON(!next);

		/* prev is now shadow of next */
		list_insert(&prev->obj->shref,
			 &next->obj->shdw_list);
		prev->obj->orig_obj = next->obj;

		/*
		 * No referrers left, meaning this object is not
		 * shadowing its original object anymore.
		 */
		if (obj->nlinks == 0) {
			BUG_ON(obj->orig_obj != next->obj);
			list_remove_init(&obj->shref);
		} else {
			/*
			 * Dropped object still has referrers, which
			 * means next has gained a new shadow.
			 * Here's why:
			 *
			 * T1 and T2:	        T2: drop-
			 * prev->drop->next	         \
			 *              became: T1: prev--- next
			 *
			 * Now we have both prev and current object
			 * in next's shadow list.
			 */
			next->obj->shadows++;
		}
	/* It's an exit, we check if there's a shadow loss */
	} else {
		if (obj->nlinks == 0) {
			/* Is it a shadow delete? Sort out next */
			if (next && obj->flags & VM_OBJ_SHADOW) {
				BUG_ON(obj->orig_obj != next->obj);
				BUG_ON(--next->obj->shadows < 0);
				// vm_object_print(next->obj);
				list_remove_init(&obj->shref);
			}
		}
	}

	/* Now deal with the object itself */
	if (vm_object_is_deletable(obj)) {
		dprintf("Deleting object:\n");
		// vm_object_print(obj);
		vm_object_delete(obj);
	} else if ((obj->flags & VM_OBJ_SHADOW) &&
		   obj->nlinks == 1 && obj->shadows == 1) {
		dprintf("Merging object:\n");
		// vm_object_print(obj);
		vma_merge_object(obj);
	}

	mm0_test_global_vm_integrity();
	return 0;
}

/*
 * A scenario that pretty much covers every exit() case.
 *
 * T = vma on a unique task
 * l = link
 * Sobj = Shadow object
 * Fobj = File object
 *
 * Every l links to the object on the nearest
 * row to it and on the same column.
 *
 *	l	l	l	l	l	l		T
 *	Sobj	Sobj
 *
 *			Sobj	Sobj	Sobj	Fobj
 *
 * Sobj	Sobj	Sobj
 * l	l	l	l	l	l	l		T
 *
 * l	l	l	l	l	l	l		T
 * Sobj
 *
 */

/* This version is used when exiting. */
int vma_drop_merge_delete_all(struct vm_area *vma)
{
	struct vm_obj_link *vmo_link, *n;

	/* Vma cannot be empty */
	BUG_ON(list_empty(&vma->vm_obj_list));

	/* Traverse and get rid of all links */
	list_foreach_removable_struct(vmo_link, n, &vma->vm_obj_list, list)
		vma_drop_merge_delete(vma, vmo_link);

	return 0;
}

/* TODO:
 * - Why not allocate a swap descriptor in vma_create_shadow() rather than
 *   a bare vm_object? It will be needed.
 * - Check refcounting of shadows, their references, page refs,
 *   reduces increases etc.
 *
 *   This handles copy-on-write semantics in various situations. Returns
 *   page struct for copy page availabe for mapping.
 *
 *   1) Copy-on-write of read-only files. (Creates r/w shadows/adds pages)
 *   2) Copy-on-write of forked RO shadows (Creates r/w shadows/adds pages)
 *   3) Copy-on-write of shm files. (Adds pages to r/w shm file from devzero).
 */
struct page *copy_on_write(struct fault_data *fault)
{
	struct vm_obj_link *vmo_link, *shadow_link;
	struct vm_object *shadow;
	struct page *page, *new_page;
	struct vm_area *vma = fault->vma;
	unsigned long file_offset = fault_to_file_offset(fault);

	/* Get the first object, either original file or a shadow */
	if (!(vmo_link = vma_next_link(&vma->vm_obj_list, &vma->vm_obj_list))) {
		printf("%s:%s: No vm object in vma!\n",
		       __TASKNAME__, __FUNCTION__);
		BUG();
	}

	/* Is the object read-only? Create a shadow object if so.
	 *
	 * NOTE: Whenever the topmost object is read-only, a new shadow
	 * object must be created. When there are no shadows one is created
	 * because, its the original vm_object that is not writeable, and
	 * when there are shadows one is created because a fork had just
	 * happened, in which case all shadows are rendered read-only.
	 */
	if (!(vmo_link->obj->flags & VM_WRITE)) {
		if (!(shadow_link = vma_create_shadow()))
			return PTR_ERR(-ENOMEM);

		/* Initialise the shadow */
		shadow = shadow_link->obj;
		shadow->orig_obj = vmo_link->obj;
		shadow->flags = VM_OBJ_SHADOW | VM_WRITE;
		shadow->pager = &swap_pager;
		vmo_link->obj->shadows++;
		// vm_object_print(vmo_link->obj);
		dprintf("%s: Created a shadow:\n", __TASKNAME__);
		// vm_object_print(shadow);
		dprintf("%s: Original object:\n", __TASKNAME__);
		// vm_object_print(shadow->orig_obj);

		/*
		 * Add the shadow in front of the original:
		 *
 		 * vma->link0->link1
 		 *       |      |
 		 *       v      v
 		 *       shadow original
		 */
		list_insert(&shadow_link->list, &vma->vm_obj_list);

		/* Add object to original's shadower list */
		list_insert(&shadow->shref, &shadow->orig_obj->shdw_list);

		/* Add to global object list */
		global_add_vm_object(shadow);

	} else {
		/* We ought to copy the missing RW page to top shadow */
		dprintf("No new shadows. Going to add to "
			"topmost r/w shadow object\n");
		shadow_link = vmo_link;

		/*
		 * FIXME: Here we check for the case that a cloned thread is
		 * doing a duplicate write request on an existing RW shadow
		 * page. If so, we return the existing writable page in the top
		 * shadow. We should find a generic way to detect duplicate
		 * requests and cease IPC at an earlier stage.
		 */
		page = shadow_link->obj->pager->ops.page_in(shadow_link->obj,
							    file_offset);
		if (!IS_ERR(page))
			return page;

		/*
		 * We start page search on read-only objects. If the first
		 * one was writable, go to next which must be read-only.
		 */
		BUG_ON(!(vmo_link = vma_next_link(&vmo_link->list,
						  &vma->vm_obj_list)));
		BUG_ON(vmo_link->obj->flags & VM_WRITE);
	}

	/* Traverse the list of read-only vm objects and search for the page */
	while (IS_ERR(page = vmo_link->obj->pager->ops.page_in(vmo_link->obj,
							       file_offset))) {
		if (!(vmo_link = vma_next_link(&vmo_link->list,
					       &vma->vm_obj_list))) {
			printf("%s:%s: Traversed all shadows and the original "
			       "file's vm_object, but could not find the "
			       "faulty page in this vma.\n",__TASKNAME__,
			       __FUNCTION__);
			BUG();
		}
	}

	/*
	 * Copy the page. This traverse and copy is like a page-in operation
	 * of a pager, except that the page is moving along vm_objects.
	 */
	new_page = copy_to_new_page(page);

	/* Update page details */
	spin_lock(&new_page->lock);
	BUG_ON(!list_empty(&new_page->list));
	new_page->refcnt = 0;
	new_page->owner = shadow_link->obj;
	new_page->offset = file_offset;
	new_page->virtual = 0;
	spin_unlock(&page->lock);

	/* Add the page to owner's list of in-memory pages */
	insert_page_olist(new_page, new_page->owner);
	new_page->owner->npages++;

	mm0_test_global_vm_integrity();

	/* Shared faults don't have shadows so we don't look for collapses */
	if (!(vma->flags & VMA_SHARED)) {

		/*
		 * Finished handling the actual fault, now check for possible
		 * shadow collapses. Does the shadow completely shadow the one
		 * underlying it?
		 */
		if (!(vmo_link = vma_next_link(&shadow_link->list,
					       &vma->vm_obj_list))) {
			/* Copier must have an object under it */
			printf("Copier must have had an object under it!\n");
			BUG();
		}
		if (vm_object_is_droppable(shadow_link->obj, vmo_link->obj))
			vma_drop_merge_delete(vma, vmo_link);
	}

	return new_page;
}

/*
 * Handles the page fault, all entries here are assumed *legal*
 * faults, i.e. do_page_fault() should have already checked
 * for illegal accesses.
 *
 * NOTE:
 * Anon/Shared pages:
 * First access from first process is COW. All subsequent RW
 * accesses (which are attempts of *sharing*) simply map that
 * page to faulting processes.
 *
 * Non-anon/shared pages:
 * First access from first process simply writes to the pages
 * of that file. All subsequent accesses by other processes
 * do so as well.
 *
 * FIXME: Add VM_DIRTY bit for every page that has write-faulted.
 */

/* Handle read faults */
struct page *page_read_fault(struct fault_data *fault)
{
	struct vm_area *vma = fault->vma;
	struct vm_obj_link *vmo_link;
	unsigned long file_offset;
	struct page *page = 0;

	file_offset = fault_to_file_offset(fault);

	/* Get the first object, either original file or a shadow */
	if (!(vmo_link = vma_next_link(&vma->vm_obj_list, &vma->vm_obj_list))) {
		printf("%s:%s: No vm object in vma!\n",
		       __TASKNAME__, __FUNCTION__);
		BUG();
	}

	/* Traverse the list of read-only vm objects and search for the page */
	while (IS_ERR(page = vmo_link->obj->pager->ops.page_in(vmo_link->obj,
							       file_offset))) {
		if (!(vmo_link = vma_next_link(&vmo_link->list,
					       &vma->vm_obj_list))) {
			printf("%s:%s: Traversed all shadows and the original "
			       "file's vm_object, but could not find the "
			       "faulty page in this vma.\n",__TASKNAME__,
			       __FUNCTION__);
			BUG();
		}
	}
	BUG_ON(!page);

	return page;
}

struct page *page_write_fault(struct fault_data *fault)
{
	unsigned int vma_flags = fault->vma->flags;
	struct vm_area *vma = fault->vma;
	struct vm_obj_link *vmo_link;
	unsigned long file_offset;
	struct page *page = 0;

	/* Copy-on-write. All private vmas are always COW */
	if (vma_flags & VMA_PRIVATE) {
		BUG_ON(IS_ERR(page = copy_on_write(fault)));

	/*
	 * This handles shared pages that are both anon and non-anon.
	 */
	} else if ((vma_flags & VMA_SHARED)) {
		file_offset = fault_to_file_offset(fault);

		/* Don't traverse, just take the first object */
		BUG_ON(!(vmo_link = vma_next_link(&vma->vm_obj_list,
						  &vma->vm_obj_list)));

		/* Get the page from its pager */
		if (IS_ERR(page = vmo_link->obj->pager->ops.page_in(vmo_link->obj,
								    file_offset))) {
			/*
			 * Writable page does not exist,
			 * if it is anonymous, it needs to be COW'ed,
			 * otherwise the file must have paged-in this
			 * page, so its a bug.
			 */
			if (vma_flags & VMA_ANONYMOUS) {
				BUG_ON(IS_ERR(page = copy_on_write(fault)));
				return page;
			} else {
				printf("%s: Could not obtain faulty "
				       "page from regular file.\n",
				       __TASKNAME__);
				BUG();
			}
		}

		/*
		 * Page and object are now dirty. Currently it's
		 * only relevant for file-backed shared objects.
		 */
		page->flags |= VM_DIRTY;
		page->owner->flags |= VM_DIRTY;
	} else
		BUG();

	return page;
}

struct page *__do_page_fault(struct fault_data *fault)
{
	unsigned int reason = fault->reason;
	unsigned int pte_flags = fault->pte_flags;
	unsigned int map_flags = 0;
	struct page *page = 0;

	if ((reason & VM_READ) && (pte_flags & VM_NONE)) {
		page = page_read_fault(fault);
		map_flags = MAP_USR_RO;

	} else if ((reason & VM_WRITE) && (pte_flags & VM_NONE)) {
		page = page_read_fault(fault);
		page = page_write_fault(fault);
		map_flags = MAP_USR_RW;

	} else if ((reason & VM_EXEC) && (pte_flags & VM_NONE)) {
		page = page_read_fault(fault);
		map_flags = MAP_USR_RX;

	} else if ((reason & VM_EXEC) && (pte_flags & VM_READ)) {
		/* Retrieve already paged in file */
		page = page_read_fault(fault);
		if (pte_flags & VM_WRITE)
			map_flags = MAP_USR_RWX;
		else
			map_flags = MAP_USR_RX;

	} else if ((reason & VM_WRITE) && (pte_flags & VM_READ)) {
		page = page_write_fault(fault);
		if (pte_flags & VM_EXEC)
			map_flags = MAP_USR_RWX;
		else
			map_flags = MAP_USR_RW;

	} else {
		printf("mm0: Unhandled page fault.\n");
		BUG();
	}

	BUG_ON(!page);

	/* Map the new page to faulty task */
	l4_map((void *)page_to_phys(page),
	       (void *)page_align(fault->address), 1,
	       map_flags, fault->task->tid);
	// vm_object_print(page->owner);

	return page;
}

/*
 * Sets all r/w shadow objects as read-only for the process
 * so that as expected after a fork() operation, writes to those
 * objects cause copy-on-write events.
 */
int vm_freeze_shadows(struct tcb *task)
{
	unsigned long virtual;
	struct vm_area *vma;
	struct vm_obj_link *vmo_link;
	struct vm_object *vmo;
	struct page *p;

	list_foreach_struct(vma, &task->vm_area_head->list, list) {

		/* Shared vmas don't have shadows */
		if (vma->flags & VMA_SHARED)
			continue;

		/* Get the first object */
		BUG_ON(list_empty(&vma->vm_obj_list));
		vmo_link = link_to_struct(vma->vm_obj_list.next,
				      struct vm_obj_link, list);
		vmo = vmo_link->obj;

		/*
		 * Is this a writeable shadow?
		 *
		 * The only R/W shadow in a vma object chain
		 * can be the first one, so we don't check further
		 * objects if first one is not what we want.
		 */
		if (!((vmo->flags & VM_OBJ_SHADOW) &&
		      (vmo->flags & VM_WRITE)))
			continue;

		/* Make the object read only */
		vmo->flags &= ~VM_WRITE;
		vmo->flags |= VM_READ;

		/*
		 * Make all pages on it read-only
		 * in the page tables.
		 */
		list_foreach_struct(p, &vmo->page_cache, list) {

			/* Find virtual address of each page */
			virtual = vma_page_to_virtual(vma, p);

			/* Map the page as read-only */
			l4_map((void *)page_to_phys(p),
			       (void *)virtual, 1,
			       MAP_USR_RO, task->tid);
		}
	}

	return 0;
}

/*
 * Page fault model:
 *
 * A page is anonymous (e.g. stack)
 *  - page needs read access:
 *  	action: map the zero page.
 *  - page needs write access:
 *      action: allocate ZI page and map that. Swap file owns the page.
 *  - page is swapped to swap:
 *      action: read back from swap file into new page.
 *
 * A page is file-backed but private (e.g. .data section)
 *  - page needs read access:
 *      action: read the page from its file.
 *  - page is swapped out before being private. (i.e. invalidated)
 *      action: read the page from its file. (original file)
 *  - page is swapped out after being private.
 *      action: read the page from its file. (swap file)
 *  - page needs write access:
 *      action: allocate new page, declare page as private, change its
 *              owner to swap file.
 *
 * A page is file backed but not-private, and read-only. (e.g. .text section)
 *  - page needs read access:
 *     action: read in the page from its file.
 *  - page is swapped out. (i.e. invalidated)
 *     action: read in the page from its file.
 *  - page needs write access:
 *     action: forbidden, kill task?
 *
 * A page is file backed but not-private, and read/write. (e.g. any data file.)
 *  - page needs read access:
 *     action: read in the page from its file.
 *  - page is flushed back to its original file. (i.e. instead of swap)
 *     action: read in the page from its file.
 *  - page needs write access:
 *     action: read the page in, give write access.
 */
struct page *do_page_fault(struct fault_data *fault)
{
	unsigned int vma_flags = (fault->vma) ? fault->vma->flags : VM_NONE;
	unsigned int reason = fault->reason;

	/* vma flags show no access */
	if (vma_flags & VM_NONE) {
		printf("Illegal access, tid: %d, address: 0x%x, PC @ 0x%x,\n",
		       fault->task->tid, fault->address, fault->kdata->faulty_pc);
		fault_handle_error(fault);
	}

	/* The access reason is not included in the vma's listed flags */
	if (!(reason & vma_flags)) {
		printf("Illegal access, tid: %d, address: 0x%x, PC @ 0x%x\n",
		       fault->task->tid, fault->address, fault->kdata->faulty_pc);
		fault_handle_error(fault);
	}

	/* Handle legitimate faults */
	return __do_page_fault(fault);
}

struct page *page_fault_handler(struct tcb *sender, fault_kdata_t *fkdata)
{
	struct fault_data fault = {
		/* Fault data from kernel */
		.kdata = fkdata,
		.task = sender,
	};

	/* Extract fault reason, fault address etc. in generic format */
	set_generic_fault_params(&fault);

	/* Get vma info */
	if (!(fault.vma = find_vma(fault.address,
				   &fault.task->vm_area_head->list)))
		printf("Hmm. No vma for faulty region. "
		       "Bad things will happen.\n");

	/* Handle the actual fault */
	return do_page_fault(&fault);
}

static inline unsigned int pte_to_map_flags(unsigned int pte_flags)
{
	unsigned int map_flags;

	switch(pte_flags) {
	case VM_READ:
		map_flags = MAP_USR_RO;
		break;
	case (VM_READ | VM_WRITE):
		map_flags = MAP_USR_RW;
		break;
	case (VM_READ | VM_WRITE | VM_EXEC):
		map_flags = MAP_USR_RWX;
		break;
	case (VM_READ | VM_EXEC):
		map_flags = MAP_USR_RX;
		break;
	default:
		BUG();
	}

	return map_flags;
}

/*
 * Prefaults a page of a task. The catch is that the page may already
 * have been faulted with even more progress than the desired
 * flags would progress in the fault (e.g. read-faulting a
 * copy-on-write'd page).
 *
 * This function detects whether progress is necessary or not by
 * inspecting the vma's vm_object chain state.
 *
 * Generally both read-fault and write-fault paths are repeatable, in
 * the sense that an already faulted page may be safely re-faulted again
 * and again, be it a read-only or copy-on-write'd page.
 *
 * The retrieval of the same page in a repetitive fashion is safe,
 * but while it also seems to appear safe, it is unnecessary to downgrade
 * or change mapping permissions of a page. E.g. make a copy-on-write'd
 * page read-only by doing a blind read-fault on it.
 *
 * Hence this function checks whether a fault is necessary and simply
 * returns if it isn't.
 *
 * FIXME: Escalate any page fault errors like a civilized function!
 */
struct page *task_prefault_smart(struct tcb *task, unsigned long address,
				 unsigned int wanted_flags)
{
	struct vm_obj_link *vmo_link;
	unsigned long file_offset;
	unsigned int vma_flags, pte_flags;
	struct vm_area *vma;
	struct page *page;
	int err;

	struct fault_data fault = {
		.task = task,
		.address = address,
	};

	/* Find the vma */
	if (!(fault.vma = find_vma(fault.address,
				   &fault.task->vm_area_head->list))) {
		dprintf("%s: Invalid: No vma for given address. %d\n",
			__FUNCTION__, -EINVAL);
		return PTR_ERR(-EINVAL);
	}

	/* Read fault, repetitive safe */
	if (wanted_flags & VM_READ)
		if (IS_ERR(page = page_read_fault(&fault)))
			return page;

	/* Write fault, repetitive safe */
	if (wanted_flags & VM_WRITE)
		if (IS_ERR(page = page_write_fault(&fault)))
			return page;

	/*
	 * If we came this far, it means we have more
	 * permissions than VM_NONE.
	 *
	 * Now we _must_ find out what those page
	 * protection flags were, and do this without
	 * needing to inspect any ptes.
	 *
	 * We don't want to downgrade a RW page to RO again.
	 */
	file_offset = fault_to_file_offset(&fault);
	vma_flags = fault.vma->flags;
	vma = fault.vma;

	/* Get the topmost vm_object */
	if (!(vmo_link = vma_next_link(&vma->vm_obj_list,
				       &vma->vm_obj_list))) {
		printf("%s:%s: No vm object in vma!\n",
		       __TASKNAME__, __FUNCTION__);
		BUG();
	}

	/* Traverse the list of vm objects and search for the page */
	while (IS_ERR(page = vmo_link->obj->pager->ops.page_in(vmo_link->obj,
							       file_offset))) {
		if (!(vmo_link = vma_next_link(&vmo_link->list,
					       &vma->vm_obj_list))) {
			printf("%s:%s: Traversed all shadows and the original "
			       "file's vm_object, but could not find the "
			       "faulty page in this vma.\n",__TASKNAME__,
			       __FUNCTION__);
			BUG();
		}
	}

	/* Use flags for the vm_object containing the page */
	if (vmo_link->obj->flags & VM_WRITE)
		pte_flags = VM_WRITE | VM_READ;
	else
		pte_flags = VM_READ;

	/*
	 * Now check vma flags for adding the VM_EXEC
	 * The real pte may not have this flag yet, but
	 * it is allowed to have it and it doesn't harm.
	 */
	if (vma_flags & VM_EXEC)
		pte_flags |= VM_EXEC;

	/* Map the page to task using these flags */
	if ((err = l4_map((void *)page_to_phys(page),
			  (void *)page_align(fault.address), 1,
			  pte_to_map_flags(pte_flags),
			  fault.task->tid)) < 0) {
		printf("l4_map() failed. err=%d\n", err);
		BUG();
	}

	return page;
}

/*
 * Prefaults the page with given virtual address, to given task
 * with given reasons. Multiple reasons are allowed, they are
 * handled separately in order.
 */
struct page *task_prefault_page(struct tcb *task, unsigned long address,
				unsigned int vmflags)
{
	struct page *ret;

	perfmon_reset_start_cyccnt();
	ret = task_prefault_smart(task, address, vmflags);

	debug_record_cycles("task_prefault_smart");

	return ret;

#if 0
	struct page *p;
	struct fault_data fault = {
		.task = task,
		.address = address,
	};

	dprintf("Pre-faulting address 0x%lx, on task %d, with flags: 0x%x\n",
		address, task->tid, vmflags);

	/* Find the vma */
	if (!(fault.vma = find_vma(fault.address,
				   &fault.task->vm_area_head->list))) {
		dprintf("%s: Invalid: No vma for given address. %d\n",
			__FUNCTION__, -EINVAL);
		return PTR_ERR(-EINVAL);
	}

	/* Flags may indicate multiple fault reasons. First do the read */
	if (vmflags & VM_READ) {
		fault.pte_flags = VM_NONE;
		fault.reason = VM_READ;
		if (IS_ERR(p = do_page_fault(&fault)))
			return p;
	}
	/* Now write */
	if (vmflags & VM_WRITE) {
		fault.pte_flags = VM_READ;
		fault.reason = VM_WRITE;
		if (IS_ERR(p = do_page_fault(&fault)))
			return p;
	}
	/* No exec or any other fault reason allowed. */
	BUG_ON(vmflags & ~(VM_READ | VM_WRITE));

	return p;
#endif
}


int vm_compare_prot_flags(unsigned int current, unsigned int needed)
{
	current &= VM_PROT_MASK;
	needed &= VM_PROT_MASK;

	if (needed & VM_READ)
		if (current & (VM_READ | VM_WRITE))
			return 1;

	if (needed & VM_WRITE &&
	    (current & VM_WRITE))
		return 1;

	return 0;
}

