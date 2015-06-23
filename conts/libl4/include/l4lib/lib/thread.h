#ifndef __THREAD_H__
#define __THREAD_H__

#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/exregs.h>
#include <l4lib/mutex.h>
#include <l4/api/thread.h>
#include <l4/lib/list.h>

/*
 * Library specific-flags for thread creation
 */
#define TC_USER_FLAGS_MASK	0x000F0000
#define TC_NOSTART		0x00010000

/* For same space */
#define STACK_SIZE			PAGE_SIZE

/* Total threads the library supports */
#define THREADS_TOTAL			10

/*
 * Keeps track of threads in the system
 * created by the pager
 */
struct l4_thread_list {
	int total;		 /* Total number of threads */
	struct l4_mutex lock;	 /* Threads list lock */
	struct link thread_list; /* Threads list */
	struct mem_cache *thread_cache; /* Cache for thread structures */
};

struct l4_thread {
	struct task_ids ids;		/* Thread ids */
	struct l4_mutex lock;		/* Lock for thread struct */
	struct link list;		/* Link to list of threads */
	unsigned long *stack;		/* Stack (grows downwards) */
	struct utcb *utcb;		/* UTCB address */
};

/*
 * These are thread calls that are meant to be
 * called by library users
 */
int thread_create(int (*func)(void *), void *args, unsigned int flags,
		  struct l4_thread **tptr);
int thread_wait(struct l4_thread *t);
void thread_exit(int exitcode);

/*
 * This is to be called only if to-be-destroyed thread is in
 * sane condition for destruction
 */
int thread_destroy(struct l4_thread *thread);

/* Library init function called by __container_init */
void __l4_threadlib_init(void);
void l4_parent_thread_init(void);
extern struct mem_cache *utcb_cache, *stack_cache;
extern struct l4_thread_list l4_thread_list;
extern void setup_new_thread(void);

#endif /* __THREAD_H__ */
