/*
 * Describes physical memory layout of realview platform.
 * Right now this contains common offsets for
 * pb11mpcore, pba9 and eb.
 *
 * This is internally included by respective platform's offsets.h
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_REALVIEW_OFFSETS_H__
#define __PLATFORM_REALVIEW_OFFSETS_H__

/* Physical memory base */
#define	PLATFORM_PHYS_MEM_START			0x00000000 /* inclusive */
#define	PLATFORM_PHYS_MEM_END			0x10000000 /* 256 MB, exclusive */

/*
 * Device offsets in physical memory
 * Naming of devices done starting with 0 subscript,
 * as we use these names for device capability
 */
#define	PLATFORM_SYSTEM_REGISTERS	0x10000000 /* System registers */
#define	PLATFORM_SYSCTRL_BASE		0x10001000 /* System controller0 */
#define PLATFORM_KEYBOARD0_BASE         0x10006000 /* Keyboard */
#define PLATFORM_MOUSE0_BASE            0x10007000 /* Mouse */
#define PLATFORM_UART0_BASE		0x10009000 /* Console port (UART0) */
#define PLATFORM_UART1_BASE		0x1000A000 /* Console port (UART1) */
#define PLATFORM_UART2_BASE		0x1000B000 /* Console port (UART2) */
#define PLATFORM_UART3_BASE		0x1000C000 /* Console port (UART3) */
#define PLATFORM_TIMER0_BASE		0x10011000 /* Timers 0 and 1 */
#define PLATFORM_TIMER1_BASE		0x10012000 /* Timers 2 and 3 */

/*
 * Virtual Memory base address, where devices will be mapped.
 * Each Device will take one page in virtual memory.
 * Nice and smooth.
 */
#define DEVICE_PAGE			0x1000

#define PLATFORM_SYSREGS_VBASE  (IO_AREA0_VADDR + (0 * DEVICE_PAGE))
#define PLATFORM_SYSCTRL_VBASE  (IO_AREA0_VADDR + (1 * DEVICE_PAGE))
#define PLATFORM_SYSCTRL1_VBASE (IO_AREA0_VADDR + (2 * DEVICE_PAGE))
#define PLATFORM_CONSOLE_VBASE  (IO_AREA0_VADDR + (3 * DEVICE_PAGE))
#define PLATFORM_TIMER0_VBASE   (IO_AREA0_VADDR + (4 * DEVICE_PAGE))
#define PLATFORM_GIC0_VBASE     (IO_AREA0_VADDR + (5 * DEVICE_PAGE))
#define PLATFORM_GIC1_VBASE     (IO_AREA0_VADDR + (7 * DEVICE_PAGE))
#define PLATFORM_GIC2_VBASE     (IO_AREA0_VADDR + (8 * DEVICE_PAGE))
#define PLATFORM_GIC3_VBASE     (IO_AREA0_VADDR + (9 * DEVICE_PAGE))


/* Add size of various user space devices, to be used in capability generation */
#define PLATFORM_TIMER1_VBASE        	(IO_AREA0_VADDR + (10 * DEVICE_PAGE))
#define PLATFORM_KEYBOARD0_VBASE	(IO_AREA0_VADDR + (11 * DEVICE_PAGE))
#define PLATFORM_MOUSE0_VBASE           (IO_AREA0_VADDR + (12 * DEVICE_PAGE))
#define PLATFORM_CLCD0_VBASE            (IO_AREA0_VADDR + (13 * DEVICE_PAGE))

/* The SP810 system controller offsets */
#define SP810_BASE			PLATFORM_SYSCTRL_VBASE
#define SP810_SCCTRL			(SP810_BASE + 0x0)

/* Add size of various user space devices, to be used in capability generation */
#define PLATFORM_UART1_SIZE		DEVICE_PAGE
#define PLATFORM_UART2_SIZE		DEVICE_PAGE
#define PLATFORM_UART3_SIZE		DEVICE_PAGE
#define PLATFORM_TIMER1_SIZE		DEVICE_PAGE
#define PLATFORM_KEYBOARD0_SIZE         DEVICE_PAGE
#define PLATFORM_MOUSE0_SIZE            DEVICE_PAGE
#define PLATFORM_CLCD0_SIZE            	DEVICE_PAGE

#endif /* __PLATFORM_REALVIEW_OFFSETS_H__ */

