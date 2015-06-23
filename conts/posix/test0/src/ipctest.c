/*
 * Tests for more complex ipc such as full and extended
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */
#include <l4lib/ipcdefs.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <tests.h>
#include <capability.h>

/*
 * Full ipc test. Sends/receives full utcb, done with the pager.
 */
void ipc_full_test(void)
{
	int ret = 0;

	/* Fill in all of the utcb locations */
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
		//printf("Writing: MR%d: %d\n", i, i);
		write_mr(i, i);
	}

	/* Call the pager */
	if ((ret = l4_sendrecv_full(pagerid, pagerid,
				    L4_IPC_TAG_SYNC_FULL)) < 0) {
		printf("%s: Failed with %d\n", __FUNCTION__, ret);
		BUG();
	}
	/* Read back updated utcb */
	for (int i = MR_UNUSED_START; i < MR_TOTAL + MR_REST; i++) {
		//printf("Read MR%d: %d\n", i, read_mr(i));
		if (read_mr(i) != 0) {
			printf("Expected 0 on all mrs. Failed.\n");
			BUG();
		}
	}

	if (!ret)
		printf("FULL IPC TEST:      -- PASSED --\n");
	else
		printf("FULL IPC TEST:      -- FAILED --\n");
}

/*
 * This is an extended ipc test that is done between 2 tasks that fork.
 */
void ipc_extended_test(void)
{
	pid_t child, parent;
	struct capability cap;
	void *base;
	char *ipcbuf;
	int err;

	memset(&cap, 0, sizeof(cap));

	/* Get parent pid */
	parent = getpid();

	/* Fork the current task */
	if ((child = fork()) < 0) {
		test_printf("%s: Fork failed with %d\n", __FUNCTION__, errno);
		goto out_err;
	}
	if (child)
		test_printf("%d: Created child with pid %d\n", getpid(), child);
	else
		test_printf("Child %d running.\n", getpid());

	/* This test makes this assumption */
	BUG_ON(L4_IPC_EXTENDED_MAX_SIZE > PAGE_SIZE);

	/*
	 * Request capability to ipc to each other from pager
	 * (Actually only the sender needs it)
	 */
	if (child) {
		cap.owner = parent;
		cap.resid = child;
	} else {
		cap.owner = getpid();
		cap.resid = parent;
	}
	cap.type = CAP_TYPE_IPC | CAP_RTYPE_THREAD;
	cap.access = CAP_IPC_EXTENDED | CAP_IPC_SEND | CAP_IPC_RECV;
	if ((err = cap_request_pager(&cap)) < 0) {
		printf("Ipc capability request failed. "
		       "err = %d\n", err);
		goto out_err;
	}

	/*
	 * Both child and parent gets 2 pages
	 * of privately mapped anonymous memory
	 */
	if ((int)(base = mmap(0, PAGE_SIZE*2, PROT_READ | PROT_WRITE,
			      MAP_PRIVATE | MAP_ANONYMOUS, 0, 0)) < 0) {
		printf("%s: mmap for extended ipc buffer failed: %d\n",
			    __FUNCTION__, (int)base);
		goto out_err;
	} else
		test_printf("%s: mmap: Anonymous private buffer at %p\n",
			    __FUNCTION__, base);

	/*
	 * Both tasks read/write both pages
	 * across the page boundary for messages
	 */
	ipcbuf = base + PAGE_SIZE - L4_IPC_EXTENDED_MAX_SIZE / 2;

	/* Child sending message */
	if (child == 0) {
		/* Child creates a string of maximum extended ipc size */
		for (int i = 0; i < L4_IPC_EXTENDED_MAX_SIZE; i++) {
			ipcbuf[i] = 'A' + i % 20;
		}
		/* Finish string with newline and null pointer */
		ipcbuf[L4_IPC_EXTENDED_MAX_SIZE - 2] = '\n';
		ipcbuf[L4_IPC_EXTENDED_MAX_SIZE - 1] = '\0';

		/* Send message to parent */
		test_printf("Child sending message: %s\n", ipcbuf);
		if ((err = l4_send_extended(parent, L4_IPC_TAG_SYNC_EXTENDED,
					    L4_IPC_EXTENDED_MAX_SIZE,
					    ipcbuf)) < 0) {
			printf("Extended ipc error: %d\n", err);
			goto out_err;
		}

	/* Parent receiving message */
	} else {
		/*
		 * Parent receives on the buffer - we are sure that the
		 * buffer is not paged in because we did not touch it.
		 * This should prove that page faults are handled during
		 * the ipc.
		 */
		test_printf("Parent: extended receiving from child.\n");
		if ((err = l4_receive_extended(child, L4_IPC_EXTENDED_MAX_SIZE,
					       ipcbuf)) < 0) {
			printf("Extended ipc error: %d\n", err);
			goto out_err;
		}

		/* We now print the message created by child. */
		test_printf("(%d): Message received from child: %s\n",
		       getpid(), ipcbuf);

		/* Check that string received from child is an exact match */
		for (int i = 0; i < L4_IPC_EXTENDED_MAX_SIZE - 2; i++) {
			if (ipcbuf[i] != ('A' + i % 20))
				goto out_err;
		}
		if (ipcbuf[L4_IPC_EXTENDED_MAX_SIZE - 2] != '\n')
			goto out_err;
		if (ipcbuf[L4_IPC_EXTENDED_MAX_SIZE - 1] != '\0')
			goto out_err;

		printf("EXTENDED IPC TEST:  -- PASSED --\n");
	}
	return;

out_err:
	printf("EXTENDED IPC TEST:  -- FAILED --\n");
}





