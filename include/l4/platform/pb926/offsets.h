/*
 * Describes physical memory layout of pb926 platform.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_PB926_OFFSETS_H__
#define __PLATFORM_PB926_OFFSETS_H__

/* Physical memory base */
#define	PLATFORM_PHYS_MEM_START			0x00000000 /* inclusive */
#define	PLATFORM_PHYS_MEM_END			0x08000000 /* 128 MB, exclusive */

/*
 * Device offsets in physical memory
 * Naming of devices done starting with 0 subscript,
 * as we use these names for device capability
 */
#define	PLATFORM_SYSTEM_REGISTERS		0x10000000 /* System registers */
#define PLATFORM_KEYBOARD0_BASE            	0x10006000 /* Keyboard */
#define PLATFORM_MOUSE0_BASE               	0x10007000 /* Mouse */
#define	PLATFORM_SYSCTRL_BASE			0x101E0000 /* System controller */
#define	PLATFORM_WATCHDOG_BASE			0x101E1000 /* Watchdog */
#define	PLATFORM_TIMER0_BASE			0x101E2000 /* Timers 0 and 1 */
#define	PLATFORM_TIMER1_BASE			0x101E3000 /* Timers 2 and 3 */
#define	PLATFORM_RTC_BASE			0x101E8000 /* Real Time Clock */
#define	PLATFORM_VIC_BASE			0x10140000 /* Primary Vectored IC */
#define	PLATFORM_SIC_BASE			0x10003000 /* Secondary IC */
#define	PLATFORM_UART0_BASE			0x101F1000 /* Console port (UART0) */
#define	PLATFORM_UART1_BASE			0x101F2000 /* Console port (UART1) */
#define	PLATFORM_UART2_BASE			0x101F3000 /* Console port (UART2) */
#define	PLATFORM_UART3_BASE			0x10009000 /* Console port (UART3) */
#define	PLATFORM_CLCD0_BASE			0x10120000 /* Color LCD */

/*
 * Device offsets in virtual memory. They offset to some virtual
 * device base address. Each page on this virtual base is consecutively
 * allocated to devices. Nice and smooth.
 */
#define DEVICE_PAGE		0x1000

#define PLATFORM_TIMER0_VBASE   (IO_AREA0_VADDR + (0 * DEVICE_PAGE))
#define PLATFORM_CONSOLE_VBASE	(IO_AREA0_VADDR + (1 * DEVICE_PAGE))
#define PLATFORM_IRQCTRL0_VBASE	(IO_AREA0_VADDR + (2 * DEVICE_PAGE))
#define PLATFORM_IRQCTRL1_VBASE	(IO_AREA0_VADDR + (3 * DEVICE_PAGE))
#define PLATFORM_SYSCTRL_VBASE  (IO_AREA0_VADDR + (4 * DEVICE_PAGE))

/* Add userspace devices here as they become necessary for irqs */
#define PLATFORM_TIMER1_VBASE		(IO_AREA0_VADDR + (6 * DEVICE_PAGE))
#define PLATFORM_KEYBOARD0_VBASE   	(IO_AREA0_VADDR + (7 * DEVICE_PAGE))
#define PLATFORM_MOUSE0_VBASE   	(IO_AREA0_VADDR + (8 * DEVICE_PAGE))
#define PLATFORM_CLCD0_VBASE           	(IO_AREA0_VADDR + (9 * DEVICE_PAGE))

/* The SP810 system controller offsets */
#define SP810_BASE			PLATFORM_SYSCTRL_VBASE
#define SP810_SCCTRL			(SP810_BASE + 0x0)

/* Add size of various user space devices, to be used in capability generation */
#define PLATFORM_UART1_SIZE		0x1000
#define PLATFORM_UART2_SIZE		0x1000
#define PLATFORM_UART3_SIZE		0x1000
#define PLATFORM_TIMER1_SIZE		0x1000
#define PLATFORM_KEYBOARD0_SIZE		0x1000
#define PLATFORM_MOUSE0_SIZE         	0x1000
#define PLATFORM_CLCD0_SIZE            	0x1000

#endif /* __PLATFORM_PB926_OFFSETS_H__ */

