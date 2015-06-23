#ifndef __THREAD_H__
#define __THREAD_H__

#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/exregs.h>
#include <l4/api/thread.h>


int thread_create(int (*func)(void *), void *args, unsigned int flags,
		  struct task_ids *new_ids);

/* For same space */
#define STACK_SIZE	0x1000

#define THREADS_TOTAL	10

#endif /* __THREAD_H__ */
