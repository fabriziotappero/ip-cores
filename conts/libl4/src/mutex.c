/*
 * Userspace mutex implementation
 *
 * Copyright (C) 2009 Bahadir Bilgehan Balban
 */
#include <l4lib/mutex.h>
#include <l4lib/types.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)

/*
 * NOTES:
 *
 * The design is kept as simple as possible.
 *
 * l4_mutex_lock() locks an initialized, mutex.
 * If it contends, it calls the mutex syscall.
 *
 * l4_mutex_unlock() releases an acquired mutex.
 * If there was contention, mutex syscall is called
 * to resolve by the kernel.
 *
 * Internals:
 *
 * (1) The kernel creates a waitqueue for every unique
 *     mutex in the system, i.e. every unique physical
 *     address that is contended as a mutex. In that respect
 *     virtual mutex addresses are translated to physical
 *     and checked for match.
 *
 * (2) If a mutex is contended, kernel is called by both the
 *     locker and the unlocker (i.e. the lock holder). The syscall
 *     results in a rendezvous and both tasks quit the syscall
 *     synchronised. A rendezvous is necessary because it is not possible
 *     to check lock status and send a WAIT or WAKEUP request to the
 *     kernel atomically from userspace. In other words, a WAKEUP call
 *     would be lost if it arrived before the unsuccessful lock attempt
 *     resulted in a WAIT.
 *
 * (3) The unlocker releases the lock after it returns from the syscall.
 * (4) The locker continuously tries to acquire the lock
 *
 * Issues:
 * - The kernel action is to merely wake up sleepers. If
 *   a new thread acquires the lock meanwhile, all those woken
 *   up threads would have to sleep again.
 * - All sleepers are woken up (aka thundering herd). This
 *   must be done because if a single task is woken up, there
 *   is no guarantee that that would in turn wake up others.
 *   It might even quit attempting to take the lock.
 * - Whether this is the best design - time will tell.
 */

extern int __l4_mutex_lock(void *word);
extern int __l4_mutex_unlock(void *word);

void l4_mutex_init(struct l4_mutex *m)
{
	m->lock = L4_MUTEX_UNLOCKED;
}

int l4_mutex_lock(struct l4_mutex *m)
{
	int err;

	while(__l4_mutex_lock(&m->lock) != L4_MUTEX_SUCCESS) {
		if ((err = l4_mutex_control(&m->lock, L4_MUTEX_LOCK)) < 0) {
			printf("%s: Error: %d\n", __FUNCTION__, err);
			return err;
		}
	}
	return 0;
}

int l4_mutex_unlock(struct l4_mutex *m)
{
	int err, contended;

	if ((contended = __l4_mutex_unlock(m))) {
		if ((err = l4_mutex_control(&m->lock,
					    contended | L4_MUTEX_UNLOCK)) < 0) {
			printf("%s: Error: %d\n", __FUNCTION__, err);
			return err;
		}
	}
	return 0;
}
