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

#undef DEBUG

#include <linux/kernel.h>
#include <linux/mm.h>
#include <linux/module.h>
#include <linux/list.h>
#include <linux/miscdevice.h>
#include <linux/ioport.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/types.h>
#include <linux/platform_device.h>
#include <linux/device.h>
#include <linux/interrupt.h>
#include <linux/io.h>
#include <linux/wait.h>
#include <linux/sched.h>
#include <linux/uaccess.h>
#include <linux/hugetlb.h>
#include <linux/highmem.h>

#include "mcomm.h"
#include "mcomm_compat.h"

struct mcomm_devdata {
	wait_queue_head_t wait; /* All waiting processes sleep here */
	struct cdev cdev;
	struct resource mem;
	void __iomem *mbox_mapped;
	void *platform_data;
	atomic_t refcount;
	unsigned int irq;
	unsigned int nr_mboxes;
	unsigned int mbox_size;
	unsigned int mbox_stride;
};

/* Only supports a single mcomm region. */
static struct mcomm_devdata _mcomm_devdata;

static struct mcomm_platform_ops *mcomm_platform_ops;



/* Wake up the process(es) corresponding to the mailbox(es) which just received
 * packets. */
static irqreturn_t mcomm_interrupt(int irq, void *dev_id)
{
	struct mcomm_devdata *devdata = dev_id;
	void __iomem *mbox;
	int i;

	mbox = devdata->mbox_mapped;
	for (i = 0; i < devdata->nr_mboxes; i++) {
		int active;

		switch (devdata->mbox_size) {
		case 1:
			active = readb(mbox);
			break;
		case 4:
			active = readl(mbox);
			break;
		default:
			active = 0;
		}

		if (active) {
			pr_debug("%s: waking mbox %d\n", __func__, i);
			wake_up_interruptible(&devdata->wait);
		}
		mbox += devdata->mbox_stride;
	}

	if (irq != NO_IRQ)
		mcomm_platform_ops->ack();

	return IRQ_HANDLED;
}

static int mcomm_mbox_pending(struct mcomm_devdata *devdata,
                              mcomm_mbox_t mbox_id)
{
	unsigned long mbox_offset;
	int active;

	mbox_offset = devdata->mbox_stride * mbox_id;

	switch (devdata->mbox_size) {
	case 1:
		active = readb(devdata->mbox_mapped + mbox_offset);
		break;
	case 4:
		active = readl(devdata->mbox_mapped + mbox_offset);
		break;
	default:
		active = 0;
	}

	if (active)
		pr_debug("mailbox %d (0x%lx) active; value 0x%x\n", mbox_id,
		         mbox_offset, active);
	else
		pr_debug("mailbox %d (0x%lx) not active\n", mbox_id, mbox_offset);

	return active;
}

static long mcomm_fd_ioctl_wait_read(struct mcomm_devdata *devdata,
                                     mcomm_mbox_t mbox_id)
{
	if (devdata->irq == NO_IRQ)
		return 0;

	return wait_event_interruptible(devdata->wait,
	                                mcomm_mbox_pending(devdata, mbox_id));
}

static long mcomm_fd_ioctl_notify(struct mcomm_devdata *devdata,
                                  mcomm_core_t target_core)
{
	/* If the target is the local core, call the interrupt handler directly. */
	if (target_core == mcomm_platform_ops->cpuid())
		mcomm_interrupt(NO_IRQ, devdata);
	else
		mcomm_platform_ops->notify(target_core);

	return 0;
}

static long mcomm_fd_ioctl(struct file *fp, unsigned int ioctl,
                           unsigned long arg)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;
	void __user *userptr = (void __user *)arg;
	long rc;

	switch (ioctl) {
	case MCOMM_CPUID: {
		u32 cpuid = mcomm_platform_ops->cpuid();

		rc = -EFAULT;
		if (copy_to_user(userptr, &cpuid, sizeof(cpuid)) == 0)
			rc = 0;
		break;
	}

	case MCOMM_WAIT_READ: {
		mcomm_mbox_t mbox_id;

		rc = -EFAULT;
		if (copy_from_user(&mbox_id, userptr, sizeof(mbox_id)) == 0) {
			pr_debug("%s: sleeping mbox %d\n", __func__, mbox_id);
			rc = mcomm_fd_ioctl_wait_read(devdata, mbox_id);
			pr_debug("%s: mbox %d woke up\n", __func__, mbox_id);
		}
		break;
	}

	case MCOMM_NOTIFY: {
		mcomm_core_t core_id;

		rc = -EFAULT;
		if (copy_from_user(&core_id, userptr, sizeof(core_id)) == 0) {
			pr_debug("%s: waking core %d\n", __func__, core_id);
			rc = mcomm_fd_ioctl_notify(devdata, core_id);
		}

		break;
	}

	default:
		rc = -EINVAL;
	}

	return rc;
}

static int __mcomm_follow_pte(struct mm_struct *mm, unsigned long address,
		pte_t **ptepp, spinlock_t **ptlp)
{
	pgd_t *pgd;
	pud_t *pud;
	pmd_t *pmd;
	pte_t *ptep;

	pgd = pgd_offset(mm, address);
	if (pgd_none(*pgd) || unlikely(pgd_bad(*pgd)))
		goto out;

	pud = pud_offset(pgd, address);
	if (pud_none(*pud) || unlikely(pud_bad(*pud)))
		goto out;

	pmd = pmd_offset(pud, address);
	VM_BUG_ON(pmd_trans_huge(*pmd));
	if (pmd_none(*pmd) || unlikely(pmd_bad(*pmd)))
		goto out;

	/* We cannot handle huge page PFN maps. Luckily they don't exist. */
	if (pmd_huge(*pmd))
		goto out;

	ptep = pte_offset_map_lock(mm, pmd, address, ptlp);
	if (!ptep)
		goto out;
	if (!pte_present(*ptep))
		goto unlock;
	*ptepp = ptep;
	return 0;
unlock:
	pte_unmap_unlock(ptep, *ptlp);
out:
	return -EINVAL;
}

static inline int mcomm_follow_pte(struct mm_struct *mm, unsigned long address,
			     pte_t **ptepp, spinlock_t **ptlp)
{
	int res;

	/* (void) is needed to make gcc happy */
	(void) __cond_lock(*ptlp,
			   !(res = __mcomm_follow_pte(mm, address, ptepp, ptlp)));
	return res;
}

#ifdef CONFIG_HAVE_IOREMAP_PROT
static int mcomm_follow_phys(struct vm_area_struct *vma,
		unsigned long address, unsigned int flags,
		unsigned long *prot, resource_size_t *phys)
{
	int ret = -EINVAL;
	pte_t *ptep, pte;
	spinlock_t *ptl;

	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP)))
		goto out;

	if (mcomm_follow_pte(vma->vm_mm, address, &ptep, &ptl))
		goto out;
	pte = *ptep;

	if ((flags & FOLL_WRITE) && !pte_write(pte))
		goto unlock;

	*prot = pgprot_val(pte_pgprot(pte));
	*phys = (resource_size_t)pte_pfn(pte) << PAGE_SHIFT;

	ret = 0;
unlock:
	pte_unmap_unlock(ptep, ptl);
out:
	return ret;
}

static int mcomm_access_phys(struct vm_area_struct *vma, unsigned long addr,
                             void *buf, int len, int write)
{
	resource_size_t phys_addr = 0;
	unsigned long prot = 0;
	void __iomem *maddr;
	int offset = addr & (PAGE_SIZE-1);

	if (mcomm_follow_phys(vma, addr, write, &prot, &phys_addr))
		return -EINVAL;

	maddr = ioremap_prot(phys_addr, PAGE_SIZE, prot);
	if (write)
		memcpy_toio(maddr + offset, buf, len);
	else
		memcpy_fromio(buf, maddr + offset, len);
	iounmap(maddr);

	return len;
}
#endif

static const struct vm_operations_struct mmap_mcomm_ops = {
#ifdef CONFIG_HAVE_IOREMAP_PROT
	.access = mcomm_access_phys
#endif
};

static int mcomm_mmap(struct file *file, struct vm_area_struct *vma)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;
	unsigned long start_page;

	if ((vma->vm_end - vma->vm_start) > resource_size(&devdata->mem))
		return -ENOMEM;

	vma->vm_page_prot = mcomm_platform_ops->mmap_pgprot(vma);
	vma->vm_ops = &mmap_mcomm_ops;

	start_page = devdata->mem.start >> PAGE_SHIFT;
	return remap_pfn_range(vma, vma->vm_start,
	                       start_page + vma->vm_pgoff,
	                       vma->vm_end - vma->vm_start,
	                       vma->vm_page_prot);
}

static int mcomm_fd_release(struct inode *inode, struct file *fp)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;

	/* XXX what happens to a thread blocked in ioctl? */

	if (atomic_dec_and_test(&devdata->refcount)) {
		if (devdata->irq != NO_IRQ)
			free_irq(devdata->irq, devdata);
		iounmap(devdata->mbox_mapped);
	}

	return 0;
}

static struct file_operations mcomm_fd_fops = {
	.release        = mcomm_fd_release,
	.unlocked_ioctl = mcomm_fd_ioctl,
	.compat_ioctl   = mcomm_fd_ioctl,
	.mmap           = mcomm_mmap,
};

static long mcomm_dev_initialize(struct mcomm_devdata *devdata, u32 offset,
                                 mcomm_mbox_t nr_mboxes, u32 mbox_size,
                                 u32 mbox_stride)
{
	resource_size_t mbox_paddr;
	long rc;

	if (offset + nr_mboxes * mbox_stride >= resource_size(&devdata->mem)) {
		printk(KERN_ERR "%s: mailboxes exceed memory area.\n", __func__);
		rc = -E2BIG;
		goto out1;
	}

	switch (mbox_size) {
	case 1:
	case 4:
		break;
	default:
		printk(KERN_ERR "%s: unsupported mailbox size %d\n", __func__,
		       mbox_size);
		rc = -EINVAL;
		goto out1;
	}

	/* Map only the memory encompassing the mailboxes. */
	mbox_paddr = devdata->mem.start + offset;
	devdata->mbox_mapped = mcomm_platform_ops->map(mbox_paddr,
	                                               nr_mboxes * mbox_stride);
	if (devdata->mbox_mapped == NULL) {
		printk(KERN_ERR "%s: failed to map the mailboxes.\n", __func__);
		rc = -EFAULT;
		goto out1;
	}

	devdata->mbox_size = mbox_size;
	devdata->mbox_stride = mbox_stride;
	devdata->nr_mboxes = nr_mboxes;

	if (devdata->irq != NO_IRQ) {
		rc = request_irq(devdata->irq, mcomm_interrupt, 0, "mcomm",
						 devdata);
		if (rc) {
			printk(KERN_ERR "%s: failed to reserve irq %d\n", __func__,
				   devdata->irq);
			goto out2;
		}
	}

	return 0;

out2:
	iounmap(devdata->mbox_mapped);
out1:
	return rc;
}

static long mcomm_dev_ioctl_init(struct mcomm_devdata *devdata, u32 offset,
                                 mcomm_mbox_t nr_mboxes, u32 mbox_size,
                                 u32 mbox_stride)
{
	long rc;

	if (atomic_inc_return(&devdata->refcount) > 1) {
		if ( (nr_mboxes != devdata->nr_mboxes) ||
		     (mbox_size != devdata->mbox_size) ||
		     (mbox_stride != devdata->mbox_stride)) {
			printk(KERN_ERR "%s: new configuration doesn't match old configuration.\n", __func__);
			rc = -EBUSY;
			goto out1;
		}
	} else {
		rc = mcomm_dev_initialize(devdata, offset, nr_mboxes, mbox_size,
		                          mbox_stride);
		if (rc)
			goto out1;
	}

	return mcomm_anon_inode_getfd("mcomm", &mcomm_fd_fops, devdata, O_RDWR);

out1:
	atomic_dec(&devdata->refcount);
	return rc;
}

static long mcomm_dev_ioctl(struct file *fp, unsigned int ioctl,
                            unsigned long arg)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;
	void __user *userptr = (void __user *)arg;
	long rc;

	switch (ioctl) {
	case MCOMM_INIT: {
		struct mcomm_init_device args;

		rc = -EFAULT;
		if (copy_from_user(&args, userptr, sizeof(args)) == 0)
			rc = mcomm_dev_ioctl_init(devdata, args.offset, args.nr_mboxes,
			                          args.mbox_size, args.mbox_stride);
		break;
	}

	default:
		rc = -EINVAL;
	}

	return rc;
}

static int mcomm_dev_open(struct inode *inode, struct file *fp)
{
	return 0;
}

static struct file_operations mcomm_dev_fops = {
	.open           = mcomm_dev_open,
	.unlocked_ioctl = mcomm_dev_ioctl,
	.compat_ioctl   = mcomm_dev_ioctl,
	.mmap           = mcomm_mmap,
};


static ssize_t mcomm_show_region_addr(struct device *dev,
                                      struct device_attribute *attr,
                                      char *buf)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;

	return sprintf(buf, "0x%llx\n", (unsigned long long)devdata->mem.start);
}
static DEVICE_ATTR(address, 0444, mcomm_show_region_addr, NULL);

static ssize_t mcomm_show_region_size(struct device *dev,
                                      struct device_attribute *attr,
                                      char *buf)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;

	return sprintf(buf, "0x%llx\n",
	               (unsigned long long)resource_size(&devdata->mem));
}
static DEVICE_ATTR(size, 0444, mcomm_show_region_size, NULL);

static struct attribute *mcomm_attributes[] = {
	&dev_attr_size.attr,
	&dev_attr_address.attr,
	NULL
};

static struct attribute_group mcomm_attr_group = {
	.attrs = mcomm_attributes,
};

struct miscdevice mcomm_misc_dev = {
	.fops = &mcomm_dev_fops,
	.minor = MISC_DYNAMIC_MINOR,
	.name = "mcomm0",
};

int mcomm_new_region(struct device *dev, struct resource *mem,
                     struct resource *irq)
{
	struct mcomm_devdata *devdata = &_mcomm_devdata;
	int rc;
	static int initialized;

	if (initialized++)
		return -EEXIST;

	init_waitqueue_head(&devdata->wait);
	devdata->mem = *mem;
	devdata->irq = irq->start;

	rc = sysfs_create_group(&dev->kobj, &mcomm_attr_group);
	if (rc) {
		printk(KERN_WARNING "%s: Failed to register sysfs attributes.\n",
		       __func__);
		goto out1;
	}

	rc = misc_register(&mcomm_misc_dev);
	if (rc) {
		printk("%s misc_register error %d\n", __func__, rc);
		goto out2;
	}

	return 0;

out2:
	sysfs_remove_group(&dev->kobj, &mcomm_attr_group);
out1:
	return rc;
}
EXPORT_SYMBOL(mcomm_new_region);

void mcomm_remove_region(struct device *dev)
{
	misc_deregister(&mcomm_misc_dev);
	sysfs_remove_group(&dev->kobj, &mcomm_attr_group);
}
EXPORT_SYMBOL(mcomm_remove_region);

int mcomm_init(struct mcomm_platform_ops *ops, struct module *module)
{
	int rc;

	rc = mcomm_init_anon_inodes();
	if (rc)
		goto out1;

	mcomm_platform_ops = ops;

	mcomm_dev_fops.owner = module;
	mcomm_fd_fops.owner = module;

	return 0;

out1:
	return rc;
}
EXPORT_SYMBOL(mcomm_init);

void mcomm_exit(void)
{
	mcomm_exit_anon_inodes();
}
EXPORT_SYMBOL(mcomm_exit);

MODULE_LICENSE("GPL v2");
MODULE_AUTHOR("Hollis Blanchard <hollis_blanchard@mentor.com>");
MODULE_DESCRIPTION("Shared memory communications channel");
