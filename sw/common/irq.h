#ifndef __IRQ_H__
#define __IRQ_H__

//-----------------------------------------------------------------
// Prototypes
//-----------------------------------------------------------------
void irq_enable(int interrupt);
void irq_disable(int interrupt);
void irq_acknowledge(int interrupt);

#endif