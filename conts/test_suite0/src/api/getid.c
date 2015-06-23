/*
 * Test l4_getid system call.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/thread.h>
#include <tests.h>


int thread_getid_nullptr(void *arg)
{
	return l4_getid(0);
}

/*
 * Pass nullptr to l4_getid syscall
 *
 * This exercise proves that the kernel does not crash
 * and validly sends a page fault to offending thread's
 * pager.
 */
int test_getid_nullptr(void)
{
	struct l4_thread *thread;
	int err;

	/*
	 * Create a new thread who will attempt
	 * passing null ptr argument
	 */
	if ((err = thread_create(thread_getid_nullptr,
				 0, TC_SHARE_SPACE,
				 &thread)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", thread->ids.tid);

	/*
	 * Listen on thread for its page fault
	 * ipc. (Recap: Upon illegal access, the kernel sends
	 * a page fault ipc message to thread's pager)
	 */
	if ((err = l4_receive(thread->ids.tid)) < 0) {
		dbg_printf("%s: listening on page fault for "
			   "nullptr thread failed. "
			   "err = %d\n", __FUNCTION__, err);
		return err;
	}

	/*
	 * Verify ipc was a page fault ipc
	 */
	if (l4_get_tag() != L4_IPC_TAG_PFAULT) {
		dbg_printf("%s: Nullptr thread ipc does not "
			   "have expected page fault tag.\n"
			   "tag=%d, expected=%d\n",
			   __FUNCTION__, l4_get_tag(),
			   L4_IPC_TAG_PFAULT);
		return -1;
	}

	/*
	 * Destroy the thread.
	 */
	if ((err = thread_destroy(thread)) < 0) {
		dbg_printf("%s: Failed destroying thread. "
			   "err= %d, tid = %d\n",
			   __FUNCTION__, err,
			   thread->ids.tid);
		return err;
	}
	return 0;
}

int test_api_getid(void)
{
	struct task_ids ids;
	int err;

	/*
	 * Test valid getid request
	 */
	if ((err = l4_getid(&ids)) < 0) {
		dbg_printf("Getid request failed. err=%d\n", err);
		goto out_err;
	}

	/* Check returned results */
	if (ids.tid != 1 || ids.spid != 1 || ids.tgid != 1) {
		dbg_printf("Getid results not as expected. "
			   "tid=%d, spid=%d, tgid=%d\n",
			   ids.tid, ids.spid, ids.tgid);
		err = -1;
		goto out_err;
	}

	/*
	 * Test null pointer argument
	 */
	if ((err = test_getid_nullptr()) < 0) {
		dbg_printf("l4_getid() null pointer test failed."
			   " err=%d\n", err);
		goto out_err;
	}

	printf("GETID:                         -- PASSED --\n");
	return 0;

out_err:
	printf("GETID:                         -- FAILED --\n");
	return err;

}

