
#include <l4/lib/spinlock.h>
#include <l4/lib/printk.h>

#include INC_GLUE(smp.h)
#include INC_SUBARCH(cpu.h)

DECLARE_SPINLOCK(smp_lock);

static unsigned long smp_var = 0;
static unsigned long signal_finished;

static unsigned long basic_var = 0;

void test_basic_coherent(void)
{
	dmb();
	if (smp_get_cpuid() == 0) {
		if (basic_var != 5555) {
			printk("FATAL: variable update not seen. var = %lu\n", basic_var);
			BUG();
		}
	} else {
		basic_var = 5555;
		dmb();
	}
}

void test_smp_coherent(void)
{
	int other;

	if (smp_get_cpuid() == 1)
		other = 0;
	else
		other = 1;

	/* Increment var */
	for (int i = 0; i < 1000; i++) {
		spin_lock(&smp_lock);
		smp_var++;
		spin_unlock(&smp_lock);
	}

	/* Signal finished */
	spin_lock(&smp_lock);
	signal_finished |= (1 << smp_get_cpuid());
	spin_unlock(&smp_lock);

	/* Wait for other to finish */
	while (!(signal_finished & (1 << other))) {
		dmb();
	}
	if (smp_get_cpuid() == 0) {
		printk("Total result: %lu\n", smp_var);
		if (smp_var != 2000) {
			printk("FATAL: Total result not as expected\n");
			BUG();
		}
		printk("%s: Success.\n", __FUNCTION__);
	}

}


static u32 make_mask(int ncpus)
{
	u32 mask = 0;
	while(--ncpus){
		mask |= CPUID_TO_MASK(ncpus);
	}
	mask |= CPUID_TO_MASK(0);

	return mask;
}

#ifndef MAX_IPIS
#define MAX_IPIS 15
#endif

void test_ipi(void)
{
	int ipi, cpu;
	for (ipi = 0; ipi <= MAX_IPIS; ipi++) {
		for (cpu = 0; cpu < CONFIG_NCPU; cpu++) {
			if (cpu == smp_get_cpuid())
				continue;
			printk("IPI %d from %d to %d\n", ipi, smp_get_cpuid(), cpu);
			arch_send_ipi(CPUID_TO_MASK(cpu), ipi);
		}
	}
	/* Send IPI to all cores at once */
	cpu = make_mask(CONFIG_NCPU);
	printk("IPI from %d to all\n", smp_get_cpuid());
	arch_send_ipi(cpu, 1);

	printk("IPI from %d to self\n", smp_get_cpuid());
	arch_send_ipi(0, 1);		/* Send IPI to self */
}
