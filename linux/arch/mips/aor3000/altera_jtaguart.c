/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <linux/init.h>
#include <linux/kernel.h>
#include <linux/platform_device.h>

struct resource altera_jtaguart_resources[] = {
	{
		.start	= 0x1FFFFFF0,
		.end	= 0x1FFFFFF7,
		.flags	= IORESOURCE_MEM,
	}, {
		.start	= 3,
		.end	= 3,
		.flags	= IORESOURCE_IRQ,
	}
};

static struct platform_device altera_jtaguart_device = {
	.name		= "altera_jtaguart",
	.id		= 0,
	.resource	= altera_jtaguart_resources,
	.num_resources	= ARRAY_SIZE(altera_jtaguart_resources),
};


static int __init aor3000_platform_init(void)
{
	platform_device_register(&altera_jtaguart_device);
	return 0;
}

device_initcall(aor3000_platform_init);
