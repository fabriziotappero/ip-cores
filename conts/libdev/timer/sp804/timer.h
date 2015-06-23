/*
 * SP804 Primecell Timer offsets
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */
#ifndef __SP804_TIMER_H__
#define __SP804_TIMER_H__

#include <libdev/io.h>

/* Register offsets */
#define SP804_LOAD			0x0
#define SP804_VALUE			0x4
#define SP804_CTRL			0x8
#define SP804_INTCLR			0xC
#define SP804_RIS			0x10
#define SP804_MIS			0x14
#define SP804_BGLOAD			0x18

#define SP804_ENABLE			(1 << 7)
#define SP804_PERIODIC			(1 << 6)
#define SP804_IRQEN			(1 << 5)
#define SP804_32BIT			(1 << 1)
#define SP804_ONESHOT			(1 << 0)

/* Timer prescaling */
#define SP804_SCALE_SHIFT		2
#define SP804_SCALE_DIV16		1
#define SP804_SCALE_DIV256		2

/* Wrapping = 0, Oneshot = 1 */
#define SP804_ONESHOT			(1 << 0)

static inline __attribute__ ((always_inline))
void sp804_load(unsigned long timer_base, u32 val)
{
	write(val, timer_base + SP804_LOAD);
}

static inline __attribute__ ((always_inline))
void sp804_irq_clear(unsigned long timer_base)
{
	write(1, timer_base + SP804_INTCLR);
}

static inline __attribute__ ((always_inline))
void sp804_enable(unsigned long timer_base)
{
	volatile u32 reg = read(timer_base + SP804_CTRL);

	write(reg | SP804_ENABLE, timer_base + SP804_CTRL);
}

void timer_start(unsigned long timer_base);
void timer_load(u32 loadval, unsigned long timer_base);
u32 timer_read(unsigned long timer_base);
void timer_stop(unsigned long timer_base);
void timer_init_periodic(unsigned long timer_base, u32 load_value);
void timer_init_oneshot(unsigned long timer_base);
void timer_init(unsigned long timer_base, u32 load_value);

#endif /* __SP804_TIMER_H__ */
