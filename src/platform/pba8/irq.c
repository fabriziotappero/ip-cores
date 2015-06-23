/*
 * Support for generic irq handling using platform irq controller (PL190)
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/drivers/irq/gic/gic.h>
#include INC_PLAT(irq.h)
#include <l4/generic/irq.h>

extern struct gic_data gic_data[IRQ_CHIPS_MAX];

struct irq_chip irq_chip_array[IRQ_CHIPS_MAX];
#if 0
#ifdef CONFIG_CPU_ARM11MPCORE
struct irq_chip irq_chip_array[IRQ_CHIPS_MAX] = {
    	[0] = {
		.name = "CoreTile GIC",
		.level = 0,
		.cascade = MPCORE_GIC_IRQ_EB_GIC1,
		.start = 0,
		.end = IRQS_MAX,
		.data = &gic_data[0],
		.ops = {
			.init = gic_dummy_init,
			.read_irq = gic_read_irq,
			.ack_and_mask = gic_ack_and_mask,
			.unmask = gic_unmask_irq
		},
        },

	[1] = {
		.name = "EB GIC",
		.level = 1,
		.cascade = IRQ_NIL,
		.start = EB_GIC_IRQ_OFFSET,
		.end = EB_GIC_IRQ_OFFSET + IRQS_MAX,
		.data = &gic_data[1],
		.ops = {
			.init = gic_dummy_init,
			.read_irq = gic_read_irq,
			.ack_and_mask = gic_ack_and_mask,
			.unmask = gic_unmask_irq,
		},
	},

};
#else
struct irq_chip irq_chip_array[IRQ_CHIPS_MAX] = {
	[0] = {
		.name = "EB GIC",
		.level = 0,
		.cascade = IRQ_NIL,
		.start = 0,
		.end = EB_GIC_IRQ_OFFSET + IRQS_MAX,
		.data = &gic_data[1],
		.ops = {
			.init = gic_dummy_init,
			.read_irq = gic_read_irq,
			.ack_and_mask = gic_ack_and_mask,
			.unmask = gic_unmask_irq,
		},
	},
};
#endif
#endif
