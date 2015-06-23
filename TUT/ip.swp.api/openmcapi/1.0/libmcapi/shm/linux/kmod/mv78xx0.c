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
#include <linux/mm.h>
#include <linux/io.h>
#include <linux/module.h>
#include <linux/platform_device.h>

#include <asm/io.h>
#include <asm/pgtable.h>

#include "mcomm.h"
#include "mcomm_dev.h"

/* extracted from the bowels of Marvell's arch/arm/mach-feroceon-mv78xx0 */
/* XXX add these to appropriate Linux headers */
#define CPU_IF_BASE(cpu)		(0xF1020000 + ((cpu) << 14))
#define AHB_TO_MBUS_BASE          	CPU_IF_BASE
#define INBOUND_DOORBELL(cpu)	(AHB_TO_MBUS_BASE(cpu) + 0x400)
#define INBOUND_DOORBELL_MASK(cpu)	(AHB_TO_MBUS_BASE(cpu) + 0x404)

#define DOORBELL_NR 0
#define DOORBELL_VAL (1<<DOORBELL_NR)

static struct mcomm_mv78xx0_data {
	void __iomem *dbell[2]; /* "inbound" doorbells */
	void __iomem *dbell_mask;
	unsigned int cpu_nr;
} mcomm_mv78xx0_data;

/* MV78xx0 is a dual-core ARMv5 processor. It does not provide implicit data
 * cache coherence between the two cores, so to simplify software we map the
 * shared memory non-cacheable in both user and kernel space. */

static pgprot_t mcomm_mv78xx0_mmap_pgprot(struct vm_area_struct *vma)
{
	return pgprot_noncached(vma->vm_page_prot);
}

static void __iomem *mcomm_mv78xx0_ioremap(unsigned long phys_addr, size_t size)
{
	return ioremap_nocache(phys_addr, size);
}

static void mcomm_mv78xx0_notify(u32 core_nr)
{
	BUG_ON(core_nr > 1);

	/* set the other core's inbound doorbell */
	writel(DOORBELL_VAL, mcomm_mv78xx0_data.dbell[core_nr]);
}

static void mcomm_mv78xx0_ack(void)
{
	/* clear this core's inbound doorbell */
	writel(0x0, mcomm_mv78xx0_data.dbell[mcomm_mv78xx0_data.cpu_nr]);
}

static unsigned long mcomm_mv78xx0_cpuid(void)
{
	return mcomm_mv78xx0_data.cpu_nr;
}

static struct mcomm_platform_ops mcomm_mv78xx0_ops = {
	.mmap_pgprot = mcomm_mv78xx0_mmap_pgprot,
	.map = mcomm_mv78xx0_ioremap,
	.notify = mcomm_mv78xx0_notify,
	.ack = mcomm_mv78xx0_ack,
	.cpuid = mcomm_mv78xx0_cpuid,
};


static void mcomm_mv78xx0_hwinit(void)
{
	unsigned int cpu_nr;
	u32 reg;

	__asm__ __volatile__ (
		"mrc p15, 1, %0, c15, c1, 0 @ read control reg\n"
		: "=r" (reg)
	);

	cpu_nr = (reg >> 14) & 0x1;

	mcomm_mv78xx0_data.cpu_nr = cpu_nr;
	mcomm_mv78xx0_data.dbell[0] = ioremap(INBOUND_DOORBELL(0), 4);
	mcomm_mv78xx0_data.dbell[1] = ioremap(INBOUND_DOORBELL(1), 4);
	mcomm_mv78xx0_data.dbell_mask = ioremap(INBOUND_DOORBELL_MASK(cpu_nr), 4);

	/* Clear any pending interrupts. */
	writel(0x0, mcomm_mv78xx0_data.dbell[cpu_nr]);

	/* Enable IRQs for our doorbell bits. */
	writel(DOORBELL_VAL, mcomm_mv78xx0_data.dbell_mask);
}

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

	mcomm_mv78xx0_hwinit();

	return mcomm_new_region(&pdev->dev, mem, irq);
}

static void mcomm_mv78xx0_hwuninit(void)
{
	iounmap(mcomm_mv78xx0_data.dbell[0]);
	iounmap(mcomm_mv78xx0_data.dbell[1]);

	/* Disable doorbell IRQ again. */
	writel(0x0, mcomm_mv78xx0_data.dbell_mask);
	iounmap(mcomm_mv78xx0_data.dbell_mask);
}

static int mcomm_remove(struct platform_device *pdev)
{
	mcomm_remove_region(&pdev->dev);
	mcomm_mv78xx0_hwuninit();

	return 0;
}

static struct platform_driver mcomm_driver = {
	.probe = mcomm_probe,
	.remove = mcomm_remove,
	.driver = {
		   .name = "mcomm",
	}
};


static int __init mcomm_mv78xx0_modinit(void)
{
	int rc;

	rc = mcomm_init(&mcomm_mv78xx0_ops, THIS_MODULE);
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
		goto out3;

	return 0;

out3:
	platform_driver_unregister(&mcomm_driver);
out2:
	mcomm_exit();
out1:
	return rc;
}
module_init(mcomm_mv78xx0_modinit);

static void mcomm_mv78xx0_modexit(void)
{
	mcomm_pdev_release();
	platform_driver_unregister(&mcomm_driver);
	mcomm_exit();
}
module_exit(mcomm_mv78xx0_modexit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Hollis Blanchard <hollis_blanchard@mentor.com>");
MODULE_DESCRIPTION("Marvell 78xx0 platform support for multi-core shared memory channel");
