/*
 * Initialise posix-related structures.
 *
 * Copyright (C) 2007-2009 Bahadir Balban
 */
#include <l4lib/kip.h>
#include <l4lib/ipcdefs.h>
#include <l4/macros.h>
#include <stdio.h>
#include <shpage.h>
#include <sys/types.h>
#include <sys/shm.h>
#include <shpage.h>
#include <libposix.h>
#include INC_GLUE(memlayout.h)

#if 0

/*
 * Shared page initialisation of posix-like tasks.
 *
 * POSIX tasks currently use a default shared page for communciation.
 * This could have been also done by long ipc calls.
 */

/*
 * Shared page for this task. Used for passing data among ipc
 * parties when message registers are not big enough. Every thread
 * has right to own one, and it has an address unique to every
 * thread. It must be explicitly mapped by both parties of the ipc
 * in order to be useful.
 */
void *shared_page;

/*
 * Obtains a unique address for the task's shared page. Note this
 * just returns the address. This address is used as an shm key
 * to map it via shmget()/shmat() later on.
 */
static void *shared_page_address(void)
{
	void *addr;
	int err;

	/* We're asking it for ourself. */
	write_mr(L4SYS_ARG0, self_tid());

	/* Call pager with utcb address request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid,
			       L4_IPC_TAG_SHPAGE)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return PTR_ERR(err);
	}

	/* Check if syscall itself was successful */
	if (IS_ERR(addr = (void *)l4_get_retval())) {
		print_err("%s: Request UTCB Address Error: %d.\n",
		       __FUNCTION__, (int)addr);
		return addr;
	}

	return addr;
}

/*
 * Initialises a non-pager task's default shared memory page
 * using posix semantics. Used during task initialisation
 * and by child tasks after a fork.
 */
int shared_page_init(void)
{
	int shmid;
	void *shmaddr;

	/*
	 * Initialise shared page only if we're not the pager.
	 * The pager does it differently for itself.
	 */
	BUG_ON(self_tid() == pagerid);

	/* Obtain our shared page address */
	shared_page = shared_page_address();

	//print_err("%s: UTCB Read from mm0 as: 0x%x\n", __FUNCTION__,
	//       (unsigned long)shared_page);

	/* Use it as a key to create a shared memory region */
	BUG_ON((shmid = shmget((key_t)shared_page,
			       PAGE_SIZE, IPC_CREAT)) < 0);

	/* Attach to the region */
	BUG_ON((shmaddr = shmat(shmid, shared_page, 0)) < 0);
	BUG_ON(shmaddr != shared_page);

	return 0;
}

#endif
