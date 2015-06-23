/*
 * Clock mangaer module of the beagleboard.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */

#ifndef __PLATFORM_BEAGLE_CM_H__
#define __PLATFORM_BEAGLE_CM_H__

/*
 * Register offsets for Clock Manager(CM)
 * PER_CM, WKUP_CM etc all have same offsets
 * for registers
 */
#define CM_FCLKEN_OFFSET    0x00
#define CM_ICLKEN_OFFSET    0x10
#define CM_CLKSEL_OFFSET    0x40

void omap_cm_enable_iclk(unsigned long cm_base, int bit);
void omap_cm_enable_fclk(unsigned long cm_base, int bit);
void omap_cm_clk_select(unsigned long cm_base, int bit, int src);

#endif /* __PLATFORM_BEAGLE_CM_H__ */

