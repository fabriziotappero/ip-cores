/*
 * Generic layer over ARMv5 soecific cache calls
 *
 * Copyright B-Labs Ltd 2010.
 */

#include INC_SUBARCH(mmu_ops.h)

void arch_invalidate_dcache(unsigned long start, unsigned long end)
{
	arm_invalidate_dcache();
}

void arch_clean_invalidate_dcache(unsigned long start, unsigned long end)
{
	arm_clean_invalidate_dcache();
}

void arch_invalidate_icache(unsigned long start, unsigned long end)
{
	arm_invalidate_icache();
}

void arch_clean_dcache(unsigned long start, unsigned long end)
{
	arm_clean_dcache();
}

void arch_invalidate_tlb(unsigned long start, unsigned long end)
{
	arm_invalidate_tlb();
}
