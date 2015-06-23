/*
 * l4/posix glue for execve()
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
#include <libposix.h>


struct sys_execve_args {
	char *path;
	char **argv;
	char **envp;
};

static inline int l4_execve(const char *pathname, char *const argv[], char *const envp[])
{
	int err = 0;

	write_mr(L4SYS_ARG0, (unsigned long)pathname);
	write_mr(L4SYS_ARG1, (unsigned long)argv);
	write_mr(L4SYS_ARG2, (unsigned long)envp);


	/* Call pager with open() request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_EXECVE)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}
	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		print_err("%s: OPEN Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	return err;
}

int execve(const char *pathname, char *const argv[], char *const envp[])
{
	int ret;

	ret = l4_execve(pathname, argv, envp);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

