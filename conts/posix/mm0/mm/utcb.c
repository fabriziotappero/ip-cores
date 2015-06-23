/*
 * Management of task utcb regions and own utcb.
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */

#include <l4/macros.h>
#include INC_GLUE(memlayout.h)
#include L4LIB_INC_ARCH(utcb.h)
#include <mmap.h>
#include <utcb.h>
#include <malloc/malloc.h>
#include <vm_area.h>
#include <memory.h>

/*
 * UTCB management in Codezero
 */

/* Globally disjoint utcb virtual region pool */
static struct address_pool utcb_region_pool;

int utcb_pool_init()
{
	int err;

	/* Initialise the global shm virtual address pool */
	if ((err =
	     address_pool_init(&utcb_region_pool,
			       __pfn_to_addr(cont_mem_regions.utcb->start),
			       __pfn_to_addr(cont_mem_regions.utcb->end)))
	    < 0) {
		printf("UTCB address pool initialisation failed.\n");
		return err;
	}
	return 0;
}

void *utcb_new_address(int npages)
{
	return address_new(&utcb_region_pool, npages);
}

int utcb_delete_address(void *utcb_address, int npages)
{
	return address_del(&utcb_region_pool, utcb_address, npages);
}

/* Return an empty utcb slot in this descriptor */
unsigned long utcb_new_slot(struct utcb_desc *desc)
{
	int slot;

	if ((slot = id_new(desc->slots)) < 0)
		return 0;
	else
		return desc->utcb_base + (unsigned long)slot * UTCB_SIZE;
}

int utcb_delete_slot(struct utcb_desc *desc, unsigned long address)
{
	BUG_ON(id_del(desc->slots, (address - desc->utcb_base)
		      / UTCB_SIZE) < 0);
	return 0;
}

unsigned long task_new_utcb_desc(struct tcb *task)
{
	struct utcb_desc *d;

	/* Allocate a new descriptor */
	if (!(d	= kzalloc(sizeof(*d))))
		return 0;

	link_init(&d->list);

	/* We currently assume UTCB is smaller than PAGE_SIZE */
       BUG_ON(UTCB_SIZE > PAGE_SIZE);

       /* Initialise utcb slots */
       d->slots = id_pool_new_init(PAGE_SIZE / UTCB_SIZE);

       /* Obtain a new and unique utcb base */
	/* FIXME: Use variable size than a page */
       d->utcb_base = (unsigned long)utcb_new_address(1);

       /* Add descriptor to tcb's chain */
       list_insert(&d->list, &task->utcb_head->list);

       /* Obtain and return first slot */
       return utcb_new_slot(d);
}

int task_delete_utcb_desc(struct tcb *task, struct utcb_desc *d)
{
	/* Unlink desc from its list */
	list_remove_init(&d->list);

	/* Unmap the descriptor region */
	do_munmap(task, d->utcb_base, 1);

	/* Return descriptor address */
	utcb_delete_address((void *)d->utcb_base, 1);

	/* Free the descriptor */
	kfree(d);

	return 0;
}

/*
 * Upon fork, the utcb descriptor list is replaced by a new one, since it is a new
 * address space. A new utcb is allocated and mmap'ed for the child task
 * running in the newly created address space.
 *
 * The original privately mmap'ed regions for thread-local utcbs remain
 * as copy-on-write on the new task, just like mmap'ed the stacks for cloned
 * threads in the parent address space.
 *
 * Upon clone, naturally the utcb descriptor chain and vm_areas remain to be
 * shared. A new utcb slot is allocated either by using an empty one in one of
 * the existing mmap'ed utcb regions, or by mmaping a new utcb region.
 */
int task_setup_utcb(struct tcb *task)
{
	struct utcb_desc *udesc;
	unsigned long slot;
	void *err;

	/* Setting this up twice is a bug */
	BUG_ON(task->utcb_address);

	/* Search for an empty utcb slot already allocated to this space */
	list_foreach_struct(udesc, &task->utcb_head->list, list)
		if ((slot = utcb_new_slot(udesc)))
			goto out;

	/* Allocate a new utcb memory region and return its base */
	slot = task_new_utcb_desc(task);
out:

	/* Check if utcb is already mapped (in case of multiple threads) */
	if (!find_vma(slot, &task->vm_area_head->list)) {
		/* Map this region as private to current task */
		if (IS_ERR(err = do_mmap(0, 0, task, slot,
					 VMA_ANONYMOUS | VMA_PRIVATE |
					 VMA_FIXED | VM_READ | VM_WRITE, 1))) {
			printf("UTCB: mmapping failed with %d\n", (int)err);
			return (int)err;
		}
	}

	/* Assign task's utcb address */
	task->utcb_address = slot;
	// printf("UTCB created at 0x%x.\n", slot);

	return 0;
}

/*
 * Deletes a utcb slot by first deleting the slot entry, the descriptor
 * address if emptied, the mapping of the descriptor, and the descriptor itself
 */
int task_destroy_utcb(struct tcb *task)
{
	struct utcb_desc *udesc;

	// printf("UTCB: Destroying 0x%x\n", task->utcb_address);

	/* Find the utcb descriptor slot first */
	list_foreach_struct(udesc, &task->utcb_head->list, list) {
		/* FIXME: Use variable alignment than a page */
		/* Detect matching slot */
		if (page_align(task->utcb_address) == udesc->utcb_base) {

			/* Delete slot from the descriptor */
			utcb_delete_slot(udesc, task->utcb_address);

			/* Is the desc completely empty now? */
			if (id_is_empty(udesc->slots))
				/* Delete the descriptor */
				task_delete_utcb_desc(task, udesc);
			return 0; /* Finished */
		}
	}
	BUG();
}


