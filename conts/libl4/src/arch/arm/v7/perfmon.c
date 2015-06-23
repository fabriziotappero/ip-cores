/*
 * Performance monitoring
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/perfmon.h>

#if defined (CONFIG_DEBUG_PERFMON_USER)
/*
 * Resets/restarts cycle counter
 */
void perfmon_reset_start_cyccnt()
{
	volatile u32 pmcctrl;

	/* Disable the cycle counter register */
	cp15_write_perfmon_cntenclr(1 << PMCCNTR_BIT);

	/* Clear the cycle counter on ctrl register */
	pmcctrl = cp15_read_perfmon_ctrl();
	pmcctrl |= (1 << PMCR_C_BIT);
	cp15_write_perfmon_ctrl(pmcctrl);

	/* Clear overflow register */
	cp15_write_perfmon_overflow(1 << PMCCNTR_BIT);

	/* Enable the cycle count */
	cp15_write_perfmon_cntenset(1 << PMCCNTR_BIT);
}

/*
 * Reads current counter, clears and restarts it
 */
u32 perfmon_read_reset_start_cyccnt()
{
	volatile u32 cyccnt = cp15_read_perfmon_cyccnt();

	perfmon_reset_start_cyccnt();

	return cyccnt;
}

#endif /* End of !CONFIG_DEBUG_PERFMON_USER */
