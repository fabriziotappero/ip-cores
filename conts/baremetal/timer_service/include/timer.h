/*
 * Timer details.
 */
#ifndef __TIMER_H__
#define	__TIMER_H__

#include <l4lib/mutex.h>
#include <l4/lib/list.h>
#include <l4lib/types.h>

/* Structure representing the sleeping tasks */
struct sleeper_task {
	struct link list;
	l4id_t tid;	/* tid of sleeping task */
	int retval;	/* return value on wakeup */
};

/* list of tasks to be woken up */
struct wake_task_list {
	struct link head;
	struct link *end; /* optimization */
	struct l4_mutex wake_list_lock; /* lock for sanity of head */
};

#define BUCKET_BASE_LEVEL_BITS		8
#define BUCKET_HIGHER_LEVEL_BITS	6

#define BUCKET_BASE_LEVEL_SIZE		(1 << BUCKET_BASE_LEVEL_BITS)
#define BUCKET_HIGHER_LEVEL_SIZE	(1 << BUCKET_HIGHER_LEVEL_BITS)

#define BUCKET_BASE_LEVEL_MASK		0xFF
#define BUCKET_HIGHER_LEVEL_MASK	0x3F

/*
 * Web of sleeping tasks
 * based on timer wheel base algorithm
 */
struct sleeper_task_bucket {
	struct link bucket_level0[BUCKET_BASE_LEVEL_SIZE];
	struct link bucket_level1[BUCKET_HIGHER_LEVEL_SIZE];
	struct link bucket_level2[BUCKET_HIGHER_LEVEL_SIZE];
	struct link bucket_level3[BUCKET_HIGHER_LEVEL_SIZE];
	struct link bucket_level4[BUCKET_HIGHER_LEVEL_SIZE];
};

/* Macros to extract bucket levels */
#define GET_BUCKET_LEVEL4(x)	\
	((x >> (BUCKET_BASE_LEVEL_BITS + (3 * BUCKET_HIGHER_LEVEL_BITS))) & \
	  BUCKET_HIGHER_LEVEL_MASK)
#define GET_BUCKET_LEVEL3(x)	\
	((x >> (BUCKET_BASE_LEVEL_BITS + (2 * BUCKET_HIGHER_LEVEL_BITS))) & \
	  BUCKET_HIGHER_LEVEL_MASK)
#define GET_BUCKET_LEVEL2(x)	\
	((x >> (BUCKET_BASE_LEVEL_BITS + (1 * BUCKET_HIGHER_LEVEL_BITS))) & \
	 BUCKET_HIGHER_LEVEL_MASK)
#define GET_BUCKET_LEVEL1(x)	\
	((x >> BUCKET_BASE_LEVEL_BITS) &  BUCKET_HIGHER_LEVEL_MASK)
#define GET_BUCKET_LEVEL0(x)	(x & BUCKET_BASE_LEVEL_MASK)

/* Macros to find bucket level */
#define IS_IN_LEVEL0_BUCKET(x)		\
	(x < (1 << BUCKET_BASE_LEVEL_BITS))
#define IS_IN_LEVEL1_BUCKET(x)		\
	(x < (1 << (BUCKET_BASE_LEVEL_BITS + BUCKET_HIGHER_LEVEL_BITS)))
#define IS_IN_LEVEL2_BUCKET(x)		\
	(x < (1 << (BUCKET_BASE_LEVEL_BITS + (2 * BUCKET_HIGHER_LEVEL_BITS))))
#define IS_IN_LEVEL3_BUCKET(x)		\
	(x < (1 << (BUCKET_BASE_LEVEL_BITS + (3 * BUCKET_HIGHER_LEVEL_BITS))))

/*
 * Timer structure
 * TODO: Keep timer 32 bit for time being,
 * we will make it 64 in future
 */
struct timer {
	int slot;		/* Notify slot on utcb */
	unsigned long base;	/* Virtual base address */
	unsigned int count;		/* Counter/jiffies */
	struct sleeper_task_bucket task_list;	/* List of sleeping tasks */
	struct l4_mutex task_list_lock;	/* Lock for sleeper_task_bucket */
	struct capability cap;  /* Capability describing timer */
};

#endif /* __TIMER_H__ */
