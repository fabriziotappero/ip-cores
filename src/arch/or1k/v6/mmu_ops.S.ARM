/*
 * low-level mmu operations
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#include INC_ARCH(asm.h)

#define C15_id			c0
#define C15_control		c1
#define C15_ttb			c2
#define C15_dom			c3
#define C15_fsr			c5
#define C15_far			c6
#define C15_tlb			c8

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

/* FIXME: Make sure the ops that need r0 dont trash r0, or if they do,
 * save it on stack before these operations.
 */

/*
 * In ARM terminology, flushing the cache means invalidating its contents.
 * Cleaning the cache means, writing the contents of the cache back to
 * main memory. In write-back caches the cache must be cleaned before
 * flushing otherwise in-cache data is lost.
 */

BEGIN_PROC(arm_set_ttb)
	mcr	p15, 0, r0, C15_ttb, c0, 0
	mov	pc, lr
END_PROC(arm_set_ttb)

BEGIN_PROC(arm_get_domain)
	mrc	p15, 0, r0, C15_dom, c0, 0
	mov	pc, lr
END_PROC(arm_get_domain)

BEGIN_PROC(arm_set_domain)
	mcr	p15, 0, r0, C15_dom, c0, 0
	mov	pc, lr
END_PROC(arm_set_domain)

BEGIN_PROC(arm_enable_mmu)
	mrc	p15, 0, r0, C15_control, c0, 0
	orr	r0, r0, #C15_C0_M
	mcr	p15, 0, r0, C15_control, c0, 0
	mov	pc, lr
END_PROC(arm_enable_mmu)

BEGIN_PROC(arm_enable_icache)
	mrc	p15, 0, r0, C15_control, c0, 0
	orr	r0, r0, #C15_C0_I
	mcr	p15, 0, r0, C15_control, c0, 0
	mov	pc, lr
END_PROC(arm_enable_icache)

BEGIN_PROC(arm_enable_dcache)
	mrc	p15, 0, r0, C15_control, c0, 0
	orr	r0, r0, #C15_C0_C
	mcr	p15, 0, r0, C15_control, c0, 0
	mov	pc, lr
END_PROC(arm_enable_dcache)

BEGIN_PROC(arm_enable_wbuffer)
	mrc	p15, 0, r0, C15_control, c0, 0
	orr	r0, r0, #C15_C0_W
	mcr	p15, 0, r0, C15_control, c0, 0
	mov	pc, lr
END_PROC(arm_enable_wbuffer)

BEGIN_PROC(arm_enable_high_vectors)
	mrc	p15, 0, r0, C15_control, c0, 0
	orr	r0, r0, #C15_C0_V
	mcr	p15, 0, r0, C15_control, c0, 0
	mov	pc, lr
END_PROC(arm_enable_high_vectors)

BEGIN_PROC(arm_invalidate_cache)
	mov	r0, #0			@ FIX THIS
	mcr	p15, 0, r0, c7, c7	@ Flush I cache and D cache
	mov	pc, lr
END_PROC(arm_invalidate_cache)

BEGIN_PROC(arm_invalidate_icache)
	mov	r0, #0			@ FIX THIS
	mcr	p15, 0, r0, c7, c5, 0	@ Flush I cache
	mov	pc, lr
END_PROC(arm_invalidate_icache)

BEGIN_PROC(arm_invalidate_dcache)
	mov	r0, #0			@ FIX THIS
	mcr	p15, 0, r0, c7, c6, 0	@ Flush D cache
	mov	pc, lr
END_PROC(arm_invalidate_dcache)

BEGIN_PROC(arm_clean_dcache)
	mrc	p15, 0 , pc, c7, c10, 3 @ Test/clean dcache line
	bne	arm_clean_dcache
	mcr	p15, 0, ip, c7, c10, 4	@ Drain WB
	mov	pc, lr
END_PROC(arm_clean_dcache)

BEGIN_PROC(arm_clean_invalidate_dcache)
1:
	mrc	p15, 0, pc, c7, c14, 3	@ Test/clean/flush dcache line
					@ COMMENT: Why use PC?
	bne	1b
	mcr	p15, 0, ip, c7, c10, 4	@ Drain WB
	mov	pc, lr
END_PROC(arm_clean_invalidate_dcache)

BEGIN_PROC(arm_clean_invalidate_cache)
1:
	mrc	p15, 0, r15, c7, c14, 3	@ Test/clean/flush dcache line
					@ COMMENT: Why use PC?
	bne	1b
	mcr	p15, 0, ip, c7, c5, 0	@ Flush icache
	mcr	p15, 0, ip, c7, c10, 4	@ Drain WB
	mov	pc, lr
END_PROC(arm_clean_invalidate_cache)

BEGIN_PROC(arm_drain_writebuffer)
	mov	r0, #0		@ FIX THIS
	mcr	p15, 0, r0, c7, c10, 4
	mov	pc, lr
END_PROC(arm_drain_writebuffer)

BEGIN_PROC(arm_invalidate_tlb)
	mcr	p15, 0, ip, c8, c7
	mov	pc, lr
END_PROC(arm_invalidate_tlb)

BEGIN_PROC(arm_invalidate_itlb)
	mov	r0, #0		@ FIX THIS
	mcr	p15, 0, r0, c8, c5, 0
	mov	pc, lr
END_PROC(arm_invalidate_itlb)

BEGIN_PROC(arm_invalidate_dtlb)
	mov	r0, #0		@ FIX THIS
	mcr	p15, 0, r0, c8, c6, 0
	mov	pc, lr
END_PROC(arm_invalidate_dtlb)

