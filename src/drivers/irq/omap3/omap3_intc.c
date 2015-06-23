/*
 * Interrupt Controller - Beagleboard
 *
 * Copyright 2010 B Labs Ltd.
 */

#include <l4/drivers/irq/omap3/omap3_intc.h>
#include INC_PLAT(offsets.h)
#include INC_PLAT(irq.h)

void omap3_intc_ack_irq(l4id_t irq)
{
	write(0x1, PLATFORM_INTC_VBASE + OMAP3_INTC_CONTROL);
}

void omap3_intc_mask_irq(l4id_t irq)
{
	omap3_intc_set_irq_status(PLATFORM_INTC_VBASE, OMAP3_INTC_MIR_SET, irq);
}

void omap3_intc_unmask_irq(l4id_t irq)
{
	omap3_intc_set_irq_status(PLATFORM_INTC_VBASE, OMAP3_INTC_MIR_CLR, irq);
}

/* End of Interrupt */
void omap3_intc_ack_and_mask(l4id_t irq)
{
	omap3_intc_mask_irq(irq);
	omap3_intc_ack_irq(irq);
}

l4id_t omap3_intc_read_irq(void *data)
{
	unsigned int irq = 0;

	if ((irq = (read(PLATFORM_INTC_VBASE + OMAP3_INTC_SIR_IRQ) & 0x7F)))
		return irq;

	return -1;
}

void omap3_intc_reset(unsigned long base)
{
	/* Assert Reset */
	write(OMAP_INTC_SOFTRESET, (base + OMAP3_INTC_SYSCONFIG));

	/* wait for completion */
	 while (!(read((base + OMAP3_INTC_SYSSTATUS)) & 0x1));
}

void omap3_intc_init(void)
{
	int i;

	/* Do Soft-Reset */
	omap3_intc_reset(PLATFORM_INTC_VBASE);

	/*
	 * Set All IRQ to IRQ type and
	 * Priority as 0x0A- some random value
	 */
	for (i = 0; i < IRQS_MAX; i++)
		omap3_intc_set_ilr(PLATFORM_INTC_VBASE, i, (0x0A << 2));

	/* Mask(set mask) all interrupts */
	for (i = 0; i < IRQS_MAX; i++)
		omap3_intc_set_irq_status(PLATFORM_INTC_VBASE,
					  OMAP3_INTC_MIR_SET, i);
}
