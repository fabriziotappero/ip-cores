/*
 * Platform specific ties between drivers and generic APIs used by the kernel.
 * E.g. system timer and console.
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#ifndef __EB_PLATFORM_H__
#define __EB_PLATFORM_H__

#include INC_PLAT(sysctrl.h)
#include <l4/drivers/irq/gic/gic.h>
#include <l4/platform/realview/platform.h>

void cpu_extra_init(void);
void init_platform_irq_controller();
void init_platform_devices();

#endif /* __EB_PLATFORM_H__ */
