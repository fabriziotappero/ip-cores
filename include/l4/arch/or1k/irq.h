#ifndef __ARM_IRQ_H__
#define __ARM_IRQ_H__

#include INC_SUBARCH(irq.h)

void irq_local_restore(unsigned long state);
void irq_local_disable_save(unsigned long *state);
int irqs_enabled();

static inline void irq_local_enable()
{
	enable_irqs();
}

static inline void irq_local_disable()
{
	disable_irqs();
}


/*
 * Destructive atomic-read.
 *
 * Write 0 to byte at @location as its contents are read back.
 */
char l4_atomic_dest_readb(void *location);


#endif /* __ARM_IRQ_H__ */
