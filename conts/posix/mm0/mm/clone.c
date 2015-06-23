/*
 * Forking and cloning threads, processes
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include L4LIB_INC_ARCH(syslib.h)
#include <l4lib/ipcdefs.h>
#include <l4lib/exregs.h>
#include <l4/api/errno.h>
#include <l4/api/thread.h>
#include <syscalls.h>
#include <vm_area.h>
#include <task.h>
#include <mmap.h>
#include <shm.h>
#include <test.h>
#include <clone.h>

int sys_fork(struct tcb *parent)
{
	int err;
	struct tcb *child;
	struct exregs_data exregs;
	struct task_ids ids;

	/* Make all shadows in this task read-only */
	vm_freeze_shadows(parent);

	/*
	 * Create a new L4 thread with parent's page tables
	 * kernel stack and kernel-side tcb copied
	 */
	if (IS_ERR(child = task_create(parent, &ids,
			    	       TCB_NO_SHARING,
				       TC_COPY_SPACE)))
		return (int)child;

	/* Set child's fork return value to 0 */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_mr(&exregs, MR_RETURN, 0);

	/* Set child's new utcb address set by task_create() */
	BUG_ON(!child->utcb_address);
	exregs_set_utcb(&exregs,
			child->utcb_address);

	/* Do the actual exregs call to c0 */
	if ((err = l4_exchange_registers(&exregs,
					 child->tid)) < 0)
		BUG();

	/* Add child to global task list */
	global_add_task(child);

	/* Start forked child. */
	l4_thread_control(THREAD_RUN, &ids);

	/* Return child tid to parent */
	return child->tid;
}

int do_clone(struct tcb *parent, unsigned long child_stack,
	     unsigned int flags, unsigned int sysflags)
{
	struct exregs_data exregs;
	struct task_ids ids;
	struct tcb *child;
	int err;

	if (IS_ERR(child = task_create(parent, &ids,
				       flags,
				       sysflags)))
		return (int)child;

	/* Set up child stack marks with given stack argument */
	child->stack_end = child_stack;
	child->stack_start = 0;

	memset(&exregs, 0, sizeof(exregs));

	/* Set child's stack pointer */
	exregs_set_stack(&exregs, child_stack);

	/* Set child's clone return value to 0 */
	exregs_set_mr(&exregs, MR_RETURN, 0);
	BUG_ON(!child->utcb_address);
	exregs_set_utcb(&exregs, child->utcb_address);

	/* Do the actual exregs call to c0 */
	if ((err = l4_exchange_registers(&exregs,
					 child->tid)) < 0)
		BUG();

	/* Add child to global task list */
	global_add_task(child);

	/* Start cloned child. */
	l4_thread_control(THREAD_RUN, &ids);

	/* Return child tid to parent */
	return child->tid;
}


int sys_clone(struct tcb *parent,
	      void *child_stack,
	      unsigned int clone_flags)
{
	unsigned int flags = 0;
	unsigned int sysflags = 0;

	if (!child_stack)
		return -EINVAL;
	BUG_ON((unsigned long)child_stack < 0x10000);

	if (clone_flags & CLONE_VM) {
		flags |= TCB_SHARED_VM;
		sysflags |= TC_SHARE_SPACE;
	}
	if (clone_flags & CLONE_FS)
		flags |= TCB_SHARED_FS;
	if (clone_flags & CLONE_FILES)
		flags |= TCB_SHARED_FILES;
	if (clone_flags & CLONE_THREAD) {
		flags |= TCB_SHARED_TGROUP;
		sysflags |= TC_SHARE_GROUP;
	}
	if (clone_flags & CLONE_PARENT)
		flags |= TCB_SHARED_PARENT;

	return do_clone(parent,
			(unsigned long)child_stack,
			flags, sysflags);
}

