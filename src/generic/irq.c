/*
 * Generic kernel irq handling.
 *
 * Copyright (C) 2007 - 2010 Bahadir Balban
 */
#include <l4/config.h>
#include <l4/macros.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/debug.h>
#include <l4/generic/platform.h>
#include <l4/generic/tcb.h>
#include <l4/generic/irq.h>
#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/api/errno.h>
#include INC_PLAT(irq.h)
#include INC_ARCH(exception.h)

/*
 * Registers a userspace thread as an irq handler.
 *
 * A userspace irq thread should have a low-level, device-specific
 * irq handler as an in-kernel counterpart. This and its irq chip
 * must have been set up at compile-time. These handlers should
 * also know how to notify their userspace threads.
 *
 * If the irq does not have these set up, we cannot allow
 * the irq registry.
 */
int irq_register(struct ktcb *task, int notify_slot, l4id_t irq_index)
{
	struct irq_desc *this_desc = irq_desc_array + irq_index;

	/* Kernel counterpart not set up, don't allow */
	if (!this_desc->handler || !this_desc->chip)
		return -ENOIRQ;

	/* Index must be valid */
	if (irq_index > IRQS_MAX || irq_index < 0)
		return -ENOIRQ;

	/* Setup the task and notify slot */
	this_desc->task = task;
	this_desc->task_notify_slot = notify_slot;

	/* Setup irq desc waitqueue */
	waitqueue_head_init(&this_desc->wqh_irq);

	/* Enable the irq */
	irq_enable(irq_index);

	return 0;
}


/* If there is cascading, enable it. */
static inline void cascade_irq_chip(struct irq_chip *this_chip)
{
	if (this_chip->cascade >= 0) {
		BUG_ON(IRQ_CHIPS_MAX == 1);
		if(this_chip->ops.unmask)
			this_chip->ops.unmask(this_chip->cascade);
	}
}

void irq_controllers_init(void)
{
	struct irq_chip *this_chip;

	for (int i = 0; i < IRQ_CHIPS_MAX; i++) {
		this_chip = irq_chip_array + i;

		/* Initialise the irq chip (e.g. reset all registers) */
		if (this_chip->ops.init)
			this_chip->ops.init();

		/* Enable cascaded irq on this chip if it exists */
		cascade_irq_chip(this_chip);
	}
}


/*
 * Finds the global irq number by looping over irq chips.
 *
 * Global irq number =
 * 	Unique irq chip_offset defined by us + irq number local to chip
 */
l4id_t global_irq_index(void)
{
	struct irq_chip *this_chip;
	l4id_t irq_index = 0;

	/*
	 * Loop over all chips, starting from the top
	 * (i.e. nearest to the cpu)
	 */
	for (int i = 0; i < IRQ_CHIPS_MAX; i++) {

		/* Get the chip */
		this_chip = irq_chip_array + i;

		/* Find local irq that is triggered on this chip */
		if (this_chip->ops.read_irq) {
			irq_index = this_chip->ops.read_irq(this_chip->data);
			BUG_ON(irq_index == IRQ_NIL);
		}

		/* See if this irq is a cascaded irq */
		if (irq_index == this_chip->cascade)
			continue; /* Yes, continue to next chip */

		/*
		 * Irq was initiated from this chip. Add this chip's
		 * global irq offset and return it
		 */
		irq_index += this_chip->start;
		return irq_index;
	}

	/*
	 * Cascaded irq detected, but no lower chips
	 * left to process. This should not happen
	 */
	BUG();

	return IRQ_NIL;
}

#include <l4/drivers/irq/gic/gic.h>

void do_irq(void)
{
	l4id_t irq_index = global_irq_index();
	struct irq_desc *this_irq;

	if (irq_index == IRQ_SPURIOUS) {
		printk("CPU%d: FATAL: Spurious irq\n", smp_get_cpuid());
		BUG();
	}

	// printk("CPU%d: Received irq %d\n", smp_get_cpuid(), irq_index);

	this_irq = irq_desc_array + irq_index;

	system_account_irq();

	/*
	 * Note, this can be easily done a few instructions
	 * quicker by some immediate read/disable/enable_all().
	 *
	 * We currently stick with it as it is clearer.
	 */
	irq_disable(irq_index);

	/* Re-enable all irqs */
	enable_irqs();

	/* Handle the irq */
	BUG_ON(!this_irq->handler);
	if (this_irq->handler(this_irq) != IRQ_HANDLED) {
		printk("CPU%d: FATAL: Spurious or broken irq\n",
		       smp_get_cpuid());
		BUG();
	}

	irq_enable(irq_index);
}
