/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <linux/interrupt.h>

#include <asm/irq_cpu.h>
#include <asm/mipsregs.h>

asmlinkage void plat_irq_dispatch(void)
{
    unsigned int pending;

    pending = read_c0_cause() & read_c0_status() & ST0_IM;

    if (pending & CAUSEF_IP2)
        do_IRQ(2);
    else if (pending & CAUSEF_IP3)
        do_IRQ(3);
    else if (pending & CAUSEF_IP4)
        do_IRQ(4);
    else if (pending & CAUSEF_IP5)
        do_IRQ(5);
    else if (pending & CAUSEF_IP6)
        do_IRQ(6);
    else if (pending & CAUSEF_IP7)
        do_IRQ(7);
    else
        spurious_interrupt();
}

void __init arch_init_irq(void)
{
        mips_cpu_irq_init();
}
