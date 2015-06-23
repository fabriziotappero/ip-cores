#ifndef __MMU__OPS__H__
#define __MMU__OPS__H__
/*
 * Prototypes for low level mmu operations
 *
 * Copyright (C) 2005 Bahadir Balban
 *
 */

void arm_set_ttb(unsigned int);
void arm_set_domain(unsigned int);
unsigned int arm_get_domain(void);
void arm_enable_mmu(void);
void arm_enable_icache(void);
void arm_enable_dcache(void);
void arm_enable_wbuffer(void);
void arm_enable_high_vectors(void);
void arm_invalidate_cache(void);
void arm_invalidate_icache(void);
void arm_invalidate_dcache(void);
void arm_clean_dcache(void);
void arm_clean_invalidate_dcache(void);
void arm_clean_invalidate_cache(void);
void arm_drain_writebuffer(void);
void arm_invalidate_tlb(void);
void arm_invalidate_itlb(void);
void arm_invalidate_dtlb(void);

static inline void arm_enable_caches(void)
{
	arm_enable_icache();
	arm_enable_dcache();
}


static inline void dmb(void)
{
	/* This is the closest to its meaning */
	arm_drain_writebuffer();
}

static inline void dsb(void)
{
	/* No op */
}

static inline void isb(void)
{
	/* No op */
}


#endif /* __MMU__OPS__H__ */
