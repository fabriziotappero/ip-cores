/*
 * Some ktcb related data
 *
 * Copyright (C) 2007 - 2009 Bahadir Balban
 */
#include <l4/generic/tcb.h>
#include <l4/generic/space.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/container.h>
#include <l4/generic/preempt.h>
#include <l4/generic/space.h>
#include <l4/lib/idpool.h>
#include <l4/api/ipc.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include INC_ARCH(exception.h)
#include INC_SUBARCH(mm.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_SUBARCH(mmu_ops.h)

void init_ktcb_list(struct ktcb_list *ktcb_list)
{
	memset(ktcb_list, 0, sizeof(*ktcb_list));
	spin_lock_init(&ktcb_list->list_lock);
	link_init(&ktcb_list->list);
}

void tcb_init(struct ktcb *new)
{

	link_init(&new->task_list);
	mutex_init(&new->thread_control_lock);

	spin_lock_init(&new->thread_lock);

	cap_list_init(&new->cap_list);

	/* Initialise task's scheduling state and parameters. */
	sched_init_task(new, TASK_PRIO_NORMAL);

	/* Initialise ipc waitqueues */
	spin_lock_init(&new->waitlock);
	waitqueue_head_init(&new->wqh_send);
	waitqueue_head_init(&new->wqh_recv);
	waitqueue_head_init(&new->wqh_pager);
}

struct ktcb *tcb_alloc_init(l4id_t cid)
{
	struct ktcb *tcb;
	struct task_ids ids;

	if (!(tcb = alloc_ktcb()))
		return 0;

	ids.tid = id_new(&kernel_resources.ktcb_ids);
	ids.tid |= TASK_CID_MASK & (cid << TASK_CID_SHIFT);
	ids.tgid = L4_NILTHREAD;
	ids.spid = L4_NILTHREAD;

	set_task_ids(tcb, &ids);

	tcb_init(tcb);

	return tcb;
}

void tcb_delete(struct ktcb *tcb)
{
	struct ktcb *pager, *acc_task;

	/* Sanity checks first */
	BUG_ON(!is_page_aligned(tcb));
	BUG_ON(tcb->wqh_pager.sleepers > 0);
	BUG_ON(tcb->wqh_send.sleepers > 0);
	BUG_ON(tcb->wqh_recv.sleepers > 0);
	BUG_ON(tcb->affinity != current->affinity);
	BUG_ON(tcb->state != TASK_INACTIVE);
	BUG_ON(!list_empty(&tcb->rq_list));
	BUG_ON(tcb->rq);
	BUG_ON(tcb == current);
	BUG_ON(tcb->nlocks);
	BUG_ON(tcb->waiting_on);
	BUG_ON(tcb->wq);

	/* Remove from zombie list */
	list_remove(&tcb->task_list);

	/* Determine task to account deletions */
	if (!(pager = tcb_find(tcb->pagerid)))
		acc_task = current;
	else
		acc_task = pager;

	/*
	 * NOTE: This protects single threaded space
	 * deletion against space modification.
	 *
	 * If space deletion were multi-threaded, list
	 * traversal would be needed to ensure list is
	 * still there.
	 */
	mutex_lock(&tcb->container->space_list.lock);
	mutex_lock(&tcb->space->lock);
	BUG_ON(--tcb->space->ktcb_refs < 0);

	/* No refs left for the space, delete it */
	if (tcb->space->ktcb_refs == 0) {
		address_space_remove(tcb->space, tcb->container);
		mutex_unlock(&tcb->space->lock);
		address_space_delete(tcb->space, acc_task);
		mutex_unlock(&tcb->container->space_list.lock);
	} else {
		mutex_unlock(&tcb->space->lock);
		mutex_unlock(&tcb->container->space_list.lock);
	}

	/* Clear container id part */
	tcb->tid &= ~TASK_CID_MASK;

	/* Deallocate tcb ids */
	id_del(&kernel_resources.ktcb_ids, tcb->tid);

	/* Free the tcb */
	free_ktcb(tcb, acc_task);
}

struct ktcb *tcb_find_by_space(l4id_t spid)
{
	struct ktcb *task;

	spin_lock(&curcont->ktcb_list.list_lock);
	list_foreach_struct(task, &curcont->ktcb_list.list, task_list) {
		if (task->space->spid == spid) {
			spin_unlock(&curcont->ktcb_list.list_lock);
			return task;
		}
	}
	spin_unlock(&curcont->ktcb_list.list_lock);
	return 0;
}

struct ktcb *container_find_tcb(struct container *c, l4id_t tid)
{
	struct ktcb *task;

	spin_lock(&c->ktcb_list.list_lock);
	list_foreach_struct(task, &c->ktcb_list.list, task_list) {
		if (task->tid == tid) {
			spin_unlock(&c->ktcb_list.list_lock);
			return task;
		}
	}
	spin_unlock(&c->ktcb_list.list_lock);
	return 0;
}

struct ktcb *container_find_lock_tcb(struct container *c, l4id_t tid)
{
	struct ktcb *task;

	spin_lock(&c->ktcb_list.list_lock);
	list_foreach_struct(task, &c->ktcb_list.list, task_list) {
		if (task->tid == tid) {
			spin_lock(&task->thread_lock);
			spin_unlock(&c->ktcb_list.list_lock);
			return task;
		}
	}
	spin_unlock(&c->ktcb_list.list_lock);
	return 0;
}

/*
 * Threads are the only resource where inter-container searches are
 * allowed. This is because on other containers, only threads can be
 * targeted for operations. E.g. ipc, sharing memory. Currently you
 * can't reach a space, a mutex, or any other resouce on another
 * container.
 */
struct ktcb *tcb_find(l4id_t tid)
{
	struct container *c;

	if (current->tid == tid)
		return current;

	if (tid_to_cid(tid) == curcont->cid) {
		return container_find_tcb(curcont, tid);
	} else {
	       	if (!(c = container_find(&kernel_resources,
					 tid_to_cid(tid))))
			return 0;
		else
			return container_find_tcb(c, tid);
	}
}

struct ktcb *tcb_find_lock(l4id_t tid)
{
	struct container *c;

	if (current->tid == tid) {
		spin_lock(&current->thread_lock);
		return current;
	}

	if (tid_to_cid(tid) == curcont->cid) {
		return container_find_lock_tcb(curcont, tid);
	} else {
	       	if (!(c = container_find(&kernel_resources,
					 tid_to_cid(tid))))
			return 0;
		else
			return container_find_lock_tcb(c, tid);
	}
}

void ktcb_list_add(struct ktcb *new, struct ktcb_list *ktcb_list)
{
	spin_lock(&ktcb_list->list_lock);
	BUG_ON(!list_empty(&new->task_list));
	BUG_ON(!++ktcb_list->count);
	list_insert(&new->task_list, &ktcb_list->list);
	spin_unlock(&ktcb_list->list_lock);
}

void tcb_add(struct ktcb *new)
{
	struct container *c = new->container;

	spin_lock(&c->ktcb_list.list_lock);
	BUG_ON(!list_empty(&new->task_list));
	BUG_ON(!++c->ktcb_list.count);
	list_insert(&new->task_list, &c->ktcb_list.list);
	spin_unlock(&c->ktcb_list.list_lock);
}

/*
 * Its important that this is per-cpu. This is
 * because it must be guaranteed that the task
 * is not runnable. Idle task on that cpu guarantees it.
 */
void tcb_delete_zombies(void)
{
	struct ktcb *zombie, *n;
	struct ktcb_list *ktcb_list =
		&per_cpu(kernel_resources.zombie_list);

	/* Traverse the per-cpu zombie list */
	spin_lock(&ktcb_list->list_lock);
	list_foreach_removable_struct(zombie, n,
				      &ktcb_list->list,
				      task_list)
		/* Delete all zombies one by one */
		tcb_delete(zombie);
	spin_unlock(&ktcb_list->list_lock);
}


/*
 * It's enough to lock list and thread without
 * traversing the list, because we're only
 * protecting against thread modification.
 * Deletion is a single-threaded operation
 */
void tcb_remove(struct ktcb *task)
{
	/* Lock list */
	spin_lock(&curcont->ktcb_list.list_lock);
	BUG_ON(list_empty(&task->task_list));
	BUG_ON(--curcont->ktcb_list.count < 0);
	spin_lock(&task->thread_lock);

	list_remove_init(&task->task_list);
	spin_unlock(&curcont->ktcb_list.list_lock);
	spin_unlock(&task->thread_lock);
}

void ktcb_list_remove(struct ktcb *new, struct ktcb_list *ktcb_list)
{
	spin_lock(&ktcb_list->list_lock);
	BUG_ON(list_empty(&new->task_list));
	BUG_ON(--ktcb_list->count < 0);
	list_remove(&new->task_list);
	spin_unlock(&ktcb_list->list_lock);
}

/* Offsets for ktcb fields that are accessed from assembler */
unsigned int need_resched_offset = offsetof(struct ktcb, ts_need_resched);
unsigned int syscall_regs_offset = offsetof(struct ktcb, syscall_regs);

/*
 * Every thread has a unique utcb region that is mapped to its address
 * space as its context is loaded. The utcb region is a function of
 * this mapping and its offset that is reached via the KIP UTCB pointer
 */
void task_update_utcb(struct ktcb *task)
{
	arch_update_utcb(task->utcb_address);
}

/*
 * Checks whether a task's utcb is currently accessible by the kernel.
 * Returns an error if its not paged in yet, maps a non-current task's
 * utcb to current task for kernel-only access if it is unmapped.
 *
 * UTCB Mappings: The design is that each task maps its utcb with user
 * access, and any other utcb is mapped with kernel-only access privileges
 * upon an ipc that requires the kernel to access that utcb, in other
 * words foreign utcbs are mapped lazily.
 */
int tcb_check_and_lazy_map_utcb(struct ktcb *task, int page_in)
{
	unsigned int phys;
	int ret;

	if (!task->utcb_address)
		return -ENOUTCB;

	/*
	 * If task == current && not mapped && page_in,
	 * 	page-in, if not return -EFAULT
	 * If task == current && not mapped && !page_in,
	 * 	return -EFAULT
	 * If task != current && not mapped,
	 * 	return -EFAULT since can't page-in on behalf of it.
	 * If task != current && task mapped,
	 * 	but mapped != current mapped, map it, return 0
	 * If task != current && task mapped,
	 * 	but mapped == current mapped, return 0
	 */

	/* FIXME:
	 *
	 * Do the check_access part without distinguishing current/non-current
	 * Do the rest (i.e. mapping the value to the current table) only if the utcb is non-current
	 */

	if (current == task) {
		/* Check own utcb, if not there, page it in */
		if ((ret = check_access(task->utcb_address, UTCB_SIZE,
					MAP_KERN_RW, page_in)) < 0)
			return -EFAULT;
		else
			return 0;
	} else {
		/* Check another's utcb, but don't try to map in */
		if ((ret = check_access_task(task->utcb_address,
					     UTCB_SIZE,
					     MAP_KERN_RW, 0,
					     task)) < 0) {
			return -EFAULT;
		} else {
			/*
			 * Task has it mapped, map it to self
			 * unless they're identical
			 */
			if ((phys =
			     virt_to_phys_by_pgd(TASK_PGD(task),
						 task->utcb_address)) !=
			     virt_to_phys_by_pgd(TASK_PGD(current),
						 task->utcb_address)) {
				/*
				 * We have none or an old reference.
				 * Update it with privileged flags,
				 * so that only kernel can access.
				 */
				add_mapping_pgd(phys, page_align(task->utcb_address),
						page_align_up(UTCB_SIZE),
						MAP_KERN_RW,
						TASK_PGD(current));
			}
			BUG_ON(!phys);
		}
	}
	return 0;
}


