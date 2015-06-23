/*
 * Some minimal tests for SMP functionality
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/exregs.h>
#include <l4lib/lib/thread.h>
#include <stdio.h>
#include <string.h>
#include <tests.h>

static int new_thread_func(void *args)
{
	struct exregs_data exregs;
	struct task_ids ids;
	int err;

	l4_getid(&ids);

#if 0
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_read(&exregs);
	if ((err = l4_exchange_registers(&exregs,
					 ids.tid)) < 0) {
		printf("SMP test: Exregs call failed on %s\n",
		       __FUNCTION__);
	}

	dbg_printf("New thread running successfully on cpu %d "
		   "tid=%d. Exiting...\n", self_tid(),
		   exregs.cpu_affinity);
#endif

	dbg_printf("SMP:New thread running successfully"
		   "tid=%d. Exiting...\n", self_tid());

	return 0;
}

/*
 * Create 2 threads on different cpus and run them.
 *
 * Parent then destroys the child. Parent and child
 * are on different cpus.
 */
int test_smp_two_threads(void)
{
	struct exregs_data exregs;
	struct l4_thread *thread;
	int err, err2;

	dbg_printf("%s: Creating a new thread\n", __FUNCTION__);
	/*
	 * Create new thread but don't start it
	 */
	if ((err = thread_create(new_thread_func, 0,
				 TC_SHARE_SPACE | TC_NOSTART,
				 &thread)) < 0) {
		dbg_printf("THREAD_CREATE failed. "
			   "err=%d\n", err);
		return err;
	}
#if 0
	dbg_printf("%s: Setting child affinity to %d\n", __FUNCTION__, 1);
	/*
	 * Set its cpu affinity to cpu = 1
	 */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_affinity(&exregs, 1);

	/* Write to affinity field */
	if ((err = l4_exchange_registers(&exregs,
					 thread->ids.tid)) < 0) {
		printf("%s: Exregs on setting cpu affinity "
		       "failed on newly created thread. err=%d\n",
		       __FUNCTION__, err);
		goto out_err;
	}

	dbg_printf("%s: Running child on other cpu\n", __FUNCTION__);
#endif
	/* Start the thread */
	l4_thread_control(THREAD_RUN, &thread->ids);

	dbg_printf("%s: Waiting on child\n", __FUNCTION__);
	/* Wait on the thread */
	if ((err = thread_wait(thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		goto out_err;
	} else {
		dbg_printf("Thread %d exited successfully. ret=%d\n",
			   thread->ids.tid, err);
	}

	dbg_printf("%s: Child destroyed successfully\n", __FUNCTION__);
	return 0;

out_err:
	/*
	 * Destroy the thread from parent
	 */
	if ((err2 = thread_destroy(thread)) < 0) {
		dbg_printf("THREAD_DESTROY failed. "
			   "err=%d\n", err2);
		return err2;
	}
	return err;
}

int test_smp_two_spaces(void)
{
	return 0;
}

int test_smp_ipc(void)
{
	return 0;
}

#if defined (CONFIG_SMP)
int test_smp(void)
{
	int err;

	if ((err = test_smp_two_threads()) < 0)
		return err;

	if ((err = test_smp_two_spaces()) < 0)
		return err;

	if ((err = test_smp_ipc()) < 0)
		return err;

	return 0;
}
#else /* Not CONFIG_SMP */

int test_smp(void)
{
	return 0;
}
#endif /* Endif */

