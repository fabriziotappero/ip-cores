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
#include <l4/lib/bit.h>
#include <l4/drivers/irq/pl190/pl190_vic.h>

struct irq_chip irq_chip_array[IRQ_CHIPS_MAX] = {
	[0] = {
		.name = "Vectored irq controller",
		.level = 0,
		.cascade = IRQ_SIC,
		.start = VIC_CHIP_OFFSET,
		.end = VIC_CHIP_OFFSET + VIC_IRQS_MAX,
		.ops = {
			.init = pl190_vic_init,
			.read_irq = pl190_read_irq,
			.ack_and_mask = pl190_mask_irq,
			.unmask = pl190_unmask_irq,
		},
	},
	[1] = {
		.name = "Secondary irq controller",
		.level = 1,
		.cascade = IRQ_NIL,
		.start = SIC_CHIP_OFFSET,
		.end = SIC_CHIP_OFFSET + SIC_IRQS_MAX,
		.ops = {
			.init = pl190_sic_init,
			.read_irq = pl190_sic_read_irq,
			.ack_and_mask = pl190_sic_mask_irq,
			.unmask = pl190_sic_unmask_irq,
		},
	},
};

static int platform_timer_handler(struct irq_desc *desc)
{
	/*
	 * Microkernel is using just TIMER0,
	 * so we call handler with TIMER01 index
	 */
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

/*
 * Keyboard handler for userspace
 */
#define PL050_KMICR		0x00
#define PL050_KMI_RXINTR	(1 << 0x4)

static int platform_keyboard_user_handler(struct irq_desc *desc)
{
	/*
         * Disable rx keyboard interrupt.
         * User will enable this
         */
	clrbit((unsigned int *)PLATFORM_KEYBOARD0_VBASE + PL050_KMICR,
	       PL050_KMI_RXINTR);

	irq_thread_notify(desc);
	return 0;
}

/*
 * Mouse handler for userspace
 */
static int platform_mouse_user_handler(struct irq_desc *desc)
{
	/*
	 * Disable rx mouse interrupt.
	 * User will enable this
	 */
	clrbit((unsigned int *)PLATFORM_MOUSE0_VBASE + PL050_KMICR,
	       PL050_KMI_RXINTR);

	irq_thread_notify(desc);
	return 0;
}

/*
 * Built-in irq handlers initialised at compile time.
 * Else register with register_irq()
 */
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
	[IRQ_KEYBOARD0] = {
		.name = "Keyboard",
		.chip = &irq_chip_array[1],
		.handler = platform_keyboard_user_handler,
	},
	[IRQ_MOUSE0] = {
		.name = "Mouse",
		.chip = &irq_chip_array[1],
		.handler = platform_mouse_user_handler,
	},
};




