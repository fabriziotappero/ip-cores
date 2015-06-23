/*
 *
 * Describes physical memory layout of Beagle Boards.
 * We have rev3 boards.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_BEAGLE_OFFSETS_H__
#define __PLATFORM_BEAGLE_OFFSETS_H__

/*
 * Physical memory base
 * FIXME: Somewhere its written: Rev 1 and 2
 * of Beagleboard has 128MB SDRAM while Rev 3 has 256MB
 * SDRAM which is detected automatically on intiliazation,
 * we have Rev3 boards, so hardcoding this only.
 */
#define PLATFORM_PHYS_MEM_START	0x80000000 /* inclusive */
#define PLATFORM_PHYS_MEM_END	0x90000000 /* 256MB, exclusive */

/*
 * Device offsets in physical memory
 * Naming of devices done starting with 0 subscript,
 * as we use these names for device capability
 */
#define PLATFORM_WKUP_CM_BASE		0x48004C00 /* Wake up clock manager */
#define PLATFORM_PERCM_BASE		0x48005000 /* Peripheral Clock Manager */
#define PLATFORM_UART0_BASE		0x4806A000 /* UART 0 */
#define PLATFORM_UART1_BASE		0x4806C000 /* UART 1 */
#define PLATFORM_UART2_BASE		0x49020000 /* UART 2 */
#define PLATFORM_TIMER0_BASE		0x48318000 /* GPTIMER1 */
#define PLATFORM_TIMER1_BASE		0x49032000 /* GPTIMER2 */
#define PLATFORM_TIMER2_BASE            0x49034000 /* GPTIMER3 */
#define PLATFORM_TIMER3_BASE            0x49036000 /* GPTIMER4 */
#define PLATFORM_TIMER4_BASE            0x49038000 /* GPTIMER5 */
#define PLATFORM_TIMER5_BASE            0x4903A000 /* GPTIMER6 */
#define PLATFORM_TIMER6_BASE            0x4903C000 /* GPTIMER7 */
#define PLATFORM_TIMER7_BASE            0x4903E000 /* GPTIMER8 */
#define PLATFORM_TIMER8_BASE            0x49040000 /* GPTIMER9 */
#define PLATFORM_TIMER9_BASE            0x48086000 /* GPTIMER10 */
#define PLATFORM_TIMER10_BASE		0x48088000 /* GPTIMER11 */
#define PLATFORM_TIMER11_BASE		0x48304000 /* GPTIMER12 */
#define PLATFORM_INTC_BASE		0x48200000 /* Interrupt controller */

/*
 * Virtual Memory base address, where devices will be mapped.
 * Each Device will take one page in virtual memory.
 * Nice and smooth.
 */
#define DEVICE_PAGE		0x1000

#define PLATFORM_WKUP_CM_VBASE		(IO_AREA0_VADDR + (0 * DEVICE_PAGE))
#define PLATFORM_CONSOLE_VBASE		(IO_AREA0_VADDR + (1 * DEVICE_PAGE))
#define PLATFORM_TIMER0_VBASE		(IO_AREA0_VADDR + (2 * DEVICE_PAGE))
#define PLATFORM_INTC_VBASE		(IO_AREA0_VADDR + (3 * DEVICE_PAGE))
#define PLATFORM_PERCM_VBASE          	(IO_AREA0_VADDR + (4 * DEVICE_PAGE))

/* Add userspace devices here as they become necessary for irqs */
#define PLATFORM_TIMER1_VBASE           (IO_AREA0_VADDR + (5 * DEVICE_PAGE))

/* Add size of various user space devices, to be used in capability generation */
#define PLATFORM_TIMER1_SIZE		DEVICE_PAGE

#endif /* __PLATFORM_BEAGLE_OFFSETS_H__ */

