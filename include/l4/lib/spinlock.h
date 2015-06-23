#ifndef __LIB_SPINLOCK_H__
#define __LIB_SPINLOCK_H__

#include <l4/lib/string.h>
#include <l4/generic/preempt.h>
#include INC_ARCH(irq.h)
#include INC_ARCH(mutex.h)

struct spinlock {
	unsigned int lock;
};

#define DECLARE_SPINLOCK(lockname) 	\
	struct spinlock lockname = {	\
		.lock = 0,		\
	}

void spin_lock_record_check(void *lock_addr);
void spin_unlock_delete_check(void *lock_addr);

static inline void spin_lock_init(struct spinlock *s)
{
	memset(s, 0, sizeof(struct spinlock));
}

/*
 * - Guards from deadlock against local processes, but not local irqs.
 * - To be used for synchronising against processes on *other* cpus.
 */
static inline void spin_lock(struct spinlock *s)
{
	preempt_disable();	/* This must disable local preempt */
#if defined(CONFIG_SMP)

#if defined (CONFIG_DEBUG_SPINLOCKS)
	spin_lock_record_check(s);
#endif
	__spin_lock(&s->lock);
#endif
}

static inline void spin_unlock(struct spinlock *s)
{
#if defined(CONFIG_SMP)

#if defined (CONFIG_DEBUG_SPINLOCKS)
	spin_unlock_delete_check(s);
#endif
	__spin_unlock(&s->lock);
#endif
	preempt_enable();
}

/*
 * - Guards from deadlock against local processes *and* local irqs.
 * - To be used for synchronising against processes and irqs
 *   on other cpus.
 */
static inline void spin_lock_irq(struct spinlock *s,
				 unsigned long *state)
{
	irq_local_disable_save(state);
#if defined(CONFIG_SMP)
#if defined (CONFIG_DEBUG_SPINLOCKS)
	spin_lock_record_check(s);
#endif

	__spin_lock(&s->lock);
#endif
}

static inline void spin_unlock_irq(struct spinlock *s,
				   unsigned long state)
{
#if defined(CONFIG_SMP)

#if defined (CONFIG_DEBUG_SPINLOCKS)
	spin_unlock_delete_check(s);
#endif

	__spin_unlock(&s->lock);
#endif
	irq_local_restore(state);
}
#endif /* __LIB__SPINLOCK_H__ */
