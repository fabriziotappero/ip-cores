/*
 * The syscall page.
 *
 * Exported to userspace, used merely for entering the kernel.
 * Actual handling happens elsewhere.
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include INC_ARCH(asm.h)

.balign 4096
.section .data.syscalls

.global __syscall_page_start;
__syscall_page_start:

/* LR_USR is inspected to find out which system call. */
BEGIN_PROC(arm_system_calls)
	swi	0x14		@ ipc 			/* 0x0 */
	swi	0x14		@ thread_switch 	/* 0x4 */
	swi	0x14		@ thread_control	/* 0x8 */
	swi	0x14		@ exchange_registers	/* 0xc */
	swi	0x14		@ schedule		/* 0x10 */
	swi	0x14		@ unmap			/* 0x14 */
	swi	0x14		@ space_control		/* 0x18 */
	swi	0x14		@ processor_control	/* 0x1c */
	swi	0x14		@ memory_control	/* 0x20 */
	swi	0x14		@ getid			/* 0x24 */
	swi	0x14		@ kread			/* 0x28 */
	swi	0x14		@ kmem_control		/* 0x2C */
	swi	0x14		@ time			/* 0x30 */
	swi	0x14		@ mutex_control		/* 0x34 */
	swi	0x14		@ cache_control		/* 0x38 */
END_PROC(arm_system_calls)

