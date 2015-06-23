/*
 * Copyright (C) 2007 Bahadir Balban
 */
#include <task.h>
#include <vm_area.h>
#include <l4lib/exregs.h>
#include __INC_ARCH(mm.h)

#if defined(DEBUG_FAULT_HANDLING)
void arch_print_fault_params(struct fault_data *fault)
{
	printf("%s: Handling %s fault (%s abort) from %d. fault @ 0x%x, generic pte flags: 0x%x\n",
	       __TASKNAME__, (fault->reason & VM_READ) ? "read" :
	       (fault->reason & VM_WRITE) ? "write" : "exec",
	       is_prefetch_abort(fault->kdata->fsr) ? "prefetch" : "data",
	       fault->task->tid, fault->address, fault->pte_flags);
}
#else
void arch_print_fault_params(struct fault_data *fault) { }
#endif


void fault_handle_error(struct fault_data *fault)
{
	struct task_ids ids;

	/* Suspend the task */
	ids.tid = fault->task->tid;
	BUG_ON(l4_thread_control(THREAD_SUSPEND, &ids) < 0);

	BUG();
}

