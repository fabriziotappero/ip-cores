/*
 * de2_70_console: simple console driver for Terasic DE2-70 board. Based on uartlite.c
 *
 * Copyright (C) 2010 Aleksander Osman
 *
 * This file is licensed under the terms of the GNU General Public License
 * version 2.  This program is licensed "as is" without any warranty of any
 * kind, whether express or implied.
 */

#include <linux/platform_device.h>
#include <linux/module.h>
#include <linux/console.h>
#include <linux/serial.h>
#include <linux/serial_core.h>
#include <linux/tty.h>
#include <linux/delay.h>
#include <linux/interrupt.h>
#include <linux/init.h>
#include <asm/io.h>


#define DE2_70_NAME			"ttyDE2"

/* ---------------------------------------------------------------------
 * Console driver operations
 */

static void de2_70_console_write(struct console *co, const char *s,
				unsigned int count)
{
	volatile char *tst = (char *)0xE0000000;
	
	while(count-- > 0) {
		tst[0] = s[0];
		s++;
	}
}

static int __devinit de2_70_console_setup(struct console *co, char *options)
{
	return 0;
}

static struct console de2_70_console = {
	.name	= DE2_70_NAME,
	.write	= de2_70_console_write,
	.setup	= de2_70_console_setup,
	.flags	= CON_PRINTBUFFER,
	.index	= -1, /* Specified on the cmdline (e.g. console=ttyUL0 ) */
};

static int __init de2_70_console_init(void)
{
	register_console(&de2_70_console);
	return 0;
}

console_initcall(de2_70_console_init);

/* ---------------------------------------------------------------------
 * Module setup/teardown
 */

int __init de2_70_init(void)
{
	return 0;
}

void __exit de2_70_exit(void)
{
}

module_init(de2_70_init);
module_exit(de2_70_exit);

MODULE_AUTHOR("Aleksander Osman <>");
MODULE_DESCRIPTION("DE2-70 console");
MODULE_LICENSE("GPL");
