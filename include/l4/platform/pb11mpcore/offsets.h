/*
 * Describes physical memory layout of PB11MPCORE platform.
 *
 * This only include physical and memory offsets that
 * are not included in realview/offsets.h
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_PB11MPCORE_OFFSETS_H__
#define __PLATFORM_PB11MPCORE_OFFSETS_H__

#include <l4/platform/realview/offsets.h>

/* Device offsets in physical memory */
#define PLATFORM_TIMER2_BASE         	0x10018000 /* TIMER 4-5 */
#define PLATFORM_TIMER3_BASE         	0x10019000 /* TIMER 6-7 */
#define PLATFORM_SYSCTRL1_BASE        	0x1001A000 /* System controller 1 */
#define PLATFORM_CLCD0_BASE		0x10020000 /* CLCD */
#define PLATFORM_GIC0_BASE            	0x1E000000 /* GIC 0 */
#define PLATFORM_GIC1_BASE            	0x1E010000 /* GIC 1 */
#define PLATFORM_GIC2_BASE            	0x1E020000 /* GIC 2 */
#define PLATFORM_GIC3_BASE            	0x1E030000 /* GIC 3 */

/*
 * Device offsets in virtual memory. They offset to some virtual
 * device base address. Each page on this virtual base is consecutively
 * allocated to devices. Nice and smooth.
 */

/* Add userspace devices here as they become necessary for irqs */

/* Add size of various user space devices, to be used in capability generation */

#endif /* __PLATFORM_PB11MPCORE_OFFSETS_H__ */

