/*
 * Support for generic irq handling.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/irq.h>
#include <l4/generic/time.h>
#include INC_PLAT(offsets.h)
#include INC_PLAT(irq.h)
#include <l4/lib/bit.h>
#include <l4/platform/realview/irq.h>

/*
 * Timer handler for userspace
 */
int platform_timer_user_handler(struct irq_desc *desc)
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
#define PL050_KMICR             0x00
#define PL050_KMI_RXINTR        (1 << 0x4)
int platform_keyboard_user_handler(struct irq_desc *desc)
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
int platform_mouse_user_handler(struct irq_desc *desc)
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

int platform_timer_handler(struct irq_desc *desc)
{
	timer_irq_clear(PLATFORM_TIMER0_VBASE);

	return do_timer_irq();
}

