/*
 * Test l4_thread_control system call.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */

#include <l4lib/lib/thread.h>
#include <stdio.h>
#include <tests.h>

/*
 * A secondary thread that tests
 * various conditions by taking actions
 * told by its parent.
 */
int new_thread_func(void *args)
{
	dbg_printf("New thread running successfully. "
		   "tid=%d\n", self_tid());

	return 0;
}

/*
 * Thread that exits by doing some number of
 * thread switches to ensure parent has a chance
 * to wait on it or attempt to destroy it
 * The purpose is to test parent-wait before self-destroy.
 */
int delayed_exit_func(void *args)
{
	int x = 5;
	l4id_t parent = *((l4id_t *)args);

	dbg_printf("%s: thread running successfully. "
		   "tid=%d\n", __FUNCTION__, self_tid());

	/*
	 * Switch to parent a few times to ensure it
	 * runs and begins to wait on us
	 */
	while (x--)
		l4_thread_switch(parent);

	return 5;
}

/*
 * Thread that exits immediately
 * Purpose is to test parent-wait after self-destroy.
 */
int imm_exit_func(void *args)
{
	return 5;
}

/*
 * We have 3 thread creation scenarios to test.
 */
struct l4_thread *test_thread_create()
{
	struct l4_thread *tptr;
	int err;

	dbg_printf("%s: Creating thread", __FUNCTION__);

	/*
	 * Create a thread in the same space
	 */
	if ((err = thread_create(new_thread_func, 0,
				 TC_SHARE_SPACE,
				 &tptr)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return PTR_ERR(err);
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", tptr->ids.tid);

	return tptr;
}

/*
 * Test thread run/resume, suspend
 *
 * We don't test recycle as that would delete the current
 * address space
 */
int test_thread_actions(struct l4_thread *thread)
{
	int err;

	dbg_printf("Suspending thread "
		   "tid=%d\n", thread->ids.tid);

	/*
	 * Suspend/resume the thread
	 */
	if ((err = l4_thread_control(THREAD_SUSPEND, &thread->ids)) < 0) {
		dbg_printf("THREAD_SUSPEND failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Suspend OK. Resuming thread "
		   "tid=%d\n", thread->ids.tid);

	if ((err = l4_thread_control(THREAD_RUN, &thread->ids)) < 0) {
		dbg_printf("THREAD_RUN failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Resume OK."
		   "tid=%d\n", thread->ids.tid);

	return 0;
}

/*
 * Test thread destruction
 */
int test_thread_destroy(struct l4_thread *thread)
{
	int err;
	l4id_t id_self = self_tid();

	dbg_printf("Destroying thread."
		   "tid=%d\n", thread->ids.tid);

	/*
	 * Destroy the thread from parent
	 */
	if ((err = thread_destroy(thread)) < 0) {
		dbg_printf("THREAD_DESTROY failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("%s: Destroy OK\n", __FUNCTION__);

	dbg_printf("%s: Creating new thread\n", __FUNCTION__);

	/*
	 * Create a new thread
	 * and tell it to destroy itself
	 * by adding a delay, then wait on it.
	 *
	 * Delay ensures we test the case that
	 * wait occurs before thread is destroyed.
	 */
	if ((err = thread_create(delayed_exit_func, &id_self,
				 TC_SHARE_SPACE,
				 &thread)) < 0) {
		dbg_printf("THREAD_CREATE failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread->ids.tid);

	dbg_printf("Waiting on thread, "
		   "tid=%d\n", thread->ids.tid);

	/* Wait on the thread */
	if ((err = thread_wait(thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		return err;
	} else {
		dbg_printf("Thread %d exited successfully. ret=%d\n",
			   thread->ids.tid, err);
	}

	/*
	 * Create a new thread
	 * and tell it to destroy itself
	 * immediately, add a delay and
	 * then wait on it.
	 *
	 * Delay ensures we test the case that
	 * wait occurs after thread is destroyed.
	 */
	if ((err = thread_create(imm_exit_func, 0,
				 TC_SHARE_SPACE,
				 &thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		return err;
	}

	/* Wait on the thread */
	if ((err = thread_wait(thread)) < 0) {
		dbg_printf("THREAD_WAIT failed. "
			   "err=%d\n", err);
		return err;
	} else {
		dbg_printf("Thread %d exited successfully. ret=%d\n",
			   thread->ids.tid, err);
	}

	return 0;
}

/*
 * TODO: In order to test null pointers a separate
 * thread who is paged by the main one should attempt
 * to pass a null ptr.
 */
int test_thread_invalid(struct l4_thread *thread)
{
	return 0;
}

int test_api_tctrl(void)
{
	struct l4_thread *thread;
	int err;

	/* Test thread create */
	if (IS_ERR(thread = test_thread_create())) {
		err = (int)thread;
		goto out_err;
	}

	/* Test thread actions */
	if ((err = test_thread_actions(thread)) < 0)
		goto out_err;

	/* Test thread destruction */
	if ((err = test_thread_destroy(thread)) < 0)
		goto out_err;

	/* Test thread invalid input */
	if ((err = test_thread_invalid(thread)) < 0)
		goto out_err;

	printf("THREAD CONTROL:                -- PASSED --\n");
	return 0;

out_err:
	printf("THREAD CONTROL:                -- FAILED --\n");
	return err;
}

