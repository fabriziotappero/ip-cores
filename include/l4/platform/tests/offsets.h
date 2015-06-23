/*
 * Mock-up platform definition file for test purposes
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __PLATFORM_TEST_OFFSETS__H__
#define __PLATFORM_TEST_OFFSETS__H__

/* Physical memory base */
extern unsigned int PHYS_MEM_START;
extern unsigned int PHYS_MEM_END;
extern unsigned int PHYS_ADDR_BASE;

/*
 * These bases taken from where kernel is `physically' linked at,
 * also used to calculate virtual-to-physical translation offset.
 * See the linker script for their sources. PHYS_ADDR_BASE can't
 * use a linker variable because it's referred from assembler.
 */

/* Device memory base */
#define	PB926_DEV_PHYS			0x10000000

/* Device offsets in physical memory */
#define	PB926_SYSREGS_BASE		0x10000000 /* System registers */
#define	PB926_SYSCNTL_BASE		0x101E0000 /* System controller */
#define	PB926_WATCHDOG_BASE		0x101E1000 /* Watchdog */
#define	PB926_TIMER0_1_BASE		0x101E2000 /* Timers 0 and 1 */
#define	PB926_TIMER1_2_BASE		0x101E3000 /* Timers 2 and 3 */
#define	PB926_RTC_BASE			0x101E8000 /* Real Time Clock */
#define	PB926_VIC_BASE			0x10140000 /* Primary Vectored IC */
#define	PB926_SIC_BASE			0x10003000 /* Secondary IC */
#define	PB926_UART0_BASE		0x101F1000 /* Console port (UART0) */

/*
 * BB: Device offsets in virtual memory. They offset to some virtual
 * device base address. Each page on this virtual base is consecutively
 * allocated to devices. Nice and smooth.
 */
#define PB926_TIMER0_1_VOFFSET			0x00001000
#define	PB926_VIC_VOFFSET			0x00002000
#define	PB926_SIC_VOFFSET			0x00003000
#define PB926_UART0_VOFFSET			0x00004000
#define PB926_SYSREGS_VOFFSET			0x00005000
#define PB926_SYSCNTL_VOFFSET			0x00006000


#endif /*__PLATFORM_TEST_OFFSETS_H__*/

