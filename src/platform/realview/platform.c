/*
 * Realview generic initialisation and setup
 *
 * Copyright (C) 2009 B Labs Ltd.
 */
#include <l4/platform/realview/uart.h>
#include <l4/platform/realview/irq.h>
#include INC_PLAT(offsets.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(smp.h)
#include <l4/generic/irq.h>
#include <l4/generic/space.h>
#include <l4/generic/platform.h>
#include <l4/generic/smp.h>
#include INC_PLAT(platform.h)
#include INC_ARCH(io.h)

/* We will use UART0 for kernel as well as user tasks, so map it to kernel and user space */
void init_platform_console(void)
{
	add_boot_mapping(PLATFORM_UART0_BASE, PLATFORM_CONSOLE_VBASE, PAGE_SIZE,
			 MAP_IO_DEFAULT);

	/*
	 * Map same UART IO area to userspace so that primitive uart-based
	 * userspace printf can work. Note, this raw mapping is to be
	 * removed in the future, when file-based io is implemented.
	 */
	add_boot_mapping(PLATFORM_UART0_BASE, USERSPACE_CONSOLE_VBASE, PAGE_SIZE,
			 MAP_USR_IO);

	uart_init(PLATFORM_CONSOLE_VBASE);
}

void platform_timer_start(void)
{
	/* Enable irq line for TIMER0 */
	irq_enable(IRQ_TIMER0);

	/* Set cpu to all cpus for timer0 */
	// irq_set_cpu(IRQ_TIMER0, cpu_all_mask());

	/* Enable timer */
	timer_start(PLATFORM_TIMER0_VBASE);
}

void init_platform_timer(void)
{
	add_boot_mapping(PLATFORM_TIMER0_BASE, PLATFORM_TIMER0_VBASE, PAGE_SIZE,
			 MAP_IO_DEFAULT);

	/* 1 Mhz means can tick up to 1,000,000 times a second */
	timer_init(PLATFORM_TIMER0_VBASE, 1000000 / CONFIG_SCHED_TICKS);
}

/* If these bits are off, 32Khz OSC source is used */
#define TIMER3_SCTRL_1MHZ	(1 << 21)
#define TIMER2_SCTRL_1MHZ	(1 << 19)
#define TIMER1_SCTRL_1MHZ	(1 << 17)
#define TIMER0_SCTRL_1MHZ	(1 << 15)

/* Set all timers to use 1Mhz OSC clock */
void init_timer_osc(void)
{
	volatile u32 reg;

	add_boot_mapping(PLATFORM_SYSCTRL_BASE, PLATFORM_SYSCTRL_VBASE,
			 PAGE_SIZE, MAP_IO_DEFAULT);

	reg = read(SP810_SCCTRL);

	reg |= TIMER0_SCTRL_1MHZ | TIMER1_SCTRL_1MHZ
	       | TIMER2_SCTRL_1MHZ | TIMER3_SCTRL_1MHZ;

	write(reg, SP810_SCCTRL);

}

void platform_init(void)
{
	init_timer_osc();
	init_platform_console();
	init_platform_timer();
	init_platform_irq_controller();
	init_platform_devices();

#if defined (CONFIG_SMP)
	init_smp();
	scu_init();
#endif
}

