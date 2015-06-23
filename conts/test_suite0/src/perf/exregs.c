/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * l4_exchange_registers performance tests
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syslib.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4lib/lib/thread.h>
#include <l4lib/perfmon.h>
#include <l4lib/exregs.h>
#include <string.h>
#include <stdio.h>
#include <tests.h>
#include <perf.h>

struct perfmon_cycles l4_exregs_cycles;

#define PERFTEST_EXREGS_COUNT		100

int perf_measure_exregs(void)
{
	struct task_ids ids;
	struct exregs_data exregs[2];
	int err;

	/* Get own space id */
	l4_getid(&ids);

	/*
	 * Initialize cycle structures
	 */
	memset(&l4_exregs_cycles, 0, sizeof (struct perfmon_cycles));
	l4_exregs_cycles.min = ~0; /* Init as maximum possible */

	/*
	 * Create a thread in the same space.
	 * Thread is not runnable.
	 */
	if ((err = l4_thread_control(THREAD_CREATE | TC_SHARE_SPACE,
				     &ids)) < 0) {
		dbg_printf("Thread create failed. "
			   "err=%d\n", err);
		return err;
	}

	dbg_printf("Thread created successfully. "
		   "tid=%d\n", ids.tid);

	/*
	 * Prepare a context part full of 0xFF
	 */
	memset(&exregs[0].context, 0xFF, sizeof(exregs[1].context));
	exregs[0].valid_vect = 0xFFFFFFFF;

	dbg_printf("Starting l4_exregs write measurement\n");
	for (int i = 0; i < PERFTEST_EXREGS_COUNT; i++) {
		perfmon_reset_start_cyccnt();
		/* Write to context */
		if ((err = l4_exchange_registers(&exregs[0], ids.tid)) < 0)
			goto out;
		perfmon_record_cycles(&l4_exregs_cycles,
				      "l4_exchange_registers");
	}

	/* Calculate average */
	l4_exregs_cycles.avg = l4_exregs_cycles.total / l4_exregs_cycles.ops;

	/*
	 * Print results
	 */
	printf("PERFMON: %s took %llu min, %llu max, %llu avg, "
	       "%llu total microseconds in %llu ops.\n",
	       "l4_exchange_registers()/WRITE",
	       l4_exregs_cycles.min * USEC_MULTIPLIER,
	       l4_exregs_cycles.max * USEC_MULTIPLIER,
	       l4_exregs_cycles.avg * USEC_MULTIPLIER,
	       l4_exregs_cycles.total * USEC_MULTIPLIER,
	       l4_exregs_cycles.ops);

	/*
	 * Prepare a context part full of 0xFF
	 */
	memset(&exregs[0].context, 0xFF, sizeof(exregs[1].context));
	exregs[0].valid_vect = 0xFFFFFFFF;

	dbg_printf("Starting l4_exregs read measurement\n");
	for (int i = 0; i < PERFTEST_EXREGS_COUNT; i++) {
		/* Set the other as read-all */
		exregs_set_read(&exregs[1]);
		exregs[1].valid_vect = 0xFFFFFFFF;

		if ((err = l4_exchange_registers(&exregs[1],
						 ids.tid)) < 0)
		goto out;
	}

	/*
	 * Read back all context and compare results
	 */
	if (memcmp(&exregs[0].context, &exregs[1].context,
		   sizeof(exregs[0].context))) {
		err = -1;
		goto out;
	}

	/* Calculate average */
	l4_exregs_cycles.avg = l4_exregs_cycles.total / l4_exregs_cycles.ops;

	/*
	 * Print results
	 */
	printf("PERFMON: %s took %llu min, %llu max, %llu avg, "
	       "%llu total microseconds in %llu ops.\n",
	       "l4_exchange_registers()/READ",
	       l4_exregs_cycles.min * USEC_MULTIPLIER,
	       l4_exregs_cycles.max * USEC_MULTIPLIER,
	       l4_exregs_cycles.avg * USEC_MULTIPLIER,
	       l4_exregs_cycles.total * USEC_MULTIPLIER,
	       l4_exregs_cycles.ops);

out:
	/*
	 * Destroy the thread
	 */
	if ((err = l4_thread_control(THREAD_DESTROY, &ids)) < 0) {
		dbg_printf("Thread destroy failed. err=%d\n",
			   err);
	}
	return 0;

}
