/*
 * Fake spinlock for future multi-threaded mm0
 */
#ifndef __MM0_SPINLOCK_H__
#define __MM0_SPINLOCK_H__

struct spinlock {
	int lock;
};

static inline void spin_lock_init(struct spinlock *s) { }
static inline void spin_lock(struct spinlock *s) { }
static inline void spin_unlock(struct spinlock *s) { }

#endif /* __MM0_SPINLOCK_H__ */
