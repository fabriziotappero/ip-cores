/*
 * Mock-up memory layout definitions for test purposes.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */

#ifndef __BASICLAYOUT_H__
#define __BASICLAYOUT_H__


#ifndef __ASSEMBLY__
#include INC_GLUE(memory.h)
#endif
#include INC_PLAT(offsets.h)

#define RESERVED_AREA_START	0x0
#define RESERVED_AREA_END	0x00400000
#define RESERVED_AREA_SIZE	(RESERVED_AREA_END - RESERVED_AREA_START)
#define RESERVED_AREA_SECTIONS	(RESERVED_AREA_SIZE / ARM_SECTION_SIZE)

/* 0x00400000 */
#define USER_AREA_START		0x00400000
#define USER_AREA_END		0xF0000000
#define USER_AREA_SIZE		(USER_AREA_END - USER_AREA_START)
#define USER_AREA_SECTIONS	(USER_AREA_SIZE / ARM_SECTION_SIZE)

/* 0xf0000000 */
#define KERNEL_AREA_START	0xF0000000
#define KERNEL_AREA_END		0xF4000000
#define KERNEL_AREA_SIZE	(KERNEL_AREA_END - KERNEL_AREA_START)
#define KERNEL_AREA_SECTIONS	(KERNEL_AREA_SIZE / ARM_SECTION_SIZE)

/* Kernel offset is taken as virtual memory base */
#define VIRT_ADDR_BASE		KERNEL_AREA_START

/* 0xf4000000 */
#define UNCACHE_AREA_START	0xF4000000
#define UNCACHE_AREA_END	0xF8000000
#define UNCACHE_AREA_SIZE	(UNCACHE_AREA_END - UNCACHE_AREA_START)
#define UNCACHE_AREA_SECTIONS	(UNCACHE_AREA_SIZE / ARM_SECTION_SIZE)

/* The page tables are the main clients of uncached virtual memory */
#define PGTABLE_ADDR_BASE	UNCACHE_AREA_START

/* 0xf8000000 */
#define VAR_AREA_START		0xF8000000
#define VAR_AREA_END		0xF9000000
#define VAR_AREA_SIZE		(VAR_AREA_END - VAR_AREA_START)
#define VAR_AREA_SECTIONS	(VAR_AREA_SIZE / ARM_SECTION_SIZE)

/* 0xf9000000 */
#define IO_AREA_START		0xF9000000
#define IO_AREA_END		0xFF000000
#define IO_AREA_SIZE		(IO_AREA_END - IO_AREA_START)
#define IO_AREA_SECTIONS	(IO_AREA_SIZE / ARM_SECTION_SIZE)

/* 0xff000000 */
#define MISC_AREA_START		0xFF000000
#define MISC_AREA_END		0xFFF00000
#define MISC_AREA_SIZE		(MISC_AREA_END - MISC_AREA_START)
#define MISC_AREA_SECTIONS	(MISC_AREA_SIZE / ARM_SECTION_SIZE)

/* First page in MISC area is used for KIP/UTCB reference page */
#define USER_KIP_PAGE		MISC_AREA_START

/* 0xfff00000 */
#define EXCPT_AREA_START	0xFFF00000
#define EXCPT_AREA_END		(EXCPT_AREA_START + ARM_SECTION_SIZE)
#define EXCPT_AREA_SIZE		(EXCPT_AREA_END - EXCPT_AREA_START)

/* 1MB IO Areas in the Virtual Address space. Define more if needed */
#define IO_AREA0_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*0))
#define IO_AREA1_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*1))
#define IO_AREA2_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*2))
#define IO_AREA3_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*3))
#define IO_AREA4_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*4))
#define IO_AREA5_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*5))
#define IO_AREA6_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*6))
#define IO_AREA7_VADDR		(IO_AREA_START + (ARM_SECTION_SIZE*7))

/*
 * Address of start of arm_high_vector - exception handling code
 */
#define ARM_HIGH_VECTOR_VADDR	(EXCPT_AREA_START | 0x000f0000 )
#define ARM_SYSCALL_VECTOR	(0xffffff00)

/*
 * These offsets depend on where the platform defines its physical memory
 * and how the system defines the virtual memory regions in arm/basiclayout.h
 */
//#define	KERNEL_OFFSET		(VIRT_ADDR_BASE - PHYS_ADDR_BASE)
//#define	PGTABLE_OFFSET		(PGTABLE_ADDR_BASE - PGTABLE_PHYS_ADDR_BASE)
/* Use a more predictible offset by just changing the top nibble */
#define KERNEL_OFFSET		VIRT_ADDR_BASE
#define PGTABLE_OFFSET		PGTABLE_ADDR_BASE

/*
 * Convenience macros for converting between address types.
 */
#if defined(__KERNEL__)
#define phys_to_virt(addr)	((unsigned int)addr)
#define phys_to_ptab(addr)	((unsigned int)addr)
#define virt_to_phys(addr)	((unsigned int)addr)
#define virt_to_ptab(addr)	(phys_to_ptab(virt_to_phys(addr)))
#endif
#endif /* __BASICLAYOUT_H__ */
