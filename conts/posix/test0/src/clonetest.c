/*
 * Clone test.
 */
#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sched.h>
#include <errno.h>
#include <tests.h>

int clone_global = 0;

extern pid_t parent_of_all;

int my_thread_func(void *arg)
{
	for (int i = 0; i < 25; i++)
		clone_global++;
	_exit(0);
}

int clonetest(void)
{
	pid_t childid;
	void *child_stack;

	/* Parent loops and calls clone() to clone new threads. Children don't come back from the clone() call */
	for (int i = 0; i < 20; i++) {
		if ((child_stack = mmap(0, 0x1000, PROT_READ | PROT_WRITE, MAP_ANONYMOUS | MAP_PRIVATE | MAP_GROWSDOWN, 0, 0)) == MAP_FAILED) {
			test_printf("MMAP failed.\n");
			goto out_err;
		} else {
			test_printf("Mapped area starting at %p\n", child_stack);
		}
		// printf("mmap returned child stack: %p\n", child_stack);

		// ((int *)child_stack)[-1] = 5; /* Test mapped area */

		test_printf("Cloning...\n");

		if ((childid = clone(my_thread_func, child_stack,
		     CLONE_PARENT | CLONE_FS | CLONE_VM | CLONE_THREAD | CLONE_SIGHAND, 0)) < 0) {
			test_printf("CLONE failed.\n");
			goto out_err;
		} else {
			test_printf("Cloned a new thread with child pid %d\n", childid);
		}
	}

	/* TODO: Add wait() or something similar and check that global is 100 */

	if (getpid() == parent_of_all)
		printf("CLONE TEST          -- PASSED --\n");

	return 0;
out_err:
	printf("CLONE TEST          -- FAILED --\n");
	return 0;
}

