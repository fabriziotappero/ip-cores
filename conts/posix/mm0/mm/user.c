/*
 * Functions to validate, map and unmap user buffers.
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include L4LIB_INC_ARCH(syslib.h)
#include <vm_area.h>
#include <task.h>
#include <user.h>
#include <l4/api/errno.h>
#include <malloc/malloc.h>

/*
 * Checks if the given user virtual address range is
 * validly owned by that user with given flags.
 *
 * FIXME: This scans the vmas page by page, we can do it faster
 * by leaping from one vma to next.
 */
int pager_validate_user_range(struct tcb *user, void *userptr, unsigned long size,
			      unsigned int vmflags)
{
	struct vm_area *vma;
	unsigned long start = page_align(userptr);
	unsigned long end = page_align_up(userptr + size);

	/* Find the vma that maps that virtual address */
	for (unsigned long vaddr = start; vaddr < end; vaddr += PAGE_SIZE) {
		if (!(vma = find_vma(vaddr, &user->vm_area_head->list))) {
			//printf("%s: No VMA found for 0x%x on task: %d\n",
			//       __FUNCTION__, vaddr, user->tid);
			return -1;
		}
		if ((vma->flags & vmflags) != vmflags)
			return -1;
	}

	return 0;
}

/*
 * Validates and maps the user virtual address range to the pager.
 * Every virtual page needs to be mapped individually because it's
 * not guaranteed pages are physically contiguous.
 *
 * FIXME: There's no logic here to make non-contiguous physical pages
 * to get mapped virtually contiguous.
 */
void *pager_get_user_page(struct tcb *user, void *userptr,
			  unsigned long size, unsigned int vm_flags)
{
	unsigned long start = page_align(userptr);
	unsigned long end = page_align_up(userptr + size);
	void *mapped = 0;

	/* Validate that user task owns this address range */
	if (pager_validate_user_range(user, userptr, size, vm_flags) < 0)
		return 0;

	/* Map first page and calculate the mapped address of pointer */
	mapped = page_to_virt(task_prefault_page(user, start, vm_flags));
	mapped = (void *)(((unsigned long)mapped) |
			  ((unsigned long)(PAGE_MASK & (unsigned long)userptr)));

	/* Map the rest of the pages, if any */
	for (unsigned long i = start + PAGE_SIZE; i < end; i += PAGE_SIZE)
		BUG();

	return mapped;
}

/*
 * Copy from one buffer to another. Stop if maxlength or
 * a page boundary is hit.
 */
int strncpy_page(void *to_ptr, void *from_ptr, int maxlength)
{
	int count = 0;
	char *to = to_ptr, *from = from_ptr;

	do {
		if ((to[count] = from[count]) == '\0') {
			count++;
			break;
		} else
			count++;
	} while (count < maxlength && !page_boundary(&from[count]));

	if (page_boundary(&from[count]))
		return -EFAULT;
	if (count == maxlength)
		return -E2BIG;

	return count;
}

/*
 * Copy from one buffer to another. Stop if maxlength or
 * a page boundary is hit. Breaks if unsigned long sized copy value is 0,
 * as opposed to a 0 byte as in string copy. If byte size 0 was used
 * a valid pointer with a 0 byte in it would give a false termination.
 */
int bufncpy_page(void *to_ptr, void *from_ptr, int maxlength)
{
	int count = 0;
	unsigned long *to = to_ptr, *from = from_ptr;

	do {
		if ((to[count] = from[count]) == 0) {
			count++;
			break;
		} else
			count++;
	} while (count < maxlength && !page_boundary(&from[count]));

	if (page_boundary(&from[count]))
		return -EFAULT;
	if (count == maxlength)
		return -E2BIG;

	return count;
}

/*
 * Copies src to dest for given size, return -EFAULT on page boundaries.
 */
int memcpy_page(void *dst, void *src, int size, int fault_on_dest)
{
	int count = 0;
	char *to = dst, *from = src;

	if (!fault_on_dest) {
		do {
			to[count] = from[count];
			count++;
		} while (count < size &&
			 !page_boundary(&from[count]));
	} else {
		do {
			to[count] = from[count];
			count++;
		} while (count < size &&
			 !page_boundary(&to[count]));
	}

	if (page_boundary(&from[count]))
		return -EFAULT;

	return count;
}

int copy_from_user(struct tcb *task, void *buf, char *user, int size)
{
	int copied = 0, ret = 0, total = 0;
	int count = size;
	void *mapped = 0;

	if (!(mapped = pager_get_user_page(task, user, TILL_PAGE_ENDS(user),
					   VM_READ)))
		return -EINVAL;

	while ((ret = memcpy_page(buf + copied, mapped, count, 0)) < 0) {
		copied += TILL_PAGE_ENDS(mapped);
		count -= TILL_PAGE_ENDS(mapped);
		if (!(mapped =
		      pager_get_user_page(task, user + copied,
					  TILL_PAGE_ENDS(user + copied),
					  VM_READ)))
			return -EINVAL;
	}

	/* Note copied is always in bytes */
	total = copied + ret;

	return total;
}

int copy_to_user(struct tcb *task, char *user, void *buf, int size)
{
	int copied = 0, ret = 0, total = 0;
	int count = size;
	void *mapped = 0;

	/* Map the user page */
	if (!(mapped = pager_get_user_page(task, user,
					   TILL_PAGE_ENDS(user),
					   VM_READ | VM_WRITE)))
		return -EINVAL;

	while ((ret = memcpy_page(mapped, buf + copied, count, 1)) < 0) {
		copied += TILL_PAGE_ENDS(mapped);
		count -= TILL_PAGE_ENDS(mapped);
		if (!(mapped = pager_get_user_page(task, user + copied,
						   TILL_PAGE_ENDS(user + copied),
						   VM_READ | VM_WRITE)))
			return -EINVAL;
	}

	/* Note copied is always in bytes */
	total = copied + ret;

	return total;
}

/*
 * Copies a variable sized userspace string or array of pointers
 * (think &argv[0]), into buffer. If a page boundary is hit,
 * unmaps the previous page, validates and maps the new page.
 */
int copy_user_buf(struct tcb *task, void *buf, char *user, int maxlength,
		  int elem_size)
{
	int count = maxlength;
	int copied = 0, ret = 0, total = 0;
	void *mapped = 0;
	int (*copy_func)(void *, void *, int count);

	/* This bit determines what size copier function to use. */
	if (elem_size == sizeof(char))
		copy_func = strncpy_page;
	else if (elem_size == sizeof(unsigned long))
		copy_func = bufncpy_page;
	else
		return -EINVAL;

	/* Map the first page the user buffer is in */
	if (!(mapped = pager_get_user_page(task, user, TILL_PAGE_ENDS(user),
					   VM_READ)))
		return -EINVAL;

	while ((ret = copy_func(buf + copied, mapped, count)) < 0) {
		if (ret == -E2BIG)
			return ret;
		else if (ret == -EFAULT) {
			/*
			 * Copied is always in bytes no matter what elem_size is
			 * because we know we hit a page boundary and we increase
			 * by the page boundary bytes
			 */
			copied += TILL_PAGE_ENDS(mapped);
			count -= TILL_PAGE_ENDS(mapped);
			if (!(mapped =
			      pager_get_user_page(task, user + copied,
						  TILL_PAGE_ENDS(user + copied),
						  VM_READ)))
				return -EINVAL;
		}
	}

	/* Note copied is always in bytes */
	total = (copied / elem_size) + ret;

	return total;
}

/*
 * Calls copy_user_buf with char-sized copying. This matters because
 * buffer is variable and the terminator must be in char size
 */
int copy_user_string(struct tcb *task, void *buf, char *user, int maxlength)
{
	return copy_user_buf(task, buf, user, maxlength, sizeof(char));
}

/*
 * Calls copy_user_buf with unsigned long sized copying. This matters
 * because buffer is variable and the terminator must be in ulong size
 */
static inline int
copy_user_ptrs(struct tcb *task, void *buf, char *user,
		 int maxlength)
{
	return copy_user_buf(task, buf, user, maxlength, sizeof(unsigned long));
}

int copy_user_args(struct tcb *task, struct args_struct *args,
		   void *argv_user, int args_max)
{
	char **argv = 0;
	void *argsbuf;
	char *curbuf;
	int argc = 0;
	int used;
	int count;

	if (!(argsbuf = kzalloc(args_max)))
		return -ENOMEM;

	/*
	 * First, copy the null-terminated array of
	 * pointers to argument strings.
	 */
	if ((count = copy_user_ptrs(task, argsbuf, argv_user, args_max)) < 0)
		goto out;

	/* On success, we get the number of arg strings + the terminator */
	argc = count - 1;
	used = count * sizeof(char *);
	argv = argsbuf;
	curbuf = argsbuf + used;

	/* Now we copy each argument string into buffer */
	for (int i = 0; i < argc; i++) {
		/* Copy string into empty space in buffer */
		if ((count = copy_user_string(task, curbuf, argv[i],
					      args_max - used)) < 0)
			goto out;

		/* Replace pointer to string with copied location */
		argv[i] = curbuf;

		/* Update current empty buffer location */
		curbuf += count;

		/* Increase used buffer count */
		used += count;
	}

	/* Set up the args struct */
	args->argc = argc;
	args->argv = argv;
	args->size = used;

	return 0;

out:
	kfree(argsbuf);
	return count;
}

