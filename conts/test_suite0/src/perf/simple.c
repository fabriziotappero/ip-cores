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

struct perfmon_cycles simple_cycles;

#define PERFTEST_SIMPLE_LOOP	2000

void perf_test_simple(void)
{
	dbg_printf("%s: This will test the cycle count of basic loops.\n",
		   __FUNCTION__);

	/*
	 * Initialize structures
	 */
	memset(&simple_cycles, 0, sizeof(struct perfmon_cycles));
	simple_cycles.min = ~0; /* Init as maximum possible */

	/*
	 * Do the test
	 */
	perfmon_reset_start_cyccnt();
	for (int i = 0; i < PERFTEST_SIMPLE_LOOP; i++)
		;

	perfmon_record_cycles(&simple_cycles,"empty_loop");

	/*
	 * Calculate average
	 */
	simple_cycles.avg = simple_cycles.total / simple_cycles.ops;

	/*
	 * Print results
	 */
	printf("%s took %llu min, %llu max, %llu avg, in %llu ops.\n",
	       "simple loop",
	       simple_cycles.min * USEC_MULTIPLIER,
	       simple_cycles.max * USEC_MULTIPLIER,
	       simple_cycles.avg * USEC_MULTIPLIER,
	       simple_cycles.ops);
}

