/*
 * EB platform-specific initialisation and setup
 *
 * Copyright (C) 2009-2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 *
 */
#include <l4/generic/platform.h>
#include <l4/generic/bootmem.h>
#include INC_PLAT(offsets.h)
#include INC_ARCH(io.h)
#include <l4/generic/space.h>
#include <l4/generic/irq.h>
#include <l4/generic/cap-types.h>
#include INC_PLAT(platform.h)
#include INC_PLAT(irq.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(smp.h)

/*
 * FIXME: This is not a platform specific
 * call, we will move this out later
 */
void device_cap_init(struct kernel_resources *kres, int devtype,
		     int devnum, unsigned long base)
{
	struct capability *cap;

	cap =  alloc_bootmem(sizeof(*cap), 0);
	cap_set_devtype(cap, devtype);
	cap_set_devnum(cap, devnum);
	cap->start = __pfn(base);
	cap->end = cap->start + 1;
	cap->size = cap->end - cap->start;
	link_init(&cap->list);
	cap_list_insert(cap, &kres->devmem_free);
}

/*
 * The devices that are used by the kernel are mapped
 * independent of these capabilities, but these provide a
 * concise description of what is used by the kernel.
 */
int platform_setup_device_caps(struct kernel_resources *kres)
{
	device_cap_init(kres, CAP_DEVTYPE_UART, 1, PLATFORM_UART1_BASE);
	device_cap_init(kres, CAP_DEVTYPE_UART, 2, PLATFORM_UART2_BASE);
	device_cap_init(kres, CAP_DEVTYPE_UART, 3, PLATFORM_UART3_BASE);
	device_cap_init(kres, CAP_DEVTYPE_TIMER, 1, PLATFORM_TIMER1_BASE);
	device_cap_init(kres, CAP_DEVTYPE_KEYBOARD, 0, PLATFORM_KEYBOARD0_BASE);
	device_cap_init(kres, CAP_DEVTYPE_MOUSE, 0, PLATFORM_MOUSE0_BASE);

	return 0;
}

void init_platform_irq_controller()
{

	unsigned int sysctrl = PLATFORM_SYSCTRL_VBASE;
	write(SYSCTRL_UNLOCK, sysctrl + SYS_LOCK);
	write(PLD_CTRL1_INTMOD_WITHOUT_DCC, sysctrl + SYS_PLDCTL1);
	write(SYSCTRL_LOCK, sysctrl + SYS_LOCK);	/* Lock again */

#if defined (CONFIG_CPU_ARM11MPCORE) || defined (CONFIG_CPU_CORTEXA9)
	/* TODO: we need to map 64KB ?*/
	add_boot_mapping(MPCORE_PRIVATE_BASE, MPCORE_PRIVATE_VBASE,
			 PAGE_SIZE * 2, MAP_IO_DEFAULT);

	gic_dist_init(0, GIC0_DIST_VBASE);
	gic_cpu_init(0, GIC0_CPU_VBASE);

#else
	add_boot_mapping(PLATFORM_GIC1_BASE, PLATFORM_GIC1_VBASE, PAGE_SIZE*2,
			 MAP_IO_DEFAULT);

	gic_dist_init(1, GIC1_DIST_VBASE);
#endif

#if !defined (CONFIG_CPU_ARM11MPCORE) && !defined (CONFIG_CPU_CORTEXA9)
	gic_cpu_init(1, PLATFORM_GIC1_VBASE);
#endif
	irq_controllers_init();
}

void init_platform_devices()
{
	/* TIMER23 */
	add_boot_mapping(PLATFORM_TIMER1_BASE, PLATFORM_TIMER1_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

        /* KEYBOARD - KMI0 */
	add_boot_mapping(PLATFORM_KEYBOARD0_BASE, PLATFORM_KEYBOARD0_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	/* MOUSE - KMI1 */
	add_boot_mapping(PLATFORM_MOUSE0_BASE, PLATFORM_MOUSE0_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

}
