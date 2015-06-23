/*
 * SP804 primecell driver honoring generic
 * timer library API
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/types.h>
#include "timer.h"

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

void timer_init_periodic(unsigned long timer_base, u32 load_value)
{
	volatile u32 reg = read(timer_base + SP804_CTRL);

	reg |= SP804_PERIODIC | SP804_32BIT | SP804_IRQEN;

	write(reg, timer_base + SP804_CTRL);

	if (load_value)
		timer_load(load_value, timer_base);
	else
		/* 1 tick per usec, 1 irq per msec */
		timer_load(1000, timer_base);
}

void timer_init_oneshot(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + SP804_CTRL);

	/* One shot, 32 bits, no irqs */
	reg |= SP804_32BIT | SP804_ONESHOT;

	write(reg, timer_base + SP804_CTRL);
}

void timer_init(unsigned long timer_base, u32 load_value)
{
	timer_stop(timer_base);
	timer_init_periodic(timer_base, load_value);
}
