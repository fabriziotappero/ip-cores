/*
 * Userspace irq handling and management
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4/api/irq.h>
#include <l4/api/errno.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/thread.h>
#include <l4/generic/capability.h>
#include <l4/generic/irq.h>
#include <l4/generic/tcb.h>
#include INC_GLUE(message.h)
#include <l4/lib/wait.h>
#include INC_SUBARCH(irq.h)

/*
 * Default function that handles userspace
 * threaded irqs. Increases irq count and wakes
 * up any waiters.
 *
 * The increment is a standard read/update/write, and
 * it is atomic due to multiple reasons:
 *
 * - We are atomic with regard to the task because we are
 *   in irq context. Task cannot run during the period where
 *   we read update and write the value.
 *
 * - The task does an atomic swap on reads, writing 0 to the
 *   location in the same instruction as it reads it. As a
 *   result task updates on the slot are atomic, and cannot
 *   interfere with the read/update/write of the irq.
 *
 * - Recursive irqs are enabled, but we are also protected
 *   from them because the current irq number is masked.
 *
 *   FIXME: Instead of UTCB, do it by incrementing a semaphore.
 */
int irq_thread_notify(struct irq_desc *desc)
{
	struct utcb *utcb;
	int err;

	/* Make sure irq thread's utcb is mapped */
	if ((err = tcb_check_and_lazy_map_utcb(desc->task,
					       0)) < 0) {
		printk("%s: Irq occured but registered task's utcb "
		       "is inaccessible without a page fault. "
		       "task id=0x%x err=%d\n"
		       "Destroying task.", __FUNCTION__,
		       desc->task->tid, err);
		/* FIXME: Racy for irqs. */
		thread_destroy(desc->task);
		/* FIXME: Deregister and disable irq as well */
	}

	/* Get thread's utcb */
	utcb = (struct utcb *)desc->task->utcb_address;

	/* Atomic increment (See above comments) with no wraparound */
	if (utcb->notify[desc->task_notify_slot] != TASK_NOTIFY_MAXVALUE)
		utcb->notify[desc->task_notify_slot]++;

	/* Async wake up any waiter irq threads */
	wake_up(&desc->wqh_irq, WAKEUP_ASYNC);

	BUG_ON(!irqs_enabled());
	return 0;
}

/*
 * Register the given globally unique irq number with the
 * current thread with given flags
 */
int irq_control_register(struct ktcb *task, int slot, l4id_t irqnum)
{
	int err;

	/*
	 * Check that utcb memory accesses won't fault us.
	 *
	 * We make sure that the irq registrar has its utcb mapped,
	 * so that if an irq occurs, the utcb address must be at
	 * least readily available to be copied over to the page
	 * tables of the task runnable at the time of the irq.
	 */
	if ((err = tcb_check_and_lazy_map_utcb(current, 1)) < 0)
		return err;

	/* Register the irq for thread notification */
	if ((err = irq_register(current, slot, irqnum)) < 0)
		return err;

	/* Make thread a real-time task */
	current->flags |= TASK_REALTIME;

	return 0;
}

/*
 * Makes current task wait on the given irq
 */
int irq_wait(l4id_t irq_index)
{
	struct irq_desc *desc = irq_desc_array + irq_index;
	struct utcb *utcb = (struct utcb *)current->utcb_address;
	int ret;

	/* Index must be valid */
	if (irq_index > IRQS_MAX || irq_index < 0)
		return -EINVAL;

	/* UTCB must be mapped */
	if ((ret = tcb_check_and_lazy_map_utcb(current, 1)) < 0)
		return ret;

	/* Wait until the irq changes slot value */
	WAIT_EVENT(&desc->wqh_irq,
		   utcb->notify[desc->task_notify_slot] != 0,
		   ret);

	if (ret < 0)
		return ret;
	else
		return l4_atomic_dest_readb(&utcb->notify[desc->task_notify_slot]);
}


/*
 * Register/deregister device irqs. Optional synchronous and
 * asynchronous irq handling.
 */
int sys_irq_control(unsigned int req, unsigned int flags, l4id_t irqnum)
{
	/* Currently a task is allowed to register only for itself */
	struct ktcb *task = current;
	int err;

	if ((err = cap_irq_check(task, req, flags, irqnum)) < 0)
		return err;

	switch (req) {
	case IRQ_CONTROL_REGISTER:
		return irq_control_register(task, flags, irqnum);
	case IRQ_CONTROL_WAIT:
		return irq_wait(irqnum);
	default:
		return -EINVAL;
	}

	return 0;
}

