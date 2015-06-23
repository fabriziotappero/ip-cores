/*
 * Copyright (C) 2007, 2008 Bahadir Balban
 *
 * Posix shared memory implementation
 */
#include <shm.h>
#include <stdio.h>
#include <task.h>
#include <mmap.h>
#include <memory.h>
#include <vm_area.h>
#include <globals.h>
#include <malloc/malloc.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include <lib/idpool.h>
#include <lib/addr.h>
#include <lib/spinlock.h>
#include <l4/api/errno.h>
#include <l4/lib/list.h>
#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>
#include INC_GLUE(memlayout.h)
#include <posix/sys/ipc.h>
#include <posix/sys/shm.h>
#include <posix/sys/types.h>

/*
 * FIXME:
 *
 * All this stuff is stored as file_private_data in the vm_file.
 * However they need to have a pseudo-fs infrastructure that
 * stores all internals under the vnode->inode field.
 */
#define shm_file_to_desc(shm_file)	\
	((struct shm_descriptor *)(shm_file)->private_file_data)

/* Unique shared memory ids */
static struct id_pool *shm_ids;

/* Globally disjoint shm virtual address pool */
static struct address_pool shm_vaddr_pool;

void *shm_new_address(int npages)
{
	return address_new(&shm_vaddr_pool, npages);
}

int shm_delete_address(void *shm_addr, int npages)
{
	return address_del(&shm_vaddr_pool, shm_addr, npages);
}

int shm_pool_init()
{
	int err;

	/* Initialise shm id pool */
	if(IS_ERR(shm_ids = id_pool_new_init(SHM_AREA_MAX))) {
		printf("SHM id pool initialisation failed.\n");
		return (int)shm_ids;
	}

	/* Initialise the global shm virtual address pool */
	if ((err =
	     address_pool_init(&shm_vaddr_pool,
			       __pfn_to_addr(cont_mem_regions.shmem->start),
			       __pfn_to_addr(cont_mem_regions.shmem->end)))
	     < 0) {
		printf("SHM Address pool initialisation failed.\n");
		return err;
	}
	return 0;
}

/*
 * Attaches to given shm segment mapped at shm_addr if the shm descriptor
 * does not already have a base address assigned. If neither shm_addr nor
 * the descriptor has an address, allocates one from the shm address pool.
 */
static void *do_shmat(struct vm_file *shm_file, void *shm_addr, int shmflg,
		      struct tcb *task)
{
	struct shm_descriptor *shm = shm_file_to_desc(shm_file);
	unsigned int vmflags;
	void *mapped;

	if (!task) {
		printf("%s:%s: Cannot find caller task with tid %d\n",
		       __TASKNAME__, __FUNCTION__, task->tid);
		BUG();
	}

	if ((unsigned long)shm_addr & PAGE_MASK) {
		if (shmflg & SHM_RND)
			shm_addr = (void *)page_align(shm_addr);
		else
			return PTR_ERR(-EINVAL);
	}

	/* Set mmap flags for segment */
	vmflags = VM_READ | VMA_SHARED | VMA_ANONYMOUS;
	vmflags |= (shmflg & SHM_RDONLY) ? 0 : VM_WRITE;

	/*
	 * Currently all tasks use the same address for each unique segment.
	 * If address is already assigned, the supplied address must match
	 * the original address. We don't look for object map count because
	 * utcb addresses are assigned before being mapped. NOTE: We may do
	 * all this in a specific shm_mmap() call in do_mmap() in the future.
	 */
	if (shm_file_to_desc(shm_file)->shm_addr) {
		if (shm_addr && (shm->shm_addr != shm_addr))
			return PTR_ERR(-EINVAL);
	}

	/*
	 * mmap the area to the process as shared. Page fault
	 * handler would handle allocating and paging-in the
	 * shared pages.
	 */
	if (IS_ERR(mapped = do_mmap(shm_file, 0, task,
				    (unsigned long)shm_addr,
				    vmflags, shm->npages))) {
		printf("do_mmap: Mapping shm area failed with %d.\n",
		       (int)mapped);
		return PTR_ERR(mapped);
	}

	/* Assign new shm address if not assigned */
	if (!shm->shm_addr)
		shm->shm_addr = mapped;
	else
		BUG_ON(shm->shm_addr != mapped);

	return shm->shm_addr;
}

void *sys_shmat(struct tcb *task, l4id_t shmid, void *shmaddr, int shmflg)
{
	struct vm_file *shm_file, *n;

	list_foreach_removable_struct(shm_file, n, &global_vm_files.list, list) {
		if (shm_file->type == VM_FILE_SHM &&
		    shm_file_to_desc(shm_file)->shmid == shmid)
			return do_shmat(shm_file, shmaddr,
					shmflg, task);
	}

	return PTR_ERR(-EINVAL);
}

int do_shmdt(struct tcb *task, struct vm_file *shm)
{
	int err;

	if ((err = do_munmap(task,
			     (unsigned long)shm_file_to_desc(shm)->shm_addr,
			     shm_file_to_desc(shm)->npages)) < 0)
		return err;

	return 0;
}

int sys_shmdt(struct tcb *task, const void *shmaddr)
{
	struct vm_file *shm_file, *n;

	list_foreach_removable_struct(shm_file, n, &global_vm_files.list, list)
		if (shm_file->type == VM_FILE_SHM &&
		    shm_file_to_desc(shm_file)->shm_addr == shmaddr)
			return do_shmdt(task, shm_file);

	return -EINVAL;
}

/*
 * This finds out what address pool the shm area came from and
 * returns the address back to that pool. There are 2 pools,
 * one for utcbs and one for regular shm segments.
 */
void shm_destroy_priv_data(struct vm_file *shm_file)
{
	struct shm_descriptor *shm_desc = shm_file_to_desc(shm_file);

	/* Release the shared memory address */
	BUG_ON(shm_delete_address(shm_desc->shm_addr,
				  shm_file->vm_obj.npages) < 0);

	/* Release the shared memory id */
	BUG_ON(id_del(shm_ids, shm_desc->shmid) < 0);

	/* Now delete the private data itself */
	kfree(shm_file_to_desc(shm_file));
}

/* Creates an shm area and glues its details with shm pager and devzero */
struct vm_file *shm_new(key_t key, unsigned long npages)
{
	struct shm_descriptor *shm_desc;
	struct vm_file *shm_file;

	BUG_ON(!npages);

	/* Allocate file and shm structures */
	if (IS_ERR(shm_file = vm_file_create()))
		return PTR_ERR(shm_file);

	if (!(shm_desc = kzalloc(sizeof(struct shm_descriptor)))) {
		kfree(shm_file);
		return PTR_ERR(-ENOMEM);
	}

	/* Initialise the shm descriptor */
	if (IS_ERR(shm_desc->shmid = id_new(shm_ids))) {
		kfree(shm_file);
		kfree(shm_desc);
		return PTR_ERR(shm_desc->shmid);
	}
	shm_desc->key = (int)key;
	shm_desc->npages = npages;

	/* Initialise the file */
	shm_file->length = __pfn_to_addr(npages);
	shm_file->type = VM_FILE_SHM;
	shm_file->private_file_data = shm_desc;
	shm_file->destroy_priv_data = shm_destroy_priv_data;

	/* Initialise the vm object */
	shm_file->vm_obj.pager = &swap_pager;
	shm_file->vm_obj.flags = VM_OBJ_FILE | VM_WRITE;

	/* Add to shm file and global object list */
	global_add_vm_file(shm_file);

	return shm_file;
}

/*
 * FIXME: Make sure hostile tasks don't subvert other tasks' shared pages
 * by early-registring their shared page address here.
 */
int sys_shmget(key_t key, int size, int shmflg)
{
	unsigned long npages = __pfn(page_align_up(size));
	struct shm_descriptor *shm_desc;
	struct vm_file *shm;

	/* First check argument validity */
	if (npages > SHM_SHMMAX || npages < SHM_SHMMIN)
		return -EINVAL;

	/*
	 * IPC_PRIVATE means create a no-key shm area, i.e. private to this
	 * process so that it would only share it with its forked children.
	 */
	if (key == IPC_PRIVATE) {
		key = -1;		/* Our meaning of no key */
		if (!(shm = shm_new(key, npages)))
			return -ENOSPC;
		else
			return shm_file_to_desc(shm)->shmid;
	}

	list_foreach_struct(shm, &global_vm_files.list, list) {
		if (shm->type != VM_FILE_SHM)
			continue;

		shm_desc = shm_file_to_desc(shm);

		if (shm_desc->key == key) {
			/*
			 * Exclusive means a create request
			 * on an existing key should fail.
			 */
			if ((shmflg & IPC_CREAT) && (shmflg & IPC_EXCL))
				return -EEXIST;
			else
				/* Found it but do we have a size problem? */
				if (shm_desc->npages < npages)
					return -EINVAL;
				else /* Return shmid of the existing key */
					return shm_desc->shmid;
		}
	}

	/* Key doesn't exist and create is set, so we create */
	if (shmflg & IPC_CREAT)
		if (!(shm = shm_new(key, npages)))
			return -ENOSPC;
		else
			return shm_file_to_desc(shm)->shmid;
	else	/* Key doesn't exist, yet create isn't set, its an -ENOENT */
		return -ENOENT;
}



#if 0

/*
 * Fast internal path to do shmget/shmat() together for mm0's
 * convenience. Works for existing areas.
 */
void *shmat_shmget_internal(struct tcb *task, key_t key, void *shmaddr)
{
	struct vm_file *shm_file;
	struct shm_descriptor *shm_desc;

	list_foreach_struct(shm_file, &global_vm_files.list, list) {
		if(shm_file->type == VM_FILE_SHM) {
			shm_desc = shm_file_to_desc(shm_file);
			/* Found the key, shmat that area */
			if (shm_desc->key == key)
				return do_shmat(shm_file, shmaddr,
						0, task);
		}
	}

	return PTR_ERR(-EEXIST);
}

/*
 * Currently, a default shm page is allocated to every thread in the system
 * for efficient ipc communication. This part below provides the allocation
 * and mapping of this page using shmat/get/dt call semantics.
 */

/*
 * Sends shpage address information to requester. The requester then uses
 * this address as a shm key and maps it via shmget/shmat.
 */
void *task_send_shpage_address(struct tcb *sender, l4id_t taskid)
{
	struct tcb *task = find_task(taskid);

	/* Is the task asking for its own utcb address */
	if (sender->tid == taskid) {
		/* It hasn't got one allocated. */
		BUG_ON(!task->shared_page);

		/* Return it to requester */
		return task->shared_page;

	/* A task is asking for someone else's utcb */
	} else {
		/* Only vfs is allowed to do so yet, because its a server */
		if (sender->tid == VFS_TID) {
			/*
			 * Return shpage address to requester. Note if there's
			 * none allocated so far, requester gets 0. We don't
			 * allocate one here.
			 */
			return task->shared_page;
		}
	}
	return 0;
}

int shpage_map_to_task(struct tcb *owner, struct tcb *mapper, unsigned int flags)
{
	struct vm_file *default_shm;

	/* Allocate a new shared page address */
	if (flags & SHPAGE_NEW_ADDRESS)
		owner->shared_page =
			shm_new_address(DEFAULT_SHPAGE_SIZE/PAGE_SIZE);
	else if (!owner->shared_page)
		BUG();

	/* Create a new shared memory segment */
	if (flags & SHPAGE_NEW_SHM)
		if (IS_ERR(default_shm = shm_new((key_t)owner->shared_page,
					      __pfn(DEFAULT_SHPAGE_SIZE))))
		return (int)default_shm;

	/* Map the shared page to mapper */
	if (IS_ERR(shmat_shmget_internal(mapper, (key_t)owner->shared_page,
					 owner->shared_page)))
		BUG();

	/* Prefault the owner's shared page to mapper's address space */
	if (flags & SHPAGE_PREFAULT)
		for (int i = 0; i < __pfn(DEFAULT_SHPAGE_SIZE); i++)
			task_prefault_page(mapper, (unsigned long)owner->shared_page +
				      __pfn_to_addr(i), VM_READ | VM_WRITE);
	return 0;
}

int shpage_unmap_from_task(struct tcb *owner, struct tcb *mapper)
{
	return sys_shmdt(mapper, owner->shared_page);
}
#endif
