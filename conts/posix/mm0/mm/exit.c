/*
 * exit()
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <shm.h>
#include <task.h>
#include <file.h>
#include <exit.h>
#include <test.h>
#include <utcb.h>
#include <vm_area.h>
#include <syscalls.h>
#include <l4lib/exregs.h>
#include <l4lib/ipcdefs.h>
#include <malloc/malloc.h>
#include <l4/api/space.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)


/* Closes all file descriptors of a task */
int task_close_files(struct tcb *task)
{
	int err = 0;

	/* Flush all file descriptors */
	for (int fd = 0; fd < TASK_FILES_MAX; fd++)
		if (task->files->fd[fd].vmfile)
			if ((err = sys_close(task, fd)) < 0) {
				printf("File close error. Tid: %d,"
				       " fd: %d, error: %d\n",
				       task->tid, fd, err);
				break;
			}
	return err;
}

/* Prepare old task's environment for new task */
int execve_recycle_task(struct tcb *new, struct tcb *orig)
{
	int err;
	struct task_ids ids = {
		.tid = orig->tid,
		.spid = orig->spid,
		.tgid = orig->tgid,
	};

	/*
	 * Copy data to new task that is
	 * to be retained from original
	 */

	/* Copy ids */
	new->tid = orig->tid;
	new->spid = orig->spid;
	new->tgid = orig->tgid;
	new->pagerid = orig->pagerid;

	/* Copy shared page */
	/*
	 * FIXME: Make sure to take care of this.
	 */
	//new->shared_page = orig->shared_page;

	/* Copy parent relationship */
	BUG_ON(new->parent);
	new->parent = orig->parent;
	list_insert(&new->child_ref, &orig->parent->children);

	/* Flush all IO on task's files and close fds */
	task_close_files(orig);

	/* Destroy task's utcb slot */
	task_destroy_utcb(orig);

	/* Vfs still knows the thread */

	/* Keep the shared page on vfs */

	/* Ask the kernel to recycle the thread */
	if ((err = l4_thread_control(THREAD_RECYCLE, &ids)) < 0) {
		printf("%s: Suspending thread %d failed with %d.\n",
		       __FUNCTION__, orig->tid, err);
		return err;
	}

	/* Destroy the locally known tcb */
	tcb_destroy(orig);

	return 0;
}

void do_exit(struct tcb *task, int status)
{
	struct task_ids ids = {
		.tid = task->tid,
		.spid = task->spid,
		.tgid = task->tgid,
	};

	/* Flush all IO on task's files and close fds */
	task_close_files(task);

	/* Destroy task's utcb slot */
	task_destroy_utcb(task);

	/* Remove default shared page shm areas from vfs */
	// printf("Unmapping 0x%p from vfs as shared-page of %d\n", task->shared_page, task->tid);
	//shpage_unmap_from_task(task, find_task(VFS_TID));

	/* Free task's local tcb */
	tcb_destroy(task);

	/* Ask the kernel to delete the thread from its records */
	l4_thread_control(THREAD_DESTROY, &ids);

	/* TODO: Wake up any waiters about task's destruction */
#if 0
	struct tcb *parent = find_task(task->parentid);
	if (parent->waiting) {
		exregs_set_mr_return(status);
		l4_exchange_registers(parent->tid);
		l4_thread_control(THREAD_RUN, parent->tid);
	}
#endif
}

void sys_exit(struct tcb *task, int status)
{
	do_exit(task, status);
}

