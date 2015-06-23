/*
 * l4/posix glue for read() / sys_readdir()
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <unistd.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/os/posix/readdir.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include INC_GLUE(message.h)
#include <libposix.h>

/*
 * TODO:
 *
 * Do this as follows:
 *
 * A short ipc l4_send() to indicate request
 * An extended l4_receive_extended() to get back extended buffer.
 *
 * Or do it just like read()
 */
static inline int l4_readdir(int fd, void *buf, size_t count)
{
	int cnt, err;

	write_mr(L4SYS_ARG0, fd);
	write_mr(L4SYS_ARG1, count);

	/* Call pager with readdir() request. Check ipc error. */
	if ((err = l4_send(pagerid, L4_IPC_TAG_READDIR)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Call pager with readdir() request. Check ipc error. */
	if ((err = l4_receive_extended(pagerid,
				       L4_IPC_EXTENDED_MAX_SIZE,
				       buf)) < 0) {
		print_err("%s: L4 Extended IPC error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Check if syscall itself was successful */
	if ((cnt = l4_get_retval()) < 0) {
		print_err("%s: READDIR Error: %d.\n", __FUNCTION__, (int)cnt);
		return cnt;
	}

	return cnt;
}

#if 0
static inline int l4_readdir(int fd, void *buf, size_t count)
{
	int cnt;

	write_mr(L4SYS_ARG0, fd);
	write_mr(L4SYS_ARG1, (unsigned long)buf);
	write_mr(L4SYS_ARG2, count);

	/* Call pager with readdir() request. Check ipc error. */
	if ((cnt = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_READDIR)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, cnt);
		return cnt;
	}
	/* Check if syscall itself was successful */
	if ((cnt = l4_get_retval()) < 0) {
		print_err("%s: READDIR Error: %d.\n", __FUNCTION__, (int)cnt);
		return cnt;

	}

	return cnt;
}
#endif
static inline int l4_read(int fd, void *buf, size_t count)
{
	int cnt;

	write_mr(L4SYS_ARG0, fd);
	write_mr(L4SYS_ARG1, (unsigned long)buf);
	write_mr(L4SYS_ARG2, count);

	/* Call pager with read() request. Check ipc error. */
	if ((cnt = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_READ)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, cnt);
		return cnt;
	}
	/* Check if syscall itself was successful */
	if ((cnt = l4_get_retval()) < 0) {
		print_err("%s: READ Error: %d.\n", __FUNCTION__, (int)cnt);
		return cnt;

	}
	return cnt;
}

ssize_t read(int fd, void *buf, size_t count)
{
	int ret;

	if (!count)
		return 0;

	ret = l4_read(fd, buf, count);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

ssize_t os_readdir(int fd, void *buf, size_t count)
{
	int ret;

	if (!count)
		return 0;

	ret = l4_readdir(fd, buf, count);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;
}

