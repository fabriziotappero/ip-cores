/*
 * ARM v5 specific init routines
 *
 * Copyright (C) 2007 - 2010 B Labs Ltd.
 */

#include <l4/generic/tcb.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/platform.h>
#include INC_SUBARCH(mm.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_ARCH(linker.h)

SECTION(".init.pgd") ALIGN(PGD_SIZE) pgd_table_t init_pgd;


void jump(struct ktcb *task)
{
	__asm__ __volatile__ (
		"mov	lr,	%0\n"	/* Load pointer to context area */
		"ldr	r0,	[lr]\n"	/* Load spsr value to r0 */
		"msr	spsr,	r0\n"	/* Set SPSR as ARM_MODE_USR */
		"add	sp, lr, %1\n"	/* Reset SVC stack */
		"sub	sp, sp, %2\n"	/* Align to stack alignment */
		"ldmib	lr, {r0-r14}^\n" /* Load all USR registers */

		"nop		\n"	/* Spec says dont touch banked registers
					 * right after LDM {no-pc}^ for one instruction */
		"add	lr, lr, #64\n"	/* Manually move to PC location. */
		"ldr	lr,	[lr]\n"	/* Load the PC_USR to LR */
		"movs	pc,	lr\n"	/* Jump to userspace, also switching SPSR/CPSR */
		:
		: "r" (task), "r" (PAGE_SIZE), "r" (STACK_ALIGNMENT)
	);
}

void switch_to_user(struct ktcb *task)
{
	arm_clean_invalidate_cache();
	arm_invalidate_tlb();
	arm_set_ttb(virt_to_phys(TASK_PGD(task)));
	arm_invalidate_tlb();
	jump(task);
}

/* Maps the early memory regions needed to bootstrap the system */
void init_kernel_mappings(void)
{
	memset((void *)virt_to_phys(&init_pgd), 0, sizeof(pgd_table_t));

	/* Map kernel area to its virtual region */
	add_section_mapping_init(align(virt_to_phys(_start_text), SZ_1MB),
				 align((unsigned int)_start_text, SZ_1MB), 1,
				 cacheable | bufferable);

	/* Map kernel one-to-one to its physical region */
	add_section_mapping_init(align(virt_to_phys(_start_text), SZ_1MB),
				 align(virt_to_phys(_start_text), SZ_1MB),
				 1, 0);
}

/*
 * Enable virtual memory using kernel's pgd
 * and continue execution on virtual addresses.
 */
void start_virtual_memory()
{
	/*
	 * TTB must be 16K aligned. This is because first level tables are
	 * sized 16K.
	 */
	if ((unsigned int)&init_pgd & 0x3FFF)
		dprintk("kspace not properly aligned for ttb:",
			(u32)&init_pgd);
	// memset((void *)&kspace, 0, sizeof(pgd_table_t));
	arm_set_ttb(virt_to_phys(&init_pgd));

	/*
	 * This sets all 16 domains to zero and  domain 0 to 1. The outcome
	 * is that page table access permissions are in effect for domain 0.
	 * All other domains have no access whatsoever.
	 */
	arm_set_domain(1);

	/* Enable everything before mmu permissions are in place */
	arm_enable_caches();
	arm_enable_wbuffer();

	arm_enable_high_vectors();

	/*
	 * Leave the past behind. Tlbs are invalidated, write buffer is drained.
	 * The whole of I + D caches are invalidated unconditionally. This is
	 * important to ensure that the cache is free of previously loaded
	 * values. Otherwise unpredictable data aborts may occur at arbitrary
	 * times, each time a load/store operation hits one of the invalid
	 * entries and those entries are cleaned to main memory.
	 */
	arm_invalidate_cache();
	arm_drain_writebuffer();
	arm_invalidate_tlb();
	arm_enable_mmu();

	/* Jump to virtual memory addresses */
	__asm__ __volatile__ (
		"add	sp, sp, %0	\n"	/* Update stack pointer */
		"add	fp, fp, %0	\n"	/* Update frame pointer */
		/* On the next instruction below, r0 gets
		 * current PC + KOFFSET + 2 instructions after itself. */
		"add	r0, pc, %0	\n"
		/* Special symbol that is extracted and included in the loader.
		 * Debuggers can break on it to load the virtual symbol table */
		".global break_virtual;\n"
		"break_virtual:\n"
		"mov	pc, r0		\n" /* (r0 has next instruction) */
		:
		: "r" (KERNEL_OFFSET)
		: "r0"
	);

	/*
	 * Restore link register (LR) for this function.
	 *
	 * NOTE: LR values are pushed onto the stack at each function call,
	 * which means the restored return values will be physical for all
	 * functions in the call stack except this function. So the caller
	 * of this function must never return but initiate scheduling etc.
	 */
	__asm__ __volatile__ (
		"add	%0, %0, %1	\n"
		"mov	pc, %0		\n"
		:: "r" (__builtin_return_address(0)), "r" (KERNEL_OFFSET)
	);

	/* should never come here */
	while(1);
}
