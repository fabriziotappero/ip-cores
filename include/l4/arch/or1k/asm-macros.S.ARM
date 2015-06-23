/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Common assembler macros
 *
 * Prem Mallappa, Bahadir Balban
 */
#ifndef __ASM_MACROS_S__
#define __ASM_MACROS_S__

	.macro get_cpuid cpuid
		mrc  p15, 0, \cpuid, c0, c0, 5	@ Read MPIDR
		and \cpuid, \cpuid, #0xF	@ Mask lower cpuid bits
	.endm

#endif /* __ASM_MACROS_S__ */
