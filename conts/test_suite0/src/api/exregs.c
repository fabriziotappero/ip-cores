/*
 * Test exchange registers system call.
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

int test_exregs_read_write(void)
{
	struct task_ids ids;
	struct exregs_data exregs[2];
	int err;

	/* Get own space id */
	l4_getid(&ids);

	/*
	 * Create a thread in the same space.
	 * Thread is not runnable.
	 */
	if ((err = l4_thread_control(THREAD_CREATE | TC_SHARE_SPACE,
				     &ids)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", ids.tid);

	/*
	 * Prepare a context part full of 0xFF
	 */
	memset(&exregs[0].context, 0xFF, sizeof(exregs[1].context));
	exregs[0].valid_vect = 0xFFFFFFFF;

	/* Write to context */
	if ((err = l4_exchange_registers(&exregs[0], ids.tid)) < 0)
		goto out;

	/* Set the other as read-all */
	exregs_set_read(&exregs[1]);
	exregs[1].valid_vect = 0xFFFFFFFF;
	if ((err = l4_exchange_registers(&exregs[1],
					 ids.tid)) < 0)
		goto out;

	/*
	 * Read back all context and compare results
	 */
	if (memcmp(&exregs[0].context, &exregs[1].context,
		   sizeof(exregs[0].context))) {
		err = -1;
		goto out;
	}

out:
	/*
	 * Destroy the thread
	 */
	if ((err = l4_thread_control(THREAD_DESTROY, &ids)) < 0) {
		dbg_printf("Thread destroy failed. err=%d\n",
			   err);
	}
	return 0;
}


int test_api_exregs(void)
{
	int err;

	if ((err = test_exregs_read_write()) < 0)
		goto out_err;

	/*
	 * TODO: Should add more tests here, e.g. setting
	 * values of a thread we're not a pager of.
	 */

	printf("EXCHANGE REGISTERS:            -- PASSED --\n");
	return 0;

out_err:
	printf("EXCHANGE REGISTERS:            -- FAILED --\n");
	return err;

}

