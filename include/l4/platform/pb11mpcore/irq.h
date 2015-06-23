#ifndef __PLATFORM_IRQ_H__
#define __PLATFORM_IRQ_H__

/* TODO: Not sure about this, need to check */
#define IRQ_CHIPS_MAX			4
#define IRQS_MAX			96

/* IRQ indices. */
#define IRQ_TIMER0			36
#define IRQ_TIMER1			37
#define IRQ_TIMER2                     73
#define IRQ_TIMER3                     74
#define IRQ_RTC				42
#define IRQ_UART0			44
#define IRQ_UART1			45
#define IRQ_UART2			46
#define IRQ_UART3                       47

/*
 * Interrupt Distribution:
 * 0-31: SI, provided by distributed interrupt controller
 * 32-63: Externel peripheral interrupts
 * 64-71: Tile site interrupt
 * 72-95: Externel peripheral interrupts
 */

#endif /* __PLATFORM_IRQ_H__ */
