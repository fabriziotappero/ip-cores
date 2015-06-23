/*
 * l4/posix glue for lseek()
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <l4lib/ipcdefs.h>
#include <libposix.h>

static inline off_t l4_lseek(int fildes, off_t offset, int whence)
{
	off_t offres;

	write_mr(L4SYS_ARG0, fildes);
	write_mr(L4SYS_ARG1, offset);
	write_mr(L4SYS_ARG2, whence);

	/* Call pager with shmget() request. Check ipc error. */
	if ((offres = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_LSEEK)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, offres);
		return offres;
	}
	/* Check if syscall itself was successful */
	if ((offres = l4_get_retval()) < 0) {
		print_err("%s: OPEN Error: %d.\n", __FUNCTION__, (int)offres);
		return offres;

	}
	return offres;
}

off_t lseek(int fildes, off_t offset, int whence)
{
	int ret = l4_lseek(fildes, offset, whence);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

