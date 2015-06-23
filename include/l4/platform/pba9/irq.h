/*
 * Support for generic irq handling using platform irq controller (GIC)
 *
 * Copyright (C) 2007 B Labs Ltd.
 */
#ifndef __PLATFORM_IRQ_H__
#define __PLATFORM_IRQ_H__


/* TODO: Not sure about this, need to check */
#define IRQ_CHIPS_MAX		1
#define IRQS_MAX		96
#define IRQ_OFFSET		0

/* IRQ indices. */
#define IRQ_TIMER0		34
#define IRQ_TIMER1		35
#define IRQ_RTC			36
#define IRQ_UART0		37
#define IRQ_UART1		38
#define IRQ_UART2		39
#define IRQ_UART3		40

#define IRQ_KEYBOARD0		44
#define IRQ_MOUSE0		45
#define IRQ_CLCD0		46

/*
 * Versatile Express A9 Interrupt Distribution:
 * 0 - 31: SI, provided by distributed interrupt controller
 * 32 - 74: Irqs from Motherboard (0 - 42)
 * 75- 81: Test chip interrupts
 */

#endif /* __PLATFORM_IRQ_H__ */

