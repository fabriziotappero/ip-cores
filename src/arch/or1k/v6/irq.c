/*
 * Low-level irq routines.
 *
 * Copyright (C) 2010 B Labs Ltd.
 * Written by  Bahadir Balban
 * Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

void irq_local_disable_save(unsigned long *state)
{
	unsigned int tmp;
	__asm__ __volatile__ (
		"mrs %0, cpsr_fc \n"
		"cpsid ia \n"
		: "=r"(tmp)
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

u8 l4_atomic_dest_readb(u8 *location)
{
	unsigned int tmp, res;
	__asm__ __volatile__ (
		"1: \n"
		"ldrex %0, [%2] \n"
		"strex %1, %3, [%2] \n"
		"teq %1, #0 \n"
		"bne 1b \n"
		: "=&r"(tmp), "=&r"(res)
		: "r"(location), "r"(0)
		: "cc", "memory"
		);

	return (u8)tmp;
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
