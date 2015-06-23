/*
 * EB platform-specific initialisation and setup
 *
 * Copyright (C) 2009 B Labs Ltd.
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

/*
 * The devices that are used by the kernel are mapped
 * independent of these capabilities, but these provide a
 * concise description of what is used by the kernel.
 */
int platform_setup_device_caps(struct kernel_resources *kres)
{
#if 0
	struct capability *uart[4], *timer[4];

	/* Setup capabilities for userspace uarts and timers */
	uart[1] =  alloc_bootmem(sizeof(*uart[1]), 0);
	uart[1]->start = __pfn(PLATFORM_UART1_BASE);
	uart[1]->end = uart[1]->start + 1;
	uart[1]->size = uart[1]->end - uart[1]->start;
	cap_set_devtype(uart[1], CAP_DEVTYPE_UART);
	cap_set_devnum(uart[1], 1);
	link_init(&uart[1]->list);
	cap_list_insert(uart[1], &kres->devmem_free);

	uart[2] =  alloc_bootmem(sizeof(*uart[2]), 0);
	uart[2]->start = __pfn(PLATFORM_UART2_BASE);
	uart[2]->end = uart[2]->start + 1;
	uart[2]->size = uart[2]->end - uart[2]->start;
	cap_set_devtype(uart[2], CAP_DEVTYPE_UART);
	cap_set_devnum(uart[2], 2);
	link_init(&uart[2]->list);
	cap_list_insert(uart[2], &kres->devmem_free);

	uart[3] =  alloc_bootmem(sizeof(*uart[3]), 0);
	uart[3]->start = __pfn(PLATFORM_UART3_BASE);
	uart[3]->end = uart[3]->start + 1;
	uart[3]->size = uart[3]->end - uart[3]->start;
	cap_set_devtype(uart[3], CAP_DEVTYPE_UART);
	cap_set_devnum(uart[3], 3);
	link_init(&uart[3]->list);
	cap_list_insert(uart[3], &kres->devmem_free);

	/* Setup timer1 capability as free */
	timer[1] =  alloc_bootmem(sizeof(*timer[1]), 0);
	timer[1]->start = __pfn(PLATFORM_TIMER1_BASE);
	timer[1]->end = timer[1]->start + 1;
	timer[1]->size = timer[1]->end - timer[1]->start;
	cap_set_devtype(timer[1], CAP_DEVTYPE_TIMER);
	cap_set_devnum(timer[1], 1);
	link_init(&timer[1]->list);
	cap_list_insert(timer[1], &kres->devmem_free);
#endif
	return 0;
}

void init_platform_irq_controller()
{
#if 0
	unsigned int sysctrl = PLATFORM_SYSCTRL_VBASE;
	write(SYSCTRL_UNLOCK, sysctrl + SYS_LOCK);
	write(PLD_CTRL1_INTMOD_WITHOUT_DCC, sysctrl+SYS_PLDCTL1);
	write(SYSCTRL_LOCK, sysctrl + SYS_LOCK);		/* Lock again */
#ifdef CONFIG_CPU_ARM11MPCORE
	/* TODO: we need to map 64KB ?*/
	add_boot_mapping(ARM11MP_PRIVATE_MEM_BASE, EB_MPCORE_PRIV_MEM_VBASE,
			 PAGE_SIZE*2, MAP_IO_DEFAULT);

	gic_dist_init(0, GIC0_DIST_VBASE);
	gic_cpu_init(0, GIC0_CPU_VBASE);

#endif
	add_boot_mapping(PLATFORM_GIC1_BASE, PLATFORM_GIC1_VBASE, PAGE_SIZE*2,
			 MAP_IO_DEFAULT);

	gic_dist_init(1, GIC1_DIST_VBASE);
	gic_cpu_init(1, PLATFORM_GIC1_VBASE);

	irq_controllers_init();
#endif
}

void init_platform_devices()
{

}
