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
#include <linux/mod_devicetable.h>
#include <linux/of_platform.h>

#include <asm/io.h>
#include <asm/pgtable.h>
#include <asm/prom.h>
#include <asm/of_device.h>
#include <asm/fsl_msg.h>

#include "mcomm.h"

#define MESSAGE_VAL 1

struct notification {
	u32 core_id;
	u32 msg_num;
};

static struct mcomm_mpc85xx_data {
	struct fsl_msg_unit **notifications; /* Assumes contiguous PIRs. */
	int nr_notifications;
} mcomm_mpc85xx_data;



static pgprot_t mcomm_mpc85xx_mmap_pgprot(struct vm_area_struct *vma)
{
	return pgprot_cached(vma->vm_page_prot);
}

static void __iomem *mcomm_mpc85xx_ioremap(unsigned long phys_addr, size_t size)
{
	return ioremap_prot(phys_addr, size, _PAGE_COHERENT);
}

static void mcomm_mpc85xx_notify(u32 core_id)
{
	fsl_send_msg(mcomm_mpc85xx_data.notifications[core_id], MESSAGE_VAL);
}

static unsigned long mcomm_mpc85xx_cpuid(void)
{
	return mfspr(SPRN_PIR);
}

static void mcomm_mpc85xx_ack(void)
{
	fsl_clear_msg(mcomm_mpc85xx_data.notifications[mcomm_mpc85xx_cpuid()]);
}

static struct mcomm_platform_ops mcomm_mpc85xx_ops = {
	.mmap_pgprot = mcomm_mpc85xx_mmap_pgprot,
	.map = mcomm_mpc85xx_ioremap,
	.notify = mcomm_mpc85xx_notify,
	.ack = mcomm_mpc85xx_ack,
	.cpuid = mcomm_mpc85xx_cpuid,
};

static void mcomm_mpc85xx_hwuninit(void)
{
	int i;

	for (i = 0; i < mcomm_mpc85xx_data.nr_notifications; i++) {
		/* XXX leaves MER enabled? */
		fsl_release_msg_unit(mcomm_mpc85xx_data.notifications[i]);
	}
}

static int mcomm_mpc85xx_hwinit(const struct notification notifications[],
                                 int nr_notifications)
{
	struct mcomm_mpc85xx_data *data = &mcomm_mpc85xx_data;
	unsigned int cur_cpu = mcomm_mpc85xx_cpuid();
	struct fsl_msg_unit *self;
	int i;

	for (i = 0; i < nr_notifications; i++) {
		u32 core_id = notifications[i].core_id;
		u32 msg_num = notifications[i].msg_num;
		struct fsl_msg_unit *msgunit;

		msgunit = fsl_request_msg(msg_num);
		BUG_ON(IS_ERR(msgunit));
		data->notifications[core_id] = msgunit;
	}

	self = data->notifications[cur_cpu];

	/* Set our MIDR and enable ourselves in in MER. */
	fsl_set_msg_dest(self, cur_cpu);
	fsl_enable_msg(self);

	return self->irq;
}

static int mcomm_mpc85xx_remove(struct of_device *odev)
{
	struct mcomm_mpc85xx_data *data = &mcomm_mpc85xx_data;

	mcomm_remove_region(&odev->dev);

	mcomm_mpc85xx_hwuninit();

	kfree(data->notifications);

	return 0;
}

static int mcomm_mpc85xx_probe(struct of_device *odev,
                               const struct of_device_id *match)
{
	struct resource mem;
	struct resource irq;
	struct mcomm_mpc85xx_data *data = &mcomm_mpc85xx_data;
	const u32 *prop;
	int len;
	int rc;
	static int initialized;

	if (initialized++)
		return -EEXIST;

	rc = of_address_to_resource(odev->node, 0, &mem);
	if (rc < 0) {
		dev_err(&odev->dev, "invalid address\n");
		rc = -EINVAL;
		goto out1;
	}

	prop = of_get_property(odev->node, "notifications", &len);
	if (!prop) {
		dev_err(&odev->dev, "no message index\n");
		rc = -EINVAL;
		goto out1;
	}
	data->nr_notifications = len / sizeof(u32) / 2;
	data->notifications =
	            kmalloc(sizeof(data->notifications[0]) * data->nr_notifications,
	            GFP_KERNEL);
	if (!data->notifications) {
		rc = -ENOMEM;
		goto out1;
	}

	irq.start = mcomm_mpc85xx_hwinit((struct notification *)prop,
	                                  data->nr_notifications);

	rc = mcomm_new_region(&odev->dev, &mem, &irq);
	/* XXX check error path */
	if (rc)
		goto out2;

	return 0;

out2:
	mcomm_mpc85xx_remove(odev);
out1:
	return rc;
}


static const struct of_device_id mcomm_match_table[] = {
	{ .compatible	= "ment,mcomm", },
	{}
};

static struct of_platform_driver mcomm_of_driver = {
	.name = "mcomm",
	.match_table = mcomm_match_table,

	.probe = mcomm_mpc85xx_probe,
	.remove = mcomm_mpc85xx_remove,
};

/* Because our node isn't under the localbus or soc nodes, platform code won't
 * automatically create an of_device for it, so we have to do it ourselves. */
static void mcomm_mpc85xx_devices_find(void)
{
	struct device_node *node = NULL;
	int i = 0;

	for (node = NULL;
		 (node = of_find_compatible_node(node, NULL, "ment,mcomm")) != NULL;) {
		char bus_id[32];
		sprintf(bus_id, "%s.%d", node->name, i++);
		of_platform_device_create(node, bus_id, NULL);
	}
}

static void mcomm_mpc85xx_devices_remove(void)
{
	struct device_node *node = NULL;

	for (node = NULL;
		 (node = of_find_compatible_node(node, NULL, "ment,mcomm")) != NULL;) {
		struct of_device *odev = of_find_device_by_node(node);

		if (odev)
			of_device_unregister(odev);
	}
}

static int __init mcomm_mpc85xx_modinit(void)
{
	int rc;

	rc = mcomm_init(&mcomm_mpc85xx_ops, THIS_MODULE);
	if (rc) {
		printk(KERN_ERR "%s: mcomm_init failed\n", __func__);
		goto out1;
	}

	rc = of_register_platform_driver(&mcomm_of_driver);
	if (rc) {
		printk(KERN_ERR "%s: failed to register platform driver\n", __func__);
		goto out2;
	}

	mcomm_mpc85xx_devices_find();

	return 0;

out2:
	mcomm_exit();
out1:
	return rc;
}
module_init(mcomm_mpc85xx_modinit);

static void mcomm_mpc85xx_modexit(void)
{
	mcomm_mpc85xx_devices_remove();
	mcomm_exit();
	return of_unregister_platform_driver(&mcomm_of_driver);
}
module_exit(mcomm_mpc85xx_modexit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Hollis Blanchard <hollis_blanchard@mentor.com>");
MODULE_DESCRIPTION("Shared memory platform support for multi-core e500 processors using MPIC");
