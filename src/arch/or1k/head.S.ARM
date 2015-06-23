/*
 * ARM Kernel entry point
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include INC_ARCH(asm.h)

#define C15_C0_M		0x0001	/* MMU */
#define C15_C0_A		0x0002	/* Alignment */
#define C15_C0_C		0x0004	/* (D) Cache */
#define C15_C0_W		0x0008	/* Write buffer */
#define C15_C0_B		0x0080	/* Endianness */
#define C15_C0_S		0x0100	/* System */
#define C15_C0_R		0x0200	/* ROM */
#define C15_C0_Z		0x0800	/* Branch Prediction */
#define C15_C0_I		0x1000	/* I cache */
#define	C15_C0_V		0x2000	/* High vectors */


/*
 * This is the entry point of the L4 ARM architecture.
 * The boot loader must call _start with the processor in privileged
 * mode and mmu disabled.
 */
	.section .text.head
BEGIN_PROC(_start)
	/* Setup status register for supervisor mode, interrupts disabled */
	msr	cpsr_fcxs, #ARM_MODE_SVC

	/* Disable mmu if it is enabled */
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #C15_C0_M	@ Disable MMU
	bic	r0, r0, #C15_C0_C	@ Disable (D) Cache
	bic	r0, r0, #C15_C0_I	@ Disable I cache
	bic	r0, r0, #C15_C0_W	@ Disable Write buffer
	bic	r0, r0, #C15_C0_Z	@ Disable Branch prediction
	mcr	p15, 0, r0, c1, c0, 0

	/* Setup boot stack (physical address) */
	ldr	sp,	_kernel_init_stack

	/* Exception stacks are defined in vector page */
	msr	cpsr_fc, #ARM_NOIRQ_ABT
	ldr	sp,	_kernel_abt_stack
	msr	cpsr_fc, #ARM_NOIRQ_IRQ
	ldr	sp,	_kernel_irq_stack
	msr	cpsr_fc, #ARM_NOIRQ_FIQ
	ldr	sp,	_kernel_fiq_stack
	msr	cpsr_fc, #ARM_NOIRQ_UND
	ldr	sp,	_kernel_und_stack
	msr	cpsr_fc, #ARM_NOIRQ_SVC

	/* Jump	to start_kernel */
	bl	start_kernel

	/* Never reached */
1:
	b	1b

_kernel_init_stack:
	.word	_bootstack_physical

/* Exception stacks are defined in vector page */
_kernel_abt_stack:
	.word	__abt_stack_high
_kernel_irq_stack:
	.word	__irq_stack_high
_kernel_fiq_stack:
	.word	__fiq_stack_high
_kernel_und_stack:
	.word	__und_stack_high
