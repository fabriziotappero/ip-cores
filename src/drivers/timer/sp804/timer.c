/*
 * SP804 primecell driver honoring generic
 * timer library API
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include INC_ARCH(io.h)
#include <l4/drivers/timer/sp804/timer.h>

unsigned long timer_secondary_base(unsigned long timer_base)
{
	return timer_base + SP804_SECONDARY_OFFSET;
}

void timer_irq_clear(unsigned long timer_base)
{
	write(1, timer_base + SP804_INTCLR);
}

/* Enable timer with its current configuration */
void timer_start(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + SP804_CTRL);

	reg |= SP804_ENABLE;

	write(reg, timer_base + SP804_CTRL);

}

/* Load the timer with ticks value */
void timer_load(u32 loadval, unsigned long timer_base)
{
	write(loadval, timer_base + SP804_LOAD);
}

u32 timer_read(unsigned long timer_base)
{
	return read(timer_base + SP804_VALUE);
}

void timer_stop(unsigned long timer_base)
{
	write(0, timer_base + SP804_CTRL);
}

void timer_init_periodic(unsigned long timer_base, unsigned int load_value)
{
	volatile u32 reg;

	/* Periodic, wraparound, 32 bit, irq on wraparound */
	reg = SP804_PERIODIC | SP804_32BIT | SP804_IRQEN;

	write(reg, timer_base + SP804_CTRL);

	/* 1 tick per usec, 1 irq per msec */
	if (load_value)
		timer_load(load_value, timer_base);
	else
		timer_load(1000, timer_base);
}

void timer_init_oneshot(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + SP804_CTRL);

	/* One shot, 32 bits, no irqs */
	reg |= SP804_32BIT | SP804_ONESHOT;

	write(reg, timer_base + SP804_CTRL);
}

void timer_init(unsigned long timer_base, unsigned int load_value)
{
	timer_init_periodic(timer_base, load_value);
}
