/*
 * omap GP timer driver honoring generic
 * timer library API
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4/drivers/timer/omap/timer.h>
#include INC_ARCH(io.h)

#define OMAP_TIMER_MAT_IT_FLAG  (1 << 0)
#define OMAP_TIMER_OVR_IT_FLAG  (1 << 1)
#define OMAP_TIMER_TCAR_IT_FLAG (1 << 2)
void timer_irq_clear(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + OMAP_TIMER_TISR);
	reg |= OMAP_TIMER_OVR_IT_FLAG;
	write(reg, timer_base + OMAP_TIMER_TISR);
}

u32 timer_periodic_intr_status(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + OMAP_TIMER_TISR);
	return (reg & OMAP_TIMER_OVR_IT_FLAG);
}

#define OMAP_TIMER_SOFT_RESET	(1 << 1)
void timer_reset(unsigned long timer_base)
{
	/* Reset Timer */
	write(OMAP_TIMER_SOFT_RESET, timer_base + OMAP_TIMER_TIOCP);

	/* Wait for reset completion */
	while (!read(timer_base + OMAP_TIMER_TSTAT));
}

void timer_load(unsigned long timer_base, u32 value)
{
	write(value, timer_base + OMAP_TIMER_TLDR);
	write(value, timer_base + OMAP_TIMER_TCRR);
}

u32 timer_read(unsigned long timer_base)
{
	return read(timer_base + OMAP_TIMER_TCRR);
}

#define OMAP_TIMER_START	(1 << 0)
void timer_start(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + OMAP_TIMER_TCLR);
	reg |= OMAP_TIMER_START;
	write(reg, timer_base + OMAP_TIMER_TCLR);
}

void timer_stop(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + OMAP_TIMER_TCLR);
	reg &= (~OMAP_TIMER_START);
	write(reg, timer_base + OMAP_TIMER_TCLR);
}

/*
* Beagle Board RevC manual:
* overflow period = (0xffffffff - TLDR + 1)*PS*(1/TIMER_FCLK)
* where,
* PS: Prescaler divisor (we are not using this)
*
* Beagle board manual says, 26MHz oscillator present on board.
* U-Boot divides the sys_clock by 2 if sys_clk is >19MHz,
* so,we have sys_clk frequency = 13MHz
*
* TIMER_FCLK = 13MHz
*
*/
void timer_init_oneshot(unsigned long timer_base)
{
	volatile u32 reg;

	/* Reset the timer */
	timer_reset(timer_base);

	/* Set timer to compare mode */
	reg = read(timer_base + OMAP_TIMER_TCLR);
	reg |= (1 << OMAP_TIMER_MODE_COMPARE);
	write(reg, timer_base + OMAP_TIMER_TCLR);

	write(0xffffffff, timer_base + OMAP_TIMER_TMAR);

	/* Clear pending Interrupts, if any */
	write(7, timer_base + OMAP_TIMER_TISR);
}

void timer_init_periodic(unsigned long timer_base)
{
	volatile u32 reg;

	/* Reset the timer */
	timer_reset(timer_base);

	/* Set timer to autoreload mode */
	reg = read(timer_base + OMAP_TIMER_TCLR);
	reg |= (1 << OMAP_TIMER_MODE_AUTORELAOD);
	write(reg, timer_base + OMAP_TIMER_TCLR);

	/*
	* Beagle Board RevC manual:
	* overflow period = (0xffffffff - TLDR + 1)*PS*(1/TIMER_FCLK)
	* where,
	* PS: Prescaler divisor (we are not using this)
	*
	* Beagle board manual says, 26MHz oscillator present on board.
	* U-Boot divides the sys_clock by 2 if sys_clk is >19MHz,
	* so,we have sys_clk frequency = 13MHz
	*
	* TIMER_FCLK = 13MHz
	* So, for 1ms period, TLDR = 0xffffcd38
	*
	*/
	timer_load(timer_base, 0xffffcd38);

	/* Clear pending Interrupts, if any */
	write(7, timer_base + OMAP_TIMER_TISR);

	/* Enable inteerupts */
	write((1 << OMAP_TIMER_INTR_OVERFLOW), timer_base + OMAP_TIMER_TIER);
}

void timer_init(unsigned long timer_base)
{
	timer_init_periodic(timer_base);
}
