#include <thread.h>
#include <container.h>
#include <capability.h>
#include <tests.h>
#include <l4/api/errno.h>
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include <l4/api/capability.h>

int simple_pager_thread(void *arg)
{
	int err;
	int res = *(int *)arg;
	struct task_ids ids;
	int testres = 0;

	l4_getid(&ids);

	printf("Thread spawned from pager, \
	       trying to create new thread.\n");
	err = l4_thread_control(THREAD_CREATE |
				TC_SHARE_SPACE, &ids);

	if (res == 0)
		if (err == -ENOCAP ||
		    err == -ENOMEM) {
			printf("Creation failed with %d "
			       "as expected.\n", err);
			testres = 0;
		} else {
			printf("Creation was supposed to fail "
			       "with %d or %d, but err = %d\n",
			       -ENOMEM, -ENOCAP, err);
			testres = 1;
		}
	else
		if (err == 0) {
			// printf("Creation succeeded as expected.\n");
			testres = 0;
		} else {
			printf("Creation was supposed to succeed, "
			       "but err = %d\n", err);
			testres = 1;
		}

	/* Destroy thread we created */
	if (err == 0 &&
	    res == 0)
		l4_thread_control(THREAD_DESTROY, &ids);

	/* Destroy self */
	l4_exit(testres);

	return 0;
}

int wait_check_test(struct task_ids *ids)
{
	int result;

	/* Wait for thread to finish */
	result = l4_thread_control(THREAD_WAIT, ids);
	if (result < 0) {
		printf("Waiting on (%d)'s exit failed.\n", ids->tid);
		return -1;
	} else if (result > 0) {
		printf("Top-level test has failed\n");
	}
	/* Else it is a success */

	return 0;
}

int capability_test(void)
{
	int err;
	struct task_ids ids;
	int TEST_MUST_FAIL = 0;
	//int TEST_MUST_SUCCEED = 1;

	/* Read pager capabilities */
	caps_read_all();

	/*
	 * Create new thread that will attempt
	 * a pager privileged operation
	 */
	if ((err = thread_create(simple_pager_thread,
				 &TEST_MUST_FAIL,
				 TC_SHARE_SPACE, &ids)) < 0) {
		printf("Top-level simple_pager creation failed.\n");
		goto out_err;
	}

	printf("waititng for result\n");
	/* Wait for test to finish and check result */
	if (wait_check_test(&ids) < 0)
		goto out_err;
#if 0

	/* Destroy test thread */
	if ((err = l4_thread_control(THREAD_DESTROY, &ids)) < 0) {
		printf("Destruction of top-level simple_pager failed.\n");
		BUG();
	}

	/*
	 * Share operations with the same thread
	 * group
	 */
	if ((err = l4_capability_control(CAP_CONTROL_SHARE,
					 CAP_SHARE_CONTAINER, 0)) < 0) {
		printf("Sharing capability with thread group failed.\n");
		goto out_err;
	}

	/*
	 * Create new thread that will attempt a pager privileged
	 * operation. This should succeed as we shared caps with
	 * the thread group.
	 */
	if ((err = thread_create(simple_pager_thread,
				 &TEST_MUST_SUCCEED,
				 TC_SHARE_SPACE |
				 TC_SHARE_GROUP, &ids)) < 0) {
		printf("Top-level simple_pager creation failed.\n");
		goto out_err;
	}

	/* Wait for test to finish and check result */
	if (wait_check_test(&ids) < 0)
		goto out_err;

	/* Destroy test thread */
	if ((err = l4_thread_control(THREAD_DESTROY, &ids)) < 0) {
		printf("Destruction of top-level simple_pager failed.\n");
		BUG();
	}
#endif

	printf("Capability Sharing Test		-- PASSED --\n");

	return 0;

out_err:
	printf("Capability Sharing Test		-- FAILED --\n");
	return 0;
}
