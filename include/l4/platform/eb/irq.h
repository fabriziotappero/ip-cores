/*
 * Copyright (C) 2009 B Labs Ltd.
 */

#ifndef __PLATFORM_IRQ_H__
#define __PLATFORM_IRQ_H__

/* Actually there are 4 GIC's on the EB, only 2 are used for tile site 1 */
#define IRQ_CHIPS_MAX		2

#if defined(CONFIG_CPU_ARM11MPCORE) || defined (CONFIG_CPU_CORTEXA9)
#define IRQS_MAX		64
#else
#define IRQS_MAX		96
#endif

/*
 * Interrupt Distribution:
 * 0-31: Used as SI provided by distributed interrupt controller
 * 32-63: Externel Peripheral Interrupts
 * 64-71: Interrupts from tile site 1
 * 72-79: Interrupts from tile site 2
 * 80-95: PCI and reserved Interrupts
 */
#define EB_GIC_IRQ_OFFSET          32
#define EB_IRQ_WATCHDOG		(EB_GIC_IRQ_OFFSET + 0)
#define EB_IRQ_SOFTINT		(EB_GIC_IRQ_OFFSET + 1)
#define EB_IRQ_COMRX		(EB_GIC_IRQ_OFFSET + 2)
#define EB_IRQ_COMTX		(EB_GIC_IRQ_OFFSET + 3)
#define EB_IRQ_TIMER01		(EB_GIC_IRQ_OFFSET + 4)
#define EB_IRQ_TIMER23		(EB_GIC_IRQ_OFFSET + 5)
#define EB_IRQ_GPIO0		(EB_GIC_IRQ_OFFSET + 6)
#define EB_IRQ_GPIO1		(EB_GIC_IRQ_OFFSET + 7)
#define EB_IRQ_GPIO2		(EB_GIC_IRQ_OFFSET + 8)

#define EB_IRQ_RTC		(EB_GIC_IRQ_OFFSET + 10)
#define EB_IRQ_UART0		(EB_GIC_IRQ_OFFSET + 12)
#define EB_IRQ_UART1		(EB_GIC_IRQ_OFFSET + 13)
#define EB_IRQ_UART2		(EB_GIC_IRQ_OFFSET + 14)
#define EB_IRQ_UART3		(EB_GIC_IRQ_OFFSET + 15)
#define EB_IRQ_SCI		(EB_GIC_IRQ_OFFSET + 16) /* Smart Card Interface */
#define EB_IRQ_MCI0		(EB_GIC_IRQ_OFFSET + 17)
#define EB_IRQ_MCI1		(EB_GIC_IRQ_OFFSET + 18)
#define EB_IRQ_AACI		(EB_GIC_IRQ_OFFSET + 19) /* Advanced Audio codec */
#define EB_IRQ_KMI0		(EB_GIC_IRQ_OFFSET + 20) /* Keyboard */
#define EB_IRQ_KMI1		(EB_GIC_IRQ_OFFSET + 21) /* Mouse */
#define EB_IRQ_LCD		(EB_GIC_IRQ_OFFSET + 20) /* Character LCD */
#define EB_IRQ_DMAC		(EB_GIC_IRQ_OFFSET + 20) /* DMA Controller */


/* Interrupt Sources to ARM 11 MPCore or EB+A9 MPCore GIC */
#define MPCORE_GIC_IRQ_AACI		(EB_GIC_IRQ_OFFSET + 0)
#define MPCORE_GIC_IRQ_TIMER01		(EB_GIC_IRQ_OFFSET + 1)
#define MPCORE_GIC_IRQ_TIMER23		(EB_GIC_IRQ_OFFSET + 2)
#define MPCORE_GIC_IRQ_USB		(EB_GIC_IRQ_OFFSET + 3)
#define MPCORE_GIC_IRQ_UART0		(EB_GIC_IRQ_OFFSET + 4)
#define MPCORE_GIC_IRQ_UART1		(EB_GIC_IRQ_OFFSET + 5)
#define MPCORE_GIC_IRQ_RTC		(EB_GIC_IRQ_OFFSET + 6)
#define MPCORE_GIC_IRQ_KMI0		(EB_GIC_IRQ_OFFSET + 7)
#define MPCORE_GIC_IRQ_KMI1		(EB_GIC_IRQ_OFFSET + 8)
#define MPCORE_GIC_IRQ_ETH		(EB_GIC_IRQ_OFFSET + 9)

/* Interrupt from GIC1 on Base board */
#define MPCORE_GIC_IRQ_EB_GIC1		(EB_GIC_IRQ_OFFSET + 10)
#define MPCORE_GIC_IRQ_EB_GIC2		(EB_GIC_IRQ_OFFSET + 11)
#define MPCORE_GIC_IRQ_EB_GIC3		(EB_GIC_IRQ_OFFSET + 12)
#define MPCORE_GIC_IRQ_EB_GIC4		(EB_GIC_IRQ_OFFSET + 13)

#if defined (CONFIG_CPU_ARM11MPCORE) || defined (CONFIG_CPU_CORTEXA9)
#define IRQ_TIMER0	MPCORE_GIC_IRQ_TIMER01
#define IRQ_TIMER1	MPCORE_GIC_IRQ_TIMER23
#define IRQ_KEYBOARD0   MPCORE_GIC_IRQ_TIMER01
#define IRQ_MOUSE0	MPCORE_GIC_IRQ_KMI1
#else
#define IRQ_TIMER0	EB_IRQ_TIMER01
#define IRQ_TIMER1	EB_IRQ_TIMER23
#define IRQ_KEYBOARD0	EB_IRQ_KMI0
#define IRQ_MOUSE0	EB_IRQ_KMI1
#endif

#endif /* __PLATFORM_IRQ_H__ */
