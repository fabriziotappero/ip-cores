/*
 * l4/posix glue for mkdir()
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <shpage.h>
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
#include <libposix.h>

static inline int l4_mkdir(const char *pathname, mode_t mode)
{
	int fd;

	// write_mr(L4SYS_ARG0, (unsigned long)pathname);
	utcb_full_strcpy_from(pathname);
	write_mr(L4SYS_ARG0, (u32)mode);

	/* Call pager with shmget() request. Check ipc error. */
	if ((fd = l4_sendrecv_full(pagerid, pagerid, L4_IPC_TAG_MKDIR)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	/* Check if syscall itself was successful */
	if ((fd = l4_get_retval()) < 0) {
		print_err("%s: MKDIR Error: %d.\n", __FUNCTION__, fd);
		return fd;
	}
	return fd;
}

int mkdir(const char *pathname, mode_t mode)
{
	int ret;

	/* If error, return positive error code */
	if ((ret = l4_mkdir(pathname, mode)) < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;
}

