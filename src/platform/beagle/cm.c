/*
 * Clock mangaer module of the beagleboard.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 */

#include INC_PLAT(cm.h)
#include INC_ARCH(io.h)

/*
 * Enable Interface clock of device (represented by bit)
 * in CM module's(represented by CM_BASE) CM_FCLEN register
 */
void omap_cm_enable_iclk(unsigned long cm_base, int bit)
{
	unsigned int val = 0;

	val = read((cm_base + CM_FCLKEN_OFFSET));
	val |= (1 << bit);
	write(val, (cm_base + CM_FCLKEN_OFFSET));
}

/*
 * Enable Functional clock of device (represented by bit)
 * in CM module's(represented by CM_BASE) CM_FCLEN register
 */
void omap_cm_enable_fclk(unsigned long cm_base, int bit)
{
	unsigned int val = 0;

	val = read((cm_base + CM_ICLKEN_OFFSET));
	val |= (1 << bit);
	write(val, (cm_base + CM_FCLKEN_OFFSET));
}

/* Set clock source for device */
void omap_cm_clk_select(unsigned long cm_base, int bit, int src)
{
	unsigned int val = 0;

	val = read((cm_base + CM_CLKSEL_OFFSET));
	val |= (src << bit);
	write(val, (cm_base + CM_CLKSEL_OFFSET));
}
