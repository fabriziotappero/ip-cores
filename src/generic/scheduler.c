/*
 * A basic priority-based scheduler.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <l4/lib/list.h>
#include <l4/lib/printk.h>
#include <l4/lib/string.h>
#include <l4/lib/mutex.h>
#include <l4/lib/math.h>
#include <l4/lib/bit.h>
#include <l4/lib/spinlock.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/resource.h>
#include <l4/generic/container.h>
#include <l4/generic/preempt.h>
#include <l4/generic/thread.h>
#include <l4/generic/debug.h>
#include <l4/generic/irq.h>
#include <l4/generic/tcb.h>
#include <l4/api/errno.h>
#include <l4/api/kip.h>
#include INC_SUBARCH(mm.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(init.h)
#include INC_PLAT(platform.h)
#include INC_ARCH(exception.h)
#include INC_SUBARCH(irq.h)

DECLARE_PERCPU(struct scheduler, scheduler);

/* This is incremented on each irq or voluntarily by preempt_disable() */
DECLARE_PERCPU(extern unsigned int, current_irq_nest_count);

/* This ensures no scheduling occurs after voluntary preempt_disable() */
DECLARE_PERCPU(static int, voluntary_preempt);

void sched_lock_runqueues(struct scheduler *sched, unsigned long *irqflags)
{
	spin_lock_irq(&sched->sched_rq[0].lock, irqflags);
	spin_lock(&sched->sched_rq[1].lock);
	BUG_ON(irqs_enabled());
}

void sched_unlock_runqueues(struct scheduler *sched, unsigned long irqflags)
{
	spin_unlock(&sched->sched_rq[1].lock);
	spin_unlock_irq(&sched->sched_rq[0].lock, irqflags);
}

int preemptive()
{
	return per_cpu(current_irq_nest_count) == 0;
}

int preempt_count()
{
	return per_cpu(current_irq_nest_count);
}

#if !defined(CONFIG_PREEMPT_DISABLE)

void preempt_enable(void)
{
	per_cpu(voluntary_preempt)--;
	per_cpu(current_irq_nest_count)--;
}

/* A positive irq nest count implies current context cannot be preempted. */
void preempt_disable(void)
{
	per_cpu(current_irq_nest_count)++;
	per_cpu(voluntary_preempt)++;
}

#else /* End of !CONFIG_PREEMPT_DISABLE */

void preempt_enable(void) { }
void preempt_disable(void) { }

#endif /* CONFIG_PREEMPT_DISABLE */

int in_irq_context(void)
{
	/*
	 * If there was a real irq, irq nest count must be
	 * one more than all preempt_disable()'s which are
	 * counted by voluntary_preempt.
	 */
	return (per_cpu(current_irq_nest_count) ==
	        (per_cpu(voluntary_preempt) + 1));
}

int in_nested_irq_context(void)
{
	/* Deducing voluntary preemptions we get real irq nesting */
	return (per_cpu(current_irq_nest_count) -
		per_cpu(voluntary_preempt)) > 1;
}

int in_process_context(void)
{
	return !in_irq_context();
}

void sched_init_runqueue(struct scheduler *sched, struct runqueue *rq)
{
	link_init(&rq->task_list);
	spin_lock_init(&rq->lock);
	rq->sched = sched;
}

void sched_init()
{
	struct scheduler *sched = &per_cpu(scheduler);

	for (int i = 0; i < SCHED_RQ_TOTAL; i++)
		sched_init_runqueue(sched, &sched->sched_rq[i]);

	sched->rq_runnable = &sched->sched_rq[0];
	sched->rq_expired = &sched->sched_rq[1];
	sched->rq_rt_runnable = &sched->sched_rq[2];
	sched->rq_rt_expired = &sched->sched_rq[3];
	sched->prio_total = TASK_PRIO_TOTAL;
	sched->idle_task = current;
}

/* Swap runnable and expired runqueues. */
static void sched_rq_swap_queues(void)
{
	struct runqueue *temp;

	BUG_ON(list_empty(&per_cpu(scheduler).rq_expired->task_list));

	/* Queues are swapped and expired list becomes runnable */
	temp = per_cpu(scheduler).rq_runnable;
	per_cpu(scheduler).rq_runnable = per_cpu(scheduler).rq_expired;
	per_cpu(scheduler).rq_expired = temp;
}

static void sched_rq_swap_rtqueues(void)
{
	struct runqueue *temp;

	BUG_ON(list_empty(&per_cpu(scheduler).rq_rt_expired->task_list));

	/* Queues are swapped and expired list becomes runnable */
	temp = per_cpu(scheduler).rq_rt_runnable;
	per_cpu(scheduler).rq_rt_runnable = per_cpu(scheduler).rq_rt_expired;
	per_cpu(scheduler).rq_rt_expired = temp;
}

/* Set policy on where to add tasks in the runqueue */
#define RQ_ADD_BEHIND		0
#define RQ_ADD_FRONT		1

/* Helper for adding a new task to a runqueue */
static void sched_rq_add_task(struct ktcb *task, struct runqueue *rq, int front)
{
	unsigned long irqflags;
	struct scheduler *sched =
		&per_cpu_byid(scheduler, task->affinity);

	BUG_ON(!list_empty(&task->rq_list));

	/* Lock that particular cpu's runqueue set */
	sched_lock_runqueues(sched, &irqflags);
	if (front)
		list_insert(&task->rq_list, &rq->task_list);
	else
		list_insert_tail(&task->rq_list, &rq->task_list);
	rq->total++;
	task->rq = rq;

	/* Unlock that particular cpu's runqueue set */
	sched_unlock_runqueues(sched, irqflags);
}

/* Helper for removing a task from its runqueue. */
static inline void sched_rq_remove_task(struct ktcb *task)
{
	unsigned long irqflags;
	struct scheduler *sched =
		&per_cpu_byid(scheduler, task->affinity);

	sched_lock_runqueues(sched, &irqflags);

	/*
	 * We must lock both, otherwise rqs may swap and
	 * we may get the wrong rq.
	 */
	BUG_ON(list_empty(&task->rq_list));
	list_remove_init(&task->rq_list);

	task->rq->total--;
	BUG_ON(task->rq->total < 0);
	task->rq = 0;

	sched_unlock_runqueues(sched, irqflags);
}

static inline void
sched_run_task(struct ktcb *task, struct scheduler *sched)
{
	if (task->flags & TASK_REALTIME)
		sched_rq_add_task(task, sched->rq_rt_runnable,
				  RQ_ADD_BEHIND);
	else
		sched_rq_add_task(task, sched->rq_runnable,
				  RQ_ADD_BEHIND);
}

static inline void
sched_expire_task(struct ktcb *task, struct scheduler *sched)
{

	if (task->flags & TASK_REALTIME)
		sched_rq_add_task(current, sched->rq_rt_expired,
				  RQ_ADD_BEHIND);
	else
		sched_rq_add_task(current, sched->rq_expired,
				  RQ_ADD_BEHIND);
}

void sched_init_task(struct ktcb *task, int prio)
{
	link_init(&task->rq_list);
	task->priority = prio;
	task->ticks_left = 0;
	task->state = TASK_INACTIVE;
	task->ts_need_resched = 0;
	task->flags |= TASK_RESUMING;
}

/* Synchronously resumes a task */
void sched_resume_sync(struct ktcb *task)
{
	BUG_ON(task == current);
	task->state = TASK_RUNNABLE;
	sched_run_task(task, &per_cpu_byid(scheduler, task->affinity));
	schedule();
}

/*
 * Asynchronously resumes a task.
 * The task will run in the future, but at
 * the scheduler's discretion. It is possible that current
 * task wakes itself up via this function in the scheduler().
 */
void sched_resume_async(struct ktcb *task)
{
	task->state = TASK_RUNNABLE;
	sched_run_task(task, &per_cpu_byid(scheduler, task->affinity));
}

/*
 * Takes all the action that will make a task sleep
 * in the scheduler. If the task is woken up before
 * it schedules, then operations here are simply
 * undone and task remains as runnable.
 */
void sched_prepare_sleep()
{
	preempt_disable();
	sched_rq_remove_task(current);
	current->state = TASK_SLEEPING;
	preempt_enable();
}

/*
 * preempt_enable/disable()'s are for avoiding the
 * entry to scheduler during this period - but this
 * is only true for current cpu.
 */
void sched_suspend_sync(void)
{
	preempt_disable();
	sched_rq_remove_task(current);
	current->state = TASK_INACTIVE;
	current->flags &= ~TASK_SUSPENDING;

	if (current->pagerid != current->tid)
		wake_up(&current->wqh_pager, 0);
	preempt_enable();

	schedule();
}

void sched_suspend_async(void)
{
	preempt_disable();
	sched_rq_remove_task(current);
	current->state = TASK_INACTIVE;
	current->flags &= ~TASK_SUSPENDING;

	if (current->pagerid != current->tid)
		wake_up(&current->wqh_pager, 0);
	preempt_enable();

	need_resched = 1;
}


extern void arch_context_switch(struct ktcb *cur, struct ktcb *next);

static inline void context_switch(struct ktcb *next)
{
	struct ktcb *cur = current;

//	printk("Core:%d (%d) to (%d)\n", smp_get_cpuid(), cur->tid, next->tid);

	system_account_context_switch();

	/* Flush caches and everything */
	BUG_ON(!current);
	BUG_ON(!current->space);
	BUG_ON(!next);
	BUG_ON(!next->space);
	BUG_ON(!next->space);
	if (current->space->spid != next->space->spid)
		arch_space_switch(next);

	/* Update utcb region for next task */
	task_update_utcb(next);

	/* Switch context */
	arch_context_switch(cur, next);

	// printk("Returning from yield. Tid: (%d)\n", cur->tid);
}

/*
 * Priority calculation is so simple it is inlined. The task gets
 * the ratio of its priority to total priority of all runnable tasks.
 */
static inline int sched_recalc_ticks(struct ktcb *task, int prio_total)
{
	BUG_ON(prio_total < task->priority);
	BUG_ON(prio_total == 0);
	return task->ticks_assigned =
		CONFIG_SCHED_TICKS * task->priority / prio_total;
}

/*
 * Select a real-time task 1/8th of any one selection
 */
static inline int sched_select_rt(struct scheduler *sched)
{
	int ctr = sched->task_select_ctr++ & 0xF;

	if (ctr == 0 || ctr == 8 || ctr == 15)
		return 0;
	else
		return 1;
}

/*
 * Selection happens as follows:
 *
 * A real-time task is chosen %87.5 of the time. This is evenly
 * distributed to a given interval.
 *
 * Idle task is run once when it is explicitly suggested (e.g.
 * for cleanup after a task exited) but only when no real-time
 * tasks are in the queues.
 *
 * And idle task is otherwise run only when no other tasks are
 * runnable.
 */
struct ktcb *sched_select_next(void)
{
	struct scheduler *sched = &per_cpu(scheduler);
	int realtime = sched_select_rt(sched);
	struct ktcb *next = 0;

	for (;;) {

		/* Decision to run an RT task? */
		if (realtime && sched->rq_rt_runnable->total > 0) {
			/* Get a real-time task, if available */
			next = link_to_struct(sched->rq_rt_runnable->task_list.next,
					      struct ktcb, rq_list);
			break;
		} else if (realtime && sched->rq_rt_expired->total > 0) {
			/* Swap real-time queues */
			sched_rq_swap_rtqueues();
			/* Get a real-time task */
			next = link_to_struct(sched->rq_rt_runnable->task_list.next,
					      struct ktcb, rq_list);
			break;
		/* Idle flagged for run? */
		} else if (sched->flags & SCHED_RUN_IDLE) {
			/* Clear idle flag */
			sched->flags &= ~SCHED_RUN_IDLE;
			next = sched->idle_task;
			break;
		} else if (sched->rq_runnable->total > 0) {
			/* Get a regular runnable task, if available */
			next = link_to_struct(sched->rq_runnable->task_list.next,
					      struct ktcb, rq_list);
			break;
		} else if (sched->rq_expired->total > 0) {
			/* Swap queues and retry if not */
			sched_rq_swap_queues();
			next = link_to_struct(sched->rq_runnable->task_list.next,
					      struct ktcb, rq_list);
			break;
		} else if (in_process_context()) {
			/* No runnable task. Do idle if in process context */
			next = sched->idle_task;
			break;
		} else {
			/*
			 * Nobody is runnable. Irq calls must return
			 * to interrupted current process to run idle task
			 */
			next = current;
			break;
		}
	}
	return next;
}

/* Prepare next runnable task right before switching to it */
void sched_prepare_next(struct ktcb *next)
{
	/* New tasks affect runqueue total priority. */
	if (next->flags & TASK_RESUMING)
		next->flags &= ~TASK_RESUMING;

	/* Zero ticks indicates task hasn't ran since last rq swap */
	if (next->ticks_left == 0) {
		/*
		 * Redistribute timeslice. We do this as each task
		 * becomes runnable rather than all at once. It is done
		 * every runqueue swap
		 */
		sched_recalc_ticks(next, per_cpu(scheduler).prio_total);
		next->ticks_left = next->ticks_assigned;
	}

	/* Reinitialise task's schedule granularity boundary */
	next->sched_granule = SCHED_GRANULARITY;
}

/*
 * Tasks come here, either by setting need_resched (via next irq),
 * or by directly calling it (in process context).
 *
 * The scheduler is similar to Linux's so called O(1) scheduler,
 * although a lot simpler. Task priorities determine task timeslices.
 * Each task gets a ratio of its priority to the total priority of
 * all runnable tasks. When this total changes, (e.g. threads die or
 * are created, or a thread's priority is changed) the timeslices are
 * recalculated on a per-task basis as each thread becomes runnable.
 * Once all runnable tasks expire, runqueues are swapped. Sleeping
 * tasks are removed from the runnable queue, and added back later
 * without affecting the timeslices. Suspended tasks however,
 * necessitate a timeslice recalculation as they are considered to go
 * inactive indefinitely or for a very long time. They are put back
 * to the expired queue if they want to run again.
 *
 * A task is rescheduled either when it hits a SCHED_GRANULARITY
 * boundary, or when its timeslice has expired. SCHED_GRANULARITY
 * ensures context switches do occur at a maximum boundary even if a
 * task's timeslice is very long. In the future, real-time tasks will
 * be added, and they will be able to ignore SCHED_GRANULARITY.
 *
 * In the future, the tasks will be sorted by priority in their
 * runqueue, as well as having an adjusted timeslice.
 *
 * Runqueues are swapped at a single second's interval. This implies
 * the timeslice recalculations would also occur at this interval.
 */
void schedule()
{
	struct ktcb *next;

	/* Should not schedule with preemption
	 * disabled or in nested irq */
	BUG_ON(per_cpu(voluntary_preempt));
	BUG_ON(in_nested_irq_context());

	/* Should not have more ticks than SCHED_TICKS */
	BUG_ON(current->ticks_left > CONFIG_SCHED_TICKS);

	/* If coming from process path, cannot have
	 * any irqs that schedule after this */
	preempt_disable();

	/* Reset schedule flag */
	need_resched = 0;

	/* Remove from runnable and put into appropriate runqueue */
	if (current->state == TASK_RUNNABLE) {
		sched_rq_remove_task(current);
		if (current->ticks_left)
			sched_run_task(current, &per_cpu(scheduler));
		else
			sched_expire_task(current, &per_cpu(scheduler));
	}

	/*
	 * FIXME: Are these smp-safe? BB: On first glance they
	 * should be because runqueues are per-cpu right now.
	 *
	 * If task is about to sleep and
	 * it has pending events, wake it up.
	 */
	if ((current->flags & TASK_PENDING_SIGNAL) &&
	    current->state == TASK_SLEEPING)
		wake_up_task(current, WAKEUP_INTERRUPT);

	/*
	 * If task has pending events, and is in userspace
	 * (guaranteed to have no unfinished jobs in kernel)
	 * handle those events
	 */
	if ((current->flags & TASK_PENDING_SIGNAL) &&
	    current->state == TASK_RUNNABLE &&
	    TASK_IN_USER(current)) {
		if (current->flags & TASK_SUSPENDING)
			sched_suspend_async();
	}

	/* Hint scheduler to run idle asap to free task */
	if (current->flags & TASK_EXITED) {
		current->flags &= ~TASK_EXITED;
		per_cpu(scheduler).flags |= SCHED_RUN_IDLE;
	}

	/* Decide on next runnable task */
	next = sched_select_next();

	/* Prepare next task for running */
	sched_prepare_next(next);

	/* Finish */
	disable_irqs();
	preempt_enable();
	context_switch(next);
}

/*
 * Start the timer and switch to current task
 * for first-ever scheduling.
 */
void scheduler_start()
{
	platform_timer_start();
	switch_to_user(current);
}

