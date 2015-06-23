/*
 * Tests for userspace mutexes
 *
 * Copyright (C) 2007-2009 Bahadir Bilgehan Balban
 */
#include <l4lib/ipcdefs.h>
#include <l4lib/mutex.h>
#include <errno.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <unistd.h>
#include <tests.h>
#include <capability.h>

/*
 * This structure is placed at the head of shared memory.
 * Tasks lock and write to rest of the page. Indicate that
 * they have run, and the later running task tests that both
 * processes has run and no data corruption occured on page_rest.
 */
struct shared_page {
	struct l4_mutex mutex;
	int shared_var;
};

static struct shared_page *shared_page;

/*
 * This test forks a parent task, creates a shared memory mapping, and makes two tasks
 * lock and write to almost the whole page 10 times with different values, and makes
 * the tasks test that the writes are all there without any wrong values. The amount of
 * time spent should justify a context switch and demonstrate that lock protects the
 * region.
 */
int user_mutex_test(void)
{
	pid_t child, parent;
	int map_size = PAGE_SIZE;
	struct capability cap;
	void *base;
	int err;

	/* Get parent pid */
	parent = getpid();


	/*
	 * Create a shared anonymous memory region. This can be
	 * accessed by both parent and child after a fork.
	 */
	if (IS_ERR(base = mmap(0, map_size, PROT_READ | PROT_WRITE,
			      MAP_SHARED | MAP_ANONYMOUS, 0, 0))) {
		printf("%s: mmap for extended ipc buffer failed: %x\n",
			    __FUNCTION__, (int)base);
		goto out_err;
	} else
		test_printf("mmap: Anonymous shared buffer at %p\n", base);

	shared_page = base;

	/* Initialize the mutex */
	l4_mutex_init(&shared_page->mutex);

	/* Initialize the shared variable */
	shared_page->shared_var = 0;

	/* Fork the current task */
	if ((child = fork()) < 0) {
		test_printf("%s: Fork failed with %d\n", __FUNCTION__, errno);
		goto out_err;
	}

	if (child)
		test_printf("%d: Created child with pid %d\n", getpid(), child);
	else
		test_printf("Child %d running.\n", getpid());

	/*
	 * Request capability to ipc to each other from pager
	 * (Actually only the sender needs it)
	 */
	memset(&cap, 0, sizeof(cap));
	if (child) {
		cap.owner = parent;
		cap.resid = child;
	} else {
		cap.owner = getpid();
		cap.resid = parent;
	}

	cap.type = CAP_TYPE_IPC | CAP_RTYPE_THREAD;
	cap.access = CAP_IPC_SHORT | CAP_IPC_SEND | CAP_IPC_RECV;
	if ((err = cap_request_pager(&cap)) < 0) {
		printf("Ipc capability request failed. "
		       "err = %d\n", err);
		goto out_err;
	}

	/* Child locks and produces */
	if (child == 0) {

		for (int x = 0; x < 2000; x++) {
			int temp;

			/* Lock page */
	//		test_printf("Child locking page.\n");
			l4_mutex_lock(&shared_page->mutex);

			/* Read variable */
	//		test_printf("Child locked page.\n");
			temp = shared_page->shared_var;

			/* Update local copy */
			temp++;

			/* Thread switch */
			l4_thread_switch(0);

			/* Write back the result */
			shared_page->shared_var = temp;

	//		test_printf("Child modified. Unlocking...\n");

			/* Unlock */
			l4_mutex_unlock(&shared_page->mutex);
	//		test_printf("Child unlocked page.\n");

			/* Thread switch */
			l4_thread_switch(0);

		}
		/* Sync with the parent */
		if ((err = l4_send(parent, L4_IPC_TAG_SYNC)) < 0) {
			printf("Error: l4_send() failed with %d\n", err);
			goto out_err;
		}


	/* Parent locks and consumes */
	} else {
		for (int x = 0; x < 2000; x++) {
			int temp;

			/* Lock page */
	//		test_printf("Parent locking page.\n");
			l4_mutex_lock(&shared_page->mutex);

			/* Read variable */
	//		test_printf("Parent locked page.\n");
			temp = shared_page->shared_var;

			/* Update local copy */
			temp--;

			/* Thread switch */
			l4_thread_switch(0);

			/* Write back the result */
			shared_page->shared_var = temp;

	//		test_printf("Parent modified. Unlocking...\n");

			/* Unlock */
			l4_mutex_unlock(&shared_page->mutex);
	//		test_printf("Parent unlocked page.\n");

			/* Thread switch */
			l4_thread_switch(0);
		}
		/* Sync with the child */
		if ((err = l4_receive(child)) < 0) {
			printf("Error: l4_receive() failed with %d\n", err);
			goto out_err;
		}

	//	test_printf("Parent checking validity of value.\n");
		if (shared_page->shared_var != 0)
			goto out_err;

		printf("USER MUTEX TEST:    -- PASSED --\n");
	}
	return 0;

out_err:
	printf("USER MUTEX TEST:    -- FAILED --\n");
	return -1;
}





