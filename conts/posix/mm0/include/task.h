/*
 * Thread control block.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#ifndef __TASK_H__
#define __TASK_H__

#include <l4/macros.h>
#include <l4/types.h>
#include INC_GLUE(memlayout.h)
#include <l4/lib/list.h>
#include L4LIB_INC_ARCH(types.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/utcb.h>
#include <lib/addr.h>
#include <l4/api/kip.h>
#include <exec.h>

#define __TASKNAME__			__PAGERNAME__

#define ARGS_MAX			DEFAULT_ENV_SIZE
#define PATH_MAX			PAGE_SIZE

#define TASK_FILES_MAX			32

/* POSIX minimum is 4Kb */
#define DEFAULT_ENV_SIZE		SZ_4K
#define DEFAULT_STACK_SIZE		SZ_32K
#define DEFAULT_SHPAGE_SIZE		PAGE_SIZE
#define TASK_SIZE			0x10000000

#define TCB_NO_SHARING				0
#define	TCB_SHARED_VM				(1 << 0)
#define	TCB_SHARED_FILES			(1 << 1)
#define TCB_SHARED_FS				(1 << 2)
#define TCB_SHARED_TGROUP			(1 << 3)
#define TCB_SHARED_PARENT			(1 << 4)

struct vm_file;

struct file_descriptor {
	unsigned long cursor;
	struct vm_file *vmfile;
};

struct task_fd_head {
	struct file_descriptor fd[TASK_FILES_MAX];
	struct id_pool *fdpool;
	int tcb_refs;
};

struct task_vma_head {
	struct link list;
	int tcb_refs;
};

#define TCB_NO_SHARING				0
#define	TCB_SHARED_VM				(1 << 0)
#define	TCB_SHARED_FILES			(1 << 1)
#define TCB_SHARED_FS				(1 << 2)
#define TASK_FILES_MAX			32

struct task_fs_data {
	struct vnode *curdir;
	struct vnode *rootdir;
	int tcb_refs;
};

struct utcb_desc {
	struct link list;
	unsigned long utcb_base;
	struct id_pool *slots;
};

struct utcb_head {
	struct link list;
	int tcb_refs;
};


/* Stores all task information that can be kept in userspace. */
struct tcb {
	/* Task list */
	struct link list;

	/* Fields for parent-child relations */
	struct link child_ref;	/* Child ref in parent's list */
	struct link children;	/* List of children */
	struct tcb *parent;		/* Parent task */

	/* Task creation flags */
	unsigned int clone_flags;

	/* Name of the task */
	char name[16];

	/* Task ids */
	l4id_t tid;
	l4id_t spid;
	l4id_t tgid;

	/* Related task ids */
	unsigned int pagerid;		/* Task's pager */

	/* Task's main address space region, usually USER_AREA_START/END */
	unsigned long start;
	unsigned long end;

	/* Page aligned program segment marks, ends exclusive as usual */
	unsigned long entry;
	unsigned long text_start;
	unsigned long text_end;
	unsigned long data_start;
	unsigned long data_end;
	unsigned long bss_start;
	unsigned long bss_end;
	unsigned long stack_start;
	unsigned long stack_end;
	unsigned long heap_start;
	unsigned long heap_end;
	unsigned long args_start;
	unsigned long args_end;

	/* Task's mmappable region */
	unsigned long map_start;
	unsigned long map_end;

	/* Chain of utcb descriptors */
	struct utcb_head *utcb_head;

	/* Unique utcb address of this task */
	unsigned long utcb_address;

	/* Virtual memory areas */
	struct task_vma_head *vm_area_head;

	/* File descriptors for this task */
	struct task_fd_head *files;
	struct task_fs_data *fs_data;

};

struct tcb_head {
	struct link list;
	int total;			/* Total threads */
};

struct tcb *find_task(int tid);
void global_add_task(struct tcb *task);
void global_remove_task(struct tcb *task);
int task_mmap_segments(struct tcb *task, struct vm_file *file, struct exec_file_desc *efd,
			struct args_struct *args, struct args_struct *env);
int task_setup_registers(struct tcb *task, unsigned int pc,
			 unsigned int sp, l4id_t pager);
struct tcb *tcb_alloc_init(unsigned int flags);
int tcb_destroy(struct tcb *task);
int task_start(struct tcb *task);
int copy_tcb(struct tcb *to, struct tcb *from, unsigned int flags);
int task_release_vmas(struct task_vma_head *vma_head);
struct tcb *task_create(struct tcb *orig,
			struct task_ids *ids,
			unsigned int ctrl_flags,
			unsigned int alloc_flags);
int task_prefault_range(struct tcb *task, unsigned long start,
			unsigned long end, unsigned int vm_flags);

#endif /* __TASK_H__ */
