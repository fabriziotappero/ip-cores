/*
 * Describes physical memory layout of EB platform.
 *
 * This only include physical and memory offsets that
 * are not included in realview/offsets.h
 *
 * Copyright (C) 2009 B Labs Ltd.
 */

#ifndef __PLATFORM_PBA8_OFFSETS_H__
#define __PLATFORM_PBA8_OFFSETS_H__

#include <l4/platform/realview/offsets.h>

/*
 * These bases taken from where kernel is `physically' linked at,
 * also used to calculate virtual-to-physical translation offset.
 * See the linker script for their sources. PHYS_ADDR_BASE can't
 * use a linker variable because it's referred from assembler.
 */
#define	PHYS_ADDR_BASE			0x100000

/* Device offsets in physical memory */
#define PLATFORM_TIMER2_BASE            0x10018000 /* Timers 4 and 5 */
#define PLATFORM_TIMER3_BASE            0x10019000 /* Timers 6 and 7 */
#define PLATFORM_SYSCTRL1_BASE          0x1001A000 /* System controller1 */
#define PLATFORM_CLCD0_BASE		0x10020000 /* CLCD */
#define PLATFORM_GIC1_BASE		0x1E000000 /* GIC 1 */
#define PLATFORM_GIC2_BASE		0x1E010000 /* GIC 2 */
#define PLATFORM_GIC3_BASE		0x1E020000 /* GIC 3 */
#define PLATFORM_GIC4_BASE		0x1E030000 /* GIC 4 */

/*
 * Device offsets in virtual memory. They offset to some virtual
 * device base address. Each page on this virtual base is consecutively
 * allocated to devices. Nice and smooth.
 * Make sure the offsets used here are not conflicting with the ones
 * present in <l4/platform/realview/offset.h>
 */

#endif /* __PLATFORM_PBA8_OFFSETS_H__ */

