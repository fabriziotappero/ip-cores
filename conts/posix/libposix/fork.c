/*
 * l4/posix glue for fork()
 *
 * Copyright (C) 2008 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <sys/types.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/utcb.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include <shpage.h>
#include <libposix.h>

static inline int l4_fork(void)
{
	int err;

	/* Call pager with open() request. Check ipc error. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_FORK)) < 0) {
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

int fork(void)
{
	int ret = l4_fork();

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}

	return ret;
}

extern int arch_clone(l4id_t to, l4id_t from, unsigned int flags);

int clone(int (*fn)(void *), void *child_stack, int flags, void *arg, ...)
{
	/* Set up the child stack */
	unsigned int *stack = child_stack;
	int ret;

	/* First word of new stack is arg */
	stack[-1] = (unsigned long)arg;

	/* Second word of new stack is function address */
	stack[-2] = (unsigned long)fn;

	/* Write the tag */
	l4_set_tag(L4_IPC_TAG_CLONE);

	/* Write the args as in usual ipc */
	write_mr(L4SYS_ARG0, (unsigned long)child_stack);
	write_mr(L4SYS_ARG1, flags);

	/* Perform an ipc but with different return logic. See implementation. */
	if ((ret = arch_clone(pagerid, pagerid, 0)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, ret);
		return ret;
	}

	if ((ret = l4_get_retval()) < 0) {
		print_err("%s: CLONE Error: %d.\n", __FUNCTION__, ret);
		return ret;
	}
	return ret;
}



