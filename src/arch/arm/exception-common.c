/*
 * Common exception handling code
 *
 * Copyright (C) 2008 - 2010 B Labs Ltd.
 * Written by Bahadir Balban
 */
#include <l4/generic/scheduler.h>
#include <l4/generic/thread.h>
#include <l4/api/thread.h>
#include <l4/generic/space.h>
#include <l4/generic/tcb.h>
#include <l4/generic/platform.h>
#include <l4/generic/debug.h>
#include <l4/lib/printk.h>
#include <l4/api/ipc.h>
#include <l4/api/kip.h>
#include <l4/api/errno.h>
#include INC_ARCH(exception.h)
#include INC_GLUE(memlayout.h)
#include INC_GLUE(memory.h)
#include INC_GLUE(mapping.h)
#include INC_GLUE(message.h)
#include INC_GLUE(ipc.h)
#include INC_SUBARCH(mm.h)


void abort_die(void)
{
	disable_irqs();
	print_early("Unhandled kernel abort.\n");
	print_early("Kernel panic.\n");
	print_early("Halting system...\n");
	while (1)
		;
}

struct ipc_state {
	u32 mr[MR_TOTAL];
	unsigned int flags;
};

void ipc_save_state(struct ipc_state *state)
{
	unsigned int *mr0_current = KTCB_REF_MR0(current);

	BUG_ON(!mr0_current);

	/* Save primary message registers */
	for (int i = 0; i < MR_TOTAL; i++)
		state->mr[i] = mr0_current[i];

	/* Save ipc flags */
	state->flags = tcb_get_ipc_flags(current);
}

void ipc_restore_state(struct ipc_state *state)
{
	unsigned int *mr0_current = KTCB_REF_MR0(current);

	BUG_ON(!mr0_current);

	/* Restore primary message registers */
	for (int i = 0; i < MR_TOTAL; i++)
		mr0_current[i] = state->mr[i];

	/* Restore ipc flags */
	tcb_set_ipc_flags(current, state->flags);
}

/* Send data fault ipc to the faulty task's pager */
int __attribute__((optimize("O0")))
fault_ipc_to_pager(u32 faulty_pc, u32 fsr, u32 far, u32 ipc_tag)
{
	int err;

	/* mr[0] has the fault tag. The rest is the fault structure */
	u32 mr[MR_TOTAL] = {
		[MR_TAG] = ipc_tag,
		[MR_SENDER] = current->tid
	};

	fault_kdata_t *fault = (fault_kdata_t *)&mr[MR_UNUSED_START];

	/* Fill in fault information to pass over during ipc */
	fault->faulty_pc = faulty_pc;
	fault->fsr = fsr;
	fault->far = far;

	/*
	 * Write pte of the abort address,
	 * which is different on pabt/dabt
	 */
	if (is_prefetch_abort(fsr))
		fault->pte = virt_to_pte(faulty_pc);
	else
		fault->pte = virt_to_pte(far);

	/*
	 * System calls save arguments (and message registers)
	 * on the kernel stack. They are then referenced from
	 * the caller's ktcb. Here, we forge a fault structure
	 * as if an ipc syscall has occured. Then the reference
	 * to the fault structure is set in the ktcb such that
	 * it lies on the mr0 offset when referred as the syscall
	 * context.
	 */

	/*
	 * Assign fault such that it overlaps
	 * as the MR0 reference in ktcb.
	 */
	current->syscall_regs = (syscall_context_t *)
				((unsigned long)&mr[0] -
				 offsetof(syscall_context_t, r3));

	/* Set current flags to short ipc */
	tcb_set_ipc_flags(current, IPC_FLAGS_SHORT);

	/* Detect if a pager is self-faulting */
	if (current->tid == current->pagerid) {
		printk("Pager (%d) faulted on itself. "
		       "FSR: 0x%x, FAR: 0x%x, PC: 0x%x pte: 0x%x CPU%d Exiting.\n",
		       current->tid, fault->fsr, fault->far,
		       fault->faulty_pc, fault->pte, smp_get_cpuid());
		thread_destroy(current);
	}

	/* Send ipc to the task's pager */
	if ((err = ipc_sendrecv(current->pagerid,
				current->pagerid, 0)) < 0) {
			BUG_ON(current->nlocks);

		/* Return on interrupt */
		if (err == -EINTR) {
			printk("Thread (%d) page-faulted "
			       "and got interrupted by its pager.\n",
			       current->tid);
			return err;
		} else { /* Suspend on any other error */
			printk("Thread (%d) faulted in kernel "
			       "and an error occured during "
			       "page-fault ipc. err=%d. "
			       "Suspending task.\n",
			       current->tid, err);
			current->flags |= TASK_SUSPENDING;
			sched_suspend_sync();
		}
	}
	return 0;
}

/*
 * When a task calls the kernel and the supplied user buffer is
 * not mapped, the kernel generates a page fault to the task's
 * pager so that the pager can make the decision on mapping the
 * buffer. Remember that if a task maps its own user buffer to
 * itself this way, the kernel can access it, since it shares
 * that task's page table.
 */
int pager_pagein_request(unsigned long addr, unsigned long size,
			 unsigned int flags)
{
	int err;
	u32 abort = 0;
	unsigned long npages = __pfn(align_up(size, PAGE_SIZE));
	struct ipc_state ipc_state;

	set_abort_type(abort, ABORT_TYPE_DATA);

	/* Save current ipc state */
	ipc_save_state(&ipc_state);

	/* For every page to be used by the
	 * kernel send a page-in request */
	for (int i = 0; i < npages; i++)
		if ((err = fault_ipc_to_pager(0, abort,
					      addr + (i * PAGE_SIZE),
					      L4_IPC_TAG_PFAULT)) < 0)
			return err;

	/* Restore ipc state */
	ipc_restore_state(&ipc_state);

	return 0;
}

/*
 * @r0: The address where the program counter was during the fault.
 * @r1: Contains the fault status register
 * @r2: Contains the fault address register
 */
void data_abort_handler(u32 faulted_pc, u32 dfsr, u32 dfar, u32 spsr)
{
	int ret;

	system_account_dabort();

	/* Indicate abort type on dfsr */
	set_abort_type(dfsr, ABORT_TYPE_DATA);

	dbg_abort("Data abort PC:0x%x, FAR: 0x%x, FSR: 0x%x, CPU%d\n",
		  faulted_pc, dfar, dfsr, smp_get_cpuid());

	/*
	 * Check abort type and tell
	 * if it's an irrecoverable fault
	 */
	if ((ret = check_abort_type(faulted_pc, dfsr, dfar, spsr)) < 0)
		goto die; /* Die if irrecoverable */
	else if (ret == ABORT_HANDLED)
		return;

	/* Notify the pager */
	fault_ipc_to_pager(faulted_pc, dfsr, dfar, L4_IPC_TAG_PFAULT);

	/*
	 * FIXME:
	 * Check return value of pager, and also make a record of
	 * the fault that has occured. We ought to expect progress
	 * from the pager. If the same fault is occuring a number
	 * of times consecutively, we might want to kill the pager.
	 */

	/* See if current task has various flags set by its pager */
	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	}

	return;
die:
	dprintk("FAR:", dfar);
	dprintk("PC:", faulted_pc);
	abort_die();
}

void prefetch_abort_handler(u32 faulted_pc, u32 ifsr, u32 ifar, u32 spsr)
{
	int ret;

	system_account_pabort();

	/* Indicate abort type on dfsr */
	set_abort_type(ifsr, ABORT_TYPE_PREFETCH);

	dbg_abort("Prefetch abort PC:0x%x, FAR: 0x%x, FSR: 0x%x, CPU%d\n",
		  faulted_pc, ifar, ifsr, smp_get_cpuid());

	/*
	 * Check abort type and tell
	 * if it's an irrecoverable fault
	 */

	if ((ret = check_abort_type(0, ifsr, ifar, spsr)) < 0)
		goto die; /* Die if irrecoverable */
	else if (ret == ABORT_HANDLED)
		return; /* Return if handled internally */

	/* Notify the pager */
	fault_ipc_to_pager(faulted_pc, ifsr, ifar, L4_IPC_TAG_PFAULT);

	/*
	 * FIXME:
	 * Check return value of pager, and also make a record of
	 * the fault that has occured. We ought to expect progress
	 * from the pager. If the same fault is occuring a number
	 * of times consecutively, we might want to kill the pager.
	 */

	/* See if current task has various flags set by its pager */
	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	}

	return;
die:
	dprintk("FAR:", ifar);
	abort_die();

}

void undefined_instr_handler(u32 undefined_address, u32 spsr, u32 lr)
{
	dbg_abort("Undefined instruction. PC:0x%x", undefined_address);

	system_account_undef_abort();

	fault_ipc_to_pager(undefined_address, 0, undefined_address,
			   L4_IPC_TAG_UNDEF_FAULT);

	if (!is_user_mode(spsr)) {
		dprintk("Undefined instruction occured in "
			"non-user mode. addr=", undefined_address);
		goto die;
	}

	/* See if current task has various flags set by its pager */
	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	}

	return;

die:
	abort_die();
}

extern int current_irq_nest_count;

/*
 * This is called right where the nest count is increased
 * in case the nesting is beyond the predefined max limit.
 * It is another matter whether this limit is enough to
 * guarantee the kernel stack is not overflown.
 *
 * FIXME: Take measures to recover. (E.g. disable irqs etc)
 *
 * Note that this is called in irq context, and it *also*
 * thrashes the designated irq stack which is only 12 bytes.
 *
 * It really is assumed the system has come to a halt when
 * this happens.
 */
void irq_overnest_error(void)
{
	printk("Irqs nested beyond limit. Current count: %d",
		current_irq_nest_count);
	print_early("System halted...\n");
	while(1)
		;
}

