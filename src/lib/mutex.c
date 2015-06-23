/*
 * Mutex/Semaphore implementations.
 *
 * Copyright (c) 2007 Bahadir Balban
 */
#include <l4/lib/mutex.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/tcb.h>
#include <l4/api/errno.h>

/*
 * Semaphore usage:
 *
 * Producer locks/produces/unlocks data.
 * Producer does semaphore up.
 * --
 * Consumer does semaphore down.
 * Consumer locks/consumes/unlocks data.
 */

#if 0
/* Update it */
/*
 * Semaphore *up* for multiple producers. If any consumer is waiting, wake them
 * up, otherwise, sleep. Effectively producers and consumers use the same
 * waitqueue and there's only one kind in the queue at any one time.
 */
void sem_up(struct mutex *mutex)
{
	int cnt;

	spin_lock(&mutex->slock);
	if ((cnt = mutex_inc(&mutex->lock)) <= 0) {
		struct waitqueue *wq;
		struct ktcb *sleeper;

		/* Each producer wakes one consumer in queue. */
		mutex->sleepers--;
		BUG_ON(list_empty(&mutex->wq.task_list));
		list_foreach_struct(wq, &mutex->wq.task_list, task_list) {
			list_remove_init(&wq->task_list);
			spin_unlock(&mutex->slock);
			sleeper = wq->task;
			printk("(%d) Waking up consumer (%d)\n", current->tid,
			       sleeper->tid);
			sched_resume_task(sleeper);
			return;	/* Don't iterate, wake only one task. */
		}
	} else if (cnt > 0) {
		DECLARE_WAITQUEUE(wq, current);
		link_init(&wq.task_list);
		list_insert_tail(&wq.task_list, &mutex->wq.task_list);
		mutex->sleepers++;
		sched_prepare_sleep();
		printk("(%d) produced, now sleeping...\n", current->tid);
		spin_unlock(&mutex->slock);
		schedule();
	}
}

/*
 * Semaphore *down* for multiple consumers. If any producer is sleeping, wake them
 * up, otherwise, sleep. Effectively producers and consumers use the same
 * waitqueue and there's only one kind in the queue at any one time.
 */
void sem_down(struct mutex *mutex)
{
	int cnt;

	spin_lock(&mutex->slock);
	if ((cnt = mutex_dec(&mutex->lock)) >= 0) {
		struct waitqueue *wq;
		struct ktcb *sleeper;

		/* Each consumer wakes one producer in queue. */
		mutex->sleepers--;
		BUG_ON(list_empty(&mutex->wq.task_list));
		list_foreach_struct(wq, &mutex->wq.task_list, task_list) {
			list_remove_init(&wq->task_list);
			spin_unlock(&mutex->slock);
			sleeper = wq->task;
			printk("(%d) Waking up producer (%d)\n", current->tid,
			       sleeper->tid);
			sched_resume_task(sleeper);
			return;	/* Don't iterate, wake only one task. */
		}
	} else if (cnt < 0) {
		DECLARE_WAITQUEUE(wq, current);
		link_init(&wq.task_list);
		list_insert_tail(&wq.task_list, &mutex->wq.task_list);
		mutex->sleepers++;
		sched_prepare_sleep();
		printk("(%d) Waiting to consume, now sleeping...\n", current->tid);
		spin_unlock(&mutex->slock);
		schedule();
	}
}
#endif

/* Non-blocking attempt to lock mutex */
int mutex_trylock(struct mutex *mutex)
{
	int success;

	spin_lock(&mutex->wqh.slock);
	if ((success = __mutex_lock(&mutex->lock)))
		current->nlocks++;
	spin_unlock(&mutex->wqh.slock);

	return success;
}

int mutex_lock(struct mutex *mutex)
{
	/* NOTE:
	 * Everytime we're woken up we retry acquiring the mutex. It is
	 * undeterministic as to how many retries will result in success.
	 * We may need to add priority-based locking.
	 */
	for (;;) {
		spin_lock(&mutex->wqh.slock);
		if (!__mutex_lock(&mutex->lock)) { /* Could not lock, sleep. */
			CREATE_WAITQUEUE_ON_STACK(wq, current);
			task_set_wqh(current, &mutex->wqh, &wq);
			list_insert_tail(&wq.task_list, &mutex->wqh.task_list);
			mutex->wqh.sleepers++;
			sched_prepare_sleep();
			spin_unlock(&mutex->wqh.slock);
			// printk("(%d) sleeping...\n", current->tid);
			schedule();

			/* Did we wake up normally or get interrupted */
			if (current->flags & TASK_INTERRUPTED) {
				current->flags &= ~TASK_INTERRUPTED;
				return -EINTR;
			}
		} else {
			current->nlocks++;
			break;
		}
	}
	spin_unlock(&mutex->wqh.slock);
	return 0;
}

static inline void mutex_unlock_common(struct mutex *mutex, int sync)
{
	struct ktcb *c = current; if (c);
	spin_lock(&mutex->wqh.slock);
	__mutex_unlock(&mutex->lock);
	current->nlocks--;
	BUG_ON(current->nlocks < 0);
	BUG_ON(mutex->wqh.sleepers < 0);
	if (mutex->wqh.sleepers > 0) {
		struct waitqueue *wq = link_to_struct(mutex->wqh.task_list.next,
						      struct waitqueue,
						      task_list);
		struct ktcb *sleeper = wq->task;

		task_unset_wqh(sleeper);
		BUG_ON(list_empty(&mutex->wqh.task_list));
		list_remove_init(&wq->task_list);
		mutex->wqh.sleepers--;
		spin_unlock(&mutex->wqh.slock);

		/*
		 * TODO:
		 * Here someone could grab the mutex, this is fine
		 * but it may potentially starve the sleeper causing
		 * non-determinism. We may consider priorities here.
		 */
		if (sync)
			sched_resume_sync(sleeper);
		else
			sched_resume_async(sleeper);

		/* Don't iterate, wake only one task. */
		return;
	}
	spin_unlock(&mutex->wqh.slock);
}

void mutex_unlock(struct mutex *mutex)
{
	mutex_unlock_common(mutex, 1);
}

void mutex_unlock_async(struct mutex *mutex)
{
	mutex_unlock_common(mutex, 0);
}

