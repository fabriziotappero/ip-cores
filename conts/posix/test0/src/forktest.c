/*
 * Fork test.
 */

#include <stdio.h>
#include <unistd.h>
#include <sys/types.h>
#include <tests.h>
#include <l4/macros.h>

int global = 0;


int forktest(void)
{
	pid_t myid;


	/* 16 forks */
	for (int i = 0; i < 3; i++) {
		test_printf("%d: Forking...\n", getpid());
		if (fork() < 0)
			goto out_err;
	}

	myid = getpid();

	if (global != 0) {
		test_printf("Global not zero.\n");
		test_printf("-- FAILED --\n");
		goto out_err;
	}
	global += myid;

	if (global != myid)
		goto out_err;


	if (getpid() != parent_of_all) {
		/* Exit here to exit successful children */
		//_exit(0);
		//BUG();
	}

	if (getpid() == parent_of_all)
		printf("FORK TEST           -- PASSED --\n");

	return 0;

	/* Any erroneous child or parent comes here */
out_err:
	printf("FORK TEST           -- FAILED --\n");
	return 0;
}

