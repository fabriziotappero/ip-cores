/*
 * Copyright 2010 B Labs.Ltd.
 *
 * Author: Prem Mallappa  <prem.mallappa@b-labs.co.uk>
 *
 * Description: SMP related platform definitions
 */
#include <l4/generic/platform.h>
#include INC_ARCH(io.h)
#include INC_SUBARCH(proc.h)
#include INC_PLAT(platform.h)
#include INC_PLAT(offsets.h)
#include INC_PLAT(sysctrl.h)
#include INC_GLUE(smp.h)
#include INC_GLUE(ipi.h)
#include INC_GLUE(mapping.h)
#include INC_SUBARCH(cpu.h)
#include <l4/drivers/irq/gic/gic.h>
#include <l4/lib/string.h>
#include <l4/generic/space.h>

extern struct irq_desc irq_desc_array[IRQS_MAX];

/* Print some SCU information */
void scu_print_state(void)
{
	volatile u32 scu_cfg = read(SCU_VBASE + SCU_CFG_REG);
	int ncpu = (scu_cfg & SCU_CFG_NCPU_MASK) + 1;
	printk("%s: SMP: %d CPU cluster, CPU", __KERNELNAME__, ncpu);
	for (int i = 0; i < ncpu; i++) {
		if ((1 << i) & (scu_cfg >> SCU_CFG_SMP_NCPU_SHIFT))
			printk("%d/", i);
	}
	printk(" are participating in SMP\n");

}

void scu_init(void)
{
	volatile u32 scu_ctrl =	read(SCU_VBASE + SCU_CTRL_REG);

	/* Enable the SCU */
	if (!(scu_ctrl & SCU_CTRL_EN))
		scu_ctrl |= SCU_CTRL_EN;

	write(scu_ctrl, SCU_VBASE + SCU_CTRL_REG);
}

void platform_smp_init(int ncpus)
{
	/* Add GIC SoftIRQ (aka IPI) */
	for (int i = 0; i < 16; i++) {
		strncpy(irq_desc_array[i].name, "SoftInt", 8);
		irq_desc_array[i].chip  = &irq_chip_array[0];
		irq_desc_array[i].handler = &ipi_handler;
	}

	add_boot_mapping(PLATFORM_SYSTEM_REGISTERS, PLATFORM_SYSREGS_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

}

int platform_smp_start(int cpu, void (*smp_start_func)(int))
{
 	/*
	 * Wake up just one core by writing the starting address to FLAGS
	 * register in SYSCTRL
	 */
	write(0xffffffff, SYS_FLAGS_CLR + PLATFORM_SYSREGS_VBASE);
	write((unsigned int)smp_start_func, SYS_FLAGS_SET + PLATFORM_SYSREGS_VBASE);
	dsb();	/* Make sure the write occurs */

	/* Wake up other core who is waiting on a WFI. */
	gic_send_ipi(CPUID_TO_MASK(cpu), 0);

	return 0;
}

void secondary_init_platform(void)
{
	gic_cpu_init(0, GIC0_CPU_VBASE);
}
