/*
 * Copyright 2010 B Labs Ltd.
 *
 * Authors: Prem Mallappa, Bahadir Balban
 *
 * SMP support
 */
#ifndef __GLUE_ARM_SMP_H__
#define __GLUE_ARM_SMP_H__

#include INC_ARCH(scu.h)

struct cpuinfo {
	u32 ncpus;
	u32 flags;
        volatile u32 cpu_spinning;
        void (*send_ipi)(int cpu, int ipi_cmd);
        void (*smp_spin)(void);
	void (*smp_finish)(void);

} __attribute__ ((__packed__));

extern struct cpuinfo cpuinfo;

#if defined(CONFIG_SMP)

void smp_attach(void);
void smp_start_cores(void);

#else
static inline void smp_attach(void) {}
static inline void smp_start_cores(void) {}
#endif

void init_smp(void);
void arch_smp_spin(void);
void smp_send_ipi(unsigned int cpumask, int ipi_num);
void platform_smp_init(int ncpus);
int  platform_smp_start(int cpu, void (*start)(int));
void secondary_init_platform(void);

extern unsigned long secondary_run_signal;

#define CPUID_TO_MASK(cpu)	(1 << (cpu))

#endif
