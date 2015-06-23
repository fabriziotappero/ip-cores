/*
 * Implementation of wakeup/wait for processes.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <l4/generic/scheduler.h>
#include <l4/lib/wait.h>
#include <l4/lib/spinlock.h>
#include <l4/api/errno.h>

/*
 * This sets any wait details of a task so that any arbitrary
 * wakers can know where the task is sleeping.
 */
void task_set_wqh(struct ktcb *task, struct waitqueue_head *wqh,
		  struct waitqueue *wq)
{
	unsigned long irqflags;

	spin_lock_irq(&task->waitlock, &irqflags);
	task->waiting_on = wqh;
	task->wq = wq;
	spin_unlock_irq(&task->waitlock, irqflags);
}


/*
 * This clears all wait details of a task. Used as the
 * task is removed from its queue and is about to wake up.
 */
void task_unset_wqh(struct ktcb *task)
{
	unsigned long irqflags;

	spin_lock_irq(&task->waitlock, &irqflags);
	task->waiting_on = 0;
	task->wq = 0;
	spin_unlock_irq(&task->waitlock, irqflags);

}

/*
 * Initiate wait on current task that
 * has already been placed in a waitqueue
 *
 * NOTE: This enables preemption and wait_on_prepare()
 * should be called first.
 */
int wait_on_prepared_wait(void)
{
	/* Now safe to sleep by preemption */
	preempt_enable();

	/* Sleep voluntarily to initiate wait */
	schedule();

	/* Did we wake up normally or get interrupted */
	if (current->flags & TASK_INTERRUPTED) {
		current->flags &= ~TASK_INTERRUPTED;
		return -EINTR;
	}
	/* No errors */
	return 0;
}

/*
 * Do all preparations to sleep but return without sleeping.
 * This is useful if the task needs to get in the waitqueue before
 * it releases a lock.
 *
 * NOTE: This disables preemption and it should be enabled by a
 * call to wait_on_prepared_wait() - the other function of the pair.
 */
int wait_on_prepare(struct waitqueue_head *wqh, struct waitqueue *wq)
{
	unsigned long irqflags;

	/* Disable to protect from sleeping by preemption */
	preempt_disable();

	spin_lock_irq(&wqh->slock, &irqflags);
	wqh->sleepers++;
	list_insert_tail(&wq->task_list, &wqh->task_list);
	task_set_wqh(current, wqh, wq);
	sched_prepare_sleep();
	//printk("(%d) waiting on wqh at: 0x%p\n",
	//       current->tid, wqh);
	spin_unlock_irq(&wqh->slock, irqflags);

	return 0;
}

/* Sleep without any condition */
int wait_on(struct waitqueue_head *wqh)
{
	unsigned long irqsave;

	CREATE_WAITQUEUE_ON_STACK(wq, current);
	spin_lock_irq(&wqh->slock, &irqsave);
	wqh->sleepers++;
	list_insert_tail(&wq.task_list, &wqh->task_list);
	task_set_wqh(current, wqh, &wq);
	sched_prepare_sleep();
	//printk("(%d) waiting on wqh at: 0x%p\n",
	//       current->tid, wqh);
	spin_unlock_irq(&wqh->slock, irqsave);
	schedule();

	/* Did we wake up normally or get interrupted */
	if (current->flags & TASK_INTERRUPTED) {
		current->flags &= ~TASK_INTERRUPTED;
		return -EINTR;
	}

	return 0;
}

/* Wake up all in the queue */
void wake_up_all(struct waitqueue_head *wqh, unsigned int flags)
{
	unsigned long irqsave;

	spin_lock_irq(&wqh->slock, &irqsave);
	BUG_ON(wqh->sleepers < 0);
	while (wqh->sleepers > 0) {
		struct waitqueue *wq = link_to_struct(wqh->task_list.next,
						  struct waitqueue,
						  task_list);
		struct ktcb *sleeper = wq->task;
		task_unset_wqh(sleeper);
		BUG_ON(list_empty(&wqh->task_list));
		list_remove_init(&wq->task_list);
		wqh->sleepers--;
		if (flags & WAKEUP_INTERRUPT)
			sleeper->flags |= TASK_INTERRUPTED;
		// printk("(%d) Waking up (%d)\n", current->tid, sleeper->tid);
		spin_unlock_irq(&wqh->slock, irqsave);

		if (flags & WAKEUP_SYNC)
			sched_resume_sync(sleeper);
		else
			sched_resume_async(sleeper);

		spin_lock_irq(&wqh->slock, &irqsave);
	}
	spin_unlock_irq(&wqh->slock, irqsave);
}

/* Wake up single waiter */
void wake_up(struct waitqueue_head *wqh, unsigned int flags)
{
	unsigned long irqflags;

	BUG_ON(wqh->sleepers < 0);

	spin_lock_irq(&wqh->slock, &irqflags);

	if (wqh->sleepers > 0) {
		struct waitqueue *wq = link_to_struct(wqh->task_list.next,
						      struct waitqueue,
						      task_list);
		struct ktcb *sleeper = wq->task;
		BUG_ON(list_empty(&wqh->task_list));
		list_remove_init(&wq->task_list);
		wqh->sleepers--;
		task_unset_wqh(sleeper);
		if (flags & WAKEUP_INTERRUPT)
			sleeper->flags |= TASK_INTERRUPTED;
		// printk("(%d) Waking up (%d)\n", current->tid, sleeper->tid);
		spin_unlock_irq(&wqh->slock, irqflags);

		if (flags & WAKEUP_SYNC)
			sched_resume_sync(sleeper);
		else
			sched_resume_async(sleeper);
		return;
	}
	spin_unlock_irq(&wqh->slock, irqflags);
}

/*
 * Wakes up a task. If task is not waiting, or has been woken up
 * as we were peeking on it, returns -1. @sync makes us immediately
 * yield or else leave it to scheduler's discretion.
 */
int wake_up_task(struct ktcb *task, unsigned int flags)
{
	unsigned long irqflags[2];
	struct waitqueue_head *wqh;
	struct waitqueue *wq;

	spin_lock_irq(&task->waitlock, &irqflags[0]);
	if (!task->waiting_on) {
		spin_unlock_irq(&task->waitlock, irqflags[0]);
		return -1;
	}
	wqh = task->waiting_on;
	wq = task->wq;

	/*
	 * We have found the waitqueue head.
	 *
	 * That needs to be locked first to conform with
	 * lock order and avoid deadlocks. Release task's
	 * waitlock and take the wqh's one.
	 */
	spin_unlock_irq(&task->waitlock, irqflags[0]);

	/*
	 * Task can be woken up by someone else here.
	 */

	spin_lock_irq(&wqh->slock, &irqflags[0]);

	/*
	 * Now lets check if the task is still
	 * waiting and in the same queue. Not irq version
	 * as we called that once already (so irqs are disabled)
	 */
	spin_lock_irq(&task->waitlock, &irqflags[1]);
	if (task->waiting_on != wqh) {
		/* No, task has been woken by someone else */
		spin_unlock_irq(&wqh->slock, irqflags[0]);
		spin_unlock_irq(&task->waitlock, irqflags[1]);
		return -1;
	}

	/* Now we can remove the task from its waitqueue */
	list_remove_init(&wq->task_list);
	wqh->sleepers--;
	task->waiting_on = 0;
	task->wq = 0;
	if (flags & WAKEUP_INTERRUPT)
		task->flags |= TASK_INTERRUPTED;
	spin_unlock_irq(&wqh->slock, irqflags[0]);
	spin_unlock_irq(&task->waitlock, irqflags[1]);

	/*
	 * Task is removed from its waitqueue. Now we can
	 * safely resume it without locks as this is the only
	 * code path that can resume the task.
	 */
	if (flags & WAKEUP_SYNC)
		sched_resume_sync(task);
	else
		sched_resume_async(task);

	return 0;
}

