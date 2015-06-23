/*
 * Copyright 2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#ifndef __VXA9_PLATSMP_H__
#define __VXA9_PLATSMP_H__

#include <l4/generic/irq.h>
#include <l4/generic/space.h>
#include <l4/drivers/irq/gic/gic.h>
#include <l4/generic/smp.h>
#include INC_GLUE(smp.h)
#include INC_PLAT(sysctrl.h)

void boot_secondary(int);
void platform_smp_init(int ncpus);
int platform_smp_start(int cpu, void (*start)(int));
void secondary_init_platform(void);

#endif /* VXA9_PLATSMP_H */
