/*
 * Platform specific ties between drivers and
 * generic APIs used by the kernel.
 * E.g. system timer and console.
 *
 * Copyright (C) Bahadir Balban 2007
 */

#ifndef __REALVIEW_PLATFORM_H__
#define __REALVIEW_PLATFORM_H__

void init_platform_irq_controller();
void init_platform_devices();

void platform_timer_start(void);
void platform_test_cpucycles();

void platform_timer_start(void);

void scu_init(void);

void scu_print_state(void);

#endif /* __REALVIEW_PLATFORM_H__ */
