/*
 * Capability checking for all system calls
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4/generic/resource.h>
#include <l4/generic/capability.h>
#include <l4/generic/container.h>
#include <l4/generic/cap-types.h>
#include <l4/generic/tcb.h>
#include <l4/api/capability.h>
#include <l4/api/thread.h>
#include <l4/api/errno.h>
#include <l4/lib/printk.h>
#include <l4/api/thread.h>
#include <l4/api/exregs.h>
#include <l4/api/ipc.h>
#include <l4/api/irq.h>
#include <l4/api/cache.h>
#include INC_GLUE(message.h)
#include INC_GLUE(ipc.h)

void capability_init(struct capability *cap)
{
	cap->capid = id_new(&kernel_resources.capability_ids);
	link_init(&cap->list);
}

/*
 * Boot-time function to create capability without
 * capability checking
 */
struct capability *boot_capability_create(void)
{
	struct capability *cap = boot_alloc_capability();

	capability_init(cap);

	return cap;
}

struct capability *capability_create(void)
{
	struct capability *cap;

	if (!(cap = alloc_capability()))
		return 0;

	capability_init(cap);

	return cap;
}

#if defined(CONFIG_CAPABILITIES)
int capability_consume(struct capability *cap, int quantity)
{
	if (cap->size < cap->used + quantity)
		return -ENOCAP;

	cap->used += quantity;

	return 0;
}

int capability_free(struct capability *cap, int quantity)
{
	BUG_ON((cap->used -= quantity) < 0);
	return 0;
}

#else
int capability_consume(struct capability *cap, int quantity)
{
	return 0;
}

int capability_free(struct capability *cap, int quantity)
{
	return 0;
}
#endif

struct capability *cap_list_find_by_rtype(struct cap_list *cap_list,
					  unsigned int rtype)
{
	struct capability *cap;

	list_foreach_struct(cap, &cap_list->caps, list)
		if (cap_rtype(cap) == rtype)
			return cap;

	return 0;
}

/*
 * Find a capability from a list by its resource type
 * Search all capability lists that task is allowed.
 *
 * FIXME:
 * Tasks should not always search for a capability randomly. Consider
 * mutexes, if a mutex is freed, it needs to be accounted to private
 * pool first if that is not full, because freeing it into shared
 * pool may lose the mutex right to another task. In other words,
 * when you're freeing a mutex, we should know which capability pool
 * to free it to.
 *
 * In conclusion freeing of pool-type capabilities need to be done
 * in order of privacy.
 */
struct capability *capability_find_by_rtype(struct ktcb *task,
					    unsigned int rtype)
{
	struct capability *cap;

	/* Search task's own list */
	list_foreach_struct(cap, &task->cap_list.caps, list)
		if (cap_rtype(cap) == rtype)
			return cap;

	/* Search space list */
	list_foreach_struct(cap, &task->space->cap_list.caps, list)
		if (cap_rtype(cap) == rtype)
			return cap;

	/* Search container list */
	list_foreach_struct(cap, &task->container->cap_list.caps, list)
		if (cap_rtype(cap) == rtype)
			return cap;

	return 0;
}

struct capability *cap_find_by_capid(l4id_t capid, struct cap_list **cap_list)
{
	struct capability *cap;
	struct ktcb *task = current;

	/* Search task's own list */
	list_foreach_struct(cap, &task->cap_list.caps, list)
		if (cap->capid == capid) {
			*cap_list = &task->cap_list;
			return cap;
		}

	/* Search space list */
	list_foreach_struct(cap, &task->space->cap_list.caps, list)
		if (cap->capid == capid) {
			*cap_list = &task->space->cap_list;
			return cap;
		}

	/* Search container list */
	list_foreach_struct(cap, &task->container->cap_list.caps, list)
		if (cap->capid == capid) {
			*cap_list = &task->container->cap_list;
			return cap;
		}

	return 0;
}

int cap_count(struct ktcb *task)
{
	return task->cap_list.ncaps +
	       task->space->cap_list.ncaps +
	       task->container->cap_list.ncaps;
}

typedef struct capability *(*cap_match_func_t) \
	(struct capability *cap, void *match_args);

/*
 * This is used by every system call to match each
 * operation with a capability in a syscall-specific way.
 */
struct capability *cap_find(struct ktcb *task, cap_match_func_t cap_match_func,
			     void *match_args, unsigned int cap_type)
{
	struct capability *cap, *found;

	/* Search task's own list */
	list_foreach_struct(cap, &task->cap_list.caps, list)
		if (cap_type(cap) == cap_type &&
		    ((found = cap_match_func(cap, match_args))))
			return found;

	/* Search space list */
	list_foreach_struct(cap, &task->space->cap_list.caps, list)
		if (cap_type(cap) == cap_type &&
		    ((found = cap_match_func(cap, match_args))))
			return found;

	/* Search container list */
	list_foreach_struct(cap, &task->container->cap_list.caps, list)
		if (cap_type(cap) == cap_type &&
		    ((found = cap_match_func(cap, match_args))))
			return found;

	return 0;
}

struct sys_mutex_args {
	unsigned long address;
	unsigned int op;
};

/*
 * Check broadly the ability to do mutex ops. Check it by
 * the thread, space or container, (i.e. the group that can
 * do this operation broadly)
 *
 * Note, that we check mutex_address elsewhere as a quick,
 * per-task virt_to_phys translation that would not get
 * easily/quickly satisfied by a memory capability checking.
 *
 * While this is not %100 right from a capability checking
 * point-of-view, it is a shortcut that works and makes sense.
 *
 * For sake of completion, the right way to do it would be to
 * add MUTEX_LOCKABLE, MUTEX_UNLOCKABLE attributes to both
 * virtual and physical memory caps of a task, search those
 * to validate the address. But we would have to translate
 * from the page tables either ways.
 */
struct capability *
cap_match_mutex(struct capability *cap, void *args)
{
	/* Unconditionally expect these flags */
	unsigned int perms = CAP_UMUTEX_LOCK | CAP_UMUTEX_UNLOCK;

	if ((cap->access & perms) != perms)
		return 0;

	/* Now check the usual restype/resid pair */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (current->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (current->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (current->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

struct sys_capctrl_args {
	unsigned int req;
	unsigned int flags;
	struct ktcb *task;
};

struct capability *
cap_match_capctrl(struct capability *cap, void *args_ptr)
{
	struct sys_capctrl_args *args = args_ptr;
	unsigned int req = args->req;
	struct ktcb *target = args->task;

	/* Check operation privileges */
	switch (req) {
	case CAP_CONTROL_NCAPS:
	case CAP_CONTROL_READ:
		if (!(cap->access & CAP_CAP_READ))
			return 0;
		break;
	case CAP_CONTROL_SHARE:
		if (!(cap->access & CAP_CAP_SHARE))
			return 0;
		break;
	case CAP_CONTROL_GRANT:
		if (!(cap->access & CAP_CAP_GRANT))
			return 0;
		break;
	case CAP_CONTROL_REPLICATE:
		if (!(cap->access & CAP_CAP_REPLICATE))
			return 0;
		break;
	case CAP_CONTROL_SPLIT:
		if (!(cap->access & CAP_CAP_SPLIT))
			return 0;
		break;
	case CAP_CONTROL_DEDUCE:
		if (!(cap->access & CAP_CAP_DEDUCE))
			return 0;
		break;
	case CAP_CONTROL_DESTROY:
		if (!(cap->access & CAP_CAP_DESTROY))
			return 0;
		break;
	default:
		/* We refuse to accept anything else */
		return 0;
	}

	/* Now check the usual restype/resid pair */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

struct sys_ipc_args {
	struct ktcb *task;
	unsigned int ipc_type;
	unsigned int xfer_type;
};

/*
 * Matches ipc direction, transfer type and target resource.
 *
 * Currently, receives are not checked as only sends have
 * a solid target id. Receives can be from any thread with
 * no particular target.
 */
struct capability *
cap_match_ipc(struct capability *cap, void *args_ptr)
{
	struct sys_ipc_args *args = args_ptr;
	struct ktcb *target = args->task;

	/* Check ipc type privileges */
	switch (args->xfer_type) {
	case IPC_FLAGS_SHORT:
		if (!(cap->access & CAP_IPC_SHORT))
			return 0;
		break;
	case IPC_FLAGS_FULL:
		if (!(cap->access & CAP_IPC_FULL))
			return 0;
		break;
	case IPC_FLAGS_EXTENDED:
		if (!(cap->access & CAP_IPC_EXTENDED))
			return 0;
		break;
	default:
		return 0;
	}

	/* NOTE: We only check on send capability */
	if (args->ipc_type & IPC_SEND)
		if (!(cap->access & CAP_IPC_SEND))
			return 0;

	/*
	 * We have a target thread, check if capability match
	 * any resource fields in target
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

struct sys_exregs_args {
	struct exregs_data *exregs;
	struct ktcb *task;
};

/*
 * CAP_TYPE_EXREGS already matched upon entry
 */
struct capability *
cap_match_exregs(struct capability *cap, void *args_ptr)
{
	struct sys_exregs_args *args = args_ptr;
	struct exregs_data *exregs = args->exregs;
	struct ktcb *target = args->task;

	/* Check operation privileges */
	if (exregs->valid_vect & EXREGS_VALID_REGULAR_REGS)
		if (!(cap->access & CAP_EXREGS_RW_REGS))
			return 0;
	if (exregs->valid_vect & EXREGS_VALID_SP)
		if (!(cap->access & CAP_EXREGS_RW_SP))
			return 0;
	if (exregs->valid_vect & EXREGS_VALID_PC)
		if (!(cap->access & CAP_EXREGS_RW_PC))
			return 0;
	if (args->exregs->valid_vect & EXREGS_SET_UTCB)
		if (!(cap->access & CAP_EXREGS_RW_UTCB))
			return 0;
	if (args->exregs->valid_vect & EXREGS_SET_PAGER)
		if (!(cap->access & CAP_EXREGS_RW_PAGER))
			return 0;

	/*
	 * We have a target thread, check if capability
	 * match any resource fields in target.
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

/*
 * FIXME: Issues on capabilities:
 *
 * As new pagers, thread groups,
 * thread ids, spaces are created, we need to
 * give them thread_control capabilities dynamically,
 * based on those ids!!! How do we get to do that, so that
 * in userspace it looks not so difficult ???
 *
 * What do you match here?
 *
 * THREAD_CREATE:
 *  - TC_SAME_SPACE
 *    - spid -> Does thread have cap to create in that space?
 *    - cid -> Does thread have cap to create in that container?
 *    - tgid -> Does thread have cap to create in that thread group?
 *    - pagerid -> Does thread have cap to create in that group of paged threads?
 *  - TC_NEW_SPACE or TC_COPY_SPACE
 *    - Check cid, tgid, pagerid,
 *  - TC_SHARE_GROUP
 *    - Check tgid
 *  - TC_AS_PAGER
 *    - pagerid -> Does thread have cap to create in that group of paged threads?
 *  - TC_SHARE_PAGER
 *    - pagerid -> Does thread have cap to create in that group of paged threads?
 *   New group -> New set of caps, thread_control, exregs, ipc, ... all of them!
 *   New pager -> New set of caps for that pager.
 *   New thread -> New set of caps for that thread!
 *   New space -> New set of caps for that space! So many capabilities!
 */

struct sys_tctrl_args {
	struct ktcb *task;
	unsigned int flags;
	struct task_ids *ids;
};

/*
 * CAP_TYPE_TCTRL matched upon entry
 */
struct capability *cap_match_thread(struct capability *cap,
				    void *args_ptr)
{
	struct sys_tctrl_args *args = args_ptr;
	struct ktcb *target = args->task;
	unsigned int action_flags = args->flags & THREAD_ACTION_MASK;

	/* Check operation privileges */
	switch (action_flags) {
	case THREAD_CREATE:
		if (!(cap->access & CAP_TCTRL_CREATE))
			return 0;
		break;
	case THREAD_DESTROY:
		if (!(cap->access & CAP_TCTRL_DESTROY))
			return 0;
		break;
	case THREAD_SUSPEND:
		if (!(cap->access & CAP_TCTRL_SUSPEND))
			return 0;
		break;
	case THREAD_RUN:
		if (!(cap->access & CAP_TCTRL_RUN))
			return 0;
		break;
	case THREAD_RECYCLE:
		if (!(cap->access & CAP_TCTRL_RECYCLE))
			return 0;
		break;
	case THREAD_WAIT:
		if (!(cap->access & CAP_TCTRL_WAIT))
			return 0;
		break;
	default:
		/* We refuse to accept anything else */
		return 0;
	}

	/* If no target and create, or vice versa, it really is a bug */
	BUG_ON(!target && action_flags != THREAD_CREATE);
	BUG_ON(target && action_flags == THREAD_CREATE);

	if (action_flags == THREAD_CREATE) {
		/*
		 * NOTE: Currently we only allow creation in
		 * current container.
		 *
		 * TODO: Add capability checking for space,
		 * as well.
		 *
		 * We _assume_ target is the largest group,
		 * e.g. same container as current. We check
		 * for `container' as target in capability
		 */
		if (cap_rtype(cap) != CAP_RTYPE_CONTAINER)
			return 0;
		if (cap->resid != curcont->cid)
			return 0;
		/* Resource type and id match, success */
		return cap;
	}

	/*
	 * We have a target thread, check if capability match
	 * any resource fields in target
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}
	return cap;
}

struct sys_map_args {
	struct ktcb *task;
	unsigned long phys;
	unsigned long virt;
	unsigned long npages;
	unsigned int flags;
};

/*
 * CAP_TYPE_MAP already matched upon entry
 */
struct capability *cap_match_mem(struct capability *cap,
				 void *args_ptr)
{
	struct sys_map_args *args = args_ptr;
	struct ktcb *target = args->task;
	unsigned long long start, end, pfn_point;
	unsigned long pfn;
	unsigned int perms;

	/* Set base according to what type of mem type we're matching */
	if (cap_type(cap) == CAP_TYPE_MAP_PHYSMEM)
		pfn = __pfn(args->phys);
	else
		pfn = __pfn(args->virt);

	/* Long long range check to avoid overflow */
	start = cap->start;
	end = cap->end;
	pfn_point = pfn;
	if (start > pfn_point || cap->end < pfn_point + args->npages)
		return 0;

	/* Check permissions */
	switch (args->flags) {
	case MAP_USR_RW:
		perms = CAP_MAP_READ | CAP_MAP_WRITE | CAP_MAP_CACHED;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	case MAP_USR_RWX:
		perms = CAP_MAP_READ | CAP_MAP_WRITE |
			CAP_MAP_EXEC | CAP_MAP_CACHED;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	case MAP_USR_RO:
		perms = CAP_MAP_READ | CAP_MAP_CACHED;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	case MAP_USR_RX:
		perms = CAP_MAP_READ | CAP_MAP_EXEC | CAP_MAP_CACHED;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	case MAP_USR_IO:
		perms = CAP_MAP_READ | CAP_MAP_WRITE | CAP_MAP_UNCACHED;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	case MAP_UNMAP:	/* Check for unmap syscall */
		if (!(cap->access & CAP_MAP_UNMAP))
			return 0;
		break;
	default:
		/* Anything else is an invalid/unrecognised argument */
		return 0;
	}

	/*
	 * We have a target thread, check if capability match
	 * any resource fields in target
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

struct sys_irqctrl_args {
	struct ktcb *registrant;
	unsigned int req;
	unsigned int flags;
	l4id_t irq;
};

/*
 * CAP_TYPE_MAP already matched upon entry.
 *
 * Match only device-specific details, e.g. irq registration
 * capability
 */
struct capability *cap_match_devmem(struct capability *cap,
				    void *args_ptr)
{
	struct sys_irqctrl_args *args = args_ptr;
	struct ktcb *target = args->registrant;
	unsigned int perms;

	/* It must be a physmem type */
	if (cap_type(cap) != CAP_TYPE_MAP_PHYSMEM)
		return 0;

	/* It must be a device */
	if (!cap_is_devmem(cap))
		return 0;

	/* Irq numbers should match */
	if (cap->irq != args->irq)
		return 0;

	/* Check permissions, we only check irq specific */
	switch (args->req) {
	case IRQ_CONTROL_REGISTER:
		perms = CAP_IRQCTRL_REGISTER;
		if ((cap->access & perms) != perms)
			return 0;
		break;
	default:
		/* Anything else is an invalid/unrecognised argument */
		return 0;
	}

	/*
	 * Check that irq registration to target is covered
	 * by the capability containment rules.
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}

/*
 * CAP_TYPE_IRQCTRL already matched
 */
struct capability *cap_match_irqctrl(struct capability *cap,
				     void *args_ptr)
{
	struct sys_irqctrl_args *args = args_ptr;
	struct ktcb *target = args->registrant;

	/* Check operation privileges */
	switch (args->req) {
	case IRQ_CONTROL_REGISTER:
		if (!(cap->access & CAP_IRQCTRL_REGISTER))
			return 0;
		break;
	case IRQ_CONTROL_WAIT:
		if (!(cap->access & CAP_IRQCTRL_WAIT))
			return 0;
		break;
	default:
		/* We refuse to accept anything else */
		return 0;
	}

	/*
	 * Target thread is the thread that is going to
	 * handle the irqs. Check if capability matches
	 * the target in any of its containment level.
	 */
	switch (cap_rtype(cap)) {
	case CAP_RTYPE_THREAD:
		if (target->tid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_SPACE:
		if (target->space->spid != cap->resid)
			return 0;
		break;
	case CAP_RTYPE_CONTAINER:
		if (target->container->cid != cap->resid)
			return 0;
		break;
	default:
		BUG(); /* Unknown cap type is a bug */
	}

	return cap;
}


struct sys_cache_args {
	unsigned long start;
	unsigned long npages;
	unsigned int flags;
};

struct capability *cap_match_cache(struct capability *cap, void *args_ptr)
{
	struct sys_cache_args *args = args_ptr;
	unsigned long pfn = __pfn(args->start);
	unsigned long long start, end, pfn_point;
	unsigned int perms;

	/* Long long range check to avoid overflow */
	start = cap->start;
	end = cap->end;
	pfn_point = pfn;
	if (start > pfn_point || end < pfn_point + args->npages)
		return 0;

	/* Check permissions */
	switch (args->flags) {
	/* check for cache functionality flags */
	case L4_INVALIDATE_DCACHE:
	case L4_INVALIDATE_ICACHE:
	case L4_INVALIDATE_TLB:
		perms = CAP_CACHE_INVALIDATE;
		if ((cap->access & perms) != perms)
			return 0;
		break;

	case L4_CLEAN_DCACHE:
	case L4_CLEAN_INVALIDATE_DCACHE:
		perms = CAP_CACHE_CLEAN;
		if ((cap->access & perms) != perms)
			return 0;
		break;

	default:
		/* Anything else is an invalid/unrecognised argument */
		return 0;
	}

	return cap;
}

#if defined(CONFIG_CAPABILITIES)
int cap_mutex_check(unsigned long mutex_address, int mutex_op)
{
	struct sys_mutex_args args = {
		.address = mutex_address,
		.op = mutex_op,
	};

	if (!(cap_find(current, cap_match_mutex,
		       &args, CAP_TYPE_UMUTEX)))
		return -ENOCAP;

	return 0;
}

int cap_cap_check(struct ktcb *task, unsigned int req, unsigned int flags)
{
	struct sys_capctrl_args args = {
		.req = req,
		.flags = flags,
		.task = task,
	};

	if (!(cap_find(current, cap_match_capctrl,
		       &args, CAP_TYPE_CAP)))
		return -ENOCAP;

	return 0;
}

int cap_map_check(struct ktcb *target, unsigned long phys, unsigned long virt,
		  unsigned long npages, unsigned int flags)
{
	struct capability *physmem, *virtmem;
	struct sys_map_args args = {
		.task = target,
		.phys = phys,
		.virt = virt,
		.npages = npages,
		.flags = flags,
	};

	if (!(physmem =	cap_find(current, cap_match_mem,
				 &args, CAP_TYPE_MAP_PHYSMEM)))
		return -ENOCAP;

	if (!(virtmem = cap_find(current, cap_match_mem,
				 &args, CAP_TYPE_MAP_VIRTMEM)))
		return -ENOCAP;

	return 0;
}

int cap_unmap_check(struct ktcb *target, unsigned long virt,
		    unsigned long npages)
{
	struct capability *virtmem;

	/* Unmap check also uses identical struct as map check */
	struct sys_map_args args = {
		.task = target,
		.virt = virt,
		.npages = npages,
		.flags = MAP_UNMAP,
	};

	if (!(virtmem = cap_find(current, cap_match_mem,
				 &args, CAP_TYPE_MAP_VIRTMEM)))
		return -ENOCAP;

	return 0;
}

/*
 * Limitation: We currently only check from sender's
 * perspective. This is because sender always targets a
 * real thread. Does sender have the right to do this ipc?
 */
int cap_ipc_check(l4id_t to, l4id_t from,
		  unsigned int flags, unsigned int ipc_type)
{
	struct ktcb *target;
	struct sys_ipc_args args;

	/* TODO: We don't check receivers, this works well for now. */
	if (ipc_type != IPC_SEND  && ipc_type != IPC_SENDRECV)
		return 0;

	/*
	 * We're the sender, meaning we have
	 * a real target
	 */
	if (!(target = tcb_find(to)))
		return -ESRCH;

	/* Set up other args */
	args.xfer_type = ipc_flags_get_type(flags);
	args.ipc_type = ipc_type;
	args.task = target;

	if (!(cap_find(current, cap_match_ipc,
		       &args, CAP_TYPE_IPC)))
		return -ENOCAP;

	return 0;
}

int cap_exregs_check(struct ktcb *task, struct exregs_data *exregs)
{
	struct sys_exregs_args args = {
		.exregs = exregs,
		.task = task,
	};

	/* We always search for current's caps */
	if (!(cap_find(current, cap_match_exregs,
		       &args, CAP_TYPE_EXREGS)))
		return -ENOCAP;

	return 0;
}

int cap_thread_check(struct ktcb *task,
		     unsigned int flags,
		     struct task_ids *ids)
{
	struct sys_tctrl_args args = {
		.task = task,
		.flags = flags,
		.ids = ids,
	};

	if (!(cap_find(current, cap_match_thread,
		       &args, CAP_TYPE_TCTRL)))
		return -ENOCAP;

	return 0;
}


int cap_irq_check(struct ktcb *registrant, unsigned int req,
		  unsigned int flags, l4id_t irq)
{
	struct sys_irqctrl_args args = {
		.registrant = registrant,
		.req = req,
		.flags = flags,
		.irq = irq,
	};

	/* Find the irq control capability of caller */
	if (!(cap_find(current, cap_match_irqctrl,
		       &args, CAP_TYPE_IRQCTRL)))
		return -ENOCAP;

	/*
	 * If it is an irq registration, find the device
	 * capability and check that it allows irq registration.
	 */
	if (req == IRQ_CONTROL_REGISTER)
		if (!cap_find(current, cap_match_devmem,
			      &args, CAP_TYPE_MAP_PHYSMEM))
			return -ENOCAP;
	return 0;
}

/*
 * This is just a wrapper call for l4_cache_control
 * system call sanity check
 */
int cap_cache_check(unsigned long start, unsigned long end, unsigned int flags)
{
	struct capability *virtmem;
	struct sys_cache_args args = {
		.start = start,
		.npages = __pfn(end) - __pfn(start),
		.flags = flags,
	};

	/*
	  * We just want to check if the virtual memory region
	  * concerned here has
	  *  appropriate permissions for cache calls
	  */
  	if (!(virtmem = cap_find(current, cap_match_cache,
			 	 &args, CAP_TYPE_MAP_VIRTMEM)))
	return -ENOCAP;

	return 0;
}

#else /* Meaning !CONFIG_CAPABILITIES */
int cap_mutex_check(unsigned long mutex_address, int mutex_op)
{
	return 0;
}

int cap_cap_check(struct ktcb *task, unsigned int req, unsigned int flags)
{
	return 0;
}

int cap_ipc_check(l4id_t to, l4id_t from,
		  unsigned int flags, unsigned int ipc_type)
{
	return 0;
}

int cap_map_check(struct ktcb *task, unsigned long phys, unsigned long virt,
		  unsigned long npages, unsigned int flags)
{
	return 0;
}

int cap_unmap_check(struct ktcb *target, unsigned long virt,
		    unsigned long npages)
{
	return 0;
}

int cap_exregs_check(struct ktcb *task, struct exregs_data *exregs)
{
	return 0;
}

int cap_thread_check(struct ktcb *task,
		     unsigned int flags,
		     struct task_ids *ids)
{
	return 0;
}

int cap_irq_check(struct ktcb *registrant, unsigned int req,
		  unsigned int flags, l4id_t irq)
{
	return 0;
}

int cap_cache_check(unsigned long start, unsigned long end,
		    unsigned int flags)
{
	return 0;
}
#endif /* End of !CONFIG_CAPABILITIES */
