/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * l4_getid performance tests
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/thread.h>
#include <l4lib/perfmon.h>
#include <perf.h>
#include <tests.h>
#include <string.h>
#include <timer.h>

struct perfmon_cycles l4_getid_cycles;

#define PERFTEST_GETID_COUNT		100

/*
 * Measure l4_getid by timer ticks
 */
void perf_measure_getid_ticks(void)
{
	const int timer_ldval = 0xFFFFFFFF;
	unsigned int timer_val, timer_stamp = 0xFFFFFFFF;
	unsigned int min = ~0, max = 0, last = 0, total = 0, ops = 0;
	struct task_ids ids;

	/* Make sure timer is disabled */
	timer_stop(timer_base);

	/* Configure timer as one shot */
	timer_init_oneshot(timer_base);

	/* Load the timer with ticks value */
	timer_load(timer_ldval, timer_base);

	/* Start the timer */
	printf("Starting the l4_getid timer tick test.\n");
	timer_start(timer_base);

	/* Do the operation */
	for (int i = 0; i < PERFTEST_GETID_COUNT; i++) {
		l4_getid(&ids);
		timer_val = timer_read(timer_base);
		last = timer_stamp - timer_val;
		timer_stamp = timer_val;
		if (min > last)
			min = last;
		if (max < last)
			max = last;
		ops++;
		total += last;
	}

	printf("TIMER: l4_getid took each %u min, %u max, %u avg,\n"
	       "%u total microseconds, and %u total ops\n", min,
	       max, total/ops, total, ops);
}

/*
 * Measure l4_getid by cpu cycles
 */
void perf_measure_getid(void)
{
	struct task_ids ids;

	/*
	 * Initialize structures
	 */
	memset(&l4_getid_cycles, 0, sizeof (l4_getid_cycles));
	l4_getid_cycles.min = ~0; /* Init as maximum possible */

	/*
	 * Do the test
	 */
	printf("Starting the l4_getid cycle counter test.\n");
	for (int i = 0; i < PERFTEST_GETID_COUNT; i++) {
		perfmon_reset_start_cyccnt();
		l4_getid(&ids);
		perfmon_record_cycles(&l4_getid_cycles,
				      "l4_getid");
	}

	/*
	 * Calculate average
	 */
	l4_getid_cycles.avg = l4_getid_cycles.total / l4_getid_cycles.ops;

	/*
	 * Print results
	 */
	printf("PERFMON: %s took %llu min, %llu max, %llu avg, "
	       "%llu total microseconds in %llu ops.\n",
	       "l4_getid()",
	       l4_getid_cycles.min * USEC_MULTIPLIER,
	       l4_getid_cycles.max * USEC_MULTIPLIER,
	       l4_getid_cycles.avg * USEC_MULTIPLIER,
	       l4_getid_cycles.total * USEC_MULTIPLIER,
	       l4_getid_cycles.ops);
}
