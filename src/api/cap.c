/*
 * Capability manipulation syscall.
 *
 * The entry to Codezero security
 * mechanisms.
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <l4/api/capability.h>
#include <l4/generic/capability.h>
#include <l4/generic/cap-types.h>
#include <l4/generic/container.h>
#include <l4/generic/tcb.h>
#include <l4/api/errno.h>
#include INC_API(syscall.h)

/*
 * Read all capabilitites of the current process.
 * This includes the private ones as well as
 * ones shared by other tasks that the task has
 * rights to but doesn't own.
 */
int cap_read_all(struct capability *caparray)
{
	struct capability *cap;
	int capidx = 0;

	/* Copy all capabilities from lists to buffer */
	list_foreach_struct(cap, &current->cap_list.caps, list) {
		memcpy(&caparray[capidx], cap, sizeof(*cap));
		capidx++;
	}

	list_foreach_struct(cap, &current->space->cap_list.caps, list) {
		memcpy(&caparray[capidx], cap, sizeof(*cap));
		capidx++;
	}

	list_foreach_struct(cap, &curcont->cap_list.caps, list) {
		memcpy(&caparray[capidx], cap, sizeof(*cap));
		capidx++;
	}

	return 0;
}

/*
 * Shares single cap. If you are sharing, there is
 * only one target that makes sense, that is your
 * own container.
 */
int cap_share_single(struct capability *user)
{
	struct capability *cap;
	struct cap_list *clist;

	if (!(cap = cap_find_by_capid(user->capid, &clist)))
		return -EEXIST;

	if (cap->owner != current->tid)
		return -EPERM;

	/* First remove it from its list */
	cap_list_remove(cap, clist);

	/* Place it where it is shared */
	cap_list_insert(cap, &curcont->cap_list);

	return 0;
}

/*
 * Shares the whole capability list.
 *
 * FIXME: Make sure each and every capability has its
 * share right set!
 */
int cap_share_all(unsigned int flags)
{
	if (flags == CAP_SHARE_ALL_CONTAINER) {

		/* Move all private caps to container */
		cap_list_move(&curcont->cap_list,
			      &current->cap_list);

		/*
		 * Move all space caps to container, also.
		 *
		 * FIXME: Make sure all space capabilities
		 * are owned by the sharer!!!
		 */
		cap_list_move(&curcont->cap_list,
			      &current->space->cap_list);
	} else if (flags == CAP_SHARE_ALL_SPACE) {

		/* Move all private caps to space */
		cap_list_move(&current->space->cap_list,
			      &current->cap_list);
	}
	return 0;
}

int cap_share(struct capability *cap, unsigned int flags)
{
	if (flags == CAP_SHARE_SINGLE)
		return cap_share_single(cap);
	else
		return cap_share_all(flags);
}

#if 0

/*
 * Currently unused. API hasn't settled.
 */
/* Grants all caps */
int cap_grant_all(struct capability *req, unsigned int flags)
{
	struct ktcb *target;
	struct capability *cap_head, *cap;
	int err;

	/* Owners are always threads, for simplicity */
	if (!(target = tcb_find(req->owner)))
		return -ESRCH;

	/* Detach all caps */
	cap_head = cap_list_detach(&current->space->cap_list);

	list_foreach_struct(cap, &cap_head->list, list) {
		/* Change ownership */
		cap->owner = target->tid;
		BUG_ON(target->tid != req->owner);

		/* Make immutable if GRANT_IMMUTABLE given */
		if (flags & CAP_GRANT_IMMUTABLE) {
			cap->access &= ~CAP_GENERIC_MASK;
			cap->access |= CAP_IMMUTABLE;
		}

		/*
		 * Sanity check: granted cap cannot have used
		 * quantity. Otherwise how else the original
		 * users of the cap free them?
		 */
		if (cap->used) {
			err = -EPERM;
			goto out_err;
		}
	}

	/* Attach all to target */
	cap_list_attach(cap_head, &target->space->cap_list);
	return 0;

out_err:
	/* Attach it back to original */
	cap_list_attach(cap_head, &current->space->cap_list);
	return err;
}

#endif

int cap_grant_single(struct capability *req, unsigned int flags)
{
	struct capability *cap;
	struct cap_list *clist;
	struct ktcb *target;

	if (!(cap = cap_find_by_capid(req->capid, &clist)))
		return -EEXIST;

	if (!(target = tcb_find(req->owner)))
		return -ESRCH;

	if (cap->owner != current->tid)
		return -EPERM;

	/* Granted cap cannot have used quantity */
	if (cap->used)
		return -EPERM;

	/* First remove it from its list */
	cap_list_remove(cap, clist);

	/* Change ownership */
	cap->owner = target->tid;
	BUG_ON(cap->owner != req->owner);

	/* Make immutable if GRANT_IMMUTABLE given */
	if (flags & CAP_GRANT_IMMUTABLE) {
		cap->access &= ~CAP_GENERIC_MASK;
		cap->access |= CAP_IMMUTABLE;
	}

	/* Place it where it is granted */
	cap_list_insert(cap, &target->space->cap_list);

	return 0;
}

int cap_grant(struct capability *cap, unsigned int flags)
{
	if (flags & CAP_GRANT_SINGLE)
		cap_grant_single(cap, flags);
	else
		return -EINVAL;
	return 0;
}

int cap_deduce_rtype(struct capability *orig, struct capability *new)
{
	struct ktcb *target;
	struct address_space *sp;

	/* An rtype deduction can only be to a space or thread */
	switch (cap_rtype(new)) {
	case CAP_RTYPE_SPACE:
		/* Check containment right */
		if (cap_rtype(orig) != CAP_RTYPE_CONTAINER)
			return -ENOCAP;

		/*
		 * Find out if this space exists in this
		 * container.
		 *
		 * Note address space search is local only.
		 * Only thread searches are global.
		 */
		if (!(sp = address_space_find(new->resid)))
			return -ENOCAP;

		/* Success. Assign new type to original cap */
		cap_set_rtype(orig, cap_rtype(new));

		/* Assign the space id to orig cap */
		orig->resid = sp->spid;
		break;
	case CAP_RTYPE_THREAD:
		/* Find the thread */
		if (!(target = tcb_find(new->resid)))
			return -ENOCAP;

		/* Check containment */
		if (cap_rtype(orig) == CAP_RTYPE_SPACE) {
			if (orig->resid != target->space->spid)
				return -ENOCAP;
		} else if (cap_rtype(orig) == CAP_RTYPE_CONTAINER) {
			if(orig->resid != target->container->cid)
				return -ENOCAP;
		} else
			return -ENOCAP;

		/* Success. Assign new type to original cap */
		cap_set_rtype(orig, cap_rtype(new));

		/* Assign the space id to orig cap */
		orig->resid = target->tid;
		break;
	default:
		return -ENOCAP;
	}
	return 0;
}

/*
 * Deduction can be by access permissions, start, end, size
 * fields, or the target resource type. Inter-container
 * deduction is not allowed.
 *
 * Target resource deduction denotes reducing the applicable
 * space of the target, e.g. from a container to a space in
 * that container.
 *
 * NOTE: If there is no target deduction, you cannot change
 * resid, as this is forbidden.
 *
 * Imagine a space cap, it cannot be deduced to become applicable
 * to another space, i.e a space is in same privilege level.
 * But a container-wide cap can be reduced to be applied on
 * a space in that container (thus changing the resid to that
 * space's id)
 *
 * capid: Id of original capability
 * new: Userspace pointer to new state of capability
 * that is desired.
 *
 * orig = deduced;
 */
int cap_deduce(struct capability *new)
{
	struct capability *orig;
	struct cap_list *clist;
	int ret;

	/* Find original capability */
	if (!(orig = cap_find_by_capid(new->capid, &clist)))
		return -EEXIST;

	/* Check that caller is owner */
	if (orig->owner != current->tid)
		return -ENOCAP;

	/* Check that it is deducable */
	if (!(orig->access & CAP_CHANGEABLE))
		return -ENOCAP;

	/* Check target resource deduction */
	if (cap_rtype(new) != cap_rtype(orig))
		if ((ret = cap_deduce_rtype(orig, new)) < 0)
			return ret;

	/* Check owners are same for request validity */
	if (orig->owner != new->owner)
		return -EINVAL;

	/* Check permissions for deduction */
	if (orig->access) {
		/* New cannot have more bits than original */
		if ((orig->access & new->access) != new->access)
			return -EINVAL;
		/* New cannot make original redundant */
		if (new->access == 0)
			return -EINVAL;

		/* Deduce bits of orig */
		orig->access &= new->access;
	} else if (new->access)
		return -EINVAL;

	/* Check size for deduction */
	if (orig->size) {
		/* New can't have more, or make original redundant */
		if (new->size >= orig->size)
			return -EINVAL;

		/*
		 * Can't make reduction on used ones, so there
		 * must be enough available ones
		 */
		if (new->size < orig->used)
			return -EPERM;
		orig->size = new->size;
	} else if (new->size)
		return -EINVAL;

	/* Range-like permissions can't be deduced */
	if (orig->start || orig->end) {
		if (orig->start != new->start ||
		    orig->end != new->end)
			return -EPERM;
	} else if (new->start || new->end)
		return -EINVAL;

	/* Ensure orig and new are the same */
	BUG_ON(orig->capid != new->capid);
	BUG_ON(orig->resid != new->resid);
	BUG_ON(orig->owner != new->owner);
	BUG_ON(orig->type != new->type);
	BUG_ON(orig->access != new->access);
	BUG_ON(orig->start != new->start);
	BUG_ON(orig->end != new->end);
	BUG_ON(orig->size != new->size);
	BUG_ON(orig->used != new->used);

	return 0;
}

/*
 * Destroys a capability
 */
int cap_destroy(struct capability *cap)
{
	struct capability *orig;
	struct cap_list *clist;

	/* Find original capability */
	if (!(orig = cap_find_by_capid(cap->capid, &clist)))
		return -EEXIST;

	/* Check that caller is owner */
	if (orig->owner != current->tid)
		return -ENOCAP;

	/* Check that it is destroyable */
	if (!(cap_generic_perms(orig) & CAP_CHANGEABLE))
		return -ENOCAP;

	/*
	 * Check that it is not a device.
	 *
	 * We don't allow devices for now. To do this
	 * correctly, we need to check if device irq
	 * is not currently registered.
	 */
	if (cap_is_devmem(orig))
		return -ENOCAP;

	cap_list_remove(orig, clist);
	free_capability(orig);
	return 0;
}

static inline int cap_has_size(struct capability *c)
{
	return c->size;
}

static inline int cap_has_range(struct capability *c)
{
	return c->start && c->end;
}

/*
 * Splits a capability
 *
 * Pools of typed memory objects can't be replicated, and
 * deduced that way, as replication would temporarily double
 * their size. So they are split in place.
 *
 * Splitting occurs by diff'ing resources possessed between
 * capabilities.
 *
 * capid: Original capability that is valid.
 * diff: New capability that we want to split out.
 *
 * orig = orig - diff;
 * new = diff;
 */
int cap_split(struct capability *diff, unsigned int flags)
{
	struct capability *orig, *new;
	struct cap_list *clist;
	int ret;

	/* Find original capability */
	if (!(orig = cap_find_by_capid(diff->capid, &clist)))
		return -EEXIST;

	/* Check target type/resid/owner is the same */
	if (orig->type != diff->type ||
	    orig->resid != diff->resid ||
	    orig->owner != diff->owner)
		return -EINVAL;

	/* Check that caller is owner */
	if (orig->owner != current->tid)
		return -ENOCAP;

	/* Check owners are same */
	if (orig->owner != diff->owner)
		return -EINVAL;

	/* Check that it is splitable */
	if (!(orig->access & CAP_CHANGEABLE))
		return -ENOCAP;

	/* Create new */
	if (!(new = capability_create()))
		return -ENOCAP;

	/* Check access bits usage and split */
	if (flags & CAP_SPLIT_ACCESS) {
		/* Access bits must never be redundant */
		BUG_ON(!orig->access);

		/* Split one can't have more bits than original */
		if ((orig->access & diff->access) != diff->access) {
			ret = -EINVAL;
			goto out_err;
		}

		/* Split one cannot make original redundant */
		if ((orig->access & ~diff->access) == 0) {
			ret = -EINVAL;
			goto out_err;
		}

		/* Split one cannot be redundant itself */
		if (!diff->access) {
			ret = -EINVAL;
			goto out_err;
		}

		/* Subtract given access permissions */
		orig->access &= ~diff->access;

		/* Assign given perms to new capability */
		new->access = diff->access;
	} else {
		/* Can't split only by access bits alone */
		if (!cap_has_size(orig) &&
		    !cap_has_range(orig)) {
			ret = -EINVAL;
			goto out_err;
		}
		/* If no split, then they are identical */
		new->access = orig->access;

		/* Diff must also reflect orig by convention */
		if (diff->access != orig->access) {
			ret = -EINVAL;
			goto out_err;
		}
	}

	/* If cap has size, split by size is compulsory */
	if (cap_type(orig) == CAP_TYPE_QUANTITY) {
		BUG_ON(!cap_has_size(orig));

		/*
		 * Split one can't have more,
		 * or make original redundant
		 */
		if (diff->size >= orig->size) {
			ret = -EINVAL;
			goto out_err;
		}

		/* Split one can't be redundant itself */
		if (!diff->size) {
			ret = -EINVAL;
			goto out_err;
		}

		/* Split one must be clean i.e. all unused */
		if (orig->size - orig->used < diff->size) {
			ret = -EPERM;
			goto out_err;
		}

		orig->size -= diff->size;
		new->size = diff->size;
		new->used = 0;
	} else {

		/* Diff must also reflect orig by convention */
		if (diff->size != orig->size) {
			ret = -EINVAL;
			goto out_err;
		}

		/* If no split, then they are identical */
		new->size = orig->size;
		new->used = orig->used;

	}

	if (flags & CAP_SPLIT_RANGE) {
		/* They must either be both one or both zero */
		BUG_ON(!!orig->start ^ !!orig->end);

		/* If orig doesn't have a range, return invalid */
		if (!orig->start && !orig->end) {
			ret = -EINVAL;
			goto out_err;
		} else {
			/* Orig has a range but diff doesn't */
			if (!diff->start || !diff->end) {
				ret = -EINVAL;
				goto out_err;
			}
			/* Both valid, but we don't permit range split */
			ret = -EPERM;
			goto out_err;
		}
	/* If no split, then they are identical */
	} else {
		new->start = orig->start;
		new->end = orig->end;
	}

	/* Copy other fields */
	new->type = orig->type;
	new->resid = orig->resid;
	new->owner = orig->owner;

	/* Add the new capability to the most private list */
	cap_list_insert(new, &current->space->cap_list);

	/* Check fields that must be identical */
	BUG_ON(new->resid != diff->resid);
	BUG_ON(new->owner != diff->owner);
	BUG_ON(new->type != diff->type);
	BUG_ON(new->access != diff->access);
	BUG_ON(new->start != diff->start);
	BUG_ON(new->end != diff->end);
	BUG_ON(new->size != diff->size);

	/* Copy capid, and used field that may not be the same */
	diff->capid = new->capid;
	diff->used = new->used;
	return 0;

out_err:
	free_capability(new);
	return ret;
}

/*
 * Replicates an existing capability. This is for expanding
 * capabilities to managed children.
 *
 * After replication, a duplicate capability exists in the
 * system, but as it is not a quantity, this does not increase
 * the capabilities of the caller in any way.
 */
int cap_replicate(struct capability *dupl)
{
	struct capability *new, *orig;
	struct cap_list *clist;

	/* Find original capability */
	if (!(orig = cap_find_by_capid(dupl->capid, &clist)))
		return -EEXIST;

	/* Check that caller is owner */
	if (orig->owner != current->tid)
		return -ENOCAP;

	/* Check that it is replicable */
	if (!(orig->access & CAP_REPLICABLE))
		return -ENOCAP;

	 /* Quantitative types must not be replicable */
	if (cap_type(orig) == CAP_TYPE_QUANTITY) {
		printk("Cont %d: FATAL: Capability (%d) "
		       "is quantitative but also replicable\n",
		       curcont->cid, orig->capid);
		/* FIXME: Should rule this out as a CML2 requirement */
		BUG();
	}

	/* Replicate it */
	if (!(new = capability_create()))
		return -ENOCAP;

	/* Copy all except capid & listptrs */
	dupl->resid = new->resid = orig->resid;
	dupl->owner = new->owner = orig->owner;
	dupl->type = new->type = orig->type;
	dupl->access = new->access = orig->access;
	dupl->start = new->start = orig->start;
	dupl->end = new->end = orig->end;
	dupl->size = new->size = orig->size;
	dupl->used = new->used = orig->used;

	/* Copy new fields */
	dupl->capid = new->capid;

	/* Add it to most private list */
	cap_list_insert(new, &current->space->cap_list);

	return 0;
}

/*
 * Read, manipulate capabilities.
 */
int sys_capability_control(unsigned int req, unsigned int flags, void *userbuf)
{
	int err = 0;

	/*
	 * Check capability to do a capability operation.
	 * Supported only on current's caps for time being.
	 */
	if ((err = cap_cap_check(current, req, flags)) < 0)
		return err;

	/* Check access for each request */
	switch(req) {
	case CAP_CONTROL_NCAPS:
		if ((err = check_access((unsigned long)userbuf,
					sizeof(int),
					MAP_USR_RW, 1)) < 0)
			return err;
		break;
	case CAP_CONTROL_READ:
		if ((err = check_access((unsigned long)userbuf,
					cap_count(current) *
					sizeof(struct capability),
					MAP_USR_RW, 1)) < 0)
			return err;
		break;
	case CAP_CONTROL_SHARE:
		if (flags == CAP_SHARE_ALL_CONTAINER ||
		    flags == CAP_SHARE_ALL_SPACE)
			break;
	case CAP_CONTROL_GRANT:
	case CAP_CONTROL_SPLIT:
	case CAP_CONTROL_REPLICATE:
	case CAP_CONTROL_DEDUCE:
	case CAP_CONTROL_DESTROY:
		if ((err = check_access((unsigned long)userbuf,
					sizeof(struct capability),
					MAP_USR_RW, 1)) < 0)
			return err;
		break;
	default:
		return -EINVAL;
	}

	/* Take action for each request */
	switch(req) {
	case CAP_CONTROL_NCAPS:
		*((int *)userbuf) = cap_count(current);
		break;
	case CAP_CONTROL_READ:
		err = cap_read_all((struct capability *)userbuf);
		break;
	case CAP_CONTROL_SHARE:
		err = cap_share((struct capability *)userbuf, flags);
		break;
	case CAP_CONTROL_GRANT:
		err = cap_grant((struct capability *)userbuf, flags);
		break;
	case CAP_CONTROL_SPLIT:
		err = cap_split((struct capability *)userbuf, flags);
		break;
	case CAP_CONTROL_REPLICATE:
		err = cap_replicate((struct capability *)userbuf);
		break;
	case CAP_CONTROL_DEDUCE:
		err = cap_deduce((struct capability *)userbuf);
		break;
	case CAP_CONTROL_DESTROY:
		err = cap_destroy((struct capability *)userbuf);
		break;
	default:
		return -EINVAL;
	}

	return err;
}

