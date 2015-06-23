/*
 * Describes physical memory layout of EB platform.
 *
 * This only include physical and memory offsets that
 * are not included in realview/offsets.h
 *
 * Copyright (C) 2009 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#ifndef __PLATFORM_EB_OFFSETS_H__
#define __PLATFORM_EB_OFFSETS_H__

#include <l4/platform/realview/offsets.h>

/* Device offsets in physical memory */
#define PLATFORM_GIC1_BASE		0x10040000 /* GIC 1 */
#define PLATFORM_GIC2_BASE		0x10050000 /* GIC 2 */
#define PLATFORM_GIC3_BASE		0x10060000 /* GIC 3 */
#define PLATFORM_GIC4_BASE		0x10070000 /* GIC 4 */

/*
 * Virtual device offsets for EB platform - starting from
 * the last common realview virtual device offset
 */
#define MPCORE_PRIVATE_VBASE		(IO_AREA0_VADDR + (14 * DEVICE_PAGE))

#if defined (CONFIG_CPU_CORTEXA9)
#define	MPCORE_PRIVATE_BASE		0x1F000000
#endif	/* End CORTEXA9 */

#if defined (CONFIG_CPU_ARM11MPCORE)
#if defined REV_C || defined REV_D
#define MPCORE_PRIVATE_BASE		0x1F000000
#else  /* REV_B and QEMU */
#define MPCORE_PRIVATE_BASE		0x10100000
#endif /* End REV_B and QEMU */
#endif /* End ARM11MPCORE */

#if defined (CONFIG_CPU_CORTEXA9) || defined (CONFIG_CPU_ARM11MPCORE)
/* MPCore private memory region */
#define SCU_BASE		MPCORE_PRIVATE_BASE
#define SCU_VBASE		MPCORE_PRIVATE_VBASE
#define GIC0_CPU_VBASE		(MPCORE_PRIVATE_VBASE + 0x100)
#define GIC0_DIST_VBASE		(MPCORE_PRIVATE_VBASE + 0x1000)
#endif /* End CORTEXA9 || ARM11MPCORE */

#define GIC1_CPU_VBASE		(PLATFORM_GIC1_VBASE + 0x0)
#define GIC2_CPU_VBASE		(PLATFORM_GIC2_VBASE + 0x0)
#define GIC3_CPU_VBASE		(PLATFORM_GIC3_VBASE + 0x0)
#define GIC4_CPU_VBASE		(PLATFORM_GIC4_VBASE + 0x0)

#define GIC1_DIST_VBASE		(PLATFORM_GIC1_VBASE + 0x1000)
#define GIC2_DIST_VBASE		(PLATFORM_GIC2_VBASE + 0x1000)
#define GIC3_DIST_VBASE		(PLATFORM_GIC3_VBASE + 0x1000)
#define GIC4_DIST_VBASE		(PLATFORM_GIC4_VBASE + 0x1000)

#if defined (CONFIG_CPU_ARM11MPCORE) || defined (CONFIG_CPU_CORTEXA9)
#define PLATFORM_IRQCTRL0_VIRTUAL		EB_GIC0_VBASE
#endif

#define PLATFORM_IRQCTRL1_VIRTUAL		EB_GIC1_VBASE

#endif /* __PLATFORM_EB_OFFSETS_H__ */

