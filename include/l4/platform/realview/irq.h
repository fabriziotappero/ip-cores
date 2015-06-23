/*
 * Platform encapsulation over timer driver.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_REALVIEW_IRQ_H__
#define __PLATFORM_REALVIEW_IRQ_H__

#include <l4/drivers/timer/sp804/timer.h>
#include <l4/generic/irq.h>

int platform_timer_user_handler(struct irq_desc *desc);
int platform_keyboard_user_handler(struct irq_desc *desc);
int platform_mouse_user_handler(struct irq_desc *desc);
int platform_timer_handler(struct irq_desc *desc);

#endif /* __PLATFORM_REALVIEW_IRQ_H__ */
