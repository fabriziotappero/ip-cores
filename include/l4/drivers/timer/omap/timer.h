/*
 * OMAP GP Timer offsets
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */
#ifndef __OMAP_GPTIMER_H__
#define __OMAP_GPTIMER_H__

/* Register offsets */
#define OMAP_TIMER_TIOCP		0x10
#define OMAP_TIMER_TSTAT		0x14
#define OMAP_TIMER_TISR                 0x18
#define OMAP_TIMER_TIER			0x1C
#define OMAP_TIMER_TCLR			0x24
#define OMAP_TIMER_TCRR			0x28
#define OMAP_TIMER_TLDR                 0x2C
#define OMAP_TIMER_TMAR				0x38
#define OMAP_TIMER_TPIR			0x48
#define OMAP_TIMER_TNIR			0x4C
#define OMAP_TIMER_TCVR			0x50

/* Enable/Disable IRQ */
#define OMAP_TIMER_IRQENABLE		1
#define OMAP_TIMER_IRQDISABLE		0

/* Timer modes supported */
#define OMAP_TIMER_MODE_AUTORELAOD	1
#define OMAP_TIMER_MODE_COMPARE		6
#define OMAP_TIMER_MODE_CAPTURE		13

/* Interrupt types */
#define OMAP_TIMER_INTR_MATCH           0x0
#define OMAP_TIMER_INTR_OVERFLOW        0x1
#define OMAP_TIMER_INTR_CAPTURE         0x2

/* Clock source for timer */
#define OMAP_TIMER_CLKSRC_SYS_CLK	0x1
#define OMAP_TIMER_CLKSRC_32KHZ_CLK	0x0

void timer_init_oneshot(unsigned long timer_base);
u32 timer_periodic_intr_status(unsigned long timer_base);
void timer_reset(unsigned long timer_base);
void timer_load(unsigned long timer_base, u32 value);
u32 timer_read(unsigned long timer_base);
void timer_start(unsigned long timer_base);
void timer_stop(unsigned long timer_base);
void timer_init_periodic(unsigned long timer_base);
void timer_irq_clear(unsigned long timer_base);
void timer_init(unsigned long timer_base);

#endif /* __OMAP_GPTIMER_H__*/
