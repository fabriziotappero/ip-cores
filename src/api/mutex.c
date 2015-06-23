/*
 * Userspace mutex implementation
 *
 * Copyright (C) 2009 Bahadir Bilgehan Balban
 */
#include <l4/lib/wait.h>
#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/container.h>
#include <l4/generic/tcb.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include <l4/api/mutex.h>
#include INC_API(syscall.h)
#include INC_ARCH(exception.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)

void init_mutex_queue_head(struct mutex_queue_head *mqhead)
{
	memset(mqhead, 0, sizeof(*mqhead));
	link_init(&mqhead->list);
	mutex_init(&mqhead->mutex_control_mutex);
}

void mutex_queue_head_lock(struct mutex_queue_head *mqhead)
{
	mutex_lock(&mqhead->mutex_control_mutex);
}

void mutex_queue_head_unlock(struct mutex_queue_head *mqhead)
{
	/* Async unlock because in some cases preemption may be disabled here */
	mutex_unlock_async(&mqhead->mutex_control_mutex);
}


void mutex_queue_init(struct mutex_queue *mq, unsigned long physical)
{
	/* This is the unique key that describes this mutex */
	mq->physical = physical;

	link_init(&mq->list);
	waitqueue_head_init(&mq->wqh_holders);
	waitqueue_head_init(&mq->wqh_contenders);
}

void mutex_control_add(struct mutex_queue_head *mqhead, struct mutex_queue *mq)
{
	BUG_ON(!list_empty(&mq->list));

	list_insert(&mq->list, &mqhead->list);
	mqhead->count++;
}

void mutex_control_remove(struct mutex_queue_head *mqhead, struct mutex_queue *mq)
{
	list_remove_init(&mq->list);
	mqhead->count--;
}

/* Note, this has ptr/negative error returns instead of ptr/zero. */
struct mutex_queue *mutex_control_find(struct mutex_queue_head *mqhead,
				       unsigned long mutex_physical)
{
	struct mutex_queue *mutex_queue;

	/* Find the mutex queue with this key */
	list_foreach_struct(mutex_queue, &mqhead->list, list)
		if (mutex_queue->physical == mutex_physical)
			return mutex_queue;

	return 0;
}

struct mutex_queue *mutex_control_create(unsigned long mutex_physical)
{
	struct mutex_queue *mutex_queue;

	/* Allocate the mutex queue structure */
	if (!(mutex_queue = alloc_user_mutex()))
		return 0;

	/* Init and return */
	mutex_queue_init(mutex_queue, mutex_physical);

	return mutex_queue;
}

void mutex_control_delete(struct mutex_queue *mq)
{
	BUG_ON(!list_empty(&mq->list));

	/* Test internals of waitqueue */
	BUG_ON(mq->wqh_contenders.sleepers);
	BUG_ON(mq->wqh_holders.sleepers);
	BUG_ON(!list_empty(&mq->wqh_contenders.task_list));
	BUG_ON(!list_empty(&mq->wqh_holders.task_list));

	free_user_mutex(mq);
}

/*
 * Here's how this whole mutex implementation works:
 *
 * A thread who locked a user mutex learns how many
 * contentions were on it as it unlocks it. It is obliged to
 * go to the kernel to wake that many threads up.
 *
 * Each contender sleeps in the kernel, but the time
 * of arrival in the kernel by both the unlocker or
 * contenders is asynchronous.
 *
 * Mutex queue scenarios at any one time:
 *
 * 1) There may be multiple contenders waiting for
 * an earlier lock holder:
 *
 * Lock holders waitqueue: Empty
 * Contenders waitqueue:   C - C - C - C
 * Contenders to wake up: 0
 *
 * The lock holder would wake up that many contenders that it counted
 * earlier in userspace as it released the lock.
 *
 * 2) There may be one lock holder waiting for contenders to arrive:
 *
 * Lock holders waitqueue: LH
 * Contenders waitqueue:   Empty
 * Contenders to wake up: 5
 *
 * As each contender comes in, the contenders value is reduced, and
 * when it becomes zero, the lock holder is woken up and mutex
 * deleted.
 *
 * 3) Occasionally multiple lock holders who just released the lock
 * make it to the kernel before any contenders:
 *
 * Contenders: Empty
 * Lock holders: LH
 * Contenders to wake up: 5
 *
 * -> New Lock holder arrives.
 *
 * As soon as the above occurs, the new LH wakes up the waiting one,
 * increments the contenders by its own contender count and starts
 * waiting. The scenario transitions to Scenario (2) in this case.
 *
 * The asynchronous nature of contender and lock holder arrivals make
 * for many possibilities, but what matters is the same number of
 * wake ups must occur as the number of contended waits.
 */

int mutex_control_lock(struct mutex_queue_head *mqhead,
		       unsigned long mutex_address)
{
	struct mutex_queue *mutex_queue;

	mutex_queue_head_lock(mqhead);

	/* Search for the mutex queue */
	if (!(mutex_queue = mutex_control_find(mqhead, mutex_address))) {
		/* Create a new one */
		if (!(mutex_queue = mutex_control_create(mutex_address))) {
			mutex_queue_head_unlock(mqhead);
			return -ENOMEM;
		}
		/* Add the queue to mutex queue list */
		mutex_control_add(mqhead, mutex_queue);

	} else if (mutex_queue->wqh_holders.sleepers) {
		/*
		 * There's a lock holder, so we can consume from
		 * number of contenders since we are one of them.
		 */
		mutex_queue->contenders--;

		/* No contenders left as far as current holder is concerned */
		if (mutex_queue->contenders == 0) {
			/* Wake up current holder */
			wake_up(&mutex_queue->wqh_holders, WAKEUP_ASYNC);

			/* There must not be any contenders, delete the mutex */
			mutex_control_remove(mqhead, mutex_queue);
			mutex_control_delete(mutex_queue);
		}

		/* Release lock and return */
		mutex_queue_head_unlock(mqhead);
		return 0;
	}

	/* Prepare to wait on the contenders queue */
	CREATE_WAITQUEUE_ON_STACK(wq, current);

	wait_on_prepare(&mutex_queue->wqh_contenders, &wq);

	/* Release lock */
	mutex_queue_head_unlock(mqhead);

	/* Initiate prepared wait */
	return wait_on_prepared_wait();
}

int mutex_control_unlock(struct mutex_queue_head *mqhead,
			 unsigned long mutex_address, int contenders)
{
	struct mutex_queue *mutex_queue;

	mutex_queue_head_lock(mqhead);

	/* Search for the mutex queue */
	if (!(mutex_queue = mutex_control_find(mqhead, mutex_address))) {

		/* No such mutex, create one and sleep on it */
		if (!(mutex_queue = mutex_control_create(mutex_address))) {
			mutex_queue_head_unlock(mqhead);
			return -ENOMEM;
		}

		/* Set new or increment the contenders value */
		mutex_queue->contenders = contenders;

		/* Add the queue to mutex queue list */
		mutex_control_add(mqhead, mutex_queue);

		/* Prepare to wait on the lock holders queue */
		CREATE_WAITQUEUE_ON_STACK(wq, current);

		/* Prepare to wait */
		wait_on_prepare(&mutex_queue->wqh_holders, &wq);

		/* Release lock first */
		mutex_queue_head_unlock(mqhead);

		/* Initiate prepared wait */
		return wait_on_prepared_wait();
	}

	/* Set new or increment the contenders value */
	mutex_queue->contenders += contenders;

	/* Wake up holders if any, and take wake up responsibility */
	if (mutex_queue->wqh_holders.sleepers)
		wake_up(&mutex_queue->wqh_holders, WAKEUP_ASYNC);

	/*
	 * Now wake up as many contenders as possible, otherwise
	 * go to sleep on holders queue
	 */
	while (mutex_queue->contenders &&
	       mutex_queue->wqh_contenders.sleepers) {
		/* Reduce total contenders to be woken up */
		mutex_queue->contenders--;

		/* Wake up a contender who made it to kernel */
		wake_up(&mutex_queue->wqh_contenders, WAKEUP_ASYNC);
	}

	/*
	 * Are we done with all? Leave.
	 *
	 * Not enough contenders? Go to sleep and wait for a new
	 * contender rendezvous.
	 */
	if (mutex_queue->contenders == 0) {
		/* Delete only if no more contenders */
		if (mutex_queue->wqh_contenders.sleepers == 0) {
			/* Since noone is left, delete the mutex queue */
			mutex_control_remove(mqhead, mutex_queue);
			mutex_control_delete(mutex_queue);
		}

		/* Release lock and return */
		mutex_queue_head_unlock(mqhead);
	} else {
		/* Prepare to wait on the lock holders queue */
		CREATE_WAITQUEUE_ON_STACK(wq, current);

		/* Prepare to wait */
		wait_on_prepare(&mutex_queue->wqh_holders, &wq);

		/* Release lock first */
		mutex_queue_head_unlock(mqhead);

		/* Initiate prepared wait */
		return wait_on_prepared_wait();
	}

	return 0;
}

int sys_mutex_control(unsigned long mutex_address, int mutex_flags)
{
	unsigned long mutex_physical;
	int mutex_op = mutex_operation(mutex_flags);
	int contenders = mutex_contenders(mutex_flags);
	int ret;

	//printk("%s: Thread %d enters.\n", __FUNCTION__, current->tid);

	/* Check valid user virtual address */
	if (KERN_ADDR(mutex_address)) {
		printk("Invalid args to %s.\n", __FUNCTION__);
		return -EINVAL;
	}

	if (mutex_op != MUTEX_CONTROL_LOCK &&
	    mutex_op != MUTEX_CONTROL_UNLOCK)
		return -EPERM;

	if ((ret = cap_mutex_check(mutex_address, mutex_op)) < 0)
		return ret;

	/*
	 * Find and check physical address for virtual mutex address
	 *
	 * NOTE: This is a shortcut to capability checking on memory
	 * capabilities of current task.
	 */
	if (!(mutex_physical =
	      virt_to_phys_by_pgd(TASK_PGD(current), mutex_address)))
		return -EINVAL;

	switch (mutex_op) {
	case MUTEX_CONTROL_LOCK:
		ret = mutex_control_lock(&curcont->mutex_queue_head,
					 mutex_physical);
		break;
	case MUTEX_CONTROL_UNLOCK:
		ret = mutex_control_unlock(&curcont->mutex_queue_head,
					   mutex_physical, contenders);
		break;
	}

	return ret;
}

