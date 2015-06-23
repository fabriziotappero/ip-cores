/*
 * l4/posix glue for close() and fsync()
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/utcb.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include <libposix.h>

static inline int l4_close(int fd)
{
	write_mr(L4SYS_ARG0, fd);

	/* Call pager with close() request. Check ipc error. */
	if ((fd = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_CLOSE)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	/* Check if syscall itself was successful */
	if ((fd = l4_get_retval()) < 0) {
		print_err("%s: CLOSE Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	return fd;
}

int close(int fd)
{
	int ret = l4_close(fd);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}

	/* else return value */
	return ret;
}

static inline int l4_fsync(int fd)
{
	write_mr(L4SYS_ARG0, fd);

	/* Call pager with close() request. Check ipc error. */
	if ((fd = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_FSYNC)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	/* Check if syscall itself was successful */
	if ((fd = l4_get_retval()) < 0) {
		print_err("%s: CLOSE Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	return fd;
}

int fsync(int fd)
{
	int ret = l4_fsync(fd);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}

	/* else return value */
	return ret;
}

