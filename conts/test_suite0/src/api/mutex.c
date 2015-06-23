/*
 * Test l4_mutex_control system call.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */

#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/thread.h>
#include <l4lib/mutex.h>
#include <tests.h>

#define MUTEX_NTHREADS			8
#define MUTEX_INCREMENTS		200
#define MUTEX_VALUE_TOTAL		(MUTEX_NTHREADS * MUTEX_INCREMENTS)

struct mutex_test_data {
	struct l4_mutex lock;
	int val;
};

static struct mutex_test_data tdata;

static void init_test_data(struct mutex_test_data *tdata)
{
	l4_mutex_init(&tdata->lock);
	tdata->val = 0;
}


int mutex_thread_non_contending(void *arg)
{
	struct mutex_test_data *data =
		(struct mutex_test_data *)arg;
	l4id_t tid = self_tid();
	int err = tid;

	for (int i = 0; i < MUTEX_INCREMENTS; i++) {
		/* Lock the data structure */
		if ((err = l4_mutex_lock(&data->lock)) < 0) {
			dbg_printf("Thread %d: Acquiring mutex failed. "
				   "err = %d\n", tid, err);
			return -err;
		}

		/*
		 * Increment and release lock
		 */
		data->val++;

		/* Unlock the data structure */
		if ((err = l4_mutex_unlock(&data->lock)) < 0) {
			dbg_printf("Thread %d: Releasing the mutex failed. "
				   "err = %d\n", tid, err);
			return -err;
		}
	}

	return 0;
}



int mutex_thread_contending(void *arg)
{
	struct mutex_test_data *data =
		(struct mutex_test_data *)arg;
	l4id_t tid = self_tid();
	int err = tid;

	for (int i = 0; i < MUTEX_INCREMENTS; i++) {
		/* Lock the data structure */
		if ((err = l4_mutex_lock(&data->lock)) < 0) {
			dbg_printf("Thread %d: Acquiring mutex failed. "
				   "err = %d\n", tid, err);
			return -err;
		}

		/*
		 * Sleep some time to have some
		 * threads blocked on the mutex
		 */
		for (int j = 0; j < 3; j++)
			l4_thread_switch(0);

		/*
		 * Increment and release lock
		 */
		data->val++;

		/* Unlock the data structure */
		if ((err = l4_mutex_unlock(&data->lock)) < 0) {
			dbg_printf("Thread %d: Releasing the mutex failed. "
				   "err = %d\n", tid, err);
			return -err;
		}
	}

	return 0;
}


int test_mutex(int (*mutex_thread)(void *))
{
	struct l4_thread *thread[MUTEX_NTHREADS];
	int err;

	/* Init mutex data */
	init_test_data(&tdata);

	/*
	 * Lock the mutex so nobody starts working
	 */
	if ((err = l4_mutex_lock(&tdata.lock)) < 0) {
		dbg_printf("Acquiring mutex failed. "
			   "err = %d\n", err);
		return err;
	}

	/* Create threads */
	for (int i = 0; i < MUTEX_NTHREADS; i++) {
		if ((err = thread_create(mutex_thread,
					 &tdata,
					 TC_SHARE_SPACE,
					 &thread[i])) < 0) {
			dbg_printf("Thread create failed. "
				   "err=%d\n", err);
			return err;
		}
	}

	/* Unlock the mutex and initiate all workers */
	if ((err = l4_mutex_unlock(&tdata.lock)) < 0) {
		dbg_printf("Releasing the mutex failed. "
			   "err = %d\n", err);
		return -err;
	}

	/*
	 * Wait for all threads to exit successfully
	 */
	for (int i = 0; i < MUTEX_NTHREADS; i++) {
		if ((err = thread_wait(thread[i])) < 0) {
			dbg_printf("THREAD_WAIT failed. "
				   "err=%d\n", err);
			return err;
		}
	}

	/*
	 * Test that lock is in correct state
	 */
	if (tdata.lock.lock != L4_MUTEX_UNLOCKED) {
		dbg_printf("MUTEX is not in unlocked condition "
			   "after tests. lockval = %d, expected = %d\n",
			   tdata.lock.lock, L4_MUTEX_UNLOCKED);
		return -1;
	}

	/*
	 * Test that increments have occured correctly
	 */
	if (tdata.val != MUTEX_VALUE_TOTAL) {
		dbg_printf("Lock-protected value incremented incorrectly "
			   "after mutex worker threads.\n"
			   "val = %d, expected = %d\n",
			   tdata.val,
			   MUTEX_VALUE_TOTAL);
		return -1;
	}
	if (tdata.val != MUTEX_VALUE_TOTAL) {
		dbg_printf("Lock-protected value incremented incorrectly "
			   "after mutex worker threads.\n"
			   "val = %d, expected = %d\n",
			   tdata.val,
			   MUTEX_VALUE_TOTAL);
		return -1;
	}

	dbg_printf("Mutex test successful.\n");
	return 0;
}

int test_api_mutexctrl(void)
{
	int err;

	if ((err = test_mutex(mutex_thread_contending)) < 0)
		goto out_err;

	if ((err = test_mutex(mutex_thread_non_contending)) < 0)
		goto out_err;

	printf("USERSPACE MUTEX:               -- PASSED --\n");
	return 0;

out_err:
	printf("USERSPACE MUTEX:               -- FAILED --\n");
	return err;
}

