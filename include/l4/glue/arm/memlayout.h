/*
 * Virtual memory layout of ARM systems.
 */

#ifndef __MEMLAYOUT_H__
#define __MEMLAYOUT_H__

#ifndef __ASSEMBLY__
#include INC_GLUE(memory.h)
#endif
#include INC_PLAT(offsets.h)

#define KERNEL_AREA_START	0xF0000000
#define KERNEL_AREA_END		0xF8000000	/* 128 MB */
#define KERNEL_AREA_SIZE	(KERNEL_AREA_END - KERNEL_AREA_START)
#define KERNEL_AREA_SECTIONS	(KERNEL_AREA_SIZE / ARM_SECTION_SIZE)

#define UTCB_SIZE		(sizeof(int) * 64)

#define IO_AREA_START		0xF9000000
#define IO_AREA_END		0xFF000000
#define IO_AREA_SIZE		(IO_AREA_END - IO_AREA_START)
#define IO_AREA_SECTIONS	(IO_AREA_SIZE / ARM_SECTION_SIZE)

#define USER_KIP_PAGE		0xFF000000

/* ARM-specific offset in KIP that tells the address of UTCB page */
#define UTCB_KIP_OFFSET		0x50

#define IO_AREA0_VADDR		IO_AREA_START
#define IO_AREA1_VADDR		(IO_AREA_START + (SZ_1MB*1))
#define IO_AREA2_VADDR		(IO_AREA_START + (SZ_1MB*2))
#define IO_AREA3_VADDR		(IO_AREA_START + (SZ_1MB*3))
#define IO_AREA4_VADDR		(IO_AREA_START + (SZ_1MB*4))
#define IO_AREA5_VADDR		(IO_AREA_START + (SZ_1MB*5))
#define IO_AREA6_VADDR		(IO_AREA_START + (SZ_1MB*6))
#define IO_AREA7_VADDR		(IO_AREA_START + (SZ_1MB*7))

/*
 * IO_AREA8_VADDR
 * The beginning page in this slot is used for userspace uart mapping
 */

#define ARM_HIGH_VECTOR		0xFFFF0000
#define ARM_SYSCALL_VECTOR	0xFFFFFF00

#define KERNEL_OFFSET		(KERNEL_AREA_START - PLATFORM_PHYS_MEM_START)

/* User tasks define them differently */
#if defined (__KERNEL__)
#define phys_to_virt(addr)	((unsigned int)(addr) + KERNEL_OFFSET)
#define virt_to_phys(addr)	((unsigned int)(addr) - KERNEL_OFFSET)
#endif

#define KERN_ADDR(x)		((x >= KERNEL_AREA_START) && (x < KERNEL_AREA_END))
#define UTCB_ADDR(x)		((x >= UTCB_AREA_START) && (x < UTCB_AREA_END))
#define is_kernel_address(x)	(KERN_ADDR(x) || (x >= ARM_HIGH_VECTOR) || \
				 (x >= IO_AREA_START && x < IO_AREA_END))

#endif /* __MEMLAYOUT_H__ */
