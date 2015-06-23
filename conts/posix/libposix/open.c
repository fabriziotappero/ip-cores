/*
 * l4/posix glue for open()
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include <errno.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/utcb.h>
#include <fcntl.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include <shpage.h>
#include <libposix.h>

static inline int l4_open(const char *pathname, int flags, mode_t mode)
{
	int fd;

	utcb_full_strcpy_from(pathname);
	write_mr(L4SYS_ARG0, flags);
	write_mr(L4SYS_ARG1, (u32)mode);

	/* Call pager with open() request. Check ipc error. */
	if ((fd = l4_sendrecv_full(pagerid, pagerid, L4_IPC_TAG_OPEN)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	/* Check if syscall itself was successful */
	if ((fd = l4_get_retval()) < 0) {
		print_err("%s: OPEN Error: %d, for path %s\n",
		       __FUNCTION__, fd, pathname);
		return fd;
	}
	return fd;
}

int open(const char *pathname, int oflag, ...)
{
	int ret;
	mode_t mode = 0;

	if (oflag & O_CREAT) {
		va_list arg;
		va_start(arg, oflag);
		mode = va_arg(arg, mode_t);
		va_end(arg);
	}
	ret = l4_open(pathname, oflag, mode);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

