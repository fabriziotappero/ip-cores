/*
 * Generic Interrupt Controller offsets
 *
 * Copyright (C) 2009 B Labs Ltd.
 *
 */

#ifndef __ARM_GIC_H__
#define __ARM_GIC_H__

#include <l4/types.h>
#include INC_PLAT(platform.h)
#include INC_PLAT(offsets.h)

/* CPU registers */
struct gic_cpu
{
	u32	  control;		/* Control Register */
	u32	  prio_mask;		/* Priority Mask */
	u32	  bin_point;		/* Binary Point Register */
	u32	  ack;			/* Interrupt */
	u32	  eoi;			/* End of Interrupt */
	u32	  running;		/* Running Priority register */
	u32	  high_pending;		/* Highest Pending Register */
};

#define NIRQ				1024
#define NREGS_1_BIT_PER_INT		32	/* when 1 bit per interrupt  */
#define NREGS_4_BIT_PER_INT		256
#define NREGS_4_BIT_PER_INT		256
#define NREGS_2_BIT_PER_INT		64
#define NID		4

/* Distributor registers */
/* -r- -- reserved */
struct	gic_dist{
	u32	  control;				/* Control Register */
	u32	  const	  type;				/* Type Register */
	u32	  dummy1[62];				/* -r- */
	u32	  set_en[NREGS_1_BIT_PER_INT];		/* Enable Set */
	u32	  clr_en[NREGS_1_BIT_PER_INT];		/* Enable Clear */
	u32	  set_pending[NREGS_1_BIT_PER_INT];	/* Set Pending */
	u32	  clr_pending[NREGS_1_BIT_PER_INT];	/* Clear Pending */
	u32	  active[NREGS_1_BIT_PER_INT];		/* Active Bit registers */
	u32	  dummy2[32];				/* -r- */
	u32	  priority[NREGS_4_BIT_PER_INT];	/* Interrupt Priority */
	u32	  target[NREGS_4_BIT_PER_INT];		/* CPU Target Registers */
	u32	  config[NREGS_2_BIT_PER_INT];		/* Interrupt Config */
	u32	  level[NREGS_2_BIT_PER_INT];		/* Interrupt Line Level */
	u32	  dummy3[64];				/* -r- */
	u32	  soft_int;				/* Software Interrupts */
	u32	  dummy4[55];				/* -r- */
	u32	  id[NID];				/* Primecell ID registers */
};


struct gic_data {
	struct gic_cpu *cpu;
	struct gic_dist *dist;
};


l4id_t gic_read_irq(void *data);

void gic_mask_irq(l4id_t irq);

void gic_unmask_irq(l4id_t irq);

void gic_ack_irq(l4id_t irq);

void gic_ack_and_mask(l4id_t irq);

void gic_clear_pending(l4id_t irq);

void gic_cpu_init(int idx, unsigned long base);

void gic_dist_init(int idx, unsigned long base);

void gic_send_ipi(int cpu, int ipi_cmd);

void gic_set_target(u32 irq, u32 cpu);

u32 gic_get_target(u32 irq);

void gic_set_priority(u32 irq, u32 prio);

u32 gic_get_priority(u32 irq);

void gic_dummy_init(void);

void gic_eoi_irq(l4id_t irq);

void gic_print_cpu(void);

#endif /* __GIC_H__ */
