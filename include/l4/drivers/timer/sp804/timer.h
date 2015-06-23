/*
 * SP804 Primecell Timer offsets
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */
#ifndef __SP804_TIMER_H__
#define __SP804_TIMER_H__

#include INC_ARCH(io.h)

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

#define SP804_SECONDARY_OFFSET		0x20

/* Timer prescaling */
#define SP804_SCALE_SHIFT		2
#define SP804_SCALE_DIV16		1
#define SP804_SCALE_DIV256		2

/* Wrapping = 0, Oneshot = 1 */
#define SP804_ONESHOT			(1 << 0)

unsigned long timer_secondary_base(unsigned long timer_base);
void timer_irq_clear(unsigned long timer_base);
void timer_start(unsigned long timer_base);
void timer_load(u32 loadval, unsigned long timer_base);
u32 timer_read(unsigned long timer_base);
void timer_stop(unsigned long timer_base);
void timer_init_periodic(unsigned long timer_base, unsigned int load_value);
void timer_init_oneshot(unsigned long timer_base);
void timer_init(unsigned long timer_base, unsigned int load_value);
#endif /* __SP804_TIMER_H__ */
