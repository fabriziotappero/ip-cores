/*
 * Kernel Entry point for secondary cpus
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#include INC_ARCH(asm.h)
#include INC_PLAT(offsets.h)
#include INC_ARCH(asm-macros.S)

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

	.section .text.head

BEGIN_PROC(__smp_start)
	msr	cpsr_fxsc, #ARM_NOIRQ_SVC

	/* Disable mmu if it is enabled */
	mrc	p15, 0, r0, c1, c0, 0
	bic	r0, r0, #C15_C0_M	@ Disable MMU
	bic	r0, r0, #C15_C0_C	@ Disable (D) Cache
	bic	r0, r0, #C15_C0_I	@ Disable I cache
	bic	r0, r0, #C15_C0_W	@ Disable Write buffer
	mcr	p15, 0, r0, c1, c0, 0

	/* Setup boot stack (physical address) */

	/*
	 * Each processor gets a unique 1024 byte stack.
	 * This stack is used until the first task becomes
	 * runnable, so there needs to be one for each core
	 *
	 * +----------+
	 * |CPU3 Stack|
	 * +----------+
	 * |CPU2 Stack|
	 * +----------+
	 * |CPU1 Stack|
	 * +----------+
	 * |CPU0 Stack|
	 * +----------+ _bootstack_physical
	 */
	get_cpuid r0
	mov	r0, r0, lsl #12	 /* 4 KB stack per-cpu */
	ldr	sp,	_secondary_cpu_stack
	sub	sp, sp, r0

	/*
	 * Each processor will get its own irq/fiq/abt/und/svc stack
	 * of size 16 bytes per mode. Each mode would have 64 bytes
	 * of stack used in total for 4 cores.
	 *
	 * Note, unlike SVC mode all abort modes also include the
	 * stack for primary core, i.e CPU0. There's no separation
	 * of primary and secondary stack regions.
	 *
	 * +------------------+ __abt_stack_high
	 * |  CPU0 ABT Stack  |
	 * +------------------+ __abt_stack_high - 0x10
	 * |  CPU1 ABT Stack  |
	 * +------------------+ __abt_stack_high - 0x20
	 * |  CPU2 ABT Stack  |
	 * +------------------+ __abt_stack_high - 0x30
	 * |  CPU3 ABT Stack  |
	 * +------------------+ __abt_stack_high - 0x40
	 *
	 */
	get_cpuid r0
	mov	r0, r0, lsl #4	/* 16 byte stack for each core */

	/* Exception stacks are defined in vector page */
	msr	cpsr_fcx, #ARM_NOIRQ_ABT
	ldr	sp,	_sec_kern_abt_stack
	sub	sp, sp, r0
	msr	cpsr_fcx, #ARM_NOIRQ_IRQ
	ldr	sp,	_sec_kern_irq_stack
	sub	sp, sp, r0
	msr	cpsr_fcx, #ARM_NOIRQ_FIQ
	ldr	sp,	_sec_kern_fiq_stack
	sub	sp, sp, r0
	msr	cpsr_fcx, #ARM_NOIRQ_UND
	ldr	sp,	_sec_kern_und_stack
	sub	sp, sp, r0
	msr	cpsr_fcx, #ARM_NOIRQ_SVC

	/* Jump	to start_kernel */
	bl	smp_secondary_init

	/* Never reached */
1:
	b	1b

_secondary_cpu_stack:
	.word	_bootstack_physical

/* Exception stacks are defined in vector page */
_sec_kern_abt_stack:
	.word	__abt_stack_high
_sec_kern_irq_stack:
	.word	__irq_stack_high
_sec_kern_fiq_stack:
	.word	__fiq_stack_high
_sec_kern_und_stack:
	.word	__und_stack_high
