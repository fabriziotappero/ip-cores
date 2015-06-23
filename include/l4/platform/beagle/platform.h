#ifndef __BEAGLE_PLATFORM_H__
#define __BEAGLE_PLATFORM_H__
/*
 * Platform specific ties between drivers and generic APIs used by the kernel.
 * E.g. system timer and console.
 *
 * Copyright (C) Bahadir Balban 2007
 */

#include INC_PLAT(offsets.h)
#include INC_GLUE(memlayout.h)
#include <l4/generic/capability.h>
#include <l4/generic/cap-types.h>

void platform_timer_start(void);

void platform_test_cpucycles(void);
#endif /* __BEAGLE_PLATFORM_H__ */
