/***************************************************************************/

/*
 *  linux/arch/m68knommu/platform/ao68000/config.c
 *
 *  Copyright (C) 1993 Hamish Macdonald
 *  Copyright (C) 1999 D. Jeff Dionne
 *
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file COPYING in the main directory of this archive
 * for more details.
 *
 * VZ Support/Fixes             Evan Stawnyczy <e@lineo.ca>
 */

/***************************************************************************/

#include <linux/types.h>
#include <linux/kernel.h>
#include <asm/system.h>
#include <asm/machdep.h>


// EARLY PRINTK from arch/arm/kernel/early_printk.c ---------------------------------
#include <linux/console.h>
#include <linux/init.h>

//extern void printch(int);

static void early_write(const char *s, unsigned n)
{
	volatile char *uart = (char *)0xE0000000;
	
	while(n-- > 0) {
		uart[0] = s[0];
		s++;
	}
}

static void early_console_write(struct console *con, const char *s, unsigned n)
{
	early_write(s, n);
}

static struct console early_console = {
	.name =		"earlycon",
	.write =	early_console_write,
	.flags =	CON_PRINTBUFFER | CON_BOOT,
	.index =	-1,
};

asmlinkage void early_printk(const char *fmt, ...)
{
	char buf[512];
	int n;
	va_list ap;

	va_start(ap, fmt);
	n = vscnprintf(buf, sizeof(buf), fmt, ap);
	early_write(buf, n);
	va_end(ap);
}

static int __init setup_early_printk(char *buf)
{
	// blockes if called in (in_interrupt()) in kernel/printk.c
	register_console(&early_console);
	return 0;
}
//------------------------------------------------------------------------------------------


/***************************************************************************/

void m68328_timer_gettod(int *year, int *mon, int *day, int *hour, int *min, int *sec)
{
	*year = *mon = *day = 1;
	*hour = 2;
	*min = 3;
	*sec = 4;
}

/***************************************************************************/

void m68328_reset (void)
{
  local_irq_disable();
  while(1) { ; }
}

/***************************************************************************/

void config_BSP(char *command, int len)
{
//  setup_early_printk(command);

  printk(KERN_INFO "\nAO68000 support Aleksander Osman <alfik@poczta.fm>\n");

  mach_gettod = m68328_timer_gettod;
  mach_reset = m68328_reset;
}

/***************************************************************************/

static irqreturn_t hw_tick(int irq, void *dummy)
{
	return arch_timer_interrupt(irq, dummy);
}

/***************************************************************************/

static struct irqaction ao68000_timer_irq = {
	.name	 = "timer",
	.flags	 = IRQF_DISABLED | IRQF_TIMER,
	.handler = hw_tick,
};

/***************************************************************************/


void hw_timer_init(void)
{
	/* set ISR */
	setup_irq(0x01, &ao68000_timer_irq);
}

/***************************************************************************/
