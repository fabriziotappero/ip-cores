
#ifndef __PLATFORM_IRQ_H__
#define __PLATFORM_IRQ_H__

/*
 * Support for generic irq handling using platform irq controller (GIC)
 *
 * Copyright (C) 2007 Bahadir Balban
 */

/* TODO: Not sure about this, need to check */
#define IRQ_CHIPS_MAX		4
#define IRQS_MAX		96

/* IRQ indices. */
#define IRQ_UART0	44
#define IRQ_UART1	45
#define IRQ_UART2	46
#define IRQ_UART3       47

/* General Purpose Timers */
#define IRQ_TIMER0	36
#define IRQ_TIMER1	37
#define IRQ_TIMER2	73
#define IRQ_TIMER3	74

#define IRQ_KEYBOARD0	52
#define IRQ_MOUSE0      53

#endif /* __PLATFORM_IRQ_H__ */

