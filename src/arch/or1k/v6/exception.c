/*
 * Memory exception handling in process context.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <l4/generic/scheduler.h>
#include <l4/generic/thread.h>
#include <l4/api/thread.h>
#include <l4/generic/space.h>
#include <l4/generic/tcb.h>
#include <l4/generic/platform.h>
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

int check_abort_type(u32 faulted_pc, u32 fsr, u32 far, u32 spsr)
{
	int ret = 0;

	/*
	 * On ARMv5, prefetch aborts dont have different
	 * status values. We validate them here and return.
	 */
	if (is_prefetch_abort(fsr)) {
		dbg_abort("Prefetch abort @ ", faulted_pc);

		/* Happened in any mode other than user */
		if (!is_user_mode(spsr)) {
			dprintk("Unhandled kernel prefetch "
				"abort at address ", far);
			return -EABORT;
		}
		return 0;
	}

	switch (fsr & FSR_FS_MASK) {
	/* Aborts that are expected on page faults: */
	case DABT_PERM_PAGE:
		dbg_abort("Page permission fault @ ", far);
		ret = 0;
		break;
	case DABT_XLATE_PAGE:
		dbg_abort("Page translation fault @ ", far);
		ret = 0;
		break;
	case DABT_XLATE_SECT:
		dbg_abort("Section translation fault @ ", far);
		ret = 0;
		break;

	/* Aborts that can't be handled by a pager yet: */
	case DABT_TERMINAL:
		dprintk("Terminal fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_VECTOR:
		dprintk("Vector abort (obsolete!) @ ", far);
		ret = -EABORT;
		break;
	case DABT_ALIGN:
		dprintk("Alignment fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_XLATE_LEVEL1:
		dprintk("External LVL1 translation fault @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_XLATE_LEVEL2:
		dprintk("External LVL2 translation fault @ ", far);
		ret = -EABORT;
		break;
	case DABT_DOMAIN_SECT:
		dprintk("Section domain fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_DOMAIN_PAGE:
		dprintk("Page domain fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_PERM_SECT:
		dprintk("Section permission fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_LFETCH_SECT:
		dprintk("External section linefetch "
			"fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_LFETCH_PAGE:
		dprintk("Page perm fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_NON_LFETCH_SECT:
		dprintk("External section non-linefetch "
			"fault dabt @ ", far);
		ret = -EABORT;
		break;
	case DABT_EXT_NON_LFETCH_PAGE:
		dprintk("External page non-linefetch "
			"fault dabt @ ", far);
		ret = -EABORT;
		break;
	default:
		dprintk("FATAL: Unrecognised/Unknown "
			"data abort @ ", far);
		dprintk("FATAL: FSR code: ", fsr);
		ret = -EABORT;
	}

	/*
	 * Check validity of data abort's source.
	 *
	 * FIXME: Why not use spsr to do this?
	 */
	if (is_kernel_address(faulted_pc)) {
		dprintk("Unhandled kernel data "
			"abort at address ",
			faulted_pc);
		ret = -EABORT;
	}

	return ret;
}

#if 0
void data_abort_handler(u32 faulted_pc, u32 fsr, u32 far)
{
	set_abort_type(fsr, ARM_DABT);

	dbg_abort("Data abort @ PC: ", faulted_pc);

	//printk("Data abort: %d, PC: 0x%x\n",
	//current->tid, faulted_pc);

	/* Check for more details */
	if (check_aborts(faulted_pc, fsr, far) < 0) {
		printascii("This abort can't be handled by "
			   "any pager.\n");
		goto error;
	}

	/* This notifies the pager */
	fault_ipc_to_pager(faulted_pc, fsr, far, L4_IPC_TAG_PFAULT);

	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	} else if (current->flags & TASK_EXITING) {
		BUG_ON(current->nlocks);
		sched_exit_sync();
	}

	return;

error:
	disable_irqs();
	dprintk("Unhandled data abort @ PC address: ", faulted_pc);
	dprintk("FAR:", far);
	dprintk("FSR:", fsr);
	printascii("Kernel panic.\n");
	printascii("Halting system...\n");
	while (1)
		;
}

void prefetch_abort_handler(u32 faulted_pc, u32 fsr, u32 far, u32 spsr)
{
	set_abort_type(fsr, ARM_PABT);

	if (check_aborts(faulted_pc, fsr, far) < 0) {
		printascii("This abort can't be handled by any pager.\n");
		goto error;
	}

	/* Did the abort occur in kernel mode? */
	if ((spsr & ARM_MODE_MASK) == ARM_MODE_SVC)
		goto error;

	fault_ipc_to_pager(faulted_pc, fsr, far, L4_IPC_TAG_PFAULT);

	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	} else if (current->flags & TASK_EXITING) {
		BUG_ON(current->nlocks);
		sched_exit_sync();
	}

	return;

error:
	disable_irqs();
	dprintk("Unhandled prefetch abort @ address: ", faulted_pc);
	dprintk("FAR:", far);
	dprintk("FSR:", fsr);
	dprintk("Aborted PSR:", spsr);
	printascii("Kernel panic.\n");
	printascii("Halting system...\n");
	while (1)
		;
}

void undef_handler(u32 undef_addr, u32 spsr, u32 lr)
{
	dbg_abort("Undefined instruction @ PC: ", undef_addr);

	//printk("Undefined instruction: tid: %d, PC: 0x%x, Mode: %s\n",
	//       current->tid, undef_addr,
	//       (spsr & ARM_MODE_MASK) == ARM_MODE_SVC ? "SVC" : "User");

	if ((spsr & ARM_MODE_MASK) == ARM_MODE_SVC) {
		printk("Panic: Undef in Kernel\n");
		goto error;
	}

	fault_ipc_to_pager(undef_addr, 0, undef_addr, L4_IPC_TAG_UNDEF_FAULT);

	if (current->flags & TASK_SUSPENDING) {
		BUG_ON(current->nlocks);
		sched_suspend_sync();
	} else if (current->flags & TASK_EXITING) {
		BUG_ON(current->nlocks);
		sched_exit_sync();
	}

	return;

error:
	disable_irqs();
	dprintk("SPSR:", spsr);
	dprintk("LR:", lr);
	printascii("Kernel panic.\n");
	printascii("Halting system...\n");
	while(1)
		;
}
#endif

