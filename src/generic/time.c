/*
 * Time.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */
#include <l4/types.h>
#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/generic/irq.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/time.h>
#include <l4/generic/preempt.h>
#include <l4/generic/space.h>
#include INC_ARCH(exception.h)
#include <l4/api/syscall.h>
#include <l4/api/errno.h>
#include INC_GLUE(ipi.h)	/*FIXME: Remove this */

/* TODO:
 * 1) Add RTC support.
 * 2) Need to calculate time since EPOCH,
 * 3) Jiffies must be initialised to a reasonable value.
 */

volatile u32 jiffies = 0;

static inline void increase_jiffies(void)
{
	jiffies++;
}


/* Internal representation of time since epoch */
struct time_info {
	int reader;
	u32 thz;	/* Ticks in this hertz so far */
	u64 sec;	/* Seconds so far */
};

static struct time_info systime = { 0 };

/*
 * A very basic (probably erroneous)
 * rule-of-thumb time calculation.
 */
void update_system_time(void)
{
	/* Did we interrupt a reader? Tell it to retry */
	if (systime.reader)
		systime.reader = 0;

	/* Increase just like jiffies, but reset every second */
	systime.thz++;

	/*
	 * On every 1 second of timer ticks, increase seconds
	 *
	 * TODO: Investigate: how do we make sure timer_irq is
	 * called SCHED_TICKS times per second?
	 */
	if (systime.thz == CONFIG_SCHED_TICKS) {
		systime.thz = 0;
		systime.sec++;
	}
}

/* Read system time */
int sys_time(struct timeval *tv, int set)
{
	int retries = 20;
	int err;

	if ((err = check_access((unsigned long)tv, sizeof(*tv),
				MAP_USR_RW, 1)) < 0)
		return err;

	/* Get time */
	if (!set) {
		while(retries > 0) {
			systime.reader = 1;
			tv->tv_sec = systime.sec;
			tv->tv_usec = 1000000 * systime.thz / CONFIG_SCHED_TICKS;

			retries--;
			if (systime.reader)
				break;
		}

		/*
		 * No need to reset reader since it will be reset
		 * on next timer. If no retries return busy.
		 */
		if (!retries)
			return -EBUSY;
		else
			return 0;

	/* Set */
	} else {
		/*
		 * Setting the time not supported yet.
		 */
		return -ENOSYS;
	}
}

void update_process_times(void)
{
	struct ktcb *cur = current;

	if (cur->ticks_left == 0) {
		/*
		 * Nested irqs and irqs during non-preemptive
		 * times could try to deduct ticks below zero.
		 * We ignore such states and return.
		 */
		if (in_nested_irq_context() || !preemptive())
			return;
		else /* Otherwise its a bug. */
			BUG();
	}

	/*
	 * These are TASK_RUNNABLE times, i.e. exludes sleeps
	 * In the future we may use timestamps for accuracy
	 */
	if (in_kernel())
		cur->kernel_time++;
	else
		cur->user_time++;

	cur->ticks_left--;
	cur->sched_granule--;

	/* Task has expired its timeslice */
	if (!cur->ticks_left)
		need_resched = 1;

	/* Task has expired its schedule granularity */
	if (!cur->sched_granule)
		need_resched = 1;
}

int do_timer_irq(void)
{
	increase_jiffies();
	update_process_times();
	update_system_time();

#if defined (CONFIG_SMP)
	smp_send_ipi(cpu_mask_others(), IPI_TIMER_EVENT);
#endif

	return IRQ_HANDLED;
}

/* Secondary cpus call this */
int secondary_timer_irq(void)
{
	update_process_times();
	return IRQ_HANDLED;
}

