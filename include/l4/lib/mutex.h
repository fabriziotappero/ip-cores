/*
 * The elementary concurrency constructs.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __LIB_MUTEX_H__
#define __LIB_MUTEX_H__

#include <l4/lib/string.h>
#include <l4/lib/spinlock.h>
#include <l4/lib/list.h>
#include <l4/lib/printk.h>
#include <l4/lib/wait.h>
#include INC_ARCH(mutex.h)

/* A mutex is a binary semaphore that can sleep. */
struct mutex {
	struct waitqueue_head wqh;
	unsigned int lock;
};

static inline void mutex_init(struct mutex *mutex)
{
	memset(mutex, 0, sizeof(struct mutex));
	waitqueue_head_init(&mutex->wqh);
}

int mutex_trylock(struct mutex *mutex);
int mutex_lock(struct mutex *mutex);
void mutex_unlock(struct mutex *mutex);
void mutex_unlock_async(struct mutex *mutex);

/* NOTE: Since spinlocks guard mutex acquiring & sleeping, no locks needed */
static inline int mutex_inc(unsigned int *cnt)
{
	return ++*cnt;
}

static inline int mutex_dec(unsigned int *cnt)
{
	return --*cnt;
}

#endif /* __LIB_MUTEX_H__ */
