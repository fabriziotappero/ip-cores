/*
 * Some tests for posix syscalls.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <pthread.h>
#include <stdio.h>
#include <string.h>
#include <l4lib/kip.h>
#include <l4lib/utcb.h>
#include <l4lib/ipcdefs.h>
#include <tests.h>
#include <unistd.h>
#include <sys/types.h>
#include <atoi.h>
#include <stdlib.h>
#include L4LIB_INC_ARCH(syslib.h)

void wait_pager(l4id_t partner)
{
	// printf("%s: Syncing with pager.\n", __TASKNAME__);
	for (int i = 0; i < 6; i++)
		write_mr(i, i);
	l4_send(partner, L4_IPC_TAG_SYNC);
	// printf("Pager synced with us.\n");
}

pid_t parent_of_all;
l4id_t pagerid;

int main(int argc, char *argv[])
{

	printf("\n%s: Started with thread id %x\n", __TASKNAME__, __raw_tid(getpid()));

	parent_of_all = getpid();

	pagerid = ascii_to_int(getenv("pagerid"));

	wait_pager(pagerid);

	printf("\n%s: Running POSIX API tests.\n", __TASKNAME__);


	small_io_test();

	dirtest();

	mmaptest();

	shmtest();

	fileio();

	forktest();

	clonetest();

	undeftest();

	if (parent_of_all == getpid()) {
		ipc_full_test();
		ipc_extended_test();
	}
	if (parent_of_all == getpid()) {
		user_mutex_test();
	}

	exectest(parent_of_all);

	while (1)
		wait_pager(pagerid);

	return 0;
}

