/*
 * This is the glue logic between posix shared memory functions
 * and their L4 implementation.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <l4lib/ipcdefs.h>
#include <l4/macros.h>
#include <libposix.h>

int l4_shmget(l4id_t key, int size, int shmflg)
{
	int err;

	write_mr(L4SYS_ARG0, key);
	write_mr(L4SYS_ARG1, size);
	write_mr(L4SYS_ARG2, shmflg);

	/* Call pager with shmget() request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_SHMGET)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}
	/* Check if syscall itself was successful */
	if (IS_ERR(err = l4_get_retval())) {
		print_err("%s: SHMGET Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Otherwise err has the positive id number */
	return err;
}

void *l4_shmat(l4id_t shmid, const void *shmaddr, int shmflg)
{
	int err;

	write_mr(L4SYS_ARG0, shmid);
	write_mr(L4SYS_ARG1, (unsigned long)shmaddr);
	write_mr(L4SYS_ARG2, shmflg);

	/* Call pager with shmget() request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_SHMAT)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return PTR_ERR(err);
	}
	/* Check if syscall itself was successful */
	if (IS_ERR(err = l4_get_retval())) {
		print_err("%s: SHMAT Error: %d.\n", __FUNCTION__, err);
		return PTR_ERR(err);

	}
	/* Obtain shm base. */
	return (void *)err;
}

int l4_shmdt(const void *shmaddr)
{
	int err;

	write_mr(L4SYS_ARG0, (unsigned long)shmaddr);

	/* Call pager with shmget() request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_SHMDT)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return -1;
	}
	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		print_err("%s: SHMDT Error: %d.\n", __FUNCTION__, err);
		return -1;
	}
	return 0;
}

int shmget(key_t key, size_t size, int shmflg)
{
	int ret = l4_shmget(key, size, shmflg);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;
}

void *shmat(int shmid, const void *shmaddr, int shmflg)
{
	void *ret = l4_shmat(shmid, shmaddr, shmflg);

	/* If error, return positive error code */
	if (IS_ERR(ret)) {
		errno = -((int)ret);
		return PTR_ERR(-1);
	}
	/* else return value */
	return ret;
}

int shmdt(const void *shmaddr)
{
	int ret = l4_shmdt(shmaddr);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;
}

