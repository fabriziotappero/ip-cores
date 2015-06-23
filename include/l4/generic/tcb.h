/*
 * Thread Control Block, kernel portion.
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */
#ifndef __TCB_H__
#define __TCB_H__

#include <l4/lib/list.h>
#include <l4/lib/mutex.h>
#include <l4/lib/spinlock.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/resource.h>
#include <l4/generic/capability.h>
#include <l4/generic/space.h>
#include INC_GLUE(memory.h)
#include INC_GLUE(syscall.h)
#include INC_GLUE(message.h)
#include INC_GLUE(context.h)
#include INC_SUBARCH(mm.h)


/*
 * These are a mixture of flags that indicate the task is
 * in a transitional state that could include one or more
 * scheduling states.
 */
#define TASK_INTERRUPTED		(1 << 0)
#define TASK_SUSPENDING			(1 << 1)
#define TASK_RESUMING			(1 << 2)
#define TASK_PENDING_SIGNAL		(TASK_SUSPENDING)
#define TASK_REALTIME			(1 << 5)

/*
 * This is to indicate a task (either current or one of
 * its children) exit has occured and cleanup needs to be
 * called
 */
#define TASK_EXITED			(1 << 3)

/* Task states */
enum task_state {
	TASK_INACTIVE	= 0,
	TASK_SLEEPING	= 1,
	TASK_RUNNABLE	= 2,
};

#define TASK_CID_MASK			0xFF000000
#define TASK_ID_MASK			0x00FFFFFF
#define TASK_CID_SHIFT			24

static inline l4id_t tid_to_cid(l4id_t tid)
{
	return (tid & TASK_CID_MASK) >> TASK_CID_SHIFT;
}

/* Values that rather have special meaning instead of an id value */
static inline int tid_special_value(l4id_t id)
{
	/* Special ids have top 2 nibbles all set */
	return (id & TASK_CID_MASK) == TASK_CID_MASK;
}

#define TASK_ID_INVALID			0xFFFFFFFF
struct task_ids {
	l4id_t tid;
	l4id_t spid;
	l4id_t tgid;
};

struct container;

struct ktcb {
	/* User context */
	task_context_t context;

	/*
	 * Reference to the context on stack
	 * saved at the beginning of a syscall trap.
	 */
	syscall_context_t *syscall_regs;

	/* Runqueue related */
	struct link rq_list;
	struct runqueue *rq;

	/* Thread Id information (See space for space id) */
	l4id_t tid;		/* Global thread id */
	l4id_t tgid;		/* Global thread group id */

	/* CPU affinity */
	int affinity;

	/* Other related threads */
	l4id_t pagerid;

	/* Flags to indicate various task status */
	unsigned int flags;

	/* IPC flags */
	unsigned int ipc_flags;

	/* Lock for blocking thread state modifications via a syscall */
	struct mutex thread_control_lock;

	/* To protect against thread deletion/modification */
	struct spinlock thread_lock;

	u32 ts_need_resched;	/* Scheduling flag */
	enum task_state state;

	struct link task_list; /* Global task list. */

	/* UTCB related, see utcb.txt in docs */
	unsigned long utcb_address;	/* Virtual ref to task's utcb area */

	/* Thread times */
	u32 kernel_time;	/* Ticks spent in kernel */
	u32 user_time;		/* Ticks spent in userland */
	u32 ticks_left;		/* Timeslice ticks left for reschedule */
	u32 ticks_assigned;	/* Ticks assigned to this task on this HZ */
	u32 sched_granule;	/* Granularity ticks left for reschedule */
	int priority;		/* Task's fixed, default priority */

	/* Number of locks the task currently has acquired */
	int nlocks;

	/* Task exit code */
	unsigned int exit_code;

	/* Page table information */
	struct address_space *space;

	/* Container */
	struct container *container;
	struct pager *pager;

	/* Capability lists */
	struct cap_list cap_list; /* Own private capabilities */

	/* Fields for ipc rendezvous */
	struct waitqueue_head wqh_recv;
	struct waitqueue_head wqh_send;
	l4id_t expected_sender;

	/* Waitqueue for notifiactions */
	struct waitqueue_head wqh_notify;

	/* Waitqueue for pagers to wait for task states */
	struct waitqueue_head wqh_pager;

	/* Tells where we are when we sleep */
	struct spinlock waitlock;
	struct waitqueue_head *waiting_on;
	struct waitqueue *wq;

	/*
	 * Extended ipc size and buffer that
	 * points to the space after ktcb
	 */
	unsigned long extended_ipc_size;
	char extended_ipc_buffer[];
};

/* Per thread kernel stack unified on a single page. */
union ktcb_union {
	struct ktcb ktcb;
	char kstack[PAGE_SIZE];
};

/*
 * Each task is allocated a unique global id. A thread group can only belong to
 * a single leader, and every thread can only belong to a single thread group.
 * These rules allow the fact that every global id can be used to define a
 * unique thread group id. Thread local ids are used as an index into the thread
 * group's utcb area to discover the per-thread utcb structure.
 */
static inline void set_task_ids(struct ktcb *task, struct task_ids *ids)
{
	task->tid = ids->tid;
	task->tgid = ids->tgid;
}

struct ktcb *tcb_find(l4id_t tid);
struct ktcb *tcb_find_lock(l4id_t tid);
void tcb_add(struct ktcb *tcb);
void tcb_remove(struct ktcb *tcb);

void tcb_init(struct ktcb *tcb);
struct ktcb *tcb_alloc_init(l4id_t cid);
void tcb_delete(struct ktcb *tcb);
void tcb_delete_zombies(void);

void ktcb_list_remove(struct ktcb *task, struct ktcb_list *ktcb_list);
void ktcb_list_add(struct ktcb *new, struct ktcb_list *ktcb_list);
void init_ktcb_list(struct ktcb_list *ktcb_list);
void task_update_utcb(struct ktcb *task);
int tcb_check_and_lazy_map_utcb(struct ktcb *task, int page_in);

#endif /* __TCB_H__ */

