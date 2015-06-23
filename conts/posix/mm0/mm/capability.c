/*
 * Pager's capabilities for kernel resources
 *
 * Copyright (C) 2009 Bahadir Balban
 */
#include <bootm.h>
#include <init.h>
#include <memory.h>
#include <capability.h>
#include <l4/api/errno.h>
#include <l4/lib/list.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4/generic/cap-types.h>	/* TODO: Move this to API */
#include L4LIB_INC_ARCH(syslib.h)
#include <malloc/malloc.h>
#include <user.h>

/* Capability descriptor list */
struct cap_list capability_list;

__initdata static struct capability *caparray;
__initdata static int total_caps = 0;

void cap_list_print(struct cap_list *cap_list)
{
	struct capability *cap;
	printf("Capabilities\n"
	       "~~~~~~~~~~~~\n");

	list_foreach_struct(cap, &cap_list->caps, list)
		cap_print(cap);

	printf("\n");
}

#define PAGER_TOTAL_MUTEX		5
int setup_children_mutex(int total_caps, struct cap_list *cap_list)
{
	struct capability *diff_cap, *mutex_cap;

	struct task_ids ids;
	int err;

	l4_getid(&ids);

	//cap_list_print(cap_list);

	/* Find out own mutex capability on our own container */
	list_foreach_struct(mutex_cap, &cap_list->caps, list) {
		if (cap_type(mutex_cap) == CAP_TYPE_QUANTITY &&
		    cap_rtype(mutex_cap) == CAP_RTYPE_MUTEXPOOL)
			goto found;
	}
	printf("cont%d: %s: FATAL: Could not find ipc "
	       "capability to own container.\n",
	       __cid(ids.tid), __FUNCTION__);
	BUG();

found:
	/* Create a new capability */
	BUG_ON(!(diff_cap = kzalloc(sizeof(*mutex_cap))));

	/* Copy it over to new mutex cap buffer */
	memcpy(diff_cap, mutex_cap, sizeof (*mutex_cap));

	/*
	 * We would like to take some mutexes,
	 * and leave the rest to children.
	 *
	 * We set up a capability that we want
	 * to separate out from the original
	 */
	if (mutex_cap->size <= PAGER_TOTAL_MUTEX) {
		printf("%s: FATAL: Can't reserve enough mutexes "
		       "for children. capid = %d, mutexes = %lu, "
		       "pager needs = %d\n", __FUNCTION__,
		       mutex_cap->capid, mutex_cap->size,
		       PAGER_TOTAL_MUTEX);
		BUG();
	}

	/* Reserve out some mutexes to self */
	diff_cap->size = PAGER_TOTAL_MUTEX;

	/* Split the mutex capability, passing the difference */
	if ((err = l4_capability_control(CAP_CONTROL_SPLIT,
					 0, diff_cap)) < 0) {
		printf("l4_capability_control() replication of "
		       "ipc capability failed.\n Could not "
		       "complete CAP_CONTROL_SPLIT request on cap (%d), "
		       "err = %d.\n", diff_cap->capid, err);
		BUG();
	}

	/*
	 * The returned one is the given diff, but
	 * created as a new capability, add it to list
	 */
	cap_list_insert(diff_cap, cap_list);
	// cap_list_print(cap_list);

	/*
	 * Share the remainder capability with our container.
	 *
	 * This effectively enables all threads/spaces in this container
	 * to use this pool of mutexes.
	 */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE, CAP_SHARE_SINGLE,
					 mutex_cap)) < 0) {
		printf("l4_capability_control() sharing of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_SHARE request.\n");
		BUG();
	}
	// cap_list_print(cap_list);

	/* Find mutex syscall operation capability on our own container */
	list_foreach_struct(mutex_cap, &cap_list->caps, list) {
		if (cap_type(mutex_cap) == CAP_TYPE_UMUTEX &&
		    cap_rtype(mutex_cap) == CAP_RTYPE_CONTAINER)
			goto found2;
	}
	printf("cont%d: %s: FATAL: Could not find UMUTEX "
	       "capability to own container.\n",
	       __cid(ids.tid), __FUNCTION__);
	BUG();

found2:

	/*
	 * Share it with our container.
	 *
	 * This effectively enables all threads/spaces in this container
	 * to use this pool of mutexes.
	 */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE, CAP_SHARE_SINGLE,
					 mutex_cap)) < 0) {
		printf("l4_capability_control() sharing of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_SHARE request.\n");
		BUG();
	}

	return 0;
}


/*
 * Replicate, deduce and grant to children the capability to
 * talk to us only.
 *
 * We are effectively creating an ipc capability from what we already
 * own, and the new one has a reduced privilege in terms of the
 * targetable resource.
 *
 * We are replicating our capability to talk to our complete container
 * into a capability to only talk to our current space. Our space is a
 * reduced target, since it is a subset contained in our container.
 */
int setup_children_ipc(int total_caps, struct cap_list *cap_list)
{
	struct capability *ipc_cap, *cap;
	struct task_ids ids;
	int err;

	l4_getid(&ids);

	// cap_list_print(cap_list);

	/* Find out our own ipc capability on our own container */
	list_foreach_struct(cap, &cap_list->caps, list) {
		if (cap_type(cap) == CAP_TYPE_IPC &&
		    cap_rtype(cap) == CAP_RTYPE_CONTAINER &&
		    cap->resid == __cid(ids.tid))
			goto found;
	}
	printf("cont%d: %s: FATAL: Could not find ipc "
	       "capability to own container.\n",
	       __cid(ids.tid), __FUNCTION__);
	BUG();

found:
	/* Create a new capability */
	BUG_ON(!(ipc_cap = kzalloc(sizeof(*ipc_cap))));

	/* Copy it over to new ipc cap buffer */
	memcpy(ipc_cap, cap, sizeof (*cap));

	/* Replicate the ipc capability, giving original as reference */
	if ((err = l4_capability_control(CAP_CONTROL_REPLICATE,
					 0, ipc_cap)) < 0) {
		printf("l4_capability_control() replication of "
		       "ipc capability failed.\n Could not "
		       "complete CAP_CONTROL_REPLICATE request on cap (%d), "
		       "err = %d.\n", ipc_cap->capid, err);
		BUG();
	}

	/* Add it to list */
	cap_list_insert(ipc_cap, cap_list);
	// cap_list_print(cap_list);

	/*
	 * The returned capability is a replica.
	 *
	 * Now deduce it such that it applies to talking only to us,
	 * instead of to the whole container as original.
	 */
	cap_set_rtype(ipc_cap, CAP_RTYPE_SPACE);
	ipc_cap->resid = ids.spid; /* This space is target resource */
	if ((err = l4_capability_control(CAP_CONTROL_DEDUCE,
					 0, ipc_cap)) < 0) {
		printf("l4_capability_control() deduction of "
		       "ipc capability failed.\n Could not "
		       "complete CAP_CONTROL_DEDUCE request on cap (%d), "
		       "err = %d.\n", ipc_cap->capid, err);
		BUG();
	}

	// cap_list_print(cap_list);

	/*
	 * Share it with our container.
	 *
	 * This effectively enables all threads/spaces in this container
	 * to communicate to us only, and be able to do nothing else.
	 */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE,
					 CAP_SHARE_SINGLE,
					 ipc_cap)) < 0) {
		printf("l4_capability_control() sharing of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_SHARE request.\n");
		BUG();
	}
	// cap_list_print(cap_list);

	return 0;
}

int setup_children_caps(int total_caps, struct cap_list *cap_list)
{
	setup_children_ipc(total_caps, cap_list);
	setup_children_mutex(total_caps, cap_list);
	return 0;
}

/* Copy all init-memory allocated capabilities */
void copy_boot_capabilities(int ncaps)
{
	struct capability *cap;

	capability_list.ncaps = 0;
	link_init(&capability_list.caps);

	for (int i = 0; i < ncaps; i++) {
		cap = kzalloc(sizeof(struct capability));

		/* This copies kernel-allocated unique cap id as well */
		memcpy(cap, &caparray[i], sizeof(struct capability));

		/* Initialize capability list */
		link_init(&cap->list);

		/* Add capability to global cap list */
		cap_list_insert(cap, &capability_list);
	}
}

int cap_read_all()
{
	int ncaps;
	int err;
	struct capability *cap;

	/* Read number of capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_NCAPS,
					 0, &ncaps)) < 0) {
		printf("l4_capability_control() reading # of"
		       " capabilities failed.\n Could not "
		       "complete CAP_CONTROL_NCAPS request.\n");
		BUG();
	}
	total_caps = ncaps;

	/* Allocate array of caps from boot memory */
	caparray = alloc_bootmem(sizeof(struct capability) * ncaps, 0);

	/* Read all capabilities */
	if ((err = l4_capability_control(CAP_CONTROL_READ,
					 0, caparray)) < 0) {
		printf("l4_capability_control() reading of "
		       "capabilities failed.\n Could not "
		       "complete CAP_CONTROL_READ_CAPS request.\n");
		BUG();
	}


	/* Copy them to real allocated structures */
	copy_boot_capabilities(ncaps);

	// cap_list_print(&capability_list);

	memset(&cont_mem_regions, 0, sizeof(cont_mem_regions));

	/* Set up pointers to important capabilities */
	list_foreach_struct(cap, &capability_list.caps, list) {
		/* Physical memory bank */
		if (cap_type(cap) == CAP_TYPE_MAP_PHYSMEM)
			cont_mem_regions.physmem = cap;

		/* Virtual regions */
		if (cap_type(cap) == CAP_TYPE_MAP_VIRTMEM) {

			/* Pager address region (get from linker-defined) */
			if (__pfn_to_addr(cap->start)
			    == (unsigned long)virtual_base)
				cont_mem_regions.pager = cap;

			/* UTCB address region */
			else if (UTCB_REGION_START ==
				 __pfn_to_addr(cap->start)) {
				if (UTCB_REGION_END !=
				    __pfn_to_addr(cap->end)) {
					printf("FATAL: Region designated "
					       "for UTCB allocation does not "
					       "match on start/end marks");
					BUG();
				}

				if (!(cap->access & CAP_MAP_UTCB)) {
					printf("FATAL: Region designated "
					       "for UTCB allocation does not "
					       "have UTCB map permissions");
					BUG();
				}
				cont_mem_regions.utcb = cap;
			}

			/* Shared memory disjoint region */
			else if (SHMEM_REGION_START ==
				 __pfn_to_addr(cap->start)) {
				if (SHMEM_REGION_END !=
				    __pfn_to_addr(cap->end)) {
					printf("FATAL: Region designated "
					       "for SHM allocation does not "
					       "match on start/end marks");
					BUG();
				}

				cont_mem_regions.shmem = cap;
			}

			/* Task memory region */
			else if (TASK_REGION_START ==
				 __pfn_to_addr(cap->start)) {
				if (TASK_REGION_END !=
				    __pfn_to_addr(cap->end)) {
					printf("FATAL: Region designated "
					       "for Task address space does"
					       "not match on start/end mark.");
					BUG();
				}
				cont_mem_regions.task = cap;
			}
		}
	}

	if (!cont_mem_regions.task ||
	    !cont_mem_regions.shmem ||
	    !cont_mem_regions.utcb ||
	    !cont_mem_regions.physmem ||
	    !cont_mem_regions.pager) {
		printf("%s: Error, pager does not have one of the required"
	 	       "mem capabilities defined. (TASK, SHM, PHYSMEM, UTCB, PAGER)\n",
		       __TASKNAME__);
		printf("%p, %p, %p, %p, %p\n", cont_mem_regions.task,
		       cont_mem_regions.shmem, cont_mem_regions.utcb,
		       cont_mem_regions.physmem, cont_mem_regions.pager);
		BUG();
	}

	return 0;
}

void setup_caps()
{
	cap_read_all();
	setup_children_caps(total_caps, &capability_list);
}

/*
 * Find our own, widened replicable capability of same type as given,
 * replicate, reduce and grant as described with given parameters.
 * Assumes parameters have already been validated and security-checked.
 */
int cap_find_replicate_reduce_grant(struct capability *cap)
{
	struct capability *possessed;
	struct capability new_cap;
	int err;

	/* Merely match type, kernel does actual check on suitability */
	list_foreach_struct(possessed, &capability_list.caps, list) {
		/* Different type, pass */
		if (cap_type(possessed) != cap_type(cap))
			continue;

		/* Copy possessed one to new one's buffer */
		memcpy(&new_cap, possessed, sizeof(*possessed));

		/* Replicate capability, giving original as reference */
		if ((err = l4_capability_control(CAP_CONTROL_REPLICATE,
						 0, &new_cap)) < 0) {
			printf("l4_capability_control() replication of "
			       "capability failed.\n Could not complete "
			       "CAP_CONTROL_REPLICATE request on cap (%d), "
			       "err = %d.\n", new_cap.capid, err);
			return err;
		}

		/*
		 * The returned capability is a replica.
		 *
		 * We don't add the newly created one to our own internal
		 * list because we will grant it shortly and lose its
		 * possession
		 *
		 * Now deduce it such that it looks like the one requested.
		 * Note, we assume the request had been validated before.
		 * Also note, the owner shall be still us.
		 */
		new_cap.resid = cap->resid;
		new_cap.type = cap->type;
		new_cap.access = cap->access;
		new_cap.start = cap->start;
		new_cap.end = cap->end;
		new_cap.size = cap->size;
		new_cap.used = cap->used;

		/*
		 * Make sure it is transferable,
		 * since we will need to grant it soon
		 */
		new_cap.access |= CAP_TRANSFERABLE;


		if ((err = l4_capability_control(CAP_CONTROL_DEDUCE,
						 0, &new_cap)) < 0) {
			/* Couldn't deduce this one, destroy the replica */
			if ((err =
			     l4_capability_control(CAP_CONTROL_DESTROY,
						   0, &new_cap)) < 0) {
				printf("l4_capability_control() destruction of "
				       "capability failed.\n Could not "
				       "complete CAP_CONTROL_DESTROY request "
				       " on cap (%d), err = %d.\n",
				       new_cap.capid, err);
				BUG();
			}
		} else /* Success */
			goto success;
	}

	return -ENOCAP;

success:
	/*
	 * Found suitable one to replicate/deduce.
	 * Grant it to requested owner.
	 *
	 * This effectively enables the owner to have all
	 * operations defined in the capability. However,
	 * we use a flag to make the capability immutable
	 * as we grant it. (We wouldn't be able to grant
	 * it if it had no grant permission originally. We
	 * remove it _as_ we grant it)
	 */
	new_cap.owner = cap->owner; /* Indicate new owner */
	if ((err = l4_capability_control(CAP_CONTROL_GRANT,
					 CAP_GRANT_SINGLE |
					 CAP_GRANT_IMMUTABLE,
					 &new_cap)) < 0) {
		printf("l4_capability_control() granting of "
		       "capability (%d) failed.\n Could not "
		       "complete CAP_CONTROL_GRANT request.\n",
		       new_cap.capid);
		return err;
	}
	return 0;
}

/*
 * A task that we manage requests a capability to do an operation
 * from us, such as the capability to do a particular ipc to a
 * particular thread. We consider the request and give the
 * capability if it is appropriate. This currently supports only
 * ipc.
 */
int sys_request_cap(struct tcb *task, struct capability *__cap_userptr)
{
	struct tcb *target;
	struct capability *cap;
	int ret;

	if (!(cap = pager_get_user_page(task, __cap_userptr,
					sizeof(*__cap_userptr),
					VM_READ | VM_WRITE)))
		return -EFAULT;

	/* Only support IPC requests for now */
	if (cap_type(cap) != CAP_TYPE_IPC) {
		ret = -EPERM;
	}

	/* Validate rest of the fields */
	if (cap->start || cap->end || cap->used || cap->size) {
		ret = -EINVAL;
		goto out;
	}

	if (cap_generic_perms(cap) != CAP_IMMUTABLE) {
		ret = -EPERM;
		goto out;
	}

	/* Find out who the task wants to ipc */
	switch (cap_rtype(cap)) {
	/* Is it a thread? */
	case CAP_RTYPE_THREAD:
		/* Find the thread */
		if (!(target = find_task(cap->resid))) {
			ret = -ESRCH;
			goto out;
		}

		/* Requester must be the owner */
		if (cap->owner != task->tid) {
			ret = -EPERM;
			goto out;
		}

		/*
		 * It is a thread that we are managing, nothing
		 * special requested here, just grant it
		 */
		if ((ret = cap_find_replicate_reduce_grant(cap)) < 0)
			goto out;
		break;
	case CAP_RTYPE_SPACE:
		/* Space requests not allowed */
		ret = -EPERM;
		goto out;
	case CAP_RTYPE_CONTAINER:
		/* Container requests not allowed */
		ret = -EPERM;
		goto out;
	}

out:
	return ret;
}

