/*
 * Test cpu cycles using platform timer
 * ticks.
 *
 * Copyright (C) 2010 B Labs Ltd.
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


void platform_measure_cpu_cycles()
{
	/* Initialize the timer */
	const int load_value = 1000;
	int mhz_top, mhz_bot, temp;
	int cyccnt;

	/* Make sure timer is disabled */
	timer_stop(timer_base);

	/* Load the timer with ticks value */
	timer_load(load_value, timer_base);

	/* One shot, 32 bits, no irqs */
	timer_init_oneshot(timer_base);

	/* Start the timer */
	timer_start(timer_base);

	/* Start counter */
	perfmon_reset_start_cyccnt();

	/* Wait until 0 */
	while (timer_read(timer_base) != 0)
		;

	cyccnt = perfmon_read_cyccnt();

	/* Fixed-point accuracy on bottom digit */
	temp = cyccnt * 64 * 10 / load_value;
	mhz_top = temp / 10;
	mhz_bot = temp - mhz_top * 10;

	//printk("Perfmon: %u cycles/%dMhz\n",
	//       cyccnt * 64, timer_load);
	printk("%s: %d.%d MHz CPU speed measured by timer REFCLK at 1MHz\n",
	       __KERNELNAME__, mhz_top, mhz_bot);
}

