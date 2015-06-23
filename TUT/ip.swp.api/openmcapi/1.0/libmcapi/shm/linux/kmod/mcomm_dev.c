/*
 * Copyright (c) 2010, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * Alternatively, this software may be distributed under the terms of the
 * GNU General Public License ("GPL") version 2 as published by the Free
 * Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

#include <linux/kernel.h>
#include <linux/module.h>
#include <linux/platform_device.h>
#include <linux/err.h>
#include <linux/ioport.h>

#include "mcomm.h"
#include "mcomm_dev.h"

static struct platform_device *mcomm_pdev;

static unsigned long mcomm_base;
module_param_named(base, mcomm_base, ulong, 0);
MODULE_PARM_DESC(base, "Physical address of the shared memory area");

static unsigned long mcomm_size;
module_param_named(size, mcomm_size, ulong, 0);
MODULE_PARM_DESC(size, "Size of the shared memory area");

static long mcomm_irq = NO_IRQ;
module_param_named(irq, mcomm_irq, long, 0);
MODULE_PARM_DESC(irq, "IRQ number used for interprocessor interrupts");

/* Allow user to manually specify the location of a shared memory region.
 * Of course, they must also have restricted the kernel's memory usage,
 * e.g. with the "mem=" kernel parameter. */
int mcomm_pdev_add(void)
{
	struct resource res[2];
	int rc = 0;

	if (!mcomm_size) {
		printk(KERN_ERR "%s: please provide base, size, and irq\n", __func__);
		return -EINVAL;
	}

	memset(res, 0, sizeof(res));

	res[0].start = mcomm_base;
	res[0].end = mcomm_base + mcomm_size - 1;
	res[0].flags = IORESOURCE_MEM,

	res[1].start = mcomm_irq;
	res[1].end = mcomm_irq;
	res[1].flags = IORESOURCE_IRQ,

	mcomm_pdev = platform_device_register_simple("mcomm", 0, res, 2);
	if (IS_ERR(mcomm_pdev)) {
		printk(KERN_WARNING "%s: Failed to create specified shared memory "
		        "device.\n", __func__);
		return PTR_ERR(mcomm_pdev);
	}

	return rc;
}
EXPORT_SYMBOL(mcomm_pdev_add);

void mcomm_pdev_release(void)
{
	platform_device_unregister(mcomm_pdev);
}
EXPORT_SYMBOL(mcomm_pdev_release);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Hollis Blanchard <hollis_blanchard@mentor.com>");
MODULE_DESCRIPTION("Manually specify shared memory area");
