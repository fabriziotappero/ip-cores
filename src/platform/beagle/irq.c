/*
 * Support for generic irq handling using platform irq controller (PL190)
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/platform.h>
#include <l4/generic/irq.h>
#include <l4/generic/time.h>
#include INC_PLAT(irq.h)
#include INC_PLAT(platform.h)
#include INC_PLAT(timer.h)
#include INC_ARCH(exception.h)
#include <l4/drivers/irq/omap3/omap3_intc.h>

struct irq_chip irq_chip_array[IRQ_CHIPS_MAX] = {
	[0] = {
		.name = "OMAP 3 irq controller",
		.level = 0,
		.cascade = IRQ_NIL,
		.start = 0,
		.end = IRQS_MAX,
		.ops = {
			.init = omap3_intc_init,
			.read_irq = omap3_intc_read_irq,
			.ack_and_mask = omap3_intc_ack_and_mask,
			.unmask = omap3_intc_unmask_irq,
		},
	},
};

static int platform_timer_handler(struct irq_desc *desc)
{
	timer_irq_clear(PLATFORM_TIMER0_VBASE);

	return do_timer_irq();
}

/*
 * Timer handler for userspace
 */
static int platform_timer_user_handler(struct irq_desc *desc)
{
	/* Ack the device irq */
	timer_irq_clear(PLATFORM_TIMER1_VBASE);

	/* Notify the userspace */
	irq_thread_notify(desc);

	return 0;
}

/* Built-in irq handlers initialised at compile time.
 * Else register with register_irq() */
struct irq_desc irq_desc_array[IRQS_MAX] = {
	[IRQ_TIMER0] = {
		.name = "Timer0",
		.chip = &irq_chip_array[0],
		.handler = platform_timer_handler,
	},
	[IRQ_TIMER1] = {
		.name = "Timer1",
		.chip = &irq_chip_array[0],
		.handler = platform_timer_user_handler,
	},
};

