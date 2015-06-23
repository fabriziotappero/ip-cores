/*
 * Functions for userspace irq handling.
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include L4LIB_INC_ARCH(irq.h)
#include L4LIB_INC_ARCH(syscalls.h)
#include <l4/api/irq.h>

/*
 * Reads the irq notification slot. Destructive atomic read ensures that
 * an irq may write to the slot in sync.
 */
int l4_irq_wait(int slot, int irqnum)
{
	int irqval = l4_atomic_dest_readb(&(l4_get_utcb()->notify[slot]));

	if (!irqval)
		return l4_irq_control(IRQ_CONTROL_WAIT, 0, irqnum);
	else
		return irqval;
}

