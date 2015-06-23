/*
 * OMAP3XXX Interrupt Controller Defines
 *
 * Copyright 2010 B Labs Ltd.
 */
#ifndef __OMAP3_INTC_H__
#define __OMAP3_INTC_H__

#include INC_ARCH(io.h)

#define OMAP3_INTC_SYSCONFIG		(0x00000010) /* RW */
#define OMAP3_INTC_SYSSTATUS		(0x00000014) /* RO */

#define OMAP3_INTC_SIR_IRQ		(0x00000040) /* RO */
#define OMAP3_INTC_SIR_FIQ		(0x00000044) /* RO */
#define OMAP3_INTC_CONTROL		(0x00000048) /* RW */
#define OMAP3_INTC_PROT			(0x0000004C) /* RW - Protection */
#define OMAP3_INTC_IDLE			(0x00000050) /* RW */

#define OMAP3_INTC_IRQ_PRIO		(0x00000060) /* RW - IRQ Priority */
#define OMAP3_INTC_FIQ_PRIO		(0x00000064) /* RW - FIQ Priority */
#define OMAP3_INTC_THREASHOLD		(0x00000068) /* RW */

#define OMAP3_INTC_ITR			(0x00000080) /* RO - Raw Interrupt Status*/
#define OMAP3_INTC_MIR			(0x00000084) /* RW - Masked Int Status */
#define OMAP3_INTC_MIR_CLR		(0x00000088) /* WO - Clear Mask*/
#define OMAP3_INTC_MIR_SET		(0x0000008C) /* WO - Set Mask*/
#define OMAP3_INTC_ISR_SET		(0x00000090) /* RW - Software Int Set */
#define OMAP3_INTC_ISR_CLR		(0x00000094) /* WO */
#define OMAP3_INTC_IRQ_PEND		(0x00000098) /* RO */
#define OMAP3_INTC_FIQ_PEND		(0x0000009C) /* RO */
#define OMAP3_INTC_ILR			(0x00000100) /* RW */

/* Reset Bits */
#define OMAP_INTC_SOFTRESET     (1 << 1)

static inline unsigned int omap3_intc_get_ilr(unsigned long base,
					     unsigned int irq)
{
	return read((base + OMAP3_INTC_ILR + (irq * 4)));
}

static inline void  omap3_intc_set_ilr(unsigned long base, unsigned int irq,
				       unsigned int val)
{
	write(val, (base + OMAP3_INTC_ILR + (irq * 4)));
}

/* Set clear Interrupt masks */
static inline
void omap3_intc_set_irq_status(unsigned long base, unsigned int reg,
			       unsigned int irq)
{
	unsigned int val = 0;
	unsigned int offset = (irq >> 5); /* Same as dividing by 32 */

	irq -= (offset * 32);

	val = read((base + reg + (0x20 * offset)));
        val |= (1 << irq);
	write(val, (base + reg + (0x20 * offset)));
}

void omap3_intc_reset(unsigned long base);
void omap3_intc_init(void);
void omap3_intc_eoi_irq(l4id_t irq);
void omap3_intc_mask_irq(l4id_t irq);
void omap3_intc_unmask_irq(l4id_t irq);
void omap3_intc_ack_irq(l4id_t irq);
void omap3_intc_ack_and_mask(l4id_t irq);
l4id_t omap3_intc_read_irq(void *data);

#endif	/* !__OMAP3_INTC_H__ */
