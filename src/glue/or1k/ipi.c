/*
 * Copyright 2010 B Labs.Ltd.
 *
 * Author: Prem Mallappa  <prem.mallappa@b-labs.co.uk>
 *
 * Description: IPI handler for all ARM SMP cores
 */

#include INC_GLUE(ipi.h)
#include INC_GLUE(smp.h)
#include INC_SUBARCH(cpu.h)
#include <l4/lib/printk.h>
#include <l4/drivers/irq/gic/gic.h>
#include <l4/generic/time.h>

/* This should be in a file something like exception.S */
int ipi_handler(struct irq_desc *desc)
{
	int ipi_event = (desc - irq_desc_array) / sizeof(struct irq_desc);

//	printk("CPU%d: entered IPI%d\n", smp_get_cpuid(),
//	       (desc - irq_desc_array) / sizeof(struct irq_desc));

	switch (ipi_event) {
	case IPI_TIMER_EVENT:
		// printk("CPU%d: Handling timer ipi\n", smp_get_cpuid());
		secondary_timer_irq();
		break;
	default:
		printk("CPU%d: IPI with no meaning: %d\n",
		       smp_get_cpuid(), ipi_event);
		break;
	}
        return 0;
}

void smp_send_ipi(unsigned int cpumask, int ipi_num)
{
	gic_send_ipi(cpumask, ipi_num);
}

