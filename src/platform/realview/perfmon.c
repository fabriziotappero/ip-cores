/*
 * Platform specific perfmon initialization
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4/platform/realview/irq.h>
#include <l4/lib/printk.h>
#include INC_PLAT(offsets.h)
#include INC_SUBARCH(perfmon.h)
#include INC_SUBARCH(mmu_ops.h)

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

#if 0
void busy_loop(int times);

void platform_test_loop_cycles()
{
        const int looptotal = 1000000;
	int cyccnt, loops = looptotal;
	int inst_per_loop = 2;
	int ipc_whole, ipc_decimal, temp;

	/* Test the basic cycle counter */
	perfmon_reset_start_cyccnt();
	isb();

	busy_loop(loops);

	/* Finish all earlier instructions */
	isb();

	cyccnt = perfmon_read_cyccnt();

	/* Finish reading cyccnt */
	isb();

	/*
	 * Do some fixed point division
	 *
	 * The idea is to multiply by 10, divide by 10 and
	 * get the remainder. Remainder becomes the decimal
	 * part. The division result is the whole part.
	 */
	temp = inst_per_loop * looptotal * 10 / (cyccnt * 64);
	ipc_whole = temp / 10;
	ipc_decimal = temp - ipc_whole * 10;

	printk("Perfmon: %d cycles/%d instructions\n",
	       cyccnt * 64, inst_per_loop * looptotal);
	printk("Perfmon: %d.%d Inst/cycle\n",
	       ipc_whole, ipc_decimal);
}

void platform_test_loop_ticks()
{
	/* Initialize the timer */
	unsigned long timer_base =
		PLATFORM_TIMER0_VBASE + SP804_TIMER1_OFFSET;
	volatile u32 reg = read(timer_base + SP804_CTRL);

        const int looptotal = 500000;
	int ticks, loops = looptotal;
	int inst_per_loop = 2;
	const int timer_load = 0xFFFFFFFF;
	int timer_read;
	int ipm_whole, ipm_decimal, temp;

	/* Make sure timer is disabled */
	write(0, timer_base + SP804_CTRL);

	/* Load the timer with a full value */
	write(timer_load, timer_base + SP804_LOAD);

	/* One shot, 32 bits, no irqs */
	reg = SP804_32BIT | SP804_ONESHOT | SP804_ENABLE;

	/* Start the timer */
	write(reg, timer_base + SP804_CTRL);
	dmb(); /* Make sure write occurs before looping */

	busy_loop(loops);

	timer_read = read(timer_base + SP804_VALUE);

	ticks = timer_load - timer_read;

	temp = (inst_per_loop * looptotal) * 10 / ticks;
	ipm_whole = temp / 10;
	ipm_decimal = temp - ipm_whole * 10;

	printk("Perfmon: %d ticks/%d instructions\n",
	       ticks, inst_per_loop * looptotal);

	printk("Perfmon: %d%d instr/Mhz.\n",
	       ipm_whole, ipm_decimal);
}


void platform_test_tick_cycles()
{
	/* Initialize the timer */
	unsigned long timer_base =
		PLATFORM_TIMER0_VBASE + SP804_TIMER1_OFFSET;
	volatile u32 reg = read(timer_base + SP804_CTRL);
	const int timer_load = 1000;
	int mhz_top, mhz_bot, temp;
	int cyccnt;

	/* Make sure timer is disabled */
	write(0, timer_base + SP804_CTRL);

	/* Load the timer with ticks value */
	write(timer_load, timer_base + SP804_LOAD);

	/* One shot, 32 bits, no irqs */
	reg = SP804_32BIT | SP804_ONESHOT | SP804_ENABLE;

	/* Start the timer */
	write(reg, timer_base + SP804_CTRL);

	/* Start counter */
	perfmon_reset_start_cyccnt();

	/* Wait until 0 */
	while (read(timer_base + SP804_VALUE) != 0)
		;

	cyccnt = perfmon_read_cyccnt();

	/* Fixed-point accuracy on bottom digit */
	temp = cyccnt * 64 * 10 / timer_load;
	mhz_top = temp / 10;
	mhz_bot = temp - mhz_top * 10;

	//printk("Perfmon: %u cycles/%dMhz\n",
	//       cyccnt * 64, timer_load);
	printk("%s: %d.%d MHz CPU speed measured by timer REFCLK at 1MHz\n",
	       __KERNELNAME__, mhz_top, mhz_bot);
}

#endif

void platform_test_tick_cycles()
{
	/* Initialize the timer */
	const int load_value = 1000;
	int mhz_top, mhz_bot, temp;
	unsigned long timer_base =
		timer_secondary_base(PLATFORM_TIMER0_VBASE);
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

