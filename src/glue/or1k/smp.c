/*
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Authors: Prem Mallappa, Bahadir Balban
 *
 * SMP Initialization of cores.
 */

#include <l4/generic/platform.h>
#include INC_GLUE(smp.h)
#include INC_GLUE(init.h)
#include INC_GLUE(mapping.h)
#include INC_SUBARCH(cpu.h)
#include INC_SUBARCH(proc.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_ARCH(linker.h)
#include INC_ARCH(io.h)
#include <l4/drivers/irq/gic/gic.h>

unsigned long secondary_run_signal;
unsigned long secondary_ready_signal;

void __smp_start(void);

void smp_start_cores(void)
{
	void (*smp_start_func)(int) =
		(void (*)(int))virt_to_phys(__smp_start);

	/* FIXME: Check why this high-level version doesn't work */
	// v7_up_dcache_op_setway(CACHE_SETWAY_CLEAN);
	v7_clean_invalidate_setway();

	/* We dont probably need this, it is not listed as a requirement */
	arm_smp_inval_icache_entirely();

	/* Start other cpus */
	for (int cpu = 1; cpu < CONFIG_NCPU; cpu++) {
		printk("%s: Bringing up CPU%d\n", __KERNELNAME__, cpu);
		if ((platform_smp_start(cpu, smp_start_func)) < 0) {
			printk("FATAL: Could not start secondary cpu. "
			       "cpu=%d\n", cpu);
			BUG();
		}

		/* Wait for this particular secondary to become ready */
		while(!(secondary_ready_signal & CPUID_TO_MASK(cpu)))
			dmb();
	}

	scu_print_state();
}

void init_smp(void)
{
	/* Start_secondary_cpus */
	if (CONFIG_NCPU > 1) {
		/* This sets IPI function pointer at bare minimum */
		platform_smp_init(CONFIG_NCPU);
	}
}

void secondary_setup_idle_task(void)
{
	/* This also has its spid allocated by primary */
	current->space = &init_space;
	TASK_PGD(current) = &init_pgd;

	/* We need a thread id */
	current->tid = id_new(&kernel_resources.ktcb_ids);
}

/*
 * Idle wait before any tasks become available for running.
 *
 * FIXME: This should be changed such that tasks running on other
 * cpus can be killed and secondaries wait on an idle task.
 *
 * Currently the tasks are held in wfi() even if asked to be killed
 * until a new runnable task becomes runnable. This may be problematic
 * for a pager who issued a kill request and is waiting for it to finish.
 */
void sched_secondary_start(void)
{
	while (!secondary_run_signal)
		dmb();

	secondary_setup_idle_task();

	setup_idle_caps();

	idle_task();

	BUG();
}


/*
 * this is where it jumps from secondary_start(), which is called from
 * board_smp_start() to align each core to start here
 */

void smp_secondary_init(void)
{
	/* Print early core start message */
	// print_early("Secondary core started.\n");

	/* Start virtual memory */
	start_virtual_memory();

	arm_smp_inval_tlb_entirely();
	arm_smp_inval_bpa_entirely();
	dsb();
	isb();

	printk("%s: CPU%d: Virtual memory enabled.\n",
	       __KERNELNAME__, smp_get_cpuid());

	/* Mostly initialize GIC CPU interface */
	secondary_init_platform();

	printk("%s: CPU%d: Initialized.\n",
	       __KERNELNAME__, smp_get_cpuid());

	sched_init();

	/* Signal primary that we are ready */
	dmb();
	secondary_ready_signal |= cpu_mask_self();

	/*
	 * Wait for the first runnable task to become available
	 */
	sched_secondary_start();
}

