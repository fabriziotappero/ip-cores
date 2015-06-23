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

#ifndef __MCOMM_H__
#define __MCOMM_H__

#include <linux/kernel.h>
#include <linux/ioctl.h>
#include <linux/cdev.h>
#include <linux/wait.h>
#include <linux/ioport.h>

typedef u32 mcomm_core_t;
typedef u32 mcomm_mbox_t;

/* Specify the layout of the mailboxes in shared memory */
#define MCOMM_INIT       _IOW('*', 0, struct mcomm_init_device)
/* All values in bytes */
struct mcomm_init_device {
	mcomm_mbox_t nr_mboxes;
	u32 offset; /* Offset from base of shared memory to first mailbox */
	u32 mbox_size;
	u32 mbox_stride; /* Offset from mailbox N to mailbox N+1 */
};

/* Get hardware-defined number for the current core */
#define MCOMM_CPUID      _IOR('*', 1, mcomm_core_t)

/* Block until data is available for specified mailbox */
#define MCOMM_WAIT_READ  _IOW('*', 2, mcomm_mbox_t)

/* Notify the specified core that data has been made available to it */
#define MCOMM_NOTIFY     _IOW('*', 3, mcomm_core_t)

#ifdef __KERNEL__

#ifndef NO_IRQ
#define NO_IRQ  0
#endif

struct vm_area_struct;

struct mcomm_platform_ops {
	pgprot_t (*mmap_pgprot)(struct vm_area_struct *vma);
	/* Can't call this "ioremap" because ARM #defines it to other names. */
	void __iomem *(*map)(unsigned long phys_addr, size_t size);
	void (*notify)(u32 core_nr);
	void (*ack)(void);
	unsigned long (*cpuid)(void);
};

int mcomm_init(struct mcomm_platform_ops *ops, struct module *module);
void mcomm_exit(void);

int mcomm_new_region(struct device *dev, struct resource *mem,
                     struct resource *irq);
void mcomm_remove_region(struct device *dev);

#endif /* __KERNEL__ */

#endif /* __MCOMM_H__ */
