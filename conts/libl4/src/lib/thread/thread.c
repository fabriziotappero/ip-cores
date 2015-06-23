/*
 * Thread creation userspace helpers
 *
 * Copyright (C) 2009 - 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/lib/thread.h>
#include <l4lib/exregs.h>
#include <l4lib/mutex.h>
#include <l4/api/errno.h>
#include <l4/api/thread.h>
#include <memcache/memcache.h>

void *l4_utcb_alloc(void)
{
	return mem_cache_alloc(utcb_cache);
}

void l4_utcb_free(void *utcb)
{
	BUG_ON(mem_cache_free(utcb_cache, utcb) < 0);
}

void *l4_stack_alloc(void)
{
	void *stack = mem_cache_alloc(stack_cache);

	/* Since it will grow downwards */
	stack += (unsigned long)STACK_SIZE;

	return stack;
}

/*
 * NOTE: may be unaligned
 */
void l4_stack_free(void *stack)
{
	/* Allocation pointer was from beginning of stack */
	stack -= (unsigned long)STACK_SIZE;
	BUG_ON(mem_cache_free(stack_cache, stack) < 0);
}

/*
 * Allocate and init a thread struct for same space
 */
struct l4_thread *l4_thread_init(struct l4_thread *thread)
{
	/*
	 * Allocate stack and utcb
	 */
	if (!(thread->utcb = l4_utcb_alloc()))
		return PTR_ERR(-ENOMEM);
	if (!(thread->stack = l4_stack_alloc())) {
		l4_utcb_free(thread->utcb);
		return PTR_ERR(-ENOMEM);
	}
	return thread;
}

void l4_thread_free(struct l4_thread *thread)
{
	struct l4_thread_list *tlist = &l4_thread_list;

	/* Lock the list */
	l4_mutex_lock(&tlist->lock);

	/* Lock the thread */
	l4_mutex_lock(&thread->lock);

	/* Remove the thread from its list */
	list_remove(&thread->list);
	tlist->total--;

	/* Unlock list */
	l4_mutex_unlock(&tlist->lock);

	/* Free thread's stack and utcb if they exist */
	if (thread->stack)
		l4_stack_free(thread->stack);
	if (thread->utcb)
		l4_utcb_free(thread->utcb);

	/* Free the thread itself */
	BUG_ON(mem_cache_free(tlist->thread_cache, thread) < 0);
}

/*
 * No locking version
 */
void l4_thread_free_nolock(struct l4_thread *thread)
{
	struct l4_thread_list *tlist = &l4_thread_list;

	/* Free thread's stack and utcb if they exist */
	if (thread->stack)
		l4_stack_free(thread->stack);
	if (thread->utcb)
		l4_utcb_free(thread->utcb);

	/* Free the thread itself */
	BUG_ON(mem_cache_free(tlist->thread_cache, thread) < 0);
}

/*
 * Destroys a child thread and reclaims its
 * stack and utcb.
 *
 * NOTE: This function is to be called with caution:
 * The destroyed child must be in a state that will
 * not compromise the system integrity, i.e. not holding
 * any locks, not in the middle of an operation.
 *
 * We usually don't know whether a synchronous destruction
 * would cause the thread to leave structures prematurely
 * (e.g. need to figure out a way of knowing if the thread
 * is holding any locks, busy, has children ...)
 */
int thread_destroy(struct l4_thread *thread)
{
	struct l4_thread_list *tlist = &l4_thread_list;
	int err;

	/* Lock the list */
	l4_mutex_lock(&tlist->lock);

	/* Lock the thread */
	l4_mutex_lock(&thread->lock);

	/* Remove the thread from its list */
	list_remove(&thread->list);
	tlist->total--;

	/* Unlock list */
	l4_mutex_unlock(&tlist->lock);

	/* Destroy the thread */
	if ((err = l4_thread_control(THREAD_DESTROY, &thread->ids)) < 0)
		return err;

	/* Reclaim l4_thread structure */
	l4_thread_free_nolock(thread);

	return 0;
}

struct l4_thread *l4_thread_alloc_init(void)
{
	struct l4_thread_list *tlist = &l4_thread_list;
	struct l4_thread *thread;

	if (!(thread = mem_cache_zalloc(tlist->thread_cache)))
		return PTR_ERR(-ENOMEM);

	link_init(&thread->list);
	l4_mutex_init(&thread->lock);

	if (IS_ERR(thread = l4_thread_init(thread))) {
		mem_cache_free(tlist->thread_cache, thread);
		return PTR_ERR(thread);
	}

	list_insert(&tlist->thread_list, &thread->list);
	tlist->total++;

	return thread;
}

/*
 * Called during initialization for setting up the
 * existing runnable thread
 */
void l4_parent_thread_init(void)
{
	struct l4_thread *thread;
	struct exregs_data exregs;
	int err;

	/* Allocate structures for the first thread */
	thread = l4_thread_alloc_init();

	/* Free the allocated stack since its unnecessary */
	l4_stack_free(thread->stack);

	/* Read thread ids */
	l4_getid(&thread->ids);

	/* Set up utcb via exregs */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_utcb(&exregs, (unsigned long)thread->utcb);
	if ((err = l4_exchange_registers(&exregs,
					 thread->ids.tid)) < 0) {
		printf("FATAL: Initialization of structures for "
		       "currently runnable thread has failed.\n"
		       "exregs err=%d\n", err);
		l4_thread_free(thread);
	}
}

/* For threads to exit on their own without any library maintenance */
void thread_exit(int exit_code)
{
	struct task_ids ids;

	/* FIXME: Find this from utcb */
	l4_getid(&ids);
	l4_thread_control(THREAD_DESTROY | exit_code, &ids);
}

int thread_wait(struct l4_thread *thread)
{
	int ret;

	/* Wait for the thread to exit */
	if ((ret = l4_thread_control(THREAD_WAIT, &thread->ids)) < 0)
		return ret;

	/* Claim its library structures */
	l4_thread_free(thread);

	/* Return zero or positive thread exit code */
	return ret;
}

/*
 * Create a new thread in the same address space as caller
 */
int thread_create(int (*func)(void *), void *args, unsigned int flags,
		  struct l4_thread **tptr)
{
	struct exregs_data exregs;
	struct l4_thread *thread;
	int err;

	/* Shared space only */
	if (!(TC_SHARE_SPACE & flags)) {
		printf("%s: Warning - This function allows only "
		       "shared space thread creation.\n",
		       __FUNCTION__);
		return -EINVAL;
	}

	/* Allocate a thread struct */
	if (IS_ERR(thread = l4_thread_alloc_init()))
		return (int)thread;

	/* Assign own space id since TC_SHARE_SPACE requires it */
	l4_getid(&thread->ids);

	/* Create thread in kernel */
	if ((err = l4_thread_control(THREAD_CREATE |
				     flags, &thread->ids)) < 0)
		goto out_err;

	/* First word of new stack is arg */
	thread->stack[-1] = (unsigned long)args;

	/* Second word of new stack is function address */
	thread->stack[-2] = (unsigned long)func;

	/* Setup new thread pc, sp, utcb */
	memset(&exregs, 0, sizeof(exregs));
	exregs_set_stack(&exregs, (unsigned long)thread->stack);
	exregs_set_utcb(&exregs, (unsigned long)thread->utcb);
	exregs_set_pc(&exregs, (unsigned long)setup_new_thread);

	if ((err = l4_exchange_registers(&exregs, thread->ids.tid)) < 0)
		goto out_err;

	/* Start the new thread, unless specified otherwise */
	if (!(flags & TC_NOSTART))
		if ((err = l4_thread_control(THREAD_RUN,
					     &thread->ids)) < 0)
			goto out_err;

	/* Set pointer to thread structure */
	*tptr = thread;

	return 0;

out_err:
	l4_thread_free(thread);
	return err;
}

