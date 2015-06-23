/*
 * Platform specific perfmon initialization
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include INC_PLAT(timer.h)
#include <l4/lib/printk.h>
#include INC_PLAT(offsets.h)
#include INC_SUBARCH(perfmon.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memlayout.h)
/*
 * Current findings by these tests:
 *
 * Cpu cycle count and timer ticks are consistently showing 400Mhz
 * with a reference timer tick of 1Mhz. So cycle counts are fixed
 * with regard to the timer.
 *
 * Instruction execute count on the busy_loop however, is varying
 * between x1, x2 combinations when compared to timer and cycle
 * count values. This is happening by trivial changes in code such
 * as adding a function call. (Other variables are ruled out, e.g.
 * no concurrent memory accesses, caches are off)
 *
 * There may be two causes to this:
 * - Due to missing dmb/dsb/isb instructions.
 * - Due to BTC (busy_loop has one branch) which may describe
 * the doubling in IPC, since out of the 2 instructions in the
 * busy loop one is a branch.
 *
 * Disabling the BTC increased cycle counts per instruction
 * significantly, advising us not to expect any accuracy in counting
 * instructions in cycles. Hence instruction-based tests are
 * commented out. It is wise to only rely upon timer and cycle counts.
 */
void platform_test_tick_cycles()
{
	/* Initialize the timer */
	const unsigned int load_value = 0xffffffff - 100000;
	int mhz_top, mhz_bot, temp;
	unsigned long timer_base = PLATFORM_TIMER1_VBASE;
	int cyccnt;

	/* Make sure timer is disabled */
	timer_stop(timer_base);

	/* One shot, 32 bits, no irqs */
	timer_init_oneshot(timer_base);

	/* Load the timer with ticks value */
        timer_load(timer_base, load_value);

	/* Start the timer */
	timer_start(timer_base);

	/* Start counter */
	perfmon_reset_start_cyccnt();

	/* Wait until 0 */
	while (timer_read(timer_base) != 0)
		;

	cyccnt = perfmon_read_cyccnt();

	/* Fixed-point accuracy on bottom digit */
	temp = cyccnt * 64 * 10 * 13 / 100000;
	mhz_top = temp / 10;
	mhz_bot = temp - mhz_top * 10;

	printk("Perfmon: 0x%x cycle count \n", cyccnt);
	printk("%s: %d.%d MHz CPU speed measured by timer REFCLK at 13MHz\n",
	       __KERNELNAME__, mhz_top, mhz_bot);
}

void platform_test_cpucycles(void)
{
	/*
	 * Variable results:
	 *
	 * platform_test_loop_cycles();
	 * platform_test_loop_ticks();
	 */

	/* Fixed result */
	platform_test_tick_cycles();
}

