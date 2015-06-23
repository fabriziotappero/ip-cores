/*
 * Virtual memory area descriptors.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#ifndef __VM_AREA_H__
#define __VM_AREA_H__

#include <stdio.h>
#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include <task.h>
#include <lib/spinlock.h>
#include <physmem.h>
#include <linker.h>
#include __INC_ARCH(mm.h)

// #define DEBUG_FAULT_HANDLING
#ifdef DEBUG_FAULT_HANDLING
#define dprintf(...)	printf(__VA_ARGS__)
#else
#define dprintf(...)
#endif

/* Some task segment marks for mm0 */
#define PAGER_MMAP_SEGMENT		SZ_1MB
#define PAGER_MMAP_START		(page_align_up(__stack))
#define PAGER_MMAP_END			(PAGER_MMAP_START + PAGER_MMAP_SEGMENT)
#define PAGER_EXT_VIRTUAL_START		PAGER_MMAP_END
#define PAGER_EXT_VIRTUAL_END		(unsigned long)(PAGER_MMAP_END + SZ_2MB)
#define PAGER_VIRTUAL_START		PAGER_EXT_VIRTUAL_END

/* Protection flags */
#define VM_NONE				(1 << 0)
#define VM_READ				(1 << 1)
#define VM_EXEC				(1 << 2)
#define VM_WRITE			(1 << 3)
#define VM_PROT_MASK			(VM_READ | VM_WRITE | VM_EXEC)

/* Shared copy of a file */
#define VMA_SHARED			(1 << 4)
/* VMA that's not file-backed, always maps devzero as VMA_COW */
#define VMA_ANONYMOUS			(1 << 5)
/* Private copy of a file */
#define VMA_PRIVATE			(1 << 6)
/* For wired pages */
#define VMA_FIXED			(1 << 7)
/* For stack, where mmap returns end address */
#define VMA_GROWSDOWN			(1 << 8)

/* Set when the page is dirty in cache but not written to disk */
#define VM_DIRTY			(1 << 9)

/* Defines the type of file. A device file? Regular file? One used at boot? */
enum VM_FILE_TYPE {
	VM_FILE_DEVZERO = 1,
	VM_FILE_VFS,
	VM_FILE_SHM,
};

/* Defines the type of object. A file? Just a standalone object? */
#define VM_OBJ_SHADOW		(1 << 10) /* Anonymous pages, swap_pager */
#define VM_OBJ_FILE		(1 << 11) /* VFS file and device pages */

struct page {
	int refcnt;		/* Refcount */
	struct spinlock lock;	/* Page lock. */
	struct link list;  /* For list of a vm_object's in-memory pages */
	struct vm_object *owner;/* The vm_object the page belongs to */
	unsigned long virtual;	/* If refs >1, first mapper's virtual address */
	unsigned int flags;	/* Flags associated with the page. */
	unsigned long offset;	/* The offset page resides in its owner */
};
extern struct page *page_array;

#define page_refcnt(x)		((x)->count + 1)
#define virtual(x)		((x)->virtual)

/* TODO: Calculate these by indexing each bank according to pfn */
#define phys_to_page(x)		(page_array + __pfn((x) - membank[0].start))
#define page_to_phys(x)		(__pfn_to_addr((((void *)(x)) - \
						(void *)page_array) / \
					       sizeof(struct page)) + \
					       membank[0].start)

/* Multiple conversions together */
#define virt_to_page(x)	(phys_to_page(virt_to_phys(x)))
#define page_to_virt(x)	(phys_to_virt((void *)page_to_phys(x)))

/* Fault data specific to this task + ptr to kernel's data */
struct fault_data {
	fault_kdata_t *kdata;		/* Generic data forged by the kernel */
	unsigned int reason;		/* Generic fault reason flags */
	unsigned int address;		/* Aborted address */
	unsigned int pte_flags;		/* Generic protection flags on pte */
	struct vm_area *vma;		/* Inittask-related fault data */
	struct tcb *task;		/* Inittask-related fault data */
};

struct vm_pager_ops {
	struct page *(*page_in)(struct vm_object *vm_obj,
				unsigned long pfn_offset);
	int (*page_out)(struct vm_object *vm_obj,
			unsigned long pfn_offset);
	int (*release_pages)(struct vm_object *vm_obj);
};

/* Describes the pager task that handles a vm_area. */
struct vm_pager {
	struct vm_pager_ops ops;	/* The ops the pager does on area */
};

/*
 * Describes the in-memory representation of a resource. This could
 * point at a file or another resource, e.g. a device area, swapper space,
 * the anonymous internal state of a process, etc. This covers more than
 * just files, e.g. during a fork, captures the state of internal shared
 * copy of private pages for a process, which is really not a file.
 */
struct vm_object {
	int npages;		    /* Number of pages in memory */
	int nlinks;		    /* Number of mapper links that refer */
	int shadows;		    /* Number of shadows that refer */
	struct link shref;	    /* Shadow reference from original object */
	struct link shdw_list; /* List of vm objects that shadows this one */
	struct link link_list; /* List of links that refer to this object */
	struct vm_object *orig_obj; /* Original object that this one shadows */
	unsigned int flags;	    /* Defines the type and flags of the object */
	struct link list;	    /* List of all vm objects in memory */
	struct vm_pager *pager;	    /* The pager for this object */
	struct link page_cache;/* List of in-memory pages */
};

/* In memory representation of either a vfs file, a device. */
struct vm_file {
	int openers;
	struct link list;
	unsigned int type;
	unsigned long length;
	struct vm_object vm_obj;
	void (*destroy_priv_data)(struct vm_file *f);
	struct vnode *vnode;
	void *private_file_data;	/* FIXME: To be removed and placed into vnode!!! */
};

/* To create per-vma vm_object lists */
struct vm_obj_link {
	struct link list;
	struct link linkref;
	struct vm_object *obj;
};

static inline void vm_link_object(struct vm_obj_link *link, struct vm_object *obj)
{
	link->obj = obj;
	list_insert(&link->linkref, &obj->link_list);
	obj->nlinks++;
}

static inline struct vm_object *vm_unlink_object(struct vm_obj_link *link)
{
	/* Delete link from object's link list */
	list_remove(&link->linkref);

	/* Reduce object's mapper link count */
	link->obj->nlinks--;

	return link->obj;
}

#define vm_object_to_file(obj) container_of(obj, struct vm_file, vm_obj)

/*
 * Describes a virtually contiguous chunk of memory region in a task. It covers
 * a unique virtual address area within its task, meaning that it does not
 * overlap with other regions in the same task. The region could be backed by a
 * file or various other resources.
 *
 * COW: Upon copy-on-write, each copy-on-write instance creates a shadow of the
 * original vm object which supersedes the original vm object with its copied
 * modified pages. This creates a stack of shadow vm objects, where the top
 * object's copy of pages supersede the ones lower in the stack.
 */
struct vm_area {
	struct link list;		/* Per-task vma list */
	struct link vm_obj_list;	/* Head for vm_object list. */
	unsigned long pfn_start;	/* Region start virtual pfn */
	unsigned long pfn_end;		/* Region end virtual pfn, exclusive */
	unsigned long flags;		/* Protection flags. */
	unsigned long file_offset;	/* File offset in pfns */
};

/*
 * Finds the vma that has the given address.
 * TODO: In the future a lot of use cases may need to traverse each vma
 * rather than searching the address. E.g. munmap/msync
 */
static inline struct vm_area *find_vma(unsigned long addr,
				       struct link *vm_area_list)
{
	struct vm_area *vma;
	unsigned long pfn = __pfn(addr);

	list_foreach_struct(vma, vm_area_list, list)
		if ((pfn >= vma->pfn_start) && (pfn < vma->pfn_end))
			return vma;
	return 0;
}

/* Adds a page to its vm_objects's page cache in order of offset. */
int insert_page_olist(struct page *this, struct vm_object *vm_obj);

/* Find a page in page cache via page offset */
struct page *find_page(struct vm_object *obj, unsigned long pfn);

/* Pagers */
extern struct vm_pager file_pager;
extern struct vm_pager devzero_pager;
extern struct vm_pager swap_pager;

/* vm object and vm file lists */
extern struct link vm_object_list;

/* vm object link related functions */
struct vm_obj_link *vm_objlink_create(void);
struct vm_obj_link *vma_next_link(struct link *link,
				  struct link *head);

/* vm file and object initialisation */
struct vm_object *vm_object_create(void);
struct vm_file *vm_file_create(void);
int vm_file_delete(struct vm_file *f);
int vm_object_delete(struct vm_object *vmo);
void vm_file_put(struct vm_file *f);

/* Printing objects, files */
void vm_object_print(struct vm_object *vmo);
void vm_print_objects(struct link *vmo_list);
void vm_print_files(struct link *file_list);

/* Buggy version. Used for pre-faulting a page from mm0 */
struct page *task_prefault_page(struct tcb *task, unsigned long address,
				unsigned int vmflags);
/* New version */
struct page *task_prefault_smart(struct tcb *task, unsigned long address,
				 unsigned int vmflags);
struct page *page_init(struct page *page);
struct page *find_page(struct vm_object *vmo, unsigned long page_offset);
void *pager_map_page(struct vm_file *f, unsigned long page_offset);
void pager_unmap_page(void *vaddr);

/* Changes all shadows and their ptes to read-only */
int vm_freeze_shadows(struct tcb *task);

int vm_compare_prot_flags(unsigned int current, unsigned int needed);
int task_insert_vma(struct vm_area *vma, struct link *vma_list);

/* Main page fault entry point */
struct page *page_fault_handler(struct tcb *faulty_task, fault_kdata_t *fkdata);

int vma_copy_links(struct vm_area *new_vma, struct vm_area *vma);
int vma_drop_merge_delete(struct vm_area *vma, struct vm_obj_link *link);
int vma_drop_merge_delete_all(struct vm_area *vma);

void global_add_vm_object(struct vm_object *obj);
void global_remove_vm_object(struct vm_object *obj);
void global_add_vm_file(struct vm_file *f);
void global_remove_vm_file(struct vm_file *f);

#endif /* __VM_AREA_H__ */
