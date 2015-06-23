/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * API performance tests
 *
 * Author: Bahadir Balban
 */
#include <tests.h>
#include <perf.h>
#include <timer.h>

/*
 * Tests all api functions by performance
 */
int test_performance(void)
{
	perf_timer_init();

	platform_measure_cpu_cycles();

	perf_measure_getid_ticks();
	perf_measure_getid();
	perf_measure_tctrl();
	perf_measure_exregs();
	perf_measure_ipc();
	perf_measure_map();
	perf_measure_unmap();
	perf_measure_mutex();

	return 0;
}

