#ifndef __PLATFORM_H__
#define __PLATFORM_H__
/*
 * Generic functions to be provided by every platform.
 *
 * Include only those API's that are needed by sources
 * outside the src/platform code.
 */

#include <l4/generic/resource.h>

void platform_init(void);

/* IRQ controller */
void irq_controller_init(void);
void platform_irq_enable(int irq);
void platform_irq_disable(int irq);

#define	dprintk(str, val)		\
{					\
	print_early(str);		\
	printhex8((val));		\
	print_early("\n");		\
}

void print_early(char *str);
void printhex8(unsigned int);

int platform_setup_device_caps(struct kernel_resources *kres);

void platform_test_cpucycles(void);

#endif /* __PLATFORM_H__ */
