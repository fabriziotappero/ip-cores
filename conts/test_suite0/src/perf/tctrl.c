/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * l4_thread_control performance tests
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

struct perfmon_cycles tctrl_cycles;

#define PERFTEST_THREAD_CREATE 			50

void perf_measure_tctrl(void)
{
	struct task_ids ids[PERFTEST_THREAD_CREATE];
	struct task_ids selfids;
	l4_getid(&selfids);

	/*
	 * Initialize structures
	 */
	memset(&tctrl_cycles, 0, sizeof (struct perfmon_cycles));
	tctrl_cycles.min = ~0; /* Init as maximum possible */

	/*
	 * Thread create test
	 */
	for (int i = 0; i < PERFTEST_THREAD_CREATE; i++) {
		perfmon_reset_start_cyccnt();
		l4_thread_control(THREAD_CREATE | TC_SHARE_SPACE, &selfids);
		perfmon_record_cycles(&tctrl_cycles, "THREAD_CREATE");

		/* Copy ids of created task */
		memcpy(&ids[i], &selfids, sizeof(struct task_ids));
	}

	/*
	 * Calculate average
	 */
	tctrl_cycles.avg = tctrl_cycles.total / tctrl_cycles.ops;

	/*
	 * Print results
	 */
	printf("%s took %llu min, %llu max, %llu avg, in %llu ops.\n",
	       "THREAD_CREATE",
	       tctrl_cycles.min * USEC_MULTIPLIER,
	       tctrl_cycles.max * USEC_MULTIPLIER,
	       tctrl_cycles.avg * USEC_MULTIPLIER,
	       tctrl_cycles.ops);

	/*
	 * Thread destroy test
	 */
	for (int i = 0; i < PERFTEST_THREAD_CREATE; i++) {
		perfmon_reset_start_cyccnt();
		l4_thread_control(THREAD_DESTROY, &ids[i]);
		perfmon_record_cycles(&tctrl_cycles,"THREAD_DESTROY");
	}

	/*
	 * Calculate average
	 */
	tctrl_cycles.avg = tctrl_cycles.total / tctrl_cycles.ops;

	/*
	 * Print results
	 */
	printf("%s took %llu min, %llu max, %llu avg, in %llu ops.\n",
	       "THREAD_DESTROY",
	       tctrl_cycles.min * USEC_MULTIPLIER,
	       tctrl_cycles.max * USEC_MULTIPLIER,
	       tctrl_cycles.avg * USEC_MULTIPLIER,
	       tctrl_cycles.ops);
}

