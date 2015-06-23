/*
 * System Calls
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/mutex.h>
#include <l4/lib/printk.h>
#include <l4/generic/scheduler.h>
#include <l4/generic/tcb.h>
#include <l4/generic/resource.h>
#include <l4/generic/tcb.h>
#include <l4/generic/space.h>
#include <l4/generic/capability.h>
#include <l4/generic/container.h>
#include <l4/api/space.h>
#include <l4/api/ipc.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include <l4/api/exregs.h>
#include INC_API(syscall.h)
#include INC_ARCH(exception.h)

void print_syscall_context(struct ktcb *t)
{
	syscall_context_t *r = t->syscall_regs;

	printk("Thread id: %d registers: 0x%x, 0x%x, 0x%x, 0x%x, "
	       "0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x, 0x%x\n",
	       t->tid, r->spsr, r->r0, r->r1, r->r2, r->r3, r->r4,
	       r->r5, r->r6, r->r7, r->r8, r->sp_usr, r->lr_usr);
}

int sys_schedule(void)
{
	printk("(SVC) %s called. Tid (%d)\n", __FUNCTION__, current->tid);
	return 0;
}

int sys_getid(struct task_ids *ids)
{
	struct ktcb *this = current;
	int err;

	if ((err = check_access((unsigned long)ids,
				sizeof(struct task_ids),
				MAP_USR_RW, 1)) < 0)
		return err;

	ids->tid = this->tid;
	ids->spid = this->space->spid;
	ids->tgid = this->tgid;

	return 0;
}

int sys_container_control(unsigned int req, unsigned int flags, void *userbuf)
{
	return 0;
}


