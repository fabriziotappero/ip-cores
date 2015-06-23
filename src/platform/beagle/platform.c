/*
 * Beagle Board platform-specific initialisation and setup
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/generic/platform.h>
#include <l4/generic/space.h>
#include <l4/generic/irq.h>
#include <l4/generic/bootmem.h>
#include INC_ARCH(linker.h)
#include INC_SUBARCH(mm.h)
#include INC_GLUE(mapping.h)
#include INC_SUBARCH(mmu_ops.h)
#include INC_GLUE(memory.h)
#include INC_PLAT(platform.h)
#include INC_PLAT(uart.h)
#include INC_PLAT(timer.h)
#include INC_PLAT(irq.h)
#include INC_ARCH(asm.h)
#include INC_PLAT(cm.h)

/*
 * The devices that are used by the kernel are mapped
 * independent of these capabilities, but these provide a
 * concise description of what is used by the kernel.
 */
int platform_setup_device_caps(struct kernel_resources *kres)
{
	struct capability *timer[1];

	/* Setup timer1 capability as free */
	timer[0] =  alloc_bootmem(sizeof(*timer[0]), 0);
	timer[0]->start = __pfn(PLATFORM_TIMER1_BASE);
	timer[0]->end = timer[0]->start + 1;
	timer[0]->size = timer[0]->end - timer[0]->start;
	cap_set_devtype(timer[0], CAP_DEVTYPE_TIMER);
	cap_set_devnum(timer[0], 1);
	link_init(&timer[0]->list);
	cap_list_insert(timer[0], &kres->devmem_free);

	return 0;
}

/*
 * Use UART2 for kernel as well as user tasks,
 * so map it to kernel and user space, this only
 * is provided by beagle board
 */
void init_platform_console(void)
{
	add_boot_mapping(PLATFORM_UART2_BASE, PLATFORM_CONSOLE_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	add_boot_mapping(PLATFORM_PERCM_BASE, PLATFORM_PERCM_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	/*
	 * Map same UART IO area to userspace so that primitive uart-based
	 * userspace printf can work. Note, this raw mapping is to be
	 * removed in the future, when file-based io is implemented.
	 */
	add_boot_mapping(PLATFORM_UART2_BASE, USERSPACE_CONSOLE_VBASE,
			 PAGE_SIZE, MAP_USR_IO);

	/* use 32KHz clock signal */
	omap_cm_clk_select(PLATFORM_PERCM_VBASE, 11,
			   OMAP_TIMER_CLKSRC_SYS_CLK);

	/* Enable Interface and Functional clock */
	omap_cm_enable_iclk(PLATFORM_PERCM_VBASE, 11);
	omap_cm_enable_fclk(PLATFORM_PERCM_VBASE, 11);

	uart_init(PLATFORM_CONSOLE_VBASE);
}

void platform_timer_start(void)
{
	/* Enable irq line for TIMER0 */
	irq_enable(IRQ_TIMER0);

	/* Enable timer */
	timer_start(PLATFORM_TIMER0_VBASE);
}

/*
 * We are using GPTIMER1 only, so we map GPTIMER1 base,
 * incase any other timer is needed we need to map it
 * to userspace or kernel space as needed
 */
void init_platform_timer(void)
{
	add_boot_mapping(PLATFORM_TIMER0_BASE, PLATFORM_TIMER0_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	add_boot_mapping(PLATFORM_WKUP_CM_BASE, PLATFORM_WKUP_CM_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

#if 0
	/* use 32KHz clock signal */
	omap_cm_clk_select(PLATFORM_WKUP_CM_VBASE, 0,
			   OMAP_TIMER_CLKSRC_32KHZ_CLK);
#else
	/*
	* Assumption: Beagle board RevC manual says,
	* it has 26MHz oscillator present, so we are
	* assuming this oscillator is our system clock
	*/
	omap_cm_clk_select(PLATFORM_WKUP_CM_VBASE, 0,
			   OMAP_TIMER_CLKSRC_SYS_CLK);
#endif

	/* Enable Interface and Functional clock */
	omap_cm_enable_iclk(PLATFORM_WKUP_CM_VBASE, 0);
	omap_cm_enable_fclk(PLATFORM_WKUP_CM_VBASE, 0);

	timer_init(PLATFORM_TIMER0_VBASE);
}

void init_platform_irq_controller()
{
	add_boot_mapping(PLATFORM_INTC_BASE, PLATFORM_INTC_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	irq_controllers_init();
}

void init_platform_devices()
{
	/* Add userspace devices here as you develop their irq handlers */
	add_boot_mapping(PLATFORM_TIMER1_BASE, PLATFORM_TIMER1_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

}

void platform_init(void)
{
	init_platform_console();
	init_platform_timer();
	init_platform_irq_controller();
	init_platform_devices();
}

