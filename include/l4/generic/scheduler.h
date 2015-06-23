/*
 * Scheduler and runqueue API definitions.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#ifndef __SCHEDULER_H__
#define __SCHEDULER_H__

#include <l4/generic/tcb.h>
#include <l4/generic/smp.h>
#include INC_SUBARCH(cpu.h)
#include INC_SUBARCH(mm.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(smp.h)

/* Task priorities */
#define TASK_PRIO_MAX		10
#define TASK_PRIO_REALTIME	10
#define TASK_PRIO_PAGER		8
#define TASK_PRIO_SERVER	6
#define TASK_PRIO_NORMAL	4
#define TASK_PRIO_LOW		2
#define TASK_PRIO_TOTAL		30

/*
 * CONFIG_SCHED_TICKS gives ticks per second.
 * try ticks = 1000, and timeslice = 1 for regressed preemption test.
 */

/*
 * A task can run continuously at this granularity,
 * even if it has a greater total time slice.
 */
#define SCHED_GRANULARITY			CONFIG_SCHED_TICKS/10

static inline struct ktcb *current_task(void)
{
	register u32 stack asm("sp");
	return (struct ktcb *)(stack & (~PAGE_MASK));
}

#define current			current_task()
#define need_resched		(current->ts_need_resched)

#define SCHED_RQ_TOTAL			4

/* A basic runqueue */
struct runqueue {
	struct scheduler *sched;
	struct spinlock lock;		/* Lock */
	struct link task_list;		/* List of tasks in rq */
	unsigned int total;		/* Total tasks */
};

/*
 * Hints and flags to scheduler
 */
enum sched_flags {
	/* Schedule idle at a convenient time */
	SCHED_RUN_IDLE = (1 << 0),
};

/* Contains per-container scheduling structures */
struct scheduler {
	unsigned int flags;
	unsigned int task_select_ctr;
	struct runqueue sched_rq[SCHED_RQ_TOTAL];

	/* Regular runqueues */
	struct runqueue *rq_runnable;
	struct runqueue *rq_expired;

	/* Real-time runqueues */
	struct runqueue *rq_rt_runnable;
	struct runqueue *rq_rt_expired;

	struct ktcb *idle_task;

	/* Total priority of all tasks in container */
	int prio_total;
};

DECLARE_PERCPU(extern struct scheduler, scheduler);

void sched_init_runqueue(struct scheduler *sched, struct runqueue *rq);
void sched_init_task(struct ktcb *task, int priority);
void sched_prepare_sleep(void);
void sched_suspend_sync(void);
void sched_suspend_async(void);
void sched_resume_sync(struct ktcb *task);
void sched_resume_async(struct ktcb *task);
void sched_enqueue_task(struct ktcb *first_time_runner, int sync);
void scheduler_start(void);
void schedule(void);
void sched_init(void);
void idle_task(void);

#endif /* __SCHEDULER_H__ */
