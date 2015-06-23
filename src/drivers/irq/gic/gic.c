/*
 * Generic Interrupt Controller support.
 *
 * Copyright (C) 2009-2010 B Labs Ltd.
 *
 * Authors: Prem Mallappa, Bahadir Balban
 */
#include <l4/lib/bit.h>
#include <l4/lib/printk.h>
#include <l4/generic/irq.h>
#include INC_PLAT(irq.h)
#include INC_SUBARCH(mmu_ops.h)
#include <l4/drivers/irq/gic/gic.h>
#include <l4/generic/smp.h>

#define GIC_ACK_IRQ_MASK		0x1FF
#define GIC_ACK_CPU_MASK		0xE00
#define GIC_IRQ_SPURIOUS		0x3FF

volatile struct gic_data gic_data[IRQ_CHIPS_MAX];

static inline struct gic_data *get_gic_data(l4id_t irq)
{
	volatile struct irq_chip *chip = irq_desc_array[irq].chip;

	if (chip)
		return (struct gic_data *)chip->data;
	else
		return 0;
}

/* Returns the irq number on this chip converting the irq bitvector */
l4id_t gic_read_irq(void *data)
{
	volatile struct gic_data *gic = (struct gic_data *)data;
	l4id_t irq = gic->cpu->ack;

	/* This is an IPI - EOI it here, since it requires cpu field */
	if ((irq & GIC_ACK_IRQ_MASK) < 16) {
		gic_eoi_irq(irq);
		/* Get the actual irq number */
		irq &= GIC_ACK_IRQ_MASK;
	}

	/* Detect GIC spurious magic value and return generic one */
	if (irq == GIC_IRQ_SPURIOUS)
		return IRQ_SPURIOUS;
	return irq;
}

void gic_mask_irq(l4id_t irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 5; /* irq / 32 */

	gic->dist->clr_en[offset] = 1 << (irq % 32);
}

void gic_unmask_irq(l4id_t irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 5 ; /* irq / 32 */

	gic->dist->set_en[offset] = 1 << (irq % 32);
}

void gic_eoi_irq(l4id_t irq)
{
	/* Careful, irq may have cpu field encoded */
	volatile struct gic_data *gic =
		get_gic_data(irq & GIC_ACK_IRQ_MASK);

	gic->cpu->eoi = irq;
}

void gic_ack_and_mask(l4id_t irq)
{
	//printk("disable/eoi irq %d\n", irq);
	gic_mask_irq(irq);
	gic_eoi_irq(irq);
}

void gic_set_pending(l4id_t irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 5; /* irq / 32 */
	gic->dist->set_pending[offset] = 1 << (irq % 32);
}

void gic_clear_pending(l4id_t irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 5; /* irq / 32 */

	gic->dist->clr_pending[offset] = 1 << (irq % 32);
}


void gic_cpu_init(int idx, unsigned long base)
{
	volatile struct gic_cpu *cpu;

	gic_data[idx].cpu = (struct gic_cpu *)base;

	cpu = gic_data[idx].cpu;

	/* Disable */
	cpu->control = 0;

	/* Set */
	cpu->prio_mask = 0xf0;
	cpu->bin_point = 3;

	/* Enable */
	cpu->control = 1;
}

void gic_dist_init(int idx, unsigned long base)
{
	volatile struct gic_dist *dist;
	int irqs_per_word;
	int nirqs;

	gic_data[idx].dist = (struct gic_dist *)(base);

	dist = gic_data[idx].dist;

	/* Disable gic */
	dist->control = 0;

	/* 32*(N+1) interrupts supported */
	nirqs = 32 * ((dist->type & 0x1f) + 1);
	if (nirqs > IRQS_MAX)
		nirqs = IRQS_MAX;

	/* Disable all interrupts */
	irqs_per_word = 32;
	for (int i = 0; i < nirqs; i += irqs_per_word)
		dist->clr_en[i/irqs_per_word] = 0xffffffff;

	/* Clear all pending interrupts */
	for (int i = 0; i < nirqs; i += irqs_per_word)
		dist->clr_pending[i/irqs_per_word] = 0xffffffff;

	/* Set all irqs as normal priority, 8 bits per interrupt */
	irqs_per_word = 4;
	for (int i = 32; i < nirqs; i += irqs_per_word)
		dist->priority[i/irqs_per_word] = 0xa0a0a0a0;

	/* Set all target to cpu0, 8 bits per interrupt */
	for (int i = 32; i < nirqs; i += irqs_per_word)
		dist->target[i/irqs_per_word] = 0x01010101;

	/* Configure all to be level-sensitive, 2 bits per interrupt */
	irqs_per_word = 16;
	for (int i = 32; i < nirqs; i += irqs_per_word)
		dist->config[i/irqs_per_word] = 0x00000000;

	/* Enable GIC Distributor */
	dist->control = 1;
}


/* Some functions, may be helpful */
void gic_set_target(l4id_t irq, u32 cpu)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 2; /* irq / 4 */

	if (cpu > 1) {
		printk("Setting irqs to reach multiple cpu targets requires a"
		       "lock on the irq controller\n"
		       "GIC is a racy hardware in this respect\n");
		BUG();
	}

	gic->dist->target[offset] |= (cpu << ((irq % 4) * 8));
}

u32 gic_get_target(u32 irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 2; /* irq / 4 */
	unsigned int target = gic->dist->target[offset];

	BUG_ON(irq > 0xFF);
	target >>= ((irq % 4) * 8);

	return target & 0xFF;
}

void gic_set_priority(u32 irq, u32 prio)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 3; /* irq / 8 */

	BUG_ON(prio > 0xF);
	BUG_ON(irq > 0xFF);

	/* target = cpu << ((irq % 4) * 4) */
	gic->dist->target[offset] |= (prio << (irq & 0x1C));
}

u32 gic_get_priority(u32 irq)
{
	volatile struct gic_data *gic = get_gic_data(irq);
	u32 offset = irq >> 3; /* offset = irq / 8 */
	u32 prio = gic->dist->target[offset] & (irq & 0xFC);

	return prio;
}

#define IPI_CPU_SHIFT	16

void gic_send_ipi(int cpumask, int ipi_cmd)
{
	volatile struct gic_dist *dist = gic_data[0].dist;
	unsigned int ipi_word = (cpumask << IPI_CPU_SHIFT) | ipi_cmd;

	dist->soft_int = ipi_word;
}

void gic_print_cpu()
{
	volatile struct gic_cpu *cpu = gic_data[0].cpu;

	printk("GIC CPU%d highest pending: %d\n", smp_get_cpuid(), cpu->high_pending);
	printk("GIC CPU%d running: %d\n", smp_get_cpuid(), cpu->running);
}

/* Make the generic code happy */
void gic_dummy_init()
{

}
