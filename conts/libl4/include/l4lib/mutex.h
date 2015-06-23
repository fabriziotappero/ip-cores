
/*
 * User space locking
 *
 * Copyright (C) 2009 Bahadir Bilgehan Balban
 */

#ifndef __L4_MUTEX_H__
#define __L4_MUTEX_H__


#if !defined(__ASSEMBLY__)

#include <l4/api/mutex.h>

struct l4_mutex {
	int lock;
} __attribute__((aligned(sizeof(int))));


void l4_mutex_init(struct l4_mutex *m);
int l4_mutex_lock(struct l4_mutex *m);
int l4_mutex_unlock(struct l4_mutex *m);

#endif

/* Mutex return value - don't mix up with mutes state */
#define L4_MUTEX_CONTENDED	-1
#define L4_MUTEX_SUCCESS	0

/*
 * Mutex states:
 * Unlocked = -1, locked = 0, anything above 0 tells
 * number of contended threads
 */
#define L4_MUTEX_LOCKED			0
#define L4_MUTEX_UNLOCKED		-1
#define L4_MUTEX(m)	\
	struct l4_mutex m = { L4_MUTEX_UNLOCKED }


#endif /* __L4_MUTEX_H__ */
