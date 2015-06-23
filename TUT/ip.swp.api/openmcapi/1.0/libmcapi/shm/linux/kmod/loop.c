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

/*
 * This file exists only to provide a driver for testing userspace code on
 * single-core platforms.
 *
 * The interrupt functions won't even be called. Instead of calling
 * ops->notify() for the single core, the higher level code directly calls its
 * interrupt handler instead.
 */

#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/platform_device.h>

#include "mcomm.h"
#include "mcomm_dev.h"

static pgprot_t mcomm_loop_mmap_pgprot(struct vm_area_struct *vma)
{
	return vma->vm_page_prot;
}

static void __iomem *mcomm_loop_ioremap(unsigned long phys_addr, size_t size)
{
#if defined(CONFIG_ARM)
	return ioremap_cached(phys_addr, size);
#elif defined(CONFIG_X86)
	return ioremap_cache(phys_addr, size);
#endif
	return ioremap(phys_addr, size);
}

static void mcomm_loop_notify(u32 core_nr)
{
	BUG();
}

static void mcomm_loop_ack(void)
{
	BUG();
}

static unsigned long mcomm_loop_cpuid(void)
{
	return 0;
}

static struct mcomm_platform_ops mcomm_loop_ops = {
	.mmap_pgprot = mcomm_loop_mmap_pgprot,
	.map = mcomm_loop_ioremap,
	.notify = mcomm_loop_notify,
	.ack = mcomm_loop_ack,
	.cpuid = mcomm_loop_cpuid,
};


static int __devinit mcomm_probe(struct platform_device *pdev)
{
	struct resource *mem;
	struct resource *irq;

	mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
	if (!mem)
		return -EINVAL;

	irq = platform_get_resource(pdev, IORESOURCE_IRQ, 0);
	if (!irq)
		return -EINVAL;

	return mcomm_new_region(&pdev->dev, mem, irq);
}

static int mcomm_remove(struct platform_device *pdev)
{
	mcomm_remove_region(&pdev->dev);

	return 0;
}

static struct platform_driver mcomm_driver = {
	.probe = mcomm_probe,
	.remove = mcomm_remove,
	.driver = {
		   .name = "mcomm",
	}
};

static int __init mcomm_loop_modinit(void)
{
	int rc;

	rc = mcomm_init(&mcomm_loop_ops, THIS_MODULE);
	if (rc) {
		printk(KERN_ERR "%s: Failed to initialize mcomm driver.\n", __func__);
		goto out1;
	}

	rc = platform_driver_register(&mcomm_driver);
	if (rc) {
		printk(KERN_ERR "%s: Failed to register platform driver.\n", __func__);
		goto out2;
	}

	/* Finally, register an mcomm device. We can only have one, so if there's
	 * an error we should just give up. */
	rc = mcomm_pdev_add();
	if (rc)
		goto out2;

	return 0;

out2:
	mcomm_exit();
out1:
	return rc;
}
module_init(mcomm_loop_modinit);

static void mcomm_loop_modexit(void)
{
	mcomm_pdev_release();
	platform_driver_unregister(&mcomm_driver);
	mcomm_exit();
}
module_exit(mcomm_loop_modexit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Hollis Blanchard <hollis_blanchard@mentor.com>");
MODULE_DESCRIPTION("Loopback driver for testing multi-core communications driver");
