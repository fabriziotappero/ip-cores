/*
 * Low-level irq routines.
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Written by  Bahadir Balban
 * Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

void irq_local_disable_save(unsigned long *state)
{
	unsigned int tmp, tmp2;
	__asm__ __volatile__ (
		"mrs %0, cpsr_fc \n"
		"orr %1, %0, #0x80 \n"
		"msr cpsr_fc, %1 \n"
		: "=&r"(tmp), "=r"(tmp2)
		:
		: "cc"
		);
	*state = tmp;
}

void irq_local_restore(unsigned long state)
{
	__asm__ __volatile__ (
		"msr cpsr_fc, %0\n"
		:
		: "r"(state)
		: "cc"
		);
}

int irqs_enabled(void)
{
	int tmp;
	__asm__ __volatile__ (
		"mrs %0, cpsr_fc\n"
		: "=r"(tmp)
		);

	if (tmp & 0x80)
		return 0;

	return 1;
}
