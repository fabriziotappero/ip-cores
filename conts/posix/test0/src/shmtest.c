/*
 * Test shmget/shmat/shmdt posix calls.
 *
 * Copyright (C) 2007 - 2008 Bahadir Balban
 */
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <tests.h>
#include <unistd.h>
#include <errno.h>

int shmtest(void)
{
	//key_t keys[2] = { 5, 10000 };
	key_t keys[2] = { 2, 3 };
	void *bases[2] = { 0 , 0 };
	int shmids[2];

	test_printf("Initiating shmget()\n");
	for (int i = 0; i < 2; i++) {
		if ((shmids[i] = shmget(keys[i], 27, IPC_CREAT | 0666)) < 0) {
			test_printf("SHMGET", errno);
			goto out_err;
		} else
			test_printf("SHMID returned: %d\n", shmids[i]);
	}
	test_printf("Now shmat()\n");
	for (int i = 0; i < 2; i++) {
		if ((int)(bases[i] = shmat(shmids[i], NULL, 0)) == -1) {
			test_printf("SHMAT", errno);
			goto out_err;
		} else
			test_printf("SHM base address returned: %p\n", bases[i]);
	}
	/* Write to the bases */
	*((unsigned int *)bases[0]) = 0xDEADBEEF;
	*((unsigned int *)bases[1]) = 0xFEEDBEEF;

	test_printf("Now shmdt()\n");
	for (int i = 0; i < 2; i++) {
		if (shmdt(bases[i]) < 0) {
			test_printf("SHMDT", errno);
			goto out_err;
		} else
			test_printf("SHM detached OK.\n");
	}
	test_printf("Now shmat() again\n");
	for (int i = 0; i < 2; i++) {
		bases[i] = shmat(shmids[i], NULL, 0);

		/* SHMAT should fail since no refs were left in last detach */
		if ((int)bases[i] != -1) {
			test_printf("SHM base address returned: %p, "
				    "but it should have failed\n", bases[i]);
			goto out_err;
		}
	}

	if (getpid() == parent_of_all)
		printf("SHM TEST            -- PASSED --\n");

	return 0;

out_err:
	printf("SHM TEST            -- FAILED --\n");
	return 0;

}
