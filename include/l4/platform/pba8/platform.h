/*
 * Platform specific ties between drivers and generic APIs used by the kernel.
 * E.g. system timer and console.
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#ifndef __PBA8_PLATFORM_H__
#define __PBA8_PLATFORM_H__

#include <l4/drivers/irq/gic/gic.h>
#include <l4/platform/realview/platform.h>

void init_platform_irq_controller();
void init_platform_devices();

#endif /* __PBA8_PLATFORM_H__ */
