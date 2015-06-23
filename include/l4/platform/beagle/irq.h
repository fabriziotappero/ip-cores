
#ifndef __PLATFORM_IRQ_H__
#define __PLATFORM_IRQ_H__

/*
 * Support for generic irq handling using platform irq controller (GIC)
 *
 * Copyright (C) 2007 Bahadir Balban
 */

/* TODO: Not sure about this, need to check */
#define IRQ_CHIPS_MAX		1
#define IRQS_MAX		96

/* IRQ indices. */
#define IRQ_UART0	72
#define IRQ_UART1	73
#define IRQ_UART2	74

/* General Purpose Timers */
#define IRQ_TIMER0	37
#define IRQ_TIMER1	38
#define IRQ_TIMER2	39
#define IRQ_TIMER3	40
#define IRQ_TIMER4	41
#define IRQ_TIMER5	42
#define IRQ_TIMER6	43
#define IRQ_TIMER7	44
#define IRQ_TIMER8	45
#define IRQ_TIMER9	46
#define IRQ_TIMER10	47
#define IRQ_TIMER11	95

#endif /* __PLATFORM_IRQ_H__ */

