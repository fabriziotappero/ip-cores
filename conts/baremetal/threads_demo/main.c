/*
 * Main function for this container
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4/api/space.h>
#include <l4lib/thread/thread.h>

/* Symbolic constants */
#define STACK_SIZE	0x1000
#define NTHREADS	10

/* Stack and utcb region */
static char stack[NTHREADS * STACK_SIZE];
DECLARE_UTCB_SPACE(utcb, NTHREADS)

/* Function definitions */
static void init_thread_lib(void)
{
	/* Thread lib is informed about the stack region. */
	l4_set_stack_params((unsigned long)stack,
				(unsigned long)(stack + sizeof(stack)),
				STACK_SIZE);

	/* Thread lib is informed about the utcb region. */
	l4_set_utcb_params((unsigned long)utcb,
				(unsigned long)(utcb + sizeof(utcb)));

	/* Now, we are ready to make calls to the library. */
}

static int do_some_work1(void *arg)
{
	struct task_ids ids;
	int value = *(int *)arg;
	int j;

	l4_getid(&ids);
	printf("tid = %d is called with the value of (%d).\n",
		__raw_tid(ids.tid), value);

	/* Wait for a while before exiting */
	j = 0x400000;
	while (--j)
		;

	return ids.tid;
}

static int do_some_work2(void *arg)
{
	struct task_ids ids;
	int value = *(int *)arg;
	int j;

	l4_getid(&ids);
	printf("tid = %d is called with the value of (%d).\n",
		__raw_tid(ids.tid), value);

	/* Wait for a while before exiting */
	j = 0x400000;
	while (--j)
		;

	l4_thread_exit(ids.tid);

	/* Should never reach here */
	return 0;
}

static int thread_demo(void)
{
	struct task_ids ids[NTHREADS];
	int arg[NTHREADS];
	int j;

	memset(ids, 0, sizeof(ids));

	/* Create threads. */
	for (int i = 0; i < NTHREADS; ++i) {
		/* The argument passed to the thread in question. */
		arg[i] = i;

		/* Threads are created. */
		if (i % 2)
			l4_thread_create(&ids[i], TC_SHARE_SPACE | TC_SHARE_PAGER,
					 do_some_work1, (void *)&arg[i]);
		else
			l4_thread_create(&ids[i], TC_SHARE_SPACE | TC_SHARE_PAGER,
					 do_some_work2, (void *)&arg[i]);

		/* Wait for a while before launching another thread. */
		j = 0x100000;
		while (--j)
			;
	}

	/* Wait for them to exit. */
	for (int i = 0; i < NTHREADS; ++i)
		printf("tid = %d exited with (%d).\n", __raw_tid(ids[i].tid),
		       l4_thread_control(THREAD_WAIT, &ids[i]));

	return 0;
}

int main(void)
{
	/* Before using the thread lib, we have to initialize it. */
	init_thread_lib();

	/* Demonstrates the usage of the thread lib. */
	thread_demo();

	return 0;
}

