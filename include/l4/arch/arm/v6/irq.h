#ifndef __ARM_V5_IRQ_H__
#define __ARM_V5_IRQ_H__

static inline void enable_irqs()
{
	__asm__ __volatile__(
		"mrs	r0, cpsr_fc\n"
		"bic	r0, r0, #0x80\n" /* ARM_IRQ_BIT */
		"msr	cpsr_fc, r0\n"
	);
}

static inline void disable_irqs()
{
	__asm__ __volatile__(
		"mrs	r0, cpsr_fc\n"
		"orr	r0, r0, #0x80\n" /* ARM_IRQ_BIT */
		"msr	cpsr_fc, r0\n"
	);
}

/* Disable the irqs unconditionally, but also keep the previous state such that
 * if it was already disabled before the call, the restore call would retain
 * this state. */
void irq_local_disable_save(unsigned long *state);
#endif
