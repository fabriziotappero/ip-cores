/*
 * Thread related system calls.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/scheduler.h>
#include <l4/generic/container.h>
#include <l4/api/thread.h>
#include <l4/api/syscall.h>
#include <l4/api/errno.h>
#include <l4/generic/tcb.h>
#include <l4/lib/idpool.h>
#include <l4/lib/mutex.h>
#include <l4/lib/wait.h>
#include <l4/generic/resource.h>
#include <l4/generic/capability.h>
#include INC_ARCH(asm.h)
#include INC_SUBARCH(mm.h)
#include INC_GLUE(mapping.h)

int sys_thread_switch(void)
{
	schedule();
	return 0;
}

/*
 * This signals a thread so that the thread stops what it is
 * doing, and take action on the signal provided. Currently this
 * may be a suspension or an exit signal.
 */
int thread_signal(struct ktcb *task, unsigned int flags,
		  unsigned int task_state)
{
	int ret = 0;

	if (task->state == task_state)
		return 0;

	/* Signify we want to suspend the thread */
	task->flags |= flags;

	/* Wake it up if it's sleeping */
	wake_up_task(task, WAKEUP_INTERRUPT | WAKEUP_SYNC);

	/* Wait until task switches to desired state */
	WAIT_EVENT(&task->wqh_pager,
		   task->state == task_state, ret);

	return ret;
}

int thread_suspend(struct ktcb *task)
{
	return thread_signal(task, TASK_SUSPENDING, TASK_INACTIVE);
}

int thread_exit(struct ktcb *task)
{
	return thread_signal(task, TASK_SUSPENDING, TASK_INACTIVE);
}

static inline int task_is_child(struct ktcb *task)
{
	return (((task) != current) &&
		((task)->pagerid == current->tid));
}

int thread_destroy_child(struct ktcb *task)
{
	/* Wait until thread exits */
	thread_exit(task);

	/* Hint scheduler that an exit occured */
	current->flags |= TASK_EXITED;

	/* Now remove it atomically */
	tcb_remove(task);

	/* Wake up waiters that arrived before removing */
	wake_up_all(&task->wqh_send, WAKEUP_INTERRUPT);
	wake_up_all(&task->wqh_recv, WAKEUP_INTERRUPT);

	BUG_ON(task->wqh_pager.sleepers > 0);
	BUG_ON(task->state != TASK_INACTIVE);

	/* Place the task on the zombie queue for its cpu */
	ktcb_list_add(task, &per_cpu_byid(kernel_resources.zombie_list,
					  task->affinity));

	return 0;
}

int thread_destroy_children(void)
{
	struct ktcb *task, *n;

	spin_lock(&curcont->ktcb_list.list_lock);
	list_foreach_removable_struct(task, n,
				      &curcont->ktcb_list.list,
				      task_list) {
		if (task_is_child(task)) {
			spin_unlock(&curcont->ktcb_list.list_lock);
			thread_destroy_child(task);
			spin_lock(&curcont->ktcb_list.list_lock);
		}
	}
	spin_unlock(&curcont->ktcb_list.list_lock);
	return 0;

}

void thread_destroy_self(unsigned int exit_code)
{
	/* Destroy all children first */
	thread_destroy_children();

	/* If self-paged, finish everything except deletion */
	if (current->tid == current->pagerid) {
		/* Remove self safe against ipc */
		tcb_remove(current);

		/* Wake up any waiters queued up before removal */
		wake_up_all(&current->wqh_send, WAKEUP_INTERRUPT);
		wake_up_all(&current->wqh_recv, WAKEUP_INTERRUPT);

		/* Move capabilities to current cpu idle task */
		cap_list_move(&per_cpu(scheduler).idle_task->cap_list,
			      &current->cap_list);

		/* Place self on the per-cpu zombie queue */
		ktcb_list_add(current, &per_cpu(kernel_resources.zombie_list));
	}

	/*
	 * Both child and a self-paging would set exit
	 * code and quit the scheduler
	 */
	current->exit_code = exit_code;

	/*
	 * Hint scheduler that an exit has occured
	 */
	current->flags |= TASK_EXITED;
	sched_suspend_sync();
}

int thread_wait(struct ktcb *task)
{
	unsigned int exit_code;
	int ret;

	// printk("%s: (%d) for (%d)\n", __FUNCTION__, current->tid, task->tid);

	/* Wait until task switches to desired state */
	WAIT_EVENT(&task->wqh_pager,
		   task->state == TASK_INACTIVE, ret);

	/* Return if interrupted by async event */
	if (ret < 0)
		return ret;

	/* Now remove it safe against ipc */
	tcb_remove(task);

	/* Wake up waiters that arrived before removing */
	wake_up_all(&task->wqh_send, WAKEUP_INTERRUPT);
	wake_up_all(&task->wqh_recv, WAKEUP_INTERRUPT);

	BUG_ON(task->wqh_pager.sleepers > 0);
	BUG_ON(task->state != TASK_INACTIVE);

	/* Obtain exit code */
	exit_code = (int)task->exit_code;

	/* Place it on the zombie queue */
	ktcb_list_add(task,
		      &per_cpu_byid(kernel_resources.zombie_list,
				    task->affinity));

	return exit_code;
}

int thread_destroy(struct ktcb *task, unsigned int exit_code)
{
	// printk("%s: (%d) for (%d)\n", __FUNCTION__, current->tid, task->tid);

	exit_code &= THREAD_EXIT_MASK;

	if (task_is_child(task))
		return thread_destroy_child(task);
	else if (task == current)
		thread_destroy_self(exit_code);
	else
		BUG();

	return 0;
}

int arch_clear_thread(struct ktcb *tcb)
{
	/* Remove from the global list */
	tcb_remove(tcb);

	/* Sanity checks */
	BUG_ON(!is_page_aligned(tcb));
	BUG_ON(tcb->wqh_pager.sleepers > 0);
	BUG_ON(tcb->wqh_send.sleepers > 0);
	BUG_ON(tcb->wqh_recv.sleepers > 0);
	BUG_ON(!list_empty(&tcb->task_list));
	BUG_ON(!list_empty(&tcb->rq_list));
	BUG_ON(tcb->rq);
	BUG_ON(tcb->nlocks);
	BUG_ON(tcb->waiting_on);
	BUG_ON(tcb->wq);

	/* Reinitialise the context */
	memset(&tcb->context, 0, sizeof(tcb->context));
	tcb->context.spsr = ARM_MODE_USR;

	/* Clear the page tables */
	remove_mapping_pgd_all_user(TASK_PGD(tcb));

	/* Reinitialize all other fields */
	tcb_init(tcb);

	/* Add back to global list */
	tcb_add(tcb);

	return 0;
}

int thread_recycle(struct ktcb *task)
{
	int ret;

	if ((ret = thread_suspend(task)) < 0)
		return ret;

	/*
	 * If there are any sleepers on any of the task's
	 * waitqueues, we need to wake those tasks up.
	 */
	wake_up_all(&task->wqh_send, 0);
	wake_up_all(&task->wqh_recv, 0);

	/*
	 * The thread cannot have a pager waiting for it
	 * since we ought to be the pager.
	 */
	BUG_ON(task->wqh_pager.sleepers > 0);

	/* Clear the task's tcb */
	arch_clear_thread(task);

	return 0;
}

/* Runs a thread for the first time */
int thread_start(struct ktcb *task)
{
	if (!mutex_trylock(&task->thread_control_lock))
		return -EAGAIN;

	/* Notify scheduler of task resume */
	sched_resume_async(task);

	/* Release lock and return */
	mutex_unlock(&task->thread_control_lock);

	return 0;
}

int arch_setup_new_thread(struct ktcb *new, struct ktcb *orig,
			  unsigned int flags)
{
	/* New threads just need their mode set up */
	if (flags & TC_NEW_SPACE) {
		BUG_ON(orig);
		new->context.spsr = ARM_MODE_USR;
		return 0;
	}

	BUG_ON(!orig);

	/* If original has no syscall context yet, don't copy */
	if (!orig->syscall_regs)
		return 0;

	/*
	 * For duplicated threads pre-syscall context is saved on
	 * the kernel stack. We copy this context of original
	 * into the duplicate thread's current context structure,
	 *
	 * No locks needed as the thread is not known to the system yet.
	 */
	BUG_ON(!(new->context.spsr = orig->syscall_regs->spsr)); /* User mode */
	new->context.r0 = orig->syscall_regs->r0;
	new->context.r1 = orig->syscall_regs->r1;
	new->context.r2 = orig->syscall_regs->r2;
	new->context.r3 = orig->syscall_regs->r3;
	new->context.r4 = orig->syscall_regs->r4;
	new->context.r5 = orig->syscall_regs->r5;
	new->context.r6 = orig->syscall_regs->r6;
	new->context.r7 = orig->syscall_regs->r7;
	new->context.r8 = orig->syscall_regs->r8;
	new->context.r9 = orig->syscall_regs->r9;
	new->context.r10 = orig->syscall_regs->r10;
	new->context.r11 = orig->syscall_regs->r11;
	new->context.r12 = orig->syscall_regs->r12;
	new->context.sp = orig->syscall_regs->sp_usr;
	/* Skip lr_svc since it's not going to be used */
	new->context.pc = orig->syscall_regs->lr_usr;

	/* Distribute original thread's ticks into two threads */
	new->ticks_left = (orig->ticks_left + 1) >> 1;
	if (!(orig->ticks_left >>= 1))
		orig->ticks_left = 1;

	return 0;
}

static DECLARE_SPINLOCK(task_select_affinity_lock);
static unsigned int cpu_rr_affinity;

/* Select which cpu to place the new task in round-robin fashion */
void thread_setup_affinity(struct ktcb *task)
{
	spin_lock(&task_select_affinity_lock);
	task->affinity = cpu_rr_affinity;

	//printk("Set up thread %d affinity=%d\n",
	//       task->tid, task->affinity);
	cpu_rr_affinity++;
	if (cpu_rr_affinity >= CONFIG_NCPU)
		cpu_rr_affinity = 0;

	spin_unlock(&task_select_affinity_lock);
}

static inline void
thread_setup_new_ids(struct task_ids *ids, unsigned int flags,
		     struct ktcb *new, struct ktcb *orig)
{
	if (flags & TC_SHARE_GROUP)
		new->tgid = orig->tgid;
	else
		new->tgid = new->tid;

	/* Update ids to be returned back to caller */
	ids->tid = new->tid;
	ids->tgid = new->tgid;
}

int thread_setup_space(struct ktcb *tcb, struct task_ids *ids, unsigned int flags)
{
	struct address_space *space, *new;
	int ret = 0;

	if (flags & TC_SHARE_SPACE) {
		mutex_lock(&curcont->space_list.lock);
		if (!(space = address_space_find(ids->spid))) {
			mutex_unlock(&curcont->space_list.lock);
			ret = -ESRCH;
			goto out;
		}
		mutex_lock(&space->lock);
		mutex_unlock(&curcont->space_list.lock);
		address_space_attach(tcb, space);
		mutex_unlock(&space->lock);
	}
	else if (flags & TC_COPY_SPACE) {
		mutex_lock(&curcont->space_list.lock);
		if (!(space = address_space_find(ids->spid))) {
			mutex_unlock(&curcont->space_list.lock);
			ret = -ESRCH;
			goto out;
		}
		mutex_lock(&space->lock);
		if (IS_ERR(new = address_space_create(space))) {
			mutex_unlock(&curcont->space_list.lock);
			mutex_unlock(&space->lock);
			ret = (int)new;
			goto out;
		}
		mutex_unlock(&space->lock);
		ids->spid = new->spid; 	/* Return newid to caller */
		address_space_attach(tcb, new);
		address_space_add(new);
		mutex_unlock(&curcont->space_list.lock);
	}
	else if (flags & TC_NEW_SPACE) {
		if (IS_ERR(new = address_space_create(0))) {
			ret = (int)new;
			goto out;
		}
		/* New space id to be returned back to caller */
		ids->spid = new->spid;
		address_space_attach(tcb, new);
		mutex_lock(&curcont->space_list.lock);
		address_space_add(new);
		mutex_unlock(&curcont->space_list.lock);
	}

out:
	return ret;
}

int thread_create(struct task_ids *ids, unsigned int flags)
{
	struct ktcb *new;
	struct ktcb *orig = 0;
	int err;

	/* Clear flags to just include creation flags */
	flags &= THREAD_CREATE_MASK;

	/* Can't have multiple space directives in flags */
	if ((flags & TC_SHARE_SPACE
	     & TC_COPY_SPACE & TC_NEW_SPACE) || !flags)
		return -EINVAL;

	/* Must have one space flag */
	if ((flags & THREAD_SPACE_MASK) == 0)
		return -EINVAL;

	/* Can't request shared utcb or tgid without shared space */
	if (!(flags & TC_SHARE_SPACE)) {
		if ((flags & TC_SHARE_UTCB) ||
		    (flags & TC_SHARE_GROUP)) {
			return -EINVAL;
		}
	}

	if (!(new = tcb_alloc_init(curcont->cid)))
		return -ENOMEM;

	/* Set up new thread space by using space id and flags */
	if ((err = thread_setup_space(new, ids, flags)) < 0)
		goto out_err;

	/* Obtain parent thread if there is one */
	if (flags & TC_SHARE_SPACE || flags & TC_COPY_SPACE) {
		if (!(orig = tcb_find(ids->tid))) {
			err = -EINVAL;
			goto out_err;
		}
	}

	/* Set creator as pager */
	new->pagerid = current->tid;

	/* Setup container-generic fields from current task */
	new->container = current->container;

	/*
	 * Set up cpu affinity.
	 *
	 * This is the default setting, it may be changed
	 * by a subsequent exchange_registers call
	 */
	thread_setup_affinity(new);

	/* Set up new thread context by using parent ids and flags */
	thread_setup_new_ids(ids, flags, new, orig);

	arch_setup_new_thread(new, orig, flags);

	tcb_add(new);

	//printk("%s: %d created: %d, %d, %d \n",
	//       __FUNCTION__, current->tid, ids->tid,
	//       ids->tgid, ids->spid);

	return 0;

out_err:
	/* Pre-mature tcb needs freeing by free_ktcb */
	free_ktcb(new, current);
	return err;
}

/*
 * Creates, destroys and modifies threads. Also implicitly creates an address
 * space for a thread that doesn't already have one, or destroys it if the last
 * thread that uses it is destroyed.
 */
int sys_thread_control(unsigned int flags, struct task_ids *ids)
{
	struct ktcb *task = 0;
	int err, ret = 0;

	if ((err = check_access((unsigned long)ids, sizeof(*ids),
				MAP_USR_RW, 1)) < 0)
		return err;

	if ((flags & THREAD_ACTION_MASK) != THREAD_CREATE) {
		if (!(task = tcb_find(ids->tid)))
			return -ESRCH;

		/*
		 * Tasks may only operate on their children. They may
		 * also destroy themselves or any children.
		 */
		if ((flags & THREAD_ACTION_MASK) == THREAD_DESTROY &&
		    !task_is_child(task) && task != current)
			return -EPERM;
		if ((flags & THREAD_ACTION_MASK) != THREAD_DESTROY
		    && !task_is_child(task))
			return -EPERM;
	}

	if ((err = cap_thread_check(task, flags, ids)) < 0)
		return err;

	switch (flags & THREAD_ACTION_MASK) {
	case THREAD_CREATE:
		ret = thread_create(ids, flags);
		break;
	case THREAD_RUN:
		ret = thread_start(task);
		break;
	case THREAD_SUSPEND:
		ret = thread_suspend(task);
		break;
	case THREAD_DESTROY:
		ret = thread_destroy(task, flags);
		break;
	case THREAD_RECYCLE:
		ret = thread_recycle(task);
		break;
	case THREAD_WAIT:
		ret = thread_wait(task);
		break;

	default:
		ret = -EINVAL;
	}

	return ret;
}

