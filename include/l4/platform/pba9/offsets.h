/*
 * Describes physical memory layout of pb926 platform.
 *
 * This only include physical and memory offsets that
 * are not included in realview/offsets.h
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Author: Bahadir Balban <bbalban@b-labs.co.uk>
 */

#ifndef __PLATFORM_PBA9_OFFSETS_H__
#define __PLATFORM_PBA9_OFFSETS_H__

#include <l4/platform/realview/offsets.h>

/*
 * Device offsets in physical memory
 * Naming of devices done starting with 0 subscript,
 * as we use these names for device capability
 */
#define PLATFORM_TIMER2_BASE		0x10018000 /* Timers 2 and 3 */
#define PLATFORM_TIMER3_BASE		0x10019000 /* Timers 2 and 3 */
#define PLATFORM_SYSCTRL1_BASE		0x1001A000 /* System controller1 */

#define PLATFORM_CLCD0_BASE		0x1001F000 /* CLCD */

#define PLATFORM_GIC0_BASE              0x1E000000 /* GIC 0 */

#define MPCORE_PRIVATE_BASE		0x1E000000

#define SCU_BASE		MPCORE_PRIVATE_BASE
#define SCU_VBASE		MPCORE_PRIVATE_VBASE
#define GIC0_CPU_VBASE		(MPCORE_PRIVATE_VBASE + 0x100)
#define GIC0_DIST_VBASE		(MPCORE_PRIVATE_VBASE + 0x1000)

/*
 * Virtual device offsets for Versatile Express A9
 * Offsets start from the last common realview virtual
 * device offset
 */
#define MPCORE_PRIVATE_VBASE	(IO_AREA0_VADDR + (14 * DEVICE_PAGE))

/* Add userspace devices here as they become necessary for irqs */

#endif /* __PLATFORM_PBA9_OFFSETS_H__ */
