/*
 * Thread creation userspace helpers
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <thread.h>
#include <l4/api/errno.h>

char stack[THREADS_TOTAL][STACK_SIZE] ALIGN(8);
char *__stack_ptr = &stack[1][0];

char utcb[THREADS_TOTAL][UTCB_SIZE] ALIGN(8);
char *__utcb_ptr = &utcb[1][0];

extern void local_setup_new_thread(void);

int thread_create(int (*func)(void *), void *args, unsigned int flags,
		  struct task_ids *new_ids)
{
	struct task_ids ids;
	struct exregs_data exregs;
	int err;

	l4_getid(&ids);

	/* Shared space only */
	if (!(TC_SHARE_SPACE & flags)) {
		printf("%s: This function allows only "
		       "shared space thread creation.\n",
		       __FUNCTION__);
		return -EINVAL;
	}

	/* Create thread */
	if ((err = l4_thread_control(THREAD_CREATE | flags, &ids)) < 0)
		return err;

	/* Check if more stack/utcb available */
	if ((unsigned long)__utcb_ptr ==
	    (unsigned long)&utcb[THREADS_TOTAL][0])
		return -ENOMEM;
	if ((unsigned long)__stack_ptr ==
	    (unsigned long)&stack[THREADS_TOTAL][0])
		return -ENOMEM;

	/* First word of new stack is arg */
	*(((unsigned int *)__stack_ptr) -1) = (unsigned int)args;

	/* Second word of new stack is function address */
	*(((unsigned int *)__stack_ptr) -2) = (unsigned int)func;

	/* Setup new thread pc, sp, utcb */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_stack(&exregs, (unsigned long)__stack_ptr);
	exregs_set_utcb(&exregs, (unsigned long)__utcb_ptr);
	exregs_set_pc(&exregs, (unsigned long)local_setup_new_thread);

	if ((err = l4_exchange_registers(&exregs, ids.tid)) < 0)
		return err;

	/* Update utcb, stack pointers */
	__stack_ptr += STACK_SIZE;
	__utcb_ptr += UTCB_SIZE;

	/* Start the new thread */
	if ((err = l4_thread_control(THREAD_RUN, &ids)) < 0)
		return err;

	memcpy(new_ids, &ids, sizeof(ids));

	return 0;
}

