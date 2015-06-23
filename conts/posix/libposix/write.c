/*
 * l4/posix glue for write()
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <unistd.h>
#include <l4lib/ipcdefs.h>
#include <libposix.h>

static inline int l4_write(int fd, const void *buf, size_t count)
{
	int wrcnt;

	write_mr(L4SYS_ARG0, fd);
	write_mr(L4SYS_ARG1, (const unsigned long)buf);
	write_mr(L4SYS_ARG2, count);

	/* Call pager with write() request. Check ipc error. */
	if ((wrcnt = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_WRITE)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, wrcnt);
		return wrcnt;
	}
	/* Check if syscall itself was successful */
	if ((wrcnt = l4_get_retval()) < 0) {
		print_err("%s: WRITE Error: %d.\n", __FUNCTION__, (int)wrcnt);
		return wrcnt;

	}
	return wrcnt;
}

ssize_t write(int fd, const void *buf, size_t count)
{
	int ret;

	if (!count)
		return 0;

	ret = l4_write(fd, buf, count);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;
}

