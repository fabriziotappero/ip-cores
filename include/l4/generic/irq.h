/*
 * Generic irq handling definitions.
 *
 * Copyright (C) 2010 B Labs Ltd.
 */
#ifndef __GENERIC_IRQ_H__
#define __GENERIC_IRQ_H__

#include <l4/lib/string.h>
#include <l4/lib/wait.h>
#include <l4/lib/printk.h>
#include INC_PLAT(irq.h)
#include INC_ARCH(types.h)

/* Represents none or spurious irq */
#define IRQ_NIL				0xFFFFFFFF /* -1 */
#define IRQ_SPURIOUS			0xFFFFFFFE /* -2 */

/* Successful irq handling state */
#define IRQ_HANDLED				0

typedef void (*irq_op_t)(l4id_t irq);
struct irq_chip_ops {
	void (*init)();
	l4id_t (*read_irq)(void *data);
	irq_op_t ack_and_mask;
	irq_op_t unmask;
	void (*set_cpu)(l4id_t irq, unsigned int cpumask);
};

struct irq_chip {
	char name[32];
	int level;		/* Cascading level */
	int cascade;		/* The irq that lower chip uses on this chip */
	int start;		/* The global irq offset for this chip */
	int end;		/* End of this chip's irqs */
	void *data;		/* Anything that a of interest to a driver */
	struct irq_chip_ops ops;
};

struct irq_desc;
typedef int (*irq_handler_t)(struct irq_desc *irq_desc);
struct irq_desc {
	char name[8];
	struct irq_chip *chip;

	/* Thread registered for this irq */
	struct ktcb *task;

	/* Notification slot for this irq */
	int task_notify_slot;

	/* Waitqueue head for this irq */
	struct waitqueue_head wqh_irq;

	/* NOTE: This could be a list for multiple handlers for shared irqs */
	irq_handler_t handler;
};

extern struct irq_desc irq_desc_array[];
extern struct irq_chip irq_chip_array[];

static inline void irq_enable(int irq_index)
{
	struct irq_desc *this_irq = irq_desc_array + irq_index;
	struct irq_chip *this_chip = this_irq->chip;

	this_chip->ops.unmask(irq_index - this_chip->start);
}

static inline void irq_disable(int irq_index)
{
	struct irq_desc *this_irq = irq_desc_array + irq_index;
	struct irq_chip *this_chip = this_irq->chip;
	this_chip->ops.ack_and_mask(irq_index - this_chip->start);
}

static inline void irq_set_cpu(int irq_index, unsigned int cpumask)
{
	struct irq_desc *this_irq = irq_desc_array + irq_index;
	struct irq_chip *this_chip = this_irq->chip;

	this_chip->ops.set_cpu(irq_index - this_chip->start, cpumask);
}

int irq_register(struct ktcb *task, int notify_slot, l4id_t irq_index);
int irq_thread_notify(struct irq_desc *desc);

void do_irq(void);
void irq_controllers_init(void);

#endif /* __GENERIC_IRQ_H__ */
